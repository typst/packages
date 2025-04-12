#import "/src/constants/drop-down-list-constants.typ": REPORT-TYPES
#import "/src/styles/thesis-front-section-style.typ": thesis-front-section-style
#import "/src/sections/01-front/preface-page.typ": preface-page
#import "/src/sections/01-front/table-of-contents-page.typ": table-of-contents-page
#import "/src/sections/01-front/list-of-table-figures-page.typ": list-of-table-figures-page
#import "/src/sections/01-front/list-of-image-figures-page.typ": list-of-image-figures-page
#import "/src/sections/01-front/list-of-math-equations-page.typ": list-of-math-equations-page
#import "/src/sections/01-front/list-of-code-figures-page.typ": list-of-code-figures-page
#import "/src/sections/01-front/thesis-study-originality-report-page.typ": thesis-study-originality-report-page
#import "/src/sections/01-front/scientific-ethics-declaration-page.typ": scientific-ethics-declaration-page
#import "/src/sections/01-front/symbols-and-abbreviations-page.typ": symbols-and-abbreviations-page
#import "/src/sections/01-front/turkish-abstract-page.typ": turkish-abstract-page
#import "/src/sections/01-front/english-abstract-page.typ": english-abstract-page

// Tezin Ön Kısmı. [Front Section of Thesis.]
#let thesis-front-section(
  department: none,
  program: none,
  report-type: none,
  date: none,
  report-title: none,
  author: none,
  advisor: none,
  thesis-originalty: none,
  keywords: none,
  show-list-of-table-figures: none,
  show-list-of-image-figures: none,
  show-list-of-math-equations: none,
  show-list-of-code-figures: none,
  have-symbols: none,
  have-abbreviations: none,
) = {
  // Tezin Ön Kısmının Stili [Style of the Front Section of Thesis]
  show: thesis-front-section-style

  /* --- Ön Söz Sayfası [Preface Page] --- */
  if (
    report-type == REPORT-TYPES.MASTER-THESIS
      or report-type == REPORT-TYPES.DOCTORAL-THESIS
      or report-type == REPORT-TYPES.TERM-PROJECT
  ) {
    preface-page(
      author: author,
      date: date,
    )
  }

  /* --- İçindekiler Sayfası [Table of Contents Page] --- */
  table-of-contents-page()

  /* --- Tablo Figürleri Listesi Sayfası [List of Table Figures Page] --- */
  if (
    (
      report-type == REPORT-TYPES.MASTER-THESIS
        or report-type == REPORT-TYPES.DOCTORAL-THESIS
        or report-type == REPORT-TYPES.TERM-PROJECT
    )
      and show-list-of-table-figures
  ) {
    list-of-table-figures-page()
  }

  /* --- Şekil Figürleri Listesi Sayfası [List of Image Figures Page] --- */
  if (
    (
      report-type == REPORT-TYPES.MASTER-THESIS
        or report-type == REPORT-TYPES.DOCTORAL-THESIS
        or report-type == REPORT-TYPES.TERM-PROJECT
    )
      and show-list-of-image-figures
  ) {
    list-of-image-figures-page()
  }

  /* --- Denklem Figürleri Listesi Sayfası [List of Equation Figures Page] --- */
  if (
    (
      report-type == REPORT-TYPES.MASTER-THESIS
        or report-type == REPORT-TYPES.DOCTORAL-THESIS
        or report-type == REPORT-TYPES.TERM-PROJECT
    )
      and show-list-of-math-equations
  ) {
    list-of-math-equations-page()
  }

  /* --- Kod Figürleri Listesi Sayfası [List of Code Figures Page] --- */
  if (
    (
      report-type == REPORT-TYPES.MASTER-THESIS
        or report-type == REPORT-TYPES.DOCTORAL-THESIS
        or report-type == REPORT-TYPES.TERM-PROJECT
    )
      and show-list-of-code-figures
  ) {
    list-of-code-figures-page()
  }

  /* --- Tez Çalışması Örijinallik Raporu Sayfası [Originality Report Page] --- */
  if (
    report-type == REPORT-TYPES.MASTER-THESIS or report-type == REPORT-TYPES.DOCTORAL-THESIS
  ) {
    thesis-study-originality-report-page(
      report-title: report-title,
      author: author,
      advisor: advisor,
      date: date,
      included-page-count: thesis-originalty.included-page-count,
      similarity-score: thesis-originalty.similarity-score,
    )
  }

  /* --- Bilimsel Etik Beyannamesi Sayfası [Scientific Ethics Declaration Page] --- */
  if (
    report-type == REPORT-TYPES.MASTER-THESIS
      or report-type == REPORT-TYPES.DOCTORAL-THESIS
      or report-type == REPORT-TYPES.TERM-PROJECT
  ) {
    scientific-ethics-declaration-page(
      author: author,
      date: date,
    )
  }

  /* --- Simgeler ve Kısaltmalar Sayfası [Symbols and Abbreviations Page] --- */
  if (
    (
      report-type == REPORT-TYPES.MASTER-THESIS
        or report-type == REPORT-TYPES.DOCTORAL-THESIS
        or report-type == REPORT-TYPES.TERM-PROJECT
    )
      and (have-symbols or have-abbreviations)
  ) {
    symbols-and-abbreviations-page(
      have-symbols: have-symbols,
      have-abbreviations: have-abbreviations,
    )
  }

  /* --- Türkçe Özet Sayfası [Turkish Abstract Page] --- */
  if (
    report-type == REPORT-TYPES.MASTER-THESIS
      or report-type == REPORT-TYPES.DOCTORAL-THESIS
      or report-type == REPORT-TYPES.TERM-PROJECT
  ) {
    turkish-abstract-page(
      department: department,
      program: program,
      report-type: report-type,
      report-title: report-title,
      author: author,
      keywords: keywords.tur,
    )
  }

  /* --- İngilizce Özet Sayfası [English Abstract Page] --- */
  if (
    report-type == REPORT-TYPES.MASTER-THESIS
      or report-type == REPORT-TYPES.DOCTORAL-THESIS
      or report-type == REPORT-TYPES.TERM-PROJECT
  ) {
    english-abstract-page(
      department: department,
      program: program,
      report-type: report-type,
      report-title: report-title,
      author: author,
      keywords: keywords.eng,
    )
  }
}
