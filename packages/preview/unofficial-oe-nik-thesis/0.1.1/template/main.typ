#import "@preview/unofficial-oe-nik-thesis:0.1.1": ai-tool, thesis-template

#show: thesis-template.with(
  // "en" or "hu", the language of the cover page, the generated titles, the captions and the references
  lang: "en",
  // BSc, BProf or SZT for a thesis, MSc for a thesis work, they have slightly different requirements
  degree: "BSc",
  // the year of submission
  year: 2026,
  title: "A Typst template for ÓE NIK theses",
  author: "Jakab Gipsz",
  // not the Neptun code, see Neptun: Studies -> Registry record -> Training data -> "Regirty number (Neptun's typo)"
  registration-number: "T/0012345/FI12904/N",
  // the signed forms are red placeholders until they are inserted, e.g. `worksheet: path("signed/worksheet.pdf")`
  // with `worksheet: none` you can get rid of the red placeholder, this pattern applies to other mandatory content
  worksheet: auto,
  declaration: auto,
  consultation-log: auto,
  // only if the thesis is confidential
  // confidentiality: path("signed/confidentiality.pdf"),
  // both the abstracts and the summaries are written in Hungarian and English
  abstract: (
    hu: include "chapters/abstract-hu.typ",
    en: include "chapters/abstract-en.typ",
  ),
  summary: (
    hu: include "chapters/summary-hu.typ",
    en: include "chapters/summary-en.typ",
  ),
  // cited in the text like `@guide`, IEEE style
  bibliography: bibliography("bibliography.bib"),
  // used in the text like `@nik`, the first use is written out, only the used ones are listed
  abbreviations: (
    (key: "nik", short: "NIK", long: "John von Neumann Faculty of Informatics"),
    (key: "pdf", short: "PDF", long: "Portable Document Format"),
  ),
  appendices: include "chapters/appendices.typ",
  // the AI tools you used, required by the 18/2026. rector's instruction, each referenced like `@ai-test-cases`
  // after what it generated
  ai-tools: [
    #ai-tool(
      developer: [Anthropic],
      name: [Claude],
      type: [generative AI chatbot],
      version: [Claude Sonnet 5.5],
      usage: [suggesting wrong parameter values for testing],
      date: datetime(year: 2026, month: 9, day: 14),
    ) <ai-test-cases>
  ],
  // the free Nimbus Roman and Nimbus Sans by default, or the original fonts of the guide if you have them
  // fonts: (serif: "Times New Roman", sans: "Arial"),
  // the missing parts are red notes while drafting, `false` (or `typst compile --input draft=false`) turns them and
  // the length checks into errors for the version to submit
  draft: true,
)

#include "chapters/introduction.typ"
#include "chapters/requirements.typ"
#include "chapters/related-work.typ"
#include "chapters/design.typ"
#include "chapters/implementation.typ"
#include "chapters/evaluation.typ"
