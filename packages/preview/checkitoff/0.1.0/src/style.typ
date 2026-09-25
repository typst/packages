/// Shallow dict merge: every key of `b` overrides the same key in `a`,
/// everything else from `a` passes through unchanged. Typst dictionaries
/// have no `+`/merge operator, so this is spelled out explicitly —
/// `.insert()` mutates the local variable `m` in place (same "bound
/// variable, not a derived value" rule `.push()` relies on for arrays
/// elsewhere in this package, see `grid.typ`'s `consecutive-runs`).
#let merge(a, b) = {
  let m = a
  for (k, v) in b { m.insert(k, v) }
  m
}

/// Package-wide fallback, used only for whatever a checklist's own
/// `style:` doesn't set (see `effective-style` below) — deliberately
/// generic/neutral (portrait, no color) rather than shaped after any one
/// real checklist, since a checklist author who wants their own grid to
/// look a specific way is expected to say so via `style:` on their own
/// checklist data, not rely on checkitoff's taste. `font: auto` and
/// `header-fill: none` mean "whatever the ambient template already has"
/// — a checklist that doesn't care about its own look shouldn't force
/// one either.
#let package-default-style = (
  preview-color: rgb("#1a5fb4"),
  show-id: true,
  paper: "a4",
  landscape: false,
  columns: (18%, 7%, 1fr, 10%),
  font: auto,
  text-size: auto,
  header-fill: none,
  header-text-color: black,
  section-fill: rgb("#eeeeee"),
  section-text-color: black,
  group-fill: rgb("#f5f5f5"),
  group-text-color: black,
)

/// Only ever holds keys the *author* explicitly set via `set-style(...)`
/// — never a full style dict — so that `effective-style` can tell "the
/// author asked for this" apart from "this is just some default" and
/// layer authorial overrides on top of the checklist's own style rather
/// than the other way around. Starts empty: no override until
/// `set-style` is actually called.
#let style-overrides = state("checkitoff-style-overrides", (:))

/// Sets document-wide style overrides. Call once, before any `check()`/
/// `render-checklist()`. Unset (`auto`) parameters are left untouched —
/// repeated calls merge rather than reset, same convention as
/// palimpsest's `set-revisions`. These values win over *both* checkitoff's
/// package default *and* whatever the active checklist's own `style:`
/// specifies (see `effective-style`) — an explicit ask from the author
/// compiling this particular manuscript is the most specific signal
/// available, so it gets the final word.
#let set-style(
  preview-color: auto,
  show-id: auto,
  paper: auto,
  landscape: auto,
  columns: auto,
  font: auto,
  text-size: auto,
  header-fill: auto,
  header-text-color: auto,
  section-fill: auto,
  section-text-color: auto,
  group-fill: auto,
  group-text-color: auto,
) = {
  let given = (
    preview-color: preview-color,
    show-id: show-id,
    paper: paper,
    landscape: landscape,
    columns: columns,
    font: font,
    text-size: text-size,
    header-fill: header-fill,
    header-text-color: header-text-color,
    section-fill: section-fill,
    section-text-color: section-text-color,
    group-fill: group-fill,
    group-text-color: group-text-color,
  ).pairs().filter(((k, v)) => v != auto).to-dict()
  style-overrides.update(s => merge(s, given))
}

/// The style `render-checklist` actually renders with, three layers deep,
/// each overriding only the keys the previous layer left unset:
/// `package-default-style` (generic, checklist-agnostic) <- the active
/// `checklist`'s own `style:` field, if it has one (its real, source
/// document's look — CONSORT's landscape A4 and pale blue bands, PRISMA's
/// navy header, STROBE's plain black-and-white, ...) <- whatever the
/// compiling author explicitly asked for via `set-style(...)`. This is
/// the mechanism that lets every checklist keep its own distinct
/// appearance by default while still being fully overridable per compile
/// — generalizing the *rendering logic* (`grid.typ`) without forcing one
/// shared visual theme onto every grid.
/// A plain function, not itself wrapped in `context` — same reasoning as
/// palimpsest's `anchors-color` (`style.typ` there): it reads
/// `style-overrides.get()`, which needs an ambient `context`, supplied by
/// whichever caller invokes this (`render-checklist`, always itself a
/// `context` block) rather than nesting a redundant one here. Wrapping
/// this in its own `context` would turn the return value into a
/// deferred/contextual value instead of a plain dictionary, breaking
/// every caller that reads a field off the result directly.
#let effective-style(checklist) = merge(
  merge(package-default-style, checklist.at("style", default: (:))),
  style-overrides.get(),
)

/// `preview-color`/`show-id` for `check()`'s preview-mode rendering
/// (`marks.typ`) — no checklist to consult there (`check()` doesn't know
/// which checklist is active, by design, see `resolve.typ`), and no need
/// for one either: the preview rendering is a drafting aid, not an
/// attempt to match any source document's look, so it only ever needs
/// the package default plus whatever the author explicitly overrode.
/// Same "plain function, ambient context supplied by the caller" shape
/// as `effective-style` above.
#let preview-style() = merge(package-default-style, style-overrides.get())
