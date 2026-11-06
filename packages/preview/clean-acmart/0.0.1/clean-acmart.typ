// MIT License
//
// Copyright (c) 2023-2025 Junliang HU <jlhu@cse.cuhk.edu.hk>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// made according to typst ieee template and official acm word template

// --- Draft Formatting

// Papers will be submitted electronically in PDF format via the web submission form.

// 1. Submissions may have at most 12 pages of technical content, including all text, figures, tables, etc. Bibliographic references are not included in the 12-page limit.
// 2. Use A4 or US letter paper size, with all text and figures fitting inside a 178 x 229 mm (7 x 9 in) block centered on the page, using two columns separated by 8 mm (0.33) of whitespace.
// 3. Use 10-point font (typeface Times Roman, Linux Libertine, etc.) on 12-point (single-spaced) leading.
// 4. Graphs and figures should be readable when printed in grayscale, without magnification.
// 5. All pages should be numbered, and references within the paper should be hyperlinked.

// Authors may optionally include supplementary material, such as formal proofs or analyses, as a separate document; PC members are not required to read this material, so the submission must stand alone without it. Supplementary material is intended for items that are not critical for evaluating the paper but may be of interest to some readers.

// Submissions violating these rules will not be considered for publication, and there will be no extensions for fixing violations. We encourage you to upload an early draft of the paper well before the deadline to check if the paper meets the formatting rules.

// Most of these rules are automatically applied when using the official SIGPLAN Latex or MS Word templates from the ACM.

// For Latex, we recommend you use:

// \documentclass[sigplan,10pt]{acmart}
// \renewcommand\footnotetextcopyrightpermission[1]{}
// ...
// \settopmatter{printfolios=true}
// \maketitle
// \pagestyle{plain}
// ...

// --- Camera-ready Formatting

// 1. Camera-ready papers can have 12 pages of technical content, including all text, figures, tables, etc. Your shepherd can approve up to two additional pages of technical content. Bibliographic references are not included in the 12-page limit.
// 2. You must use the US letter paper size, with all text and figures fitting inside a 178 x 229 mm (7 x 9 in) block centered on the page, using two columns separated by 8 mm (0.33) of whitespace.
// 3. Use 10-point font (typeface Times Roman, Linux Libertine, etc.) on 12-point (single-spaced) leading.
// 4. Graphs and figures should be readable when printed in grayscale, without magnification.
// 5. Do not include page numbers, footers, or headers. References within the paper should be hyperlinked.
// 6. Paper titles should be in Initial Caps Meaning First Letter of the Main Words Should be Made Capital Letters. As an example, refer to the previous sentence: note the Capital Letter "M" in Must, Meaning, and Main, the Capital Letter "C" in Caps and Capital and the Capital Letter "L" in Letter and Letters.

// Most of these rules are automatically applied when using the official SIGPLAN LaTeX or MS Word templates from the ACM, available from the ACM Template Page.

// Please follow the font requirements from part 8 of the ACM Guidelines for Proceedings.
// 7. In particular, papers should have Type 1 fonts (scalable), not Type 3 (bit-mapped).
// 8. All fonts MUST be embedded within the PDF file. This will usually happen by default when using pdflatex, but in rare cases, PDFs generated with pdflatex will not contain embedded fonts. This most often occurs when vector images included in paper do not themselves embed their fonts.

// 9. Authors should make sure to use the ACM classification system. For details, please see the ACM CCS Page.

// 10. Be sure that there are no bad page or column breaks, meaning no widows (last line of a paragraph at the top of a column). 
// 11. Section and Sub-section heads should remain with at least 2 lines of body text when near the end of a page or column.

// 12. When submitting the camera-ready paper, make sure the author full names and affiliations in HotCRP are up-to-date, and that the abstract in HotCRP is also updated.

// ---

#let copyright-owner(mode: none) = {
  if mode == "acmcopyright" [
    ACM.
  ] else if mode == "acmlicensed" [
    Copyright held by the owner/author(s). Publication rights licensed to ACM.
  ] else if mode in ("rightsretained", "cc") [
    Copyright held by the owner/author(s).
  ] else [
    // TODO
  ]
}

#let copyright-permission(mode: none) = {
  if mode == "acmcopyright" [
    Permission to make digital or hard copies of all or part of this
    work for personal or classroom use is granted without fee provided
    that copies are not made or distributed for profit or commercial
    advantage and that copies bear this notice and the full citation on
    the first page. Copyrights for components of this work owned by
    others than ACM must be honored. Abstracting with credit is
    permitted. To copy otherwise, or republish, to post on servers or
    to redistribute to lists, requires prior specific permission
    and/or a fee. Request permissions from permissions\@acm.org.
  ] else if mode == "acmlicensed" [
    Permission to make digital or hard copies of all or part of this
    work for personal or classroom use is granted without fee provided
    that copies are not made or distributed for profit or commercial
    advantage and that copies bear this notice and the full citation on
    the first page. Copyrights for components of this work owned by
    others than the author(s) must be honored. Abstracting with credit
    is permitted. To copy otherwise, or republish, to post on servers
    or to redistribute to lists, requires prior specific permission
    and/or a fee. Request permissions from
    permissions\@acm.org.
  ] else if mode == "rightsretained" [
    Permission to make digital or hard copies of part or all of this
    work for personal or classroom use is granted without fee provided
    that copies are not made or distributed for profit or commercial
    advantage and that copies bear this notice and the full citation on
    the first page. Copyrights for third-party components of this work
    must be honored. For all other uses, contact the
    owner/author(s).
  ] else if mode == "cc" [
    #image("cc-by.svg", width: 25%)
    This work is licensed under a
    #link("https://creativecommons.org/licenses/by/4.0/")[
      Creative Commons Attribution International 4.0
    ]
    License.
  ] else [
    // TODO
  ]
}

// https://github.com/typst/typst/issues/2196#issuecomment-1728135476
#let to-string(it) = {
  if type(it) == str {
    it
  } else if type(it) != content {
    str(it)
  } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(to-string).join()
  } else if it.has("body") {
    to-string(it.body)
  } else if it == [ ] {
    " "
  }
}

// Accepts a list of dict
// (
//   (
//     generic: [Software and its engineering], 
//     specific: ([Virtual machines], [Virtual memory], ),
//   ),
//   ...
// )
#let acmart-ccs(ccs-concepts) = [
  #set par(first-line-indent: 0em)
  *
  _CCS Concepts:_ 
  #ccs-concepts.map(concept => 
    [ #sym.bullet #concept.generic #sym.arrow.r #concept.specific.join("; ")]
  ).join("; ").
  *
]

#let acmart-keywords(keywords) = [
  #set par(first-line-indent: 0em)
  *_Keywords:_* 
  #keywords.join(", ")
]

// Display the ACM reference format.
#let acmart-ref(title, authors, conference, doi) = [
  #set par(first-line-indent: 0em)
  #set text(size: 0.9em)
  *ACM Reference Format:*
  #let names = authors.map(author => author.name)
  #if names.len() > 1 {
    names.push(" and " + names.pop())
  }
  #names.join(","). <anon>
  #conference.year
  #title.
  In _ #conference.name (#conference.short), #conference.date, #conference.year, #conference.venue. _
  ACM, New York, NY, USA, #context counter(page).final().at(0) pages.
  #link(doi)
]

// Display the authors list.
#let acmart-authors(authors, ncols: 5) = {
  let author(author) = {
    set align(center)
    text(
      1.2em,
      link(
        "mailto:" + to-string(author.remove("email")),
        author.remove("name"),
      ),
    ) + author.remove("mark", default: [])
    for (k, v) in author [\ #v]
  }
  for i in range(calc.ceil(authors.len() / ncols)) [
    #let end = calc.min((i + 1) * ncols, authors.len())
    #let is-last = authors.len() == end
    #let slice = authors.slice(i * ncols, end)
    #grid(
      columns: slice.len() * (1fr,),
      gutter: -10em,
      ..slice.map(author),
    ) <anon>
  ]
}

// Display the affiliations.
#let acmart-affiliations(affiliations, ncols: 3) = {
  let affiliation(affiliation) = {
    set align(center)
    affiliation.remove("mark", default: []) + affiliation.remove("name")
    for (k, v) in affiliation [\ #v]
  }
  for i in range(calc.ceil(affiliations.len() / ncols)) [
    #let end = calc.min((i + 1) * ncols, affiliations.len())
    #let is-last = affiliations.len() == end
    #let slice = affiliations.slice(i * ncols, end)
    #grid(
      columns: slice.len() * (1fr,),
      gutter: -5em,
      ..slice.map(affiliation),
    ) <anon>
  ]
}

// This function gets your whole document as its `body`
#let acmart(
  // The paper's title.
  title: [Paper Title],

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors: (
    (
      name: [Junliang Hu],
      email: [jlhu\@cse.cuhk.edu.hk],
      // mark: super[1],
    ),
  ),

  // An array of affiliations. To be used when you want to seperate affiliation information from authors.
  // affiliations: (
  //   (
  //     name: [The Chinese University of Hong Kong],
  //     mark: super[1],
  //     department: [Department of Computer Science and Engineering],
  //     location: [Hong Kong],
  //   ),
  // ),
  affiliations: (),

  keywords: (
    "Virtual machine",
    "Virtual memory",
    "Operating system"
  ),

  conference: (
    name:  [ACM SIGOPS 31th Symposium on Operating Systems Principles],
    short: [SOSP ’25],
    year:  [2025],
    date:  [October 13–16],
    venue: [Seoul, Republic of Korea],
  ),

  doi: "https://doi.org/10.1145/0000000000",
  isbn: "979-8-0000-0000-0/00/00",
  price: "$15.00",
  copyright: "cc",

  // Whether we are submitting as an anonymous version
  review: none,

  // https://github.com/typst/typst/issues/4224#issuecomment-2755913480
  // 1.2em - 1em
  leading: .2em,
  // should be 54 lines of text
  font-size: 10pt,

  colors: (
    blue: rgb(29, 75, 125),
    red: rgb(97, 38, 103),
  ),

  // The paper's content.
  body
) = {
  set document(
    title: title, 
    author: if review == none { authors.map(a => to-string(a.name)) } else { () },
    keywords: keywords
  )
  // Configure the page. (rule 2)
  // Text block: 178 x 229 mm (7 x 9 in)
  // US letter: 8½″ × 11″ (216 mm × 279 mm)
  // A4: 210 mm × 297 mm (8.3″ × 11.7″)
  set page(
    paper: "us-letter",
    margin: (x: (8.5 - 7) / 2 * 1in, y: (11 - 9) / 2 * 1in),
    numbering: "1",
    columns: 2,
  )
  set columns(gutter: 8mm)
  
  // Set the body font. (rule 3)
  set text(
    font: "Linux Libertine",
    size: font-size,
    top-edge: 1em,
    bottom-edge: 0em
  )
  show heading: set text(size: font-size)
  show heading.where(level: 1): set text(size: 1.2em)
  // Configure paragraph properties.
  // 12pt leading, i.e. 1.2x font-size (rule 3)
  set block(spacing: leading)
  set par(
    leading: leading,
    spacing: leading,
    justify: true,
    first-line-indent: 1em
  )
  show heading: set block(above: leading, below: leading)
  set figure(gap: leading)
  // This affects the gap between figure and main content
  set place(clearance: 1em)

  // https://tex.stackexchange.com/a/540068
  show raw: set text(font: "Inconsolata")

  // Color http/https hyperlink with blue
  show link: it => if type(it.dest) != str or not it.dest.starts-with("http") {it} else {
    text(fill: colors.blue, it)
  }
  // Color section/figure/table numbering with red
  show ref: it => if it.element == none or it.element.func() not in (heading, figure, table) {it} else {
    let e = it.element
    let f = it.element.func()
    let s = if it.supplement not in (auto, none) {it.supplement}
            else if f == heading {sym.section}
            else {e.supplement}
    let sep = if s == sym.section [] else [ ]
    link(
      e.location(), 
      s + sep + text(
        fill: colors.red,
        numbering(e.numbering, ..e.at("counter", default: counter(f)).at(e.location()))
      ),
    )
  }
  // Color only number inside citation groups with red
  show ref: it => if it.element != none or it.citation == none or it.supplement != auto {it} else {
    set text(fill: colors.red)
    show regex("[\[\],-]"): set text(fill: black)
    show ", ": "," + h(.15em)
    it
  }

  // Configure equation numbering and spacing.
  // set math.equation(numbering: "(1)")

  // Configure lists.
  set enum(indent: .25em, body-indent: .25em)
  set list(indent: .25em, body-indent: .25em)
  set footnote.entry(indent: 0em)
  
  // Configure headings.
  set heading(numbering: "1.1.1")
  show heading: it => if it.numbering == none { it } else {
    let numbering = if it.body in ([Abstract], [Acknowledgement]) {
      none
    } else {
      counter(heading).display(it.numbering) + h(calc.max(.25em, 1em / it.level))
    }
    let reset = it.body in ([Abstract], [Acknowledgement])
    block(numbering + it.body)
    if it.body in ([Abstract], [Acknowledgement]) {
      counter(heading).update(0) 
    }
  }
  
  show bibliography: it => {
      colbreak(weak: true)
      it
  }

  let anon = if review != none { hide } else { (e) => e }
  show <anon>: anon

  place(top + center, scope: "parent", float: true, {
    // Display the paper's title.
    align(center, text(font: "Linux Biolinum", size: 1.5em, [* #title *]))
    if review != none {
      // Display submission id if specified via review
      v(.5em) + text(size: 1.2em, [Submission: #review])
    } else {
      // Display authors and affiliaitons instead
      v(.5em) + acmart-authors(authors)   
      v(.5em) + acmart-affiliations(affiliations)
    }
  })
  
  if copyright != none {
    place(bottom, float: true, scope: "column", [
      #set par(first-line-indent: 0em)
      #line(length: 100%, stroke: .5pt)
      #copyright-permission(mode: copyright)
  
      _ #conference.short, #conference.date, #conference.year, #conference.venue. _
      
      #sym.copyright #conference.year #copyright-owner(mode: copyright)
      
      ACM ISBN #isbn...#price
      
      #link(doi)
    ])
  }
  
  show bibliography: it => {
    colbreak(weak: true)
    set text(size: .9em)
    it
  }
  
  // Display the paper's contents.
  body
}
