/// Creates a Tromp diagram. -> content
#let tromp(
  /// A #link("https://typst.app/universe/package/lambdabus/", [Lambdabus expression]) or result of #typc("expression()"). -> str | dictionary
  expression,
  /// Either the string #typc("\"pixel\"") or #typc("\"line\""). -> str
  mode: "pixel",
  /// A float representing the scale from the default pixel size. -> float
  scale: 1.0,
  /// If using the #typc("\"pixel\"") mode, must be a color. If using the #typc("\"line\"") mode, must be a stroke or a #cetz-link("basics/styling", [CeTZ style]). -> color | stroke | dictionary
  style: black,
  /// #typc("auto") or a function that takes in a parameter name string and returns content.
  ///
  /// Defaults to #typc("param => $italic(param)$"). -> content | auto | none
  labels: none,
) = {
  import "@preview/cetz:0.4.2": canvas, draw
  import "tromp.typ": tromp-recursion
  import "@preview/lambdabus:0.1.0" as lmd
  let parsed-expression = expression
  if type(parsed-expression) == str {
    parsed-expression = lmd.parse(parsed-expression)
  }
  if mode not in ("pixel", "line") {
    panic("unknown mode '" + mode + "'")
  }
  let result = tromp-recursion(parsed-expression, (), 0, 0, labels != none, mode)
  return canvas(length: 1cm * scale, {

    import draw: rect, line, content
    for (x1, y1, x2, y2, line-style) in result.lines {
      if line-style == auto {
        line-style = style
      }
      if mode == "pixel" {
        rect((x1, -0.5 * y1), (x2 + 0.25, -0.5 * y2 - 0.25), stroke: none, fill: line-style)
      } else if mode == "line" {
        line((x1, -0.5 * y1), (x2, -0.5 * y2), stroke: line-style)
      }
    }

    for (x, y, param, label) in result.labels {
      let label-content
      if label == auto {
        if labels == auto {
          label-content = $italic(param)$
        } else if type(labels) == function {
          label-content = labels(param)
        }
      } else if type(label) == function {
        label-content = label(param)
      } else {
        label-content = label
      }
      if mode == "pixel" {
        content((x + 0.3, -0.5 * y - 0.225), text(label-content, 11pt * scale), anchor: "base-west")
      } else if mode == "line" {
        content((x + 0.125, -0.5 * y), text(label-content, 11pt * scale), anchor: "mid-west")
      }
    }
  })
}

/// Adds additional metadata to an expression made with #typc("value()"), #typc("abstraction()"), or #typc("application()") so that Lambdabus can do math on it.
#let expression(
  /// The lambda calculus expression constructed through #typc("value()"), #typc("abstraction()"), or #typc("application()"). -> dictionary
  expression,
) = {
  import "@preview/lambdabus:0.1.0": lambda
  return lambda.tag(expression)
}

/// Creates a stylable value.
#let value(
  /// The string corresponding to the abstraction parameter. -> str
  parameter,
  /// If using the #typc("\"pixel\"") mode, must be #typc("auto") or a color. If using the #typc("\"line\"") mode, must be #typc("auto"), a stroke, or a #cetz-link("basics/styling", [CeTZ style]). If auto, defaults to the whole diagram's default style. -> auto | color | stroke | dictionary
  style: auto,
) = {
  return (
    type: "value",
    name: parameter,
    style: style,
  )
}

/// Creates a stylable abstraction.
#let abstraction(
  /// The string corresponding to the parameter of this abstraction. -> str
  parameter,
  /// An expression constructed through #typc("value()"), #typc("abstraction()"), and #typc("application()") or a Lambdabus expression. -> str | dictionary
  body,
  /// If using the #typc("\"pixel\"") mode, must be #typc("auto") or a color. If using the #typc("\"line\"") mode, must be #typc("auto"), a stroke, or a #cetz-link("basics/styling", [CeTZ style]). If auto, defaults to the whole diagram's default style. -> auto | color | stroke | dictionary
  style: auto,
  /// #typc("auto"), #typc("none"), content, or a function that takes the parameter as a string and returns content. If #typc("auto"), defaults to the whole diagram's label style. -> auto | none | content | function
  label: auto,
) = {
  import "@preview/lambdabus:0.1.0": parsing
  let parsed-body = body
  if type(parsed-body) == str {
    parsed-body = parsing.parse-expr(parsed-body.codepoints())
  }
  return (
    type: "abstraction",
    param: parameter,
    body: parsed-body,
    style: style,
    label: label,
  )
}

/// Creates a stylable application.
#let application(
  /// An expression constructed through #typc("value()"), #typc("abstraction()"), and #typc("application()") or a Lambdabus expression. -> str | dictionary
  function,
  /// An expression constructed through #typc("value()"), #typc("abstraction()"), and #typc("application()") or a Lambdabus expression. -> str | dictionary
  parameter,
  /// If using the #typc("\"pixel\"") mode, must be #typc("auto") or a color. If using the #typc("\"line\"") mode, must be #typc("auto"), a stroke, or a #cetz-link("basics/styling", [CeTZ style]). If auto, defaults to the whole diagram's default style. -> auto | color | stroke | dictionary
  style: auto,
) = {
  import "@preview/lambdabus:0.1.0": parsing
  let parsed-function = function
  if type(parsed-function) == str {
    parsed-function = parsing.parse-expr(parsed-function.codepoints())
  }
  let parsed-parameter = parameter
  if type(parsed-parameter) == str {
    parsed-parameter = parsing.parse-expr(parsed-parameter.codepoints())
  }
  return (
    type: "application",
    fn: parsed-function,
    param: parsed-parameter,
    style: style,
  )
}
