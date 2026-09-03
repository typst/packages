#import "utils.typ": parse-anchor, default-del-mark

/// Default palette, one color per reviewer, ordered so that adjacent
/// reviewers stay visually distinct (varies by more than hue: styles also
/// differ by underline vs. strike, so black-and-white printing still
/// distinguishes add from del even where color is lost).
#let default-palette = (
  rgb("#1a5fb4"), // reviewer 1 — blue
  rgb("#a51d2d"), // reviewer 2 — red
  rgb("#2ec27e"), // reviewer 3 — green
  rgb("#813d9c"), // reviewer 4 — purple
  rgb("#e66100"), // reviewer 5 — orange
  rgb("#0ab9dc"), // reviewer 6 — cyan
)

/// Color a fully neutral, template-safe gray, used for passages without a
/// reviewer-shaped anchor (typographical fixes with no anchor at all).
#let neutral-color = rgb("#5c5c5c")

/// Color for editor comments — distinct from every reviewer slot in
/// `default-palette`, dark enough to read as "authority", not "reviewer".
#let editor-color = rgb("#241f31")

#let reviewer-color(n) = default-palette.at(calc.rem(n - 1, default-palette.len()))

/// Muted variant of an `add` color, used for `del`: desaturated and
/// darkened rather than a plain gray, so a deletion still reads as
/// "the same reviewer, muted" rather than losing reviewer identity
/// altogether. Exists because `add` and `del` used to share one color,
/// distinguished only by decoration (`underline` vs `strike`) — which
/// works on text but leaves the two visually identical on math, where
/// neither decoration reaches the real glyphs (`tests/strike-methods.typ`
/// §"Le vrai problème", cases E.1–E.4; full exploration and the decision
/// to fix it this way in `CLAUDE.md`). The exact formula is a first
/// working draft, not tuned against the whole palette above.
#let del-color(c) = c.desaturate(60%).darken(15%)

#let default-style = (
  style: "inline", // "inline" | "bar" | "none"  ("margin" is v0.2)
  color: auto, // auto = anchors-color(...), or a fixed color to override per-reviewer/author colors
  add-style: underline,
  del-style: default-del-mark,
  highlight-passage: false,
  show-anchor: true,
  del-numbering: "none", // "none" | "keep"
  require-exchange: true, // numbered anchors with no matching exchange warn by default
  comment-word: "comment", // header noun for reviewer/editor exchanges: "Reviewer 1 — comment 2"
  change-word: "change", // header noun for author notes: "Bobby Fischer — change 3"
)

// Defined here (right after the plain color helpers, before the author
// section below) rather than further down with `set-revisions`, purely
// so `anchors-color` — which needs to read it — can be defined right
// after it: Typst resolves top-level names in file order, a function
// can't forward-reference a `#let` that appears later in the same
// module (verified directly: calling a closure that reads a name bound
// afterward errors "unknown variable", it's not hoisted).
#let style-state = state("palimpsest-style", default-style)

/// Palette for co-author anchors (`author-color`, below) — deliberately
/// different hues from `default-palette`, not just a rotation of it, so a
/// reviewer and a co-author showing up in the same tracked manuscript
/// (revision and peer review overlapping) are never confusable at a
/// glance, even by coincidence.
#let default-author-palette = (
  rgb("#0d9488"), // teal
  rgb("#b45309"), // amber
  rgb("#be185d"), // pink
  rgb("#4d7c0f"), // olive
  rgb("#4338ca"), // indigo
  rgb("#78350f"), // brown
)

/// Registry populated by `set-revisions(authors: ...)`: maps an author id
/// (the string parsed out of an anchor like `<bob-3>`) to a dict with
/// optional `name:`/`color:` keys. Kept as its own state, separate from
/// `style-state`, since it's data (who's who), not a rendering style
/// knob — but still just a "set once via `set-revisions`, read many
/// times" state, the same shape `style-state` already is, not the
/// per-occurrence kind of state that turned out not to fit `anchors-color`
/// (see `author-color` below).
#let author-registry = state("palimpsest-authors", (:))

/// Deterministic, configuration-free color for an author id: the sum of
/// its characters' Unicode codepoints, modulo the palette size — verified
/// directly (`"bob"` and `"alice"` land on different slots). Pure
/// function of the string, not of document position: an *auto-assigned
/// color* was originally meant to go "first author encountered in the
/// document gets slot 0, second gets slot 1", but that requires
/// `anchors-color`'s call sites (`mark-visual`, `passage`, `suppress` in
/// `marks.typ`) to *emit* a state-update marker into the rendered tree at
/// each occurrence — state updates only take effect once actually placed
/// in content, not merely called as a side effect inside a plain
/// function (verified directly, isolated from this codebase). That's a
/// materially bigger, riskier change than a color lookup should need, so
/// the hash instead: same color for the same name everywhere, no state,
/// no restructuring, at the accepted cost that two unrelated names can
/// coincidentally land on the same slot.
#let author-hash-color(id) = {
  let sum = id.clusters().map(c => c.to-unicode()).sum(default: 0)
  default-author-palette.at(calc.rem(sum, default-author-palette.len()))
}

/// Color for an author id: the registry's explicit `color:` if one was
/// configured via `set-revisions(authors: ...)`, otherwise the
/// deterministic hash color above.
///
/// Deliberately *not* wrapped in its own `context`: `author-registry` is
/// only ever written once (by `set-revisions`), so reading it is exactly
/// the same "set once, read many times" shape `style-state` already is
/// throughout this file. A plain function that calls `.get()` directly,
/// invoked from *within* a caller's existing `context` block (as
/// `anchors-color` already is at all three of its call sites), resolves
/// fine and returns a plain, immediately usable color — verified
/// directly. Wrapping it in a redundant nested `context` here would
/// instead turn the return value into content, breaking every caller
/// that does `color.lighten(...)`/`fill: color` on the result.
#let author-color(id) = {
  let entry = author-registry.get().at(id, default: (:))
  entry.at("color", default: author-hash-color(id))
}

/// Display name for an author id: the registry's `name:` if configured,
/// otherwise the raw id exactly as written in the anchor. Same "plain
/// function, ambient context" reasoning as `author-color` above.
#let author-display-name(id) = {
  let entry = author-registry.get().at(id, default: (:))
  entry.at("name", default: id)
}

/// Picks the color for a set of anchors: `set-revisions(color: ...)`
/// wins outright if set (a fixed color for every mark, no exceptions —
/// this is the one knob meant to *override* per-reviewer/author
/// coloring entirely, not participate in it); otherwise the first
/// anchor that parses (`r<reviewer>-<n>`, `e<n>`, or `<author>[-<n>]`)
/// decides the color; a passage with no anchor at all, or nothing left
/// to decide, gets `neutral-color`.
#let anchors-color(anchors) = {
  let sty = style-state.get()
  if sty.color != auto {
    return sty.color
  }
  for a in anchors {
    let p = parse-anchor(a)
    if p != none {
      return if p.kind == "editor" {
        editor-color
      } else if p.kind == "author" {
        author-color(p.author)
      } else {
        reviewer-color(p.reviewer)
      }
    }
  }
  neutral-color
}

/// Normalizes one `authors:` entry to `(name: ..., color: ...)`, either
/// key possibly absent: a plain string is shorthand for `(name: string)`;
/// a dict passes through, keeping only `name:`/`color:` if present.
#let normalize-author-entry(v) = {
  if type(v) == str { (name: v) } else { v }
}

/// Sets the document-wide revision style. Call once, before any `passage`.
/// Unset (`auto`) parameters keep their current value — repeated calls
/// merge rather than reset.
///
/// `authors:` registers co-author ids (see `parse-anchor`'s `author`
/// kind) to a full display name and/or a fixed color — e.g.
/// `authors: (bob: (name: "Bobby Fischer", color: rgb("#...")), alice:
/// "Alice Smith")`. Unlike the other parameters here, passing `authors:`
/// *replaces* the whole registry rather than merging key-by-key — call
/// it once with the complete map. An author id never mentioned here
/// still works (see `author-color`/`author-display-name`), just with an
/// automatic hash-based color and its raw id as the display name.
///
/// `require-exchange:` gates the "anchor: no matching exchange" warning
/// (`passage`, `marks.typ`) for *numbered* anchors — bare, number-less
/// anchors (`<bob>`, no `-<n>`) are always exempt regardless of this
/// setting, since they're not meant to key into one particular exchange
/// in the first place.
///
/// `comment-word:`/`change-word:` control the noun `exchange`/`note`
/// generate in their header ("Reviewer 1 — comment 2" / "Bobby Fischer —
/// change 3") — overridable per call via `exchange(..., term: ...)`/
/// `note(..., term: ...)`.
#let set-revisions(
  style: auto,
  color: auto,
  add-style: auto,
  del-style: auto,
  highlight-passage: auto,
  show-anchor: auto,
  del-numbering: auto,
  authors: auto,
  require-exchange: auto,
  comment-word: auto,
  change-word: auto,
) = {
  if authors != auto {
    author-registry.update(authors.pairs().map(((k, v)) => (k, normalize-author-entry(v))).to-dict())
  }
  style-state.update(s => {
    if style != auto { s.style = style }
    if color != auto { s.color = color }
    if add-style != auto { s.add-style = add-style }
    if del-style != auto { s.del-style = del-style }
    if highlight-passage != auto { s.highlight-passage = highlight-passage }
    if show-anchor != auto { s.show-anchor = show-anchor }
    if require-exchange != auto { s.require-exchange = require-exchange }
    if comment-word != auto { s.comment-word = comment-word }
    if change-word != auto { s.change-word = change-word }
    if del-numbering != auto { s.del-numbering = del-numbering }
    s
  })
}
