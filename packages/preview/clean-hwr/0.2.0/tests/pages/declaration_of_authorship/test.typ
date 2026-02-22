#import "/pages/declaration_of_authorship.typ": _render-declaration-of-authorship

#include "/tests/helper/set-l10n-db.typ"

#let metadata-relevant-for-test = (
    title: [Custom *paper* title],
    authors: ("Bob the test blob", "Test Brown", "Blue White", "Yellow H. J."),
    authors-per-line: 3,
)

#_render-declaration-of-authorship(custom-declaration-of-authorship: lorem(40))

#_render-declaration-of-authorship(metadata: metadata-relevant-for-test)

#let metadata-relevant-for-test-two = (
    title: [Custom *paper* title],
    authors: "Bob the test blob",
)

#_render-declaration-of-authorship(metadata: metadata-relevant-for-test-two)
