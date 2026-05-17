#import "../lib.typ": *


#import "@preview/layout-ltd:0.1.0": *
#show: layout-limiter.with(max-iterations: 3)

#[
  #set page(height: auto)
  = case: 1
  #box(stroke: red, width: 100%)[
    #set par(first-line-indent: (amount: 3em, all: false))

    #show: par-indent
    #[
      // #show text:  it => context it.size
      #set text(size: 2em)
      $ a + b $

      #lorem(2)
      *#[

        #set text(size: 1.5em)
        #set text(fill: red)
        $ a + b $

        #lorem(2)
      ]*
      AAA
    ]
    #lorem(4)
  ]
  = case: 2
  #box(stroke: red, width: 100%)[
    #set par(first-line-indent: (amount: 3em, all: false))

    #show: par-indent
    #[
      #set text(size: 2em)
      $ a + b $

      #lorem(2)
      *#[

        #set text(size: 1.5em)
        #set text(fill: red)
        $ a + b $

        #lorem(2)
      ]*
      AAA
    ]

    #lorem(4)
  ]
  = case: 3
  #box(stroke: red, width: 100%)[
    #set par(first-line-indent: (amount: 3em, all: false))

    #show: par-indent
    #[
      // #show text:  it => context it.size
      #set text(size: 2em)
      $ a + b $

      #lorem(2)
      *#[

        #set text(size: 1.5em)
        #set text(fill: red)
        $ a + b $

        #lorem(2)
      ]*

      AAA
    ]
    #lorem(4)
  ]
  = case: 4
  #box(stroke: red, width: 100%)[
    #set par(first-line-indent: (amount: 3em, all: true))

    #show: par-indent
    #[
      // #show text:  it => context it.size
      #set text(size: 2em)
      $ a + b $

      #lorem(2)
      *#[

        #set text(size: 1.5em)
        #set text(fill: red)
        $ a + b $
        #lorem(2)
      ]*
      AAA
    ]
    #lorem(4)
  ]
  = case: 5
  #box(stroke: red, width: 100%)[
    #set par(first-line-indent: (amount: 3em, all: true))

    #show: par-indent
    #[
      // #show text:  it => context it.size
      #set text(size: 2em)
      $ a + b $

      #lorem(2)
      *#[

        #set text(size: 1.5em)
        #set text(fill: red)
        $ a + b $
        #lorem(2)
      ]*

      AAA
    ]
    #lorem(4)
  ]
  = case: 6
  #box(stroke: red, width: 100%)[
    #set par(first-line-indent: (amount: 3em, all: true))

    #show: par-indent
    #[
      // #show text:  it => context it.size
      #set text(size: 2em)
      $ a + b $

      #lorem(2)
      *#[

        #set text(size: 1.5em)
        #set text(fill: red)
        $ a + b $
        #lorem(2)
      ]*
      AAA
    ]

    #lorem(4)
  ]
  = case: 7
  #box(stroke: red, width: 100%)[
    #set par(first-line-indent: (amount: 3em, all: true))

    #show: par-indent
    #[
      #set par(justify: true)
      #set text(size: 2em)
      $ a + b $

      #lorem(2)
      *#[

        #set text(size: 1.5em)
        #set text(fill: red)
        $ a + b $
        #lorem(2)
      ]*
      AAA
    ]
    #lorem(4)
  ]
]




#pagebreak()



#set page(height: auto)
#set heading(numbering: "1.")





=
#[
  #set par(first-line-indent: (amount: 3em, all: true))
  #let test = [
    #set text(fill: blue)
    // #set par(justify: true)
    #lorem(1)
    $
      a^2 + b^2 = c^2 \
      vec(1, 1, 1)
    $
    #text(size: 2em)[
      #set par(leading: 1em)
      #lorem(5)
    ]
    #lorem(2)

    // #set par(leading: 1em)
    *#lorem(10)*
    $ a $
    #[
      #set text(size: 2em)
      // #set par(leading: 1em)
      #lorem(5)
      #par(leading: 1.2em)[#lorem(5)]
      //
      1111
      #align(center, [#rect()])
      #lorem(5)
    ]
  ]
  #table(
    columns: (1fr,) * 2,
    [
      #test
      #lorem(5)
    ],
    [
      #show: par-indent.with(exclude-elem: (align,))
      #test
      #lorem(5)
    ],
  )
]

=
#[
  #let test = [
    #set par(first-line-indent: (amount: 3em, all: true))
    #set text(fill: blue, size: 2em)
    // #set par(justify: true)
    #lorem(1)
    $
      a^2 + b^2 = c^2 \
      vec(1, 1, 1)
    $
    #lorem(5)
  ]
  #table(
    columns: (1fr,) * 2,
    [
      #test
      #lorem(5)
    ],
    [
      #show: par-indent
      #test
      #lorem(5)
    ],
  )
]


=
#[
  #set par(first-line-indent: (amount: 3em, all: false))
  #let test = [
    #set text(fill: blue, size: 2em)
    #lorem(1)
    $
      a^2 + b^2 = c^2 \
      vec(1, 1, 1)
    $
    #lorem(5)
  ]
  #table(
    columns: (1fr,) * 2,
    [
      #test
      #lorem(5)
    ],
    [
      #show: par-indent
      #test
      #lorem(5)
    ],
  )
]


=
#[
  #set par(first-line-indent: (amount: 3em, all: false))
  #let test = [
    #set text(fill: blue, size: 2em)
    #lorem(1)
    $
      a^2 + b^2 = c^2 \
      vec(1, 1, 1)
    $

    #lorem(5)
  ]
  #table(
    columns: (1fr,) * 2,
    [
      #test
      #lorem(5)
    ],
    [
      #show: par-indent
      #test
      #lorem(5)
    ],
  )
]


=
#[
  #set par(first-line-indent: (amount: 3em, all: false))
  #let test = [
    #set text(fill: blue, size: 2em)
    #lorem(1)
    $
      a^2 + b^2 = c^2 \
      vec(1, 1, 1)
    $

    #lorem(5)
  ]
  #table(
    columns: (1fr,) * 2,
    [
      #test
      #block[#lorem(2)]
    ],
    [
      #show: par-indent
      #test
      #block[#lorem(2)]
    ],
  )
]


=
#[
  #set block(stroke: red)
  #set heading(numbering: none)
  #set par(first-line-indent: (amount: 3em, all: false), spacing: 1.5em, leading: .5em)
  #let test = [
    #lorem(1)
    $
      a^2 + b^2 = c^2 \
      vec(1, 1, 1)
    $

    #lorem(5)

    #line(length: 100%)
    change: par-first-line-indent
    #set par(first-line-indent: (amount: 2em, all: true))
    + #lorem(2)
    #lorem(5)

    #line(length: 100%)
    change: par-first-line-indent
    #set par(first-line-indent: (amount: 2em, all: false))
    + #lorem(2)

    #lorem(5)

    #line(length: 100%)
    change: par-first-line-indent
    #set par(first-line-indent: (amount: 2em, all: false))
    + #lorem(2)
    #lorem(5)

    #line(length: 100%)
    align
    #align([2222222])
    2222222222

    #line(length: 100%)
    set align
    #[
      #set align(center)
      2222222222
    ]
    22222222

    #line(length: 100%)
    set par
    #[
      #set par(justify: true)
      #lorem(10)
    ]
    22222222

    #line(length: 100%)
    heading
    == heading
    2222222222

    #line(length: 100%)
    heading
    #title[#title]
    2222222222

    #line(length: 100%)
    table
    #table[>>][!!]
    2222222222

    #line(length: 100%)
    grid
    #grid[>>][!!]
    2222222222

    #line(length: 100%)
    pad
    #pad(x: 1em, y: 1em)[>>]
    2222222222

    #line(length: 100%)
    stack
    #[
      #stack([#lorem(2)], [#lorem(2)])
      #lorem(2)
    ]

    #line(length: 100%)
    rect
    #rect()
    #lorem(2)

    #line(length: 100%)
    v
    #v(1em)
    #lorem(2)

    #line(length: 100%)
    #outline()
    #lorem(2)

    #line(length: 100%)
    1111111
    / abcdd: #lorem(2)
    / #lorem(2): #lorem(6)
    #lorem(6)
  ]
  #table(
    columns: (1fr,) * 2,
    [
      #test
      #lorem(2)
    ],
    [
      #show: par-indent.with(use-par-leading: (apply-elem: "all"))
      #test
      #lorem(2)
    ],
  )
]


=
#[
  #set par(first-line-indent: (amount: 3em, all: false), spacing: 1.5em, leading: .5em)
  #show: par-indent.with(
    use-par-leading: (
      apply-elem: (block, math.equation, list, enum, terms),
    ),
  )
  #set block(stroke: red)
  #table(
    columns: (1fr,) * 2,
    [
      #lorem(2)
      #block(lorem(2))
      #lorem(2)
      #parize-block[
        #parize-par-above-flag
        #lorem(2)
      ]
      #lorem(2)
    ],
    [
      #lorem(2)
      #block([

        #lorem(2)
      ])
      #lorem(2)

      #parize-block[
        #parize-par-above-flag

        #lorem(2)
      ]

      #lorem(2)
    ],
  )
]
