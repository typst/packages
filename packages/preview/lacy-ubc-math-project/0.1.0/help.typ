#let font-size = 10pt

#let sections = (
  "introduction",
  "getting-started",
  "setup",
  "author",
  "math",
  "drawing",
  "question",
  "solution",
  "caveats",
)

#let get-orientation(tag) = {
  if tag == <show> {
    return (
      dir: ltr,
      cols: (1fr, 1fr),
      align: (x, y) => horizon + (right, left).at(calc.rem(x, 2)),
      line: grid.vline,
    )
  } else if tag == <showt> {
    return (
      dir: ttb,
      cols: 1,
      align: (x, y) => (bottom, top).at(calc.rem(y, 2)),
      line: grid.hline,
    )
  }
}

#let help-setup(body) = {
  import "@preview/showman:0.1.2": runner
  let prefix-orig = (
    "#import \"@preview/lacy-ubc-math-project:0.1.0\": *",
    "#let __example-question-counters = range(1, unsafe.__max-qs-level + 1).map(i => counter(\"example-question-\" + str(i)))",
    "#for c in __example-question-counters {",
    "  c.update(1)",
    "}",
    "#let __example-question-labels = (\"ex:1\", \"a\", \"i\",)",
    "#set text(font: (\"DejaVu Serif\", \"New Computer Modern\"))",
    "#let question = question.with(counters: __example-question-counters, labels: __example-question-labels)",
    "#set math.equation(numbering: \"(1.1)\")",
    "#show: equate.with(breakable: true, sub-numbering: true)",
  ).join("\n")
  let suffix-orig = ""
  show raw.where(block: true): it => context {
    if "label" in it.fields() and it.label in (<show>, <showt>) and it.lang in ("typst", "typc") {
      let orientation = get-orientation(it.label)
      let prefix = prefix-orig
      let suffix = suffix-orig
      if it.lang == "typc" {
        prefix = prefix + "\n#{"
        suffix = "}\n" + suffix
      }

      runner.standalone-example(
        it,
        eval-prefix: prefix,
        eval-suffix: suffix,
        direction: orientation.dir,
        container: (input, output, direction: ltr) => {
          block(
            // breakable: false,
            width: 100%,
            grid(
              columns: orientation.cols,
              align: orientation.align,
              inset: (x: 1em, y: 0.8em),
              grid.cell(input),
              orientation.at("line")(stroke: 0.5pt),
              grid.cell(output),
            ),
          )
        },
      )
    } else { it }
  }

  show raw.where(block: false): r => box(
    fill: black.transparentize(95%),
    radius: 0.4em,
    inset: 0.35em,
    baseline: 0.35em,
    r,
  )

  body
}

#let help = (:)
#for section in sections {
  help.insert(
    section,
    block(
      width: 100%,
      inset: font-size,
      stroke: blue + 0.5pt,
      [
        #set text(size: font-size)
        #set heading(outlined: false)

        #text(fill: gray)[User Manual]
        #v(font-size * 0.5, weak: true)

        #show: help-setup
        #include "manuals/" + section + ".typ"
        #import "shorthand.typ": hrule
        #hrule

        #context v(par.spacing * -0.5)

        #text(
          size: font-size * 0.8,
          [
            Other helps: #sections.filter(s => s != section).map(s => raw(s)).join(", ").
          ],
        )
      ],
    ),
  )
}
