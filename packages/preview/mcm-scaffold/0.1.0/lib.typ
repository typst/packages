#let text-font = ("Times New Roman", "TeX Gyre Termes")

#let mcm(
  title: "A Typst Template for MCM/ICM",
  problem-chosen: "ABCDEF",
  team-control-number: "1111111",
  year: "2025",
  summary: [],
  keywords: [],
  magic-leading: 0.65em,
  body,
) = {
  set document(title: team-control-number)
  
  set text(
    font: text-font,
    size: 12pt,
    lang: "en"
  )

  //----------------------------summary-------------------------//
  [
    #set page(
      paper: "us-letter",
      margin: (top: 1.02cm, bottom: 0cm, left: 2.54cm, right: 2.54cm)
    )

    #set par(
      justify: true, 
      first-line-indent: 2em
    )
    
    #grid(
      columns: (5.63cm,) * 3,
      rows: (14pt,) * 3,
      align: center + horizon,
  
      [*Problem Chosen*], [*#year*], [*Team Control Number*],
      grid.cell(rowspan: 2, text(size: 20pt)[#problem-chosen]),
      [*MCM/ICM*],
      grid.cell(rowspan: 2, text(size: 20pt)[#team-control-number]),
      [*Summary Sheet*]
    )

    #line(length: 100%, stroke: (thickness: 1.1pt, dash: "solid"))

    #align(center)[#text()[*#title*]]

    #align(center)[#text()[*Summary*]]

    #par(leading: magic-leading)[#summary]

    *Keywords:* #keywords

    #counter(page).update(0)
    // #pagebreak()
  ]
  //-----------------------------------------------------------//
  


  set page(
    paper: "us-letter",
    margin: (top: 2.54cm, bottom: 2.54cm, left: 2.54cm, right: 2.54cm),
    header: [
      Team \# #team-control-number
      #h(1fr)
      Page
      #counter(page).display(
      "1 of 1",
      both: true,
      )
      #v(-0.8em)
      #line(length: 100%, stroke: (thickness: 0.6pt, dash: "solid"))
    ]
  )



//--------------------------outline---------------------------//

  show outline.entry.where(
    level: 1
  ): it => {
    v(12pt, weak: true)
    strong(it)
  }

  show heading.where(outlined: false): set align(center)
  
  outline(
    indent: auto,
  )
  
  pagebreak()


//--------------------------heading---------------------------//
  let empty-par = par[#box()]
  let fake-par = context empty-par + v(-measure(empty-par + empty-par).height)

  set heading(
    numbering: "1.1 "
  )

  show heading: it => [#it #v(4pt)]
  show heading.where(level: 1): it => [#it #v(4pt)]
  show heading: it => it + fake-par
  


//-------------------------paragraph--------------------------//
  set par(
    justify: true, 
    first-line-indent: 2em
  )
  

  //-------------------------list-----------------------------//
  set list(indent: 1em)
  set enum(indent: 1em)
  show enum: it => it + fake-par

//--------------------------figure----------------------------//
  set figure(gap: 1em)
  show figure: it => it + fake-par

//---------------------------image----------------------------//
  set image(width: 70%)


//---------------------------table----------------------------//
  show figure.where(
    kind: table
  ): set figure.caption(position: top)
  
  show table.cell.where(y: 0): strong
  show table.cell.where(y: 0): set par(justify: false)
  
  
//---------------------------math-----------------------------//
  set math.equation(numbering: "(1)")
  show math.equation.where(block: true): it => it + fake-par


//-------------------------reference--------------------------//

  set bibliography(title: "References")


//---------------------------code-----------------------------//
  show raw.where(block: false): it => box(
    fill: luma(240), inset: (x: 2pt), outset: (y: 3pt), radius: 1pt
  )[#text(size: 10pt)[#it]]

  show raw.where(block: true): it =>  block(
    width: 100%, fill: luma(240), inset: 10pt, radius: 3pt, stroke: 0pt, breakable: true
  )[#it] + fake-par

  
//------------------------------------------------------------//
  body  
}


//---------------------------enum-----------------------------//
#let enum-default = { set enum(numbering: "1.") }

#let enum-paren(content) = {
  set enum(numbering: "1)")
  content
  enum-default
}


//---------------------------image----------------------------//
#let img-single(path: str, width: 70%, caption: none, placement: none) = {
  figure(
    image(path, width: width),
    caption: caption,
    placement: placement
  )
}
  
#let img-grid(cols: 2, rows: 1, imgs: array, subcaps: (), caption: none, placement: none) = {
  assert(cols * rows == imgs.len())

  let col-width = ()
  let row-height = ()

  let i = cols
  while i > 0 {
    col-width.push(90%/cols)
    i -= 1
  }

  let i = rows
  while i > 0 {
    row-height.push(auto)
    i -= 1
  }

  // subcap completion
  let i = imgs.len() - subcaps.len()
  while i > 0 {
    subcaps.push(none)
    i -= 1
  }

  // cells
  let cells = ()
  let i = 0
  while i < rows {
    let j = 0
    while j < cols {
      cells.push(
        grid.cell(image(imgs.at(i * cols + j), width: 70%), align: bottom)
      )
      j += 1
    }
    let k = 0
    while k < cols {
      cells.push(
        grid.cell(subcaps.at(i * cols + k), align: top)
      )
      k += 1
    }
    i += 1
  }

  rows += 1
  figure(
    grid(
      columns: col-width,
      rows: row-height,
      column-gutter: 0.5em,
      row-gutter: 0.5em,
      align: bottom,
      ..cells,
    ),
    caption: caption,
    placement: placement
  )
}

//---------------------------table----------------------------//
#let threee-line-table(columns: array, align: auto, headers: array, bodies: array, caption: content) = {
  figure(
    table(
        columns: columns,
        align: align,
        stroke: (_, y) => (
          top: if y == 0 {1pt} else if y == 1 {0.6pt} else {0pt},
          bottom: 1pt,
        ),
        ..headers,
        ..bodies,
    ),
    caption: caption
  )
}

//---------------------------tools----------------------------//
#let no-indent = context h(-par.first-line-indent)

#let math-no-number(content) = { 
  set math.equation(numbering: none) 
  content
}

#let place-here(it) = {
  set figure(placement: auto)
  it
}