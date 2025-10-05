// University Assignment Template
// Usage: #import "template.typ": *
// Then call: #show: university-assignment.with(
//   title: "Your Title",
//   subtitle: "Your Subtitle",
//   author: "Your Name",
//   details: (
//     course: "ECSE 303",
//     supervisor: "Prof. Smith",
//     due-date: "September 19, 2025",
//     hardware: "Raspberry Pi, LED, resistor",
//     software: "C (WiringPi), Python (RPi.GPIO)",
//     duration: "~3 hours",
//   ),
//   date: datetime.today()
// )

#let university-assignment(
  title: "Assignment Title",
  subtitle: none,
  author: "",
  details: (:),
  date: datetime.today(),
  body
) = {
  // Page setup
  set page(margin: 1in)
  set text(size: 10pt)
  set heading(numbering: "1.")
  
  // Custom code block styling
  show raw.where(block: true): it => align(center)[
    #block(
      radius: 8pt,
      fill: luma(240),
      inset: 1em,
      stroke: none,
      breakable: false,
      width: 80%,
    )[
      #it
    ]
  ]
  
  show block.where(fill: rgb("#f0f8ff")): it => align(center, it)
  
  // Custom heading styles
  show heading.where(level: 1): it => [
    #set align(center)
    #set text(size: 20pt, weight: "bold")
    #block()[#it.body]
    #line(length: 100%, stroke: 0.5pt + rgb("#000000"))
    #v(0.5em)
  ]
  
  show heading.where(level: 2): it => [
    #set text(size: 18pt, weight: "semibold", fill: rgb(50, 50, 50))
    #block(above: 1.2em, below: 0.8em)[#it.body]
  ]
  
  // Simple emphasis and strong styling
  show emph: it => text(style: "italic", weight: "medium")[#it.body]
  show strong: it => text(weight: "bold")[#it.body]
  
  // Simple list styling
  show list: it => block(above: 0.6em, below: 0.6em)[#it]
  
  // Simple quote styling
  show quote: it => block(
    align(center),
    fill: luma(248),
    stroke: (left: 3pt + luma(180)),
    inset: (left: 1em, rest: 0.8em),
    radius: (right: 3pt),
  )[
    #set text(style: "italic")
    #it
  ]
  
  // Enhanced title page
  align(center)[
    #v(1.5em)
    #block(
      radius: 12pt,
      inset: 2em,
      stroke: 2pt,
    )[
      #text(size: 28pt, weight: "bold")[
        #title
      ]
      #if subtitle != none [
        #v(0.5em)
        #text(size: 20pt, weight: "semibold")[
          #subtitle
        ]
      ]
    ]
    #v(0.3em)
    #stack(
      dir: ltr,
      spacing: 1em,
      text(size: 20pt, weight: "bold")[#author],
      text(size: 20pt, fill: rgb(100, 100, 100))[#date.display("[month repr:long] [day], [year]")],
    )
    #v(2em)
  ]
  
  // Assignment Summary Box
  block(
    radius: 8pt,
    fill: rgb(248, 250, 252),
    stroke: 1pt + rgb(200, 220, 240),
    inset: 1.5em,
    width: 100%,
  )[
    #align(center)[
      #text(size: 16pt, weight: "bold", fill: rgb(30, 70, 120))[
        Assignment Overview
      ]
    ]
    #v(0.8em)
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 2em,
      row-gutter: 1em,
      // Left column
      [
        *Document Contents:*
        #outline(
          title: none,
          indent: 1em,
          depth: 2,
        )
      ],
      // Right column
      [
        *Assignment Details:*
        #if "course" in details [
          - *Course:* #details.course
        ]
        #if "supervisor" in details [
          - *Supervisor:* #details.supervisor
        ]
        #if "instructor" in details [
          - *Instructor:* #details.instructor
        ]
        #if "professor" in details [
          - *Professor:* #details.professor
        ]
        #if "due-date" in details [
          - *Due Date:* #details.due-date
        ]
        #if "hardware" in details [
          - *Hardware:* #details.hardware
        ]
        #if "software" in details [
          - *Software:* #details.software
        ]
        #if "duration" in details [
          - *Duration:* #details.duration
        ]
        #if "lab-number" in details [
          - *Lab Number:* #details.lab-number
        ]
        #if "partner" in details [
          - *Lab Partner:* #details.partner
        ]
        #if "section" in details [
          - *Section:* #details.section
        ]
      ],
    )
  ]
  
  v(1em)
  line(length: 100%, stroke: 0.5pt + rgb(200, 220, 240))
  v(0.5em)
  v(2em)
  
  pagebreak()
  
  // Document body
  body
}

// Example usage:
/*
#show: university-assignment.with(
  title: "Lab 3: GPIO and LED Control",
  subtitle: "Embedded Systems",
  author: "Your Name",
  details: (
    course: "ECSE 303",
    supervisor: "Michael Goldberg",
    due-date: "September 19, 2025",
    hardware: "Raspberry Pi, LED, resistor",
    software: "C (WiringPi), Python (RPi.GPIO)",
    duration: "~3 hours",
  ),
  date: datetime.today()
)

= Introduction
Your content here...
*/