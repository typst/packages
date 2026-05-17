#import "../lib.typ": *
#set page(width: 12cm, margin: 1cm, height: auto)
#set block(stroke: red)

#set par(spacing: 1.5em)

#show strong: set text(size: 1.5em)
#show "Indented": set text(fill: blue)
#show "UnIndented": set text(fill: red)

#show "leading": set text(fill: purple)
#show "spacing": set text(fill: green)

#let debug = context state("__cdl_par_type__", (data: (par-type: 0), backup: ())).get()

= `#set par(first-line-indent: (amount: 2em, all: true))`

#[
  #set par(first-line-indent: (amount: 2em, all: true))
  #show: par-indent.with(
    exclude-elem: (rect,),
    use-par-leading: (
      block-text-leading: (rect,),
      text-block-leading: (rect,),
      block-block-leading: (rect,),
    ),
  )

  `exclude par-indent for `rect` and par-leading for `rect` with rect's block.spacing == auto`

  #block[
    *Indented* #lorem(8) *par.spacing*

    #rect()
    *Indented + par.leading* #lorem(8) *par.leading*
    #rect()

    *Indented + par.spacing* #lorem(8)

    #block[Block-element *par.leading*]
    #rect()
  ]


  `#show rect: set block(spacing: 1em)`
  #show rect: set block(spacing: 1em)
  #block[
    *Indented* #lorem(8) *spacing: 1em*
    #rect()
    *Indented + spacing: 1em* #lorem(8)
    #rect()

    *Indented + spacing: 1em* #lorem(8)

    #block[Block-element *spacing: 1em*]
    #rect()
  ]

]

#pagebreak()

= `#set par(first-line-indent: (amount: 2em, all: false))`

#[
  #set par(first-line-indent: (amount: 2em, all: false))
  #show: par-indent.with(
    exclude-elem: (rect,),
    use-par-leading: (
      block-text-leading: (rect,),
      text-block-leading: (rect,),
      block-block-leading: (rect,),
    ),
  )
  `exclude par-indent for `rect` and par-leading for `rect` with rect's block.spacing == auto`
  #block[
    *UnIndented* #lorem(8) *par.spacing*

    #rect()
    *UnIndented + par.leading* #lorem(8) *par.leading*
    #rect()

    *UnIndented + par.spacing* #lorem(8)

    #block[Block-element *par.leading*]
    #rect()

    #block[Block-element *par.spacing*]

    #rect()
  ]

  `#show rect: set block(spacing: 1em)`
  #show rect: set block(spacing: 1em)
  #block[
    *UnIndented* #lorem(8) *spacing: 1em*
    #rect()
    *UnIndented + spacing: 1em* #lorem(8)
    #rect()

    *UnIndented + spacing: 1em* #lorem(8)

    #block[Block-element *spacing: 1em*]
    #rect()

    #block[Block-element *spacing: 1em*]

    #rect()
  ]

]


#pagebreak()

= `#set par(first-line-indent: (amount: 2em, all: false))`

#[
  #set par(first-line-indent: (amount: 2em, all: false))

  `par-indent + block-text-leading for `rect``
  #block[
    #show: par-indent.with(
      include-elem: (rect,),
      use-par-leading: (
        block-text-leading: (rect,),
        text-block-leading: (),
        block-block-leading: (),
      ),
    )

    *UnIndented* #lorem(8) *par.spacing*

    #rect()
    *UnIndented + par.leading* #lorem(8) *par.spacing*
    #rect()

    *Indented + par.spacing* #lorem(8)

    #block[Block-element *par.spacing*]
    #rect()

    #block[Block-element *par.spacing*]

    #rect()
  ]

  `par-indent + text-block-leading for `rect``

  #block[
    #show: par-indent.with(
      include-elem: (rect,),
      use-par-leading: (
        block-text-leading: (),
        text-block-leading: (rect,),
        block-block-leading: (),
      ),
    )

    *UnIndented* #lorem(8) *par.spacing*

    #rect()
    *UnIndented + par.spacing* #lorem(8) *par.leading*
    #rect()

    *Indented + par.spacing* #lorem(8)

    #block[Block-element *par.spacing*]
    #rect()

    #block[Block-element *par.spacing*]

    #rect()
  ]

  `par-indent + block-block-leading for `rect``

  #block[
    #show: par-indent.with(
      include-elem: (rect,),
      use-par-leading: (
        block-text-leading: (),
        text-block-leading: (),
        block-block-leading: (rect,),
      ),
    )

    *UnIndented* #lorem(8) *par.spacing*

    #rect()
    *UnIndented + par.spacing* #lorem(8) *par.spacing*
    #rect()

    *Indented + par.spacing* #lorem(8)

    #block[Block-element *par.leading*]
    #rect()

    #block[Block-element *par.spacing*]

    #rect()
  ]

]

#pagebreak()

= `#set par(first-line-indent: (amount: 2em, all: true))`

#[
  #set par(first-line-indent: (amount: 2em, all: true))

  `par-indent + block-text-leading for `rect``
  #block[
    #show: par-indent.with(
      include-elem: (rect,),
      use-par-leading: (
        block-text-leading: (rect,),
        text-block-leading: (),
        block-block-leading: (),
      ),
    )

    *Indented* #lorem(8) *par.spacing*

    #rect()
    *UnIndented + par.leading* #lorem(8) *par.spacing*
    #rect()

    *Indented + par.spacing* #lorem(8)

    #block[Block-element *par.spacing*]
    #rect()

    #block[Block-element *par.spacing*]

    #rect()
  ]

  `par-indent + text-block-leading for `rect``

  #block[
    #show: par-indent.with(
      include-elem: (rect,),
      use-par-leading: (
        block-text-leading: (),
        text-block-leading: (rect,),
        block-block-leading: (),
      ),
    )

    *Indented* #lorem(8) *par.spacing*

    #rect()
    *UnIndented + par.spacing* #lorem(8) *par.leading*
    #rect()

    *Indented + par.spacing* #lorem(8)

    #block[Block-element *par.spacing*]
    #rect()

    #block[Block-element *par.spacing*]

    #rect()
  ]

  `par-indent + block-block-leading for `rect``

  #block[
    #show: par-indent.with(
      include-elem: (rect,),
      use-par-leading: (
        block-text-leading: (),
        text-block-leading: (),
        block-block-leading: (rect,),
      ),
    )

    *UnIndented* #lorem(8) *par.spacing*

    #rect()
    *UnIndented + par.spacing* #lorem(8) *par.spacing*
    #rect()

    *Indented + par.spacing* #lorem(8)

    #block[Block-element *par.leading*]
    #rect()

    #block[Block-element *par.spacing*]

    #rect()
  ]

]
