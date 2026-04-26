#import "@preview/classic-aau-report:0.3.0": project, mainmatter, chapters, backmatter, appendix
#import "setup/macros.typ": *

// revision to use for add, rmv and change
#set-revision(1)

// it is also possible to apply show rules to the entire project
// it is more or less a search and replace when applying it to a string.
// see https://typst.app/docs/reference/styling/#show-rules
// #show "naive": "naïve"
// #show "Dijkstra's": smallcaps

// Initialize acronyms / glossary
// See https://typst.app/universe/package/glossy for additional details.
#show: init-glossary.with((
  EV: "Electric Vehicle", // automatically infer plurality and set short = key
  // or be specific - maybe you would like a key to actually show something different
  web: (
    short: "WWW", // @web will show WWW
    long: "World Wide Web",
  ),
  PBL: "Problem Based Learning",
))

#show: project.with(
  meta: (
    project-group: "CS-xx-DAT-y-zz",
    participants: (
      "Alice",
      "Bob",
      "Chad",
    ),
    supervisors: "John McClane",
    // can also be specified as a list
    // supervisors: ("John McClane", "Hans Gruber"),

    // field of study shown on the front page
    field-of-study: "Computer Science",

    // specify if not a semester project
    // project-type: "Bachelor Project"
  ),
  en: (
    title: "An Awesome Project",
    theme: "Writing a project in Typst",
    abstract: [#lorem(50)],

    // NOTE: department and department-url can be set for BOTH en and dk
    // the defaults are the department of CS
    // department: "Department of Computer Science",
    // department-url: "https://www.cs.aau.dk",
  ),
  // omit the `dk` option completely to remove the Danish titlepage
  dk: (
    title: "Et Fantastisk Projekt",
    theme: "Et projekt i Typst",
    abstract: [#lorem(50)],
  ),
)

// put anything here that is to be included in the frontmatter, (with roman page numbers)
// like a preface, if so desired
// = Preface
// #lorem(100)

#outline(depth: 2)

// show a list of current todos
#note-outline()

#show: mainmatter
#include "chapters/introduction.typ"

#show: chapters
#include "chapters/problem-analysis.typ"
#include "chapters/custom-macros.typ"

// in the backmatter, the chapter numbers are removed again
// show the references here, along with other backmatter content, like a list of acronyms
#show: backmatter
#include "chapters/conclusion.typ"

// the documentation for this package includes a few different themes
// or even allows you to use your own custom one
#glossary(title: "List of Acronyms")
#bibliography("references.bib", title: "References")

#show: appendix
#include "appendices/scripting.typ"
