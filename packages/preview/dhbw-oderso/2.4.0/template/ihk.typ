// LTeX: enabled=false

#import "base.typ": __signature-line, project
#import "@preview/linguify:0.5.0": linguify
#import "utils.typ": __linguify-content

/// Template adapter for IHK thesis documents.
///
/// This function configures the base `project` template for vocational training documentations.
///
/// In addition to the parameters listed below, this adapter accepts all parameters
/// from the base `project` template (e.g., `title-long`, `title-short`, `thesis-type`,
/// `abstracts`, `appendices`, `library`, `abbreviations`, `lang`).
/// -> content
#let ihk-adapter(
  /// Whether the thesis is submitted digitally. Affects the signature line
  /// display in the statutory declaration. -> bool
  digital-submission: true,
  /// Whether to include a confidentiality clause page. -> bool
  confidentiality-clause: true,
  /// The examination type (e.g., "Abschlussprüfung Teil 2"). -> str | none
  examination: none,
  /// The training occupation (Ausbildungsberuf),
  /// e.g., "Fachinformatiker für Anwendungsentwicklung". -> str
  training-occupation: "Fachinformatiker für Anwendungsentwicklung",
  /// List of author dictionaries. Each author should have: `firstname`,
  /// `lastname`, `examinee-number`, and optionally `signature`. -> array
  authors: (
    (
      firstname: none,
      lastname: none,
      examinee-number: none,
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
  /// Name of the training company. -> str
  company-name: "Corp SE",
  /// City where the company is located. -> str
  company-city: "Berlin",
  /// Company logo image. -> content | none
  company-logo: none,
  /// Department within the company. -> str | none
  company-department: none,
  /// Name of the company supervisor. -> str | none
  company-supervisor: none,
  /// Additional arguments passed to the base template.
  ..args,
  /// The main document body content. -> content
  body,
) = {
  let submission-info = [
    #__linguify-content("as-part-of-examination-ihk")

    *#examination*

    #__linguify-content("in-the-training-occupation")\
    #training-occupation
  ]

  // TODO: only for compatibility reasons: Remove with v3.0.0 release
  if type(submission-date) == datetime {
    submission-date = submission-date.display(submission-date-format)
  }

  let metadata = (
    __linguify-content("submission-date"),
    submission-date,
    __linguify-content("processing-duration"),
    __linguify-content("weeks", args: (count: processing-period-weeks)),
    __linguify-content("examinee-number"),
    authors.map(a => a.examinee-number).join(linebreak()),
    __linguify-content("training-company"),
    company-name + linebreak() + company-city,
    __linguify-content("department"),
    company-department,
    __linguify-content("supervisor-at-training-company"),
    company-supervisor,
  )
  let statutory-declaration = {
    pagebreak(weak: true)
    align(center, heading(
      __linguify-content("statutory-declaration"),
      level: 1,
    ))

    // Using the statutory declaration of the dhbw, as there is no template for the IHK
    __linguify-content("statutory-declaration-note-dhbw", args: (
      author-count: authors.len(),
    ))

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

    __linguify-content("confidentiality-agreement-note-ihk")
  }

  show: project.with(
    __logo-left: company-logo,
    __logo-right: image("assets/IHK-Logo.svg"),
    __authors: authors,
    __submission-info: submission-info,
    __metadata: metadata,
    __confidentiality-clause: confidentiality-clause,
    __postamble: (
      statutory-declaration,
      ..if (confidentiality-clause) { (confidentiality-clause-text,) },
    ),
    ..args,
  )
  body
}
