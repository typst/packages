#import "/src/core/validation-manager/validators/datetime-type-validator.typ": datetime-type-validator
#import "/src/core/validation-manager/validators/dictionary-type-validator.typ": dictionary-type-validator
#import "/src/core/validation-manager/validators/array-type-validator.typ": array-type-validator
#import "/src/core/validation-manager/validators/orcid-validator.typ": orcid-validator
#import "/src/core/validation-manager/validators/email-validator.typ": email-validator

// Öz Geçmiş bilgilerini doğrular. [Validates curriculum vitae information.]
#let curriculum-vitae-info-validator(value: none) = {
  // Doğum günü parametresini doğrula. [Validate the birthday parameter.]
  datetime-type-validator(
    value: value.birthday,
    value-name: "curriculum-vitae.birthday",
    value-description: "Öz Geçmiş sayfasındaki doğum tarihi",
  )

  // Sözlük parametre türünü doğrula. [Validate dictionary parameter type.]
  dictionary-type-validator(
    value: value.high-school,
    value-name: "template-configurations.high-school",
    value-description: "Şablon ayarlarındaki lise",
  )

  // Sözlük parametre türünü doğrula. [Validate dictionary parameter type.]
  dictionary-type-validator(
    value: value.undergraduate,
    value-name: "template-configurations.undergraduate",
    value-description: "Şablon ayarlarındaki lisans",
  )

  // Sözlük parametre türünü doğrula. [Validate dictionary parameter type.]
  dictionary-type-validator(
    value: value.masters-degree,
    value-name: "template-configurations.masters-degree",
    value-description: "Şablon ayarlarındaki yüksek lisans",
  )

  // Dizi parametre türünü doğrula. [Validate array parameter type.]
  array-type-validator(
    value: value.skills,
    value-name: "curriculum-vitae-info.skills",
    value-description: "Öz Geçmişdeki beceriler",
  )

  // Dizi parametre türünü doğrula. [Validate array parameter type.]
  array-type-validator(
    value: value.work-experiences,
    value-name: "curriculum-vitae-info.work-experiences",
    value-description: "Öz Geçmişdeki iş deneyimleri",
  )

  // Dizi parametre türünü doğrula. [Validate array parameter type.]
  array-type-validator(
    value: value.get-info-from-recommended-peoples,
    value-name: "curriculum-vitae-info.get-info-from-recommended-peoples",
    value-description: "Öz Geçmişdeki bilgi almak için önerebileceğim şahıs",
  )

  // E-Posta parametresini doğrula. [Validate the email parameter.]
  email-validator(
    value: value.email,
    value-name: "curriculum-vitae.email",
    value-description: "Öz Geçmiş sayfasındaki e-posta adresi",
  )

  // İş Deneyimleri parametresini doğrula. [Validate the work-experiences parameter.]
  for (index, work-experience) in value.work-experiences.enumerate(start: 1) {
    // Sözlük parametre türünü doğrula. [Validate dictionary parameter type.]
    dictionary-type-validator(
      value: work-experience,
      value-name: "template-configurations.work-experience",
      value-description: "Şablon ayarlarındaki " + str(index) + ". iş deneyimi",
    )

    // Başlangıç Tarihi parametresini doğrula. [Validate the start-date parameter.]
    datetime-type-validator(
      value: work-experience.start-date,
      value-name: "curriculum-vitae parametresindeki work-experience.start-date",
      value-description: "Öz Geçmişteki" + str(index) + ". iş deneyiminin başlangıç tarihi",
    )

    // Bitiş Tarihi parametresini doğrula. [Validate the end-date parameter.]
    datetime-type-validator(
      value: work-experience.end-date,
      value-name: "curriculum-vitae parametresindeki work-experience.end-date",
      value-description: "Öz Geçmişteki" + str(index) + ". iş deneyiminin bitiş tarihi",
    )

    // Başlangıç tarihinin bugünün tarihinden önce olduğunu doğrula. [Validate the start date is before the today's date.]
    assert(
      work-experience.start-date < datetime.today(),
      message: "Öz Geçmişteki "
        + str(index)
        + ". iş deneyiminde hata var. 'curriculum-vitae parametresindeki work-experience.start-date' tarihi bugünün tarihinden ileride olamaz.",
    )

    // Bitiş tarihinin bugünün tarihinden önce olduğunu doğrula. [Validate the end date is before the today's date.]
    assert(
      work-experience.end-date < datetime.today(),
      message: "Öz Geçmişteki "
        + str(index)
        + ". iş deneyiminde hata var. 'curriculum-vitae parametresindeki work-experience.end-date' tarihi bugünün tarihinden ileride olamaz.",
    )

    // Başlangıç tarihinin bitiş tarihinden önce olduğunu doğrula. [Validate the start date is before the end date.]
    assert(
      work-experience.start-date < work-experience.end-date,
      message: "Öz Geçmişteki "
        + str(index)
        + ". iş deneyiminde hata var. 'curriculum-vitae parametresindeki work-experience.start-date' tarihi 'curriculum-vitae parametresindeki work-experience.end-date' tarihinden ileride olamaz.",
    )

    // Başlangıç tarihinin doğum tarihinden sonra olduğunu doğrula. [Validate the start date is after the birthday date.]
    assert(
      work-experience.start-date > value.birthday,
      message: "Öz Geçmişteki "
        + str(index)
        + ". iş deneyiminde hata var. 'curriculum-vitae parametresindeki work-experience.start-date' tarihi doğum günü tarihinden geride olamaz.",
    )

    // bitiş tarihinin doğum tarihinden sonra olduğunu doğrula. [Validate the end date is after the birthday date.]
    assert(
      work-experience.end-date > value.birthday,
      message: "Öz Geçmişteki "
        + str(index)
        + ". iş deneyiminde hata var. 'curriculum-vitae parametresindeki work-experience.end-date' tarihi doğum günü tarihinden geride olamaz.",
    )
  }

  // Bilgi Almak İçin Önerebileceğim Şahıslar parametresini doğrula. [Validate the get-info-from-recommended-people parameter.]
  for (index, get-info-from-recommended-people) in value.get-info-from-recommended-peoples.enumerate(start: 1) {
    // Sözlük parametre türünü doğrula. [Validate dictionary parameter type.]
    dictionary-type-validator(
      value: get-info-from-recommended-people,
      value-name: "template-configurations.get-info-from-recommended-people",
      value-description: "Şablon ayarlarındaki " + str(index) + ". bilgi almak için önerebileceğim şahıs",
    )

    // ORCID parametresini doğrula. [Validate the ORCID parameter.]
    if get-info-from-recommended-people.orcid != none {
      orcid-validator(
        value: get-info-from-recommended-people.orcid,
        value-name: "curriculum-vitae parametresindeki get-info-from-recommended-people.orcid",
        value-description: "Öz Geçmişteki " + str(index) + ". bilgi almak için önerebileceğim şahsın ORCID'i",
      )
    }

    // E-Posta parametresini doğrula. [Validate the email parameter.]
    email-validator(
      value: get-info-from-recommended-people.email,
      value-name: "curriculum-vitae parametresindeki get-info-from-recommended-people.email",
      value-description: "Öz Geçmişteki " + str(index) + ". bilgi almak için önerebileceğim şahsın e-posta adresi",
    )
  }
}
