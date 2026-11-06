#let tromp-recursion(
  expression,
  abstractions,
  old-x,
  old-y,
  use-labels,
  is-base-abstraction: true,
  mode
) = {
  // list of (x1, y1, x2, y2, style)
  let lines
  // labels of the abstractions
  let labels
  // (x-min, x-max) of each abstraction in scope (without the nubs)
  let abstraction-bounds
  // together, x and y specify the bottom-right corner that
  // applications must stretch over.
  let x = old-x
  let y = old-y

  if expression.type == "value" {
    labels = () // so we don't return labels: none
    let relevant-abstractions = abstractions.enumerate().filter(
      ((_, var)) => var == expression.name
    ).map(((index, _)) => index)
    if relevant-abstractions.len() == 0 {
      panic("variable " + expression.name + " is not in the expression")
    }
    // choose the last abstraction, since one could theoretically make them with duplicate names.
    let abstraction = relevant-abstractions.at(-1)
    // all abstractions in scope reach right
    abstraction-bounds = abstractions.map(
      _ => (x, x)
    )

    let style = expression.at("style", default: auto)
    if mode == "pixel" {
      lines = ()
      for other-abstraction in range(abstraction, abstractions.len() - 1) {
        lines.push((x, other-abstraction + 1, x, other-abstraction, style))
      }
      lines.push((x, y - 0.5, x, y, style))
    } else {
      lines = ((x, abstraction, x, y, style),)
    }
    // +1 so the next application will bend around this
    x += 1
  }

  else if expression.type == "abstraction" {
    let new-abstractions = abstractions
    new-abstractions.push(expression.param)
    let abstraction-y = y // height of abstraction line
    y += 1 // new abstraction was added, so future applications must bend over it.
    let body-result = tromp-recursion(expression.body, new-abstractions, x, y, use-labels, is-base-abstraction: false, mode)
    lines = body-result.lines
    labels = body-result.labels
    let new-abstraction-bounds = body-result.abstraction-bounds

    // don't return the just-added abstraction in abstraction-bounds
    abstraction-bounds = new-abstraction-bounds
    // mutate by popping to remove last item
    let (x-min, x-max) = abstraction-bounds.pop()
    let style = expression.at("style", default: auto)
    lines.push((x-min - 0.25, abstraction-y, x-max + 0.25, abstraction-y, style))
    x = body-result.x
    y = body-result.y
    let label = expression.at("label", default: auto)
    if use-labels {
      labels.push((x-max + 0.3, abstraction-y, expression.param, label))
      if is-base-abstraction and mode == "pixel" {
        x += 0.25
      }
    }
  }

  else if expression.type == "application" {
    let application-x1 = x
    let fn-result = tromp-recursion(expression.fn, abstractions, x, y, use-labels, mode)
    lines = fn-result.lines
    labels = fn-result.labels
    abstraction-bounds = fn-result.abstraction-bounds
    x = fn-result.x
    let fn-y = fn-result.y
    let application-x2 = x
    // use the old y because the parameter doesn't have to stretch over the function in the y-direction.
    let param-result = tromp-recursion(expression.param, abstractions, x, y, use-labels, mode)
    lines += param-result.lines
    labels += param-result.labels
    // expand abstractions to be widest of both
    abstraction-bounds = abstraction-bounds.zip(param-result.abstraction-bounds).map(
      (((x1-min, x1-max), (x2-min, x2-max))) => (calc.min(x1-min, x2-min), calc.max(x2-min, x2-max))
    )
    x = param-result.x
    let param-y = param-result.y
    y = calc.max(fn-y, param-y)
    let style = expression.at("style", default: auto)
    if mode == "pixel" {
      lines.push((application-x1 + 0.25, y, application-x2 - 0.25, y, style))
      // line to parameter
      if param-y != y {
        lines.push((application-x2, param-y + 0.5, application-x2, y, style))
      }
      y += 1
      // line to function
      if fn-y != y {
        lines.push((application-x1, fn-y + 0.5, application-x1, y, style))
      }
    } else {
      lines.push((application-x1, y, application-x2, y, style))
      // line to parameter
      lines.push((application-x2, param-y, application-x2, y, style))
      y += 1
      // line to function
      lines.push((application-x1, fn-y, application-x1, y, style))
    }
  }

  return (
    lines: lines,
    labels: labels,
    abstraction-bounds: abstraction-bounds,
    x: x,
    y: y,
  )
}
