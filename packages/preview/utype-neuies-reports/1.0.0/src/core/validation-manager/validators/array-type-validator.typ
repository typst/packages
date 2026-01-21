#import "/src/constants/validation-constants.typ": (
  STRING-ERROR-INLINE-TITLE,
  STRING-RELATED-DOCUMENTATION-INLINE-TITLE,
  STRING-TYPST-ARRAY-DOCUMENTATION-LINK,
)

// Girdinin dizi türünde olduğunu doğrular. [Validates if the value is an array.]
#let array-type-validator(
  value: none,
  value-name: none,
  value-description: none,
) = {
  // Girdi, dizi türünde değilse hata ver. [Throw error if the value is not an array type.]
  assert(
    type(value) == array,
    message: STRING-ERROR-INLINE-TITLE
      + value-description
      + " alanındaki "
      + "'"
      + value-name
      + "' parametresine desteklenmeyen ya da hatalı bir giriş oldu. Lütfen 'array(1, ...)' ya da '(1, ...)' şeklinde bir söz dizimi ile dizi (array) giriniz. "
      + STRING-RELATED-DOCUMENTATION-INLINE-TITLE
      + STRING-TYPST-ARRAY-DOCUMENTATION-LINK,
  )
}
