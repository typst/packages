

// Removed CCS XML parsing for a more low-tech solution
// E.g. instead of passing the following XML string to the template,
// you just pass [General and reference $->$ Surveys and overviews]

#let ccs-xml = "<ccs2012><concept><concept_id>10002944.10011122.10002945</concept_id><concept_desc>General and reference~Surveys and overviews</concept_desc><concept_significance>300</concept_significance></concept></ccs2012>"

#let parse-ccs(ccs-desc) = {
  let ccs = bytes(ccs-desc)
  let find-tag(elem, tag) = {
    elem.children.find(e => "tag" in e and e.tag == tag)
  }
  let contents = xml(ccs)
  let concept = find-tag(contents.at(0), "concept")
  find-tag(concept, "concept_desc")
    .children
    .at(0)
    .split("~")
    .join({
      h(1mm)
      sym.arrow
      h(1mm)
    })
}


// supplementary-material-description: [These are supplementary materials],
//   supplementary-material: (
//     (
//       cite: "DBLP:books/mk/GrayR93",
//       subcategory: [Typesetting],
//       swhid: [Typst],
//       classification: [Documentation],
//       url: "https://typst.app/docs/",
//       linktext: [typst docs website],
//     ),
//     (
//       cite: "DBLP:books/mk/GrayR93",
//       subcategory: [Description, Subcategory],
//       swhid: [Software Heritage Identifier],
//       classification: [General Classification (e.g. Software, Dataset, Model, ...)],
//       url: "http://google.com",
//       linktext: [opt. text shown instead of the URL],
//     ),
//   ),
// 


// handling of supplement details:
// if supplement != none {
//   supplement
//   linebreak()
// }
// for sup in supplement-details {
//   set text(9pt)
//   [_#sup.classification, (#sup.subcategory)_]
//   text(font: fonts.mono, link(sup.url, sup.linktext))
//   linebreak()
//   h(5mm)
//   [archived at ]
//   text(font: fonts.mono, sup.swhid)
//   linebreak()
// }
// 
// 
// 
// if funding != none {
//   funding
//   linebreak()
// }
// for author in authors {
//   if "funding" in author [
//     #emph(author.name): #text(author.funding)
//     #linebreak()
//   ]
// }
// 
// 
// 
// author.affiliations.map(aff => [
//   #aff.name,
//   #if aff.at("address", default: none) != none [#aff.address,]
//   #if aff.at("country", default: none) != none { aff.country } else [COUNTRY PLEASE]
//   #linebreak()
// ]).join()




#heading(numbering: none, level: 4)[Minimum Requirements]

- Use pdflatex and an up-to-date LATEX system.
- Use further LATEX packages and custom made macros carefully and only if required.
- Use the provided sectioning macros: \\section, \\subsection, \\subsubsection, \\paragraph, \\paragraph\*, and \\subparagraph\* (for more details, see Section 2.4).
- Provide suitable graphics of at least 300dpi (preferably in PDF format).
- Use BibTEX and keep the standard style (plainurl) for the bibliography.
- Please try to keep the warnings log as small as possible. Avoid overfull \hboxes and any kind of warnings/errors with the referenced BibTEX entries.
- Use a spellchecker to correct typos.

#heading(level: 5, numbering: none)[Mandatory metadata macros]
#lorem(200)