// # Annex. Anexo.
// NBR 14724:2024 4.2.3.4

#let include_annex(
  title: "",
  label: none,
  body,
) = {
  // Annexes must be numbered with letters
  set heading(numbering: "A.1.1")

  [
    // When referenced, annexes must have the supplement "Anexo"
    #heading(supplement: "Anexo", title)#label
    #body
  ]
}
