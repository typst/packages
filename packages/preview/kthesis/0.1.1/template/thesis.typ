#import "@preview/kthesis:0.1.1": kth-thesis, setup-appendices

// The template is extensible and plays well with other dependencies;
// For example, a table of acronyms can be generated using glossarium
#import "@preview/glossarium:0.5.4": make-glossary, register-glossary, print-glossary
#import "./acronyms.typ": acronyms
#show: make-glossary
#register-glossary(acronyms)

// Configure formatting options before invoking the template;
// For example, uncomment below to set another font (except for covers)
// #set text(font: "New Computer Modern")

// --------------------------------------------------------------------- //
// ---------- MAIN THESIS TEMPLATE ENTRYPOINT & CONFIGURATION ---------- //
// --------------------------------------------------------------------- //
#show: kth-thesis.with(
  // Primary document language; either "en" or "sv"
  primary-lang: "en",
  // Language-specific title, subtitle, abstract, and keywords.
  // Grouped by language, with only values for "en" and "sv" being mandatory.
  // Localized abstract/keywords headings may be omitted only for "en" and "sv".
  // Field "alpha-3" is the language's ISO 639-3 code, for non-"en"/"sv" langs.
  localized-info: (
    en: (
      title: "How to Abandon Dinosaur-Age TypeSetting Software",
      subtitle: "A Modern Approach to Problem-Solving",
      abstract: include "./content/abstract-1-en.typ",
      keywords: ("Dogs", "Chicken nuggets"),
    ),
    sv: (
      title: "Svenska Översättningen av Titeln",
      subtitle: "Svenska Översättningen av Undertiteln",
      abstract: include "./content/abstract-2-sv.typ",
      keywords: ("Hundar", "Kycklingnuggets"),
    ),
    pt: (
      alpha-3: "por",
      title: "Tradução em Português do Título",
      subtitle: "Tradução em Português do Subtítulo",
      abstract-heading: "Resumo",
      keywords-heading: "Palavras-chave",
      abstract: include "./content/abstract-3-pt.typ",
      keywords: ("Cães", "Nuggets de frango"),
    ),
  ),
  // Ordered author information; only first and last names fields are mandatory
  authors: (
    (
      first-name: "John",
      last-names: "Doe",
      email: "john.doe@example.com",
      user-id: "jod",
      school: "School of Electrical Engineering and Computer Science",
      department: "Department of Typesetting Sanity",
    ),
    (
      first-name: "Jane",
      last-names: "Doe",
    ),
  ),
  // Ordered supervisor information; "external-org" replaces userid/school/dept
  supervisors: (
    (
      first-name: "Alice",
      last-names: "Smith",
      email: "alice@example.com",
      user-id: "alice",
      school: "School of Electrical Engineering and Computer Science",
      department: "Department of Loyal Supervision",
    ),
    (
      first-name: "Bob",
      last-names: "Jones",
      email: "bob@example.com",
      external-org: "Företag AB",
    ),
  ),
  // Thesis examiner; must be internal to the school so all fields are mandatory
  examiner: (
    first-name: "Charlie",
    last-names: "Johnson",
    email: "charlie@example.com",
    user-id: "chj",
    school: "School of Electrical Engineering and Computer Science",
    department: "Department of Fair Examination",
  ),
  // Degree project course within which the thesis is being conducted.
  // All fields are mandatory; credits are the course's ECTS credits (hp).
  course: (
    code: "DA237X",
    credits: 30,
  ),
  // Degree as part of which the thesis is conducted; all fields are mandatory.
  // Subject area is main field of study as listed in the second dropdown here:
  // https://www.kth.se/en/student/studier/examen/examensregler-1.5685
  // Kind is the degree title conferred as listed in the third dropdown above.
  // Cycle is either 1 (Bachelor's) or 2 (Master's), per Bologna.
  degree: (
    code: "TCYSM",
    name: "Master's Program, Cybersecurity",
    subject-area: "Computer Science and Engineering",
    kind: "Master of Science",
    cycle: 2,
  ),
  // National subject category codes; mandatory for DiVA classification.
  // One or more 3-to-5 digit codes, with preference for 5-digit codes, from:
  // https://www.scb.se/contentassets/10054f2ef27c437884e8cde0d38b9cc4/standard-for-svensk-indelning--av-forskningsamnen-2011-uppdaterad-aug-2016.pdf
  national-subject-categories: ("10201", "10206"),
  // School that the thesis is part of (abbreviation)
  school: "EECS",
  // TRITA number assigned to thesis after final examiner approval
  trita-number: "2024:0000",
  // Host company collaborating for this thesis; may be none
  host-company: "Företag AB",
  // Host organization collaborating for this thesis; may be none
  host-org: none,
  // Names of opponents for this thesis; may be none until they're assigned
  opponents: ("Mary Ignatia", "Alexander Smith"),
  // Thesis presentation details; may be none until it's scheduled and set.
  // Either "online" or "location" fields may be none, but not both.
  presentation: (
    language: "en",
    slot: datetime(
      year: 2025,
      month: 6,
      day: 14,
      hour: 13,
      minute: 0,
      second: 0,
    ),
    online: (service: "Zoom", link: "https://kth-se.zoom.us/j/111222333"),
    location: (
      room: "F1 (Alfvénsalen)",
      address: "Lindstedtsvägen 22",
      city: "Stockholm",
    ),
  ),
  // Acknowledgements body
  acknowledgements: include "content/acknowledgements.typ",
  // Additional front-matter sections, each with keys "heading" and "body"
  extra-preambles: (
    (heading: "Acronyms and Abbreviations", body: print-glossary(acronyms)),
  ),
  // Document date; hardcode for determinism/reproducibility
  doc-date: datetime.today(),
  // Document city (where it's being signed/authored/submitted)
  doc-city: "Stockholm",
  // Extra keywords, embedded in document metadata but not listed in text
  doc-extra-keywords: ("master thesis",),
  // Whether to include trailing "For DiVA" metadata structure section
  with-for-diva: true,
)

// Tip: when tagging elements, scope labels like <intro:goals:example>

#include "./content/ch01-introduction.typ"
#include "./content/ch02-background.typ"
#include "./content/ch03-method.typ"
#include "./content/ch04-the-thing.typ"
#include "./content/ch05-results.typ"
#include "./content/ch06-discussion.typ"
#include "./content/ch07-conclusion.typ"

#bibliography("references.yaml", title: "References")

#show: setup-appendices
#include "./content/zz-a-usage.typ"
#include "./content/zz-b-else.typ"
