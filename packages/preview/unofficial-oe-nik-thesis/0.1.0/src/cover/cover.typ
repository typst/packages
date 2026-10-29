// The inside cover page, sources as in ../template.typ, and:
// EN cover: the English cover page, the English texts come from it
//   https://nik.uni-obuda.hu/wp-content/uploads/2026/04/Cover-page.docx
// The layout is the Docx's cover page with the lengths stored in it, except the vertical positions of the title and
// the footer, which aren't stored, they're measured from the Docx rendered by LibreOffice

#let cover-texts = (
  en: (
    faculty: "JOHN VON NEUMANN FACULTY OF INFORMATICS",
    name: "Student’s name:",
    logo: "Óbuda University logo",
    seal: "seal of the John von Neumann Faculty of Informatics",
    // EN cover: "Registrations number", the Guide has "Student's registration number"
    registration-number: "Student’s registration number:",
  ),
  hu: (
    faculty: "NEUMANN JÁNOS INFORMATIKAI KAR",
    name: "Hallgató neve:",
    logo: "Óbudai Egyetem logó",
    seal: "a Neumann János Informatikai Kar emblémája",
    registration-number: "Hallgató törzskönyvi száma:",
  ),
)

#let cover-page(
  lang: none,
  thesis-type: none,
  year: none,
  author: none,
  registration-number: none,
) = {
  let texts = cover-texts.at(lang)
  let margin = (top: 1.5cm, right: 2cm, left: 3cm)
  set page(margin: margin)
  // Docx: paragraphs have 8pt before and 1.5 line spacing, a single line of 12pt Arial is 1.15em, 0.245em of it
  // below the baseline
  // Own: wrapped lines are 8pt apart too, like the Docx's two paragraphs of the faculty name
  let descent = 0.245 * 12pt
  let baseline = 1.5 * 1.15 * 12pt - descent
  set text(top-edge: baseline, bottom-edge: -descent)
  set par(leading: 8pt, spacing: 8pt, justify: false)
  // Own: URW Nimbus Sans instead of Arial, like Nimbus Roman (Supervisor) instead of Times New Roman
  set text(font: "Nimbus Sans", size: 12pt)

  grid(
    columns: (4.69cm, 5.75cm, 1fr),
    inset: (x: 0.19cm, top: 8pt),
    image("oe-logo.svg", width: 4.31cm, height: 2.55cm, fit: "stretch", alt: texts.logo),
    // EN cover: 10pt, probably as "FACULTY OF INFORMATICS" doesn't fit into the cell in 12pt
    align(center, text(size: (en: 10pt, hu: 12pt).at(lang), weight: "bold", texts.faculty)),
    grid.cell(
      inset: (left: 0.19cm + 1.2cm, top: 0.3cm),
      image("nik-seal.png", width: 2.71cm, height: 3.36cm, fit: "stretch", alt: texts.seal),
    ),
  )

  place(
    top + center,
    dy: 11.24cm - margin.top,
    text(font: "Nimbus Roman", size: 36pt, weight: "bold", top-edge: "baseline", upper(thesis-type)),
  )

  place(top, dy: 25.16cm - margin.top - baseline, grid(
    columns: (2.63cm, 6cm, 1fr),
    inset: (x: 0.12cm),
    row-gutter: 8pt,
    align: (left, left, right),
    strong("OE-NIK"), texts.name, strong(author),
    strong(str(year)), texts.registration-number, strong(registration-number),
  ))
}
