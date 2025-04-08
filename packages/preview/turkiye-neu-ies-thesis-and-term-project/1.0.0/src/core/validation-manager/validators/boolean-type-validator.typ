#import "/src/constants/validation-constants.typ": (
  STRING-ERROR-INLINE-TITLE,
  STRING-RELATED-DOCUMENTATION-INLINE-TITLE,
  STRING-TYPST-BOOLEAN-DOCUMENTATION-LINK,
)

// Girdinin mantıksal türde olduğunu doğrular. [Validates boolean type.]
#let boolean-type-validator(
  value: none,
  value-name: none,
  value-description: none,
) = {
  // Girdi, mantıksal türde değilse hata ver. [Throw error if value is not boolean type.]
  assert(
    type(value) == bool,
    message: STRING-ERROR-INLINE-TITLE
      + value-description
      + " alanındaki "
      + "'"
      + value-name
      + "' parametresine desteklenmeyen ya da hatalı bir giriş oldu. Lütfen 'true' ya da 'false' giriniz. "
      + STRING-RELATED-DOCUMENTATION-INLINE-TITLE
      + STRING-TYPST-BOOLEAN-DOCUMENTATION-LINK,
  )
}
