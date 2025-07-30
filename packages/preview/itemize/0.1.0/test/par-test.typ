#import "@preview/itemize:0.1.0" as el
#set page(width: 350mm, height: auto, margin: 25pt)
#[
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
      - #lorem(16)
      - #lorem(16)
        - #lorem(16)
        - #lorem(16)
    + #lorem(16)
      - #lorem(16)

        #lorem(16)
      - #lorem(16)
    + #lorem(16)
    + + - - + #lorem(16)
  ]
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
      paragraph-typ
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
