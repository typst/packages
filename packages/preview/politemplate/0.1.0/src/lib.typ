#import "@preview/tablex:0.0.9": (
  tablex,
  rowspanx,
  colspanx,
  cellx,
  hlinex,
  vlinex,
)
#import "@preview/hydra:0.6.1": hydra, anchor, selectors

/// This function renders a cover
///
/// ```example
/// >>> #show: doc => scale(90%, doc)
/// #frontpage(
///   title: [Poli Template],
///   logo: "/template/logo.jpg",
///   students: (
///     ([Student 1],[13685478]),
///     ([Student 2],[13645638]),
///   ),
///   teachers: (
///     [Teacher 1],
///     [Teacher 2],
///   ),
///   header: [
///     departamento de engenharia elétrica\
///     PRO3821 - Fundamentos da economia\
///     Turma 1
///   ],
///   footer: [São Paulo, SP],
///   no_pagebrake: true
/// )
/// ```
/// -> content
#let frontpage(
  /// Title of the document
  /// -> str | content
  title: none,
  /// Cover's header
  /// -> str | content | none
  header: [],
  /// Cover's footer
  /// -> str | content | none
  footer: [],
  /// Authors of the document.\
  /// A list of name and NUSP (optional) in the following format:
  /// ```typ
  /// ( ([name1], [nusp]), ([name2], [nusp]) )
  /// ```
  /// -> array | none
  students: (),
  /// Teachers of the discipline.\
  /// A list of names in the following format:
  /// ```typ
  /// ( [name1], [name2] )
  /// ```
  /// -> array | none
  teachers: (), // ( [name1], [name2], ... )
  /// cover's logo image
  /// -> image | none
  logo: none,
  /// Prevent default pagebreak after cover
  /// -> bool
  no_pagebrake: false
) = {
  align(center + top)[
    #upper(header)
  ]

  align(if (logo == none) {
    center + horizon
  } else {
    center
  })[
    #line(length: 100%, stroke: (thickness: 3pt, cap: "round"))
    #text(title, weight: "bold", size: 20pt)
    #line(length: 100%, stroke: (thickness: 3pt, cap: "round"))
  ]

  if logo != none {
    set image(width: 70%)
    if type(logo) == str {
      align(center + horizon, image(logo, width: 70%))
    } else {
      align(center + horizon, logo)
    }
  }

  let valid_array(arr, default) = if (type(arr) == array and arr.len() > 0) {
    default
  }

  align(
    bottom,
    block[
      #set align(top)
      #grid(
        columns: (1.7fr, 1pt, 1fr),
        row-gutter: 10pt,
        valid_array(students)[_Aluno:_],
        [],
        valid_array(teachers)[_Professor:_],

        grid(
          columns: 1fr, row-gutter: 10pt,
          ..students.map(it => {
            if type(it) == array {
              let nome = it.at(0)
              let nusp = it.at(1)
              [- #nome #text(size: 9pt)[ | NUSP: #nusp ]]
            } else {
              [- #it]
            }
          })
        ),
        [],
        grid(
          columns: 1fr, row-gutter: 10pt,
          ..teachers.map(nome => {
            [- #nome]
          })
        ),
      )
      #v(1cm)
    ],
  )


  align(center + bottom)[
    #footer\
    #datetime.today().year()
  ]

  if not no_pagebrake {
    pagebreak(weak: true)
  }
}

/// Main template
/// -> content
#let politemplate(
  /// Title of the document
  /// -> str | content
  title: [Poli Template],
  /// cover's logo image
  /// -> image | none
  logo: none,
  /// Authors of the document.\
  /// A list of name and NUSP (optional) in the following format:
  /// ```typ
  /// ( ([name1], [nusp]), ([name2], [nusp]) )
  /// ```
  /// -> array | none
  students: (),
  /// Teachers of the discipline.\
  /// A list of names in the following format:
  /// ```typ
  /// ( [name1], [name2] )
  /// ```
  /// -> array | none
  teachers: (),
  /// Institution name
  /// -> str | content | none
  institution: [],
  /// Cover's header
  /// -> str | content | none
  front_header: none,
  /// Place where the document was written
  /// -> str | content | none
  location: [],
  /// bibliography
  bibliography: none,
  /// A list of header names where to not render the footer
  ///
  /// -> bibliography | none
  footer_ignore: none,
  /// Document content
  /// -> content
  doc,
) = [
  #set text(lang: "pt")

  // Footer Setup
  #set page(
    footer: {
      anchor()
      context {
        let curr_heading = hydra(1)
        if curr_heading == none or not curr_heading.has("children") {
          return
        }
        let heading_text = curr_heading.children.filter(it => it.has("text")).last().text
        
        if footer_ignore == none or not footer_ignore.contains(heading_text) {
          line(length: 100%)
          block()
          
          place(left, curr_heading)
          place(right, counter(page).display("1", both: false))
        }
        
      }
    }
  )

  // Frontpage
  #frontpage(
    title: title,
    logo: logo,
    students: students,
    teachers: teachers,
    header: [
      #institution

      #front_header
    ],
    footer: location,
  )
  

  // Heading setup
  #set heading(numbering: "1.")

  // // Break before headings. Ignore this behaviour by adding #metadata("nobreak") at the header's end
  // // i.e.: = Title #metadata("nobreak")
  #show heading.where(level: 1): it => {
    if it.has("body") and it.body.func() != text {
      let last = it.body.children.last()
      if last.func() == metadata and last.value == "nobreak" {
        return it
      }
    }
    
    pagebreak(weak: true) + it
  }
  
  // First line indentation and text justification
  #set par(
    first-line-indent: (
      amount: 1.5em,
      all: true,
    ),
    justify: true
  )
  
  // Outline setup
  #show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    strong(it)
  }

  #outline(indent: auto)
  
  #pagebreak(weak: true)

  // Content
  #doc

  // Show bibliography if a ".bib" file is provided
  #if (bibliography != none) {
    bibliography
  }
]
