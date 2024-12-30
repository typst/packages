#import "@preview/classic-aau-report:0.1.0": project, frontmatter, mainmatter, backmatter, appendix

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
    // project-type: "Bachelor's Project"
  ),
  en: (
    title: "An awesome project",
    theme: "Writing a project in Typst",
    abstract: [#lorem(50)],

    // NOTE: both department and department-url can be set for BOTH en and dk
    // the defaults are for CS at AAU
    // department: "Department of Computer Science",
    // department-url: "https://www.cs.aau.dk",
  ),
  dk: (
    title: "Et fantastisk projekt",
    theme: "Et projekt i Typst",
    abstract: [#lorem(50)],
  ),
)

// put anything here that is to be included in the frontmatter, (with roman page numbers)
// like a list of tables, figures or todos

#show: frontmatter
#include "chapters/introduction.typ"

#show: mainmatter
#include "chapters/problem-analysis.typ"
#include "chapters/conclusion.typ"

// in the backmatter, the chapter numbers are removed again
// show the references here, along with other backmatter content, like a list of acronyms
#show: backmatter
#bibliography("references.bib", title: "References")

#show: appendix
#include "appendices/code-snippets.typ"
