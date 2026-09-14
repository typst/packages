#import "/src/constants/drop-down-list-constants.typ": REPORT-TYPES
#import "/src/styles/thesis-main-section-style.typ": thesis-main-section-style
#import "/src/sections/02-main/introduction-page.typ": introduction-page
#import "/src/sections/02-main/literature-review-page.typ": literature-review-page
#import "/src/sections/02-main/methodology-page.typ": methodology-page
#import "/src/sections/02-main/findings-page.typ": findings-page
#import "/src/sections/02-main/discussion-conclusion-and-suggestions-page.typ": (
  discussion-conclusion-and-suggestions-page,
)

// Tezin Ana Kısmı. [Main Section of Thesis.]
#let thesis-main-section(
  report-type: none,
  have-introduction-in-term-project: none,
  have-literature-review-in-term-project: none,
  have-methodology-in-term-project: none,
  have-findings-in-term-project: none,
  have-discussion-conclusion-and-suggestions-in-term-project: none,
  show-separated-sub-headings-in-discussion-conclusion-and-suggestions: none,
) = {
  // Tezin Ana Kısmının Stili [Style of Main Section of Thesis]
  show: thesis-main-section-style

  /* --- Bölüm 1: Giriş [Chapter 1: Introduction] --- */
  if (report-type == REPORT-TYPES.TERM-PROJECT and have-introduction-in-term-project == false) {
    []
  } else {
    introduction-page()
  }

  /* --- Bölüm 2: Alan Yazın (İlgi̇li̇ Araştırmalar) [Chapter 2: Literature Review] --- */
  if (report-type == REPORT-TYPES.TERM-PROJECT and have-literature-review-in-term-project == false) {
    []
  } else {
    literature-review-page()
  }

  /* --- Bölüm 3: Yöntem [Chapter 3: Methodology] --- */
  if (report-type == REPORT-TYPES.TERM-PROJECT and have-methodology-in-term-project == false) {
    []
  } else {
    methodology-page()
  }

  /* --- Bölüm 4: Bulgular [Chapter 4: Findings] --- */
  if (report-type == REPORT-TYPES.TERM-PROJECT and have-findings-in-term-project == false) {
    []
  } else {
    if (
      report-type == REPORT-TYPES.MASTER-THESIS
        or report-type == REPORT-TYPES.DOCTORAL-THESIS
        or report-type == REPORT-TYPES.TERM-PROJECT
    ) {
      findings-page()
    }
  }

  /* --- Bölüm 5: Tartışma, Sonuç ve Öneriler [Chapter 5: Discussion, Conclusion and Suggestions] --- */
  if (
    report-type == REPORT-TYPES.TERM-PROJECT and have-discussion-conclusion-and-suggestions-in-term-project == false
  ) {
    []
  } else {
    if (
      report-type == REPORT-TYPES.MASTER-THESIS
        or report-type == REPORT-TYPES.DOCTORAL-THESIS
        or report-type == REPORT-TYPES.TERM-PROJECT
    ) {
      discussion-conclusion-and-suggestions-page(
        show-separated-sub-headings: show-separated-sub-headings-in-discussion-conclusion-and-suggestions,
      )
    }
  }
}
