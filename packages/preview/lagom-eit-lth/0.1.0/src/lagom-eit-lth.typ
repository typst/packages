#import "global.typ": *
#import "print.typ": *
#import "style.typ": *
#import "logic.typ": frontmatter, mainmatter, backmatter, _reset-counters, _in-outline

#let template-version = version(0,1,0) // Change when changes are made to the template, used to distinguish from original

// Custom captions, used when wanting two different texts from the main body and the outline
#let flex-caption(long, short) = context if state("in-outline").get() { short } else { long }

//---------------------------------------------|  THESIS  |---------------------------------------------//

// Thesis template
#let thesis(
  thesis-title: none,
  thesis-title-sv: none,
  thesis-subtitle: none,
  thesis-subtitle-sv: none,
  short-title: [#degree-level-en's thesis],
  authors: none,
  supervisors: none,
  examiner: none,
  course-code: [EITM01],
  affiliations: none,
  description: none,
  keywords: (),
  document-style: "revised",
  front-cover-background: rect(width: 100%, height: 100%, fill: lu-light-brown),
  date: datetime.today(),
  report-number: none,
  issn: none,
  print: false,
  body
  ) = {

// Assertions for required arguments
  assert(thesis-title != none, message: "Missing required argument 'thesis-title'.")
  assert(authors != none, message: "Missing required argument 'authors'.")
  assert(supervisors != none, message: "Missing required argument 'supervisors'.")
  assert(examiner != none, message: "Missing required argument 'examiner'.")

  // Assertions for variable types
  assert(type(authors) == array, 
    message: "Variable 'authors' must be of type array ((name, email),)."
  )
  assert(type(supervisors) == dictionary, 
    message: "Variable 'supervisors' must be of type dictionary (academic: (name, email, affiliation), company: (name, email, affiliation))."
  )
  assert(type(examiner) == dictionary,  
    message: "Variable 'examiner' must be of type dictionary (name, email)."
  )
  assert(type(keywords) == array, 
    message: "Variable 'keywords' must be of type array."
  )
  assert(type(print) == bool, 
    message: "Variable 'print' must be of type boolean."
  )
  assert(type(date) == datetime, 
    message: "Variable 'date' must be of type datetime."
  )
  assert(type(front-cover-background) == content, 
    message: "Variable 'front-cover-background' must be of type content."
  )

  // Assertions for logic and specific values
  assert(not (report-number == none and print), message: "Thesis must have a report-id to be printed!")
  
  assert(document-style in ("original", "revised"), 
    message: "Variable 'doucument-style' must be either 'original' (default) or 'revised'."
  )

  if document-style == "original"{
    state("header").update(_header-original())
    state("heading").update(_ => _heading-original)
  }
  else if document-style == "revised"{
    state("header").update(_header-alternating())
    state("heading").update(_ => _heading-new)
  }
  
  // Set rules
  set document(
    title: thesis-title,
    author: authors.map(author => author.name),
    description: description,
    keywords: keywords,
    date: date
  )
  
  set par(
    justify: true, 
    first-line-indent: 1.5em, 
    spacing: 1.5em,
    leading: 0.5em
  )

  set page(
    number-align: center + bottom,
    footer-descent: 0% + 7.5mm,
    header-ascent: 0% + 7.5mm,
    binding: left
  )

  // Calculated necessary margins for the document depending if print == true or false. sis-g5 has dimensions 169x239mm
  let (g5-width, g5-height) = (169mm, 239mm)
  let (a4-width, a4-height) = (210mm, 297mm)
  let (a4-offset-width, a4-offset-height) = ((a4-width - g5-width) / 2, (a4-height - g5-height) / 2)
  
  let (body_width, body_height) = (125mm, 200mm)
  let inside = 1in
  let outside = g5-width - inside - body_width
  let vertical =  (g5-height - body_height) / 2

  // Sets only if print == false, adds a G5 box to the pages and some information on top
  set page(
    paper: "a4",
    margin: (
      inside: inside + a4-offset-width,
      outside: outside + a4-offset-width,
      rest: vertical + a4-offset-height,
      ),
    background: [
      #set text(size: 12pt)
      #place(center, dy: 22.5mm, stack(
        dir: ltr,
        spacing: 1cm,
        emph(short-title),
        date.display("[year]/[month padding:none]/[day padding:none]"),
        [page #context(counter(page).display())],
        [#sym.hash #context(here().page())]
      ))
      #align(center + horizon, rect(stroke: 0.2mm, width: g5-width, height: g5-height))
    ]
  ) if print == false

  set page(
    paper: "sis-g5",
    margin: (
      inside: inside,
      outside: outside,
      rest: vertical
    ),
  ) if print == true
  
  // Text
  set text(
    lang: "en",
    font: font-main,
    fill: colour-main,
    weight: "regular",
    size: size-main,
  )

  show smallcaps: set text(tracking: 0.5pt)
  
  // Line
  set line(length: 100%,
    stroke: (
      thickness: 0.75pt,
      cap: "round")
    )

  // Footnotes
  show footnote.entry: set text(fill: colour-secondary)
  set footnote.entry(
    separator: line(length: 30%, stroke: 0.5pt + colour-secondary),
    gap: 1em
  )

  // Figures
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: raw): set block(breakable: true)
  show figure: block.with(above: 3em, below: 3em)
  show figure.caption: it => {
    set text(font: font-secondary, size: size-secondary)
    block(width: 75%)[
      #strong([#it.supplement #context{it.counter.display(it.numbering)}#it.separator])
      #text(fill: colour-secondary)[#it.body]
    ]
  }

  // Tables
  show table.cell.where(y: 0): strong
  set table(
    inset: (x: 8pt, y: 4pt),
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  {rgb("#efefef")}
  )

  // Terms, used mainly in the abbreviations or nomenclature section
  set terms(tight: false, spacing: 5mm)

  // Equations
  set math.equation(supplement: none)
  show math.equation: set text(font: font-math)
  
  //Raw text (Code)
  set raw(block: true, align: start, tab-size: 4, theme: "theme.tmTheme")
  show raw: set text(fill: luma(5%), font: "Source Code Pro")
  show raw.where(block: true): block.with(fill: luma(98%), inset: 20pt, radius: 3pt, width: 100%, stroke: 0.5pt + luma(80%))
  show raw.where(block: true): it => {
    show raw.line: line => {
      box(grid(columns: (1em, 2em, 1fr), text(fill: luma(25%), [#line.number]), none, line))
    }
    it
  }

  // Outline
  // Creates a different style of outline for figures with field kind, otherwise shows the ordinary outline. The ordinary outline is customized with set and show rules
  let outline-entry(it) = {
    let a = 0
    context {
        if it.element.has("kind") {
            let loc = it.element.location()
            if counter(figure.where(kind: it.element.kind)).at(loc).last() == 1 {block(above: 1em)}
            block(above: 1em,
            link(loc,
                box(strong(it.prefix().children.at(2)), width: 7.5mm)
                + it.body()
                + box([#align(center, block(width: 100% - 5mm, repeat(".", gap: 2mm)))], width: 1fr)
                + it.page()
              )
          )
        }
        else {
         it
        }
    }
  }

  set outline(depth: 2, indent: 1em)
  show outline.entry.where(level: 1): set outline.entry(fill: [#align(center, line(length: 100% - 5mm))])
  show outline.entry.where(level: 1): strong
  show outline.entry.where(level: 1): set block(above: 2em)
  show outline.entry.where(level: 2): set outline.entry(fill: [#align(center, block(width: 100% - 5mm, repeat(".", gap: 2mm)))])
  show outline.entry.where(level: 2): set block(above: 1em)
  
  //Outline for figures, equations, etc.
  show outline: it => {
    _in-outline.update(true)
    it
    _in-outline.update(false)
  }
  show outline.entry: outline-entry
  
  // Headings
  set heading(supplement: [Section])
  show heading: set text(weight: "semibold")
  show heading: set par(leading: 1em, justify: false)
  show heading.where(level: 1): set heading(supplement: [Chapter])
  show heading.where(level: 1): set block(below: 3em)
  show heading.where(level: 2): set block(above: 2em, below: 1em)
  show heading.where(level: 2): set text(size: size-sub-heading)
  show heading.where(level: 3): set block(above: 1.5em, below: 1em)
  show heading.where(level: 3): set text(size: size-sub-sub-heading)
  
  // Figures out which heading to place depending on the state of the document
  show heading.where(level: 1): it => context{ pagebreak(weak: true, to: "odd") + _reset-counters() + state("heading").get()(it)}
  
  // Bibliography
  set bibliography(title: "References" ,style: "ieee")

  // Quotes
  set quote(block: true)
  show quote: set block(inset: 2mm)

  // Beginning of document
  
  // Front cover page, if print is true
  if print == true {_front-cover-page(
    thesis-title,
    front-cover-background,
    authors,
    degree-level-en,
    department-en,
  )}

  // Blank page
  if print == true {
    page(align(bottom + left, text(style: "italic", "Blank page — remove in final print.")))
    pagebreak(to: "odd")
  }
  
  // Title page
  _title-page(
    thesis-title, 
    thesis-subtitle,
    authors,
    supervisors,
    examiner,
    degree-level-en,
    department-en,
    ("../assets/LU-BLACK-ENG.png",) + if affiliations != none {
      affiliations.map(affiliation => affiliation.logo)
    },
    date
  )
  
  // Information of thesis, on verso of title page
  _information-page(
    thesis-title,
    thesis-title-sv,
    thesis-subtitle,
    thesis-subtitle-sv,
    authors,
    if affiliations != none {affiliations.map(affiliation => affiliation.name)},
    supervisors,
    examiner,
    course-code,
    issn,
    department-en,
    date
  )

  counter(page).update(1)
  body

  // Backcover, if print is true
  if print == true {_back-cover(
    degree-level-en,
    department-en,
    department-short-en,
    department-link,
    report-number,
    date)}
}

//---------------------------------------------|  POPULAR SCIENCE SUMMARY |---------------------------------------------//

// Template for the popular science summary paper. Based on the LaTeX version from department of computer science (CS) at LTH.
#let popular-science-summary(
  summary-title: none,
  original-title: none,
  authors: none,
  supervisors: none,
  examiner: none,
  lead-paragraph: none,
  thesis-link: none,
  presentation-date: datetime.today(),
  lang: "sv",
  body
) = {
  
  // Assertions for required arguments
  assert(summary-title != none, message: "Missing required argument 'summary-title'.")
  assert(original-title != none, message: "Missing required argument 'original-title'.")
  assert(authors != none, message: "Missing required argument 'authors'.")
  assert(supervisors != none, message: "Missing required argument 'supervisors'.")
  assert(examiner != none, message: "Missing required argument 'examiner'.")
    
  // Assertions for logic and specific values
  assert(lang in ("sv", "en"), 
    message: "Variable 'lang' must be either 'en' or 'sv' ('sv' by default)."
  )
  
  // Assertions for variable types
  assert(type(authors) == array, 
    message: "Variable 'authors' must be of type array."
  )
  assert(type(supervisors) == dictionary, 
    message: "Variable 'supervisors' must be of type dictionary (academic: (name, email, affiliation), company: (name, email, affiliation))."
  )
  assert(type(examiner) == dictionary, 
    message: "Variable 'examiner' must be of type dictionary (name, email)."
  )
  assert(type(presentation-date) == datetime, 
    message: "Variable 'presentation-date' must be of type datetime.")

  // Dictionary containing predetermined words and sentences in both english and swedish.
  let language-fields = (
    sv: (
      department: department-sv,
      faculty: "LTH | Lunds Universitet",
      degree-project: "Examensarbete",
      student-singular: "Student",
      students-plural: "Studenter",
      supervisor-singular : "Handledare",
      supervisors-plural : "Handledare",
      examiner: "Examinator",
      popular-science-summary: "Populärvetenskaplig sammanfattning",
      presented: "Presenterad",
      availability: "Tillgänglig vid",
      figure-supplement: "Figur",
      and-label: "och"
    ),
    
    en: (
      department: department-en,
      faculty : "LTH | Lund University",
      degree-project : "Degree Project",
      student-singular : "Student",
      students-plural: "Students",
      supervisor-singular : "Supervisor",
      supervisors-plural : "Supervisors",
      examiner: "Examiner",
      popular-science-summary: "Popular Science Summary",
      presented: "Presented",
      availability: "Available at",
      figure-supplement: "Figure",
      and-label: "and"
    )
  )

  // Information box about the degree project found in the top of the paper
  let information() = {
    set text(size: size-secondary)
    set par(first-line-indent: 0pt, spacing: 5mm)
    
    let spacing = 0.5em
    let students = ""
    let supervisor-label = ""
    
    if authors.len() > 1 {students = "students-plural"} else {students = "student-singular"}
    if supervisors.len() > 1 {supervisor-label = "supervisors-plural"} else {supervisor-label = "supervisor-singular"}
    box(
      stroke: (left: (thickness: 1pt, paint: lu-bronze, cap: "round")),
      outset: 3mm,
      [
        #language-fields.at(lang).at("department") | #language-fields.at(lang).at("faculty") | #language-fields.at(lang).at("presented") #presentation-date.display("[day padding:none] [month repr:long] [year]") 
        
        #parbreak()
        
        #strong(upper(language-fields.at(lang).at("degree-project"))) #h(spacing) #original-title #linebreak()
        #strong(upper(language-fields.at(lang).at(students))) #h(spacing) #authors.map(author => author.name).join(", ", last: " & ")
        #linebreak()
        #strong(upper(language-fields.at(lang).at(supervisor-label))) #h(spacing) #supervisors.values().map(supervisor => [#supervisor.name (#supervisor.affiliation)]).join(", ", last: " " + language-fields.at(lang).at("and-label") + " ") #linebreak()
        #strong(upper(language-fields.at(lang).at("examiner"))) #h(spacing) #examiner.name

        #parbreak()

        #if thesis-link != none [#language-fields.at(lang).at("availability") #link(thesis-link)]
      ]
    )
  }

  set text(size: size-main, font: font-secondary, lang: lang)
  
  set heading(level: 2, outlined: false, bookmarked: false)
  show heading: it => context {h(- par.first-line-indent.amount); it.body + [ ]}
  show heading: set text(font: font-main, fill: lu-bronze)
  show heading: smallcaps
  
  set figure(supplement: language-fields.at(lang).at("figure-supplement"), numbering: "1")
  set document(
    author: authors.map(author => author.name),
    date: presentation-date,
    title: summary-title
  )
  set par(justify: true, first-line-indent: (amount: 1em, all: true))
  
  show title: set text(size: size-heading, font: font-main,  fill: lu-bronze)
  
  show link: set text(fill: lu-blue)
  
  // The paper itself
  page(margin: (top: 1.5cm, rest: 2cm))[
    #block(below: 2em, 
      grid(
        rows: 4,
        gutter: 1.5em,
        information(),
        [#language-fields.at(lang).at("popular-science-summary") | *#authors.map(author => author.name).join(", ", last: " & ")*],
        title(),
        par(first-line-indent: 0pt, strong(text(lead-paragraph, font: font-main, size: size-sub-sub-heading)))
      )
    )
    #columns(2, gutter: 2em, body)
  ]
}

//---------------------------------------------|  GOAL DOCUMENT |---------------------------------------------//

// Template for the goal document. Based on the docx template provided by Peter Nilsson at EIT.
#let goal-document(
  tentative-title: none,
  authors: none,
  start-date: none,
  end-date: none,
  course-code: none,
  academic-supervisor: none,
  examiner: none,
  lang: "en",
  body
) = {

  // Assertions for required arguments
  assert(tentative-title != none, message: "Missing required argument 'tentative-title'.")
  assert(authors != none, message: "Missing required argument 'authors'.")
  assert(start-date != none, message: "Missing required argument 'start-date'.")
  assert(end-date != none, message: "Missing required argument 'end-date'.")
  assert(course-code != none, message: "Missing required argument 'course-code'.")
  assert(academic-supervisor != none, message: "Missing required argument 'academic-supervisor'.")
  assert(examiner != none, message: "Missing required argument 'examiner'.")

  // Assertions for logic and specific values
  assert(lang in ("sv", "en"), 
    message: "Variable 'lang' must be either 'sv' or 'en' ('en' by default)."
  )

  // Assertions for variable types
  assert(type(authors) == array, 
    message: "Variable 'authors' must be of type array."
  )
  assert(type(start-date) == datetime, 
    message: "Variable 'start-date' must be of type datetime."
  )
  assert(type(end-date) == datetime, 
    message: "Variable 'end-date' must be of type datetime."
  )

  // Dictionary containing predetermined words and sentences in both english and swedish.
  let language-fields = (
    sv : (
      subtitle-phrase: "Ett Måldokument för Examensarbete på " + str(degree-level-sv),
      by-phrase: "Av",
      department-phrase: [#department-sv \ Lunds Tekniska Högskola, LTH, Lunds Universitet \ SE-221 00 Lund, Sverige],
      student-singular: "Student",
      student-plural: "Studenter",
      civic-number-singular: "Personnummer",
      civic-number-plural: "Personnummer",
      email: "Mailadress",
      academic-supervisor: "Huvudhandledare",
      examiner: "Examinator",
      project-start: "Arbetet börjar",
      project-end: "Arbetet avslutas",
      course-code: "Kurskod",
      and-label: " och ",
      signing-line: "Detta måldokument är godkänt av",
    ),
    en: (
      subtitle-phrase: "A Goal Document for " + str(degree-level-en) +  "'s Thesis Work",
      by-phrase: "By",
      department-phrase: [#department-en \ Faculty of Engineering, LTH, Lund University \ SE-221 00 Lund, Sweden],
      student-singular: "Student",
      student-plural: "Students",
      civic-number-singular: "Civic registration number",
      civic-number-plural: "Civic registration numbers",
      email: "Email address",
      academic-supervisor: "Main supervisor",
      examiner: "Examiner",
      project-start: "Project start",
      project-end: "Project end",
      course-code: "Course code",
      and-label: " and ",
      signing-line: "This goal document is approved by"
    )
  )

  // Prints information about the degree project
  let information() = {
    let student-label = ""
    let civic-number-label = ""
    if authors.map(author => author.name).len() > 1 {student-label = "student-plural"} else {student-label = "student-singular"}
    if authors.map(author => author.civic-number).len() > 1 {civic-number-label = "civic-number-plural"} else {civic-number-label = "civic-number-singular"}
    
    block(stroke: (left: (thickness: 1pt)), outset: 2mm)[
      #set par(leading: 0.75em)
      #language-fields.at(lang).at(student-label): #authors.map(author => author.name).join(", ", last: language-fields.at(lang).at("and-label")) 
      #linebreak()
      #language-fields.at(lang).at(civic-number-label): #authors.map(author => author.civic-number).join(", ", last: language-fields.at(lang).at("and-label")) #linebreak()
      #language-fields.at(lang).at("email"): #authors.map(author => author.email).join(",", last: language-fields.at(lang).at("and-label"))
      #linebreak()
      #language-fields.at(lang).at("academic-supervisor"): #academic-supervisor.name, #link("mailto:" + academic-supervisor.email )
      #linebreak()
      #language-fields.at(lang).at("examiner"): #examiner.name, #link("mailto:" + examiner.email)
      #linebreak()
      #language-fields.at(lang).at("project-start"): #start-date.display()
      #linebreak()
      #language-fields.at(lang).at("project-end"): #end-date.display()
      #linebreak()
      #language-fields.at(lang).at("course-code"): #course-code
    ]
  }

  // Area used for signing the document
  let signing() = {
    language-fields.at(lang).at("signing-line") + ":"
    v(0.5em)
    grid(columns: (1fr, 1fr), rows: (auto, 1cm, auto), row-gutter: 1em, column-gutter: 2cm,
      language-fields.at(lang).at("academic-supervisor"),
      language-fields.at(lang).at("examiner"),
      box(height: 100%, width: 90%, stroke: (bottom: (thickness: 1pt))),
      box(height: 100%, width: 90%, stroke: (bottom: (thickness: 1pt))),
      academic-supervisor.name,
      examiner.name)
  }
  set heading(numbering: "1. ")
  show heading: set text(font: font-main)
  set text(font: font-secondary, lang: lang)
  set figure(supplement: [Fig])
  set page(numbering: "1/1")

  set document(
    author: authors.map(author => author.name),
    title: tentative-title,
  )
  
  //Title page
  page(numbering: none)[
    #set text(font: font-main, size: size-sub-sub-heading)
    #set align(horizon + center)
    #show title: set text(size: size-heading + 2pt)
    #place(top + left, image("../assets/LU-RGB-ENG.png", width: 3cm))
    #block(height: 40%,
      grid(columns: 1, rows: auto, row-gutter: 1fr,
        title(),
        text(size: size-sub-heading, language-fields.at(lang).at("subtitle-phrase")),
        [#language-fields.at(lang).at("by-phrase") \
        #stack(dir: ltr, spacing: 2em, ..authors.map(author => author.name))],
        language-fields.at(lang).at("department-phrase"),
        text(size: size-sub-heading, str(start-date.year()))
      )
    )
  ]

  counter(page).update(1)
  block(below: 3em, information())
  
  body
  
  block(above: 2cm, signing())
}

//---------------------------------------------|  PROJECT PLAN  |---------------------------------------------//

// Template for the project plan, used after the goal document but in the same .typ file. Based on the docx template by Peter Nilsson at EIT
#let project-plan(
  academic-supervisor: none,
  examiner: none,
  lang: "en",
  body
) = {
  
  // Assertions for required arguments
  assert(academic-supervisor != none, 
    message: "Missing required argument 'academic-supervisor'.")
  assert(examiner != none,
    message: "Missing required argument 'examiner'.")

  // Assertions for logic and specific values
  assert(lang in ("sv", "en"),
    message: "Variable lang must be either 'sv' or 'en' ('en' by default).")

  let language-fields = (
    sv : (
      academic-supervisor: "Huvudhandledare",
      examiner: "Examinator",
      signing-line: "Denna projektplan är godkänd av"
    ),
    en: (
      academic-supervisor: "Main Supervisor",
      examiner: "Examiner",
      signing-line: "This project plan is approved by"
    )
  )

  // Area used for signing the document
  let signing() = {
    language-fields.at(lang).at("signing-line") + ":"
    v(0.5em)
    grid(columns: (1fr, 1fr), rows: (auto, 1cm, auto), row-gutter: 1em, column-gutter: 2cm,
      language-fields.at(lang).at("academic-supervisor"),
      language-fields.at(lang).at("examiner"),
      box(height: 100%, width: 90%, stroke: (bottom: (thickness: 1pt))),
      box(height: 100%, width: 90%, stroke: (bottom: (thickness: 1pt))),
      academic-supervisor.name,
      examiner.name)
  }
  set text(font: font-secondary, lang: lang)
  set figure(supplement: [Fig])

  body 

  block(above: 2cm, signing())
}