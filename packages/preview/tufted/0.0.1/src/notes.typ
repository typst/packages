#let template-notes(content) = {
  show footnote: it => {
    if target() == "html" {
      let number = counter(footnote).display(it.numbering)
      html.sup(class: "footnote-ref", number)
      html.span(class: "marginnote", super(number) + [ ] + it.body)
    }
  }
  content
}

