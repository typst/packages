#let delimiter = " | "

#let array-to-str(a, delimiter: delimiter) = {
   a.join(delimiter)
}

#let resume-contacts(contact) = {
   set align(center)
   array-to-str(contact)
}

// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(title: "", author: (), contacts: (), body) = {
  // Set the document's basic properties.
  set document(author: author.name, title: title)
  set page(
    /// Margins of the page
    margin: (x: 1cm, y:1cm),
  )
    
  // set text(font: "Linux Libertine", lang: "en")
  set text(font: "Noto Serif CJK SC", lang: "zh")
    
  // Title row.
  align(center)[
    #block(text(weight: 700, 1.7em, author.name))
  ]
  
  resume-contacts(contacts)

  // Main body.
  set par(justify: true)

  body
}

#let format-date(date) = {
  if type(date) == datetime [date.display()] 
  else if type(date) == str and date.len() == 0 [今] 
  else if type(date) == str {
    date
  } else {
    // todo panic
  }
}

#let resume-date(start, end: "") = {
  if start == "" and end == "" {
    "" 
  } else {
    format-date(start) + " " + $dash.en$ + " " + format-date(end)
  }
}

#let resume-item(left:"", right:"", body) = {
  text(size: 12pt, place(end, right))
  text(size: 12pt, left)
  linebreak()
  body
}

#let resume-education(university: "", degree: "", school: "", start: "", end: "", body) = {
  let left = (strong(university), school, degree)
  let right = resume-date(start, end: end);
  
  resume-item(
    left: array-to-str(left),
    right: right,
    body
  )
}

#let resume-work(company: "", duty: "", start: "", end: "", body) = {
  let left = (strong(company), duty)
  let right = resume-date(start, end: end)

  resume-item(
    left: array-to-str(left),
    right: right,
    body
  )
}

#let resume-project(title: "", duty: "", start: "", end: "", body) = {
  let left = (strong(title), duty)
  let right = resume-date(start, end: end)

  resume-item(
    left: array-to-str(left),
    right: right,
    body
  )
}

#let resume-section(title) = {
  v(-8pt)
  heading(level:1, title)
  line(length: 100%)
  v(-2pt)
}
