// back-matter.typ
//
// Extended summaries, appendix, and Lebenslauf. Placement follows the
// old LaTeX template: the extended summary in the other language sits
// in the front matter before the text, the one in the thesis language
// follows the last chapter of the text as an unnumbered chapter. Both
// are optional. Fakultät 2 asks for a German and an English summary of
// two to four pages each, which the two abstracts cover. The Lebenslauf
// may be at most one page per § 13 (3).

#let summary-section(body) = {
  heading(level: 1, numbering: none, outlined: true)[Summary]
  body
}

#let zusammenfassung-section(body) = {
  heading(level: 1, numbering: none, outlined: true)[Zusammenfassung]
  body
}

// Appendix. Restarts the chapter count and letters the chapters, so
// level-1 headings read A, B, ... and deeper ones A.1, A.1.1.
#let appendix-section(body) = {
  counter(heading).update(0)
  set heading(numbering: (..nums) => {
    let n = nums.pos()
    let letter = numbering("A", n.first())
    if n.len() == 1 { letter } else { letter + "." + n.slice(1).map(str).join(".") }
  })
  body
}

#let lebenslauf-section(body, language: "english") = {
  let label = if language == "german" { "Lebenslauf" } else { "Curriculum Vitae" }
  heading(level: 1, numbering: none, outlined: true)[#label]
  body
}
