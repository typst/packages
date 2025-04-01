#let last-page(
  department: "",
  university: "",
  address-I: "",
  address-II: "",
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

      #address-I \
      #address-II

      #v(1em)

      #link(
        "https://"+departmentwebsite,
        departmentwebsite
      )
    ]
  )
  
  body
}