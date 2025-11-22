#import "/src/core/validation-manager/validators/dictionary-type-validator.typ": dictionary-type-validator
#import "/src/core/validation-manager/validators/array-type-validator.typ": array-type-validator
#import "/src/core/validation-manager/validators/minimum-value-validator.typ": minimum-value-validator
#import "/src/core/validation-manager/validators/maximum-value-validator.typ": maximum-value-validator
#import "/src/constants/keyword-count-rule.typ": keyword-count-rule
#import "/src/constants/validation-constants.typ": STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK

// Anahtar Kelime girdisinin geçerli ve anahtar kelime sayısı kuralına uygun olduğunu doğrular. [Validates if the keywords value is valid and matches the keyword count rule.]
#let keywords-validator(value: none) = {
  // Sözlük parametre türünü doğrula. [Validate dictionary parameter type.]
  dictionary-type-validator(
    value: value,
    value-name: "template-configurations.keywords",
    value-description: "Şablon ayarlarındaki anahtar kelimeler",
  )

  // Dizi parametre türünü doğrula. [Validate array parameter type.]
  array-type-validator(
    value: value.tur,
    value-name: "template-configurations.keywords.tur",
    value-description: "Şablon ayarlarındaki Türkçe anahtar kelimeler",
  )
  array-type-validator(
    value: value.eng,
    value-name: "template-configurations.keywords.eng",
    value-description: "Şablon ayarlarındaki İngilizce anahtar kelimeler",
  )

  // Türkçe anahtar kelime sayısını doğrula. [Validate Turkish keyword count.]
  minimum-value-validator(
    value: value.tur.len(),
    min-value: keyword-count-rule.MIN,
    value-name: "keywords.tur",
    value-description: "Türkçe anahtar kelime sayısı",
    documantation-link: STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK,
  )
  maximum-value-validator(
    value: value.tur.len(),
    max-value: keyword-count-rule.MAX,
    value-name: "keywords.tur",
    value-description: "Türkçe anahtar kelime sayısı",
    documantation-link: STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK,
  )

  // İngilizce anahtar kelime sayısını doğrula. [Validate English keyword count.]
  minimum-value-validator(
    value: value.eng.len(),
    min-value: keyword-count-rule.MIN,
    value-name: "keywords.eng",
    value-description: "İngilizce anahtar kelime sayısı",
    documantation-link: STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK,
  )
  maximum-value-validator(
    value: value.eng.len(),
    max-value: keyword-count-rule.MAX,
    value-name: "keywords.eng",
    value-description: "İngilizce anahtar kelime sayısı",
    documantation-link: STRING-TYPST-DICTIONARY-DOCUMENTATION-LINK,
  )
}
