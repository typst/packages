#import "@preview/simple-soc-report:0.1.0": *
#show: report.with(
  project-type: "B.Comp. Dissertation",
  author-name: "Your Name",
  project-title: "Your Title",
  academic-year: "2025/2026",
  project-id: "H123456",
  advisor: "Your Advisor",
  deliverables: ("Report: 1 Volume", "Example Code: 1"),
  abstract-content: [
    #include "frontmatter/abstract.typ"
  ],
  acknowledgement-content: [
    #include "frontmatter/acknowledgements.typ"
  ],
  department: "Department of Computer Science",
  school: "School of Computing",
  university: "National University of Singapore",
  subject-descriptors: "D.2.10 Software Engineering: Design",
  keywords: (
    "Software Engineering",
    "Web Development",
  ),
  implementation-software: ("Typst 0.13+", "Git"),
  bibliography: bibliography("cite.bib", title: "References", style: "apa"),
  appendix-content: [
    #include "appendices/appendix-a.typ"
    #include "appendices/appendix-b.typ"
  ],
)

// You can put all your contents within this document,
// Or you can split them into multiple files and include them here, as shown below
// If you are using TinyMist, you may need to pin the main buffer in multi-file projects
// See https://myriad-dreamin.github.io/tinymist/frontend/vscode.html for instructions for VS Code

#include "chapters/introduction.typ"

= Conclusion<chap:conclusion>
#lorem(50)
#figure(
  table(
    columns: 3,
    table.header([*H1*], [*H2*], [*H3*]),
    [B1], [B2], [B3],
    [C1], [C2], [C3],
    [D1], [D2], [D3],
  ),
  caption: [An example table],
) <table:example-table>

