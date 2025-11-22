#let expr-to-str(expr) = {
  if expr.type == "value" {
    return expr.name
  } else if expr.type == "application" {
    let left = if expr.fn.type == "abstraction" {
      "(" + expr-to-str(expr.fn) + ")"
    } else {
      expr-to-str(expr.fn)
    }
    let right = if expr.param.type in ("application", "abstraction") {
      "(" + expr-to-str(expr.param) + ")"
    } else {
      expr-to-str(expr.param)
    }
    
    return left + " " + right
  } else if expr.type == "abstraction" {
    return "λ" + expr.param + "." + expr-to-str(expr.body)
  }
}

#let display-expr(
  expr,
  highlight,
  implicit-parenthesis,
) = {
  let display(expr) = display-expr(expr, highlight, implicit-parenthesis)
  let par(content, ..fill) = text(..fill)[(] + content + text(..fill)[)]

  if expr.type == "value" {
    if "index" in expr {
      highlight(expr.name, expr.index)
    } else {
      expr.name
    }
  } else if expr.type == "application" {
    if implicit-parenthesis {
      par(fill: gray)[#display(expr.fn) #display(expr.param)]
    } else {
      let left = if expr.fn.type == "abstraction" {
        par(display(expr.fn))
      } else {
        display(expr.fn)
      }

      let right = if expr.param.type in ("application", "abstraction") {
        par(display(expr.param))
      } else {
        display(expr.param)
      }

      [#left #right]
    }
    
  } else if expr.type == "abstraction" {
    let content = [λ] + highlight(expr.param, expr.index) + [.] + display(expr.body)

    if implicit-parenthesis {
      par(content, fill: gray)
    } else {
      content
    }
  }
}
