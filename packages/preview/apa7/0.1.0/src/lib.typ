#import "apa7/layout.typ": apply-layout, format-running-head
#import "apa7/typography.typ": apply-typography, default-font-size
#import "apa7/heading.typ": apply-headings
#import "apa7/cover.typ": render-cover, format-apa-date, render-authors
#import "apa7/abstract.typ": render-abstract, render-keywords
#import "apa7/table.typ": apply-tables, apa-table, render-table-note
#import "apa7/figure.typ": apply-figures, apa-figure, render-figure-note
#import "apa7/appendix.typ": apa-appendix, appendix-counter
#import "apa7/reference.typ": apply-references, cite-narrative, cite-parenthetical
#import "apa7/stat.typ": apa-stat, apa-t, apa-f, apa-r, apa-chi2, apa-z, apa-mean, apa-ci, format-p, format-num
#import "apa7/theorem.typ": (
  apa-theorem,
  apa-definition,
  apa-lemma,
  apa-corollary,
  apa-proposition,
  apa-example,
  apa-proof,
  eq,
  deq,
  sen,
  tg,
  ctg,
  cotg,
  cosec,
  arcsen,
  arctg,
  arcctg,
  arccotg,
  senh,
  tgh,
  ctgh,
  cotgh,
  cosech,
  mcd,
  mcm,
  MCD,
  MCM,
  rot,
  traza,
  rango,
)

/// Main template function for APA 7th Edition documents in Typst.
///
/// Configures document metadata (PDF/UA-1), page geometry, running heads,
/// approved typography, line spacing, and paragraph indentation.
///
/// Parameters:
/// - title: The title of the paper (string or content). Required for PDF metadata.
/// - authors: List of author dictionaries: (name: "...", affiliation: "...").
/// - paper-type: "student" | "professional" (default: "student").
/// - running-head: Shortened uppercase title (max 50 chars) for professional headers.
/// - font: Standard font family (default: "Times New Roman").
/// - font-size: Font size length or auto (auto selects standard size per font).
/// - paper-size: "us-letter" | "a4" (default: "us-letter").
/// - lang: ISO 639-1 language code (default: "en").
/// - region: Optional ISO 3166-1 alpha-2 region code.
/// - date: Publication or assignment date (datetime or auto).
/// - body: Document content.
#let apa7(
  title: [Untitled Document],
  authors: (),
  paper-type: "student",
  running-head: none,
  course: none,
  instructor: none,
  due-date: none,
  author-note: none,
  abstract: none,
  keywords: (),
  repeat-title: true,
  cover: true,
  font: "Times New Roman",
  font-size: auto,
  paper-size: "us-letter",
  lang: "en",
  region: none,
  date: auto,
  body,
) = {
  // Extract author names for PDF metadata
  let author-names = if type(authors) == array {
    authors.map(a => {
      if type(a) == dictionary {
        a.at("name", default: "")
      } else {
        str(a)
      }
    })
  } else {
    ()
  }

  // Set document metadata for PDF/UA-1 and screen reader catalog access
  set document(
    title: title,
    author: author-names,
    date: date,
  )

  show: apply-layout.with(
    paper-type: paper-type,
    running-head: if running-head != none { running-head } else { title },
    paper-size: paper-size,
  )

  show: apply-typography.with(
    font: font,
    font-size: font-size,
    lang: lang,
    region: region,
  )

  show: apply-headings
  show: apply-tables.with(lang: lang)
  show: apply-figures.with(lang: lang)
  show: apply-references.with(lang: lang)

  if cover {
    render-cover(
      paper-title: title,
      authors: authors,
      paper-type: paper-type,
      course: course,
      instructor: instructor,
      due-date: if due-date != none { due-date } else { date },
      author-note: author-note,
      lang: lang,
    )
  }

  if abstract != none {
    render-abstract(
      abstract: abstract,
      keywords: keywords,
      lang: lang,
    )
  }

  // APA 7 Section 2.11: Repeat paper title centered and bold at the top of the first body page
  if repeat-title and title != none {
    align(center)[
      #strong(title)
      #v(1em)
    ]
  }

  body
}
