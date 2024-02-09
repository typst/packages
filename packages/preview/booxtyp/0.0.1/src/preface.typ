#let preface(body, title: [Preface]) = {
  // Do not number or outline the preface
  heading(numbering: none, outlined: false)[#title]

  // Preface content
  body
}
