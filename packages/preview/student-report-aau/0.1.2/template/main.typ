#import "template.typ": *

// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  meta: (
    title: "AAU Project Report Name",
    theme: "Insert theme name",
    project_period: "Fall Semester 2023",
    project_group: "group 1",
    participants: (
      (name: "Participant 1", email: "participant1@student.aau.dk"),
      (name: "Participant 2", email: "participant2@student.aau.dk"),
    ),
    supervisor: (
      (name: "Supervisor 1", email: "supervisor@studnet.aau.dk"),
    ),
    date: datetime.today().display()
  ),
  // Insert your abstract after the colon, wrapped in brackets.
  // Example: `abstract: [This is my abstract...]`
  abstract: [This is the abstract, please write something here. #lorem(59)],
  department: "Computer Science",
)

// This is the primary file in the project.
// Commonly referred to as 'master' in LaTeX, and wokenly called 'main' in Typst.

#include "chapters/chapter1.typ"
#pagebreak(weak: true)

#include "chapters/chapter2.typ"
#pagebreak(weak: true)

#bibliography("sources/sources1.bib")
