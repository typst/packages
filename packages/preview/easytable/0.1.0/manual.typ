#import "@preview/tidy:0.2.0"
#import "src/lib.typ": easytable, elem
#import elem: *

#let example_result(body) = block(stroke: 0.5pt + luma(80%), inset: 10pt, breakable: false, body)

#let example(code, result) = grid(columns: 2, column-gutter: 5pt, {
  set block(breakable: false)
  code
}, example_result(result))

#set par(justify: true)

// #set text(font: "Noto Serif CJK JP")
#show heading: set text(font: "Noto Sans CJK JP")

#show heading: set pad(bottom: 2em)
#set heading(numbering: "1.")

#show raw.where(block: false): box.with(
  fill: black.lighten(95%),
  inset: (x: 2pt, y: 0pt),
  outset: (x: 0pt, y: 2pt),
  radius: 1.5pt,
)

#show raw.where(block: true, lang: "typst"): block.with(
  width: 100%,
  fill: black.lighten(95%),
  inset: (x: 8pt, y: 6pt),
  radius: (top-left: 6pt, bottom-right: 6pt, rest: 0pt),
)

#align(center)[
  #text(size: 2em, [Typst-Easytable Package])

  version: 0.1.0

  #datetime.today().display()
]

#outline(title: "Outline", indent: 1em, depth: 3)

= Overview

`typst-easytable` is a simple package for writing tables in Typst.

== Goal of `typst-easytable`

- Concise, highly visible markup
- Some degree of flexibility, versatility

== Non-Goal of `typst-easytable`

- Features that are not needed for most applications

= Usage

```typst
#import "@preview/easytable:0.1.0": easytable, elem
```

== A Simple Table

Simple tables can be described simply.

#example[
```typst
#easytable({
  elem.tr[How      ][I      ][want      ]
  elem.tr[a        ][drink, ][alcoholic ]
  elem.tr[of       ][course,][after     ]
  elem.tr[the      ][heavy  ][lectures  ]
  elem.tr[involving][quantum][mechanics.]
})
```
][
  #easytable({
    elem.tr[How ][I ][want ]
    elem.tr[a ][drink, ][alcoholic]
    elem.tr[of ][course,][after ]
    elem.tr[the ][heavy ][lectures ]
    elem.tr[involving][quantum][mechanics.]
  })
]

`elem.tr` is a function representing data element in the `elem` module.
To add a table header, use the `elem.th` function. It represents header element.

#example[
```typst
#easytable({
  elem.th[Header 1 ][Header 2][Header 3  ]
  elem.tr[How      ][I       ][want      ]
  elem.tr[a        ][drink,  ][alcoholic ]
  elem.tr[of       ][course, ][after     ]
  elem.tr[the      ][heavy   ][lectures  ]
  elem.tr[involving][quantum ][mechanics.]
})
```
][
  #easytable({
    elem.th[Header 1 ][Header 2][Header 3 ]
    elem.tr[How ][I ][want ]
    elem.tr[a ][drink, ][alcoholic ]
    elem.tr[of ][course, ][after ]
    elem.tr[the ][heavy ][lectures ]
    elem.tr[involving][quantum ][mechanics.]
  })
]

If you feel tedious to write `elem.*`, you can omit it by writing as follows:

```typst
// If you don't care having functions such as `th` and `tr` in global namespace,
// it is easiest to write the import statement here!
#import elem: *

#easytable({
  // If you care, please state the following for each table.
  // import elem: *
  tr[How      ][I      ][want      ]
  tr[a        ][drink, ][alcoholic ]
  tr[of       ][course,][after     ]
  tr[the      ][heavy  ][lectures  ]
  tr[involving][quantum][mechanics.]
})
```

We will omit `import elem: *` in examples hereafter.

The argument of `elem.tr` is variadic, i.e., you can easily create tables with any number of columns.

#example[
#set text(size: 0.9em)
```typst
#easytable({
  vline(x: 1, stroke: 0.5pt)
  cstyle(..(center,) * 7)

  th[$*$][$e$][$r$][$r^2$][$s$][$r s$][$r^2s$]
  tr[$e$][$e$][$r$][$r^2$][$s$][$r s$][$r^2s$]
  tr[$r$][$r$][$r^2$][$e$][$r s$][$r^2s$][$s$]
  tr[$r^2$][$r^2$][$e$][$r$][$r^2s$][$s$][$r s$]
  tr[$s$][$s$][$r^2s$][$r s$][$e$][$r^2$][$r$]
  tr[$r s$][$r s$][$s$][$r^2s$][$r$][$e$][$r^2$]
  tr[$r^2s$][$r^2s$][$r s$][$s$][$r^2$][$r$][$e$]
})
```
][
  #easytable({
    vline(x: 1, stroke: 0.5pt)
    cstyle(..(center,) * 7)

    th[$*$][$e$][$r$][$r^2$][$s$][$r s$][$r^2s$]
    tr[$e$][$e$][$r$][$r^2$][$s$][$r s$][$r^2s$]
    tr[$r$][$r$][$r^2$][$e$][$r s$][$r^2s$][$s$]
    tr[$r^2$][$r^2$][$e$][$r$][$r^2s$][$s$][$r s$]
    tr[$s$][$s$][$r^2s$][$r s$][$e$][$r^2$][$r$]
    tr[$r s$][$r s$][$s$][$r^2s$][$r$][$e$][$r^2$]
    tr[$r^2s$][$r^2s$][$r s$][$s$][$r^2$][$r$][$e$]
  })
]

Please be careful, the number of arguments to `th` and `tr` (and `cstyle` and `cwidth`, described below) elements must be consistent within a table. If not, the Typst processor throws an error.
Conversely, there is no need to worry about forgetting to put a cell and not noticing that the layout is broken.

== Changing Alignment and Width of Columns

To change the alignment for each column, use `cstyle`:

#example[
```typst
#easytable({
  cstyle(left, center, right)
  th[Header 1 ][Header 2][Header 3  ]
  tr[How      ][I       ][want      ]
  tr[a        ][drink,  ][alcoholic ]
  tr[of       ][course, ][after     ]
  tr[the      ][heavy   ][lectures  ]
  tr[involving][quantum ][mechanics.]
})
```
][
  #easytable({
    cstyle(left, center, right)
    th[Header 1 ][Header 2][Header 3 ]
    tr[How ][I ][want ]
    tr[a ][drink, ][alcoholic ]
    tr[of ][course, ][after ]
    tr[the ][heavy ][lectures ]
    tr[involving][quantum ][mechanics.]
  })
]

What if I want to change the length of each column? Use `cwidth`:

```typst
#easytable({
  cwidth(100pt, 1fr, 20%)
  th[Header 1 ][Header 2][Header 3  ]
  tr[How      ][I       ][want      ]
  tr[a        ][drink,  ][alcoholic ]
  tr[of       ][course, ][after     ]
  tr[the      ][heavy   ][lectures  ]
  tr[involving][quantum ][mechanics.]
})
```
#example_result[
  #easytable({
    cwidth(100pt, 1fr, 20%)
    th[Header 1 ][Header 2][Header 3 ]
    tr[How ][I ][want ]
    tr[a ][drink, ][alcoholic ]
    tr[of ][course, ][after ]
    tr[the ][heavy ][lectures ]
    tr[involving][quantum ][mechanics.]
  })
]

It is of course possible to use `cstyle` and `cwidth` in combination.

```typst
#easytable({
  cwidth(100pt, 1fr, 20%)
  cstyle(left, center, right)
  th[Header 1 ][Header 2][Header 3  ]
  tr[How      ][I       ][want      ]
  tr[a        ][drink,  ][alcoholic ]
  tr[of       ][course, ][after     ]
  tr[the      ][heavy   ][lectures  ]
  tr[involving][quantum ][mechanics.]
})
```

#example_result[
  #easytable({
    cwidth(100pt, 1fr, 20%)
    cstyle(left, center, right)
    th[Header 1 ][Header 2][Header 3 ]
    tr[How ][I ][want ]
    tr[a ][drink, ][alcoholic ]
    tr[of ][course, ][after ]
    tr[the ][heavy ][lectures ]
    tr[involving][quantum ][mechanics.]
  })
]

It is also possible to write long content that spans multiple lines.

```typst
#easytable({
  cwidth(auto, 50%)
  cstyle(right, left)
  th[Term][Long Description]
  tr[*LaTeX*][A great typesetting system. May be difficult to learn.]
  tr([*Typst*], [
    A great typesetting system! Specifically, it offers the following advantages:

    - Very easy to install
    - Very easy to learn

    We encourage everyone to use it.
  ])
})
```

#example_result[
  #easytable(
    {
      cwidth(auto, 50%)
      cstyle(right, left)
      th[Term][Long Description]

      tr[*LaTeX*][A great typesetting system. May be difficult to learn.]

      tr(
        [*Typst*],
        [
          A great typesetting system! Specifically, it offers the following advantages:

          - Very easy to install
          - very easy to learn

          We encourage everyone to use it.
        ],
      )
    },
  )
]

== Customizing Element

Element `tr` has an keyword argument `trans`, which can be used to customize the layout of a particular line.

#example[
```typst
#easytable({
  let tr2 = tr.with(trans: emph)
  let tr3 = tr.with(
    trans: (c) => box(fill: blue, inset: 3pt, text(size: 0.8em, fill: white, c)),
  )

  th[Header 1][Header 2][Header 3]
  tr[How][I][want]
  tr2[a][drink,][alcoholic]
  tr[of][course,][after]
  tr3[the][heavy][lectures]
  tr[involving][quantum][mechanics.]
})
```
][
  #easytable(
    {
      let tr2 = tr.with(trans: emph)
      let tr3 = tr.with(
        trans: (c) => box(fill: blue, inset: 3pt, text(size: 0.8em, fill: white, c)),
      )
      th[Header 1][Header 2][Header 3]
      tr[How][I][want]
      tr2[a][drink,][alcoholic]
      tr[of][course,][after]
      tr3[the][heavy][lectures]
      tr[involving][quantum][mechanics.]
    },
  )
]

If you want to assign a common layout to all rows, you can override the definition of `tr` itself locally.

#example[
```typst
#easytable(
  {
    let tr = tr.with(trans: pad.with(x: 3pt))

    th[Header 1][Header 2][Header 3]
    tr[How][I][want]
    tr[a][drink,][alcoholic]
    tr[of][course,][after]
    tr[the][heavy][lectures]
    tr[involving][quantum][mechanics.]
  },
)
```
][
  #easytable({
    let tr = tr.with(trans: pad.with(y: 3pt))

    th[Header 1 ][Header 2][Header 3 ]
    tr[How ][I ][want ]
    tr[a ][drink, ][alcoholic ]
    tr[of ][course, ][after ]
    tr[the ][heavy ][lectures ]
    tr[involving][quantum ][mechanics.]
  })
]

Use the `cell_style` argument to change the background color.

#example[
```typst
#easytable({
  let th = th.with(trans: emph)
  let tr = tr.with(
    cell_style: (x: none, y: none)
      => (fill: if calc.even(y) {
        luma(95%)
      } else {
        none
      })
  )

  th[Header 1][Header 2][Header 3]
  tr[How][I][want]
  tr[a][drink,][alcoholic]
  tr[of][course,][after]
  tr[the][heavy][lectures]
  tr[involving][quantum][mechanics.]
})
```
][
  #easytable({
    let th = th.with(trans: emph)
    let tr = tr.with(cell_style: (x: none, y: none)
    => (fill: if calc.even(y) {
      luma(95%)
    } else {
      none
    }))

    th[Header 1][Header 2][Header 3]
    tr[How][I][want]
    tr[a][drink,][alcoholic]
    tr[of][course,][after]
    tr[the][heavy][lectures]
    tr[involving][quantum][mechanics.]
  })
]

With `hline` you can draw a horizontal line at any position. The same goes for `vline`.

#example[
```typst
#easytable({
  th[Header 1][Header 2][Header 3]
  tr[How][I][want]
  hline(stroke: red)
  tr[a][drink,][alcoholic]
  tr[of][course,][after]
  tr[the][heavy][lectures]
  tr[involving][quantum][mechanics.]

  // Specifying the insertion point directly
  hline(stroke: 2pt + green, y: 4)
  vline(
    stroke: (paint: blue, thickness: 1pt, dash: "dashed"),
    x: 2,
    start: 1,
    end: 5,
  )
})
```
][
  #easytable({
    th[Header 1][Header 2][Header 3]
    tr[How][I][want]
    hline(stroke: red)
    tr[a][drink,][alcoholic]
    tr[of][course,][after]
    tr[the][heavy][lectures]
    tr[involving][quantum][mechanics.]

    // Specifying the insertion point directly
    hline(stroke: 2pt + green, y: 4)
    vline(
      stroke: (paint: blue, thickness: 1pt, dash: "dashed"),
      x: 2,
      start: 1,
      end: 5,
    )
  })
]

== Customizing Column Style

Use `cstyle`.
The `cstyle` function accepts a function as well as an alignment as its argument.

#example[
```typst
#easytable({
  let show_tag(c) = box(
    fill: red.darken(60%),
    inset: (x: 2pt),
    outset: (y: 2pt),
    text(fill: white, size: 0.8em, c),
  )

  cstyle(left, center, left)
  th[Header 1][Header 2][Header 3]

  // Change style from the middle of the table
  cstyle(left, center, show_tag)
  tr[How][I][want]
  tr[a][drink,][alcoholic]
  tr[of][course,][after]
  tr[the][heavy][lectures]
  tr[involving][quantum][mechanics.]
})
```
][
  #easytable({
    let show_tag(c) = box(
      fill: red.darken(60%),
      inset: (x: 2pt),
      outset: (y: 2pt),
      text(fill: white, size: 0.8em, c),
    )

    cstyle(left, center, left)
    th[Header 1][Header 2][Header 3]

    // Change style from the middle of the table
    cstyle(left, center, show_tag)
    tr[How][I][want]
    tr[a][drink,][alcoholic]
    tr[of][course,][after]
    tr[the][heavy][lectures]
    tr[involving][quantum][mechanics.]
  })
]

