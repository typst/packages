#import "/src/constants/validation-constants.typ": (
  STRING-ERROR-INLINE-TITLE,
  STRING-RELATED-DOCUMENTATION-INLINE-TITLE,
  WHAT-IS-MY-ORCID-ID-LINK,
)

// ORCID girdisinin geçerli bir ORCID ID olduğunu doğrular. [Validates if the ORCID value is a valid ORCID ID.]
#let orcid-validator(
  value: none,
  value-name: none,
  value-description: none,
) = {
  // Girdi, geçerli bir ORCID ID değilse hata ver. [Throw error if the ORCID value is not a valid ORCID ID.]
  assert(
    type(value.find(regex("\d{4}-\d{4}-\d{4}-\d{4}"))) == str,
    message: STRING-ERROR-INLINE-TITLE
      + value-description
      + " alanındaki "
      + "'"
      + value-name
      + "' parametresine desteklenmeyen ya da hatalı bir giriş oldu. Lütfen 'XXXX-XXXX-XXXX-XXXX' (X: rakam) şeklinde giriniz. "
      + STRING-RELATED-DOCUMENTATION-INLINE-TITLE
      + WHAT-IS-MY-ORCID-ID-LINK,
  )
}
