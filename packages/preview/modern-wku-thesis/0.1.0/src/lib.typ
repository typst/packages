#let graduate-thesis(
  title: [thesis title],
  author: "author name",
  degree: [MS of Computer Information Systems],
  department: [Department of Computer Science and Technology],
  university: [Wenzhou-Kean University],
  supervisor: [Supervisor Name],
  month: [Month],
  year: [Year],
  degree-year: [Year],
  program-type: [Master of Science],
  degree-type: [Master],
  degree-department: [Computer Science and Technology],
  abstract: none,
  keywords: none,
  acknowledgments: none,
  acronyms:(:),
  bibliography: none,
  body
)={
  set document(title: title, author: author)
  // 初始设置：前置章节不显示任何编号
  set heading(numbering: none)
  
  // 设置标题字号和间距
  show heading: it => {
    let sizes = (25pt, 18pt, 15pt, 12pt, 12pt, 12pt)
    let spacings = (2em, 1.6em, 1.3em, 1.1em, 1em, 1em)
    let level = it.level - 1
    let size = if level < sizes.len() { sizes.at(level) } else { 12pt }
    let spacing = if level < spacings.len() { spacings.at(level) } else { 1em }
    
    v(spacing, weak: true)
    text(size: size, weight: "bold")[#it]
    v(spacing, weak: true)
  }
  
  // 设置表格标题样式：10pt，粗体，位于表格上方
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption.where(kind: table): it => {
    text(size: 10pt, weight: "bold")[#it]
  }

  show figure.caption.where(kind: image): it=>{
    text(size: 10pt, weight: "bold")[#it]
  }
  
  // COVER PAGE
  set text(size: 14pt)
  align(center)[
    #text(size: 21pt, weight: "bold")[#title]
    
    #text(size: 12pt)[by:]
    
    
    #text(weight: "bold")[#author]
    
    #v(3em)
    
    #text(size: 12pt)[
      A Thesis Submitted in Fulfillment of the Requirements for the Degree of
    ]
    
    #text(weight: "bold")[#degree]
    
    #v(3em)
    
    // University logo
     #image("assets/logo.png", width: 100pt)
    
    #v(3em)
    
    #department
    
    #university
    
    #v(2em)
    
    Supervised By: \ *#supervisor*
    
    #v(2em)
    
    ©#month #year
  ]
  pagebreak()
  
  // COVER PAGE BACKFRONT
  set text(size: 12pt)
  set page(numbering: "i")
  counter(page).update(2)
  
  grid(
    columns: (1fr, 1fr),
    column-gutter: auto,
    row-gutter: 1.5em,
    align: (left, right),
    [
      #program-type (#degree-year)
      #linebreak()
      #degree-department
    ],
    [
      #university
      #linebreak()
      Wenzhou, China
    ],
  )
  v(5em)
  grid(
    columns: (0.5fr, 1fr),
    column-gutter: auto,
    row-gutter: 3em,
    align: (left, left),
    [
      TITLE:
    ],
    [
      #title
    ],
    [
      AUTHOR:
    ],
    [
      #author
      #linebreak()
      #degree-type, (#degree-department)
      #linebreak()
      #university
      #linebreak()
      Wenzhou, China
    ],
    [
      SUPERVISORS:
    ],
    [
      #supervisor
    ],
    // Number of pages row - auto-generated
    [
      NUMBER OF PAGES:
    ],
    [
      #context {
        let total-pages = counter(page).final().first()
        total-pages
      }
    ]
  )
  pagebreak()

  // Abstract section (if provided)
  set par(justify: true, leading: 1em, spacing: 2.5em)
  if abstract != none {
    [= Abstract]
    
    [#abstract]
    
    v(1em)

    if keywords != none {
      text(weight: "bold")[Keywords: ] + [#keywords]
    }
    
    pagebreak()
  }
  
  // Acknowledgments section (if provided)
  if acknowledgments != none {
    [= Acknowledgments]
    
    [#acknowledgments]
    
    pagebreak()
  }

  
  
  
  
  // 设置目录缩进
  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    strong(it)
  }
  show outline.entry.where(level: 2): it => {
    pad(left: -4em, it)
  }
  show outline.entry.where(level: 3): it => {
    pad(left: -5em, it)
  }
  show outline.entry.where(level: 4): it => {
    pad(left: -5em, it)
  }
  
  outline(title: text(size: 25pt, weight: "bold")[Table of Contents])
  pagebreak()
  
  // Add List of Figures as a heading so it appears in TOC
  heading(level: 1, numbering: none)[List of Figures]
  outline(title: none, target: figure.where(kind: image))
  pagebreak()
  
  // Add List of Tables as a heading so it appears in TOC
  heading(level: 1, numbering: none)[List of Tables]
  outline(title: none, target: figure.where(kind: table))
  pagebreak()

  if acronyms != none {
    [= Definition of Acronyms]
    
    // Create table from acronyms dictionary wrapped in figure
    figure(
      table(
         columns: (20%, 80%),
         stroke: 0.5pt,
         align: (center, left),
         table.header(
           [*Acronym*], [*Definition*]
         ),
        ..acronyms.pairs().map(((key, value)) => (key, value)).flatten()
      ),
      caption: [Definition of Acronyms],
      kind: table
    )
    
    pagebreak()
  }
  // Main content - Arabic numerals starting from 1
  set page(numbering: "1")
  counter(page).update(1)
  
  // 重置章节计数器并设置正文标题编号：显示 "Chapter"
  counter(heading).update(0)
  set heading(numbering: (..nums) => {
    let level = nums.pos().len()
    if level == 1 {
      "Chapter " + str(nums.pos().at(0))
    } else if level == 2 {
      str(nums.pos().at(0)) + "." + str(nums.pos().at(1))
    } else if level == 3 {
      // Level 3: A.B.C format
      let letters = ("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
      letters.at(nums.pos().at(2) - 1)+"."
    } else if level == 4 {
      // Level 4: just a dot
      "•"
    } else {
      nums.pos().map(str).join(".")
    }
  })
  
  show std.bibliography: set text(12pt)
  show std.bibliography: set par(spacing: 1em, leading: 0.5em)
  set std.bibliography(title: [References], style: "ieee")
  body
  // 使用相对于调用文件的路径
  bibliography
}