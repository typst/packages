
// Formating Config of the Appendix
#let format-appendix(body) = {
  
  // Set - Pages
  // --------------------------------------------------------
  set page(
    footer: context {
      set align(center)
      set text(11pt)
      [Appendix - ]
      counter(page).display("1 / 1", both: true)
  })

  
  // Set - Headings
  // --------------------------------------------------------
  set heading(
    numbering: "A.1.",
    supplement: [Appendix],
  )

  
  // Style - Appendix Title
  // --------------------------------------------------------
  show <appendix>: set text(size: 25pt,)

  
  // Body
  // --------------------------------------------------------
  counter(page).update(1)
  counter(heading).update(0)
  
  pagebreak()
  
  heading(
    level: 1, 
    numbering: none, 
    [#underline[Appendix]<appendix>]
  )
  
  body
}
