#let mla(
  title: "Paper Title",
  author: none,
  professor: none,
  date: none,
  course: none,
  bibliography-file: none,
  body
) = {
  // Set document metdata.
  set document(
    title: title,
    author: author.firstname + " " + author.lastname
  )
  
  // Configure the page.
  set page(
    paper: "us-letter",
    header: align(
      right + horizon,
      [
        #v(0.5in)
        #author.lastname
        #context(counter(page).display("1"))
      ]
    ),
    margin: 1in
  )
  
  // Set paragraph properties.
  set par(
    first-line-indent: 0.5in,
    justify: false, 
    leading: 2em
  )
  set par( 
    spacing: 2em 
  )

  // Set the body font.
  set text(
    font: "Liberation Serif",
    size: 12pt,
  )

  // Configure headings.
  set heading(numbering: "1.1.a.")
  show heading: set block(spacing: 2em)
  show heading: it => {
    set text(size: 12pt)
    set par(first-line-indent: 0in)
    
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(6pt, weak: true)
    }
    
    // Don't number the conclusion
    let is-conclusion = it.body in ([conclusion], [Conclusion], [CONCLUSION])
    v(2em)
    if it.level == 1 and is-conclusion == true {
      block[#text(weight: "bold")[#it.body]]
    } else if it.level == 1 and is-conclusion == false {
      block[#text(weight: "bold")[#number #it.body]]
    } else if it.level == 2 {
      block[#text(weight: "semibold")[#number #it.body]]
    } else if it.level == 3 {
      block[#text(weight: "medium")[#number #it.body]]
    }
    v(2em)
  }

  // configure block quotes
  set quote(block: true)
  show quote: set pad(left: 0.5in)
  show quote: set block(spacing: 2em)

  // configure tables
  show figure.where(kind: table): it => {
    set block(spacing: 1em)
    set par(
      first-line-indent: 0in,
      leading: 1em
    )
    set table(stroke: none, align: center, row-gutter: 1em)
    strong([Table #it.counter.display(it.numbering) #linebreak()])
    it.caption.body
    it.body
    it.supplement
  }

  // configure illustrations
  show figure.where(kind: image): it => {
    set block(spacing: 1em)
    set par(
      first-line-indent: 0in,
      leading: 1em
    )
    it.body
     align(
       center,
       [Fig. #it.counter.display(it.numbering)\. #it.caption.body]
     )
    
  }

  // MLA boilerplate
  align(left,
    stack(
      dir:ttb,
      spacing: 2em,
      [#author.firstname #author.lastname],
      ..if professor != none { (professor,) } else { () },
      course,
      date
    )
  )
  
  // Display the paper's title.
  align(center, title)

  // Display the paper's contents.
  body

  // Display the bibliography, if any is given.
  if bibliography-file != none {
    pagebreak()
    align(center, "Works Cited")
    show bibliography: set par(
      first-line-indent: 0in,
      hanging-indent: 0.5in
    )
    bibliography(
      bibliography-file, title:none, style: "mla"
    )
  }
}
