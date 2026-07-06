#import "utils.typ": is-html, html-style

#let html-align-trailing = state("eggs-html-align-trailing")


/// Insert content as non-breaking, right-aligned,
/// and showing on the next line if it does not fit.
///
/// - body (content): The contents to show.
/// *Required*
///
/// - gap (length): Minimum space between the main line and the trailing content
/// *Default*: 1.5em
///
/// -> content
#let trailing(body, gap: 1.5em) = context if is-html() {
    context {
      html.elem("span",
        attrs: (
          class: "eggs-trailing",
          ..if html-align-trailing.get() {(
            style: html-style(
              float: "right"
            )
          )}
        ),
        body
      )    
    }
  } else {
    box()
    h(1fr)
    sym.wj
    box({h(gap); body})
  }

