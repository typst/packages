#import "/src/constants/validation-constants.typ": (
  STRING-ERROR-INLINE-TITLE,
  STRING-RELATED-DOCUMENTATION-INLINE-TITLE,
  STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK,
)
#import "/src/constants/drop-down-list-constants.typ": ACADEMIC-MEMBER-TITLES

// Öğretim üyesi ünvanını doğrular. [Validates academic member title.]
#let academic-member-title-validator(value: none) = {
  // Tanımlı öğretim üyesi ünvanları dışındaki girdilerde hata ver. [Throw error for invalid academic member titles.]
  assert(
    value in ACADEMIC-MEMBER-TITLES.values(),
    message: STRING-ERROR-INLINE-TITLE
      + "'academic-member-title' parametresine desteklenmeyen ya da hatalı bir giriş oldu. Lütfen 'ACADEMIC-MEMBER-TITLES' sözlüğündeki bir öğretim üyesi ünvanı seçiniz. "
      + STRING-RELATED-DOCUMENTATION-INLINE-TITLE
      + STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK,
  )
}
