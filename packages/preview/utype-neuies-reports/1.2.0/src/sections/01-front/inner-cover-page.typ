#import "/src/constants/drop-down-list-constants.typ": REPORT-TYPES
#import "/src/components/inner-cover-page/thesis-proposal-inner-cover-page-component.typ": (
  thesis-proposal-inner-cover-page-component,
)
#import "/src/components/inner-cover-page/thesis-inner-cover-page-component.typ": thesis-inner-cover-page-component
#import "/src/components/inner-cover-page/term-project-inner-cover-page-component.typ": (
  term-project-inner-cover-page-component,
)

// İç Kapak sayfası. [Inner Cover page.]
#let inner-cover-page(
  language: none,
  department: none,
  program: none,
  report-type: none,
  date: none,
  report-title: none,
  author: none,
  advisor: none,
  second-advisor: none,
  thesis-study-funding-organization: none,
) = {
  // Rapor türüne göre ilgili iç kapak sayfasını seç. [Select the inner cover page according to the report type.]
  if (
    report-type == REPORT-TYPES.MASTER-THESIS-PROPOSAL or report-type == REPORT-TYPES.DOCTORAL-THESIS-PROPOSAL
  ) {
    thesis-proposal-inner-cover-page-component(
      language: language,
      department: department,
      program: program,
      report-type: report-type,
      date: date,
      report-title: report-title,
      author: author,
      advisor: advisor,
      second-advisor: second-advisor,
      thesis-study-funding-organization: thesis-study-funding-organization,
    )
  } else if (report-type == REPORT-TYPES.MASTER-THESIS or report-type == REPORT-TYPES.DOCTORAL-THESIS) {
    thesis-inner-cover-page-component(
      language: language,
      department: department,
      program: program,
      report-type: report-type,
      date: date,
      report-title: report-title,
      author: author,
      advisor: advisor,
      second-advisor: second-advisor,
      thesis-study-funding-organization: thesis-study-funding-organization,
    )
  } else if report-type == REPORT-TYPES.TERM-PROJECT {
    term-project-inner-cover-page-component(
      language: language,
      department: department,
      program: program,
      report-type: report-type,
      date: date,
      report-title: report-title,
      author: author,
      advisor: advisor,
      second-advisor: second-advisor,
      thesis-study-funding-organization: thesis-study-funding-organization,
    )
  }

  // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
  pagebreak(weak: true)
}
