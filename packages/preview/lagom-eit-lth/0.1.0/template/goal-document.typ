#import "@preview/lagom-eit-lth:0.1.0": goal-document, project-plan
#import "metadata.typ": *
#import "@preview/gantty:0.5.1": gantt

#let lang = "en"

#goal-document(
  tentative-title: title,
  authors: authors,
  start-date: start-date,
  end-date: end-date,
  course-code: "ETIM01",
  academic-supervisor: supervisors.at("academic"),
  examiner: examiner,
  lang: lang,
)[

#let amount = 50
  
= Introduction
#lorem(amount)

= Background and Motivation
#lorem(amount)

= Project Aims and Main Challenges
#lorem(amount)

= Approach and Methodology
#lorem(amount)

= Previous work
#lorem(amount)

= Advancements and Outcome
#lorem(amount)

= Resources
#lorem(amount)

]

#project-plan(
  academic-supervisor: supervisors.at("academic"),
  examiner: examiner,
  lang: lang
)[


= Project plan
  
#let project-plan = (
  tasks: (
    (
      name: "Some main task",
      start: "2026-01-01",
      end: "2026-01-16"
    ),
    (
      name: "Task 1",
      subtasks: (
        (
          name: "hello",
          start: "2026-01-16",
          end: "2026-02-03",
        ),
      ),
    ),
        (
      name: "Task 3",
      subtasks: (
        (
          name: "hello",
          start: "2026-02-17",
          end: "2026-03-20",
        ),
      ),
    ),
        (
      name: "Task 4",
      subtasks: (
        (
          name: "hello",
          start: "2026-03-21",
          end: "2026-04-20",
        ),
      ),
    ),
  ),
)

#figure(rect(inset: 1em)[
  #set align(left)
  
], caption: [The project plan for the thesis work.]) <fig:project-plan>

// And render
#figure(gantt(project-plan), caption: [A Gantt chart over the project plan from @fig:project-plan.])
  
]