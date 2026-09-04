/// Internal label wrapping the whole response letter's content, so that
/// `letter-bibliography` can scope citations to it via `within` (§8) and
/// `revisions` knows what to place inside `response.pdf`.
#let letter-root = <palimpsest-letter>

/// Minimal default letter template — a title, nothing else. Overridable
/// wholesale via `revisions(letter-template: ...)`.
#let default-letter-template(body) = {
  align(center, text(size: 1.4em, weight: "bold")[Response to Reviewers])
  v(1.5em)
  body
}

/// Wraps `body` with the letter's own figure/table numbering (§7.2):
/// "Figure R1", restarting from the manuscript's own numbering, so a
/// figure the letter includes "for the reviewer only" is never
/// confusable with a manuscript figure. Only actually reaches a figure
/// that has no manuscript original to match — one `pinpoint(excerpt:
/// true)` re-emits from the manuscript instead shows that original's
/// *own* real number, pinned by `strip-labels` (`utils.typ`) before
/// this `set` rule ever gets a say (a local `numbering:` on the figure
/// itself always wins) — so "R1", "R2", ... now only ever means "a
/// figure genuinely native to this letter," never "a citation of
/// manuscript figure N," a distinction the plain "R" sequence didn't
/// carry on its own before this pinning existed. Must structurally *wrap* `body`
/// — not run as a sibling statement before it — because `set` rules
/// scope to the content they contain, not to whatever a caller happens
/// to place next to their result.
///
/// Resets one counter *per figure kind* (`image`, `table`, `raw` — the
/// three Typst infers automatically depending on what a figure wraps,
/// verified directly: `figure(rect(...))` gets `kind: image`,
/// `figure(table(...))` gets `kind: table`, `figure(raw(...))` gets
/// `kind: raw`), not the bare `counter(figure)`. This isn't
/// belt-and-braces: `counter(figure)` and `counter(figure.where(kind:
/// image))` are genuinely different counter objects in Typst 0.15 —
/// verified directly, including across `#document(...)` boundaries in a
/// bundle — and a `figure`'s own displayed number is computed from the
/// *kind-scoped* one. Resetting only the bare `counter(figure)` looks
/// like it works (`context counter(figure).get()` reads back `0` right
/// after), but the actual number shown on the next figure of a given
/// kind is unaffected by that reset — it keeps counting from wherever
/// that kind's counter already was (e.g. from a manuscript figure of
/// the same kind counted earlier in the bundle), producing "Figure R2"
/// instead of "Figure R1" for what is the *only* figure in the letter.
/// A figure using an explicit custom `kind:` (rare) isn't covered by
/// this reset — out of scope for v0.1, same spirit as other
/// template-shape assumptions already documented as limitations.
#let with-letter-numbering(body) = {
  set figure(numbering: n => "R" + str(n))
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: raw)).update(0)
  body
}

/// The letter's own bibliography, restricted to citations made *inside*
/// the letter (`within(letter-root)`) and numbered independently from
/// the manuscript's own bibliography (`group: "letter"`, not the
/// manuscript's `auto` group) — without both, the letter would either
/// absorb the manuscript's citations or share its numbering (§8).
///
/// Note for spec maintenance: the spec's example uses `group: false`;
/// Typst 0.15's `bibliography()` takes `auto` or a name *string* for
/// `group`, not a boolean — verified directly, `false` is a compile
/// error. Fixed here; the spec text should be corrected too.
///
/// `path` must be root-relative (leading `/`, resolved against
/// `--root`), not relative to `responses.typ`. Typst resolves a path
/// string against the file that *calls the path-consuming builtin* —
/// here, `bibliography()` inside this very function, in `letter.typ` —
/// not the file that wrote the string literal. A plain
/// `"responses.bib"` would make Typst look for the file next to
/// `letter.typ` inside the package itself, and fail. Verified directly;
/// this is standard Typst behavior; every package function that takes a
/// user path has the same constraint.
#let letter-bibliography(path, title: [References cited in this response]) = {
  bibliography(
    path,
    title: title,
    target: selector(cite).within(letter-root),
    group: "letter",
  )
}
