#import "/pages/title_page.typ": _render-title-page

#include "/tests/helper/set-l10n-db.typ"

#let metadata= (
  paper-type: [Test print],
  title: [Custom PTB Template],
  student-id: "ABCDEFG",
  authors: "Bob the blob",
  company: "XY",
  enrollment-year: "2000",
  semester: "4",
  company-supervisor: "Dr. K. Brown",
  // These do not need to be changed by the user
  authors-per-line: 2,
)
#let word-count = "200"

#_render-title-page(
  metadata: metadata,
  word-count: word-count,
)
