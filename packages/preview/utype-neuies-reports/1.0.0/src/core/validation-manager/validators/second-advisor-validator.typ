#import "/src/core/validation-manager/validators/dictionary-type-validator.typ": dictionary-type-validator
#import "/src/core/validation-manager/validators/orcid-validator.typ": orcid-validator
#import "/src/core/validation-manager/validators/academic-member-title-validator.typ": academic-member-title-validator

// İkinci Danışman bilgilerini doğrular. [Validates second advisor information.]
#let second-advisor-validator(value: none) = {
  // Sözlük parametre türünü doğrula. [Validate dictionary parameter type.]
  dictionary-type-validator(
    value: value,
    value-name: "template-configurations.second-advisor",
    value-description: "Şablon ayarlarındaki ikinci danışman",
  )

  // İkinci Danışmanın ORCID parametresini doğrula. [Validate the second advisor's ORCID parameter.]
  orcid-validator(
    value: value.orcid,
    value-name: "second-advisor.orcid",
    value-description: "İkinci Danışmanın ORCID değeri",
  )

  // Akademik ünvanı doğrula. [Validate the academic title.]
  academic-member-title-validator(value: value.academic-member-title)
}
