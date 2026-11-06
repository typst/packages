// This file is provided under the ISC license,
// as described in the LICENSE.md at the root of this directory.

#let bilingual(en, fr) = [ #en \ (#text(luma(80))[#fr]) ]

// ANR explanations about each section, grayed out
#let comment(doc) = [
  #set text(luma(120))
  #doc
]

// ANR explanations in footnotes, grayed out
#let __footnote(doc) = footnote(comment(doc))
#let footnote(doc) = __footnote(doc)

#let title(doc) = {
  align(center, text(17pt)[*#doc*])
}

#let style(
  short-project-name: smallcaps[InterestingProject],
  AAPG: [AAPG2099],
  CES: [CES 48 - Fondements du numérique : informatique, automatique, traitement du signal],
  instrument: [JCJC / PRCI / PRCE / PME],
  coordinator: [Coordinator Name],
  duration: [99 years],
  funding-request: [999,999,999],
  doc
) = {
  set page(
    paper: "a4",

    // imitate the header of the .docx template
    header: align(center)[#table(
  	columns: (0.8fr, 1fr, 0.4fr, 0.6fr),
	align: left,
  	stroke: none,
  	AAPG, [*#short-project-name*], table.cell(colspan: 2, [*#instrument*]),
  	[Coordinated by:], [#coordinator], [#duration], [#funding-request €],
  	table.cell(colspan: 4, [#CES]),
  	table.hline()
    )],

    // 2cm margins are recommended in the ANR-provided template
    // use 3cm at the top to leave space for the header
    margin: (x: 2cm, top: 3cm, bottom: 2cm),

    // page numbers
    numbering: "1",
  )

  // 11pt text is recommended  in the ANR-provided template
  set text(11pt)

  // Imitate the heading numbers of the .docx template:
  // I. II. III. for sections
  // a. b. c. for subsections (without repeating the section number)
  // nothing below
  let anr_numbering(..nums) = {
    let count = nums.pos().len()
    if count == 1 {
      numbering("I.", ..nums)
    } else if count == 2 {
      numbering("a.", nums.at(1))
    } else { "" }
  }
  set heading(numbering: anr_numbering)

  // add a bit more spacing below headings
  // than the very compact Typst default
  show heading: set block(below: 1em)

  doc
}
