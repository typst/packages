#import "@preview/abbr:0.3.0"
#import "src/title-page.typ": print-title-page
#import "src/headings.typ": configure-document-styles, apply-font
#import "src/abbreviations.typ": load-abbreviations, print-abbreviations
#import "src/front-matter.typ": print-declaration, print-table-of-contents, print-list-of-figures
#import "src/locale.typ": get-strings

#let template(
  title: "",
  authors: "",
  type-of-work: "",
  date: "",
  info: (),
  abbr-csv-content: none,
  department: "Fachbereich Informatik",
  department-en: "Department of Computer Science",
  show-declaration: false,
  force-list-of-figures: false,
  force-abbreviations: false,
  header-title: auto,
  lang: "de",
  font: "Liberation Sans",
  body,
) = {

  // Variables
  let author-list = if type(authors) == str { (authors,) } else { authors }
  let header-title = if header-title == auto { title } else { header-title }
  let strings = get-strings(lang)

  set document(title: title, author: author-list.join(", "))
  show: configure-document-styles.with(lang, strings.bibliography_title, font)

  // Title page
  set page(numbering: none, header: none, footer: none)
  print-title-page(title, type-of-work, author-list, info, department, department-en, strings)
  pagebreak()

  set page(
    numbering: "i",
    header: if header-title == none or header-title == "" { none } else { context {
      set text(size: 10pt)
      header-title
      v(-0.6em)
      line(length: 100%)
    }},
    footer: context {
      set text(size: 10pt)
      align(right, counter(page).display("i"))
    },
  )

  // Decleration
  if show-declaration {
    print-declaration(strings)
  }

  // Table of contents
  print-table-of-contents(strings)

  // List of figures
  print-list-of-figures(strings, force-print: force-list-of-figures)


  // Abbreviations
  show: abbr.show-rule
  abbr.config(style: it => emph(it))
  load-abbreviations(abbr-csv-content)

  if abbr-csv-content != none {
    context {
      if force-abbreviations or state("abbr-list", ()).final().len() > 3 {
        print-abbreviations(strings)
      }
    }
  }
  pagebreak()


  // Main content
  counter(page).update(1)

  set page(
    numbering: "1",
    footer: context {
      set text(size: 10pt)
      align(right, counter(page).display("1"))
    },
  )

  body

}
