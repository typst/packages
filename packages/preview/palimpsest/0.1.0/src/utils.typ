/// Recursively collects the `.value` of every `metadata` element in `body`
/// whose value is a dictionary tagged with `tag`, in document order.
/// Purely structural (no layout, no context) — walks the content tree as
/// data, the same way typst-navigator's `extract-text` does.
///
/// Walks *every* content- or array-valued field of each element, not just
/// `body`/`children` — a mark nested in a `figure`'s `caption:` or a
/// table's cells lives in a field the shortlist would have missed.
#let collect-metadata(body, tag) = {
  let walk(node) = {
    let t = type(node)
    if t == content {
      if node.func() == metadata {
        let v = node.value
        if type(v) == dictionary and v.at("tag", default: none) == tag {
          return (v,)
        }
        return ()
      }
      return node.fields().values().map(v => {
        let t2 = type(v)
        if t2 == content or t2 == array { walk(v) } else { () }
      }).sum(default: ())
    } else if t == array {
      return node.map(walk).sum(default: ())
    }
    return ()
  }
  walk(body)
}

/// Normalizes the `anchors` argument accepted by `passage` and its
/// shortcuts: `none`, a single label, or an array of labels — always
/// returns an array.
#let normalize-anchors(anchors) = {
  if anchors == none { () }
  else if type(anchors) == array { anchors }
  else { (anchors,) }
}

/// Parses an anchor label into its round/kind/identity/number components.
/// `<r1-2>` → round 1 (implicit), reviewer 1, comment 2.
/// `<2r1-2>` → round 2, reviewer 1, comment 2.
/// `<e1>` → editor comment 1 (round 1, no reviewer number).
/// `<2e1>` → round 2, editor comment 1.
/// `<bob-3>` → author "bob", change 3 (round 1, implicit) — anything that
/// isn't a reviewer/editor label but still looks like `<name>` or
/// `<name>-<number>` (tried in that order, so `r1-2`/`e3` always hit the
/// reviewer/editor branches first, never this one). `<bob>` alone (no
/// trailing `-<number>`) parses as author "bob" with `num: none` — a
/// bare, non-discriminating anchor meant to be reused freely across many
/// passages/notes with no per-occurrence identity, not an error (see
/// `passage`'s and `exchange`'s exemptions for `num: none` anchors).
/// A hyphen inside the name itself is handled correctly (`<bob-fischer-12>`
/// → author "bob-fischer", change 12): only a *trailing* `-<digits>` is
/// ever read as the number, so a name with no trailing `-<digits>` at all
/// (`<bob>`, `<bob-fischer>`) is just a bare name, never split further.
/// Returns `none` only for labels that don't even look like a bare
/// identifier (essentially never, in practice, for a real Typst label).
#let parse-anchor(lbl) = {
  let s = str(lbl)
  let m = s.match(regex("^(\d*)r(\d+)-(\d+)$"))
  if m != none {
    return (
      round: if m.captures.at(0) in (none, "") { 1 } else { int(m.captures.at(0)) },
      kind: "reviewer",
      reviewer: int(m.captures.at(1)),
      num: int(m.captures.at(2)),
    )
  }
  let me = s.match(regex("^(\d*)e(\d+)$"))
  if me != none {
    return (
      round: if me.captures.at(0) in (none, "") { 1 } else { int(me.captures.at(0)) },
      kind: "editor",
      reviewer: none,
      num: int(me.captures.at(1)),
    )
  }
  let ma = s.match(regex("^(\d*)([a-zA-Z][a-zA-Z0-9_-]*?)(?:-(\d+))?$"))
  if ma != none {
    return (
      round: if ma.captures.at(0) in (none, "") { 1 } else { int(ma.captures.at(0)) },
      kind: "author",
      author: ma.captures.at(1),
      num: if ma.captures.at(2) == none { none } else { int(ma.captures.at(2)) },
    )
  }
  none
}

/// True if `body` contains no non-whitespace text anywhere in its tree —
/// used to catch an `exchange` written with a comment but an empty
/// response (§11: "exchange r3-1: empty response").
#let is-blank(body) = {
  let walk(node) = {
    let t = type(node)
    if t == content {
      if node.func() == metadata { return false }
      if node.has("text") {
        return node.text.trim() != ""
      }
      return node.fields().values().any(v => {
        let t2 = type(v)
        if t2 == content or t2 == array { walk(v) } else { false }
      })
    } else if t == array {
      return node.any(walk)
    }
    false
  }
  not walk(body)
}

/// Recursively collects every non-`none` `.label` found anywhere in
/// `body`'s tree (a figure, a heading, an equation — any labelled
/// element). Used by `pinpoint(excerpt: true)` to detect when
/// re-emitting a passage's stored content into the letter would plant a
/// second copy of a label that's meant to be unique in the bundle (a
/// figure the manuscript also cross-references by that same label,
/// typically) — Typst treats a duplicate label as a hard compile error,
/// not a warning, so this has to be checked *before* re-emitting, not
/// discovered by trying it.
#let collect-labels(body) = {
  let walk(node) = {
    let t = type(node)
    if t == content {
      let lbl = node.fields().at("label", default: none)
      let own = if lbl != none { (lbl,) } else { () }
      own + node.fields().values().map(v => {
        let t2 = type(v)
        if t2 == content or t2 == array { walk(v) } else { () }
      }).sum(default: ())
    } else if t == array {
      node.map(walk).sum(default: ())
    } else {
      ()
    }
  }
  walk(body)
}

/// Walks `body` structurally (same recursion shape as `collect-labels`,
/// above) to find which numbered element kinds it actually contains —
/// `heading`, and `figure` broken down by `image`/`table`/`raw` kind
/// (inferred from the figure's own `body` field, same inference Typst
/// itself uses and the same one `mark-figure-body` has to redo
/// explicitly after crossing), plus `math.equation`. Used by
/// `neutralize-numbering` (`marks.typ`) to snapshot/restore only the
/// counters a given deletion actually touches, instead of all five
/// unconditionally on every single deletion — not just an optimization:
/// verified directly that touching all five regardless of content, with
/// enough mixed deletions stacked in one document (several headings,
/// figures, tables, and equations all deleted), makes Typst's layout
/// solver fail to converge within its default five attempts ("document
/// did not converge" — reproduced with `tests/bundle-numbering-restore.typ`,
/// which needed all four kinds deleted together to trigger it; any
/// three alone converged fine, isolating the cause to the sheer volume
/// of stacked, unconditional counter reads/writes rather than any one
/// kind in particular).
#let no-kinds = (heading: false, image: false, table: false, raw: false, equation: false)

#let numbered-kinds-in(body) = {
  // Typst closures can't mutate a captured variable (verified directly
  // — "variables from outside the function are read-only"), so this
  // combines results by *returning and OR-ing* them, the same shape
  // `collect-labels` (above) already uses for the same reason, rather
  // than accumulating into a shared dict from inside `walk` the way an
  // first draft of this function tried and failed to compile.
  let or-kinds = (a, b) => (
    heading: a.heading or b.heading,
    image: a.image or b.image,
    table: a.table or b.table,
    raw: a.raw or b.raw,
    equation: a.equation or b.equation,
  )
  let walk(node) = {
    let t = type(node)
    if t == content {
      let f = node.func()
      let own = if f == heading {
        (..no-kinds, heading: true)
      } else if f == math.equation {
        (..no-kinds, equation: true)
      } else if f == figure {
        let b = node.fields().at("body", default: none)
        let bf = if type(b) == content { b.func() } else { none }
        if bf == table {
          (..no-kinds, table: true)
        } else if bf == raw {
          (..no-kinds, raw: true)
        } else {
          (..no-kinds, image: true)
        }
      } else {
        no-kinds
      }
      node.fields().values().fold(own, (acc, v) => {
        let t2 = type(v)
        if t2 == content {
          or-kinds(acc, walk(v))
        } else if t2 == array {
          v.fold(acc, (acc2, x) => if type(x) == content { or-kinds(acc2, walk(x)) } else { acc2 })
        } else {
          acc
        }
      })
    } else if t == array {
      node.fold(no-kinds, (acc, x) => or-kinds(acc, walk(x)))
    } else {
      no-kinds
    }
  }
  walk(body)
}

/// Recursively reconstructs `node` with every label removed —
/// `pinpoint(excerpt: true)` runs this on a passage's stored content
/// before re-emitting it into the letter, so a figure/table/equation/
/// heading the passage adds can be *shown*, not just cited by page,
/// even though its label is also the target of a real `@ref` elsewhere
/// in the bundle (§6quinquies/§6septies): the copy in the letter no
/// longer carries that label, so citing it anywhere still resolves
/// unambiguously to the one true original in the manuscript (verified
/// directly, including with an `@ref` sitting inline right next to the
/// stripped copy).
///
/// A `figure`, a labelled block `math.equation`, or a labelled
/// `heading` that still has its original label at the point this runs
/// gets one more thing done to it before that label is dropped:
/// `query(lbl)` finds the true, already-shown manuscript original (the
/// copy being built right now doesn't exist yet, so this can't resolve
/// to itself), and its real, resolved number is pinned onto the
/// reconstructed copy's `numbering:` field as a literal value (`(..) =>
/// real-number`). A local `numbering:` always wins over whatever `set
/// figure(numbering: ...)`/`set math.equation(numbering:
/// ...)`/`set heading(numbering: ...)` is active where the copy is
/// re-emitted — normally the letter's own independent "R" sequence for
/// a figure (`with-letter-numbering`, `letter.typ`) — so a figure,
/// equation, or heading the letter quotes shows the *same* number it
/// has in the manuscript ("Figure 2"/"Equation 3"/"2.1" in both places)
/// instead of a letter-local one ("Figure 2" in the manuscript, "Figure
/// R1" in the letter) that gave no hint the two were the same element.
/// The three element types need different fields to compute that real
/// number, which is the only reason they're not handled by one shared
/// branch: a `figure` synthesizes its own `.counter` once shown (scoped
/// to its `kind`, so it already reads the right one whatever that kind
/// is); `math.equation` and `heading` don't synthesize one, so
/// `counter(math.equation)`/`counter(heading)` — the one, ungrouped
/// counter every equation shares, and likewise the one counter that
/// already returns a heading's full "2.1"-style array regardless of
/// level (verified directly, no per-level split the way `figure` has a
/// per-`kind` one) — have to be read explicitly instead. Skipped,
/// falling through to whatever numbering already applies, whenever
/// there's nothing to pin: no label, the label doesn't resolve anywhere
/// (a figure/equation/heading the *letter* itself adds, never in the
/// manuscript at all), or the original's own `numbering` is `none`
/// (some future case setting it directly — not `del-numbering: "none"`
/// itself, which since `neutralize-numbering` (`marks.typ`) switched
/// from blanking numbering to snapshotting/restoring the counter no
/// longer sets a deleted element's own `numbering` to `none` at all; a
/// deleted figure/equation/heading keeps its real, resolved numbering
/// and is pinned just like a kept one — this guard is now mostly
/// theoretical, kept because `numbering(none, ..)` is still a hard
/// Typst error if it's ever `none` for any other reason). An *inline*
/// equation is covered by the same branch as a block one —
/// `math.equation`'s `.numbering` field and the shared counter work
/// identically either way — but an inline equation is rarely labelled
/// or numbered in practice, so this is mostly untested territory. A
/// `heading` is, in the same sense, rarely labelled at all outside of
/// this use case — the gain only shows up for a heading the author
/// specifically labels so it can be quoted with its real section
/// number; an unlabelled one (the common case) just stays unnumbered in
/// the letter, as before.
///
/// Doesn't change how many counter slots a re-emitted figure consumes
/// — it still advances whichever kind-scoped counter is active where
/// it's shown (a real `figure` element always does, however its number
/// is displayed), same as before this pinning existed. A letter's own,
/// genuinely new figure appearing after several quoted ones therefore
/// still gets whatever "R" number that position implies, not a clean
/// "R1" — already true before this change (an excerpt has always
/// consumed a slot in the letter's counter, only its *displayed*
/// number is new), so left as is rather than introducing a separate
/// counter namespace (`kind:`) to fix a property nobody has asked for.
///
/// Reconstructs an element via its own `.func()(..fields)` — works
/// uniformly across element types (figure, heading, math.equation, all
/// verified) *except* that a `sequence`'s `children` field is one
/// positional array argument, not one argument per child (`ctor(c)`,
/// not `ctor(..c)` — verified: the latter errors "expected array,
/// found content"); every other field with a content/array value goes
/// through `..named-fields` uniformly since element constructors accept
/// their own field names as keyword arguments.
///
/// Only reconstructs subtrees that actually contain a label
/// (`collect-labels(node).len() == 0` bails out immediately) — the vast
/// majority of any passage's content has no label anywhere in it, and
/// skipping reconstruction there is both cheaper and safer: rebuilding
/// content nobody needs to change is pure risk for no benefit. `metadata`
/// nodes are never reconstructed either — the package's own internal
/// tag labels (`<palimpsest-mark>` etc., deliberately reused across the
/// whole bundle) must survive re-emission untouched.
#let strip-labels(node) = {
  let t = type(node)
  if t == content {
    if node.func() == metadata or collect-labels(node).len() == 0 {
      return node
    }
    let f = node.fields()
    let new-f = (:)
    for (k, v) in f {
      if k == "label" { continue }
      let t2 = type(v)
      new-f.insert(k, if t2 == content {
        strip-labels(v)
      } else if t2 == array {
        v.map(x => if type(x) == content { strip-labels(x) } else { x })
      } else {
        v
      })
    }
    let ctor = node.func()
    if ctor == figure or ctor == math.equation or ctor == heading {
      let lbl = f.at("label", default: none)
      if lbl != none {
        let hits = query(lbl)
        if hits.len() > 0 {
          let orig = hits.first()
          if orig.numbering != none {
            // `figure` synthesizes its own `.counter` once shown, scoped
            // to its `kind`. `math.equation` and `heading` don't — both
            // share one, plain, ungrouped counter apiece (`heading`'s
            // isn't scoped by level either: `counter(heading)` alone
            // already returns the full "2.1"-style array, verified
            // directly), so both read the same generic counter directly.
            let cval = if ctor == figure {
              orig.counter.at(orig.location())
            } else if ctor == math.equation {
              counter(math.equation).at(orig.location())
            } else {
              counter(heading).at(orig.location())
            }
            let real-number = numbering(orig.numbering, ..cval)
            new-f.insert("numbering", (..) => real-number)
          }
        }
      }
    }
    if "body" in new-f {
      let b = new-f.remove("body")
      ctor(b, ..new-f)
    } else if "children" in new-f {
      // `children`'s calling convention isn't uniform: `sequence` wants
      // its array as one positional argument (`ctor(c)` — spreading
      // errors "expected array, found content"), while `table`, `grid`
      // and likely others of that family want each child spread as its
      // own positional argument (`ctor(..c)` — passing the array as one
      // argument errors "expected content, found array"). Both verified
      // directly; `repr(ctor)` is the only way found to tell them apart,
      // since `sequence` itself isn't a nameable value to compare
      // against directly (`node.func() == sequence` doesn't parse).
      let c = new-f.remove("children")
      if repr(ctor) == "sequence" { ctor(c, ..new-f) } else { ctor(..c, ..new-f) }
    } else {
      ctor(..new-f)
    }
  } else if t == array {
    node.map(strip-labels)
  } else {
    node
  }
}

/// Overlays a horizontal line at mid-height across `body`, colored by
/// the ambient `text.fill` (not a parameter — reads the color already
/// set by whatever `text(fill: ...)` wraps the call, so it stays in
/// sync with `mark-visual`'s coloring without needing to be threaded
/// through separately). Used as `del`'s default mark for an *inline*
/// equation: `strike()`/`underline()` never decorate real math glyphs
/// (only literal quoted-string subscripts), verified exhaustively in
/// `tests/strike-methods.typ` §1/§2 — this overlay reaches the glyphs
/// themselves. Safe specifically because it's only ever applied to a
/// single inline equation, not to reflowable prose (see `CLAUDE.md`
/// §6bis for the M1 regression this would otherwise repeat, and
/// `tests/strike-methods.typ` cases G.12/H.4 for the residual risk that
/// remains even scoped this narrowly: a long inline equation loses its
/// native ability to break across lines — accepted, inline equations
/// are rarely long in practice).
#let strike-b(body) = context {
  let c = text.fill
  let sz = measure(body)
  box(width: sz.width, height: sz.height)[
    #body
    #place(top + left, dy: sz.height / 2, line(length: sz.width, stroke: 0.6pt + c))
  ]
}

/// Overlays a diagonal cross spanning all of `body`, colored by the
/// ambient `text.fill` (same reasoning as `strike-b` above). Used as
/// `del`'s default mark for a *block* equation, a `figure`, and a bare
/// `table`. Preferred over `strike-b`'s single mid-height line at block
/// scale for two reasons, both verified in `tests/strike-methods.typ`:
/// a line at mid-height becomes *invisible* when it coincides with
/// content that already has its own horizontal bar (a fraction — case
/// I.1, not merely "hard to see": indistinguishable from an unmarked
/// fraction), and a block equation/figure never needs to reflow
/// word-by-word, so the `measure`+`box` overlay that's unsafe for prose
/// (§6bis) is safe here (§8.2's note, `tests/strike-methods.typ`).
#let cross(body) = context {
  let c = text.fill
  let sz = measure(body)
  box(width: sz.width, height: sz.height)[
    #body
    #place(top + left, line(start: (0pt, 0pt), end: (sz.width, sz.height), stroke: 0.8pt + c))
    #place(top + left, line(start: (0pt, sz.height), end: (sz.width, 0pt), stroke: 0.8pt + c))
  ]
}

/// Reconstructs `fig` with its `body` field crossed out (`cross`,
/// above) and everything else — crucially, `caption` — untouched, so a
/// caller wrapping the result in `strike()` still reaches the caption's
/// real text natively, while the figure's body (an image, a plot, a
/// table with no text of its own) gets the overlay instead. `label` and
/// `counter` are removed before reconstructing and the label alone is
/// reattached after (`[#new-fig#lbl]`, the same postfix-attachment
/// syntax as `#figure(...) <label>` in markup): `label` isn't a valid
/// named argument to `figure()`'s constructor, and `counter` is a field
/// Typst synthesizes once a figure has actually been shown — present on
/// the `fig` this function is really called with (nested inside a real
/// `del()` passage), never present when constructing a bare `figure()`
/// by hand, which is why this gap surfaced only once tested against a
/// *labeled* figure nested in a larger deletion, not against the
/// simpler cases that motivated `cross` in the first place (all
/// verified in `tests/strike-methods.typ`, case F.9's note and
/// F.9–F.11).
///
/// `kind` is also removed and recomputed explicitly, from `b` — the
/// original, uncrossed body — rather than left for Typst to re-infer on
/// the reconstructed figure: `cross(b)` wraps `b` in a `box`, and a
/// figure's automatic kind inference only recognizes a body whose own
/// `.func()` is directly `table`/`raw` (falling back to `image`
/// otherwise) — a `box` matches neither, so a crossed *table* was
/// silently mis-inferred as `kind: image` and captioned/counted as a
/// "Figure" instead of a "Table". Invisible as long as a deleted
/// figure's number was hidden outright (`neutralize-numbering`'s old
/// `numbering: none` approach); surfaced once that changed to keep the
/// real number visible (`neutralize-numbering` now restores counters
/// instead of blanking them) — verified directly, see
/// `docs/manual-snippets/style-del-numbering-none.typ`'s tracked
/// output before this fix ("Figure 3: Removed table" under a plain,
/// non-custom template). Doesn't affect *which* counter actually
/// advances at layout time if this inference is still somehow wrong for
/// some future body shape — `neutralize-numbering` restores every
/// kind-scoped counter unconditionally, so a subsequent real figure's
/// own number was never at risk, only this element's own caption.
#let mark-figure-body(fig) = {
  let f = fig.fields()
  let b = f.remove("body")
  let lbl = f.remove("label", default: none)
  let _ = f.remove("counter", default: none)
  let _ = f.remove("kind", default: none)
  let kind = if b.func() == table { table } else if b.func() == raw { raw } else { image }
  let new-fig = fig.func()(cross(b), kind: kind, ..f)
  if lbl != none { [#new-fig#lbl] } else { new-fig }
}

/// Reconstructs a *block* `math.equation` with only its `body` field
/// crossed out — same shape and same underlying reason as
/// `mark-figure-body`, above. An earlier version crossed the *whole*
/// numbered equation directly (`cross(eq)`, `eq` still carrying its own
/// `numbering:`): `cross`'s `measure(body)` only ever returns an
/// element's tight, intrinsic size — for a numbered equation, that
/// collapses back down to just the width of its glyphs, discarding the
/// full-page-width, number-pushed-to-the-margin layout Typst's own
/// equation-numbering machinery gives a *normally* placed numbered
/// equation. The reconstructed box ended up exactly as wide as "E =
/// mc²" alone, squeezing the equation's real number right up against
/// it instead of at the margin — verified directly, reproduced with a
/// bare `#set math.equation(numbering: ...)` equation measured and
/// re-boxed, no palimpsest involved. Crossing only `body` avoids this:
/// `cross` only ever measures the bare math glyphs (always meant to be
/// tightly boxed), while the surrounding `math.equation` — reconstructed
/// with its `numbering`/`block` fields untouched — gets Typst's native,
/// full-width, right-justified numbering layout exactly like a kept or
/// added equation, centering itself the same way any block equation
/// natively does. The caller no longer needs its own `align(center,
/// block(...))` wrapper for this (removed): that wrapper only ever
/// existed to recenter a box that had collapsed to its tight size, not
/// something a *correctly*-sized reconstructed equation needs.
#let mark-equation-body(eq) = {
  let f = eq.fields()
  let b = f.remove("body")
  let lbl = f.remove("label", default: none)
  let new-eq = eq.func()(cross(b), ..f)
  if lbl != none { [#new-eq#lbl] } else { new-eq }
}

/// `del`'s default visual mark (`style.typ`'s `default-style.del-style`):
/// native `strike()` for plain text — reflows normally, exactly like
/// today — with three exceptions found and fixed together, all
/// documented at length in `tests/strike-methods.typ`: a *block* math
/// equation or a bare `table` gets `cross`, an *inline* equation gets
/// `strike-b`'s single line (a full cross would be disproportionate on
/// a single symbol, and a wide cross degrades toward two near-parallel
/// lines rather than an inline mark to begin with), and a `figure` gets
/// `mark-figure-body` plus an outer `strike()` so its caption is still
/// natively struck. Recurses into a `sequence` to find these wherever
/// they sit in a passage that mixes prose, equations and a figure in
/// one `del(...)` call (verified nested three deep, case F.9) — a show
/// rule was tried first and rejected: reconstructing a `math.equation`
/// or `figure` from *inside* a show rule matching that same element
/// type re-triggers the rule on its own output (`maximum show rule
/// depth exceeded`, cases G.9 and the note preceding this function's
/// sibling `mark-figure-body`); a one-shot recursive rebuild, called
/// once and never registered as a standing rule, has no such trap.
#let default-del-mark(body) = {
  if type(body) != content {
    body
  } else if body.func() == math.equation and body.at("block", default: false) {
    mark-equation-body(body)
  } else if body.func() == math.equation {
    strike-b(body)
  } else if body.func() == figure {
    strike(mark-figure-body(body))
  } else if body.func() == table {
    strike(cross(body))
  } else if repr(body.func()) == "sequence" {
    body.children.map(default-del-mark).sum(default: [])
  } else {
    strike(body)
  }
}

/// Local override for `add`/`del`/`rep`'s internal clean-vs-tracked
/// rendering choice, read via `context`. `pinpoint(excerpt: true, mode:
/// ...)` sets this immediately before re-emitting a passage's stored
/// content and resets it right after, so one excerpt can render in a
/// specific mode regardless of what the *current compile* is actually
/// doing — the manuscript's own copy, laid out earlier at its own
/// position, is unaffected (state resolves by document position, same
/// trick as `current-passage-anchors` above). `none` = no override,
/// defer to the real compile mode (today's behavior, unchanged).
///
/// Deliberately **not** consulted by the public `mode()` in
/// `marks.typ`: that one always reflects the actual compile and is
/// meant for the author's own mode-dependent content (a table's column
/// count, say) — only the package's own marks respond to this override,
/// not arbitrary user code re-emitted along with them.
#let render-mode-override = state("palimpsest-render-mode-override", none)

/// True while `add`/`del`/`rep` are rendering as part of a
/// `pinpoint(excerpt: true)` re-emission, read via `context` — same
/// set-before/reset-after bracketing and same position-based resolution
/// as `render-mode-override` above. When true, each mark strips labels
/// from its own `body`/`old`/`new` *before* deciding what to show
/// (`strip-labels`, still on the plain, not-yet-`context`-wrapped
/// value, so the structural walk it needs still works) — letting a
/// figure/table/equation a passage adds be shown in full in the letter
/// even though its label is also referenced elsewhere in the bundle,
/// without duplicating that label. Must happen inside `add`/`del`/`rep`
/// themselves, not from `pinpoint` after the fact: by the time a mark's
/// *rendered* content exists, it is wrapped in `context` (needed for
/// `render-mode-override` above) and therefore structurally opaque —
/// stripping has to happen before that wrapping, on the original
/// argument, which only the mark itself still has direct access to.
#let in-excerpt = state("palimpsest-in-excerpt", false)

/// State holding the anchors of the passage currently being emitted, so
/// that `add`/`del`/`rep` — called *inside* a passage's body, i.e. before
/// the enclosing `passage()` call itself runs — can still pick up the
/// passage's anchors at layout time via `context`. Resolution follows
/// final document order, not Typst call order, so this works even though
/// marks are evaluated before the passage that will contain them.
///
/// `none` outside of any passage (the "#del outside any passage"
/// diagnostic fires on exactly this) — distinct from `()`, a real
/// passage that simply has no anchor (§4, "passage sans ancre").
#let current-passage-anchors = state("palimpsest-current-anchors", none)
