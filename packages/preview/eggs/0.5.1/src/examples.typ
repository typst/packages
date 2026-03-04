#import "gloss.typ": gloss
#import "config.typ": auto-sub
#import "ex-label.typ": ex-label, get-ex-label
#import "judge.typ": judge

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
  auto-judges: auto,
) = {
  assert(config != none, message: "`show: eggs` must be used before `example`")

  let reset-at(..args, level: 0) = {
    let counter = args.pos()
    if counter.len() > level + 1 {
      return counter.slice(0, level + 1)
    }
    return counter
  }

  if number == none {
    // increment only if no custom number is sent
    counter(config.counter-name).step(level: level + 1)
  } else {
    // since the counter is not stepped,
    // prevent subexample numbering from being continued from the previous example
    counter(config.counter-name).update(reset-at.with(level: level))
  }

  context {
    let example-count = counter(config.counter-name).get()
    if number != none {
      if example-count.len() >= level + 1 {
        example-count.at(level) = number
      } else {
        example-count.insert(level, number)
      }
    }

    let label = label
    if label == none {
      label = get-ex-label(content)
    }
    if config.auto-labels and label == none and parent-label != none {
      label = std.label(str(parent-label) + ":" + (numbering("a", example-count.at(level))))
    }

    // override auto centering in figures
    show figure.where(kind: "example"): set align(start)
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
      set par(
        first-line-indent: 0em,
        spacing: par.leading,
      )

      // turn +'s into subexamples
      show enum: it => {
        if auto-sub(auto-subexamples, config.auto-subexamples) {
          for item in it.children {
            build-example(
              item.body,
              level: 1,
              parent-label: label,
              config: config.sub,
              auto-glosses: auto-sub(auto-glosses, config.auto-glosses)
            )
          }
        } else {
          it
        }
      }
      // turn -'s into glosses
      show list: it => {
        if auto-sub(auto-glosses, config.auto-glosses) {
          gloss(..it.children.map(it => it.body))
        } else {
          it
        }
      }

      // turn selected initial characters into corresponding judges
      let aj = auto-sub(auto-judges, config.auto-judges)
      if aj.len() == 0 {
        // make passing an empty structure actually work
        aj = ("emptydictionaryfiller": false)
      }
      assert(type(aj) == dictionary, message: "`auto-judges` must be a dictionary")

      let escape-special-characters(s) = s.replace(regex("[-\[\]{}()+?.,^$|\\s]"), c => "\\" + c.text)
      let judge-regex(a) = regex("^(" + a.map(escape-special-characters).join("|") + ")+ ?")
      show judge-regex(aj.keys()): it => {
        show " ": ""
        show judge-regex(aj.keys().filter(key => aj.at(key))): super
        judge(it)
      }
      it
    }

    // show the example
    [
      #figure(
        kind: config.figure-kind,
        numbering: _ => numbering(config.ref-pattern, ..example-count),
        supplement: config.label-supplement,
        outlined: false,
        grid(
          columns: (config.indent, config.body-indent, 1fr),
          [],
          numbering(config.num-pattern, example-count.at(level)),
          grid.cell(content, breakable: config.breakable),
        )
      ) #label
    ]
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
  /// Override config preset for automatic judge conversion. -> array
  auto-judges: auto,
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
    auto-judges: auto-judges,
  )
}
