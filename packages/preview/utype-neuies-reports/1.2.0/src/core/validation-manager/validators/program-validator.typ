#import "/src/constants/validation-constants.typ": (
  STRING-ERROR-INLINE-TITLE,
  STRING-RELATED-DOCUMENTATION-INLINE-TITLE,
  STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK,
)
#import "/src/constants/drop-down-list-constants.typ": PROGRAMS

// Bilim Dalını doğrular. [Validates the program.]
#let program-validator(value: none) = {
  // Tanımlı Bilim Dalları dışındaki girdilerde hata ver. [Throw error for invalid programs.]
  assert(
    value in PROGRAMS.values(),
    message: STRING-ERROR-INLINE-TITLE
      + "'program' parametresine desteklenmeyen ya da hatalı bir giriş oldu. Lütfen 'PROGRAMS' sözlüğündeki bir bilim dalını seçiniz. "
      + STRING-RELATED-DOCUMENTATION-INLINE-TITLE
      + STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK,
  )
}
