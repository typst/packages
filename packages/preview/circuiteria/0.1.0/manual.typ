#import "@preview/tidy:0.3.0"
#import "@preview/cetz:0.2.2": draw, canvas
#import "src/lib.typ"
#import "doc/examples.typ"
#import "src/circuit.typ": circuit
#import "src/element.typ"
#import "src/gates.typ"
#import "src/util.typ"
#import "src/wire.typ"

#set heading(numbering: (..num) => if num.pos().len() < 4 {
  numbering("1.1", ..num)
})
#{
  outline(indent: true, depth: 3)
}

#show link: set text(blue)
#show heading.where(level: 3): it => context {
  let cnt = counter(heading)
  let i = cnt.get().at(it.depth) - 1
  let color = util.colors.values().at(i)
  block(width: 100%)[
    #grid(
      columns: (auto, 1fr),
      column-gutter: 1em,
      align: horizon,
      it,
      {
        place(horizon)[
          #line(
            start: (0%, 0%),
            end: (100%, 0%),
            stroke: color + 1pt
          )
        ]
        place(horizon)[
          #circle(radius: 3pt, stroke: none, fill: color)
        ]
        place(horizon+right)[
          #circle(radius: 3pt, stroke: none, fill: color)
        ]
      }
    )
  ]
}

#set page(numbering: "1/1", header: align(right)[circuiteria #sym.dash.em v#lib.version])
#set page(
  header: locate(loc => {
    let txt = [circuiteria #sym.dash.em v#lib.version]
    let cnt = counter(heading)
    let cnt-val = cnt.get()
    if cnt-val.len() < 2 {
      align(left, txt)
      return
    }
    let i = cnt-val.at(1) - 1
    grid(
      columns: (auto, 1fr),
      column-gutter: 1em,
      align: horizon,
      txt,
      place(horizon + left)[
        #rect(width: 100%, height: .5em, radius: .25em, stroke: none, fill: util.colors.values().at(i))
      ]
    )
  }),
  footer: locate(loc => {
    let cnt = counter(heading)
    let cnt-val = cnt.get()
    if cnt-val.len() < 2 { return }
    let i = cnt-val.at(1) - 1
    grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      align: horizon,
      place(horizon + left)[
        #rect(width: 100%, height: .5em, radius: .25em, stroke: none, fill: util.colors.values().at(i))
      ],
      counter(page).display("1/1", both: true)
    )
  })
)

#let doc-ref(target, full: false, var: false) = {
  let (module, func) = target.split(".")
  let label-name = module + func
  let display-name = func
  if full {
    display-name = target
  }
  if not var {
    label-name += "()"
    display-name += "()"
  }
  link(label(label-name))[#display-name]
}

= Introduction

This package provides a way to make beautiful block circuit diagrams using the CeTZ package.

= Usage

Simply import #link("src/lib.typ") and call the `circuit` function:
#pad(left: 1em)[```typ
#import "src/lib.typ"
#lib.circuit({
  import lib: *
  ...
})
```]

= Reference

#let circuit-docs = tidy.parse-module(
  read("src/circuit.typ"),
  name: "circuit",
  require-all-parameters: true
)
#tidy.show-module(circuit-docs)

#pagebreak()

#let util-docs = tidy.parse-module(
  read("src/util.typ"),
  name: "util",
  require-all-parameters: true,
  scope: (
    util: util,
    canvas: canvas,
    draw: draw
  )
)
#tidy.show-module(util-docs)

#pagebreak()

#let wire-docs = tidy.parse-module(
  read("src/wire.typ"),
  name: "wire",
  require-all-parameters: true,
  scope: (
    wire: wire,
    circuit: circuit,
    draw: draw,
    examples: examples,
    doc-ref: doc-ref
  )
)
#tidy.show-module(wire-docs)

#pagebreak()

#let element-docs = tidy.parse-module(
  read("src/elements/element.typ") + "\n" +
  read("src/elements/alu.typ") + "\n" +
  read("src/elements/block.typ") + "\n" +
  read("src/elements/extender.typ") + "\n" +
  read("src/elements/multiplexer.typ") + "\n" +
  read("src/elements/group.typ"),
  name: "element",
  scope: (
    element: element,
    circuit: circuit,
    draw: draw,
    wire: wire,
    tidy: tidy,
    examples: examples,
    doc-ref: doc-ref
  )
)

#tidy.show-module(element-docs, sort-functions: false)

#pagebreak()

#let gates-docs = tidy.parse-module(
  read("src/elements/logic/gate.typ") + "\n" +
  read("src/elements/logic/and.typ") + "\n" +
  read("src/elements/logic/buf.typ") + "\n" +
  read("src/elements/logic/or.typ") + "\n" +
  read("src/elements/logic/xor.typ"),
  name: "gates",
  scope: (
    element: element,
    circuit: circuit,
    gates: gates,
    draw: draw,
    wire: wire,
    tidy: tidy,
    examples: examples,
    doc-ref: doc-ref
  )
)

#tidy.show-module(gates-docs, sort-functions: false)