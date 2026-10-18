#import "../../assets/text-blobs.typ": copyright-text, join-names, master-strings
#import "../utils/fonts.typ": front-font, leading-for

// Copyright page, following kulemt v2.2.0 (\@@_print_copyright_page:).
//
//     (C) <academic year + 1> KU Leuven - <faculty>
//     <Published by> <authors>,
//     <contact address>
//
//     <copyright notice, master's programme language>
//     [<copyright notice, thesis language>, only when the two differ]
//
// Set 10/12 in the front font, ragged right (kulemt uses \raggedright and a
// smaller size specifically to avoid hyphenation), no paragraph indent, half a
// blank line between paragraphs, pushed to the bottom of the page.
//
// The notice is fixed text. The faculty name defaults to the faculty; the
// address is the student's own department, defaulting to the faculty address
// exactly as kulemt does when a programme defines none. 0.1.0 shipped the
// kulemt v1 page instead, with the department, phone, e-mail and "B-3001
// Heverlee" hard-coded into the sentence.

/// The year printed: the END of the academic year, as kulemt does with
/// \int_eval:n { \l_kulemt_opt_acyear_int + 1 }.
/// -> int
#let copyright-year(academic-year) = {
  if type(academic-year) == array { academic-year.at(1) } else {
    academic-year + 1
  }
}

/// -> content
#let insert-copyright(
  english-master,
  lang,
  authors,
  academic-year,
  faculty,
  address,
  margin: (left: 28mm, right: 28mm, top: 37mm, bottom: 45mm),
) = {
  let master-lang = if english-master { "en" } else { "nl" }

  page(
    paper: "a4",
    margin: margin,
    header: none,
    footer: none,
    numbering: none,
  )[
    #{
      set align(left + bottom)
      set text(font: front-font, size: 10pt, lang: master-lang)
      set par(
        justify: false,
        first-line-indent: 0pt,
        leading: leading-for(10pt, 12pt),
        spacing: 6pt, // \parskip = .5\baselineskip
      )
      set text(hyphenate: false)

      block[
        #sym.copyright #copyright-year(academic-year) KU~Leuven #sym.dash.en #faculty.at(master-lang) \
        #master-strings(english-master).publisher-pre #join-names(authors, lang: master-lang), \
        #address.at(master-lang)
      ]

      // The explicit parbreak()s matter: without them Typst runs consecutive
      // blocks into a single paragraph and the Dutch notice ends mid-line
      // followed straight by "All rights reserved...".
      parbreak()
      copyright-text.at(master-lang)

      // kulemt prints a second notice only when the programme language and the
      // thesis language differ (\bool_xor:nnT).
      if master-lang != lang {
        parbreak()
        copyright-text.at(lang)
      }
    }
  ]
}
