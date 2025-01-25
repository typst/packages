/*
Inspiration: https://github.com/typst/packages/blob/main/packages/preview/cetz/0.1.0/manual.typ
*/

#import "runner.typ": raw-with-eval, config

#let filled-container(inline: false, ..args) = {
  let (container, unit) = if inline {
    (box.with(baseline: 0.35em), 0.35em)
  } else {
    (block.with(breakable: false), 0.5em)
  }
  container(fill: rgb("#ddd6"), inset: unit, radius: unit, ..args)
}

#let _add-raw-line-numbers(it) = {
  box(
    grid(columns: 2, column-gutter: 0.5em)[
      #context {
        let reserved = measure(text[#it.count]).width
        box(text(fill: gray)[#it.number], width: reserved)
      }
    ][#it],
  )
}

#let format-raw(it, line-numbers: false, ..background-kwargs) = {
  show raw.line: it => if line-numbers {
    _add-raw-line-numbers(it)
  } else {
    it
  }
  filled-container(it, ..background-kwargs)
}

#let show-only-labels(
  body,
  labels: (),
  template: none,
  use-box: true,
  page-size: (width: auto, height: auto),
) = {
  if type(labels) == label {
    labels = (labels,)
  }
  if labels.len() == 0 {
    return
  }
  let (first, ..rest) = labels
  let to-search = rest.fold(first, selector.or)

  if template == none {
    template = it => it
  }
  set page(..page-size, margin: 0pt)

  if use-box {
    box(width: 0pt, height: 0pt, clip: true, body)
  } else {
    hide(body)
  }

  context {
    let outputs = query(to-search)
    for output in outputs {
      pagebreak(weak: true)
      {
        show: template
        block(output, above: 0pt, below: 0pt, breakable: false)
      }
    }
  }
}

#let _content-printer(typst-file, ..updated-config) = {
  let __default-config = config
  let showman-config = (:)
  import typst-file: *
  // If the file defines its own `showman-config`, use those values instead.
  // This will happen automatically through the wildcard import

  let showman-config = __default-config + showman-config + updated-config.named()

  let show-lbls-kwargs = (:)
  for key in ("template", "page-size") {
    if key in showman-config {
      show-lbls-kwargs.insert(key, showman-config.at(key))
    }
  }

  show: show-only-labels.with(
    labels: showman-config.showable-labels,
    ..show-lbls-kwargs,
    use-box: false,
  )

  show raw: raw-with-eval.with(
    langs: showman-config.runnable-langs,
    eval-kwargs: showman-config.at("eval-kwargs", default: (:)),
  )
  include (typst-file)
}

#let template(
  body,
  theme: "light",
  raw-style: (block: (:), inline: (:)),
  runnable-langs: ("example",),
  ..runnable-kwargs,
) = {
  // Formatting inline raw code
  let inline-style = raw-style.remove("inline", default: (:))
  let block-style = raw-style.remove("block", default: (:))


  show raw: it => {
    let inline = not it.at("block", default: false)
    let use-kwargs = if inline {
      inline-style + raw-style
    } else {
      (width: 100%, ..raw-style, ..block-style)
    }
    format-raw(inline: inline, ..use-kwargs, it)
  }
  show raw: raw-with-eval.with(langs: runnable-langs, ..runnable-kwargs)
  show config.output-label: format-raw.with(..block-style)

  set text(font: "Libertinus Serif")
  // Add variables here to avoid triggering error in Pandoc 3.1.10
  let _ = ""
  if theme == "dark" {
    set text(fill: white)
    set page(fill: black)
    body
  } else {
    body
  }
}
