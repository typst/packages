#import "layout.typ": margin-note

#let template-figures(content) = {
  // Redefine figure caption to use marginnote
  show figure.caption: it => html.span(
    class: "marginnote",
    it.supplement + sym.space.nobreak + it.counter.display() + it.separator + it.body,
  )

  // Redefine figure itself
  show figure: it => if target() == "html" {
    html.figure({
      it.caption
      it.body
    })
  }

  content
}
