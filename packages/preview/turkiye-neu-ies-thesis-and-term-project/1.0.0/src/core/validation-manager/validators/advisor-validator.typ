#import "/src/core/validation-manager/validators/dictionary-type-validator.typ": dictionary-type-validator
#import "/src/core/validation-manager/validators/orcid-validator.typ": orcid-validator
#import "/src/core/validation-manager/validators/academic-member-title-validator.typ": academic-member-title-validator

// Danışman bilgilerini doğrular. [Validates advisor information.]
#let advisor-validator(value: none) = {
  // Sözlük parametre türünü doğrula. [Validate dictionary parameter type.]
  dictionary-type-validator(
    value: value,
    value-name: "template-configurations.advisor",
    value-description: "Şablon ayarlarındaki danışman",
  )

  // Danışmanın ORCID parametresini doğrula. [Validate the advisor's ORCID parameter.]
  orcid-validator(
    value: value.orcid,
    value-name: "advisor.orcid",
    value-description: "Danışmanın ORCID değeri",
  )

  // Akademik ünvanı doğrula. [Validate the academic title.]
  academic-member-title-validator(value: value.academic-member-title)
}
