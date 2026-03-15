#let template-math(content) = {
  set math.equation(numbering: "(1)")

  show math.equation.where(block: false): it => {
    if target() == "html" {
      html.span(role: "math", html.frame(it))
    } else {
      it
    }
  }

  show math.equation.where(block: true): it => {
    if target() == "html" {
      html.figure(role: "math", html.frame(it))
    } else {
      it
    }
  }

  content
}
