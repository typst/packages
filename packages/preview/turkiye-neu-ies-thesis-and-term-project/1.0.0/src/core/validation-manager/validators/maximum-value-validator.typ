#import "/src/constants/validation-constants.typ": (
  STRING-ERROR-INLINE-TITLE,
  STRING-RELATED-DOCUMENTATION-INLINE-TITLE,
  STRING-TYPST-INT-DOCUMENTATION-LINK,
)

// Girdinin, belirtilen en fazla değerden fazla olmadığını doğrular. [Validates if the value is less than or equal to the specified maximum value.]
#let maximum-value-validator(
  value: none,
  max-value: none,
  value-name: none,
  value-description: none,
  documantation-link: STRING-TYPST-INT-DOCUMENTATION-LINK,
) = {
  // Mesajın ilk kısmı. [The first part of the message.]
  let message-part-1 = "'" + value-name + "' parametresine desteklenmeyen ya da hatalı bir giriş oldu. "

  // Mesajın ikinci kısmı. [The second part of the message.]
  let message-part-2 = STRING-RELATED-DOCUMENTATION-INLINE-TITLE + documantation-link

  // Girdi, belirtilen en fazla değerden fazla ise hata ver. [Throw error if the value is greater than the specified maximum value.]
  assert(
    value <= max-value,
    message: STRING-ERROR-INLINE-TITLE
      + message-part-1
      + value-description
      + " en fazla "
      + str(max-value)
      + " olabilir. "
      + message-part-2,
  )
}
