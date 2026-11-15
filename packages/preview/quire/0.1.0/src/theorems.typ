/// This module defines theorem-like environments, built on the `theorion` package.
#import "@preview/theorion:0.6.0" as theorion: (
  indent-fakepar, indent-repairer, make-frame, set-indent-mode, theorion-i18n, theorion-i18n-map,
)
#import "config.typ": _config
#import "headings.typ": _within-section

/// Numbers a theorem-like environment within its section, like figures and equations. Theorion calls it with the
/// location of the frame and expects a numbering function.
///
/// -> function
#let _numbering(_) = (..nums) => {
  let nums = nums.pos()
  _within-section(_config.get(), nums.slice(0, -1), nums.last())
}

/// Generic renderer for theorem-like frames, the `render` callback of theorion's `make-frame`: the full title (in
/// small caps by default) followed by the body (in italics by default) in a single paragraph.
///
/// -> content
#let _render(
  /// The prefix of the frame. Provided by theorion and unused.
  /// -> content
  prefix: none,
  /// The user-provided title of the frame. Provided by theorion and unused.
  /// -> str | content
  title: "",
  /// The full title of the frame: name, number and optional title. Provided by theorion.
  /// -> content
  full-title: auto,
  /// Function styling the full title.
  /// -> function
  render-full-title: smallcaps,
  /// Function styling the body.
  /// -> function
  render-body: emph,
  /// The body of the frame. Provided by theorion.
  /// -> content
  body,
) = context {
  // Theorion reads its indentation settings from state, hence the context.
  block(width: 100%, spacing: 1.3em, indent-repairer(render-full-title(full-title) + [. ] + render-body(body)))
  indent-fakepar
}

/// Renderer for definition-like frames: upright body.
#let _render-definition = _render.with(render-body: it => it)

/// Renderer for remark-like frames: emphasized full title and upright body.
#let _render-remark = _render.with(render-full-title: emph, render-body: it => it)

/// Creates a frame sharing the counter of `theorem`.
#let _frame(identifier, counter: none, render: _render) = make-frame(
  identifier,
  theorion-i18n-map.at(identifier),
  counter: counter,
  numbering: _numbering,
  render: render,
)

/// Theorem environment. All the theorem-like environments share its counter.
///
/// ```typ
/// #theorem(title: [Euclid])[There are infinitely many primes.]
/// ```
#let (theorem-counter, theorem-box, theorem, _show-theorem) = _frame("theorem")

/// Lemma environment.
#let (lemma-counter, lemma-box, lemma, _show-lemma) = _frame("lemma", counter: theorem-counter)

/// Proposition environment.
#let (proposition-counter, proposition-box, proposition, _show-proposition) = _frame(
  "proposition",
  counter: theorem-counter,
)

/// Corollary environment.
#let (corollary-counter, corollary-box, corollary, _show-corollary) = _frame("corollary", counter: theorem-counter)

/// Conjecture environment.
#let (conjecture-counter, conjecture-box, conjecture, _show-conjecture) = _frame("conjecture", counter: theorem-counter)

/// Definition environment, with an upright body.
#let (definition-counter, definition-box, definition, _show-definition) = _frame(
  "definition",
  counter: theorem-counter,
  render: _render-definition,
)

/// Assumption environment, with an upright body.
#let (assumption-counter, assumption-box, assumption, _show-assumption) = _frame(
  "assumption",
  counter: theorem-counter,
  render: _render-definition,
)

/// Axiom environment, with an upright body.
#let (axiom-counter, axiom-box, axiom, _show-axiom) = _frame(
  "axiom",
  counter: theorem-counter,
  render: _render-definition,
)

/// Example environment, with an upright body.
#let (example-counter, example-box, example, _show-example) = _frame(
  "example",
  counter: theorem-counter,
  render: _render-definition,
)

/// Remark environment, with an emphasized title and upright body.
#let (remark-counter, remark-box, remark, _show-remark) = _frame(
  "remark",
  counter: theorem-counter,
  render: _render-remark,
)

/// Note environment, with an emphasized title and upright body.
#let (note-counter, note-box, note, _show-note) = _frame("note", counter: theorem-counter, render: _render-remark)

/// Warning environment, with an emphasized title and upright body.
#let (warning-counter, warning-box, warning, _show-warning) = _frame(
  "warning",
  counter: theorem-counter,
  render: _render-remark,
)

/// Proof environment, ended by a QED symbol.
///
/// ```typ
/// #proof(of: [@thm:primes])[Suppose there are finitely many primes…]
/// ```
///
/// -> content
#let proof(
  /// What is being proved, appended to the title in parentheses (typically a reference).
  /// -> none | content
  of: none,
  /// The proof.
  /// -> content
  body,
) = {
  let title = theorion-i18n(theorion-i18n-map.proof)
  theorion.proof(title: if of == none { title } else [#title (#of)], body)
}

/// Applies the show rules of the theorem-like environments.
///
/// -> content
#let _theorems-setup(
  /// The resolved configuration.
  /// -> dictionary
  cfg,
  /// The content to apply the settings to.
  /// -> content
  body,
) = {
  show: _show-theorem
  show: _show-lemma
  show: _show-proposition
  show: _show-corollary
  show: _show-conjecture
  show: _show-definition
  show: _show-assumption
  show: _show-axiom
  show: _show-example
  show: _show-remark
  show: _show-note
  show: _show-warning

  // Number within sections, like figures and equations.
  (theorem-counter.set-inherited-levels)(cfg.levels.section)
  set-indent-mode(auto)

  body
}
