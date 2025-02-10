// MIT License
//
// Copyright (c) 2023-2024 Junliang HU <jlhu@cse.cuhk.edu.hk>
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

// This file is created according to the official template page and styling guide on OSDI '23:
// - https://www.usenix.org/conferences/author-resources/paper-templates
// - https://www.usenix.org/conference/osdi23/requirements-authors
// #quote[
//   - No longer than 12 single-spaced 8.5" x 11" pages, including figures and tables, plus as many pages as needed for references.
//   - Submissions may include as many additional pages as needed for references but _*not*_ for supplementary material in appendices.
//   - Use 10-point type on 12-point (single-spaced) leading and Times Roman or a similar font for the body of the paper.
//   - All text and figures fit inside a 7" x 9" (178 mm x 229 mm) block centered on the page, using two columns separated by 0.33" (8 mm) of whitespace. All graphs and figures should be readable when printed in black and white.
//   - Papers not meeting these criteria will be rejected without review, and no deadline extensions will be granted for reformatting.
//   - Pages should be numbered, and figures and tables should be legible in black and white, without requiring magnification.
//   - The paper review process is double-blind. Authors must make a good faith effort to anonymize their submissions, and they should not identify themselves either explicitly or by implication (e.g., through the references or acknowledgments). Submissions violating the detailed formatting and anonymization rules will not be considered for review. If you are uncertain about how to anonymize your submission, please contact the program co-chairs, osdi23chairs@usenix.org, well in advance of the submission deadline.
// ]
#import "@preview/wrap-it:0.1.1": wrap-content
#import "@preview/drafting:0.2.1": set-page-properties

#let author(author) = if type(author) == dictionary {
  align(center, wrap-content(
    author.mark,
    text(size: 12pt, link("mailto:" + author.email, author.name)),
    align: top + right,
    column-gutter: 0.2em,
  ))
}

#let affiliation(affiliation) = if type(affiliation) == dictionary {
  align(center, wrap-content(
    affiliation.mark,
    text(size: 10pt, style: "italic", affiliation.name),
    align: top + left,
    column-gutter: 0.2em,
  ))
}

#let usenix(
  title: [USENIX OSDI Paper Template],
  authors: (
    (name: "Junliang Hu", email: "jlhu@cse.cuhk.edu.hk", mark: []),
  ),
  affiliations: (
    (name: [The Chinese University of Hong Kong], mark: []),
  ),
  review: false,
  print: false,
  body
) = {
  set document(author: authors.map(a => a.name), title: title)
  set page(
    paper: "us-letter",
    margin: (x: (8.5in - 7in) / 2, y: (11in - 9in) / 2),
    numbering: "1",
    columns: 2,
  )
  // set columns(gutter: 8mm)
  set columns(gutter: 1in / 3)
  // The leading has different definitions, but the end result is that each page should fit exactly 54 lines of lorem ipsum.
  set-page-properties()
  // Font: https://tex.stackexchange.com/questions/540011/font-used-in-acm-template
  set text(font: "Libertinus Serif", lang: "en", size: 10pt)
  set par(spacing: .55em, leading: .55em, justify: true)
  show math.equation: set text(font: "New Computer Modern Math")
  show raw: set text(font: "Inconsolata", weight: "medium", size: 9pt)
  show bibliography: it => {
    colbreak(weak: true)
    set text(size: .8em)
    it
    colbreak(weak: true)
  }
  // TODO: make cite red and ref green
  // see: https://github.com/typst/typst/discussions/2585#discussioncomment-10318563
  
  // https://typst-doc-cn.github.io/docs/chinese/
  // set text(font: ("Libertinus Serif", "Noto Sans CJK SC"), lang: "en", size: 10pt)
  // show regex("\p{sc=Hani}+"): set text(size: 0.8em)

  // Set heading format
  show heading: set text(size: 10pt)
  show heading.where(level: 1): set text(size: 12pt)
  set heading(numbering: "1.1.1.1")
  show heading.where(body: [Abstract]): it => {    
    set heading(numbering: none)
    align(center, block(it.body))
  }
    show heading.where(body: [Acknowledgement]): it => {
    set heading(numbering: none)
    block(it.body)
  }
  show bibliography: it => {
      it
      counter(heading).update(0)
  }
  
  // hide any thing tagged with <anon>
  show <anon>: if review { hide } else { (e) => e }

  // Let figure float or sink to the top/bottom edge
  show figure: set block(breakable: true)
  // Table should have their caption on top
  show figure.where(kind: table): set figure.caption(position: top)


  // Wrap all links in a blue box
  show link: it => if not print {
    box(stroke: blue, it.body)
  } else { it }

  // https://typst.app/docs/reference/layout/columns/
  place(top + center, scope: "parent", float: true, {
    // Title row.
    align(center, block(text(weight: "bold", 14pt, title)))

    // Author information.
    let cols = 6
    pad(x: (cols - calc.rem(authors.len(), cols)) * 24pt, top: 12pt, [
      #grid(
        columns: (1fr,) * calc.min(cols, authors.len()),
        gutter: 0pt,
        ..authors.map(author),
      ) <anon>
    ])
    
    // Affiliation information.
    pad(x: 60pt, bottom: 12pt, [
      #grid(
        columns: (1fr,) * calc.min(4, affiliations.len()),
        gutter: 0pt,
        ..affiliations.map(affiliation),
      ) <anon>
    ])
  })

  body
}
