// Edit this file first. Use an explicit submission date.
#let project = (
  title: [Title of Your Final Year Design Project],
  students: (
    (name: "Student Name", id: "011 XXX XXX"),
    // (name: "Second Student", id: "011 XXX XXX"),
  ),
  date: [Month Year],
  // Optional: supervisors: ([Supervisor Name, Designation],),
  abstract: include "front-matter/abstract.typ",
  acknowledgements: include "front-matter/acknowledgements.typ",
  // Enable when relevant; otherwise no publication page is generated.
  // publications: include "front-matter/publications.typ",
  show-figure-list: true,
  show-table-list: true,
)
