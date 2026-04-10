#import "i18n.typ"
#import "labelling.typ": impromptu-label

/// Theorem environment.
///
/// *Example*
/// ```typst
/// #theorem(name: "Pythagoras")[$a^2 + b^2 = c^2$]
/// ```
/// -> content
#let theorem(
  /// The theorem kind which is displayed as prefix. -> content | str
  kind: context i18n.translate("Theorem"),
  /// The numbering of the theorem.
  ///
  /// - #auto: Use an automatic counter.
  /// - `none`: Don't number the theorem at all.
  /// - Everything else is displayed as is.
  ///
  /// -> auto | none | content | str
  numbering: auto,
  /// The name of the theorem. -> content | str | none
  name: none,
  /// A label that you can reference or query. -> str | none
  label: none,
  /// The supplement of the theorem which is used in outlines and references.
  ///
  /// When set to #auto, it uses the same value as `kind`.
  ///
  /// -> auto | content | str | function | none
  supplement: auto,
  /// Whether to reference the theorem by name if possible.
  ///
  /// By default, theorems are referenced by number if possible.
  ///
  /// -> bool
  reference-prefer-name: false,
  /// Whether the contents of the theorem is emphasized. -> bool
  emphasized: true,
  /// The `fill` value of the theorem box. -> none | color | gradient | tiling
  fill: none,
  /// The `stroke` value of the theorem box. -> stroke
  stroke: none,
  /// The `inset` value of the theorem box. -> length
  inset: 0em,
  /// The `outset` value of the theorem box. -> length
  outset: 0.5em,
  /// The `radius` value of the theorem box. -> length
  radius: 0em,
  /// The `above` value of the theorem box. -> length
  above: 1.3em,
  /// The `below` value of the theorem box. -> length
  below: 1.3em,
  /// The `width` value of the theorem box. -> auto | relative | fraction
  width: 100%,
  /// The body of the theorem. -> content
  content,
) = {
  let theorem-count = counter("sheetstorm-theorem-count")

  state("sheetstorm-theorem-id").update(
    if reference-prefer-name {
      if name != none ["#name"] else { numbering }
    } else {
      if numbering != none { numbering } else ["#name"]
    },
  )

  let auto-numbering = (numbering == auto)
  if auto-numbering {
    numbering = context theorem-count.get().first()
  }

  let prefix = {
    let numbering = if numbering != none [ #numbering]
    let name = if name != none [ (#name)]
    [*#kind#numbering*#name*.*]
  }

  if emphasized { content = emph(content) }

  block(
    fill: fill,
    stroke: stroke,
    inset: inset,
    outset: outset,
    radius: radius,
    above: above,
    below: below,
    width: width,
    {
      if label != none {
        if supplement == auto { supplement = kind }
        impromptu-label(
          kind: "sheetstorm-theorem-label",
          supplement: supplement,
          label,
        )
      }
      [#prefix #content]
    },
  )

  if auto-numbering {
    theorem-count.step()
  }
}

/// Corollary environment, based on the `theorem` environment.
#let corollary = theorem.with(kind: context i18n.translate("Corollary"))

/// Lemma environment, based on the `theorem` environment.
#let lemma = theorem.with(kind: context i18n.translate("Lemma"))

/// Proof environment.
///
/// *Example*
/// ```typst
/// #proof[Let $a=1$, then is $a+1 = 2$ immediate.]
/// ```
/// -> content
#let proof(
  /// The symbol that marks the end of the proof. -> content
  qed: $square$,
  /// The prefix that displayed at the beginning of the proof. -> content | str
  prefix: context i18n.translate("Proof"),
  /// The styling of the `prefix`. -> function
  prefix-style: p => [_#p._],
  /// The `fill` value of the proof box. -> none | color | gradient | tiling
  fill: none,
  /// The `stroke` value of the proof box. -> stroke
  stroke: none,
  /// The `inset` value of the proof box. -> length
  inset: 0em,
  /// The `outset` value of the proof box. -> length
  outset: 0.5em,
  /// The `radius` value of the proof box. -> length
  radius: 0em,
  /// The `above` value of the proof box. -> length
  above: 1em,
  /// The `below` value of the proof box. -> length
  below: 1em,
  /// The `width` value of the proof box. -> auto | relative | fraction
  width: 100%,
  /// The body of the proof. -> content
  content,
) = {
  let prefix = prefix-style(prefix)
  block(
    fill: fill,
    stroke: stroke,
    inset: inset,
    outset: outset,
    radius: radius,
    above: above,
    below: below,
    width: width,
    [#prefix #content #h(1fr)\u{2060}#box[#h(1em)#qed]],
  )
}

