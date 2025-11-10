#import "@preview/itemize:0.1.2" as el
#set page(width: 350mm, height: auto, margin: 25pt) //,
= constom label

#let simple-test2 = [
  + #lorem(5)
    + $vec(1, 1, 1, 1)$ #lorem(5)
    + #lorem(5)
    - #lorem(5)

    - #lorem(5)
  + - + - + #lorem(5)
  + #lorem(5)
    - $vec(1, 1, 1, 1)$ #lorem(5)
      - #lorem(5)
      - #lorem(5)
        + #lorem(5)
        + #lorem(5)
      + #lorem(5)
        - #lorem(5)
          - #lorem(5)
      + #lorem(5)
        #lorem(20)
  + - - + + #lorem(5)
]
#set enum(numbering: "(1).(a).(i)")
#table(
  columns: (1fr, 1fr),
  [
    ```typ
    #set enum(numbering: "(1).(a).(i)")
    #show enum: el.default-enum.with(
      fill: (red, blue, green),
      weight: "bold",
    )
    #show list: el.default-list.with(fill: (yellow, orange))
    ```
  ],
  [
    ```typ
    #set enum(numbering: "(1).(a).(i)")
    #show: el.default-enum-list.with(
      fill: (red, blue, green, yellow, orange),
      weight: "bold",
    )
    ```],

  [
    #show enum: el.default-enum.with(
      fill: (red, blue, green),
      weight: "bold",
    )
    #show list: el.default-list.with(fill: (yellow, orange))
    #simple-test2
  ],
  [
    #show: el.default-enum-list.with(
      fill: (red, blue, green, yellow, orange),
      weight: "bold",
    )
    #simple-test2
  ],
)


#[
  #show: el.default-enum-list.with(
    fill: (blue, auto, green, auto),
    size: 25pt,
    weight: auto,
  )
  #let test-c = [
    + #lorem(5)
      + #lorem(5)
      + #lorem(5)
        + #lorem(5)
        - #lorem(5)
          - #lorem(5)
          - #lorem(5)
    + #lorem(5)
  ]

  #table(
    columns: (1fr, 1fr),
    [
      ```typ
      #show: el.default-enum-list.with(
        fill: (blue, auto, green, auto),
        size: 25pt,
        weight: auto,
      )
      #set text(fill: red, weight: "bold", size: 15pt)
      ```
    ],
    [
      ```typ
      #show: el.default-enum-list.with(
        fill: (blue, auto, green, auto),
        size: 25pt,
        weight: auto,
      )
      #set text(fill: black, weight: "thin", size: 15pt)
      ```
    ],

    [
      #show: el.default-enum-list.with(
        fill: (blue, auto, green, auto),
        size: 25pt,
        weight: auto,
      )
      #set text(fill: red, weight: "bold", size: 15pt)
      #test-c
    ],
    [
      #show: el.default-enum-list.with(
        fill: (blue, auto, green, auto),
        size: 25pt,
        weight: auto,
      )
      #set text(fill: black, weight: "thin", size: 15pt)
      #test-c
    ],
  )
]
== using `numbering` of `enum` to custom
#let test2 = [
  + #lorem(50)
  + #lorem(5) $mat(1, 0, 0; 0, 1, 0; 0, 0, 1)$
    + #lorem(20)
      + #lorem(10)
      + #lorem(10)
    + #lorem(20)
  + #lorem(20)
]
#[

  ```typ
  #show: el.default-enum-list
  #let ff = (..num) => {
    if el.level() == 1 {
      text(size: 20pt, fill: blue, weight: "bold", numbering("A.", ..num))
    } else if el.level() == 2 {
      numbering("a)", ..num)
    } else {
      text(fill: red, numbering("(1).", ..num))
    }
  }

  #set enum(numbering: ff, full: false)

  + #lorem(50)
  + #lorem(5) $mat(1, 0, 0; 0, 1, 0; 0, 0, 1)$
    + #lorem(20)
      + #lorem(10)
      + #lorem(10)
    + #lorem(20)
  + #lorem(20)
  ```
  #show: el.default-enum-list
  #let ff = (..num) => {
    if el.level() == 1 {
      text(size: 20pt, fill: blue, weight: "bold", numbering("A.", ..num))
    } else if el.level() == 2 {
      numbering("a)", ..num)
    } else {
      text(fill: red, numbering("(1).", ..num))
    }
  }

  #set enum(numbering: ff, full: false)

  #test2
]

#[
  ```typ
  #show: el.default-enum-list
  #let ff = (..num) => {
    if el.level() == 1 {
      let first = box(stroke: 1pt + blue, inset: 5pt, text(size: 20pt, fill: blue, weight: "bold", numbering(
        "A",
        ..num,
      )))
      let (height,) = measure(first)
      move(dy: height / 3, first)
    } else if el.level() == 2 {
      numbering("(A).(a)", ..num)
    } else {
      text(fill: red, numbering("(A).(a).(1)", ..num))
    }
  }

  #set enum(numbering: ff, full: false)

  + #lorem(50)
  + #lorem(5) $mat(1, 0, 0; 0, 1, 0; 0, 0, 1)$
    + #lorem(20)
      + #lorem(10)
      + #lorem(10)
    + #lorem(20)
  + #lorem(20)
  ```
  #show: el.default-enum-list
  #let ff = (..num) => {
    if el.level() == 1 {
      let first = box(stroke: 1pt + blue, inset: 5pt, text(size: 20pt, fill: blue, weight: "bold", numbering(
        "A",
        ..num,
      )))
      let (height,) = measure(first)
      move(dy: height / 3, first)
    } else if el.level() == 2 {
      numbering("(A).(a)", ..num)
    } else {
      text(fill: red, numbering("(A).(a).(1)", ..num))
    }
  }

  #set enum(numbering: ff, full: true)

  #test2
]

=== for fun
#[
  ```typ
  #import emoji: *
  #show: el.default-enum-list

  #let emoji = (alien, book.orange, butterfly, cloud.storm)
  #let ff = (..num) => context {
    set text(fill: red)
    let count = el.level-count()
    let n = count.last()
    let level = count.len()
    if level == 1 {
      if n in range(3) {
        numbering("1.", ..num)
      } else {
        numbering("A.", n - 2)
      }
    } else if level == 2 {
      emoji.at(calc.rem(n, emoji.len()) - 1)
    } else {
      numbering("a)", ..num)
    }
  }
  #set enum(numbering: ff)
  ```
  #import emoji: *
  #show: el.default-enum-list

  #let emoji = (alien, book.orange, butterfly, cloud.storm)
  #let ff = (..num) => context {
    set text(fill: red)
    let count = el.level-count()
    let n = count.last()
    let level = count.len()
    if level == 1 {
      if n in range(3) {
        numbering("1.", ..num)
      } else {
        numbering("A.", n - 2)
      }
    } else if level == 2 {
      emoji.at(calc.rem(n, emoji.len()) - 1)
    } else {
      numbering("a)", ..num)
    }
  }
  #set enum(numbering: ff)
  + 123
  + 234
  + ddd
  + fff
  + gggg
    + 111
    + 123
      + ddd
      + 111
    + aaa
    + fff
    + dddd
  + dddd
    + 123
    + aaa
]

== using `marker` of `list` to custom

#[
  ```typ
  #import emoji: *
  #show: el.default-enum-list
  #let marker = level => {
    if level == 1 {
      ([#sym.suit.club.filled], [#sym.suit.spade.filled], [#sym.suit.heart.filled])
    } else if level == 2 {
      n => rotate(24deg * n, box(rect(stroke: 1pt + blue, height: 1em, width: 1em)))
    } else {
      [#sym.ballot.check.heavy]
    }
  }
  #set list(marker: marker)
  ```
  #import emoji: *
  #show: el.default-enum-list
  #let marker = level => {
    if level == 1 {
      ([#sym.suit.club.filled], [#sym.suit.spade.filled], [#sym.suit.heart.filled])
    } else if level == 2 {
      n => rotate(24deg * n, box(rect(stroke: 1pt + blue, height: 1em, width: 1em)))
    } else {
      [#sym.ballot.check.heavy]
    }
  }
  #set list(marker: marker)
  - 123
  - 234
    - 111
    - 123
      - ddd
      - 111
    - aaa
    - fff
    - dddd
  - dddd
    - 123
  - aaa
]
