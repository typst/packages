#import "/src/constants/date-constants.typ": FULL-DATE-FORMAT, MONTH-YEAR-DATE-FORMAT
#import "/src/constants/language-free-string-constants.typ": STRING-ORCID
#import "/src/styles/curriculum-vitae-page-style.typ": curriculum-vitae-page-style
#import "/src/core/language-manager/language-manager.typ": translator
#import "/src/constants/language-keys.typ": language-keys
#import "/src/components/fullname-with-title-component.typ": fullname-with-title-component
#import "/src/components/orcid-link-component.typ": orcid-link-component
#import "/src/components/email-link-component.typ": email-link-component
#import "/src/components/orcid-with-prefix-component.typ": orcid-with-prefix-component

// Öz Geçmiş sayfası. [Curriculum Vitae page.]
#let curriculum-vitae-page(
  first-name: none,
  last-name: none,
  orcid: none,
  birthplace: none,
  birthday: none,
  address: none,
  marital-status: none,
  phone-number: none,
  email: none,
  high-school: (
    name: none,
    program: none,
    place: none,
    start-year: none,
  ),
  undergraduate: (
    name: none,
    program: none,
    place: none,
    start-year: none,
  ),
  masters-degree: (
    name: none,
    program: none,
    place: none,
    start-year: none,
  ),
  skills: none,
  work-experiences: (
    (
      start-date: none,
      end-date: none,
      title: none,
      organization-name: none,
      place: none,
    ),
    (
      start-date: none,
      end-date: none,
      title: none,
      organization-name: none,
      place: none,
    ),
  ),
  get-info-from-recommended-peoples: (
    (
      name-with-title: none,
      orcid: none,
      email: none,
    ),
    (
      name-with-title: none,
      orcid: none,
      email: none,
    ),
  ),
) = {
  // İş deneyimlerini geçmişten günümüze doğru sırala. [Sort your work experiences from past to present.]
  let sorted-work-experiences = work-experiences.sorted(
    key: work-experience => (work-experience.start-date, work-experience.end-date),
  )

  // Sayfa stilini uygula. [Apply page style.]
  show: curriculum-vitae-page-style

  // Başlığı ekle. [Add heading.]
  heading(level: 1, translator(key: language-keys.CURRICULUM-VITAE))

  // Bir miktar boşluk bırak. [Leave a little space.]
  v(1em)

  // Genel Bilgiler tablosu. [General Information table.]
  table(
    columns: (auto, 2fr, auto, 1fr),
    table.cell(colspan: 4, align(center)[*#translator(key: language-keys.GENERAL-INFO)*]),
    [*#translator(key: language-keys.FIRST-NAME-LAST-NAME):*], [#first-name #upper(last-name)], [*#translator(key: language-keys.SIGNATURE):*], [],
    [*#translator(key: language-keys.PHONE-NUMBER):*], [#phone-number], [*#translator(key: language-keys.BIRTHDAY):*], [#birthday.display(FULL-DATE-FORMAT)], [*#translator(key: language-keys.EMAIL):*], [#email-link-component(
        email: email,
      )],
    [*#translator(key: language-keys.BIRTHPLACE):*], [#birthplace],
    [*#STRING-ORCID:*], [#orcid-link-component(
        orcid: orcid,
      )], [*#translator(key: language-keys.MARITAL-STATUS):*], [#marital-status],
    [*#translator(key: language-keys.ADRESS):*], table.cell(colspan: 3)[#address],
  )

  // Eğitim Bilgiler tablosu. [Educational Backgorund table.]
  table(
    columns: (auto, 4fr, 3fr, 2fr, 1fr),
    table.cell(colspan: 5, align(center)[*#translator(key: language-keys.EDUCATIONAL-BACKGROUND)*]),
    align(center)[*#translator(key: language-keys.SCHOOL-TYPE)*], align(center)[*#translator(key: language-keys.SCHOOL-NAME)*], align(center)[*#translator(key: language-keys.PROGRAM)*], align(center)[*#translator(key: language-keys.PLACE)*], align(center)[*#translator(key: language-keys.YEAR)*],
    [*#translator(key: language-keys.HIGH-SCHOOL):*], [#high-school.name], [#high-school.program], [#high-school.place], align(center)[#high-school.start-year],
    [*#translator(key: language-keys.UNDERGRADUATE):*], [#undergraduate.name], [#undergraduate.program], [#undergraduate.place], align(center)[#undergraduate.start-year],
    [*#translator(key: language-keys.MASTERS-DEGREE):*], [#masters-degree.name], [#masters-degree.program], [#masters-degree.place], align(center)[#masters-degree.start-year],
  )

  // Çalışma Hayatı tablosu. [Work Experiences table.]
  table(
    columns: (auto, 1fr),
    table.cell(colspan: 2, align(center)[*#translator(key: language-keys.WORK-BACKGROUND)*]),
    [*#translator(key: language-keys.SKILLS):*], [#skills.join("; ")],
    [*#translator(key: language-keys.WORK-EXPERIENCES):*], [#(
        sorted-work-experiences
          .map(it => (
            align(
              center,
              "("
                + it.start-date.display(MONTH-YEAR-DATE-FORMAT)
                + " - "
                + it.end-date.display(MONTH-YEAR-DATE-FORMAT)
                + ") "
                + "("
                + it.title
                + ")",
            )
              + align(
                center,
                it.organization-name + " (" + it.place + ") ",
              )
          ))
          .join(line())
      )],
    [*#translator(key: language-keys.GET-INFO-FROM-RECOMMENDED-PEOPLES):*], [#(
        get-info-from-recommended-peoples
          .map(it => (
            fullname-with-title-component(
              title: it.title,
              first-name: it.first-name,
              last-name: it.last-name,
            )
              + if it.orcid != none { " (" + orcid-with-prefix-component(orcid: it.orcid) + ")" }
              + "\n"
              + translator(key: language-keys.EMAIL)
              + ": "
              + email-link-component(email: it.email)
          ))
          .join(line())
      )],
  )

  // Mevcut sayfa zaten boşsa sayfa sonu pasif olsun (weak: true). [Disable page break if the current page is already empty (weak: true).]
  pagebreak(weak: true)
}
