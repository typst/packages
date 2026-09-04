#import "utils.typ": collect-metadata, normalize-anchors, current-passage-anchors, render-mode-override, in-excerpt, strip-labels, parse-anchor, numbered-kinds-in
#import "style.typ": style-state, anchors-color, neutral-color, del-color
#import "diagnostics.typ": diagnose

/// Always the real compile mode — for the author's own mode-dependent
/// content. Never influenced by `pinpoint`'s local override (see
/// `effective-mode`, which is what `add`/`del`/`rep` use internally).
#let mode() = sys.inputs.at("mode", default: "clean")

/// What `add`/`del`/`rep` actually render by, read via `context`:
/// `render-mode-override` when `pinpoint(excerpt: true, mode: ...)` has
/// set one for the content currently being re-emitted, otherwise the
/// real compile mode.
#let effective-mode() = {
  let ov = render-mode-override.get()
  if ov != none { ov } else { mode() }
}

/// Renders a mark's tracked-mode appearance: styled per `add-style`/
/// `del-style`, colored by the enclosing passage's reviewer — `del`
/// desaturated via `del-color` so an addition and a deletion of the
/// same math never look identical (`tests/strike-methods.typ`, cases
/// E.1–E.4) — neutralized to the clean look when `style: "none"`
/// (layout QA mode, §10.1).
#let mark-visual(kind, body) = context {
  let sty = style-state.get()
  let anchors = current-passage-anchors.get()
  let outside = anchors == none
  let warning = if outside {
    diagnose("#" + kind + " outside any passage: no anchor, no page")
  }
  if sty.style == "none" and not outside {
    if kind == "add" { body } else { none }
  } else {
    let base-color = if outside { neutral-color } else { anchors-color(anchors) }
    let color = if kind == "del" { del-color(base-color) } else { base-color }
    let styled = if kind == "add" { (sty.add-style)(body) } else { (sty.del-style)(body) }
    // Still render a fallback even when outside a passage — losing the
    // reviewer's text on top of the diagnostic would compound the
    // author's mistake, not flag it.
    [#warning#text(fill: color, styled)]
  }
}

/// Keeps figure/table/equation/heading numbering in deleted content
/// shown in tracked mode from disturbing anything that comes after it,
/// so clean and tracked versions keep identical numbering (§7.3) —
/// while still letting the deleted element show its own real number
/// (struck through), rather than hiding it. Snapshots every relevant
/// counter right before `body`, lets `body` render normally (so a
/// deleted figure/heading/equation still consumes and displays its true
/// number, exactly as it would if kept), then resets each counter back
/// to its snapshot right after — an absolute restore, not a per-element
/// decrement, so it stays correct no matter how many numbered elements
/// `body` contains or how they're nested (a deleted top-level section
/// that itself contains a deleted subsection and a deleted figure, all
/// in one `del(...)`, restores correctly in one shot: verified directly,
/// see the exploration notes below). Figures are reset per `kind`
/// (`image`/`table`/`raw`, the same three `with-letter-numbering`,
/// `letter.typ`, already resets) since Typst scopes a figure's real
/// displayed number to a kind-specific counter, not the bare
/// `counter(figure)` (§6quaterquadragies-class distinction, verified
/// directly). `math.equation` has no such per-kind split — one shared
/// counter for every equation.
///
/// Also verified directly against `@preview/charged-ieee`, which
/// reimplements figure numbering via its own show rule and used to
/// crash outright on `numbering: none` (the previous approach here):
/// with a real number left in place and only the counter restored
/// afterward, it neither crashes nor leaks — the show rule reads the
/// same counter this restores, so it renders the correct number too.
/// `suppress`/`suppressed` remain the answer when the deleted content
/// itself shouldn't be shown at all, not merely mis-numbered.
///
/// No-op when `del-numbering: "keep"` — the deleted element consumes a
/// real, unrestored number and everything after it shifts, on purpose.
///
/// Only snapshots/restores the counters actually present in the
/// *original, unwrapped* content — `kinds`, from `numbered-kinds-in`
/// (`utils.typ`), computed by the caller (`del`/`rep`) from the raw
/// body *before* it's passed through `mark-visual` — not all five
/// unconditionally. Two independent reasons, found in this order:
/// first, correctness at scale — touching every counter on every
/// deletion regardless of content overloads Typst's layout solver once
/// several mixed deletions stack up in one document (see
/// `numbered-kinds-in`'s docstring for the reproduction). Second, and
/// more fundamental: `kinds` *cannot* be computed from `body` as
/// received here, because by the time `del`/`rep` call this function
/// `body` is already `mark-visual(...)`'s output — a `context` value,
/// structurally opaque like any other, so a first attempt at detecting
/// kinds internally, from this parameter, silently found nothing every
/// time and disabled every restore unconditionally instead of only the
/// unnecessary ones (verified directly, caught by re-checking actual
/// rendered numbers after the "no convergence warning" result looked
/// like success — the warning was gone only because nothing was being
/// restored *at all* any more, not because the restores had become
/// correctly selective).
#let neutralize-numbering(body, kinds) = context {
  let sty = style-state.get()
  if sty.del-numbering == "none" {
    let snap-heading = if kinds.heading { counter(heading).get() }
    let snap-image = if kinds.image { counter(figure.where(kind: image)).get() }
    let snap-table = if kinds.table { counter(figure.where(kind: table)).get() }
    let snap-raw = if kinds.raw { counter(figure.where(kind: raw)).get() }
    let snap-equation = if kinds.equation { counter(math.equation).get() }
    body
    if kinds.heading { counter(heading).update(snap-heading) }
    if kinds.image { counter(figure.where(kind: image)).update(snap-image) }
    if kinds.table { counter(figure.where(kind: table)).update(snap-table) }
    if kinds.raw { counter(figure.where(kind: raw)).update(snap-raw) }
    if kinds.equation { counter(math.equation).update(snap-equation) }
  } else {
    body
  }
}

/// Marks `body` as newly added text. Emits nothing structural of its own
/// beyond the mark metadata: the anchor and page come from the enclosing
/// `passage`.
#let add(body) = {
  [#metadata((tag: "palimpsest-mark", kind: "add", old: none, new: body)) <palimpsest-mark>]
  context {
    let body = if in-excerpt.get() { strip-labels(body) } else { body }
    if effective-mode() == "clean" {
      body
    } else {
      mark-visual("add", body)
    }
  }
}

/// Marks `body` as removed text. Emits nothing in clean mode — a deletion
/// that survives into the clean version isn't a deletion (§7.3): no
/// `hide()`, no reserved space, no consumed counter.
#let del(body) = {
  [#metadata((tag: "palimpsest-mark", kind: "del", old: body, new: none)) <palimpsest-mark>]
  context {
    let body = if in-excerpt.get() { strip-labels(body) } else { body }
    if effective-mode() == "clean" {
      none
    } else {
      // `numbered-kinds-in` must see the *raw* body, before
      // `mark-visual` wraps it in its own `context` block — a context
      // value is structurally opaque, so computing kinds from
      // `mark-visual`'s output instead (tried first) silently found
      // nothing every time, disabling the counter restore below for
      // every kind, always — verified directly, see
      // `neutralize-numbering`'s docstring.
      neutralize-numbering(mark-visual("del", body), numbered-kinds-in(body))
    }
  }
}

/// Marks a replacement of `old` by `new`. Clean mode shows `new` only;
/// tracked mode shows both, `old` struck and numbering-neutralized, `new`
/// styled as an addition.
#let rep(old, new) = {
  [#metadata((tag: "palimpsest-mark", kind: "rep", old: old, new: new)) <palimpsest-mark>]
  context {
    let stripping = in-excerpt.get()
    let old = if stripping { strip-labels(old) } else { old }
    let new = if stripping { strip-labels(new) } else { new }
    if effective-mode() == "clean" {
      new
    } else {
      let sty = style-state.get()
      if sty.style == "none" {
        new
      } else {
        [#neutralize-numbering(mark-visual("del", old), numbered-kinds-in(old)) #mark-visual("add", new)]
      }
    }
  }
}

/// Marks the entirety of a passage's content as removed, like `del` —
/// but unlike `del`, never renders the removed content in tracked mode,
/// only `note`, centered like the floating element it typically
/// replaces (a figure, a table, an equation). `del`'s tracked rendering
/// still emits a real `figure`/`math.equation`, and some templates
/// recompute their own numbering from a show rule that ignores
/// `del-numbering: "none"` — silently (a deleted figure keeps a real,
/// template-assigned number that doesn't exist in the clean version) or
/// by crashing outright if forced harder (verified against
/// `charged-ieee`, see CLAUDE.md). `suppress` sidesteps the whole
/// problem by construction: since no real figure/table/equation is ever
/// emitted here, there is nothing for a template's numbering to
/// interfere with, regardless of how that template implements it.
#let suppress(note) = {
  [#metadata((tag: "palimpsest-mark", kind: "suppress", old: note, new: none)) <palimpsest-mark>]
  if mode() == "clean" {
    none
  } else {
    context {
      let anchors = current-passage-anchors.get()
      if anchors == none {
        diagnose("#suppress outside any passage: no anchor, no page")
      } else {
        align(center, block(text(fill: del-color(anchors-color(anchors)), style: "italic")[[#note]]))
      }
    }
  }
}

/// The citable unit: wraps `body` (plain text and/or `add`/`del`/`rep`
/// marks) and attaches the anchor(s) that the response letter's
/// `pinpoint` will resolve back to this location.
///
/// Called either as `passage(anchors, body)` or, for a passage with no
/// anchor (typographical fix, editor request), as `passage(body)` — the
/// arity of the positional arguments decides which.
///
/// `anchors` is `none`, a single label, or an array of labels.
/// `summary`, when given, is what `pinpoint(excerpt: true)` renders
/// instead of the passage content — for a passage that is entirely
/// deleted and therefore has no meaningful excerpt in the clean version
/// (§6.3).
/// `allow-empty` suppresses the "no mark" diagnostic — used by `touched`,
/// which declares a location without marking any change.
#let passage(..args) = {
  let pos = args.pos()
  let (anchors, body) = if pos.len() >= 2 { (pos.at(0), pos.at(1)) } else { (none, pos.at(0)) }
  let summary = args.named().at("summary", default: none)
  let allow-empty = args.named().at("allow-empty", default: false)
  let anchor-list = normalize-anchors(anchors)
  let marks = collect-metadata(body, "palimpsest-mark")

  current-passage-anchors.update(anchor-list)
  [#metadata((
    tag: "palimpsest-passage",
    anchors: anchor-list,
    summary: summary,
    marks: marks,
    raw-body: body,
  )) <palimpsest-passage>]

  if marks.len() == 0 and summary == none and not allow-empty {
    let where = if anchor-list.len() > 0 { " " + anchor-list.map(str).join(", ") } else { "" }
    diagnose("passage" + where + ": contains no mark (did you mean touched?)")
  }

  context {
    let sty = style-state.get()
    for a in anchor-list {
      let p = parse-anchor(a)
      // A bare, number-less anchor (`<bob>`, no `-<n>`) isn't meant to
      // key into one particular exchange in the first place — the "pure
      // change-tracking, no letter" workflow reuses it freely across
      // many passages, possibly with no exchange/note ever written for
      // it. `require-exchange: false` (`set-revisions`) additionally
      // silences the check for *numbered* anchors too, for someone who
      // wants the numbering/coloring but genuinely never writes a
      // response document.
      let bare = p != none and p.num == none
      if not bare and sty.require-exchange {
        let matches = query(<palimpsest-exchange>).any(el => el.value.anchor == a)
        if not matches {
          diagnose("anchor " + str(a) + ": no matching exchange")
        }
      }
    }
  }

  context {
    let sty = style-state.get()
    let show-tracked = mode() != "clean" and sty.style != "none"
    let color = anchors-color(anchor-list)
    let content = if show-tracked and sty.highlight-passage {
      box(fill: color.lighten(85%), inset: (x: 2pt), outset: (y: 2pt), radius: 1pt)[#body]
    } else {
      body
    }
    let tagged = if show-tracked and sty.show-anchor and anchor-list.len() > 0 {
      [#content #super(text(fill: color, size: 0.75em)[\[#anchor-list.map(a => upper(str(a))).join(", ")\]])]
    } else {
      content
    }
    if show-tracked and sty.style == "bar" {
      block(
        stroke: (left: 2pt + color),
        inset: (left: 6pt),
        spacing: 0.65em,
        width: 100%,
      )[#tagged]
    } else {
      tagged
    }
  }
  current-passage-anchors.update(none)
}

/// `passage` + `add` in one call, for a passage entirely made of new text.
#let added(anchors, body, summary: none) = passage(anchors, add(body), summary: summary)

/// `passage` + `del` in one call, for a passage entirely removed.
#let deleted(anchors, body, summary: none) = passage(anchors, del(body), summary: summary)

/// `passage` + `suppress` in one call: the passage is entirely removed,
/// with `note` shown centered in the tracked manuscript in place of the
/// real content — see `suppress` for why this exists alongside
/// `deleted`. `note` also becomes `pinpoint`'s excerpt summary unless
/// `summary:` is given explicitly: the manuscript placeholder and the
/// letter's summary don't have to read the same way (one is written for
/// a reader mid-manuscript, the other for a reviewer mid-letter who
/// already has the comment in front of them), so the two are kept as
/// distinct parameters rather than one doing double duty — but default
/// to sharing `note`'s text, since most of the time they don't need to
/// differ.
///
/// Deliberately takes **no** original-content parameter at all, unlike
/// `deleted(anchors, body, ...)` — this is not an oversight. The real
/// content is never rendered anywhere by this function, clean or
/// tracked; a parameter that only ever sat there unused would be pure
/// latent risk (a future edit that starts passing it to something that
/// *does* render it, defeating the whole point of `suppress` over
/// `del`) for no benefit. If you want the removed material kept at hand
/// in the source — to reconsider later, say — a plain `//` comment
/// right above the call is inert (Typst never evaluates it) and costs
/// nothing; git history keeps it regardless either way.
#let suppressed(anchors, note, summary: auto) = passage(
  anchors,
  suppress(note),
  summary: if summary == auto { note } else { summary },
)

/// `passage` + `rep` in one call, for a passage entirely rewritten.
#let replaced(anchors, old, new, summary: none) = passage(anchors, rep(old, new), summary: summary)

/// Declares a location without marking any change — "see p. 4, we keep
/// this wording as is".
#let touched(anchors, body) = passage(anchors, body, allow-empty: true)
