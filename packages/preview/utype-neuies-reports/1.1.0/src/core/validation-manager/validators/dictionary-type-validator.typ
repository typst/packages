#import "/src/constants/validation-constants.typ": (
  STRING-ERROR-INLINE-TITLE,
  STRING-RELATED-DOCUMENTATION-INLINE-TITLE,
  STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK,
)

// Girdinin dözlük türünde olduğunu doğrular. [Validates if the value is a dictionary.]
#let dictionary-type-validator(
  value: none,
  value-name: none,
  value-description: none,
) = {
  // Girdi, sözlük türünde değilse hata ver. [Throw error if the value is not a dictionary type.]
  assert(
    type(value) == dictionary,
    message: STRING-ERROR-INLINE-TITLE
      + value-description
      + " alanındaki "
      + "'"
      + value-name
      + "' parametresine desteklenmeyen ya da hatalı bir giriş oldu. Lütfen '(key: value)' şeklinde bir söz dizimi ile sözlük (dictionary) giriniz. "
      + STRING-RELATED-DOCUMENTATION-INLINE-TITLE
      + STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK,
  )
}
