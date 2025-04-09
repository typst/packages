#import "/src/constants/drop-down-list-constants.typ": LANGUAGES, REPORT-TYPES
#import "/src/styles/thesis-back-section-style.typ": thesis-back-section-style
#import "/src/sections/03-back/work-schedule-page.typ": work-schedule-page
#import "/src/sections/03-back/bibliography-page.typ": bibliography-page
#import "/src/sections/03-back/appendices-page.typ": appendices-page
#import "/src/sections/03-back/curriculum-vitae-page.typ": curriculum-vitae-page
#import "/src/sections/03-back/expanded-turkish-abstract-page.typ": expanded-turkish-abstract-page

// Tezin Arka Kısmı. [Back Section of Thesis.]
#let thesis-back-section(
  language: none,
  department: none,
  program: none,
  report-type: none,
  report-title: none,
  author: none,
  work-packages: none,
  curriculum-vitae-info: none,
) = {
  // Tezin Arka Kısmının Stili [Style of Back Section of Thesis]
  show: thesis-back-section-style

  /* --- Çalışma Takvimi Sayfası [Work Schedule Page] --- */
  if (
    report-type == REPORT-TYPES.MASTER-THESIS-PROPOSAL or report-type == REPORT-TYPES.DOCTORAL-THESIS-PROPOSAL
  ) {
    work-schedule-page(
      report-type: report-type,
      work-packages: work-packages,
    )
  }

  /* --- Genişletilmiş Türkçe Özet Sayfası [Expanded Turkish Abstract Page] --- */
  if (
    language == LANGUAGES.EN-US
      and (
        report-type == REPORT-TYPES.MASTER-THESIS
          or report-type == REPORT-TYPES.DOCTORAL-THESIS
          or report-type == REPORT-TYPES.TERM-PROJECT
      )
  ) {
    expanded-turkish-abstract-page(
      department: department,
      program: program,
      report-type: report-type,
      report-title: report-title,
      author: author,
    )
  }

  /* --- Kaynaklar Sayfası [References Page]  --- */
  bibliography-page()

  /* --- Ekler Sayfası [Appendices Page]  --- */
  appendices-page()

  /* --- Öz Geçmiş Sayfası [Curriculum Vitae Page]  --- */
  if report-type == REPORT-TYPES.TERM-PROJECT {
    curriculum-vitae-page(
      first-name: author.first-name,
      last-name: author.last-name,
      orcid: author.orcid,
      ..curriculum-vitae-info,
    )
  }
}
