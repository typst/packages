// LTeX: enabled=false
#import "@preview/dhbw-oderso:2.2.0": caption-with-source, dhbw-ma-adapter
#import "glossary.typ": abbreviations, glossary
#import "appendix.typ": appendices

#show: dhbw-ma-adapter.with(
  lang: "en",

  // Wether to display a signature line for the statutory declaration
  digital-submission: true,

  // Set to false if you also submit a printed copy of your thesis. Important for the statutory declaration
  digital-only: true,

  // Set to false if you do not need a confidentiality clause
  confidentiality-clause: true,

  // Long title, displayed on cover slide
  title-long: "Writing in Typst about a long, very scientific topic",

  // Shorter title, displayed in header of each file
  title-short: "Writing in Typst",

  thesis-type: "Projektarbeit 1 (T3_2000)",
  examination: "Bachelor of Science (B.Sc.)",
  study: "Wirtschaftsinformatik Software Engineering",

  authors: (
    (
      firstname: "John",
      lastname: "Doe",
      matriculation-number: "0000000",
      course: "TINF23B2",
      // remove if you do not have a signature image
      signature: image("assets/placeholder-signature.png"),
      email: "john.doe@dhbw.com",
      address: "Example Street 1, 12345 Example City",
      phone-number: "+49 0000 0000",
      // specific attributes for the ai declaration
      ai-dec-product-name: "ChatGPT, DeepL",
      ai-dec-topic: "Writing in Typst about a long, very scientific topic",
      ai-dec-topic-editing: "Structuring, organizing",
      ai-dec-research: "Research using AI",
      ai-dec-design: "Text generation, correction",
    ), // make sure to keep this comma after the first author if there is only one author!
    (
      firstname: "Erika",
      lastname: "Musterfrau",
      matriculation-number: "1234567",
      course: "TINF23B1",
      signature: none,
      email: none,
      address: none,
      phone-number: none,
      ai-dec-product-name: "ChatGPT, DeepL",
      ai-dec-topic: "Writing in Typst about a long, very scientific topic",
      ai-dec-topic-editing: "Structuring, organizing",
      ai-dec-research: "Research using AI",
      ai-dec-design: "Text generation, correction",
    ),
  ),

  signature-city: "Mannheim",

  // Set to specific date with "24.12.2026"
  submission-date: datetime.today().display("[day].[month].[year]"),
  module-submission-date: datetime.today().display("[day].[month].[year]"),

  processing-period-weeks: 12,

  // Remove if your thesis is written without a company
  company-department: "Human Resources",
  company-supervisor: (
    firstname: "Max",
    lastname: "Mustermann",
    email: "max.mustermann@examples.com",
    phone-number: "+49 0000 1111",
  ),
  company-logo: image("assets/placeholder-company-logo.svg"),

  university-supervisor: (
    firstname: "Heinrich",
    lastname: "Braun",
    email: "heinrich.braun@examples.com",
    phone-number: "+49 0000 2222",
  ),

  course-director: "Sebastian Ritterbusch",

  ai-declaration-form-data: (
    module-name: "Projektmanagement",
    semester: "1",
    exam-type: "Projektarbeit I", // "Projektarbeit I", "Projektarbeit II", "Seminararbeit", "Bachelorarbeit"
  ),

  // acknowledgements: usage: (
  //   content: [content] || include("front-matter/acknowledgements.typ")
  // )
  // remove property to remove acknowledgements
  acknowledgements: (
    include "misc/acknowledgments.typ"
  ),

  // abstracs: usage: (language, language (displayed), content)
  abstracts: (
    ("de", "Deutsch", include "misc/abstract-german.typ"),
    ("en", "English", include "misc/abstract-english.typ"),
  ),

  // Appendix can be configured in appendix.typ
  // remove property to remove appendices
  appendices: appendices,

  // Bibliography
  library: bibliography("refs.bib"),

  abbreviations: abbreviations,
  glossary: glossary,
)

// You can now start writing :)

#include "chapters/introduction.typ"
#include "chapters/basic_formatting.typ"
#include "chapters/advanced_elements.typ"
#include "chapters/references_citations.typ"
#include "chapters/reference_management.typ"
#include "chapters/conclusion.typ"
