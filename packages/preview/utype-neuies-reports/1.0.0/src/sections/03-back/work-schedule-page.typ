#import "/src/styles/work-schedule-page-style.typ": work-schedule-page-style
#import "/src/constants/work-schedule-month-count-rule.typ": work-schedule-month-count-rule
#import "/src/constants/drop-down-list-constants.typ": REPORT-TYPES
#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys

// Çalışma Takvimi sayfası. [Work Schedule page.]
#let work-schedule-page(
  report-type: none,
  work-packages: none,
) = {
  // Sayfa stilini uygula [Apply page style]
  show: work-schedule-page-style

  // Rapor türüne göre çalışma takvimi aylarını belirle [Determine the months of the work schedule according to the type of report]
  let month-numbers = if report-type == REPORT-TYPES.MASTER-THESIS-PROPOSAL {
    array.range(1, work-schedule-month-count-rule.MASTER-THESIS-PROPOSAL + 1, step: 1)
  } else if report-type == REPORT-TYPES.DOCTORAL-THESIS-PROPOSAL {
    array.range(1, work-schedule-month-count-rule.DOCTORAL-THESIS-PROPOSAL + 1, step: 1)
  }

  // Sütun sayısını belirle [Determine the number of columns]
  let month-count = month-numbers.len()

  // Sayfa başlığı [Page title]
  heading(level: 1, translator(key: language-keys.WORK-SCHEDULE))

  // İş paketleri listesi [Work packages list]
  for (index, work-package) in work-packages.enumerate(start: 1) {
    [*#translator(key: language-keys.SHORT-WORK-PACKAGE) #index:* #work-package.description\ ]
  }

  // Tablo başlığındaki aylar [Months in the table header]
  let table-header-months = month-numbers.map(index => {
    [*#index*]
  })

  // Tablo hücreleri [Table cells]
  let table-cells = for (index, work-package) in work-packages.enumerate(start: 1) {
    (
      [*#translator(key: language-keys.SHORT-WORK-PACKAGE) #index*],
      ..month-numbers.map(month => {
        if work-package.months.contains(month) {
          table.cell(fill: rgb(166, 166, 166))[]
        } else {
          []
        }
      }),
    )
  }

  // Çalışma takvimi tablosu [Work schedule table]
  table(
    columns: (auto,) + ((1fr,) * month-count),
    align: center + horizon,
    table.header(
      table.cell(rowspan: 2)[*#translator(key: language-keys.SHORT-WORK-PACKAGE)\**],
      table.cell(colspan: month-count)[*#translator(key: language-keys.MONTHS)*],
      ..table-header-months,
    ), ..table-cells,
    table.footer(
      table.cell(
        colspan: month-count + 1,
        align: left,
        stroke: (
          left: 0pt,
          right: 0pt,
          bottom: 0pt,
        ),
      )[\*#translator(key: language-keys.SHORT-WORK-PACKAGE): #translator(key: language-keys.WORK-PACKAGE)],
    ),
  )

  // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).] [If the page at the end of the page is empty, the end of the page should be passive]
  pagebreak(weak: true)
}
