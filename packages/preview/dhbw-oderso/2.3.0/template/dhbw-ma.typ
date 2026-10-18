// LTeX: enabled=false

#import "@preview/linguify:0.5.0": linguify, linguify-raw
#import "base.typ": __signature-line, project
#import "assets/ai-declaration-form_dhbw-ma.typ": ai-declaration-form
#import "utils.typ": __linguify-content

/// Template adapter for DHBW Mannheim thesis documents.
///
/// This function configures the base `project` template with DHBW Mannheim-specific
/// settings, including statutory declarations, confidentiality clauses,
/// and the official AI declaration form.
///
/// In addition to the parameters listed below, this adapter accepts all parameters
/// from the base `project` template (e.g., `title-long`, `title-short`, `thesis-type`,
/// `abstracts`, `appendices`, `library`, `abbreviations`, `lang`).
/// -> content
#let dhbw-ma-adapter(
  /// Whether the thesis is submitted digitally. Affects the signature line
  /// display in the statutory declaration. -> bool
  digital-submission: true,
  /// Whether the thesis is submitted digitally only (no printed copy).
  /// Affects the wording of the statutory declaration. -> bool
  digital-only: true,
  /// Whether to include a confidentiality clause page. -> bool
  confidentiality-clause: true,
  /// The examination degree, e.g., "Bachelor of Science (B.Sc.)". -> str
  examination: "Bachelor of Science (B.Sc.)",
  /// The field of study, e.g., "Computer Science". -> str
  study: "Computer Science",
  /// List of author dictionaries. Each author should have: `firstname`,
  /// `lastname`, `matriculation-number`, `course`, `signature` (optional),
  /// `email`, `address`, and `phone-number`. -> array
  authors: (
    (
      firstname: none,
      lastname: none,
      matriculation-number: none,
      course: none,
      signature: none,
      email: none,
      address: none,
      phone-number: none,
      ai-dec-product-name: none,
      ai-dec-topic: none,
      ai-dec-topic-editing: none,
      ai-dec-research: none,
      ai-dec-design: none,
    ),
  ),
  /// City shown on the signature line. -> str
  signature-city: "Mannheim",
  /// Submission date of the thesis. -> str
  submission-date: datetime.today().display("[day].[month].[year]"),
  /// Submission date for the module (used in AI declaration form). -> str
  module-submission-date: datetime.today().display("[day].[month].[year]"),
  /// Format string for displaying dates. (see #link("https://typst.app/docs/reference/foundations/datetime/#format")[datetime formats]) -> str
  submission-date-format: "[day].[month].[year]",
  /// Duration of the thesis processing period in weeks. -> int | none
  processing-period-weeks: none,
  /// University supervisor dictionary with `firstname`, `lastname`,
  /// `email`, and `phone-number`. -> dictionary
  university-supervisor: (
    firstname: none,
    lastname: none,
    email: none,
    phone-number: none,
  ),
  /// Name of the training company. -> str | none
  company-name: "Corp SE",
  /// City where the company is located. -> str | none
  company-city: "Berlin",
  /// Company logo image. -> content | none
  company-logo: none,
  /// Department within the company. -> str | none
  company-department: none,
  /// Company supervisor dictionary with `firstname`, `lastname`,
  /// `email`, and `phone-number`. -> dictionary
  company-supervisor: (
    firstname: none,
    lastname: none,
    email: none,
    phone-number: none,
  ),
  /// Name of the course director. -> str | none
  course-director: none,
  /// AI declaration form data dictionary. Contains: `module-name`, `exam-type`
  /// ("Projektarbeit I", "Projektarbeit II", "Seminararbeit", "Bachelorarbeit"),
  /// `product-name`, `topic`, `topic-editing`, `research`, `design`, and
  /// `position` ("preamble", "postamble", or "after-confidentiality-clause"). -> dictionary
  ai-declaration-form-data: (
    module-name: none,
    semester: none,
    exam-type: none,
    product-name: none,
    topic: none,
    topic-editing: none,
    research: none,
    design: none,
  ),
  /// Additional arguments passed to the base template.
  ..args,
  /// The main document body content. -> content
  body,
) = {
  let submission-info = [
    #__linguify-content("as-part-of-examination-dhbw")

    *#examination*

    #__linguify-content("in-field-of-study", args: (study: study))

    #context __linguify-content("at-the-institution", args: (
      institution: linguify-raw("dhbw-long"),
      city: linguify-raw("ma"),
    ))
  ]

  // TODO: only for compatibility reasons: Remove with v3.0.0 release
  if type(submission-date) == datetime {
    submission-date = submission-date.display(submission-date-format)
  }
  // TODO: only for compatibility reasons: Remove with v3.0.0 release
  if type(module-submission-date) == datetime {
    module-submission-date = module-submission-date.display(
      submission-date-format,
    )
  }

  let company-supervisor-data = [
    #company-supervisor.firstname #company-supervisor.lastname#if (
      company-supervisor.phone-number != none
    ) {
      ", " + company-supervisor.phone-number
    }
    #if (company-supervisor.email != none) {
      linebreak()
      company-supervisor.email
    }
  ]

  let university-supervisor-data = [
    #university-supervisor.firstname #university-supervisor.lastname#if (
      university-supervisor.phone-number != none
    ) {
      ", " + university-supervisor.phone-number
    }
    #if (university-supervisor.email != none) {
      linebreak()
      university-supervisor.email
    }
  ]

  let metadata = (
    __linguify-content("submission-date"),
    submission-date,
    __linguify-content("processing-duration"),
    __linguify-content("weeks", args: (count: processing-period-weeks)),
    __linguify-content("matriculation-number")
      + ", "
      + __linguify-content("course"),
    authors
      .map(a => a.matriculation-number + ", " + a.course)
      .join(linebreak()),
    ..if company-name != none and company-city != none {
      (
        __linguify-content("training-company"),
        company-name + linebreak() + company-city,
      )
    },
    ..if company-department != none {
      (__linguify-content("department"), company-department)
    },
    ..if company-supervisor.firstname != none
      or company-supervisor.lastname != none {
      (
        __linguify-content("supervisor-at-training-company"),
        company-supervisor-data,
      )
    },
    ..if course-director != none {
      (__linguify-content("course-director"), course-director)
    },
    __linguify-content("supervisor-at-university"),
    university-supervisor-data,
  )
  let statutory-declaration = {
    pagebreak(weak: true)
    // Get course year of first author
    if authors == none or type(authors) != array or authors.len() == 0 {
      panic("At least one author has to be specified!")
    }

    let course-year = int(authors.at(0).course.find(regex("\d+")))

    // TODO: The statutory declaration changed for courses starting in 2024. This complicated edge case for courses from 2023
    // and earlier can safely be removed by September 2026
    let statuatory-declaration = if course-year < 24 {
      __linguify-content("statutory-declaration-note-dhbw-old", args: (
        author-count: authors.len(),
        title: args.at("title-long"),
        type: args.at("thesis-type"),
      ))
    } else {
      __linguify-content("statutory-declaration-note-dhbw", args: (
        author-count: authors.len(),
      ))
    }

    let statuatory-declaration-printed = if course-year < 24 {
      __linguify-content("statutory-declaration-note-dhbw-old-printed", args: (
        author-count: authors.len(),
      ))
    } else {
      __linguify-content("statutory-declaration-note-dhbw-printed", args: (
        author-count: authors.len(),
      ))
    }

    align(center, heading(
      __linguify-content("statutory-declaration"),
      level: 1,
    ))

    statuatory-declaration
    if not digital-only {
      (
        " " + statuatory-declaration-printed
      )
    }

    set grid.cell(align: left, inset: (x: 1em, y: 0.3em))

    for a in authors {
      __signature-line(
        author: a,
        date: submission-date,
        digital: digital-submission,
        city: signature-city,
      )
    }
  }

  let confidentiality-clause-text = {
    pagebreak(weak: true)
    [#[] <__confidentiality-clause>]
    align(center, heading(
      __linguify-content("confidentiality-agreement"),
      level: 1,
    ))

    __linguify-content("confidentiality-agreement-note-dhbw")
  }

  let ai-declarations = ()
  for a in authors {
    let ai-declaration = ai-declaration-form(
      digital: digital-only,
      name: a.lastname + ", " + a.firstname,
      identification-number: a.matriculation-number,
      address: a.address,
      course: a.course,
      email: a.email,
      mobile-number: a.phone-number,
      module-name: ai-declaration-form-data.module-name,
      semester: ai-declaration-form-data.semester,
      module-submission-date: module-submission-date,
      exam-type: ai-declaration-form-data.exam-type,
      product-name: a.ai-dec-product-name,
      topic: a.ai-dec-topic,
      topic-editing: a.ai-dec-topic-editing,
      research: a.ai-dec-research,
      design: a.ai-dec-design,
      signature-city: signature-city,
      signature-date: submission-date,
      signature-image: a.signature,
    )
    ai-declarations.push(ai-declaration)
  }
  show: project.with(
    __logo-left: company-logo,
    __logo-right: image("assets/DHBW-Logo.svg"),
    __authors: authors,
    __submission-info: submission-info,
    __metadata: metadata,
    __confidentiality-clause: confidentiality-clause,
    __postamble: (
      statutory-declaration,
      ..if (confidentiality-clause) { (confidentiality-clause-text,) },
      ..ai-declarations,
    ),
    ..args,
  )
  body
}
