// Set this to "fydp-1" to omit the optional implementation chapter.
// Remaining chapter numbers and references update automatically.
#let report-stage = sys.inputs.at("stage", default: "final")
#assert(("final", "fydp-1").contains(report-stage), message: "Unknown report stage.")

#include "chapters/01-introduction.typ"
#include "chapters/02-background.typ"
#include "chapters/03-project-design.typ"
#if report-stage == "final" {
  include "chapters/04-implementation.typ"
}
#include "chapters/05-standards.typ"
#include "chapters/06-conclusion.typ"

#bibliography("references.bib", title: [References], style: "ieee")
