#import "@preview/modern-project-report:0.1.0": project

#show: project.with(
  title: "Sample Project Report",
  subtitle: "A Study on Modern Software Engineering Concepts",
  abstract: [
    This project report presents an in-depth analysis and implementation of the target system.
    It details the theoretical foundation, architecture, methodology, experimental results, and conclusion.
  ],
  subject: "PROJ-CS881 PROJECT - III",
  degree: "Bachelor of Technology",
  stream: "Computer Science & Engineering",
  guide: (
    name: "Dr. Jane Smith",
    designation: "Associate Professor",
    department: "Department of Computer Science & Engineering",
  ),
  authors: (
    (
      name: "Alice Johnson",
      department: "Computer Science",
      rollno: "123456789",
      regno: "1000000010 of 2021-22",
    ),
    (
      name: "Bob Smith",
      department: "Computer Science",
      rollno: "123456790",
      regno: "1000000011 of 2021-22",
    ),
  ),
  department: "Department of Computer Science & Engineering",
  institute: "University Institute of Technology",
  address: "123 University Campus, Kolkata - 700001",
)

// Main document content below

= Introduction
#lorem(60)

== Background
#lorem(120)

== Objectives
#lorem(80)

= Related Work
#lorem(50)

== Literature Survey
#lorem(100)

=== Analysis of Existing Systems
#lorem(90)

= System Architecture & Implementation
#lorem(60)

== Design Details
#lorem(100)

#rect(
  stroke: 0.5pt + luma(120),
  inset: 10pt,
  radius: 4pt,
  width: 100%,
  lorem(20),
)

= Conclusion & Future Scope
#lorem(80)
