#let resume(
  paper: "a4",
  top-margin: 0.4in,
  bottom-margin: 0.2in,
  left-margin: 0.3in,
  right-margin: 0.3in,
  font: "New Computer Modern",
  font-size: 11pt,
  personal-info-font-size: 10.5pt,
  author-name: "",
  author-position: center,
  personal-info-position: center,
  phone: "",
  location: "",
  email: "",
  website: "",
  linkedin-user-id: "",
  github-username: "",
  body
) = {
  set document(
    title: "Résumé | " + author-name,
    author: author-name,
    keywords: "cv",
    date: none
  )

  set page(
    paper: paper,
    margin: (
      top: top-margin, bottom: bottom-margin,
      left: left-margin, right: right-margin
    ),
  )

  set text(
    font: font, size: font-size, lang: "en", ligatures: false
  )

  show heading.where(
    level: 1
  ): it => block(width: 100%)[
    #set text(font-size + 2pt, weight: "regular")
    #smallcaps(it.body)
    #v(-1em)
    #line(length: 100%, stroke: stroke(thickness: 0.4pt))
    #v(-0.2em)
  ]

  let contact_item(value, link-type: "", prefix: "") = {
    if value != "" {
      if link-type != "" {
        underline(offset: 0.3em)[#link(link-type + value)[#(prefix + value)]]
      } else {
        value
      }
    }
  }

  align(author-position, [
    #upper(text(font-size+16pt, weight: "extrabold")[#author-name])
    #v(-2em)
  ])

  align(personal-info-position, text(personal-info-font-size)[    
    #{
      let sepSpace = 0.2em
      let items = (
        contact_item(phone),
        contact_item(location),
        contact_item(email, link-type: "mailto:"),
        contact_item(website, link-type: "https://"),
        contact_item(linkedin-user-id, link-type: "https://linkedin.com/in/", prefix: "linkedin.com/in/"),
        contact_item(github-username, link-type: "https://github.com/", prefix: "github.com/"),
      )
      items.filter(x => x != none).join([
        #show "|": sep => {
          h(sepSpace)
          [|]
          h(sepSpace)
        }
        |
      ])
    }
  ])

  body
}

// ---
// Custom functions

#let generic_1x2(r1c1, r1c2) = {
  grid(
    columns: (1fr, 1fr),
    align(left)[#r1c1],
    align(right)[#r1c2]
  )
}

#let generic_2x2(cols, r1c1, r1c2, r2c1, r2c2) = {
  // sanity checks
  assert.eq(type(cols), array)

  grid(
    columns: cols,
    align(left)[#r1c1 \ #r2c1],
    align(right)[#r1c2 \ #r2c2]
  )
}

#let custom-title(title, spacing-between: -0.5em, body) = {
  [= #title]
  body
  v(spacing-between)
}

// Custom list to be used inside custom-title section.
#let skills(body) = {
  if body != [] {
    set par(leading: 0.6em)
    set list(
      body-indent: 0.1em,
      indent: 0em,
      marker: []
    )
    body
  }
}

// Converts datetime format into readable period.
#let period_worked(start-date, end-date) = {
  // sanity checks
  assert.eq(type(start-date), datetime)
  assert(type(end-date) == datetime or type(end-date) == str)

  if type(end-date) == str and end-date == "Present" {
    end-date = datetime.today()
  }

  return [
      #start-date.display("[month repr:short] [year]") -- 
      #if (
        (end-date.month() == datetime.today().month()) and 
        (end-date.year() == datetime.today().year())
      ) [
        Present
      ] else [
        #end-date.display("[month repr:short] [year]")
      ]
  ]
}

// Pretty self-explanatory.
#let work-heading(title, company, location, start-date, end-date, body) = {
  // sanity checks
  assert.eq(type(start-date), datetime)
  assert(type(end-date) == datetime or type(end-date) == str)

  generic_2x2(
    (1fr, 1fr),
    [*#title*], [*#period_worked(start-date, end-date)*], 
    [#company], emph(location)
  )
  v(-0.2em)
  if body != [] {
    v(-0.4em)
    set par(leading: 0.6em)
    set list(indent: 0.5em)
    body
  }
}

// Pretty self-explanatory.
#let project-heading(name, stack: "", project-url: "", body) = {
  if project-url.len() != 0 { link(project-url)[*#name*] } else {
    [*#name*] 
  }
  if stack != "" {
    [
      #show "|": sep => { h(0.3em); [|]; h(0.3em) }
      |*#stack*
    ]
  }
  v(-0.2em)
  if body != [] {
    v(-0.4em)
    set par(leading: 0.6em)
    set list(indent: 0.5em)
    body
  }
}

// Pretty self-explanatory.
#let education-heading(institution, location, degree, major, start-date, end-date, body) = {
  // sanity checks
  assert.eq(type(start-date), datetime)
  assert(type(end-date) == datetime or type(end-date) == str)

  generic_2x2(
    (70%, 30%),
    [*#institution*], [*#location*], 
    [#degree, #major], period_worked(start-date, end-date)
  )
  v(-0.2em)
  if body != [] {
    v(-0.4em)
    set par(leading: 0.6em)
    set list(indent: 0.5em)
    body
  }
}

// #let work_highlights(..points)  = {
//   v(-0.4em)
//   list(
//     indent: 0.4em,
//     ..((..l) => {
//       let new_array = ()
//       for item in l.pos() {
//         new_array.push(par(leading: 0.55em)[#item])
//       }
//       return new_array
//     })(..points)
//   )
// }
