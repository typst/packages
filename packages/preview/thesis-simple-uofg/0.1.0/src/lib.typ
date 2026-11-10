/* 
lib.typ — the 2026 Typst template for University of Glasgow's PhD theses
Copyright (C) 2026 Olivia Weston

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

// Auxiliary functions
#let current-chapter(level: 1) = context {
  let page = here().page()
  let heading-selector = query(selector(heading.where(level: level)))

  let on-page = heading-selector.filter(h => h.location().page() == page)
  if on-page.len() > 0 { return on-page.first().body }

  let before = heading-selector.filter(h => h.location().page() < page)
  if before.len() > 0 { return before.last().body }

  none
}
#let current-page() = context counter(page).get().at(-1)
#let last-page() = context counter(page).final().first()

/// This function sets up page headers dynamically so that the page numbering is always on the outer side (with respect to binding), and chapter name is on the inner side.
///
/// -> 
#let setup-thesis-header(doc) = {
  set page(header: context {
    set text(10pt)

    let p = here().page()
    let binding = left
    let inside-right = if binding == left { calc.even(p) } else { calc.odd(p) }

    if inside-right {
      [Page #current-page() of #last-page()
      #h(1fr)
      #smallcaps[#current-chapter()]]
    } else {
      [#smallcaps[#current-chapter()]
      #h(1fr)
      Page #current-page() of #last-page()]
    }
  })
  doc
}

/// This function mutates headings at level 1 (chapter) to produce their own pages, similar to LaTeX's book documentclass.
///
/// - font (string): Specifies the font to use for displaying chapter pages. If on Windows, it's likely that `"sans"` will not work as an option.
/// -> Alters the appearance of `heading`s.
#let setup-chapter-headings(font: "sans", doc) = {
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    set page(header: none)
    block(height: 1fr, width: 100%)[
      #set align(center + horizon)
      #set text(size: 20pt, weight: "bold", font: font)
    
      Chapter #context counter(heading).display("1")
      
      #it.body
    ]
    pagebreak(weak: true)
  }
  doc
}

/// This function generates a title page, maintains numbering as per the guideline document, and returns the state back to the next odd page available so that the abstract is on its own page, and there is no printing occurring on the back of the title page.
///
/// - title (string): Title of the thesis.
/// - author (string): Full name of the author.
/// - author-degree (string): Author's existing degree(/s).
/// - goal-degree (string): Degree achieved for thesis (usually "Doctor of Philosophy (PhD)").
/// - college (string): University of Glasgow college without the "College of".
/// - school (string): University of Glasgow school without the "School of".
/// - month (string): Month of submission in long written form, e.g. "January".
/// - year (string): Year of submission.
/// -> Modifies document state to generate a title page.
#let title-page-generate(
  title: "TITLE",
  author: "AUTHORNAME",
  author-degree: "AUTHORDEGREE",
  goal-degree: "GOALDEGREE",
  college: "COLLEGE",
  school: "SCHOOL",
  month: "MONTH",
  year: "YEAR"
) = {
  set page(margin: (top: 0mm))
  image("../UofG-marketing/uofg-blue-badge.svg")
  text(size: 22pt, weight: "bold")[#title]
  parbreak()
  text(size: 20pt)[#author]
  linebreak()
  text(size: 20pt)[#author-degree]
  parbreak()
  text(size: 18pt)[Submitted in fulfilment of the requirements for the]
  linebreak()
  text(size: 18pt)[Degree of #goal-degree]
  parbreak()
  text(size: 16pt)[College of #college]
  linebreak()
  text(size: 16pt)[School of #school]
  linebreak()
  text(size: 16pt)[University of Glasgow]
  parbreak()
  text(size: 18pt)[
    #smallcaps[#month] #h(0.5em) #year
  ]
  pagebreak(weak: true, to: "odd")
}

// Primary entry point

/// `thesis-template` is a generator for the University of Glasgow PhD thesis frontmatter, that is, the title page, the abstract, and the surrounding document-wide formatting.
///
/// - title (string): The full title of the thesis. 
/// - author (string): The author of the thesis.
/// - author-degree (string): The academic degree of the author. To remove switch to empty string.
/// - abstract (string): The full text of the abstract.
/// - font (string): The primary font of the document. University of Glasgow guidelines allow Times New Roman and Trebuchet MS. Defaults to "Times New Roman."
/// - font-size (length): The size of the main body font. Defaults to 11pt.
/// - heading-font (string): The font family used for headings. University of Glasgow guidelines allow Arial and Trebuchet MS. Defaults to "Trebuchet MS."
/// - goal-degree (string): The degree for which the thesis is being submitted. Defaults to "Doctor of Philosophy (PhD)."
/// - college (string): The college, to which the student belongs. Defaults to "Science & Engineering." See [official guidance](https://www.gla.ac.uk/colleges/).
/// - school (string): The school, to which the student belongs. Defaults to "Computing Science." See [official guidance](https://www.gla.ac.uk/schools/).
/// - month (string):  The long-format month representing the date of submission. Defaults to "January."
/// - year (string): A string numeral representing the date (year) of submission. Defaults to "2027."
/// - paper (string): A string referring to the dimensions of the paper produced by Typst. Defaults to "a4." 
/// - doc (content): The continuation handle used internally to return the rest of the document.
/// -> 
#let thesis-template(
  title: text(hyphenate: false)[New interpretations of green eggs and ham  according to Debord],
  author: "John Paul Satire",
  author-degree: "MSc",
  abstract: [We have long sought an answer to the question: what if Dr. Seuss' eggs were tea eggs (茶叶蛋) from the Chinese cuisines? In this thesis we describe an approach based on existentialist continental philosophy, Marxist philosophy, and postmodern philosophy to show an alternative reading of the acclaimed children's book #emph["Green eggs and ham"] connecting the economic hardship in the fowl egg industry to social imperialism practised in the country of Grundania. We develop a multilateral analysis based on both common sentiment through social surveys, and a material analysis on the basis of egg production and consumption in Asia and Europe.],
  font: "Times New Roman",
  font-size: 11pt,
  heading-font: "Trebuchet MS",
  goal-degree: "Doctor of Philosophy (PhD)",
  college: "Science & Engineering",
  school: "Computing Science",
  month: "December",
  year: "2027",
  paper: "a4",
  doc
) = {
// Customising apearance
set text(
  hyphenate: true,
  lang: "en",
  region: "gb",
  font: font,
  size: font-size
)
set page(
  margin: 
  (
    inside: 40mm, 
    outside: 15mm, 
    top: 18mm, 
    bottom: 18mm
  ),
  paper: "a4"
)
set quote(block: true)
set heading(numbering: "1.")
set par(spacing: 3em, leading: 1.5em)


// Minimum font size is not enforcible, but should be in a comment or README somewhere. TODO.
show footnote: set text(size: 10pt)

show heading: it => {
  set block(below: 1.5em)
  text(
      font: heading-font,
      it
  )
}

show quote.where(block: true): it => text(
  set pad(left: 5mm, right: 5mm),
  set par(leading: 1em),
  it
)

set align(center + horizon)

title-page-generate(
  title: title,
  author: author,
  author-degree: author-degree,
  goal-degree: goal-degree,
  college: college,
  school: school,
  month: month,
  year: year
)

show: setup-thesis-header

heading(numbering: none)[Abstract]

set par(justify: true)

text[#abstract]

set align(top + left)

show: setup-chapter-headings.with(font: heading-font)

doc
}