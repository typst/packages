/*
 * ============================================================
 * TITLE PAGE COMPONENT
 * ============================================================
 *
 * Generates a title page based on the official IU title
 * page example.
 *
 * The layout consists of six sections:
 * 1. University logo
 * 2. Examination and course information
 * 3. University and degree program
 * 4. Document title
 * 5. Author information
 * 6. Supervisor and submission information
 *
 * Fixed spacing is used within each section.
 * Fractional spacing separates the sections.
 *
 * Required fields:
 * - university
 * - document-type
 * - title
 * - author
 *
 * All remaining fields are optional.
 * ============================================================
 */


/*
 * ------------------------------------------------------------
 * TITLE PAGE FUNCTION
 * ------------------------------------------------------------
 *
 * Parameters:
 * - settings: Title page configuration dictionary.
 * - language: Document language ("de" or "en").
 */

#let render-title-page(
  settings,
  language: "de",
) = {

  /*
   * ==========================================================
   * UNIVERSITY INFORMATION
   * ==========================================================
   */

  let university = settings.at("university")
  let faculty = settings.at("faculty", default: none)
  let degree-program = settings.at(
    "degree-program",
    default: none,
  )
  let logo = settings.at("logo", default: none)


  /*
   * ==========================================================
   * DOCUMENT INFORMATION
   * ==========================================================
   */

  let document-type = settings.at("document-type")
  let course = settings.at("course", default: none)
  let course-number = settings.at(
    "course-number",
    default: none,
  )
  let semester = settings.at("semester", default: none)

  let title = settings.at("title")
  let subtitle = settings.at("subtitle", default: none)


  /*
   * ==========================================================
   * AUTHOR INFORMATION
   * ==========================================================
   */

  let author = settings.at("author")
  let student-id = settings.at(
    "student-id",
    default: none,
  )


  /*
   * ==========================================================
   * SUBMISSION INFORMATION
   * ==========================================================
   */

  let supervisor = settings.at(
    "supervisor",
    default: none,
  )

  let location = settings.at("location", default: none)
  let submission-date = settings.at(
    "submission-date",
    default: none,
  )


  /*
   * ==========================================================
   * LOCALIZED LABELS
   * ==========================================================
   */

  let degree-label = if language == "de" {
    "Studiengang"
  } else {
    "Degree Program"
  }

  let student-label = if language == "de" {
    "Matrikelnummer"
  } else {
    "Student ID"
  }

  let supervisor-label = if language == "de" {
    "Betreuende Person/ Tutor:in"
  } else {
    "Supervisor"
  }

  let date-label = if language == "de" {
    "Abgabedatum"
  } else {
    "Submission Date"
  }

  let date-format = if language == "de" {
    "[day padding:none].[month padding:none].[year]"
  } else {
    "[month repr:long] [day padding:none], [year]"
  }


  /*
   * ==========================================================
   * SECTION 1: UNIVERSITY LOGO
   * ==========================================================
   *
   * The logo is displayed independently at the top
   * of the title page.
   */

  let logo-section = [
    #if logo != none [
      #logo
    ]
  ]


  /*
   * ==========================================================
   * SECTION 2: EXAMINATION INFORMATION
   * ==========================================================
   *
   * Displays:
   * - Examination type
   * - Course name
   * - Optional course number
   * - Optional semester
   *
   * The examination type uses regular font weight.
   */

  let examination-section = [

    // Examination type
    #text(size: 11pt)[
      #document-type
    ]

    // Optional course name
    #if course != none [
      #v(0.35cm)
      #text(size: 11pt)[#course]
    ]

    // Optional course number without a label
    #if course-number != none [
      #v(0.25cm)
      #text(size: 11pt)[#course-number]
    ]

    // Optional semester
    #if semester != none [
      #v(0.25cm)
      #text(size: 11pt)[#semester]
    ]

  ]


  /*
   * ==========================================================
   * SECTION 3: UNIVERSITY INFORMATION
   * ==========================================================
   *
   * Displays the university name and degree program.
   *
   * All information uses regular font weight.
   */

  let university-section = [

    // Full university name
    #text(size: 11pt)[
      #university
    ]

    // Optional faculty
    #if faculty != none [
      #v(0.3cm)
      #text(size: 11pt)[#faculty]
    ]

    // Optional degree program
    #if degree-program != none [
      #v(0.35cm)

      #text(size: 11pt)[
        #degree-program
      ]
    ]

  ]


  /*
   * ==========================================================
   * SECTION 4: DOCUMENT TITLE
   * ==========================================================
   *
   * The title is the primary typographic element
   * of the title page.
   *
   * Automatic hyphenation is disabled.
   */

  let title-section = [

    // Document title
    #block(
      width: 100%,
      above: 0pt,
      below: 0pt,
    )[
      #text(
        size: 14pt,
        weight: "bold",
        hyphenate: false,
      )[
        #title
      ]
    ]

    // Optional subtitle
    #if subtitle != none [
      #v(0.35cm)

      #text(size: 11pt)[
        #subtitle
      ]
    ]

  ]


  /*
   * ==========================================================
   * SECTION 5: AUTHOR INFORMATION
   * ==========================================================
   *
   * Displays the author's name and student ID.
   */

  let author-section = [

    // Author name
    #text(size: 11pt)[#author]

    // Optional student ID
    #if student-id != none [
      #v(0.3cm)

      #text(size: 11pt)[
        #(student-label): #student-id
      ]
    ]

  ]


  /*
   * ==========================================================
   * SECTION 6: SUBMISSION INFORMATION
   * ==========================================================
   *
   * Displays:
   * - Supervisor
   * - Optional location
   * - Submission date
   */

  let submission-section = [

    // Optional supervisor
    #if supervisor != none [
      #text(size: 11pt)[
        #(supervisor-label): #supervisor
      ]
    ]

    // Optional submission location
    #if location != none [
      #if supervisor != none [
        #v(0.35cm)
      ]

      #text(size: 11pt)[#location]
    ]

    // Optional submission date
    #if submission-date != none [
      #if supervisor != none or location != none [
        #v(0.45cm)
      ]

      #text(size: 11pt)[
        #(date-label):
        #(submission-date.display(date-format))
      ]
    ]

  ]


  /*
   * ==========================================================
   * TITLE PAGE LAYOUT
   * ==========================================================
   *
   * Arranges all six sections vertically.
   *
   * Fractional spacing distributes the remaining space
   * between the sections according to their weights.
   *
   * Larger weights create more space between groups.
   *
   * The layout adapts to different title lengths and
   * optional metadata.
   */

  [

    // Hide the page number on the title page.
    #set page(numbering: none)

    // Use centered, non-justified text.
    #set par(
      justify: false,
      first-line-indent: 0pt,
      spacing: 0pt,
    )

    #align(center)[

      // Initial top spacing
      #v(0.5fr)

      // 1. University logo
      #logo-section

      // Logo to examination information
      #v(1.3fr)

      // 2. Examination information
      #examination-section

      // Examination to university information
      #v(1fr)

      // 3. University information
      #university-section

      // University information to document title
      #v(0.9fr)

      // 4. Document title
      #title-section

      // Document title to author information
      #v(1fr)

      // 5. Author information
      #author-section

      // Author to submission information
      #v(1.1fr)

      // 6. Submission information
      #submission-section

      // Remaining bottom spacing
      #v(0.8fr)

    ]

    // Continue the document on the next page.
    #pagebreak()

  ]
}