#import "/src/constants/validation-constants.typ": (
  STRING-ERROR-INLINE-TITLE,
  STRING-RELATED-DOCUMENTATION-INLINE-TITLE,
  STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK,
)
#import "/src/constants/drop-down-list-constants.typ": DEPARTMENTS
#import "/src/core/validation-manager/validators/dictionary-type-validator.typ": dictionary-type-validator

// Ana Bilim Dalını doğrula. [Validate the department.]
#let department-validator(value: none) = {
  // Tanımlı Ana Bilim Dalları dışındaki girdilerde hata ver. [Throw error for invalid departments.]
  assert(
    value in DEPARTMENTS.values(),
    message: STRING-ERROR-INLINE-TITLE
      + "'department' parametresine desteklenmeyen ya da hatalı bir giriş oldu. Lütfen 'DEPARTMENTS' sözlüğündeki bir ana bilim dalını seçiniz. "
      + STRING-RELATED-DOCUMENTATION-INLINE-TITLE
      + STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK,
  )
}
