#import "utils.typ": append-qed, error, global-name

#let theorems = state(global-name("theorems"), (:))

/// Initialise the package.
///
/// Add ```typ #show: trivial.init``` to the start of the document.
/// -> content
#let init(
  /// The document.
  /// -> content
  doc,
) = context (
  theorems
    .final()
    .pairs()
    .fold(doc, (acc, (kind, style)) => {
      // Undo show-set rules on figures.
      show figure.where(kind: kind): set align(start)
      show figure.where(kind: kind): set block(breakable: true)

      // Style the theorem environment.
      show figure.where(kind: kind): style

      acc
    })
)

/// Create and display a theorem.
///
/// One should define functions so that the first three arguments pre-applied,
/// e.g.
/// ```typ
/// #let numbered = trivial.theorem.with(
///   "numbered",
///   trivial.styles.theorem.default,
///   numbering: "1",
/// )
/// #let theorem = numbered.with([Theorem])
/// #let lemma = numbered.with([Lemma])
/// ```
/// -> content
#let theorem(
  /// An identifier for the theorem.
  ///
  /// This is used as the wrapper figure's #figure-kind, so theorems with the
  /// same kind share the same counter.
  /// -> str
  kind,
  /// How to format the theorem.
  ///
  /// See @theorem-style for more information.
  /// -> function
  style,
  /// The name of the theorem.
  /// -> content
  name,
  /// How to number the theorem. Accepts a #numbering-type.
  /// -> none | str | function
  numbering: none,
  /// The optional title and body.
  ///
  /// Either one or two arguments are expected.
  /// -> content
  ..args,
) = {
  if kind == none {
    error("an identifier kind must be provided")
  } else if style == none {
    error("a style function must be provided")
  } else if name == none {
    error("a name must be provided")
  }

  let args = args.pos()
  let (title, body) = if args.len() == 1 {
    (none, args.first())
  } else if args.len() == 2 {
    args.slice(0, 2)
  } else {
    error("expected either one or two arguments")
  }

  let update = theorems.update(x => {
    if not kind in x { x.insert(kind, style) }
    x
  })
  return figure(
    update + body,
    caption: title,
    kind: kind,
    supplement: name,
    numbering: numbering,
  )
}

/// Type signature of the function expected in @theorem.style.
/// -> content
#let theorem-style(
  /// The name of the environment is stored in the figure's #figure-supplement
  /// and the optional title in its #figure-caption.
  /// -> figure
  it,
) = {}

/// Create and display a proof.
///
/// One should define a new function with the first three arguments
/// pre-applied, e.g.
/// ```typ
/// #let proof = trivial.proof.with(
///   [Proof],
///   trivial.styles.proof.default,
///   qed: $qed$,
/// )
/// ```
/// -> content
#let proof(
  /// The default title to use.
  /// -> content
  title,
  /// How to format the proof.
  ///
  /// See @proof-style for more information.
  /// -> function
  style,
  /// The QED symbol to use.
  /// -> none | content
  qed: none,
  /// The optional title and body.
  ///
  /// Either one or two arguments are expected.
  /// -> content
  ..args,
) = {
  if title == none {
    error("a default title must be provided")
  } else if style == none {
    error("a style function must be provided")
  }

  let args = args.pos()
  let (title, body) = if args.len() == 1 {
    (title, args.first())
  } else if args.len() == 2 {
    args.slice(0, 2)
  } else {
    error("expected either one or two arguments")
  }

  let body = append-qed(body, qed)
  return style(title, body)
}

/// Type signature of the function expected in @proof.style.
/// -> content
#let proof-style(
  /// -> content
  title,
  /// -> content
  body,
) = {}
