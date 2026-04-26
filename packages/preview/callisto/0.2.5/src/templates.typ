#import "reading.typ": *

#let _count-string(count) = if count == none { return " " } else { str(count) }

#let _in-out-num(prefix, count) = context {
  let txt = raw(prefix + "[" + _count-string(count) + "]:")
  place(top+left, dx: -1.2em - measure(txt).width, txt)
}

#let plain-raw(cell, ..args) = source(cell)
#let plain-markdown(cell, handlers: auto, ..args) = {
  block(
    width: 100%,
    spacing: 1em,
    read-mime(
      source(cell).text,
      format: "text/markdown",
      handlers: handlers,
    ),
  )
}
#let plain-input(cell, input-args: none, ..args) = source(cell, ..input-args)
#let plain-output(cell, output-args: none, ..args) = {
  outputs(cell, ..output-args, result: "value").join()
}

#let notebook-raw = plain-raw
#let notebook-markdown = plain-markdown
#let notebook-input(cell, output: true, input-args: none, ..args) = {
  let src = source(cell, ..input-args)
  block(
    above: 2em,
    below: if output { 0pt } else { 2em },
    width: 100%,
    inset: 0.5em,
    fill: luma(240),
    {
      _in-out-num("In ", cell.execution_count)
      src
    },
  )
}
#let normal-block = block.with(width: 100%)
#let error-block = normal-block.with(
  fill: red.lighten(90%),
  outset: 0.5em,
)

// Wrap some outputs in a raw block
#let _notebook-output-value(out) = {
  if out.type == "error" {
    return raw(block: true, lang: "txt", out.traceback.join("\n"))
  }
  if out.type == "stream" or out.format == "text/plain" {
    return raw(block: true, lang: "txt", out.value)
  }
  return out.value
}

#let notebook-output(cell, output-args: none, ..args) = {
  let outs = outputs(cell, ..output-args, result: "dict")
  if outs.len() == 0 { return }
  block(
    above: 0pt,
    below: 2em,
    width: 100%,
    inset: 0.5em,
    {
      for out in outs {
        let value = _notebook-output-value(out)
        if out.type == "execute_result" { 
          block({
            _in-out-num("Out", cell.execution_count)
            value
          })
        } else if out.type == "error" {
          error-block(value)
        } else if out.type == "stream" and out.name == "stderr" {
          error-block(value)
        } else if out.type == "stream" {
          normal-block(value)
        } else {
          value
        }
      }
    },
  )
}

// Templates

#let plain-cell = (
  raw: plain-raw,
  markdown: plain-markdown,
  input: plain-input,
  output: plain-output,
)
#let notebook-cell = (
  raw: notebook-raw,
  markdown: notebook-markdown,
  input: notebook-input,
  output: notebook-output,
)

// Dict of default cell templates
#let cell-templates = (
  plain: plain-cell,
  notebook: notebook-cell,
)
