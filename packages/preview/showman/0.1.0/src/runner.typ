/*
Inspiration: https://github.com/typst/packages/blob/main/packages/preview/cetz/0.1.0/manual.typ
*/

#let example-blocks = state("example-blocks", ())
#let label-counters = state("external-code-label-counters", (:))

#let config = (
  runnable-langs: ("example", ),
  showable-labels: (<example-output>, ),
  output-label: <example-output>,
  input-label: <example-input>,
)

#let bidirectional-grid(direction: auto, ..args) = {
  // More complex logic can determine auto layout in the future
  if direction == auto {
    direction = ltr
  }
  let n-args = args.pos().len()
  let grid-kwargs = (:)
  if direction in (ltr, rtl) {
    grid-kwargs = (columns: (auto,) * n-args, column-gutter: 1em)
  } else {
    grid-kwargs = (rows: n-args, row-gutter: 1em)
  }
  let pos = args.pos()
  if direction in (rtl, btt) {
    pos = pos.rev()
  }
  grid(..grid-kwargs, ..pos, ..args.named())
}

#let _fetch-result-from-cache(result-cache, index: -1) = {
  let out = result-cache.at(index, default: none)
  if out == none {
    [\<Not yet evaluated\>]
  } else {
    out
  }
}

#let external-code(
  raw-content,
  result-cache: (:),
  direction: auto,
  scope: (:),
  container: bidirectional-grid,
) = {
  let input-source = raw-content.text
  let lang = raw-content.at("lang", default: "default")
  [#metadata(input-source)#label(lang)]
  label-counters.update(old => {
    old.insert(lang, old.at(lang, default: -1) + 1)
    old
  })
  locate(loc => {
    let idx = label-counters.at(loc).at(lang)
    let fetched = _fetch-result-from-cache(result-cache.at(lang, default: ()), index: idx)
    let output = [#fetched#config.output-label]
    let input = [#raw-content#config.input-label]
    container(direction: direction, input, output)
  })
}

#let wilcard-import-string-from-modules(scope) = {
  let preamble = ()
  for key in scope.keys() {
    if type(scope.at(key)) == module {
      preamble.push("#import " + key + ": *")
    }
  }
  preamble.join("\n")
}

#let standalone-example(
  raw-content,
  direction: auto,
  eval-prefix: "",
  eval-suffix: "",
  unpack-modules: false,
  scope: (:),
  container: bidirectional-grid,
) = {
  let pieces = (eval-prefix, raw-content.text, eval-suffix)
  if unpack-modules {
    pieces.insert(0, wilcard-import-string-from-modules(scope))
  }
  let output = eval(pieces.join("\n"), mode: "markup", scope: scope)

  let grid-args = (box(width: 1fr)[#raw-content#config.input-label], )
  grid-args.push[
    #set text(font: "Linux Libertine")
    #output#config.output-label
  ]
  container(direction: direction, ..grid-args)
}


#let global-example(raw-content, eval-prefix: "", eval-suffix: "", ..args) = {
  locate(loc => {
    let all-blocks = ()
    all-blocks.push("#let output = (body) => {}")
    for block in example-blocks.at(loc) {
      all-blocks.push(eval-prefix)
      all-blocks.push(block)
      all-blocks.push(eval-suffix)
    }
    all-blocks.push("#let output = (content) => { content }")
    all-blocks.push(eval-prefix)
    standalone-example(
      raw-content, eval-prefix: all-blocks.join("\n"), eval-suffix: eval-suffix, ..args
    )
  })
  example-blocks.update(old => {
    old.push(raw-content.text)
    old
  })
}

#let raw-with-eval(
  it, global: auto, langs: config.runnable-langs, block: true, eval-kwargs: (:)
) = {
  if type(langs) != array {
    langs = (langs,)
  }
  for (ii, lang) in langs.enumerate() {
    if type(lang) == content and lang.has("text") {
      langs.at(ii) = regex(lang.text)
    }
  }
  let cur-lang = it.at("lang", default: none)
  let needs-run = block == it.at("block", default: false) and (
    langs == auto or langs.any(el => cur-lang.match(el) != none)
  )
  if not needs-run {
    it
    return
  }

  [#metadata(cur-lang)<runnable-lang>]

  if global == auto {
    global = "global" in cur-lang
  }
  if cur-lang != "typ" {
    // Raw style will be double applied which shrinks text, so preemptively undo the
    // shrinking
    set text(size: 1.25em)
    it = raw(it.text, lang: "typ", block: it.block)
  }

  if global {
    global-example(it, ..eval-kwargs)
  } else {
    standalone-example(it, ..eval-kwargs)
  }
}
