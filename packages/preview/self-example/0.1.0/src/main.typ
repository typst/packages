
#let defaultRaw(code) = {
  code
}
#let defaultEval(code) = {
  code
}
#let mergeColumn(raw, eval) = {
  grid(columns:(1fr,1fr),gutter:10pt)[#raw][#eval]
}
#let mergeRow(raw, eval) = {
  raw
  eval
}
#let coloredMerge(raw, eval) = {
  import "@preview/gentle-clues:1.1.0": *
  grid(columns:(1fr,1fr),gutter:10pt)[#code(raw)][#example(eval)]
  
}
#let defaultMerge = mergeColumn;
#let getExamplePair(code) = {
  (raw(code, block: true, lang: "typst"), eval(code, mode: "markup"))
}
#let getExampleBase(code, raw_handler: defaultRaw, eval_handler: defaultEval) = {
  let result = getExamplePair(code);
  (raw_handler(result.at(0)), eval_handler(result.at(1)))
}
#let getExample(code, raw_handler: defaultRaw, eval_handler:defaultEval, merge_handler: defaultMerge) = {
  let result = getExampleBase(code, raw_handler:raw_handler, eval_handler:eval_handler);
  merge_handler(result.at(0), result.at(1))
}

