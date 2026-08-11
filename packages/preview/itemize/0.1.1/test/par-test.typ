#import "@preview/itemize:0.1.1" as el
#set page(width: 350mm, height: auto, margin: 25pt)
#let ex1 = [
  + #lorem(16)
  + #lorem(16)

    #lorem(16)
    + #lorem(16)
    + #lorem(16)

      #lorem(16)
      + #lorem(16)

        #lorem(16)
      #lorem(16)
      + #lorem(16)
    + #lorem(16)
  + #lorem(16)
  - #lorem(16)

    #lorem(16)
    - #lorem(16)
    - #lorem(16)
      - #lorem(16)

        #lorem(16)

      #lorem(16)
      - #lorem(16)
  + #lorem(16)
    - #lorem(16)

      #lorem(16)
    - #lorem(16)
  + #lorem(16)
  + + - - + #lorem(16)
]
#[
  #table(
    columns: (1fr, 1fr),
    [
      default-type
      ```typ
      #set enum(numbering: "(A).(I).(i)", full: true)
      #set par(first-line-indent: 2em)
      #show: el.default-enum-list
      ```
    ],
    [
      paragraph-type
      ```typ
      #set enum(numbering: "(A).(I).(i)", full: true)
      #set par(first-line-indent: 2em)
      #show: el.paragraph-enum-list
      ```
    ],

    [
      #set enum(numbering: "(A).(I).(i)", full: true)
      #set par(first-line-indent: 2em)
      #show: el.default-enum-list
      #ex1
    ],
    [
      #set enum(numbering: "(A).(I).(i)", full: true)
      #set par(first-line-indent: 2em)
      #show: el.paragraph-enum-list
      #ex1
    ],
  )
]

= costom hanging-indent and line-indent

#[
  #table(
    columns: (1fr, 1fr),
    [
      default-type
      ```typ
      #set enum(numbering: "(A).(I).(i)", full: true)
      #set par(first-line-indent: 3em, hanging-indent: 1em)
      #show: el.default-enum-list.with(line-indent: (1em, 0em, auto), hanging-indent: (auto, -1em, auto))
      ```
    ],
    [
      paragraph-type
      ```typ
      #set enum(numbering: "(A).(I).(i)", full: true)
      #set par(first-line-indent: 3em, hanging-indent: 1em)
      #show: el.paragraph-enum-list.with(line-indent: (1em, 0em, auto), hanging-indent: (auto, -1em, auto))
      ```
    ],

    [
      #set enum(numbering: "(A).(I).(i)", full: true)
      #set par(first-line-indent: 3em, hanging-indent: 1em)
      #show: el.default-enum-list.with(line-indent: (1em, 0em, auto), hanging-indent: (auto, -1em, auto))
      #ex1
    ],
    [
      #set enum(numbering: "(A).(I).(i)", full: true)
      #set par(first-line-indent: 3em, hanging-indent: 1em)
      #show: el.paragraph-enum-list.with(line-indent: (1em, 0em, auto), hanging-indent: (auto, -1em, auto))
      #ex1
    ],
  )
]

= `indent` and `label-indent`
#[

  #let test1 = [
    + #lorem(16)
      + #lorem(16)
      + #lorem(16)

        #lorem(16)
        + #lorem(16)
      - #lorem(16)
      - #lorem(16)
    + #lorem(16)
  ]
  #table(
    columns: (1fr, 1fr),
    [
      indent
      ```typ
      #show: el.paragraph-enum-list.with(indent: 1em)
      ```
    ],
    [
      label-indent
      ```typ
      #show: el.paragraph-enum-list.with(label-indent: 1em)
      ```
    ],

    [
      #show: el.paragraph-enum-list.with(indent: 1em)
      #test1
    ],
    [
      #show: el.paragraph-enum-list.with(label-indent: 1em)
      #test1
    ],
  )
]



