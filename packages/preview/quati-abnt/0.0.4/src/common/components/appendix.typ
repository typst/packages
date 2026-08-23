// # Appendix. Apêndice.
// NBR 14724:2024 4.2.3.3

#let include_appendix(
  title: "",
  label: none,
  body,
) = {
  // Appendixes must be numbered with letters
  set heading(numbering: "A.1.1")

  [
    // When referenced, appendixes must have the supplement "Apêndice"
    #heading(supplement: "Apêndice", title)#label
    #body
  ]
}
