#import "utils.typ": current-passage-anchors, collect-labels, render-mode-override, in-excerpt, strip-labels
#import "diagnostics.typ": diagnose

/// True if `body` (already run through `strip-labels`) still carries a
/// label that's the target of an actual `@ref`/`ref()` somewhere in the
/// bundle. `strip-labels` on `raw-body` handles a label sitting directly
/// in a passage's content (a bare figure inside a `touched` passage,
/// say — not wrapped in any mark); it *can't* reach a label that's part
/// of `add`/`del`/`rep`'s own content, because their visual rendering is
/// wrapped in `context` (needed for `render-mode-override`) and
/// therefore structurally opaque before layout, same as any `context`
/// block — that case is instead handled inside the marks themselves,
/// via `in-excerpt` (`utils.typ`), stripping their `body`/`old`/`new`
/// *before* the `context` wrapping ever applies. This check is the
/// backstop for whatever neither of those two reaches. Checking `ref`
/// targets rather than mere label existence is what excludes the
/// package's own internal tag labels (`<palimpsest-mark>` etc., reused
/// on every mark in the bundle by design) for free — two elements can
/// share a label harmlessly as long as nothing ever references it
/// (verified directly); Typst only rejects a label once something tries
/// to resolve it and finds it ambiguous.
#let has-conflicting-label(body) = {
  let referenced = query(ref).map(r => r.target)
  collect-labels(body).any(lbl => lbl in referenced)
}

/// Default `format:` for the page-only mode: "(modified on p. 7)" or
/// "(see p. 4)" when `<anchor>` matches no real `add`/`del`/`rep` mark
/// anywhere (a `touched` passage, cited only to point at unchanged
/// text) — never the same wrong "modified" for both cases, verified
/// exhaustively in `tests/bundle-pinpoint-methods.typ` (case 1.6: an
/// unqualified "modified" is not just clumsy there, it's false). This
/// substitution is not a `parens`/`verb` option: there is no legitimate
/// case for asserting a change that didn't happen, so it isn't gated
/// behind anything the caller has to remember to ask for.
///
/// `parens:` wraps the whole thing in parentheses (the historical,
/// still-default look — reads as a trailing citation, `tests/…` case
/// 1.1/1.5). `verb: none` drops "modified on"/"see" entirely, leaving
/// only "p. 7"/"p. 7 and p. 12" — for a sentence that already supplies
/// its own verb (case 1.2/1.3, where the wired-in parenthetical clashes
/// with "This sentence was updated:" or "See … for …"). Neither knob
/// alone covers every sentence shape tried; combined, the two do —
/// see the case-by-case comparison and the recap table in
/// `tests/bundle-pinpoint-methods.typ`.
#let format-pages(pages, has-marks, parens: true, verb: auto) = {
  let word = if verb == none {
    none
  } else if has-marks {
    "modified on"
  } else {
    "see"
  }
  let core = if pages.len() == 1 {
    if word != none { [#word p. #pages.first()] } else { [p. #pages.first()] }
  } else {
    let joined = pages.map(p => "p. " + str(p)).join(", ", last: " and ")
    if word != none { [#word #joined] } else { joined }
  }
  if parens { [(#core)] } else { core }
}

/// True if `body` (any Typst value) contains no `figure`, `table`, or
/// block-mode `math.equation` at or below its own top level — decides
/// whether an excerpt is safe to wrap in literal quotation marks
/// (`pinpoint(..., quotes: true)`). Forcing quotation marks onto a
/// figure produces two stray quote glyphs sitting alone above and below
/// it, confirmed directly (`tests/bundle-pinpoint-methods.typ`, case
/// Q.3) — not a matter of taste, a real visual defect, so `quotes:
/// true` only ever *requests* quotation marks; this check has the final
/// say.
#let is-textual(body) = {
  if type(body) != content {
    true
  } else {
    let is-block-eq = body.func() == math.equation and body.at("block", default: false)
    if body.func() == figure or body.func() == table or is-block-eq {
      false
    } else if repr(body.func()) == "sequence" {
      body.children.all(is-textual)
    } else {
      true
    }
  }
}

/// `is-textual`, extended to an entire `<palimpsest-passage>` metadata
/// value rather than a single content tree. Needed because `v.raw-body`
/// alone under-detects: content that passes through `add`/`del`/`rep`
/// has its *visible* copy wrapped in `context` (required for
/// `render-mode-override`, see `marks.typ`) and is therefore
/// structurally opaque before layout — a figure added via `#add[...]`
/// is invisible to `is-textual(v.raw-body)` alone, which silently falls
/// through to "textual" and would let `quotes: true` produce the very
/// stray-glyph defect it exists to prevent. Found by testing the
/// figure case specifically, not by inspection: an early version of
/// this check passed on a bare figure and failed silently on the same
/// figure nested inside `add` (`tests/bundle-pinpoint-methods.typ`, the
/// note following case Q.4). Each mark's `old`/`new` fields, captured
/// *before* that `context` wrapping (the same mechanism `in-excerpt`
/// below already relies on), are what make the mark's own content
/// inspectable — checked here in addition to `raw-body`, not instead of
/// it, since a figure sitting directly in the passage rather than
/// inside any mark only ever shows up in `raw-body`.
#let passage-is-textual(v) = {
  let marks-ok = v.marks.all(m => is-textual(m.old) and is-textual(m.new))
  is-textual(v.raw-body) and marks-ok
}

/// Queries the manuscript for every `passage` carrying `anchor` and
/// renders their location — or, with `excerpt: true`, their actual
/// content. This is the mechanism the spec (§1) calls out as the point
/// of the whole package: cross-document `query()` inside the same
/// bundle sees the manuscript's real page numbers and real content, so
/// the letter can never cite a stale page or a passage that no longer
/// reads the way the letter claims it does.
///
/// `mode:` (§6.4) picks how an excerpt's marks render, regardless of
/// what the *current compile* is actually doing: `auto` (default)
/// defers to the real compile mode, same as the manuscript's own copy;
/// `"clean"` forces the final-text-only look; `"tracked"` forces
/// struck/underlined marks, even though `response.pdf` is only ever
/// produced by the clean compile (§9.1) — reviewer-facing, "show what
/// changed" excerpts don't need a second compile to look tracked.
/// Implemented via `render-mode-override` (`utils.typ`), set right
/// before re-emitting `raw-body` and reset right after — resolution
/// follows document position, not call order, so this can't affect the
/// manuscript's own copy, laid out earlier at its own position. An
/// earlier version of this docstring called the feature out of scope,
/// worried that deferring `add`/`del`/`rep`'s clean/tracked choice
/// through a state would regress prose line-wrapping the way an
/// unrelated change did in M1 (`mark-line`, see the log below) — turned
/// out to be a different risk: `mark-line` broke things by wrapping
/// marked content in a measured `box`, not by deferring the mode
/// decision. Verified in isolation before wiring this in for real.
///
/// A figure/table/equation a passage adds, removes, or simply contains
/// is shown here in full even when its label is cross-referenced
/// elsewhere in the manuscript (`@fig-...`, the common case: most
/// figures worth adding are also worth discussing in text) — two label
/// stripping mechanisms cover this between them, one for content inside
/// a mark, one for content that isn't: `strip-labels(v.raw-body)` (run
/// unconditionally below) reaches a label sitting directly in the
/// passage's content (a bare figure inside a `touched` passage, or a
/// table with only one cell modified, say), but *can't* reach a label
/// that's part of `add`/`del`/`rep`'s own content, because their visual
/// rendering is wrapped in `context` (needed for `render-mode-override`
/// above) and therefore structurally opaque before layout — `in-excerpt`
/// (`utils.typ`), set right before re-emitting, makes each mark strip
/// its own `body`/`old`/`new` before that wrapping ever applies, which
/// covers the rest. Only once both have had their shot does a
/// remaining conflict fall back to the page number with a diagnostic,
/// rather than crash the whole compile on a duplicate label — see
/// `has-conflicting-label`.
///
/// `parens:`/`verb:` (page-only mode) and `show-page:`/`quotes:`
/// (excerpt mode) are the outcome of a dedicated exploration —
/// `tests/bundle-pinpoint-methods.typ` — testing the default rendering
/// against a battery of real sentence shapes, not designed up front:
///
/// - `parens: false` drops the parentheses around the page-only
///   citation, for a sentence that already supplies its own punctuation
///   ("See #pinpoint(<r>, parens: false, verb: none) for the updated
///   wording."). `verb: none` additionally drops "modified on"/"see",
///   leaving only the page — the two are independent because neither
///   alone covers every sentence shape tried (case B1 vs B2 in the
///   exploration); `verb: auto` (default) is not a style choice, it is
///   a correctness fix — see `format-pages`.
/// - `show-page: false` (excerpt mode) drops the leading "**p. X** — "
///   for a sentence that already states where the excerpt comes from,
///   or a caller who deliberately doesn't want it. `quotes: true` wraps
///   textual excerpts in real quotation marks (native `quote()`) —
///   silently declines to on anything `passage-is-textual` flags as
///   non-text (a figure, a table, a block equation), rather than
///   produce the stray-glyph defect forcing them always would (case
///   Q.3 in the exploration).
#let pinpoint(
  anchor,
  excerpt: false,
  parens: true,
  verb: auto,
  show-page: true,
  quotes: false,
  format: auto,
  mode: auto,
  on-empty: auto,
) = context {
  let hits = query(<palimpsest-passage>).filter(el => el.value.anchors.contains(anchor))

  if hits.len() == 0 {
    if on-empty == auto {
      diagnose("pinpoint(" + repr(anchor) + "): no revision attached to this anchor", always: true)
    } else if on-empty == none {
      none
    } else {
      on-empty
    }
  } else if not excerpt {
    let pages = hits.map(h => h.location().page()).dedup()
    let has-marks = hits.any(h => h.value.marks.len() > 0)
    if format == auto {
      format-pages(pages, has-marks, parens: parens, verb: verb)
    } else {
      format(pages, has-marks)
    }
  } else {
    hits.map(h => {
      let v = h.value
      let stripped = strip-labels(v.raw-body)
      if v.summary != none {
        [Removed: #v.summary.]
      } else if has-conflicting-label(stripped) {
        // Falling back to the page rather than crashing the compile —
        // same "gracefully degrade on a hard case" choice the spec
        // makes for `window:` on non-prose (§6.3). Only reached once
        // both label-stripping mechanisms have already had their shot —
        // a genuinely stubborn case. Always shows the page regardless
        // of `show-page:` — this is a degraded fallback carrying a
        // diagnostic, not a normal citation the caller is styling.
        [*p. #h.location().page()* — #diagnose("pinpoint(" + repr(anchor) + ", excerpt: true): passage contains a label referenced elsewhere in the bundle; showing the page only", always: true)]
      } else {
        let content = {
          current-passage-anchors.update(v.anchors)
          in-excerpt.update(true)
          if mode != auto { render-mode-override.update(mode) }
          if quotes and passage-is-textual(v) { quote(stripped) } else { stripped }
          if mode != auto { render-mode-override.update(none) }
          in-excerpt.update(false)
          current-passage-anchors.update(none)
        }
        if show-page {
          [*p. #h.location().page()* --- #content]
        } else {
          content
        }
      }
    }).join(parbreak())
  }
}
