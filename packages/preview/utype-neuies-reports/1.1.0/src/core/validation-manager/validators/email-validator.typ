#import "/src/constants/validation-constants.typ": (
  STRING-ERROR-INLINE-TITLE,
  STRING-RELATED-DOCUMENTATION-INLINE-TITLE,
  STRING-TYPST-STR-DOCUMENTATION-LINK,
)

// Girdinin geçerli bir e-posta adresi olduğunu doğrular. [Validates if the value is a valid email address.]
#let email-validator(
  value: none,
  value-name: none,
  value-description: none,
) = {
  // Girdi, geçerli bir e-posta adresi değilse hata ver. [Throw error if the value is not a valid email address.]
  assert(
    type(value.find(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"))) == str,
    message: STRING-ERROR-INLINE-TITLE
      + value-description
      + " alanındaki "
      + "'"
      + value-name
      + "' parametresine desteklenmeyen ya da hatalı bir giriş oldu. Lütfen geçerli bir email giriniz. "
      + STRING-RELATED-DOCUMENTATION-INLINE-TITLE
      + STRING-TYPST-STR-DOCUMENTATION-LINK,
  )
}
