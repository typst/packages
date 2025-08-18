#import "/src/core/validation-manager/validators/dictionary-type-validator.typ": dictionary-type-validator
#import "/src/core/validation-manager/validators/minimum-value-validator.typ": minimum-value-validator
#import "/src/core/validation-manager/validators/maximum-value-validator.typ": maximum-value-validator

// Tez özgünlük raporunu doğrular. [Validates thesis originality report.]
#let thesis-originalty-validator(value: none) = {
  // Sözlük parametre türünü doğrula. [Validate dictionary parameter type.]
  dictionary-type-validator(
    value: value,
    value-name: "template-configurations.thesis-originalty",
    value-description: "Şablon ayarlarındaki tezin örijinalliği",
  )

  // Taranan sayfa sayısı parametresini doğrula. [Validate the included-page-count parameter.]
  minimum-value-validator(
    value: value.included-page-count,
    min-value: 1,
    value-name: "included-page-count",
    value-description: "Taranan sayfa sayısı",
  )

  // Benzerlik oranı parametresini doğrula. [Validate the similarity-score parameter.]
  minimum-value-validator(
    value: value.similarity-score,
    min-value: 0,
    value-name: "similarity-score",
    value-description: "Benzerlik oranı",
  )
  maximum-value-validator(
    value: value.similarity-score,
    max-value: 100,
    value-name: "similarity-score",
    value-description: "Benzerlik oranı",
  )
}
