#import "../lib.typ": *
#set page(width: 12cm, margin: 1cm, height: auto)
#set par(first-line-indent: (amount: 2em, all: true), spacing: 1.5em)
#set block(stroke: red)
#show: par-indent.with(use-par-leading: (apply-elem: (block, math.equation, raw)))
#[
  #lorem(2)
  #table(
    columns: 2,
    [#lorem(2)], [#lorem(2)],
  )
  #lorem(2) par-leading // uses `par-leading` below
  #context [
    ```typst
    #let template(doc) = ...
    ```
    #lorem(2)
    $
      a^2 + b^2 = c^2
    $
  ]
  #lorem(2) par-leading // uses `par-leading` above
]
#line(length: 100%)
#[
  #lorem(2)
  #table(
    columns: 2,
    [#lorem(2)], [#lorem(2)],
  )

  #lorem(2) indent and par-spacing
  #context [
    ```typst
    #let template(doc) = ...
    ```
    #lorem(2)
    $
      a^2 + b^2 = c^2
    $
  ]
  #lorem(2) indent and par-spacing
]

#line(length: 100%)

#[
  #lorem(2)
  #table(
    columns: 2,
    [#lorem(2)], [#lorem(2)],
  ) 
  // not indent
  #context [
    #lorem(2) 
    $
      a^2 + b^2 = c^2
    $
    #lorem(2)
  ]

  #lorem(2)
]

#line(length: 100%)

#[
  #lorem(2)
  #table(
    columns: 2,
    [#lorem(2)], [#lorem(2)],
  )
  
  #context [
    #lorem(2) // indent
    $
      a^2 + b^2 = c^2
    $
    #lorem(2)
  ]
  // uses `par-leading`
  $
    a^2 + b^2 = c^2
  $
]
