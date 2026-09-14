#import "/src/constants/validation-constants.typ": (
  STRING-ERROR-INLINE-TITLE,
  STRING-RELATED-DOCUMENTATION-INLINE-TITLE,
  STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK,
)
#import "/src/constants/drop-down-list-constants.typ": LANGUAGES
#import "/src/core/validation-manager/validators/dictionary-type-validator.typ": dictionary-type-validator

// Dili doğrular. [Validates the language.]
#let language-validator(value: none) = {
  // Sözlük parametre türünü doğrula. [Validate dictionary parameter type.]
  dictionary-type-validator(
    value: value,
    value-name: "template-configurations.language",
    value-description: "Şablon ayarlarındaki dil",
  )

  // Tanımlı dil değerleri dışındaki girdilerde hata ver. [Throw error for invalid languages.]
  assert(
    value in LANGUAGES.values(),
    message: STRING-ERROR-INLINE-TITLE
      + "'language' parametresine desteklenmeyen ya da hatalı bir giriş oldu. Lütfen 'LANGUAGES' sözlüğündeki bir dili seçiniz. "
      + STRING-RELATED-DOCUMENTATION-INLINE-TITLE
      + STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK,
  )
}
