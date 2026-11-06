#import "i18n.typ"
#import "ref.typ": impromptu-label

/// Internal generic building block for "theorem style" environments.
///
/// This is not meant to be used directly.
///
/// -> content
#let _styled_environment(
  /// The environment kind which is displayed as prefix. -> content | str
  kind: none,
  /// The styling of the `prefix`. -> function
  prefix-style: strong,
  /// The numbering of the environment.
  ///
  /// - #auto: Use an automatic counter.
  /// - `none`: Don't number the theorem at all.
  /// - Everything else is displayed as is.
  ///
  /// -> auto | none | content | str
  numbering: auto,
  /// The name of the environment. -> content | str | none
  name: none,
  /// A label that you can reference or query. -> str | none
  label: none,
  /// The supplement of the environment which is used in outlines and references.
  ///
  /// When set to #auto, it uses the same value as `kind`.
  ///
  /// -> auto | content | str | function | none
  supplement: auto,
  /// Whether to reference the environment by name if possible.
  ///
  /// By default, environments are referenced by number if possible.
  ///
  /// -> bool
  reference-prefer-name: false,
  /// Whether the contents of the environment is emphasized. -> bool
  emphasized: false,
  /// The `fill` value of the environment box. -> none | color | gradient | tiling
  fill: none,
  /// The `stroke` value of the environment box. -> stroke
  stroke: none,
  /// The `inset` value of the environment box. -> length
  inset: 0em,
  /// The `outset` value of the environment box. -> length
  outset: 0.5em,
  /// The `radius` value of the environment box. -> length
  radius: 0em,
  /// The `above` value of the environment box. -> length
  above: 1.3em,
  /// The `below` value of the environment box. -> length
  below: 1.3em,
  /// The `width` value of the environment box. -> auto | relative | fraction
  width: 100%,
  /// The body of the environment. -> content
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
    [#prefix-style[#kind#numbering]#name#prefix-style[.]]
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

// FIXME: Bug in tidy:0.4.3, cannot handle multi-line curried functions like below.
// Temporarily join them into single line for generating docs.
// Remove this comment when upgrading to next tidy version.
// - Issue: https://github.com/Mc-Zen/tidy/issues/63
// - Fix: https://github.com/Mc-Zen/tidy/pull/65

/// Theorem environment.
///
/// *Example*
/// ```typst
/// #theorem(name: "Pythagoras")[$a^2 + b^2 = c^2$]
/// ```
/// -> content
#let theorem = _styled_environment.with(
  kind: context i18n.translate("Theorem"),
  emphasized: true,
)

/// Corollary environment, based on the `theorem` environment. -> content
#let corollary = theorem.with(kind: context i18n.translate("Corollary"))

/// Lemma environment, based on the `theorem` environment. -> content
#let lemma = theorem.with(kind: context i18n.translate("Lemma"))

/// Definition environment, based on the `theorem` environment. -> content
#let definition = _styled_environment.with(
  kind: context i18n.translate("Definition"),
)

/// Example environment, based on the `theorem` environment. -> content
#let example = _styled_environment.with(kind: context i18n.translate("Example"))

/// Proof environment.
///
/// *Example*
/// ```typst
/// #proof[Let $a=1$, then is $a+1 = 2$ immediate.]
/// ```
/// -> content
#let proof(
  /// The prefix that displayed at the beginning of the proof. -> content | str
  prefix: context i18n.translate("Proof"),
  /// The symbol that marks the end of the proof. -> content
  qed: $square$,
  /// The styling of the `prefix`. -> function
  prefix-style: emph,
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
  body,
) = {
  _styled_environment(
    kind: prefix,
    prefix-style: prefix-style,
    numbering: none,
    fill: fill,
    stroke: stroke,
    inset: inset,
    outset: outset,
    radius: radius,
    above: above,
    below: below,
    width: width,
  )[#body #h(1fr)\u{2060}#box[#h(1em)#qed]]
}
