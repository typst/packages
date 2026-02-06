#let last-page(
  department: "",
  university: "",
  address-i: "",
  address-ii: "",
  departmentwebsite: "",
  background-color: rgb("#224ea9"),
  body) = {
  set page(
    footer: [],
    numbering: none, 
    margin: auto,
    fill: background-color
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

      #address-i \
      #address-ii

      #v(1em)

      #link(
        "https://"+departmentwebsite,
        departmentwebsite
      )
    ]
  )
  
  body
}