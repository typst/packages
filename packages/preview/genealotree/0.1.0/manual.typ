#import "@preview/mantys:0.1.3": *
#import "@preview/showman:0.1.1"
#import "@preview/tidy:0.2.0"

#let show-module(name, scope:(:)) = tidy-module(
  read(name + ".typ"),
  name: name,
  include-examples-scope: true,
  tidy: tidy,
  extract-headings: 3
)

#import "genealotree.typ": *

#show: mantys.with(
    ..toml("typst.toml"),
    examples-scope: (
        genealogy_init: genealogy_init,
        add_persons: add_persons,
        add_unions: add_unions,
        canvas: canvas,
        draw_tree: draw_tree
    )
)
#show link: set text(blue)

= Introduction
<sec-intro>

This package is based on #link("https://typst.app/universe/package/cetz/")[CeTZ] and it provides functions to draw genealogical trees. It is oriented towards medical genealogy to study genetic disorders inheritance, but you might be able to use it to draw your family tree.

*Features :*
- Draw an unlimited number of independant genealogical trees
- Supports consanguinity and unions between different trees (see limitations)
- Auto adjusts position of children to optimize spacing
- Customize all lengths
- Draw as much phenotypes as needed by coloring individuals
- Print genotype and/or phenotype labels under individuals

*Limitations :*
- Must manually adjust individual position in the tree when drawing consanguinity and unions between trees to prevent overlapping of individuals.
- No remarriages (might be added in a future version)
- No union between individuals at different generations (might be added in a future version)

*To be implemented :*
- Allow to pass CeTZ arguments to every elements to cutomize their appearance
- Draw optional legends for tree symbols and for phenotypes

= Usage
<sec-usage>

#example[```
#let geneal_example = genealogy_init()
#let geneal_example = add_persons(
    geneal_example,
    (
        "I1": (sex: "m", phenos: ("ill",)),
        "I2": (sex: "f"),
        "II1": (sex: "f", phenos: ("ill",)),
        "II1*": (sex: "m"),
        "II2": (sex: "f"),
        "II3": (sex: "f", phenos: ("ill",)),
        "II3*": (sex: "m"),
        "III1": (sex: "f", phenos: ("ill",)),
        "III1*": (sex: "m"),
        "III2": (sex: "f"),
        "III3": (sex: "m", phenos: ("ill",)),
        "III4": (sex: "f"),
        "IV1": (sex: "m"),
        "IV2": (sex: "m", phenos: ("ill",)),
        "IV3": (sex: "f", phenos: ("ill",)),
    )
)

#let geneal_example = add_unions(
    geneal_example,
    (("I1", "I2"), ("II1", "II2", "II3")),
    (("II1", "II1*"), ("III1",)),
    (("II3", "II3*"), ("III2", "III3", "III4")),
    (("III1", "III1*"), ("IV1", "IV2", "IV3"))
)
#canvas(length: 0.4cm, {
    // Draw the tree
    draw_tree(geneal_example)
})
```]

#pagebreak()

== Available commands
<sec-avail_comma>

#show-module("genealotree")

// == Customizing appearance
// <sec-custo_appea>

== Elements names in CeTZ
<sec-eleme_names_in>
This section documents CeTZ elements name, so you can use them in the canva to add manual modifications to the tree.
- persons symbol : persons name
- persons topline : persons name + "\_\_vt\_\_"
- persons botline : persons name + "\_\_vb\_\_"
- union horizontal line : first parents name + second parents name + "\_\_h\_\_" (parents name are sorted alphabetically)
- union vertical line (joining an union line with a siblings line) : first parents name + second parents name + "\_\_v\_\_" (parents name are sorted alphabetically)
- siblings line : first parents name + second parents name + "\_\_s\_\_" (parents name are sorted alphabetically)

#let geneal_showlines = genealogy_init()
#let geneal_showlines = add_persons(
    geneal_showlines,
    (
        "I1": (sex: "m"),
        "I2": (sex: "f"),
        "II1": (sex: "f"),
        "II2": (sex: "m"),
        "II3": (sex: "f"),
    )
)
#let geneal_showlines = add_unions(
    geneal_showlines,
    (("I1", "I2"), ("II1", "II2", "II3"))
)
#figure(
    [
        #canvas(length: 0.8cm, {
            draw_tree(geneal_showlines)
            content((name: "I1", anchor: "center"), [I1])
            content((name: "I2", anchor: "center"), [I2])
            content((name: "II1", anchor: "center"), [II1])
            content((name: "II2", anchor: "center"), [II2])
            content((name: "II3", anchor: "center"), [II3])
            line(
                (name: "I1" + "__vb__", anchor: 50%),
                (rel: (-4.25, 0)),
                name: "vb",
                stroke: (dash: "dashed")
            )
            mark((name: "vb", anchor: 0%), (rel: (0.1,0)), symbol: "circle", fill: black)
            content(
                (name: "vb", anchor: 100%),
                anchor: "east",
                padding: 0.1,
                [I1\_\_vb\_\_])
            line(
                (name: "II1" + "__vt__", anchor: 50%),
                (rel: (-2, 0)),
                name: "vt",
                stroke: (dash: "dashed")
            )
            mark((name: "vt", anchor: 0%), (rel: (0.1,0)), symbol: "circle", fill: black)
            content(
                (name: "vt", anchor: 100%),
                anchor: "east",
                padding: 0.1,
                [II1\_\_vt\_\_])
            line(
                (name: "I1I2" + "__v__", anchor: 50%),
                (rel: (-6, 0)),
                name: "uv",
                stroke: (dash: "dashed")
            )
            mark((name: "uv", anchor: 0%), (rel: (0.1,0)), symbol: "circle", fill: black)
            content(
                (name: "uv", anchor: 100%),
                anchor: "east",
                padding: 0.1,
                [I1I2\_\_v\_\_])
            line(
                (name: "I1I2" + "__h__", anchor: 75%),
                (rel: (0, -0.5)),
                name: "uh",
                stroke: (dash: "dashed")
            )
            line(
                (name: "uh", anchor: 100%),
                (rel: (3.5/4 + 4.25,0)),
                name: "uh2",
                stroke: (dash: "dashed")
            )
             mark((name: "uh", anchor: 0%), (rel: (0.1,0)), symbol: "circle", fill: black)
            content(
                (name: "uh2", anchor: 100%),
                anchor: "west",
                padding: 0.1,
                [I1I2\_\_h\_\_])
            line(
                (name: "I1I2" + "__s__", anchor: 75%),
                (rel: (0, 0.5)),
                name: "uh",
                stroke: (dash: "dashed")
            )
            line(
                (name: "uh", anchor: 100%),
                (rel: (4,0)),
                name: "uh2",
                stroke: (dash: "dashed")
            )
             mark((name: "uh", anchor: 0%), (rel: (0.1,0)), symbol: "circle", fill: black)
            content(
                (name: "uh2", anchor: 100%),
                anchor: "west",
                padding: 0.1,
                [I1I2\_\_s\_\_])
        })
        
    ],
    caption: [Elements names in CeTZ. Persons names are labelled at their center.]
)<fig-cetz_names>


// = Behavior
// <sec-behav>

// == Persons position in the tree
// <sec-perso_posit_in>

// == Width optimization
// <sec-width_optim>

// = Internals
// <sec-inter>
// == Calculating spacings between individuals
// <sec-calcu_spaci_betwe>
// #show-module("calc_functions")

// == Drawing functions
// <sec-drawi_funct>
// #show-module("draw_functions")
