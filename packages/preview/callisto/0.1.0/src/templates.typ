#import "reading.typ": *

#let _count-string(count) = if count == none { return " " } else { str(count) }

#let _in-out-num(prefix, count) = context {
  let txt = raw(prefix + "[" + _count-string(count) + "]:")
  place(top+left, dx: -1.2em - measure(txt).width, txt)
}

#let plain-raw(cell, ..args) = source(cell)
#let plain-markdown(cell, handlers: default-handlers, ..args) = {
  block(
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
#let error-block = block.with(
  fill: red.lighten(90%),
  outset: 0.5em,
  width: 100%,
)
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
        if out.type == "execute_result" { 
          block({
            _in-out-num("Out", cell.execution_count)
            out.value
          })
        } else if out.type == "error" {
            error-block(out.traceback.join("\n"))
        } else if out.type == "stream" and out.name == "stderr" {
            error-block(out.value)
        } else {
          out.value
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

#let plain-doc(it) = {
  show raw.where(block: true): set block(
    inset: (left: 1.2em, y: 1em),
    stroke: (left: 3pt+luma(96%)),
  )
  it
}

#let notebook-doc(it) = it

// Dict of default doc templates
#let doc-templates = (
  plain: plain-doc,
  notebook: notebook-doc,
)
