#let template-notes(content) = {
  show footnote: it => {
    if target() == "html" {
      let number = counter(footnote).display(it.numbering)
      let fn-id = "fn-" + number
      let ref-id = "fnref-" + number

      // Numeric references in the main text
      html.sup(class: "footnote-ref", html.a(
        class: "footnote-ref-link",
        href: "#" + fn-id,
        id: ref-id,
        number,
      ))

      // Footnote content in the margin
      html.span(
        class: "marginnote",
        id: fn-id,
        html.sup(html.a(class: "footnote-ref-link", href: "#" + ref-id, number)) + [ ] + it.body,
      )
    }
  }
  content
}

