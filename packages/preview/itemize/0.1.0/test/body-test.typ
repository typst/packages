#import "../lib.typ" as el
#set page(height: auto, margin: 25pt) //,

== custom body

#let test0 = [
  + #lorem(50)
  + #lorem(5) $mat(1, 0, 0; 0, 1, 0; 0, 0, 1)$
    + #lorem(20)
      + #lorem(10)
      + #lorem(15)
    + #lorem(20)
  + #lorem(20)
]
=== example1
#[
  #show: el.default-enum-list.with(fill: (blue, red, green))
  #show enum: it => context {
    text(
      size: 15pt * calc.pow(0.9, el.level()),
      fill: color.mix((red, 90% * calc.pow(0.6, el.level())), (blue, 20% * calc.pow(2.5, el.level()))),
      it,
    )
  }
  #set enum(numbering: "(1).(a).(i)")
  #test0
]
=== example2
#[

  #show: el.default-enum-list.with(is-full-width: false)
  #show list: it => context {
    if el.list-level() == 1 {
      it
    } else if el.list-level() == 2 {
      block(stroke: 1pt + blue, it)
    } else {
      block(fill: yellow.lighten(50%), it)
    }
  }
  - #lorem(50)
  - #lorem(5) $mat(1, 0, 0; 0, 1, 0; 0, 0, 1)$
    - #lorem(20)
      - #lorem(10)
      - #lorem(15)
    - #lorem(20)
  - #lorem(20)

]


=== bug
#[
  #show: el.default-enum-list.with(is-full-width: false)
  #show enum.item: it => context {
    if el.level() == 2 {
      block(stroke: 1pt + red, inset: 5pt, it)
    } else {
      it
    }
  }

  #set enum(numbering: "(1).(a).(i)")
  + #lorem(50)
  + #lorem(5) $mat(1, 0, 0; 0, 1, 0; 0, 0, 1)$
    + #lorem(20)
      + #lorem(10)
      + #lorem(15)
    + #lorem(20)
  + #lorem(20)

  Note that, when we use `show enum.item`, then number in the item will be not correct, which is a bug.

]

