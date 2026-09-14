#import "/src/constants/validation-constants.typ": (
  STRING-ERROR-INLINE-TITLE,
  STRING-RELATED-DOCUMENTATION-INLINE-TITLE,
  STRING-TYPST-ARRAY-DOCUMENTATION-LINK,
)
#import "/src/constants/drop-down-list-constants.typ": REPORT-TYPES
#import "/src/constants/work-schedule-month-count-rule.typ": work-schedule-month-count-rule
#import "/src/core/validation-manager/validators/dictionary-type-validator.typ": dictionary-type-validator
#import "/src/core/validation-manager/validators/array-type-validator.typ": array-type-validator

// İş paketlerini doğrular. [Validates work packages.]
#let work-packages-validator(
  value: none,
  report-type: none,
) = {
  // Dizi parametre türünü doğrula. [Validate array parameter type.]
  array-type-validator(
    value: value,
    value-name: "template-configurations.work-packages",
    value-description: "Şablon ayarlarındaki iş paketleri",
  )

  // Sözlük parametre türünü doğrula. [Validate dictionary parameter type.]
  for (index, work-package) in value.enumerate(start: 1) {
    dictionary-type-validator(
      value: work-package,
      value-name: "template-configurations.work-packages",
      value-description: "Şablon ayarlarındaki " + str(index) + ". iş paketi",
    )
  }

  // Ay sayısını rapor türüne göre seç. [Select the month count according to the report type.]
  let month-count = if report-type == REPORT-TYPES.MASTER-THESIS-PROPOSAL {
    work-schedule-month-count-rule.MASTER-THESIS-PROPOSAL
  } else if report-type == REPORT-TYPES.DOCTORAL-THESIS-PROPOSAL {
    work-schedule-month-count-rule.DOCTORAL-THESIS-PROPOSAL
  }

  // Girilen iş paketlerinin birleştirerek bir dizi oluştur. [Create an array by combining the entered work packages.]
  let work-packages-months = ()
  for work-package in value {
    for month in work-package.months {
      if not (work-packages-months.contains(month)) {
        work-packages-months.push(month)
      }
    }
  }

  // İş paketlerinin doğrulama değerini oluştur. [Create the validation value of the work packages.]
  let assertion-value = array.range(1, month-count + 1, step: 1)

  // İş Paketlerinin toplam ay sayısını doğrula. [Validate th sum of the month count of work-packages.]
  assert(
    work-packages-months == assertion-value,
    message: STRING-ERROR-INLINE-TITLE
      + "'work-packages' parametresi içerindeki 'months' parametresine ya da parametrelerine desteklenmeyen ya da hatalı bir giriş oldu. "
      + str(month-count)
      + " aylık çalışma takviminde eksik aylar var. Lütfen iş paketlerine karşılık gelen ayların toplamda "
      + str(month-count)
      + " ay olduğundan emin olun. "
      + STRING-RELATED-DOCUMENTATION-INLINE-TITLE
      + STRING-TYPST-ARRAY-DOCUMENTATION-LINK,
  )
}
