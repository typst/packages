#import "@preview/itemize:0.1.0" as el

#set page(width: 350mm, height: auto, margin: 25pt)

#let eqs = $
  norm(x+y)^2 + norm(x-y)^2 = 2(norm(x)^2 + norm(y)^2)
$

#let inline-eq1 = [$l^p = {bold(x) = (x_1, x_2,...) : norm(bold(x))_p :=(sum_(j=1)^oo|x_j|^p)^(1 / p) < oo }$ ($1<=p<oo$)]
#let inline-eq2 = [$vec(1, 1, 1, 1)$]

#let simple-test = [
  + #lorem(5)
    #eqs
    + $vec(1, 1, 1, 1)$ #lorem(5)
      + #lorem(5)
      + #lorem(5)

        #lorem(5)
  + + + #lorem(5)
  - #lorem(5)
    #eqs
    - $vec(1, 1, 1, 1)$ #lorem(5)
      - #lorem(5)
      - #lorem(5)

        #lorem(20)
  - - - #lorem(5)

  + #lorem(5)
    - #lorem(5)
    - #lorem(5)
  + #lorem(5)
  + - + - - - #lorem(5)
  - - + + - - #lorem(5)
]
= simple-test
#[
  #table(
    columns: (1fr, 1fr),
    [original], [itemize],
    [#simple-test],
    [#show: el.default-enum-list
      #simple-test],
  )
]

#[
  #set enum(numbering: "(1).(a).(i)", reversed: true)
  ```typ
  #set enum(numbering: "(1).(a).(i)", reversed: true)
  ```
  #table(
    columns: (1fr, 1fr),
    [original], [itemize],
    [#simple-test],
    [#show: el.default-enum-list
      #simple-test],
  )
]

#[
  #set enum(numbering: "(1).(a).(i)", full: true, indent: 0.5em, body-indent: 1em)
  #set list(indent: 1.5em, body-indent: 0.5em)
  #set par(first-line-indent: (amount: 2em, all: true))
  ```typ
  #set enum(numbering: "(1).(a).(i)", full: true, indent: 0.5em, body-indent: 1em)
  #set list(indent: 1.5em, body-indent: 0.5em)
  #set par(first-line-indent: (amount: 2em, all: true))
  ```
  #table(
    columns: (1fr, 1fr),
    [original], [itemize],
    [#simple-test],
    [#show: el.default-enum-list
      #simple-test],
  )
]

= more-test
#let item-list-test = [
  `enum test`
  + first
    #eqs
  + second
    + nesting item one
    + nesting item two
      + more
      + + further more
        + further further more
          +
            + ....
            + ....
  + third
  + and eqs
    + #inline-eq1
    + #inline-eq2
    + text


  \

  `list test`
  - first
  - second
    - nesting item one
    - nesting item two
      - more
      - - further more
        - further further more
  - third
  - and eqs
    - #inline-eq1
    - #inline-eq2
    - text
      -
        - ...
        - ....
          - - - - - ...

  \

  `mixed and more test`
  + first
  + second
    - nesting item one
    - nesting item two
      + more
      + more more

        #lorem(20)

      + - further more
        - further further more
          - more
          - #lorem(10)
            + more
      + more more

      #lorem(20)

      #lorem(20)

      + - further more
        -
          + more
          + #lorem(10)

      + - further more
        -
          + more
          + #lorem(10)
      - 100. further more
        +
          - more
          - #lorem(10)
  + third
  + and eqs
    - #inline-eq1
    - #inline-eq2
    - text
  #lorem(20)
]
#[
  #set enum(numbering: "(1).(a).(i)", full: true)
  #table(
    columns: (1fr, 1fr),
    [original], [fix],
    [#item-list-test],
    [#show: el.default-enum-list
      #item-list-test],
  )
]
