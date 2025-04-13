#import "abbreviations.typ"

// ╭─────────────────────╮
// │ Interlinear glosses │
// ╰─────────────────────╯

#let build-gloss(item-spacing, formatters, gloss-line-lists) = {
    assert(gloss-line-lists.len() > 0, message: "Gloss line lists cannot be empty")

    let len = gloss-line-lists.at(0).len()

    for line in gloss-line-lists {
        assert(line.len() == len)
    }

    assert(formatters.len() == gloss-line-lists.len(), message: "The number of formatters and the number of gloss line lists should be equal")

    let make-item-box(..args) = {
        box(stack(dir: ttb, spacing: 0.5em, ..args))
    }

    for item-index in range(0, len) {
        let args = ()
        for (line-idx, formatter) in formatters.enumerate() {
            let formatter-fn = if formatter == none {
                (x) => x
            } else {
                formatter
            }

            let item = gloss-line-lists.at(line-idx).at(item-index)
            args.push(formatter-fn(item))
        }
        make-item-box(..args)
        h(item-spacing)
    }
}

// Typesets the internal part of the interlinear glosses. This function does not deal with the external matters of numbering and labelling; which are handled by `example()`.
#let gloss(
  header: none,
  header-style: none,
  source: (),
  source-style: none,
  transliteration: none,
  transliteration-style: none,
  morphemes: none,
  morphemes-style: none,
  additional-lines: (), //List of list of content
  translation: none,
  translation-style: none,
  item-spacing: 1em,
) = {
  assert(type(source) == "array", message: "source needs to be an array; perhaps you forgot to type `(` and `)`, or a trailing comma?")

  if morphemes != none {
    assert(type(morphemes) == "array", message: "morphemes needs to be an array; perhaps you forgot to type `(` and `)`, or a trailing comma?")
    assert(source.len() == morphemes.len(), message: "source and morphemes have different lengths")
  }

  if transliteration != none {
    assert(transliteration.len() == source.len(), message: "source and transliteration have different lengths")
  }

  let gloss-items = {
    if header != none {
      if header-style != none {
        header-style(header)
      } else {
        header
      }
      linebreak()
    }

    let formatters = (source-style,)
    let gloss-line-lists = (source,)

    if transliteration != none {
      formatters.push(transliteration-style)
      gloss-line-lists.push(transliteration)
    }

    if morphemes != none {
      formatters.push(morphemes-style)
      gloss-line-lists.push(morphemes)
    }

    for additional in additional-lines {
      formatters.push(none) //TODO fix this
      gloss-line-lists.push(additional)
    }

    build-gloss(item-spacing, formatters, gloss-line-lists)

    if translation != none {
      linebreak()

      if translation-style == none {
        translation
      } else {
        translation-style(translation)
      }
    }
  }

  align(left)[#gloss-items]
}



// ╭─────────────────────╮
// │ Linguistic examples │
// ╰─────────────────────╯

#let example-count = counter("example-count")

#let example(
    label: none,
    label-supplement: [example],
    gloss-padding: 2.5em, //TODO document these
    left-padding: 0.5em,
    numbering: false,
    breakable: false,
    ..args
) = {
    let add-subexample(subexample, count) = {
        // Remove parameters which are not used in the `gloss`.
        // TODO Make this functional, if (or when) it’s possible in Typst: filter out `label` and `label-supplement` when they are passed below.
        let subexample-internal = subexample
        if "label" in subexample-internal {
            let _ = subexample-internal.remove("label")
        }
        if "label-supplement" in subexample-internal {
            let _ = subexample-internal.remove("label-supplement")
        }
        par()[
            #box()[
                #figure(
                    kind: "subexample",
                    numbering: it => [#example-count.display()#count.display("a")],
                    outlined: false,
                    supplement: it => {if "label-supplement" in subexample {return subexample.label-supplement} else {return "example"}},
                    stack(
                        dir: ltr, //TODO this needs to be more flexible
                        [(#context count.display("a"))],
                        left-padding,
                        gloss(..subexample-internal)
                    )
                ) #if "label" in subexample {std.label(subexample.label)}
            ]
        ]
    }

    if numbering {
        example-count.step()
    }

    let example-number = if numbering {
        [(#context example-count.display())]
    } else {
        none
    }

    style(styles => {
        block(breakable: breakable)[
            #figure(
                kind: "example",
                numbering: it => [#example-count.display()],
                outlined: false,
                supplement: label-supplement,
                stack(
                    dir: ltr, //TODO this needs to be more flexible
                    left-padding,
                    [#example-number],
                    gloss-padding - left-padding - measure([#example-number]).width,
                    {
                        if args.pos().len() == 1 { // a simple example with no sub-examples
                            gloss(..arguments(..args.pos().at(0)))
                        }
                        else { // containing sub-examples
                            let subexample-count = counter("subexample-count")
                            subexample-count.update(0)
                            set align(left)
                            if "header" in args.named() {
                                par[#args.named().header]
                            }
                            for subexample in args.pos() {
                                subexample-count.step()
                                add-subexample(subexample, subexample-count)
                            }
                        }
                    }
                ),
            ) #if label != none {std.label(label)}
        ]
    }
    )
}

#let numbered-example = example.with(numbering: true)
