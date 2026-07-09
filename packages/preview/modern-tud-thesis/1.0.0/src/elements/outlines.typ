#let conditional_outline(selector, title) = {
   context {
      let c
      if query(<note>).len() > 0 {
        c = counter(selector).at(<backmatter-start>)
      } else {
        c = counter(selector).final()
      }
      if c.at(0) > 0 {
          show outline.entry: set text(weight: "regular")
          outline(
            title: heading(title, outlined: false),
            target: selector,
          )
          pagebreak()
      }
  }
}