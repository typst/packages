// LTeX: enabled=false

#import "@preview/linguify:0.5.0": linguify, linguify-raw
#import "base.typ": __signature-line, project
#import "utils.typ": __linguify-content, styled-table

/// Template adapter for DHBW Karlsruhe thesis documents.
///
/// This function configures the base `project` template with DHBW Karlsruhe-specific
/// settings, including statutory declarations, confidentiality clauses,
/// and AI tool acknowledgements according to DHBW guidelines.
///
/// In addition to the parameters listed below, this adapter accepts all parameters
/// from the base `project` template (e.g., `title-long`, `title-short`, `thesis-type`,
/// `abstracts`, `appendices`, `library`, `abbreviations`, `lang`).
/// -> content
#let dhbw-ka-adapter(
  /// Whether the thesis is submitted digitally. Affects the signature line
  /// display in the statutory declaration. -> bool
  digital-submission: true,
  /// Whether the thesis is submitted digitally only (no printed copy).
  /// Affects the wording of the statutory declaration. -> bool
  digital-only: true,
  /// Whether to include a confidentiality clause page. -> bool
  confidentiality-clause: true,
  /// List of AI tools used in the thesis, according to section 4.6 of
  /// #link("https://www.karlsruhe.dhbw.de/fileadmin/user_upload/documents/content-de/Studiengaenge-Technik/Informatik/191212_Leitlinien_Praxismodule_Studien_Bachelorarbeiten.pdf")[Leitlinien für Wissenschaftliche Arbeiten]. Each entry should have
  /// `tool` (name) and `usage` (description of how it was used). -> array
  ai-acknowledgement: (
    (
      tool: none,
      usage: none,
    ),
  ),
  /// The examination degree, e.g., "Bachelor of Science (B.Sc.)". -> str
  examination: "Bachelor of Science (B.Sc.)",
  /// The field of study, e.g., "Computer Science". -> str
  study: "Computer Science",
  /// List of author dictionaries. Each author should have: `firstname`,
  /// `lastname`, `matriculation-number`, `course`, and optionally `signature`
  /// (an image or text for digital signatures). -> array
  authors: (
    (
      firstname: none,
      lastname: none,
      matriculation-number: none,
      course: none,
      signature: none,
    ),
  ),
  /// City shown on the signature line. -> str
  signature-city: "Karlsruhe",
  /// Submission date of the thesis. -> str
  submission-date: datetime.today().display("[day].[month].[year]"),
  /// Format string for displaying the submission date. (see #link("https://typst.app/docs/reference/foundations/datetime/#format")[datetime formats]) -> str
  submission-date-format: "[day].[month].[year]",
  /// Duration of the thesis processing period in weeks. -> int | none
  processing-period-weeks: none,
  /// Name of the university supervisor. -> str | none
  university-supervisor: none,
  /// Name of the training company. -> str | none
  company-name: "Corp SE",
  /// City where the company is located. -> str | none
  company-city: "Berlin",
  /// Company logo image. -> content | none
  company-logo: none,
  /// Department within the company. -> str | none
  company-department: none,
  /// Name of the company supervisor. -> str | none
  company-supervisor: none,
  /// Additional arguments passed to the base template (e.g., `title-long`,
  /// `title-short`, `thesis-type`, `abstracts`, `appendices`, `library`,
  /// `abbreviations`, `lang`).
  ..args,
  /// The main document body content. -> content
  body,
) = {
  // Submission Information
  let submission-info = [
    #__linguify-content("as-part-of-examination-dhbw")

    *#examination*

    #__linguify-content("in-field-of-study", args: (study: study))

    #context __linguify-content("at-the-institution", args: (
      institution: linguify-raw("dhbw-long"),
      city: linguify-raw("ka"),
    ))
  ]

  // TODO: only for compatibility reasons: Remove with v3.0.0 release
  if type(submission-date) == datetime {
    submission-date = submission-date.display(submission-date-format)
  }

  // Metadata
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
    ..if company-supervisor != none {
      (__linguify-content("supervisor-at-training-company"), company-supervisor)
    },
    __linguify-content("supervisor-at-university"),
    university-supervisor,
  )

  // AI-Declaration
  let ai-acknowledgement = ai-acknowledgement.filter(ack => (
    ack.tool != none and ack.usage != none
  ))
  let ai-acknowledgement-text = {
    pagebreak(weak: true)
    align(center, heading(
      __linguify-content("ai-acknowledgement-heading-dhbw"),
      level: 1,
    ))

    let table-cells = ai-acknowledgement.fold((), (acc, (tool, usage)) => (
      acc + (tool, usage)
    ))

    align(center, styled-table(
      columns: (auto, 1fr),
      table-content: (
        table.header(
          __linguify-content("tool"),
          __linguify-content("usage-description"),
        ),
        ..table-cells,
      ),
    ))
  }

  // Statutory Declaration
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

    // TODO: Just like above, this check for course-year >= 24 can be removed after September 2026 as all courses will use that statutory declaration.
    if course-year >= 24 and ai-acknowledgement.len() > 0 {
      linebreak()
      __linguify-content("statutory-declaration-note-dhbw-ai")
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

  // Confidentiality Clause
  let confidentiality-clause-text = {
    pagebreak()
    [#[] <__confidentiality-clause>]
    align(center, heading(
      __linguify-content("confidentiality-agreement"),
      level: 1,
    ))

    __linguify-content("confidentiality-agreement-note-dhbw")
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
      ..if (ai-acknowledgement.len() > 0) {
        (ai-acknowledgement-text,)
      },
    ),
    ..args,
  )
  body
}
