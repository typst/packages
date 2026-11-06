// Fubell — NTU thesis template for Typst.
//
// Usage:
//   #import "@preview/fubell:0.1.0": thesis, appendix
//   #show: thesis.with( ... )

#import "src/config.typ"
#import "src/cover.typ": cover-page
#import "src/certification.typ": certification-page, certification-page-from-pdf
#import "src/front-matter-page.typ": front-matter-page
#import "src/outline-page.typ": outline-page
#import "src/appendix.typ": appendix

#let thesis(
  university: (zh: "國立臺灣大學", en: "National Taiwan University"),
  college: (zh: "", en: ""),
  institute: (zh: "", en: ""),
  title: (zh: "", en: ""),
  author: (zh: "", en: ""),
  advisor: (zh: "", en: ""),
  student-id: "",
  degree: "master", // "master" or "phd"
  date: (year-zh: "", year-en: "", month-zh: "", month-en: ""),
  keywords: (zh: (), en: ()),
  // -- Front matter content --
  abstract-zh: [],
  abstract-en: [],
  acknowledgement-zh: none,
  acknowledgement-en: none,
  // -- Options --
  lang: "zh", // "zh" or "en" — controls outline titles and document language
  font-profile: "submission", // "submission", "web", or "portable"
  font-en: auto,
  font-zh: auto,
  committee-count: 4,
  bibliography-file: none,
  watermark: none, // optional watermark image, e.g. image("assets/watermark.png")
  doi: none, // optional DOI string, e.g. "doi:10.6342/NTU2024XXXXX"
  certification-pdf: none, // optional: scanned certification PDF bytes, e.g. read("cert.pdf", encoding: none)
  certification-pdf-page: 1, // which page of the PDF to embed
  certification-pdf-fit: "contain", // "contain", "cover", or "stretch"
  body,
) = {
  let watermark-content = if type(watermark) == str or type(watermark) == bytes {
    image(watermark)
  } else {
    watermark
  }
  let profile-fonts = config.resolve-fonts(font-profile)
  let resolved-font-en = if font-en == auto { profile-fonts.en } else { font-en }
  let resolved-font-zh = if font-zh == auto { profile-fonts.zh } else { font-zh }
  let as-font-list = value => if type(value) == array { value } else { (value,) }
  let text-fonts = as-font-list(resolved-font-en) + as-font-list(resolved-font-zh)

  // -- Document metadata --
  set document(
    title: title.en,
    author: author.en,
  )
  [#metadata((
    profile: font-profile,
    en: resolved-font-en,
    zh: resolved-font-zh,
  )) <fubell-font-config>]

  // -- Page setup --
  set page(
    paper: "a4",
    margin: (
      top: config.margin-top,
      bottom: config.margin-bottom,
      left: config.margin-left,
      right: config.margin-right,
    ),
    ..if watermark-content != none {
      (background: place(top + right, dx: -2.5cm, dy: 2.5cm, {
        set image(width: 3.5cm)
        watermark-content
      }))
    },
    // A custom footer replaces the default one, which is what renders `numbering`.
    // Render both so page numbers survive when a DOI is set.
    ..if doi != none {
      (footer: context {
        set align(center)
        if page.numbering != none {
          counter(page).display(page.numbering)
        }
        place(right, dx: 2cm, text(size: 10pt)[#doi])
      })
    },
  )

  // -- Typography --
  set text(
    size: config.body-size,
    font: text-fonts,
    lang: lang,
    ..if lang == "zh" { (region: "tw") },
  )
  let pick-lang = (zh, en) => if lang == "zh" { zh } else { en }
  let _leading = pick-lang(config.line-spacing-zh, config.line-spacing-en)
  set par(leading: _leading, spacing: _leading, first-line-indent: (amount: 2em, all: true), justify: true)

  // -- Heading style --
  let chapter-prefix = pick-lang("第", "Chapter ")
  let chapter-suffix = pick-lang("章 ", " ")
  let chapter-num-fmt = pick-lang("一", "1")
  let thesis-numbering = (..nums) => {
    let nums = nums.pos()
    if nums.len() == 1 {
      chapter-prefix + numbering(chapter-num-fmt, nums.first()) + chapter-suffix
    } else {
      numbering("1.1", ..nums) + " "
    }
  }

  set heading(numbering: thesis-numbering)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1.5em)
    align(center, text(size: config.heading-size, weight: "bold")[
      #if it.numbering != none {
        counter(heading).display(it.numbering)
      }
      #it.body
    ])
    v(1.2em)
  }
  show heading.where(level: 2): it => {
    v(0.5 * _leading)
    text(size: config.subheading-size, weight: "bold")[#it]
    v(0.5 * _leading)
  }
  show heading.where(level: 3): it => {
    v(0.5 * _leading)
    text(size: config.body-size, weight: "bold")[#it]
    v(0.5 * _leading)
  }
  show heading.where(level: 4): it => {
    v(0.5 * _leading)
    text(size: config.body-size, weight: "bold")[#it]
    v(0.5 * _leading)
  }

  // ================================================================
  // Front matter
  // ================================================================

  // 1. Cover page (書名頁)
  cover-page(
    university: university,
    college: college,
    institute: institute,
    title: title,
    author: author,
    advisor: advisor,
    degree: degree,
    date: date,
    doi: doi,
  )

  // 2. Certification page (口試委員會審定書)
  if certification-pdf != none {
    certification-page-from-pdf(
      certification-pdf,
      pdf-page: certification-pdf-page,
      fit: certification-pdf-fit,
    )
  } else {
    certification-page(
      university: university,
      author: author,
      title: title,
      institute: institute,
      student-id: student-id,
      degree: degree,
      date: date,
      committee-count: committee-count,
    )
  }

  // 3. Acknowledgements (致謝)
  if acknowledgement-zh != none {
    front-matter-page(heading-text: "致謝", content: acknowledgement-zh, lang: "zh")
  }
  if acknowledgement-en != none {
    front-matter-page(heading-text: "Acknowledgements", content: acknowledgement-en, lang: "en")
  }

  // 4. Chinese abstract (中文摘要)
  front-matter-page(
    heading-text: "摘要",
    content: abstract-zh,
    keywords: keywords.zh,
    lang: "zh",
  )

  // 5. English abstract (英文摘要)
  front-matter-page(
    heading-text: "Abstract",
    content: abstract-en,
    keywords: keywords.en,
    lang: "en",
  )

  // 6. Table of contents, list of figures, list of tables
  {
    let toc-title = pick-lang("目錄", "Table of Contents")
    let lof-title = pick-lang("圖目錄", "List of Figures")
    let lot-title = pick-lang("表目錄", "List of Tables")

    outline-page(toc-title, depth: 3)
    outline-page(lof-title, target: figure.where(kind: image))
    outline-page(lot-title, target: figure.where(kind: table))
  }

  // ================================================================
  // Main matter
  // ================================================================

  // Reset to Arabic page numbering for main content
  set page(numbering: "1")
  counter(page).update(1)

  body

  // ================================================================
  // Back matter — bibliography
  // ================================================================

  if bibliography-file != none {
    let bib-title = pick-lang("參考文獻", "References")
    pagebreak(weak: true)
    set bibliography(title: bib-title)
    show bibliography: set heading(numbering: none)
    show bibliography: set text(lang: "en")
    show heading.where(level: 1): it => {
      align(center, text(size: config.heading-size, weight: "bold")[#it.body])
      v(1.5em)
    }
    bibliography-file
  }
}
