#import "/core/util.typ": handle
#import "/core/reading/output.typ": outputs
#import "plain.typ"

// Make a string for a cell execution count, showing a space if missing
#let _count-string(count) = if count == none { return " " } else { str(count) }

// Add the In/Out annotation in the margin of code cell input/output
#let _in-out-num(prefix, count) = context {
  let txt = raw(prefix + "[" + _count-string(count) + "]:")
  place(top+left, dx: -1.2em - measure(txt).width, txt)
}

#let _handler-raw-cell(cell, ctx: none, ..args) = block(
  spacing: 1.5em,
  width: 100%,
  inset: 0.5em,
  fill: luma(240),
  handle(cell.source, mime: "source-code-generic", ctx: ctx, lang: ctx.raw-lang),
)

#let _handler-code-cell-input(cell, ctx: none, block-args: none, ..args) = block(
  above: 2em,
  below: if ctx.output and cell.outputs.len() > 0 { 0pt } else { 2em },
  width: 100%,
  inset: 0.5em,
  fill: luma(240),
  ..block-args,
  {
    _in-out-num("In ", cell.execution_count)
    handle(cell.source, mime: "source-code-generic", ctx: ctx, lang: ctx.lang)
  },
)

// Styled block for error items (error outputs or stderr streams)
#let _error-block = block.with(
  width: 100%,
  fill: red.lighten(90%),
  outset: 0.5em,
)

// Customized default handler for errors, rendering the traceback
#let _handler-error(data, ctx: none, ..args) = {
  let txt = data.traceback.join("\n")
  let rendered = handle(txt, mime: "text-console-block", ctx: ctx, ..args)
  _error-block(rendered)
}

#let _handler-stream-stderr(data, ctx: none, ..args) = {
  let value = handle(data, mime: "stream-generic", ctx: ctx, ..args)
  _error-block(value)
}

#let _handler-result(data, ctx: none, ..args) = block({
  _in-out-num("Out", ctx.cell.execution_count)
  handle(data, mime: "rich-output-generic", ctx: ctx, ..args)
})

#let _handler-code-cell-output(cell, ctx: none, ..args) = {
  let outs = outputs(cell, ..ctx.cfg)
  if outs.len() == 0 { return }
  block(
    above: if ctx.input { 0pt } else { 2em },
    below: 2em,
    width: 100%,
    inset: 0.5em,
    outs.join(),
  )
}

#let _placeholder-input-from-source(source, ctx: none, ..args) = {
  let cell = (
    source: source,
    execution_count: "?",
  )
  let block-args = (stroke: (dash: "dashed"))
  ctx.output = false
  return _handler-code-cell-input(cell, ctx: ctx, block-args: block-args)
}

#let theme = plain.theme + (
  stream-stderr: _handler-stream-stderr,
  error: _handler-error,
  result: _handler-result,
  raw-cell: _handler-raw-cell,
  code-cell-input: _handler-code-cell-input,
  code-cell-output: _handler-code-cell-output,
  placeholder-input-from-source: _placeholder-input-from-source,
)
