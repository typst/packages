#import "@preview/pinit:0.1.4": *
#import "@preview/showybox:2.0.1": showybox as sb
#import "@preview/badgery:0.1.1" as bgy

// Copied from https://github.com/typst-doc-cn/tutorial/blob/main/src/mod.typ
#let exec-code(cc, res: none, scope: (:), eval: eval) = {

  rect(
    width: 100%,
    inset: 10pt,
    {
      // Don't corrupt normal headings
      set heading(outlined: false)

      if res != none {
        res
      } else {
        eval(cc.text, mode: "markup", scope: scope)
      }
    },
  )
}

// al: alignment
#let code(cc, code-as: none, res: none, scope: (:), eval: eval, exec-code: exec-code, al: left) = {
  let code-as = if code-as == none {
    cc
  } else {
    code-as
  }

  let vv = exec-code(cc, res: res, scope: scope, eval: eval)
  if al == left {
    layout(lw => style(styles => {
      let width = lw.width * 0.5 - 0.5em
      let u = box(width: width, code-as)
      let v = box(width: width, vv)

      let u-box = measure(u, styles)
      let v-box = measure(v, styles)

      let height = calc.max(u-box.height, v-box.height)
      stack(
        dir: ltr,
        {
          set rect(height: height)
          u
        },
        1em,
        {
          rect(height: height, width: width, inset: 10pt, vv.body)
        },
      )
    }))
  } else {
    code-as
    vv
  }
}

#let package = toml("./typst.toml").package
#let version = package.version

#let entry(name, type: "function") = {
  set box(inset: 0.3em, radius: 0.3em)
  box(fill: purple.transparentize(80%))[#raw(type)]
  box[#name]
}

#let nblx = [numblex]

#let positional = [#set text(size: 8pt);#box(bgy.badge-red("positional"), baseline: 30%)]
#let named = [#set text(size: 8pt);#box(bgy.badge-gray("named"), baseline: 30%)]

#let warning(doc) = {
  let warning_mark = [
    #place(horizon + center)[
      #polygon.regular(fill: none, stroke: 0.05em, vertices: 3, size: 1em)
    ]
    #place(horizon + center)[
      #v(0.16em)
      #set text(font: "Avenir Next", weight: "semibold", size: 0.5em)
      !
    ]
  ]
  sb(
    frame: (
      border-color: red.darken(50%),
      title-color: red.lighten(60%),
      body-color: red.lighten(80%),
    ),
    title-style: (
      color: black,
      weight: "regular",
      align: left,
    ),
    shadow: (
      offset: 3pt,
    ),
    title: stack(
      dir: ltr,
      spacing: 5pt,
      align(horizon, [#set text(size: 15pt);#h(10pt)#warning_mark]),
      [
        #set text(size: 14pt)
        Warning
      ],
    ),
    doc,
  )
}

// Manual content
#align(center)[#text(size: 24pt)[Numblex #version Manual]]

// #outline()

= Concepts

== Numbering

Numbering is just a function that takes a list of numbers and returns a string. And this function can be used as the value of the `numbering` option in Typst.

For example, the numbering function could return a string like this:

#align(center)[
  #set text(size: 16pt)
  #"<1-(3).4.>"
]

We can split the string into several parts, and each part is an element.

#align(center)[
  #let colors = (blue, green, yellow, red, purple, orange)
  #set text(size: 16pt)
  #(
    "< 1 - (3). 4. >".split(" ").zip(colors).map(x => box(
      inset: (bottom: 0.4em, top: 0.2em),
      fill: x.at(1).transparentize(60%),
    )[#x.at(0)])
  ).join([])
]

== Element

The elements are categorized into two types: ordinals and constants. Here "<", "-", ">" are constants, and "1", "(3).", "4." are ordinals.

We use the following format to represent the whole numbering

== Numbering String

The Typst official numbering string is not powerful enough, we usually need to set the numbering to a custom function to implement more complex numbering. However, this leads to redundancy. We define a new format to represent the numbering.

#align(center)[
  #set text(size: 16pt)
  `{<} {[1]} {-} {([3]).} {[4].} {>}`
]

Each element is enclosed in a pair of curly braces(`{}`), and anything else is ignored. The element can be a constant(with no `[]` in it) or an ordinal(with `[]` in it). The ordinal element is only displayed when the depth is enough.

== Patterns

Patterns are used to represent the ordinal or constant. The ordinal will be replaced by the final ordinal string in the output numbering, and anything outside the `[]` will be kept as it is.

#align(center)[
  #set text(size: 16pt)
  `{Chapter [1].}` $=>$ Chapter 1.
]

Of course, this is designed to avoid the following problem:

#code(```Typst
#set heading(numbering: "Chapter 1.")
= Once Upon a Time
#set heading(numbering: "Ch\apter 1.")
= Once Upon a Time
```)

== Ordinals

Most of the time, you can just put the character corresponding to the ordinal you want in the `[]`. #nblx passes the character to the `numbering` function in Typst to get the ordinal.

However, #nblx has also modified and extended the ordinal definition.

- `[]`: an empty string, it takes the number but generates nothing.
- `[(1)]`: shorthand for circled numbers (①, ②, ③, ...). If you want the ordinal (1), (2), (3), ..., please use `{([1])}` instead.

_Use single character to represent the ordinal if possible, since Typst have complicated rules to handle the prefix and suffix of the numbering._

The element can be different in different contexts. For example, we might need them to show up in different forms according to the depth.

== Conditions

Conditions are functions that take the current numbering configuration and return a boolean value. The condition match is executed sequentially, and the first match will be used.

Currently the following configuration context are defined:

=== depth: `int` (short: `d`)

The depth of the numbering.

From Typst v0.11.1 on, we can use heading.depth to get the depth of the heading. Similarly, we introduce the numbering depth, which is the length of the list of numbers passed to the numbering function.

#warning[
  The condition here is implemented using `eval`, which is not safe and might cause other problems.
]

You may represent a conditional element using the following format:

#align(center)[
  #set text(size: 16pt)
  `{PAT_1:COND_1;PAT_2:COND_2;...}`
]

Leave the condition empty is equivalent to `true`.

#align(center)[
  #set text(size: 16pt)
  `{PAT_1:COND_1;PAT_2}` $equiv$ `{PATTERN_1:COND_1;PAT_2:true}`
]

If no condition is matched, the element will return an empty string. _Notice that `[]` must appear in none(constant element) or all(ordinal element) of the patterns._

== Examples

#import "./lib.typ": numblex

#code(
  ```Typst
  #set heading(numbering: numblex("{Section [A].:d==1;[A].}{[1].}{[1])}"))
  = Electrostatic Field
  == Introduction
  === Gauss's Law
  ```,
  scope: (numblex: numblex),
)

#code(
  ```Typst
  #set heading(numbering: numblex("{[一]、:d==1}{[1].:d==2}{[(1)]}"))
  = 保角变换
  == 介绍
  === 调和函数的保角性
  ```,
  scope: (numblex: numblex),
)

#code(
  ```Typst
  #let example = numblex("{<} {[1]} {-:d>=2} {([1]).} {[1].} {>}")
  #numbering(example, 1) \
  #numbering(example, 1, 3) \
  #numbering(example, 1, 3, 4)
  ```,
  scope: (numblex: numblex),
)

= Reference

#show heading.where(level: 2): entry

The package provides a function `numblex` to generate the numbering function for Typst.

== `numblex`

=== Parameters

- #positional `s`
- #named `..options`

= Known Issues & Limitations

+ Automatic repeating (which Typst official numbering supports) is not supported yet.

+ Character escaping for "{}[]:;" is not supported yet.
