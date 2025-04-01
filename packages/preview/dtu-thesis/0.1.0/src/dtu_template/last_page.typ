#let last_page(
  department: "",
  university: "",
  addressI: "",
  addressII: "",
  departmentwebsite: "",
  body) = {
  set page(
    footer: [],
    numbering: none, 
    margin: auto,
    fill: rgb("#224ea9")
  )

  set text(
    font: "Libertinus Serif",
    lang: "en",
    size: 11pt,
    fill: white
  )
  place(
    left + bottom,
    [
      #department \
      #university

      #v(1em)

      #addressI \
      #addressII

      #v(1em)

      #link(
        "https://"+departmentwebsite,
        departmentwebsite
      )
    ]
  )
  
  body
}