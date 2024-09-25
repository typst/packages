#let report(
  language: "en",
  title: "",
  author: "",
  faculty: "",
  department: "",
  include-declaration-of-independent-processing: false,
  body,
) = {
  import "src/template.typ": template
  template(
    is-thesis: false,
    is-master-thesis: false,
    is-bachelor-thesis: false,
    is-report: true,

    language: language,
    
    title_de: title,
    keywords_de: none,
    abstract_de: none,

    title_en: title,
    keywords_en: none,
    abstract_en: none,

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

  title_de: "",
  keywords_de: none,
  abstract_de: none,

  title_en: none,
  keywords_en: none,
  abstract_en: none,

  author: "",
  faculty: "",
  department: "",
  study-course: "",
  supervisors: (),
  submission-date: none,
  include-declaration-of-independent-processing: true,
  body,
) = {
  import "src/template.typ": template
  template(
    is-thesis: true,
    is-master-thesis: false,
    is-bachelor-thesis: true,
    is-report: false,

    language: language,

    title_de: title_de,
    keywords_de: keywords_de,
    abstract_de: abstract_de,

    title_en: title_en,
    keywords_en: keywords_en,
    abstract_en: abstract_en,

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

  title_de: "",
  keywords_de: none,
  abstract_de: none,

  title_en: none,
  keywords_en: none,
  abstract_en: none,

  author: "",
  faculty: "",
  department: "",
  study-course: "",
  supervisors: (),
  submission-date: none,
  include-declaration-of-independent-processing: true,
  body,
) = {
  import "src/template.typ": template
  template(
    is-thesis: true,
    is-master-thesis: true,
    is-bachelor-thesis: false,
    is-report: false,

    language: language,

    title_de: title_de,
    keywords_de: keywords_de,
    abstract_de: abstract_de,

    title_en: title_en,
    keywords_en: keywords_en,
    abstract_en: abstract_en,

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