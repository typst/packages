#import "@preview/elembic:1.1.1" as e

#import "gloss.typ": gloss
#import "utils.typ": auto-length, gen-get-function, prefix
#import "ex-label.typ": ex-label, get-ex-label
#import "judge.typ": judge


#let ctr = counter("eggsample")
#let fn-ctr = counter("fn-eggsample")

// trim a counter, removing all values after `level`
#let reset-at(..args, level: 0) = {
  let c = args.pos()
  if c.len() > level + 1 {
    return c.slice(0, level + 1)
  }
  return c
}

// either step the counter or trim it
#let update-counter(ctr, level: 0, increment: true) = {
  if increment {
    // increment only if no custom number is sent
    ctr.step(level: level + 1)
  } else {
    // since the counter is not stepped,
    // prevent subexample numbering from being continued from the previous example
    ctr.update(reset-at.with(level: level))
  }
}


// generate a sub label of the form parent-label:n,
// getting n from the counter
#let auto-sub-label(parent-label) = label(
  str(parent-label)
  + ":"
  + (numbering("a", ctr.get().at(1, default: 0) + 1))
)


// assemble the example
#let build-example(
  elem,
  // use recursion with early binding
  // per https://github.com/typst/typst/issues/744#issuecomment-2343319015
  subexample-func: none,
  number: none,
  level: 0,
  kind: none
) = {

  // turn a list into subexamples
  let into-subexamples(enabled, level: 0, subexample-wrapper: none, parent-number: none, parent-label: none) = it => {
    if enabled {
      subexample-wrapper(
        ..it.children.map(item => {
          subexample-func(
            item.body,
            _parent-number: parent-number,
            _parent-label: parent-label,
          )
        })
      )
    } else {
      it
    }
  }

  // turn a list into glosses
  let into-glosses(enabled) = it => {
    if enabled {
      gloss(..it.children.map(it => it.body))
    } else {
      it
    }
  }

  // show selected initial characters as corresponding judges
  let format-judges(body, auto-judges: (:)) = {
    if auto-judges.len() == 0 {
      // make passing an empty structure actually work
      auto-judges = ("emptydictionaryfiller": false)
    }
    assert(type(auto-judges) == dictionary, message: "`auto-judges` must be a dictionary")

    let escape-special-characters(s) = s.replace(regex("[-\[\]{}()+?.,^$|\\s]"), c => "\\" + c.text)
    let judge-regex(a) = regex("^(" + a.map(escape-special-characters).join("|") + ")+ ?")
    show judge-regex(auto-judges.keys()): it => {
      show " ": ""
      show judge-regex(auto-judges.keys().filter(key => auto-judges.at(key))): super
      judge(it)
    }
    body
  }

  let show-with-autos(elem, level: 0, parent-number: none, parent-label: none) = {
    show enum: into-subexamples(
      elem.auto-subexamples,
      level: 0,
      subexample-wrapper: elem.at("subexample-wrapper", default: "none"),
      parent-number: parent-number,
      parent-label: parent-label
    )
    show list: into-glosses(elem.auto-glosses)
    format-judges(elem.body, auto-judges: elem.auto-judges)
  }

  show: it => {
    set block(spacing: (elem.get-spacing)())
    // for wrapping examples in a grid
    set grid(row-gutter: (elem.get-spacing)())
    it
  }

  grid(
    columns: (elem.indent, elem.body-indent, 1fr),
    [],
    numbering(
      elem.num-pattern,
      if elem.number != none { elem.number } else { elem._counter.get().at(level) }
    ),
    grid.cell(
      show-with-autos(
        elem,
        level: level,
        parent-number: elem.at("number", default: none),
        parent-label: if elem.auto-subexamples and elem.auto-labels { elem.at("label", default: none) } else { none }
      ),
      breakable: elem.breakable),
  )
}

/// Second-level linguistic subexample. Only intended for use inside an example.
///
/// - body (content): The body of the subexample.
///
///   *Required*
///
/// - number (int | none): Overrides automatic numbering of the subexample. If not none, the counter does not increment.
///
///   *Default*: none
///
///
/// - auto-glosses (bool): Whether to treat bullet lists as glosses.
///
///   *Default*: true
///
/// - auto-judges (dictionary): A dictionary of characters to convert into judges (keys) and whether to superscript them (values).
///
///   *Default*: ("\*": false, "\#": true, "?": true, "OK": true)
///
/// - indent (length): Distance between the left edge of the top-level example and the left edge of the subexample number.
///
///   *Default*: 0em
///
/// - body-indent (length): Distance between the left edge of the subexample marker and the left edge of the subexample body.
///
///   *Default*: 1.5em
///
/// - spacing (length): Vertical spacing around the subexample.
///
///   *Default*: current `par.leading`.
///
/// - breakable (bool): Whether the subexample figure is breakable.
///
///   *Default*: false
///
/// - num-pattern (str | function): Subexample number format.
///   A numbering pattern.
///
///   *Default*: "a."
///
/// - ref-pattern (str | function): Example reference format.
///   A 2-level numbering pattern.
///
///   *Default*: "1a"
///
/// - second-sub-ref-pattern (str | function): Format to reference the second argument of `ex-ref` if it is a subexample.
///   A 1-level numbering pattern.
///
///   *Default*: "a"
///
/// - label-supplement (str | none): The subexample figure supplement used in references.
///   Has no effect when `smart-ref` is `true`.
///
///   *Default*: none
///
/// -> content
#let subexample = e.element.declare(
  "subexample",
  prefix: prefix,
  doc: "Second-level subexample. Only intended for use inside an example.",

  fields: (
    e.field("body", content, required: true, doc: "The body of the subexample"),
    e.field("number", e.types.option(int), doc: "Overrides automatic numbering of the subexample. If not none, the counter does not increment."),

    e.field("auto-glosses", bool, default: true, doc: "Whether to treat bullet lists as glosses."),
    // accept lists for legacy support of ()
    e.field("auto-judges", e.types.union(dictionary, array), default: (
      "\*": false,
      "\#": true,
      "?": true,
      "OK": true,
    ), folds: false, doc: "A dictionary of characters to convert into judges (keys) and whether to superscript them (values)."),

    e.field("indent", length, default: 0em, doc: "Distance between the the left edge of the top-level example body and the left edge of the subexample number."),
    e.field("body-indent", length, default: 1.5em, doc: "Distance between the left edge of the subexample marker and the left edge of the subexample body."),
    e.field("spacing", auto-length, default: auto, doc: "Vertical spacing around the subexample. Currently, there is no way to modify spacing between two subexamples specifically."),
    e.field("breakable", bool, default: false, doc: "Whether the subexample figure is breakable."),
    
    e.field("num-pattern", e.types.union(str, function), default: "a.", doc: "Subexample number format."),
    e.field("ref-pattern", str, default: "1a", doc: "Example reference format (without brackets). A 2-level numbering pattern."),
    e.field("second-sub-ref-pattern", str, default: "a", doc: "Format to reference the second argument of `ex-ref` if it is a subexample. A 1-level numbering pattern."),
    e.field("label-supplement", e.types.option(str), doc: "The subexample figure supplement used in references. Has no effect when `smart-ref` is `true`."),

    e.field("_counter", counter, default: counter("eggsample"), doc: "The example counter. Set automatically and differs in footnotes."),
    e.field("_parent-number", e.types.option(int), doc: "Top-level example number, when overriden. Set automatically."),
    e.field("_parent-label", e.types.option(label), doc: "Top-level example label for auto-labels. Set automatically."),
    e.field("auto-subexamples", bool, synthesized: true),
    e.field("get-spacing", function, synthesized: true, default: () => par.leading)
  ),
  
  construct: constructor => (..args) => {
    if args.named().at("label", default: none) != none {
      constructor(..args)
    } else {
      let lbl = get-ex-label(args.pos().at(0))

      // only use context when needed to generate auto labels
      if lbl == none and args.at("_parent-label", default: none) != none {
        context {
          let lbl = auto-sub-label(args.at("_parent-label"))
          constructor(..args, label: lbl)
        }
      } else {
        constructor(..args, label: lbl)
      }
    }
  },

  synthesize: it => {
    it.auto-subexamples = false
    gen-get-function(it, ("spacing", par.leading))
  },

  // using custom counter
  count: _ => it => update-counter(it._counter, level: 1, increment: it.number == none),

  reference: (
    supplement: it => it.label-supplement,
    // using custom counter
    numbering: it => _ => {
      let parent-number = if it.at("_parent-number", default: none) != none {
        it._parent-number
      } else {
        it._counter.get().at(0)
      }
      let number = if it.at("number", default: none) != none {
        it.number
      } else {
        it._counter.get().at(1)
      }

      numbering(
        it.ref-pattern,
        parent-number, number
      )
    }
  ),

  display: it => build-example(
    it,
    level: 1,
  )
)


/// Top-level linguistic example.
///
/// - body (content): The body of the example.
///
///   *Required*
///
/// - number (int | none): Overrides automatic numbering of the example. If not none, the counter does not increment.
///
///   *Default*: none
///
/// - auto-subexamples (bool): Whether to treat numbered lists in examples as subexamples.
///
///   *Default*: true
///
/// - auto-glosses (bool): Whether to treat bullet lists in examples as glosses.
///
///   *Default*: true
///
/// - auto-labels (bool): Whether to insert subexample labels of the form ex-label:a.
///
///   *Default*: true
///
/// - auto-judges (dictionary): A dictionary of characters to convert into judges (keys) and whether to superscript them (values).
///
///   *Default*: ("\*": false, "\#": true, "?": true, "OK": true)
///
/// - indent (length): Distance between the left margin and the left edge of the example number.
///
///   *Default*: 0em
///
/// - body-indent (length): Distance between the left edge of the example marker and the left edge of the example body.
///
///   *Default*: 2.5em
///
/// - spacing (length): Vertical spacing around the example.
///   Currently, there is no way to modify spacing between two examples specifically.
///
///   *Default*: current `par.spacing`.
///
/// - breakable (bool): Whether the example figure is breakable.
///
///   *Default*: false
///
/// - num-pattern (str | function): Example number format.
///   A numbering pattern.
///
///   *Default*: "(1)"
///
/// - ref-pattern (str | function): Example reference format.
///   A 2-level numbering pattern.
///
///   *Default*: "1a"
///
/// - label-supplement (str | none): The example figure supplement used in references.
///   Has no effect when `smart-ref` is `true`.
///
///   *Default*: none
///
/// - smart-refs (bool): Whether to format `@`-references and `ref`-references to examples
///   Adding parenthesis and parsing the supplement.
///
///   *Default*: true
///
/// -> content
#let example = e.element.declare(
  "example",
  prefix: prefix,
  doc: "Top-level linguistic example",

  fields: (
    e.field("body", content, required: true, doc: "The body of the example"),
    e.field("number", e.types.option(int), doc: "Overrides automatic numbering of the example. If not none, the counter does not increment."),

    e.field("auto-subexamples", bool, default: true, doc: "Whether to treat numbered lists in examples as subexamples."),
    e.field("auto-glosses", bool, default: true, doc: "Whether to treat bullet lists in examples as glosses."),
    e.field("auto-labels", bool, default: true, doc: "Whether to insert subexample labels of the form ex-label:a."),
    // accept lists for legacy support of ()
    e.field("auto-judges", e.types.union(dictionary, array), default: (
      "\*": false,
      "\#": true,
      "?": true,
      "OK": true,
    ), folds: false, doc: "A dictionary of characters to convert into judges (keys) and whether to superscript them (values)."),

    e.field("subexample-wrapper", function, default: (..args) => {args.pos().join()}, doc: "A function to wrap the subexample list. Should accept any number of arguments and return content. E.g. to align your subexamples horizontally, pass `grid.with(columns: 5)`. Only works for automatic examples."),

    e.field("indent", length, default: 0em, doc: "Distance between the left margin and the left edge of the example number."),
    e.field("body-indent", length, default: 2.5em, doc: "Distance between the left edge of the example marker and the left edge of the example body."),
    e.field("spacing", auto-length, default: auto, doc: "Vertical spacing around the example. Currently, there is no way to modify spacing between two examples specifically."),
    e.field("breakable", bool, default: false, doc: "Whether the example figure is breakable."),

    e.field("num-pattern", e.types.union(str, function), default: "(1)", doc: "Example number format."),
    e.field("ref-pattern", str, default: "1a", doc: "Example reference format (without brackets). A 2-level numbering pattern."),
    e.field("label-supplement", e.types.option(str), default: none, doc: "The example figure supplement used in references. Has no effect when `smart-ref` is `true`."),
    e.field("smart-refs", bool, default: true, doc: "Whether to format `@`-references and `ref`-references to examples Adding parenthesis and parsing the supplement."),

    e.field("_counter", counter, default: counter("eggsample"), doc: "The example counter. Set automatically and differs in footnotes."),
    e.field("get-spacing", function, synthesized: true, default: () => par.spacing)
  ),

  construct: constructor => (..args) => {
    if args.named().at("label", default: none) != none {
      constructor(..args)
    } else {
      constructor(..args, label: get-ex-label(args.pos().at(0, default: [])))
    }
  },

  synthesize: it => gen-get-function(it, ("spacing", par.spacing)),

  // using custom counter
  count: _ => it => update-counter(it._counter, level: 0, increment: it.number == none),

  reference: (
    supplement: it => it.label-supplement,
    // using custom counter
    numbering: it => _ => numbering(
      it.ref-pattern,
      if it.number != none { it.number } else { it._counter.get().at(0) }
    )
  ),

  display: it => build-example(
    subexample-func: subexample,
    it,
    level: 0,
  )
)
