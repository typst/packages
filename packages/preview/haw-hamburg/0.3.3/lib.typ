#let report(
  language: "en",
  title: "",
  author: "",
  faculty: "",
  department: "",
  include-declaration-of-independent-processing: false,
  body,
) = {
  import "template.typ": template
  template(
    is-thesis: false,
    is-master-thesis: false,
    is-bachelor-thesis: false,
    is-report: true,

    language: language,
    
    title-de: title,
    keywords-de: none,
    abstract-de: none,

    title-en: title,
    keywords-en: none,
    abstract-en: none,

    author: author,
    faculty: faculty,
    department: department,
    study-course: none,
    supervisors: (),
    submission-date: none,
    include-declaration-of-independent-processing: include-declaration-of-independent-processing,
    body,
  )
}

#let bachelor-thesis(
  language: "en",

  title-de: "",
  keywords-de: none,
  abstract-de: none,

  title-en: none,
  keywords-en: none,
  abstract-en: none,

  author: "",
  faculty: "",
  department: "",
  study-course: "",
  supervisors: (),
  submission-date: none,
  include-declaration-of-independent-processing: true,
  body,
) = {
  import "template.typ": template
  template(
    is-thesis: true,
    is-master-thesis: false,
    is-bachelor-thesis: true,
    is-report: false,

    language: language,

    title-de: title-de,
    keywords-de: keywords-de,
    abstract-de: abstract-de,

    title-en: title-en,
    keywords-en: keywords-en,
    abstract-en: abstract-en,

    author: author,
    faculty: faculty,
    department: department,
    study-course: study-course,
    supervisors: supervisors,
    submission-date: submission-date,
    include-declaration-of-independent-processing: include-declaration-of-independent-processing,
    body,
  )
}

#let master-thesis(
  language: "en",

  title-de: "",
  keywords-de: none,
  abstract-de: none,

  title-en: none,
  keywords-en: none,
  abstract-en: none,

  author: "",
  faculty: "",
  department: "",
  study-course: "",
  supervisors: (),
  submission-date: none,
  include-declaration-of-independent-processing: true,
  body,
) = {
  import "template.typ": template
  template(
    is-thesis: true,
    is-master-thesis: true,
    is-bachelor-thesis: false,
    is-report: false,

    language: language,

    title-de: title-de,
    keywords-de: keywords-de,
    abstract-de: abstract-de,

    title-en: title-en,
    keywords-en: keywords-en,
    abstract-en: abstract-en,

    author: author,
    faculty: faculty,
    department: department,
    study-course: study-course,
    supervisors: supervisors,
    submission-date: submission-date,
    include-declaration-of-independent-processing: include-declaration-of-independent-processing,
    body,
  )
}