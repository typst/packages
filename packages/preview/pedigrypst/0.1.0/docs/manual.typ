#import "@preview/tidy:0.4.3"
#import "@preview/meander:0.4.1"
#import "@preview/pedigrypst:0.1.0" as pedigrypst: pedigree
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/larrow:1.0.1": label-arrow

#show link: content => underline(content, stroke: blue)

#let CeTZ = link("https://github.com/johannes-wolf/cetz", [CeTZ])
#let cetz-link(dest, body) = link("https://cetz-package.github.io/docs/" + dest, body)
#let hbar = line(end: (100%, 0%))
#set page(numbering: "1")

#align(center, text([= `pedigrypst`], size: 24pt))

#align(center, [
  A #link("https://typst.app", [Typst]) package for building pedigrees, built on top of #cetz-link("", [CeTZ])

  #link("https://github.com/CrowdingFaun624/Pedigrypst", `github.com/CrowdingFaun624/Pedigrypst`)

  #strong[Version 0.1.0]
])
#v(1in)

// Thanks to fletcher for having nicely formatted things that I don't know how to do
#columns(2)[
	#outline(
		title: align(center, box(width: 100%)[Guide]),
		indent: 1em,
		target: selector(heading).before(<toc-functions>, inclusive: false),
	)
	#colbreak()
	#outline(
		title: align(center, box(width: 100%)[Reference]),
		indent: 1em,
		target: selector(heading.where(level: 2)).or(heading.where(level: 3)).after(<toc-functions>, inclusive: true),
	)
]

#pagebreak()
== Pedigree<toc-pedigree>
#align(center, pedigree(length: 4cm, generation-labels: false, {
  import pedigrypst: *
  individual(1, 1, "male", label: none)
  individual(1, 2, "female", label: none)
  individual(2, 1, "unknown", fill: "unknown", label: none)
  individual(2, 2, "female", label: none)
  individual(2, 3, "female", label: none)
  individual(2, 4, "male", label: none)
  twins("i2-2", "i2-3", monozygotic: true)
  union("i1-1", "i1-2")
  union("i2-3", "i2-4")
  children("u1", "i2-1", "t1")
  children("u2", infertile: true)
}, draw: () => {
  import draw: *
  let arrow(c1, c2, control) = {
    bezier(c1, c2, control)
    let (x2, y2) = c2
    let (xc, yc) = control
    let angle = calc.atan2(x2 - xc, y2 - yc)
    mark((x2 + 0.02 * calc.cos(angle), y2 + 0.02 * calc.sin(angle)), angle, symbol: "stealth", fill: black)
  }

  content((1, 0.25), [Union Line], anchor: "south")
  arrow((1, 0.23), (1.05, 1/64), (1.125, 0.125))

  content((-0.15, 0), [Individual], anchor: "north")
  arrow((0, 0.015), (0.22, 0.1), (0.125, 0.125))

  content((1.25, -0.375), [Line of Descent], anchor: "north-west")
  arrow((1.24, -0.375), (1, -0.25), (1.125, -0.25))

  content((0.5, -0.4), [Sibling Line], anchor: "east")
  arrow((0.51, -0.4), (0.7, -0.48), (0.6, -0.4))

  content((-0.125, -0.575), [Child Line], anchor: "south-east")
  arrow((-0.125, -0.59), (-0.02, -0.7), (-0.0625, -0.675))

  content((1.85, -0.625), [Twin Line], anchor: "west")
  arrow((1.83, -0.625), (1.7, -0.75), (1.75, -0.6))

  content((1.5, -1.3), [Monozygocity Line], anchor: "north")
  arrow((1.5, -1.3), (1.5, -0.75), (1.55, -1))

  content((2.3, -1.53), [No Children Line], anchor: "east")
  arrow((2.2, -1.48), (2.4, -1.47), (2.3, -1.25))

  content((2.7, -1.55), [Infertility Line], anchor: "south-west")
  arrow((2.8, -1.54), (2.55, -1.6), (2.73, -1.74))
}))

There are five different types of objects in a pedigree in Pedigrypst.

=== Individual<toc-pedigree-individual>

An *individual* is a single square, circle, or other shape that corresponds to a single organism.

#meander.reflow({
  import meander: *

  placed(top + right, pedigree(length: 2cm, generation-labels: false, {
    import pedigrypst: *
    individual(1, 1, "female", fill: "left", label: [Duplicate])
    duplicate(1, "i1-1")
  }), boundary: contour.margin(0.5cm))
  container()
  content[
    === Duplicate<toc-pedigree-duplicate>

    A *duplicate* is a type of individual that mimics another individual. They act like individuals in all other ways.

    === Union<toc-pedigree-union>

    A *union* is a relationship between two individuals. They do not necessarily have any children.
  ]
})

=== Twin<toc-pedigree-twin>

A *twin* is an object that contains multiple individuals. If this object is the child of a children object, then they will be drawn like twins.

=== Children<toc-pedigree-children>

A *children* is an object that references a union or an individual as its parents and multiple (or zero) individuals or twin objects as its children.

#hbar
== Shapes<toc-shapes>

There are four shapes/sexes that an individual can have, which is specified using the third parameter of #raw("individual", lang: "typc").

#table(stroke: none, columns: (25%,) * 4, ..{
  import pedigrypst: individual
  let h(sex) = align(center, raw("\"" + sex + "\"", lang: "typc"))
  let a(sex) = align(center, pedigree(length: 2cm, generation-labels: false, individual(1, 1, sex, label: none)))
  let fills = ("male", "female", "unknown", "miscarriage")
  (table.header(..fills.map(h)), ..fills.map(a))
})
The #raw("\"miscarriage\"", lang: "typc") shape is offset slightly higher than the other shapes.

#pagebreak()
== Fills<toc-fills>
There are eight preset fills available, which are specified using the #raw("fill", lang: "typc") parameter of #raw("individual", lang: "typc")

#table(stroke: none, columns: (12.5%,) * 8, ..{
  import pedigrypst: individual
  let h(fill) = align(center, raw("\"" + fill + "\"", lang: "typc"))
  let a(fill) = align(center, pedigree(length: 2cm, generation-labels: false, individual(1, 1, "male", fill: fill, label: none)))
  let fills = ("filled", "empty", "unknown", "dot", "left", "right", "up", "down")
  (table.header(..fills.map(h)), ..fills.map(a))
})

#meander.reflow({
  import meander: *
  import pedigrypst: individual

  placed(top + right, pedigree(length: 2cm, generation-labels: false, individual(1, 1, "male", fill: "I-III-IV", label: raw("\"I-III-IV\"", lang: "typc"))))

  container()
  content[
    Additionally, #link("https://en.wikipedia.org/wiki/Quadrant_(plane_geometry)", [quadrant]) notation may be used to specify the fill of each quadrant of a shape. This takes the form of a sequence of Roman numerals separated by hyphens. For example, the string #raw("\"I-III-IV\"", lang: "typc") encodes the fill of the individual shown to the right.
  ]
})

#hbar
== References<toc-references>

Objects in the pedigree can reference other objects using *references*.

=== Individual References<toc-references-individual>

#meander.reflow({
  import meander: *

  let ind-label(generation, ind-number, size: 10.5pt) = text(raw("\"i" + str(generation) + "-" + str(ind-number) + "\"", lang: "typc"), size)
  placed(top + right, pedigree(length: 2.5cm, generation-height: 0.75, {
    import pedigrypst: *
    individual(1, 1, "male", in-label: ind-label(1, 1))
    individual(1, 2, "female", in-label: ind-label(1, 2))
    individual(1, 3, "female", in-label: ind-label(1, 3))
    individual(1, 4, "male", in-label: ind-label(1, 4))
    individual(2, 1, "female", in-label: ind-label(2, 1))
    individual(2, 17, "male", in-label: [#ind-label(2, 17, size: 9pt) <end17>])
    individual(3, 1, "male", in-label: ind-label(3, 1))
    union("i1-1", "i1-2")
    union("i1-3", "i1-4")
    union("i2-1", "i2-17")
    children("u1", "i2-1")
    children("u2", "i2-17")
    children("u3", "i3-1")
  }))

  container()
  content[
    Individual references are strings that start with a lowercase #raw("\"i\"", lang: "typc"). Next is the one-indexed generation number of the individual. Then, there is a hyphen. Finally, there is the individual number, which is the number of the individual within its own generation.\ \

    #label-arrow(<start17>, <end17>, from-offset: (6cm, 25pt), to-offset: (-4pt, -8pt), bend: -70)
    The individual number may be any number, as long as an individual has it. Notably, individual numbers may be skipped. Because individual II-17 is created using #raw("individual(2, 17, \"male\")", lang: "typc"), it can be referenced<start17> using #raw("\"i2-17\"", lang: "typc").
  ]
})

=== Other References<toc-references-other>

Other objects can be referenced using their one-indexed ID. The ID of an object is how many objects of the same type, including itself, came before it.

#tidy.show-example.show-example(```typ
<<<#pedigree({
<<<  individual(1, 1, "male") // i1-1
<<<  individual(1, 2, "female") // i1-2
<<<  individual(2, 1, "male") // i2-1
<<<  individual(2, 2, "female") // i2-2
<<<  individual(2, 3, "female") // i2-3
<<<  individual(2, 4, "male") // i2-4
<<<  duplicate(3, "i1-1") // d1
<<<  twins("i2-2", "i2-3") // t1
<<<  union("i1-1", "i1-2") // u1
<<<  union("i2-3", "i2-4") // u2
<<<  children("u1", "i2-1", "t1") // c1
<<<  children("u2", "d1") // c2
<<<})

>>>// me when I lie
>>>#let l(c) = raw("\"" + c + "\"", lang: "typc")
>>>#import pedigrypst: *
>>>#pedigree(length: 2cm, generation-height: 1.2, {
>>>  individual(1, 1, "male")
>>>  individual(1, 2, "female")
>>>  individual(2, 1, "male")
>>>  individual(2, 2, "female")
>>>  individual(2, 3, "female")
>>>  individual(2, 4, "male")
>>>  duplicate(3, "i1-1", bezier: -1.3, label: l("d1"))
>>>  twins("i2-2", "i2-3", label: l("t1"))
>>>  union("i1-1", "i1-2", label: l("u1"))
>>>  union("i2-3", "i2-4", label: l("u2"))
>>>  children("u1", "i2-1", "t1", label: l("c1"))
>>>  children("u2", "d1", label: l("c2"))
>>>})
```, scope: (pedigrypst: pedigrypst))

Duplicate are referenced with #raw("\"d\"", lang: "typc"), twins are referenced with #raw("\"t\"", lang: "typc"), unions are referenced with #raw("\"u\"", lang: "typc"), and childrens are referenced with #raw("\"c\"", lang: "typc").

#pagebreak()
== Decorations<toc-decorations>

#let decorations-table(columns, pedigree-func, text-func, data) = {
  import pedigrypst: *
  let cells = data.map(((arguments, text, top, bottom),) => {
    v(top)
    align(center, pedigree-func(..arguments))
    v(bottom)
    raw(text-func(text), lang: "typc")
  })
  let real-cells = ()
  for (index, cell) in cells.enumerate() {
    if calc.rem(index, columns) == columns - 1 and index != cells.len() - 1 {
      real-cells.push(table.hline())
    }
    real-cells.push(cell)
  }
  table(
    columns: (100% / columns,) * columns, stroke: none, inset: (x: 5pt, y: 8.5pt),
    ..real-cells
  )
}

=== Individual Decorations<toc-decorations-individual>

#{
  import pedigrypst: *
  decorations-table(
    4,
    (..args) => pedigree(length: 2cm, generation-labels: false, individual(1, 1, "male", label: none, ..args)),
    text => "individual(\n\t1, 1, \"male\",\n\t" + text + ",\n)",
    (
      ((dead: true), "dead: true", 0pt, 0pt),
      ((dead: "double"), "dead: \"double\"", 0pt, 0pt),
      ((adopted: true), "adopted: true", 3.5pt, 3.5pt),
      ((adopted: "alt"), "adopted: \"alt\"", 3.5pt, 3.5pt),
      ((propositus: true), "propositus: true", 10.5pt, 0pt),
      ((propositus: top), "propositus: top", 0pt, 7pt),
      ((label: [Wowee]), "label: [Wowee]", 10.5pt, 1.5pt),
      ((in-label: [P]), "label: [P]", 10.5pt, 7pt),
    ),
  )
}

=== Duplicate Decorations<toc-decorations-duplicate>
#{
  import pedigrypst: *
  decorations-table(
    2,
    (..args) => pedigree(length: 2cm, generation-labels: false, {
      individual(1, 1, "male")
      duplicate(1, "i1-1", ..args)
    }),
    text => "duplicate(1, \"i1-1\", " + text + ")",
    (
      ((bezier: 2), "bezier: 2", 0pt, 0pt),
      ((label: [Label]), "label: [Label]", 11.25pt, 0pt),
    )
  )
}

=== Twin Decorations<toc-decorations-twin>
#{
  import pedigrypst: *
  decorations-table(
    3,
    (..args) => pedigree(length: 1.75cm, generation-labels: false, {
      individual(1, 1, "male", label: none)
      individual(2, 3, "male", label: none)
      individual(2, 1, "male")
      individual(2, 2, "male")
      twins("i2-1", "i2-2", ..args)
      children("i1-1", "i2-3", "t1")
    }),
    text => "twins(\n\t\"i2-1\", \"i2-2\",\n\t" + text + ",\n)",
    (
      ((monozygotic: true), "monozygotic: true", 0pt, 0pt),
      ((monozygotic: "unknown"), "monozygotic: \"unknown\"", 0pt, 0pt),
      ((label: [Twins]), "label: [Twins]", 0pt, 0pt)
    )
  )
}
#pagebreak()
=== Union Decorations<toc-decorations-union>
#{
  import pedigrypst: *
  decorations-table(
    2,
    (..args) => pedigree(length: 2cm, generation-labels: false, {
      individual(1, 1, "male")
      individual(1, 2, "female")
      union("i1-1", "i1-2", ..args)
    }),
    text => "union(\n\t\"i1-1\", \"i1-2\",\n\t" + text + ",\n)",
    (
      ((consanguineous: true), "consanguineous: true", 0pt, 0pt),
      ((label: [Hi]), "label: [Hi]", 0pt, 0pt),
      ((divorced: true), "divorced: true", 0pt, 0pt),
      ((divorced: 2), "divorced: 2", 0pt, 0pt),
    )
  )
}

=== Children Decorations<toc-decorations-children>
#{
  import pedigrypst: *
  decorations-table(
    2,
    (..args) => pedigree(length: 2cm, generation-labels: false, {
      individual(1, 1, "male", label: none)
      individual(1, 2, "female", label: none)
      union("i1-1", "i1-2")
      if "infertile" in args.named() {
        children("u1", ..args)
      } else {
        individual(2, 1, "male")
        individual(2, 2, "female")
        children("u1", "i2-1", "i2-2", ..args)
      }
    }),
    text => {
      if "infertile" in text { // very hack yes
        "children(\"u1\", " + text + ")"
      } else {
        "children(\n\t\"u1\", \"i2-1\", \"i2-2\",\n\t" + text + ",\n)"
      }
    },
    (
      ((infertile: true), "infertile: true", 0pt, 47.5pt),
      ((label: [Children]), "label: [Children]", 0pt, 0pt),
    )
  )
}

=== Pedigree Decorations<toc-decorations-pedigree>

Note: The individuals and children are truncated from the code preview.

#{
  import pedigrypst: *
  import draw: content
  decorations-table(
    2,
    (..args) => pedigree(..args, {
      individual(1, 1, "male", label: none)
      individual(2, 1, "male", label: none)
      children("i1-1", "i2-1")
    }),
    // text => "pedigree(\n\t" + text + ",\n\t{\n\t\tindividual(1, 1, \"male\")\n\t\tindividual(2, 1, \"male\")\n\t\tchildren(\"i1-1\", \"i2-1\")\n\t},\n)",
    text => "pedigree(" + text + ")",
    (
      ((generation-height: 0.6), "generation-height: 0.5", 0pt, 11.25pt),
      ((generation-labels: false), "generation-labels: false", 0pt, 0pt),
      ((length: 1.5cm), "length: 1.5cm", 0pt, 0pt),
      ((draw: () => content((-1, 0), [Foo])), "draw: () => content(\n\t(-1, 0), [Foo],\n)", 0pt, 22.1pt),
    )
  )
}

#pagebreak()
== Example<toc-example>

#let my-example(code) = tidy.show-example.show-example(code, scope: (
  pedigree: pedigrypst.pedigree,
  individual: pedigrypst.individual,
  duplicate: pedigrypst.duplicate,
  twins: pedigrypst.twins,
  union: pedigrypst.union,
  children: pedigrypst.children,
))

#my-example(```typc
pedigree(
  length: 2cm,
  convergence-time: 250,
  empty-style: red.lighten(50%),
  {
    individual(1, 1, "male")
    individual(1, 2, "female")
    individual(2, 1, "female")
    individual(2, 2, "male")
    individual(2, 3, "female")
    individual(2, 4, "male")
    individual(3, 1, "male")
    individual(3, 2, "female")
    individual(3, 3, "male")
    individual(3, 4, "male")
    individual(3, 5, "female")
    individual(4, 1, "female")
    individual(4, 2, "female")
    individual(5, 1, "male")
    individual(6, 1, "male")
    individual(6, 2, "male")
    individual(6, 3, "male")
    individual(6, 4, "male", fill: "filled", propositus: true)

    union("i1-1", "i1-2")
    union("i2-1", "i2-2")
    union("i2-3", "i2-4")
    union("i3-1", "i4-1", consanguineous: true)
    union("i3-2", "i3-3")
    union("i3-4", "i3-5")
    union("i5-1", "i4-2", consanguineous: true)

    children("u1", "i2-2", "i2-4")
    children("u2", "i3-1")
    children("u3", "i3-3", "i3-4")
    children("u4", "i5-1")
    children("u5", "i4-1")
    children("u6", "i4-2")
    children("u7", "i6-1", "i6-2", "i6-3", "i6-4")
  }
)
```)

#pagebreak()
== Functions<toc-functions>
#let docs = tidy.parse-module(read("../src/main.typ"), scope: (
  meander: meander,
  pedigrypst: pedigrypst,
  CeTZ: CeTZ,
  cetz-link: cetz-link,
))

#tidy.show-module(docs)
