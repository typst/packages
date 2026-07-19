#import "gloss.typ": gloss
#import "config.typ": auto-sub
#import "ex-label.typ": ex-label, get-ex-label

#let example-count = counter("example")

#let build-example(
  content,
  // 0 (example) or 1 (subexample)
  level: 0,
  number: none,
  label: none,
  parent-label: none,
  config: none,
  auto-subexamples: auto,
  auto-glosses: auto,
) = {
  if number == none {
    example-count.step(level: level + 1)
  }

  context {
    let label = label
    if label == none {
      label = get-ex-label(content)
    }
    if config.auto-labels and label == none and parent-label != none {
      label = std.label(str(parent-label) + ":" + (numbering("a", example-count.get().at(level))))
    }

    let example-number
    if number != none {
      // if custom number is sent, override example number and don't increment
      example-number = numbering(config.num-pattern, number)
    } else {
      example-number = numbering(config.num-pattern, example-count.get().at(level))
    }

    // override auto centering in figures
    show figure.where(kind: "subexample"): set align(start)

    show figure.where(kind: "subexample"): set block(
      spacing: auto-sub(config.spacing, par.leading),
      breakable: config.breakable,
    )

    show figure.where(kind: "example"): it => {
      set block(
        spacing: auto-sub(config.spacing, par.spacing),
        breakable: config.breakable,
      )
      // override auto centering in figures
      set align(start)
      set par(
        first-line-indent: 0em,
        spacing: par.leading,
      )

      // turn +'s into subexamples
      show enum: it => context {
        if auto-sub(auto-subexamples, config.auto-subexamples) {
          for item in it.children {
            {
              build-example(
                item.body,
                level: 1,
                parent-label: label,
                number: number,
                config: config.sub,
                auto-glosses: auto-sub(auto-glosses, config.auto-glosses)
              )
            }
          }
        } else {
          it
        }
      }
      // turn -'s into glosses
      show list: it => {
        if auto-sub(auto-glosses, config.auto-glosses) {
          gloss(
            ..it.children.map(it => it.body),
         )
        } else {
          it
        }
      }
      it
    }

    // show the example
    [
      #figure(
        kind: config.figure-kind,
        numbering: it => [#example-count.display("1a")],
        supplement: config.label-supplement,
        outlined: false,
        grid(
          columns: (config.indent, config.body-indent, 1fr),
          [],
          example-number,
          grid.cell(content, breakable: config.breakable),
        )
      ) #if label != none {label}
    ]
    // [#repr(label)]
  }
}


/// Explicitly typesets a subexample
/// as a figure of type "subexample".
/// Only intended for use inside an example. -> content
#let subexample(
  /// The body of the subexample. -> content
  content,
  /// The label to use for reference. -> label | none
  label: none,
  /// Overrides automatic numbering of the subexample.
  /// If not none, the counter does not increment. -> int | none
  number: none,
  /// Override config preset for automatic bullet list conversion. -> bool
  auto-glosses: auto,
) = context {

  let config = state("eggs-config").get().sub
  build-example(
    content,
    level: 1,
    label: label,
    number: number,
    config: config,
    auto-glosses: auto-glosses,
  )
}


/// Typesets a top-level example
/// as a figure of kind "example". -> content
#let example(
  /// The body of the example. -> content
  content,
  /// The label to use for reference. -> label | none
  label: none,
  /// Overrides automatic numbering of the example.
  /// If not none, the counter does not increment. -> int | none
  number: none,
  /// Override config preset for automatic numbered linst conversion. -> bool
  auto-subexamples: auto,
  /// Override config preset for automatic bullet list conversion. -> bool
  auto-glosses: auto,
) = context {

  let config = state("eggs-config").get()
  build-example(
    content,
    level: 0,
    label: label,
    number: number,
    config: config,
    auto-subexamples: auto-subexamples,
    auto-glosses: auto-glosses,
  )
}


