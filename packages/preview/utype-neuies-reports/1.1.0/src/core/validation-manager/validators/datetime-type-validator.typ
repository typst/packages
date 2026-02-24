#import "/src/constants/validation-constants.typ": (
  STRING-ERROR-INLINE-TITLE,
  STRING-RELATED-DOCUMENTATION-INLINE-TITLE,
  STRING-TYPST-DATETIME-DOCUMENTATION-LINK,
)

// Girdinin tarih-zaman türünde olduğunu doğrular. [Validates if the value is a datetime.]
#let datetime-type-validator(
  value: none,
  value-name: none,
  value-description: none,
) = {
  // Girdi, tarih-zaman türünde değilse hata ver. [Throw error if the value is not a datetime type.]
  assert(
    type(value) == datetime,
    message: STRING-ERROR-INLINE-TITLE
      + value-description
      + " alanındaki "
      + "'"
      + value-name
      + "' parametresine desteklenmeyen ya da hatalı bir giriş oldu. Lütfen 'datetime' fonksiyonunu kullanarak tarih giriniz. "
      + STRING-RELATED-DOCUMENTATION-INLINE-TITLE
      + STRING-TYPST-DATETIME-DOCUMENTATION-LINK,
  )
}
