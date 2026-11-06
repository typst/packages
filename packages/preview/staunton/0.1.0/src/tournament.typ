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

#import "style.typ": default-table-style, table-style-state
#import "i18n.typ": ui-string

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
#let _table-figure(tbl, title, caption, supplement, lang) = {
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
  figure(body, kind: chess-table-kind, supplement: supp, caption: caption)
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
/// - games (array): parsed games (from `parse-pgn`).
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
/// - games (array): parsed games (from `parse-pgn`).
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
/// - games (array): parsed games (from `parse-pgn`).
/// - by (str): `"player"` or `"team"`.
/// - tiebreaks (auto, array): as for `standings`.
/// - match-points (dictionary): as for `standings`.
/// - title (none, content): a title shown above the table.
/// - caption (none, content): the figure caption (needed for the table to appear
///   in `chess-table-outline`).
/// - supplement (auto, content): the figure supplement; `auto` is language-aware.
/// - lang (auto, str): language for defaults; `auto` follows the document.
/// - ..table-args (arguments): forwarded to `#table`.
/// -> content
#let standings-table(games, by: "player", tiebreaks: auto, match-points: (win: 2, draw: 1, loss: 0), title: none, caption: none, supplement: auto, lang: auto, ..table-args) = {
  let tbs = if tiebreaks != auto { tiebreaks } else { _default-tiebreaks(by) }
  let rows = standings(games, by: by, tiebreaks: tiebreaks, match-points: match-points)
  let name-h = if by == "team" { "Team" } else { "Player" }

  let header = (
    [*Pos*], [*#name-h*], [*Pl*], [*+*], [*=*], [*\u{2212}*], [*Pts*],
  ) + tbs.map(tb => [*#_tb-label.at(tb)*])

  let body = ()
  for r in rows {
    body += (
      [#r.rank], [#r.name], [#r.played], [#r.wins], [#r.draws], [#r.losses], [#_fmt(r.score)],
    ) + tbs.map(tb => [#_fmt(_tb-value(r, tb))])
  }

  let tbl = table(
    columns: 7 + tbs.len(),
    align: (col, row) => if col == 1 { left } else { center },
    table.header(..header),
    ..body,
    ..table-args.named(),
  )
  _table-figure(tbl, title, caption, supplement, lang)
}

// ---- cross-table (round-robin only) ---------------------------------------

/// Cross-table for a round-robin: `(names, ranks, totals, matrix)`, rows/cols in
/// standings order, `matrix.at(i).at(j)` entity i's score vs j (player: game
/// points; team: board points), `none` on the diagonal. Errors if the entity does
/// not form a round-robin (some pair never met) — use `standings` + `progress` for
/// Swiss / league events.
///
/// - games (array): parsed games (from `parse-pgn`).
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
/// - games (array): parsed games (from `parse-pgn`).
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
  let name-h = if by == "team" { "Team" } else { "Player" }

  let header = ([*\#*], [*#name-h*],) + range(n).map(i => [*#(i + 1)*]) + ([*Pts*],)
  let body = ()
  for i in range(n) {
    body.push([#ct.ranks.at(i)])
    body.push([#(i + 1) #h(0.4em) #ct.names.at(i)])
    for j in range(n) {
      if i == j { body.push(table.cell(fill: luma(220))[]) }
      else { body.push([#_fmt(ct.matrix.at(i).at(j))]) }
    }
    body.push([*#_fmt(ct.totals.at(i))*])
  }

  let tbl = table(
    columns: 2 + n + 1,
    align: (col, row) => if col == 1 { left } else { center },
    table.header(..header),
    ..body,
    ..table-args.named(),
  )
  _table-figure(tbl, title, caption, supplement, lang)
}

// ---- progress (round by round) --------------------------------------------

/// Per-entity round-by-round progress: `(names, ranks, rounds, cells)`, where
/// `cells.at(i).at(k)` is `(score, cumulative)` for entity i in `rounds.at(k)`
/// (player: game points that round; team: match points). Needs the `Round` tag;
/// works for open / Swiss events too.
///
/// - games (array): parsed games (from `parse-pgn`).
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
/// - games (array): parsed games (from `parse-pgn`).
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
  let name-h = if by == "team" { "Team" } else { "Player" }

  let header = ([*\#*], [*#name-h*],) + pg.rounds.map(r => [*R#r*]) + ([*Pts*],)
  let body = ()
  for (i, nm) in pg.names.enumerate() {
    body.push([#pg.ranks.at(i)])
    body.push(nm)
    for c in pg.cells.at(i) {
      if c.score == none { body.push([\u{2013}]) }
      else { body.push([#_fmt(c.score) #text(fill: luma(120), size: 0.8em)[(#_fmt(c.cumulative))]]) }
    }
    let total = pg.cells.at(i).fold(0.0, (a, c) => a + (if c.score == none { 0.0 } else { c.score }))
    body.push([*#_fmt(total)*])
  }

  let tbl = table(
    columns: 2 + pg.rounds.len() + 1,
    align: (col, row) => if col == 1 { left } else { center },
    table.header(..header),
    ..body,
    ..table-args.named(),
  )
  _table-figure(tbl, title, caption, supplement, lang)
}
