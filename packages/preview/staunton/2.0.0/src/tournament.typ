// ===========================================================================
// Tournament tables -- built from a parsed PGN's roster + results,
// no engine needed. Compute functions return plain data (testable); the
// `*-table` renderers turn that data into Typst `#table` content.
//
// Entity modes (`by`):
//   * "player" -- White/Black names; each game is one encounter.
//   * "team"   -- WhiteTeam/BlackTeam; games in one major round between the same
//                 two teams form a MATCH (board points summed; match points by
//                 board-point comparison).
//
// Standings are sorted by primary score (player: game points; team: match
// points) descending, then the `tiebreaks` in order, then first appearance in
// the file ("first mentioned on top"). Tie-breaks: "buchholz" (Σ opponents'
// final scores), "sonneborn-berger" (Σ opponent score × your result), and (team)
// "board-points".
//
// Tables are variant-agnostic (pure results). This module is Stage 1
// (standings); cross-table and progress come next.
// ===========================================================================

#import "style.typ": default-table-style, table-style-state, validate-table-style, _html-target
#import "i18n.typ": ui-string

// The 8 table-styling fields a `*-table` call accepts alongside the raw
// `#table` pass-through (see `_split-table-style`). Kept distinct from
// `title`/`caption`/`supplement`/`lang`, which every renderer already has as
// named parameters.
#let table-render-style-keys = (
  "grid", "header-align", "header-fill", "body-align", "body-fill",
  "table-align", "caption-bold", "highlight-winners",
)

// Split a `*-table` call's `..table-args.named()` into `(style-over, raw)`:
// a key goes to `style-over` iff it is one of `table-render-style-keys`, else
// it is a raw `#table` argument (and, per `_table-style-args`'s callers, wins
// over the presets).
#let _split-table-style(named) = {
  let style-over = (:)
  let raw = (:)
  for (k, v) in named {
    if table-render-style-keys.contains(k) { style-over.insert(k, v) } else { raw.insert(k, v) }
  }
  (style-over, raw)
}

// Pure builder for the `#table` styling args (`stroke`/`fill`/`align`) from a
// resolved style dictionary `st` (defaults + document state + per-call
// overrides). `cols`/`nrows` are the table's total column/row counts
// (including the header row); `name-col` is the column index holding the
// entity name (always 1, per the "exactly one name column" design decision).
// Kept pure (no state reads) so tests can pin its output directly.
#let _table-style-args(st, cols, nrows, name-col) = {
  let stroke = if st.grid == "complete" {
    (x, y) => (
      left: if x == 0 { 1pt } else { 0.5pt },
      top: if y == 0 { 1pt } else { 0.5pt },
      right: if x == cols - 1 { 1pt } else { none },
      bottom: if y == nrows - 1 { 1pt } else { none },
    )
  } else if st.grid == "no-outer" {
    (x, y) => (
      left: if x == 0 { none } else { 0.5pt },
      top: if y == 0 { none } else { 0.5pt },
      right: none,
      bottom: none,
    )
  } else {
    // "header-rule"
    (x, y) => (
      top: if y == 1 { 1pt } else { none },
      left: none, right: none, bottom: none,
    )
  }

  let header-fill = if st.header-fill == none { none }
    else if st.header-fill == "gray" { luma(230) }
    else { st.header-fill }
  let zebra-active = st.body-fill != none
  let zebra-shade = if st.body-fill == "zebra" { luma(245) } else { st.body-fill }
  let fill = (x, y) => {
    if y == 0 { header-fill }
    else if zebra-active and calc.even(y) { zebra-shade }
    else { none }
  }

  let align = (x, y) => {
    if y == 0 { st.header-align }
    else if x == name-col { left }
    else { st.body-align }
  }

  (stroke: stroke, fill: fill, align: align)
}

// Whether a given cell (at `col`) of a rank-1 row should be bolded for the
// "highlight-winners" feature: on, the entity is ranked 1st, and the cell is
// either the name column or the points/totals column (`name-col`/`pts-col`
// are per-renderer -- see each `*-table`'s call site). Pure (no state reads)
// so a test can pin it directly, same pattern as `_table-style-args`.
#let _winner-bold(highlight-winners, rank, col, name-col, pts-col) = {
  highlight-winners and rank == 1 and (col == name-col or col == pts-col)
}

// The crosstable's self/self diagonal cell fill: a distinct legible blue when
// the body zebra fill is active (it would otherwise wash the diagonal out on
// odd rows), else the original neutral gray. Pure.
#let _crosstable-diagonal-fill(body-fill) = {
  if body-fill != none { rgb("#c9d6e5") } else { luma(220) }
}

// The figure `kind` for tournament tables. Distinct from diagrams' "chess" so the
// two get separate counters and separate outlines. Public (re-exported by lib).
#let chess-table-kind = "chess-table"

// Wrap a rendered `#table` in a referenceable / outlineable #figure. `title` (a
// heading drawn ABOVE the table, inside the figure body) and `caption` (the
// figure caption, shown below and used by refs + outline) are both optional.
// `supplement` resolution: a per-call value wins; else the document
// `set-table-defaults` value; else (auto) the language-aware default
// ("Table"/"Tabelle"/...). `lang` (default auto -> document language) selects
// that localized default. The figure carries `kind: chess-table-kind`.
#let _table-figure(tbl, title, caption, supplement, lang, style-over) = {
  let body = if title == none { tbl } else {
    context {
      let gap = (default-table-style + table-style-state.get()).title-gap
      stack(dir: ttb, spacing: gap, title, tbl)
    }
  }
  let supp = if supplement != auto { supplement } else {
    context {
      let s = (default-table-style + table-style-state.get()).supplement
      if s == auto { ui-string(lang, "table-supplement") } else { s }
    }
  }
  // `table-align` resolves inside a CONTEXT NODE passed as `figure(..)`'s
  // `body:` ARGUMENT, not by wrapping the returned `figure(..)` call itself in
  // `context {}`/`show {..}`/`align(..)` -- any of those would make
  // `_table-figure` return an opaque wrapper node (context/styled/sequence/
  // align) instead of the figure element itself, which breaks BOTH `@label`
  // refs (a label can only attach to the figure directly) and native-HTML
  // table export (verified: even a bare `show`+`figure(..)` sibling pair, or
  // `align(.., figure(..))`, turns the return value into an unlabelable
  // "styled"/"align" node). Native HTML export doesn't support `align`
  // either, so skip it under `target() == "html"` (it would otherwise emit an
  // "align ignored" warning there).
  let aligned-body = context {
    let st = default-table-style + table-style-state.get() + style-over
    validate-table-style(st)
    if _html-target() { body } else { align(st.table-align, body) }
  }
  // `caption-bold` bolds the caller's caption text, resolved the same way --
  // inside a context node passed as `caption:`'s VALUE, never via a `show
  // figure.caption` rule (which, to affect the figure this call returns,
  // would have to be a sibling statement ahead of `figure(..)` in this same
  // block -- exactly the wrapping this function must avoid; see above).
  // Consequence: only the caller's caption text is boldable this way, not the
  // figure's own auto "Table N:" prefix (which Typst composes internally, out
  // of reach without that same forbidden `show` rule); a caption-align knob
  // (matching `table-align`) was spiked and hits the identical wall, so it is
  // NOT implemented -- the caption keeps its default position/alignment.
  let styled-caption = if caption == none { none } else {
    context {
      let st = default-table-style + table-style-state.get() + style-over
      validate-table-style(st)
      if st.caption-bold { strong(caption) } else { caption }
    }
  }
  // A caption-less table is referenceable but unlisted (see the `caption`
  // docstring): gate `outlined` on the caption so it leaves no blank outline row.
  figure(aligned-body, kind: chess-table-kind, supplement: supp, caption: styled-caption, outlined: caption != none)
}

// "1-0"/"0-1"/"1/2-1/2" -> (white, black) scores; anything else (e.g. "*") -> none.
#let _result-scores(r) = {
  if r == "1-0" { (1.0, 0.0) }
  else if r == "0-1" { (0.0, 1.0) }
  else if r == "1/2-1/2" { (0.5, 0.5) }
  else { none }
}

// Major round from a "round.board" tag ("5.3" -> 5); none if absent/non-numeric.
#let _major-round(round) = {
  if round == none { return none }
  let s = if type(round) == str { round } else { str(round) }
  let head = s.split(".").at(0)
  if head.match(regex("^[0-9]+$")) != none { int(head) } else { none }
}

// Format a score: 4 -> "4", 4.5 -> "4½", 0.5 -> "½".
#let _fmt(x) = {
  let whole = calc.floor(x)
  let frac = x - whole
  if frac == 0 { str(whole) }
  else if frac == 0.5 { (if whole == 0 { "" } else { str(whole) }) + "½" }
  else { str(x) }
}

/// Split a games array into a dict keyed by the `Event` tag, preserving insertion
/// order within each event. Games without an `Event` tag group under `""`.
///
/// - games (array): parsed games (from `games`).
/// -> dictionary
#let games-by-event(games) = {
  let out = (:)
  for g in games {
    let e = g.tags.at("Event", default: "")
    let cur = out.at(e, default: ())
    cur.push(g)
    out.insert(e, cur)
  }
  out
}

// Group games into team matches: all games in one major round between the same
// two teams (board points summed). Returns a list of match records, in
// first-seen order:
//   (round, a, b, sa, sb, oa, ob, mpa, mpb)  -- board points sa/sb, outcomes
//   oa/ob (1/0.5/0), match points mpa/mpb. Used by team standings, cross-table
//   and progress.
#let _team-matches(games, mp) = {
  let matches = (:)
  let mkeys = ()
  for (gi, g) in games.enumerate() {
    let wt = g.tags.at("WhiteTeam", default: none)
    let bt = g.tags.at("BlackTeam", default: none)
    let r = _result-scores(g.tags.at("Result", default: "*"))
    if r == none or wt == none or bt == none { continue }
    let rnd = _major-round(g.tags.at("Round", default: none))
    let pair = (wt, bt).sorted()
    let key = repr((if rnd == none { gi } else { rnd }, pair))
    let m = matches.at(key, default: (round: rnd, a: pair.at(0), b: pair.at(1), sa: 0.0, sb: 0.0))
    if wt == m.a { m.sa += r.at(0); m.sb += r.at(1) } else { m.sa += r.at(1); m.sb += r.at(0) }
    if not (key in matches) { mkeys.push(key) }
    matches.insert(key, m)
  }
  mkeys.map(k => {
    let m = matches.at(k)
    let (oa, ob) = if m.sa > m.sb { (1.0, 0.0) } else if m.sa < m.sb { (0.0, 1.0) } else { (0.5, 0.5) }
    let pts(o) = if o == 1.0 { mp.win } else if o == 0.5 { mp.draw } else { mp.loss }
    (round: m.round, a: m.a, b: m.b, sa: m.sa, sb: m.sb, oa: oa, ob: ob, mpa: pts(oa), mpb: pts(ob))
  })
}

// Build (order, encounters) for the chosen mode. An encounter is one entity's
// view of one game (player) or match (team):
//   (entity, opp, points, outcome, secondary)
// where `points` feeds the primary score, `outcome` is 1/0.5/0 (for SB), and
// `secondary` is the board-point contribution (team) or game score (player).
#let _encounters(games, by, mp) = {
  let order = ()
  let seen = (:)
  let enc = ()

  if by == "player" {
    for g in games {
      let w = g.tags.at("White", default: none)
      let b = g.tags.at("Black", default: none)
      for nm in (w, b) {
        if nm != none and not seen.at(nm, default: false) { seen.insert(nm, true); order.push(nm) }
      }
      let r = _result-scores(g.tags.at("Result", default: "*"))
      if r == none or w == none or b == none { continue }
      enc.push((entity: w, opp: b, points: r.at(0), outcome: r.at(0), secondary: r.at(0)))
      enc.push((entity: b, opp: w, points: r.at(1), outcome: r.at(1), secondary: r.at(1)))
    }
  } else if by == "team" {
    for g in games {
      for nm in (g.tags.at("WhiteTeam", default: none), g.tags.at("BlackTeam", default: none)) {
        if nm != none and not seen.at(nm, default: false) { seen.insert(nm, true); order.push(nm) }
      }
    }
    for m in _team-matches(games, mp) {
      enc.push((entity: m.a, opp: m.b, points: m.mpa, outcome: m.oa, secondary: m.sa))
      enc.push((entity: m.b, opp: m.a, points: m.mpb, outcome: m.ob, secondary: m.sb))
    }
  } else {
    panic("tournament: `by` must be \"player\" or \"team\"; got " + repr(by))
  }
  (order: order, enc: enc)
}

#let _default-tiebreaks(by) = if by == "team" { ("board-points", "sonneborn-berger") } else { ("buchholz", "sonneborn-berger") }

#let _tb-value(rec, tb) = {
  if tb == "buchholz" { rec.buchholz }
  else if tb == "sonneborn-berger" { rec.sonneborn-berger }
  else if tb == "board-points" { rec.at("board-points", default: 0.0) }
  else { panic("tournament: unknown tiebreak " + repr(tb)) }
}

/// Compute standings — an array of records sorted best-first: `(rank, name,
/// score, played, wins, draws, losses, buchholz, sonneborn-berger, [board-points
/// for teams])`.
///
/// - games (array): parsed games (from `games`).
/// - by (str): `"player"` or `"team"`.
/// - tiebreaks (auto, array): ordered tiebreak keys, or `auto` for the mode
///   default.
/// - match-points (dictionary): team match-point values, `(win:, draw:, loss:)`.
/// -> array
#let standings(games, by: "player", tiebreaks: auto, match-points: (win: 2, draw: 1, loss: 0)) = {
  let tbs = if tiebreaks != auto { tiebreaks } else { _default-tiebreaks(by) }
  let r = _encounters(games, by, match-points)

  // aggregate
  let data = (:)
  for (i, n) in r.order.enumerate() {
    data.insert(n, (name: n, score: 0.0, played: 0, wins: 0, draws: 0, losses: 0, secondary: 0.0, opps: (), idx: i))
  }
  for e in r.enc {
    let d = data.at(e.entity)
    d.score += e.points
    d.played += 1
    d.secondary += e.secondary
    if e.outcome == 1.0 { d.wins += 1 } else if e.outcome == 0.5 { d.draws += 1 } else { d.losses += 1 }
    d.opps.push((opp: e.opp, outcome: e.outcome))
    data.insert(e.entity, d)
  }
  // tie-breaks need every entity's final score, so compute after aggregation
  for n in r.order {
    let d = data.at(n)
    let bh = 0.0
    let sb = 0.0
    for o in d.opps { let os = data.at(o.opp).score; bh += os; sb += os * o.outcome }
    d.insert("buchholz", bh)
    d.insert("sonneborn-berger", sb)
    d.insert("board-points", d.secondary)
    data.insert(n, d)
  }

  // sort: stable passes least-significant first (idx base -> tiebreaks reversed
  // -> primary score), so score is the dominant key and idx the final tie-break.
  let s = r.order.map(n => data.at(n))
  for tb in tbs.rev() { s = s.sorted(key: d => -_tb-value(d, tb)) }
  s = s.sorted(key: d => -d.score)

  let out = ()
  for (i, d) in s.enumerate() {
    let rank = if i > 0 and s.at(i - 1).score == d.score { out.at(i - 1).rank } else { i + 1 }
    let rec = (
      rank: rank, name: d.name, score: d.score, played: d.played,
      wins: d.wins, draws: d.draws, losses: d.losses,
      buchholz: d.buchholz, sonneborn-berger: d.sonneborn-berger,
    )
    if by == "team" { rec.insert("board-points", d.at("board-points")) }
    out.push(rec)
  }
  out
}

#let _tb-label = (buchholz: "Bh", sonneborn-berger: "SB", board-points: "BP")

/// Render a standings table as a Typst `#table` figure (kind `"chess-table"`).
/// The data options are exactly as for `standings`.
///
/// - games (array): parsed games (from `games`).
/// - by (str): `"player"` or `"team"`.
/// - tiebreaks (auto, array): as for `standings`.
/// - match-points (dictionary): as for `standings`.
/// - title (none, content): a title shown above the table.
/// - caption (none, content): the figure caption (needed for the table to appear
///   in `table-outline`).
/// - supplement (auto, content): the figure supplement; `auto` is language-aware.
/// - lang (auto, str): language for defaults; `auto` follows the document.
/// - ..table-args (arguments): forwarded to `#table`.
/// -> content
#let standings-table(games, by: "player", tiebreaks: auto, match-points: (win: 2, draw: 1, loss: 0), title: none, caption: none, supplement: auto, lang: auto, ..table-args) = {
  let tbs = if tiebreaks != auto { tiebreaks } else { _default-tiebreaks(by) }
  let rows = standings(games, by: by, tiebreaks: tiebreaks, match-points: match-points)
  let (style-over, raw) = _split-table-style(table-args.named())
  let cols = 7 + tbs.len()
  let nrows = rows.len() + 1

  // Column headers are language-aware, so they resolve inside a `context`
  // (tiebreak abbreviations are internationally standardized -> not localized).
  let tbl = context {
    let st = default-table-style + table-style-state.get() + style-over
    validate-table-style(st)
    let sa = _table-style-args(st, cols, nrows, 1)

    let body = ()
    for r in rows {
      let name-cell = if _winner-bold(st.highlight-winners, r.rank, 1, 1, 6) { strong[#r.name] } else { [#r.name] }
      let pts-cell = if _winner-bold(st.highlight-winners, r.rank, 6, 1, 6) { strong[#_fmt(r.score)] } else { [#_fmt(r.score)] }
      body += (
        [#r.rank], name-cell, [#r.played], [#r.wins], [#r.draws], [#r.losses], pts-cell,
      ) + tbs.map(tb => [#_fmt(_tb-value(r, tb))])
    }

    let name-h = if by == "team" { ui-string(lang, "tbl-team") } else { ui-string(lang, "tbl-player") }
    let header = (
      [*#ui-string(lang, "tbl-rank")*], [*#name-h*], [*#ui-string(lang, "tbl-played")*],
      [*+*], [*=*], [*\u{2212}*], [*#ui-string(lang, "tbl-points")*],
    ) + tbs.map(tb => [*#_tb-label.at(tb)*])
    table(
      columns: cols,
      ..(stroke: sa.stroke, fill: sa.fill, align: sa.align) + raw,
      table.header(repeat: true, ..header),
      ..body,
    )
  }
  _table-figure(tbl, title, caption, supplement, lang, style-over)
}

// ---- cross-table (round-robin only) ---------------------------------------

/// Cross-table for a round-robin: `(names, ranks, totals, matrix)`, rows/cols in
/// standings order, `matrix.at(i).at(j)` entity i's score vs j (player: game
/// points; team: board points), `none` on the diagonal. Errors if the entity does
/// not form a round-robin (some pair never met) — use `standings` + `progress` for
/// Swiss / league events.
///
/// - games (array): parsed games (from `games`).
/// - by (str): `"player"` or `"team"`.
/// - match-points (dictionary): team match-point values.
/// -> dictionary
#let crosstable(games, by: "player", match-points: (win: 2, draw: 1, loss: 0)) = {
  let rows = standings(games, by: by, match-points: match-points)
  let names = rows.map(r => r.name)
  let n = names.len()
  let pos = (:)
  for (i, nm) in names.enumerate() { pos.insert(nm, i) }

  let matrix = range(n).map(_ => range(n).map(_ => none))
  let met = range(n).map(_ => range(n).map(_ => false))
  let r = _encounters(games, by, match-points)
  for e in r.enc {
    let i = pos.at(e.entity)
    let j = pos.at(e.opp)
    let cur = matrix.at(i).at(j)
    matrix.at(i).at(j) = (if cur == none { 0.0 } else { cur }) + e.secondary
    met.at(i).at(j) = true
  }
  // round-robin check: every off-diagonal pair must have met
  for i in range(n) {
    for j in range(n) {
      if i != j and not met.at(i).at(j) {
        panic("crosstable: " + repr(by) + " entities do not form a round-robin (" + names.at(i) + " never met " + names.at(j) + "); use standings + progress instead")
      }
    }
  }
  (names: names, ranks: rows.map(r => r.rank), totals: rows.map(r => r.score), matrix: matrix)
}

/// Render a round-robin cross-table as a Typst `#table` figure. Columns are
/// numbered to match the row order; the diagonal is shaded.
///
/// - games (array): parsed games (from `games`).
/// - by (str): `"player"` or `"team"`.
/// - match-points (dictionary): team match-point values.
/// - title (none, content): a title shown above the table.
/// - caption (none, content): the figure caption.
/// - supplement (auto, content): the figure supplement; `auto` is language-aware.
/// - lang (auto, str): language for defaults; `auto` follows the document.
/// - ..table-args (arguments): forwarded to `#table`.
/// -> content
#let crosstable-table(games, by: "player", match-points: (win: 2, draw: 1, loss: 0), title: none, caption: none, supplement: auto, lang: auto, ..table-args) = {
  let ct = crosstable(games, by: by, match-points: match-points)
  let n = ct.names.len()
  let (style-over, raw) = _split-table-style(table-args.named())
  let cols = 2 + n + 1
  let nrows = n + 1

  let tbl = context {
    let st = default-table-style + table-style-state.get() + style-over
    validate-table-style(st)
    let sa = _table-style-args(st, cols, nrows, 1)
    // The self/self diagonal fill overrides the table-level zebra fill (which
    // would otherwise wash it out on odd rows), keeping it legible.
    let diag-fill = _crosstable-diagonal-fill(st.body-fill)

    let body = ()
    for i in range(n) {
      let name-cell = if _winner-bold(st.highlight-winners, ct.ranks.at(i), 1, 1, 2 + n) {
        strong[#(i + 1) #h(0.4em) #ct.names.at(i)]
      } else {
        [#(i + 1) #h(0.4em) #ct.names.at(i)]
      }
      body.push([#ct.ranks.at(i)])
      body.push(name-cell)
      for j in range(n) {
        if i == j { body.push(table.cell(fill: diag-fill)[]) }
        else { body.push([#_fmt(ct.matrix.at(i).at(j))]) }
      }
      // Totals cell is already `strong` regardless of `highlight-winners`.
      body.push([*#_fmt(ct.totals.at(i))*])
    }

    let name-h = if by == "team" { ui-string(lang, "tbl-team") } else { ui-string(lang, "tbl-player") }
    let header = ([*\#*], [*#name-h*],) + range(n).map(i => [*#(i + 1)*]) + ([*#ui-string(lang, "tbl-points")*],)
    table(
      columns: cols,
      ..(stroke: sa.stroke, fill: sa.fill, align: sa.align) + raw,
      table.header(repeat: true, ..header),
      ..body,
    )
  }
  _table-figure(tbl, title, caption, supplement, lang, style-over)
}

// ---- progress (round by round) --------------------------------------------

/// Per-entity round-by-round progress: `(names, ranks, rounds, cells)`, where
/// `cells.at(i).at(k)` is `(score, cumulative)` for entity i in `rounds.at(k)`
/// (player: game points that round; team: match points). Needs the `Round` tag;
/// works for open / Swiss events too.
///
/// - games (array): parsed games (from `games`).
/// - by (str): `"player"` or `"team"`.
/// - match-points (dictionary): team match-point values.
/// -> dictionary
#let progress(games, by: "player", match-points: (win: 2, draw: 1, loss: 0)) = {
  let rows = standings(games, by: by, match-points: match-points)
  let names = rows.map(r => r.name)

  // per entity: round -> score that round
  let per = (:)
  for nm in names { per.insert(nm, (:)) }
  let rounds-seen = (:)
  if by == "player" {
    for g in games {
      let r = _result-scores(g.tags.at("Result", default: "*"))
      let rnd = _major-round(g.tags.at("Round", default: none))
      if r == none or rnd == none { continue }
      let w = g.tags.at("White", default: none)
      let b = g.tags.at("Black", default: none)
      rounds-seen.insert(str(rnd), rnd)
      for (nm, sc) in ((w, r.at(0)), (b, r.at(1))) {
        if nm == none { continue }
        let pr = per.at(nm)
        pr.insert(str(rnd), pr.at(str(rnd), default: 0.0) + sc)
        per.insert(nm, pr)
      }
    }
  } else {
    for m in _team-matches(games, match-points) {
      if m.round == none { continue }
      rounds-seen.insert(str(m.round), m.round)
      for (nm, pts) in ((m.a, m.mpa), (m.b, m.mpb)) {
        let pr = per.at(nm)
        pr.insert(str(m.round), pr.at(str(m.round), default: 0.0) + pts)
        per.insert(nm, pr)
      }
    }
  }
  let rounds = rounds-seen.values().sorted()

  let cells = ()
  for nm in names {
    let pr = per.at(nm)
    let cum = 0.0
    let row = ()
    for rnd in rounds {
      let sc = pr.at(str(rnd), default: none)
      if sc != none { cum += sc }
      row.push((score: sc, cumulative: cum))
    }
    cells.push(row)
  }
  (names: names, ranks: rows.map(r => r.rank), rounds: rounds, cells: cells)
}

/// Render a progress table as a Typst `#table` figure: a column per round showing
/// that round's result and the running total, plus a final total.
///
/// - games (array): parsed games (from `games`).
/// - by (str): `"player"` or `"team"`.
/// - match-points (dictionary): team match-point values.
/// - title (none, content): a title shown above the table.
/// - caption (none, content): the figure caption.
/// - supplement (auto, content): the figure supplement; `auto` is language-aware.
/// - lang (auto, str): language for defaults; `auto` follows the document.
/// - ..table-args (arguments): forwarded to `#table`.
/// -> content
#let progress-table(games, by: "player", match-points: (win: 2, draw: 1, loss: 0), title: none, caption: none, supplement: auto, lang: auto, ..table-args) = {
  let pg = progress(games, by: by, match-points: match-points)
  let (style-over, raw) = _split-table-style(table-args.named())
  let cols = 2 + pg.rounds.len() + 1
  let nrows = pg.names.len() + 1

  let tbl = context {
    let st = default-table-style + table-style-state.get() + style-over
    validate-table-style(st)
    let sa = _table-style-args(st, cols, nrows, 1)

    let body = ()
    for (i, nm) in pg.names.enumerate() {
      let bold = _winner-bold(st.highlight-winners, pg.ranks.at(i), 1, 1, 2 + pg.rounds.len())
      body.push([#pg.ranks.at(i)])
      body.push(if bold { strong[#nm] } else { [#nm] })
      for c in pg.cells.at(i) {
        if c.score == none { body.push([\u{2013}]) }
        else { body.push([#_fmt(c.score) #text(fill: luma(120), size: 0.8em)[(#_fmt(c.cumulative))]]) }
      }
      let total = pg.cells.at(i).fold(0.0, (a, c) => a + (if c.score == none { 0.0 } else { c.score }))
      // Total cell is already `strong` regardless of `highlight-winners`.
      body.push([*#_fmt(total)*])
    }

    let name-h = if by == "team" { ui-string(lang, "tbl-team") } else { ui-string(lang, "tbl-player") }
    let r-abbr = ui-string(lang, "tbl-round-abbr")
    let header = ([*\#*], [*#name-h*],) + pg.rounds.map(r => [*#r-abbr#r*]) + ([*#ui-string(lang, "tbl-points")*],)
    table(
      columns: cols,
      ..(stroke: sa.stroke, fill: sa.fill, align: sa.align) + raw,
      table.header(repeat: true, ..header),
      ..body,
    )
  }
  _table-figure(tbl, title, caption, supplement, lang, style-over)
}
