// We should not put these states in self,
// otherwise we cannot call footcite inside a context
// due to it being wrapped by `touying-fn-wrapper`.
#let footcited-keys = state("footcited-keys", ())
#let bib-is-hidden = state("bib-is-hidden", false)
#let footcite-once = state("footcite-once", true)


#let _footcite-label-prefix = "touying-greyc-footcite:"


/// Cite and show fullcite as a footnote.
/// See `std.cite` and `std.footnote` for clarifications of parameters.
///
/// -> content
#let footcite(
  key,
  cite-style: "apa",
  foot-style: auto,
  supplement: none,
  numbering: "1",
  label: auto,
) = context {
  let page = here().page()
  let footnote-label = if label != auto { label } else { _footcite-label-prefix + str(key) }
  if not footcite-once.get() {
    // only shown on the slide it is first mentioned
    footnote-label += "-" + str(page)
  }
  let already-cited = footcited-keys.get()
  let is-cited = footnote-label in already-cited
  if not is-cited {
    footcited-keys.update(old => {
      old.push(footnote-label)
      old
    })
  }
  cite(key, form: "normal", style: cite-style, supplement: supplement)
  if not is-cited {
    [#footnote(numbering: numbering)[
        #if bib-is-hidden.final() {
          cite(key, form: "normal", style: cite-style)
          h(0.5em)
        }
        #context cite(key, form: "full", style: foot-style, supplement: supplement)
      ]#std.label(footnote-label)]
  } else {
    ref(std.label(footnote-label))
  }
}
