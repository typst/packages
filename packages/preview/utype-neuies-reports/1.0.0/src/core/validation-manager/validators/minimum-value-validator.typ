#import "/src/constants/validation-constants.typ": (
  STRING-ERROR-INLINE-TITLE,
  STRING-RELATED-DOCUMENTATION-INLINE-TITLE,
  STRING-TYPST-INT-DOCUMENTATION-LINK,
)

// Girdinin belirtilen en az değerden az olmadığını doğrular. [Validates if the value is greater than or equal to the specified minimum value.]
#let minimum-value-validator(
  value: none,
  min-value: none,
  value-name: none,
  value-description: none,
  documantation-link: STRING-TYPST-INT-DOCUMENTATION-LINK,
) = {
  // Mesajın ilk kısmı. [The first part of the message.]
  let message-part-1 = "'" + value-name + "' parametresine desteklenmeyen ya da hatalı bir giriş oldu. "

  // Mesajın ikinci kısmı. [The second part of the message.]
  let message-part-2 = (
    STRING-RELATED-DOCUMENTATION-INLINE-TITLE + documantation-link
  )

  // Girdi, belirtilen en az değerden az ise hata ver. [Throw error if the value is less than the specified minimum value.]
  assert(
    value >= min-value,
    message: STRING-ERROR-INLINE-TITLE
      + message-part-1
      + value-description
      + " en az "
      + str(min-value)
      + " olabilir. "
      + message-part-2,
  )
}
