#import "/src/constants/drop-down-list-constants.typ": REPORT-TYPES
#import "/src/core/validation-manager/validators/boolean-type-validator.typ": boolean-type-validator
#import "/src/core/validation-manager/validators/array-type-validator.typ": array-type-validator
#import "/src/core/validation-manager/validators/dictionary-type-validator.typ": dictionary-type-validator
#import "/src/core/validation-manager/validators/datetime-type-validator.typ": datetime-type-validator
#import "/src/core/validation-manager/validators/language-validator.typ": language-validator
#import "/src/core/validation-manager/validators/department-validator.typ": department-validator
#import "/src/core/validation-manager/validators/program-validator.typ": program-validator
#import "/src/core/validation-manager/validators/report-type-validator.typ": report-type-validator
#import "/src/core/validation-manager/validators/report-title-validator.typ": report-title-validator
#import "/src/core/validation-manager/validators/author-validator.typ": author-validator
#import "/src/core/validation-manager/validators/advisor-validator.typ": advisor-validator
#import "/src/core/validation-manager/validators/second-advisor-validator.typ": second-advisor-validator
#import "/src/core/validation-manager/validators/orcid-validator.typ": orcid-validator
#import "/src/core/validation-manager/validators/academic-member-title-validator.typ": academic-member-title-validator
#import "/src/core/validation-manager/validators/thesis-originalty-validator.typ": thesis-originalty-validator
#import "/src/core/validation-manager/validators/keywords-validator.typ": keywords-validator
#import "/src/core/validation-manager/validators/work-packages-validator.typ": work-packages-validator
#import "/src/core/validation-manager/validators/curriculum-vitae-info-validator.typ": curriculum-vitae-info-validator

// Şablon parametrelerinin doğrulama işlemlerini yapan yönetici fonksiyondur. [Manager function for validating template parameters.]
#let validation-manager(
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
  thesis-originalty: none,
  keywords: none,
  show-list-of-table-figures: none,
  show-list-of-image-figures: none,
  show-list-of-math-equations: none,
  show-list-of-code-figures: none,
  have-symbols: none,
  have-abbreviations: none,
  have-introduction-in-term-project: none,
  have-literature-review-in-term-project: none,
  have-methodology-in-term-project: none,
  have-findings-in-term-project: none,
  have-discussion-conclusion-and-suggestions-in-term-project: none,
  show-separated-sub-headings-in-discussion-conclusion-and-suggestions: none,
  work-packages: none,
  curriculum-vitae-info: none,
) = {
  /* ---- Doğrulama İşlemleri [Validation Process] ---- */

  // Dil parametresini doğrula. [Validate the language parameter.]
  language-validator(value: language)

  // Ana Bilim Dalı parametresini doğrula. [Validate the department parameter.]
  department-validator(value: department)

  // Bilim Dalı parametresini doğrula. [Validate the program parameter.]
  program-validator(value: program)

  // Rapor türü parametresini doğrula. [Validate the report type parameter.]
  report-type-validator(value: report-type)

  // Tarih parametresini doğrula. [Validate the date parameter.]
  datetime-type-validator(
    value: date,
    value-name: "template-configurations.date",
    value-description: "Şablon ayarlarındaki tarih",
  )

  // Rapor Başlığı parametresini doğrula. [Validate the report-title parameter.]
  report-title-validator(value: report-title)

  // Yazar parametresini doğrula. [Validate the author parameter.]
  author-validator(value: author)

  // Danışmanın ORCID parametresini doğrula. [Validate the advisor's ORCID parameter.]
  advisor-validator(value: advisor)

  // İkinci Danışmanın ORCID parametresini doğrula. [Validate the second advisor's ORCID parameter.]
  if second-advisor != none {
    second-advisor-validator(value: second-advisor)
  }

  // Tez Çalışmasını Destekleyen Kuruluş parametresini doğrula. [Validate thesis-study-funding-organization parameter.]
  if thesis-study-funding-organization != none {
    dictionary-type-validator(
      value: thesis-study-funding-organization,
      value-name: "template-configurations.thesis-study-funding-organization",
      value-description: "Şablon ayarlarındaki Tez Çalışmasını Destekleyen Kuruluş",
    )
  }

  // Orijinallik parametresini doğrula. [Verify the authenticity parameter.]
  if (
    report-type == REPORT-TYPES.MASTER-THESIS or report-type == REPORT-TYPES.DOCTORAL-THESIS
  ) {
    thesis-originalty-validator(value: thesis-originalty)
  }

  // Anahtar Kelimeler parametresini doğrula. [Validate keywords parameter.]
  keywords-validator(value: keywords)

  // Tablo figürleri listesini göster parametresini doğrula. [Validate show-list-of-table-figures parameter.]
  boolean-type-validator(
    value: show-list-of-table-figures,
    value-name: "template-configurations.show-list-of-table-figures",
    value-description: "Şablon ayarlarındaki tablo figürleri listesini göster seçeneği",
  )

  // Şekil figürleri listesini göster parametresini doğrula. [Validate show-list-of-image-figures parameter.]
  boolean-type-validator(
    value: show-list-of-image-figures,
    value-name: "template-configurations.show-list-of-image-figures",
    value-description: "Şablon ayarlarındaki şekil figürleri listesini göster seçeneği",
  )

  // Denklem figürleri listesini göster parametresini doğrula. [Validate show-list-of-math-equations parameter.]
  boolean-type-validator(
    value: show-list-of-math-equations,
    value-name: "template-configurations.show-list-of-math-equations",
    value-description: "Şablon ayarlarındaki denklem figürleri listesini göster seçeneği",
  )

  // Kod figürleri listesini göster parametresini doğrula. [Validate show-list-of-code-figures parameter.]
  boolean-type-validator(
    value: show-list-of-code-figures,
    value-name: "template-configurations.show-list-of-code-figures",
    value-description: "Şablon ayarlarındaki kod figürleri listesini göster seçeneği",
  )

  // Simgelerim var parametresini doğrula. [Validate have-symbols parameter.]
  boolean-type-validator(
    value: have-symbols,
    value-name: "template-configurations.have-symbols",
    value-description: "Şablon ayarlarındaki simgelerim var seçeneği",
  )

  // Kısaltmalarım var parametresini doğrula. [Validate have-abbreviations parameter.]
  boolean-type-validator(
    value: have-abbreviations,
    value-name: "template-configurations.have-abbreviations",
    value-description: "Şablon ayarlarındaki kısaltmalarım var seçeneği",
  )

  // Dönem Projemde "Giriş" başlığım var parametresini doğrula. [Validate have-introduction-in-term-project parameter.]
  boolean-type-validator(
    value: have-introduction-in-term-project,
    value-name: "template-configurations.have-introduction-in-term-project",
    value-description: "Şablon ayarlarındaki dönem projemde 'Giriş' başlığım var seçeneği",
  )

  // Dönem Projemde "Alan Yazın (İlgili Araştırmalar)" başlığım var parametresini doğrula. [Validate have-literature-review-in-term-project parameter.]
  boolean-type-validator(
    value: have-literature-review-in-term-project,
    value-name: "template-configurations.have-literature-review-in-term-project",
    value-description: "Şablon ayarlarındaki dönem projemde 'Alan Yazın (İlgili Araştırmalar)' başlığım var seçeneği",
  )

  // Dönem Projemde "Yöntem" başlığım var parametresini doğrula. [Validate have-methodology-in-term-project parameter.]
  boolean-type-validator(
    value: have-methodology-in-term-project,
    value-name: "template-configurations.have-methodology-in-term-project",
    value-description: "Şablon ayarlarındaki dönem projemde 'Yöntem' başlığım var seçeneği",
  )

  // Dönem Projemde "Bulgular" başlığım var parametresini doğrula. [Validate have-findings-in-term-project parameter.]
  boolean-type-validator(
    value: have-findings-in-term-project,
    value-name: "template-configurations.have-findings-in-term-project",
    value-description: "Şablon ayarlarındaki dönem projemde 'Bulgular' başlığım var seçeneği",
  )

  // Dönem Projemde "Tartışma, Sonuç ve Öneriler" başlığım var parametresini doğrula. [Validate have-discussion-conclusion-and-suggestions-in-term-project parameter.]
  boolean-type-validator(
    value: have-discussion-conclusion-and-suggestions-in-term-project,
    value-name: "template-configurations.have-discussion-conclusion-and-suggestions-in-term-project",
    value-description: "Şablon ayarlarındaki dönem projemde 'Tartışma, Sonuç ve Öneriler' başlığım var seçeneği",
  )

  // 'TARTIŞMA, SONUÇ VE ÖNERİLER' bölümündeki alt başlıkları göster parametresini doğrula. [Validate show-separated-sub-headings-in-discussion-conclusion-and-suggestions parameter.]
  boolean-type-validator(
    value: show-separated-sub-headings-in-discussion-conclusion-and-suggestions,
    value-name: "template-configurations.show-separated-sub-headings-in-discussion-conclusion-and-suggestions",
    value-description: "Şablon ayarlarındaki 'TARTIŞMA, SONUÇ VE ÖNERİLER' bölümündeki alt başlıkları göster seçeneği",
  )

  // Çalışma Takvimindeki iş paketlerinin aylarının toplamını doğrula. [Validate the sum of the months of work packages in the Work Schedule.]
  if (
    report-type == REPORT-TYPES.MASTER-THESIS-PROPOSAL or report-type == REPORT-TYPES.DOCTORAL-THESIS-PROPOSAL
  ) {
    work-packages-validator(value: work-packages, report-type: report-type)
  }

  // Öz Geçmişi doğrula. [Validate the Curriculum Vitae.]
  if report-type == REPORT-TYPES.TERM-PROJECT {
    curriculum-vitae-info-validator(value: curriculum-vitae-info)
  }
}
