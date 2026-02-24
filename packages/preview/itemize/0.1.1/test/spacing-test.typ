#import "@preview/itemize:0.1.1" as el
#set page(width: 350mm, height: auto, margin: 25pt) //,
= spacing test

#let spacing-test-0 = [
  #lorem(20)
  + #lorem(40)
  + #lorem(20)
    + #lorem(20)

      #lorem(20)
    + #lorem(20)
  + #lorem(20)
  + #lorem(20)

  + #lorem(20)
  #lorem(20)
]
#[

  #set par(spacing: 3em, leading: 1em)
  #set enum(numbering: "(1).(A).(i)", spacing: 2em) //spacing: 1em,
  // #show enum: it => {
  //   set enum(indent: 0em)
  //   it
  // }
  #table(
    columns: (1fr, 1fr),
    [tight false], [tight false],
    [
      #spacing-test-0
    ],
    [
      #show: el.default-enum-list
      #spacing-test-0
    ],
  )
]

#let spacing-test-1 = [
  #lorem(20)
  + #lorem(40)
  + #lorem(20)
    + #lorem(20)

      #lorem(20)
    + #lorem(20)
  + #lorem(20)
  + #lorem(20)
  + #lorem(20)
  #lorem(20)
]
#[

  #set par(spacing: 3em, leading: 1em)
  #set enum(numbering: "(1).(A).(i)", spacing: 2em) //spacing: 1em,
  #table(
    columns: (1fr, 1fr),
    [tight true], [tight true],
    [
      #spacing-test-1
    ],
    [
      #show: el.default-enum-list
      #spacing-test-1
    ],
  )
]


#let spacing-test-not = [
  #lorem(20)

  + #lorem(40)
  + #lorem(20)

    + #lorem(20)
      #lorem(20)
    + #lorem(20)
  + #lorem(20)
  #lorem(20)
]
#[
  ```typ
    #set par(spacing: 3em, leading: 1em)
    #set enum(numbering: "(1).(A).(i)", spacing: 2em)
    #let spacing-test-not = [
      #lorem(20) // 此处断行,typst会把将第一个项目列表的上边距设为par.spacing, 但tight为false

      + #lorem(40)
      + #lorem(20) // 此处断行,typst会把将第一个项目列表的上边距设为par.spacing, 但tight为false

        + #lorem(20)
          #lorem(20)
        + #lorem(20)
      + #lorem(20)
      + #lorem(20)
      + #lorem(20)
      #lorem(20)
  ]
    #table(
      columns: (1fr, 1fr),
      [original], [do not work],
      [
        #spacing-test-not
      ],
      [
        #show: el.default-enum-list
        #show enum: set block(stroke: 1pt + red)
        #spacing-test-not
      ],
    )
  ```


  #set par(spacing: 3em, leading: 1em)
  #set enum(numbering: "(1).(A).(i)", spacing: 2em) //spacing: 1em,
  #table(
    columns: (1fr, 1fr),
    [origin], [do not display as the original one],
    [
      #spacing-test-not
    ],
    [
      #show: el.default-enum-list
      #spacing-test-not
    ],
  )
]



= custom spacing test

#let spacing-test-2 = [
  #lorem(20)

  + #lorem(40)
  + #lorem(20)

    + #lorem(20)

      #lorem(20)
    + #lorem(20) $vec(1, 1, 1, 1)$
    + #lorem(20)

    #lorem(20)
  + #lorem(20)
  + #lorem(20)
  + #lorem(20)
  #lorem(20)
]

#let spacing-test-21 = [
  #lorem(10)
  + #lorem(40)
  + //#lorem(20)

    + #lorem(20)

      #lorem(20)
    + #lorem(20) $vec(1, 1, 1, 1)$

  // #lorem(20)
  + #lorem(20)
  + #lorem(20)
  + #lorem(20)
  #lorem(20)
]


#table(
  inset: 10pt,
  columns: (1fr, 1fr),
  [
    enum spacing
    ```typ
    #show: el.default-enum-list.with(enum-spacing: (3em, (above: 2em, below: auto)))
    #show enum: set block(fill: yellow.lighten(50%), stroke: 1pt + green)
    ```
  ],
  [
    item spacing
    ```typ
    #show: el.default-enum-list.with(item-spacing: (3em, 1.5em))
    #show enum: set block(fill: gray.lighten(50%), stroke: 1pt + blue)
    ```
  ],

  [
    #show: el.default-enum-list.with(enum-spacing: (3em, (above: 2em, below: auto)))
    #show enum: set block(fill: yellow.lighten(50%), stroke: 1pt + green)
    #spacing-test-2
  ],
  [
    #show: el.default-enum-list.with(item-spacing: (3em, 1.5em))
    #show enum: set block(fill: gray.lighten(50%), stroke: 1pt + blue)
    #spacing-test-2
  ],

  [
    #show: el.default-enum-list.with(enum-spacing: (3em, (above: 2em, below: auto)))
    #show enum: set block(fill: yellow.lighten(50%), stroke: 1pt + green)
    #spacing-test-21
  ],
  [
    #show: el.default-enum-list.with(item-spacing: (3em, 1.5em))
    #show enum: set block(fill: gray.lighten(50%), stroke: 1pt + blue)
    #spacing-test-21
  ],
)


= custom margin test
#let margin-enum-test = [
  #lorem(20)
  + #lorem(40)
  + #lorem(20)
    + #lorem(20)
      #lorem(20)
    + #lorem(20)
      + #lorem(5)
      + #lorem(5)
    + #lorem(10)
  + #lorem(20)
  #lorem(20)
]
#let margin-list-test = [
  #lorem(20)
  - #lorem(40)
  - #lorem(20)
    - #lorem(20)
      #lorem(20)
    - #lorem(20)
      - #lorem(5)
      - #lorem(5)
    - #lorem(10)
  - #lorem(20)
  #lorem(20)
]
#[


  #table(
    columns: (1fr, 1fr),
    [
      enum margin
      ```typ
      #set enum(numbering: "(1).(A).(i)")
      #show: el.default-enum-list.with(enum-margin: (0em, 30%, auto), is-full-width: false)
      #show enum: it => {
        block(stroke: 1pt + red, inset: 5pt, it)
      }
      ```
    ],
    [
      list margin
      ```typ
      #show: el.default-enum-list.with(enum-margin: (0em, 30%, auto), is-full-width: false)
      #show list: it => {
        block(stroke: 1pt + blue, inset: 5pt, it)
      }
      ```
    ],

    [
      #set enum(numbering: "(1).(A).(i)")

      #show: el.default-enum-list.with(enum-margin: (0em, 30%, auto), is-full-width: false)
      #show enum: it => {
        block(stroke: 1pt + red, inset: 5pt, it)
      }
      #margin-enum-test
    ],
    [
      #show: el.default-enum-list.with(enum-margin: (0em, 30%, auto), is-full-width: false)
      #show list: it => {
        block(stroke: 1pt + blue, inset: 5pt, it)
      }
      #margin-list-test
    ],
  )
]

= using function
#[
  #let ex1 = [
    + #lorem(16)
    + #lorem(16)
      + #lorem(16)
      + #lorem(16)
        + #lorem(16)
          + #lorem(16)
        + #lorem(16)
    + #lorem(16)
    - #lorem(16)
      - #lorem(16)
      - #lorem(16)
        - #lorem(16)
        - #lorem(16)
  ]
  #table(
    columns: (1fr, 1fr),
    [
      original
      ```typ
      #set enum(numbering: "(A).(I).(i)", full: true, number-align: left)
      ```
    ],
    [
      using indent
      ```typ
      #set enum(numbering: "(A).(I).(i)", full: true, number-align: left)
      #let indent-f = (level, label-width, level-type) => {
        if level >= 2 {
          -(label-width.get)(level - 1) - (level-type.get)(level - 1).body-indent
        }
      }
      #show: el.default-enum-list.with(indent: indent-f)
      ```
    ],

    [
      #set enum(numbering: "(A).(I).(i)", full: true, number-align: left)
      #ex1
    ],
    [
      #set enum(numbering: "(A).(I).(i)", full: true, number-align: left)
      #let indent-f = (level, label-width, level-type) => {
        if level >= 2 {
          -(label-width.get)(level - 1) - (level-type.get)(level - 1).body-indent
        }
      }
      #show: el.default-enum-list.with(indent: indent-f)
      #ex1
    ],
  )
]



