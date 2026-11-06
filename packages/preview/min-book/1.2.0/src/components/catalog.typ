#let new(catalog, title, subtitle, authors, date, volume, edition) = {
  set par(
    first-line-indent: 0pt,
    spacing: 1em
  )
  set box(width: 1fr)
  set rect(
    width: 100% + 1em,
    inset: 0.5em
  )
  show rect: set align(center)
  
  if title == none {title = ""}
  if subtitle != none {title = title + " – " + subtitle}
  if authors == none {authors = ""}
  if volume == 0 {volume = ""}
  if edition == 0 {edition = 1}
  if catalog.publisher == none {catalog.publisher = ""}
  if catalog.place == none {catalog.place = ""}

  authors = if type(authors) == array {authors = authors.at(0) + " et al."}
    else {
      // Book Author -> Author, Book
      authors.replace(regex("^(.+)\s([^\s]+)$"), m => {
        if m.captures.len() == 2 {
          m.captures.last()
          ", "
          m.captures.first()
        }
        else {m.text}
      })
    }
  
  // Bibliographic citation data
  let bib = "
    this-book:
      type: book
      title: " + str(title) + "
      author: " + str(authors) + "
      date: " + str(date.year()) + "
      publisher: 
        name: " + str(catalog.publisher) + "
        location: " + str(catalog.place) + "
      location: " + str(catalog.place) + "
      volume: " + str(volume) + "
      edition: " + str(edition)
  
  catalog.before
  
  rect(align(
    left + top,
    {
    set par(hanging-indent: 1.5em)
    
    if catalog.id != none [#catalog.id.]
    parbreak()
    
    bibliography(title: none, bytes(bib), style: "chicago-notes", full: true)
    
    if catalog.isbn != none [ISBN #catalog.isbn.]
    parbreak()
    
    if catalog.subjects != () {
      for item in catalog.subjects.enumerate() {
        str(item.at(0) + 1) + ". " + item.at(1)
        h(8pt)
      }
    }
    if catalog.access != () {
      if type(catalog.access) == str {catalog.access = (catalog.access,)}
      
      for item in catalog.access.enumerate() {
        numbering("I.", item.at(0) + 1) + " " + item.at(1)
        h(8pt)
      }
    }
    parbreak()
    
    if catalog.ddc != none {box[]}
    if catalog.udc != none {box(align(center, catalog.udc))}
    if catalog.ddc != none {box(align(right, catalog.ddc))}
    })
  )
  
  catalog.after
}