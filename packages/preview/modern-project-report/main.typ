#import "lib.typ": project

// Sample report content for testing and generating previews
#show: project.with(
  title: "Sample Project Report",
  subtitle: "A sample project on modern software engineering",
  abstract: lorem(50),
  subject: "PROJ-CS881 PROJECT - III",
  degree: "Bachelor of Technology",
  stream: "Information Technology",
  guide: (
    name: "Mr. Aurghyadip Kundu",
    designation: "Assistant Professor",
    department: "Information Technology",
  ),
  authors: (
    (
      name: "Jane Doe",
      department: "Computer Science",
      rollno: "123456789",
      regno: "1000000010 of 2021-22",
    ),
    (
      name: "John Doe",
      department: "Computer Science",
      rollno: "123456789",
      regno: "1000000010 of 2021-22",
    ),
    (
      name: "Jason Doe",
      department: "Computer Science",
      rollno: "123456789",
      regno: "1000000010 of 2021-22",
    ),
    (
      name: "Jimmy Doe",
      department: "Computer Science",
      rollno: "123456789",
      regno: "1000000010 of 2021-22",
    ),
    (
      name: "Timmy Doe",
      department: "Computer Science",
      rollno: "123456789",
      regno: "1000000010 of 2021-22",
    ),
  ),
  department: "Department of Information Technology",
  institute: "Calcutta Institute of Engineering and Management",
  address: "24/1A Chandi Ghosh Road, Kolkata - 700040",
)

// Main document content below

= Introduction
#lorem(60)

== In this paper
#lorem(320)

== Contributions
#lorem(40)

== Some Other Things
#lorem(40)

= Related Work
#lorem(50)

== Level 2 Heading
#lorem(100)

=== Level 3 Heading
#lorem(100)

==== Level 4 Heading
#lorem(100)

===== Level 5 Heading
#lorem(100)

#rect(
  stroke: 0.5pt + luma(120),
  inset: 10pt,
  radius: 4pt,
  width: 100%,
  lorem(10),
)