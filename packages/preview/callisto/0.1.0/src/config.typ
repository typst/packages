#import "reading.typ"
#import "templates.typ"
#import "rendering.typ"

#let _doc-template(template) = {
  templates.doc-templates.at(template, default: it => it)
}

#let config(
  // Cell selection args
  nb: none,
  count: "index",
  name-path: auto,
  cell-type: "all",
  keep: "all",
  // Other args
  lang: auto,
  raw-lang: none,
  result: "value",
  stream: "all",
  format: auto,
  handlers: auto,
  ignore-wrong-format: false,
  template: "notebook",
  // Special args (should not override args set in pre-configured functions)
  output-type: "all",
  input: true,
  output: true,
) = {
  let cell-args = (
    nb: nb,
    count: count,
    name-path: name-path,
    cell-type: cell-type,
    keep: keep,
  )
  let input-args = (
    lang: lang,
    raw-lang: none,
    result: result,
  )
  let output-args = (
    stream: stream,
    format: format,
    handlers: handlers,
    ignore-wrong-format: ignore-wrong-format,
    result: result,
  )
  let all-output-args = (
    ..output-args,
    output-type: output-type,
  )
  let render-args = (
    ..input-args,
    ..output-args,
    template: template,
  )
  let all-render-args = (
    ..render-args,
    output-type: output-type,
    input: input,
    output: output,
  )
  return (
    cells:        reading.cells       .with(..cell-args),
    cell:         reading.cell        .with(..cell-args),
    outputs:      reading.outputs     .with(..cell-args, ..all-output-args),
    output:       reading.output      .with(..cell-args, ..all-output-args),
    displays:     reading.displays    .with(..cell-args, ..output-args),
    display:      reading.display     .with(..cell-args, ..output-args),
    results:      reading.results     .with(..cell-args, ..output-args),
    result:       reading.result      .with(..cell-args, ..output-args),
    stream-items: reading.stream-items.with(..cell-args, ..output-args),
    stream-item:  reading.stream-item .with(..cell-args, ..output-args),
    errors:       reading.errors      .with(..cell-args, ..output-args),
    error:        reading.error       .with(..cell-args, ..output-args),
    streams:      reading.streams     .with(..cell-args, ..output-args),
    stream:       reading.stream      .with(..cell-args, ..output-args),
    sources:      reading.sources     .with(..cell-args, ..input-args),
    source:       reading.source      .with(..cell-args, ..input-args),
    render:       rendering.render  .with(..cell-args, ..all-render-args),
    Cell:         rendering.Cell    .with(..cell-args, ..all-render-args),
    In:           rendering.In      .with(..cell-args, ..render-args),
    Out:          rendering.Out     .with(..cell-args, ..render-args),
    template:     _doc-template(template),
  )
}
