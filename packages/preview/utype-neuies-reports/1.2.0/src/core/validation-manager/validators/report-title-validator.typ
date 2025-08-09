#import "/src/constants/validation-constants.typ": (
  STRING-ERROR-INLINE-TITLE,
  STRING-RELATED-DOCUMENTATION-INLINE-TITLE,
  STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK,
)
#import "/src/constants/drop-down-list-constants.typ": LANGUAGES
#import "/src/core/validation-manager/validators/dictionary-type-validator.typ": dictionary-type-validator

// Rapor başlığını doğrular. [Validates report title.]
#let report-title-validator(value: none) = {
  // Sözlük parametre türünü doğrula. [Validate dictionary parameter type.]
  dictionary-type-validator(
    value: value,
    value-name: "template-configurations.report-title",
    value-description: "Şablon ayarlarındaki rapor başlığı",
  )

  // Sözlük parametre türünü doğrula. [Validate dictionary parameter type.]
  dictionary-type-validator(
    value: value.tur,
    value-name: "template-configurations.report-title.tur",
    value-description: "Şablon ayarlarındaki Türkçe rapor başlığı",
  )

  // Sözlük parametre türünü doğrula. [Validate dictionary parameter type.]
  dictionary-type-validator(
    value: value.eng,
    value-name: "template-configurations.report-title.eng",
    value-description: "Şablon ayarlarındaki İngilizce rapor başlığı",
  )
}
