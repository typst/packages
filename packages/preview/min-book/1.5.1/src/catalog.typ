#let insert(catalog, meta) = {
  set par(
    first-line-indent: 0pt,
    spacing: 1em
  )
  set rect(
    width: 100%,
    inset: (x: 0pt, y: 0.5em),
    outset: (x: 0.5em, y: 0pt),
  )
  set bibliography(
    title: none,
    style: catalog.bib-style,
    full: true
  )
  
  show rect: set align(center + bottom)
  
  if catalog.publisher == none {catalog.publisher = ""}
  if catalog.place == none {catalog.place = ""}
  if type(catalog.subjects) == str {catalog.subjects = (catalog.subjects,)}
  if type(catalog.access) == str {catalog.access = (catalog.access,)}
  if type(catalog.before) == str {catalog.before = eval(catalog.before, mode: "markup")}
  if type(catalog.after) == str {catalog.after = eval(catalog.after, mode: "markup")}
  
  let bib = read("assets/catalog.yaml") // bibliographic citation data
  let classes = ()
  let data
  
  if catalog.ddc != none {classes.push(none)}
  if catalog.udc != none {classes.push(catalog.udc)}
  if catalog.ddc != none {classes.push(catalog.ddc)}
  
  meta.title = meta.title + if meta.subtitle != none {" – " + meta.subtitle}
  meta.title = meta.title.replace("\n", " ")
  meta.authors = if type(meta.authors) == array {meta.authors.at(0) + " et al."} else {
    meta.authors.replace(regex("^(.+)\s([^\s]+)$"), m => {
      // Author, Book
      if m.captures.len() == 2 {m.captures.last() + ", " + m.captures.first()}
      else {m.text}
    })
  }
  bib = bib
    .replace("TITLE", str(meta.title))
    .replace("AUTHORS", str(meta.authors))
    .replace("DATE", str(meta.date.year()))
    .replace("PUBLISHER", str(catalog.publisher))
    .replace("PLACE", str(catalog.place))
    .replace("VOLUME", str(meta.volume))
    .replace("EDITION", str(meta.edition))

  data = {
    set align(start + top)
    set par(hanging-indent: 1.5em)
    
    catalog.id
    
    bibliography(bytes(bib))
    
    if catalog.isbn != none {"ISBN " + catalog.isbn}
    parbreak()
    
    for item in catalog.subjects.enumerate() {
      str(item.at(0) + 1) + ". " + item.at(1)
      h(8pt)
    }
    for item in catalog.access.enumerate() {
      numbering("I.", item.at(0) + 1) + " " + item.at(1)
      h(8pt)
    }
    parbreak()
    
    grid(
      ..classes,
      columns: (1fr,) * classes.len(),
      align: center
    )
  }
  
  catalog.before
  
  rect(data)
  
  catalog.after
}