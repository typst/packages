#let conditional_outline(selector, title) = {
   context {
      let c
      if query(<backmatter-start>).len() > 0 {
        c = counter(selector).at(<backmatter-start>)
      } else {
        c = counter(selector).final()
      }
      if c.at(0) > 0 {          
          outline(
            title: title,
            target: selector,
          )
          pagebreak()
      }
  }
}