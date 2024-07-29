#import "@preview/modernpro-cv:1.0.0": *

    #show: cv-single.with(
  font-type: "PT Serif",
  continue_header: "false",
  name: "John Doe",
  address: "123 Street, City, Country",
  lastupdated: "true",
  pagecount: "true",
  date: "2024-07-03",
  contacts: (
    (text: "08856", link: ""),
    (text: "example.com", link: "https://www.example.com"),
    (text: "github.com", link: "https://www.github.com"),
    (text: "123@example.com", link: "mailto:123@example.com"),
  ),
)

// about
#section[about]
#descript[#lorem(50)]
#sectionsep
#section("Education")
#education(institution: [#lorem(4)], major: [#lorem(2)], period: "xxxx-xxxx", location: "UK", description: [
  - #lorem(10),
  - #lorem(10),
  - #lorem(10),
])

#education(institution: [#lorem(4)], major: [#lorem(2)], period: "xxxx-xxxx", location: "UK")

#section("Skills")
#oneline-item(title: "Programming Languages", content: [Python, C++, Java, JavaScript, HTML, CSS, SQL, LaTeX])
#oneline-item(title: "Frameworks", content: [React, Node.js, Express, Flask, Django, Bootstrap, jQuery])
#oneline-item(title: "Tools", content: [Git, GitHub, Docker, AWS, Heroku, MongoDB, MySQL, PostgreSQL, Redis, Linux])
#sectionsep
// Award
#section("Awards")
#award(award: "Scholarship", date: "2018", institution: "University")
#award(award: "Prize", date: "2018", institution: "University")
#sectionsep
//Experience
#section("Experience")
#job(position: "Software Engineer", institution: [#lorem(4)], location: "UK", date: "xxxx-xxxx", description: [
  - #lorem(10),
  - #lorem(10),
  - #lorem(10),
])
#subsectionsep
#job(position: "Software Engineer", institution: [#lorem(4)], location: "UK", date: "xxxx-xxxx")
#sectionsep
// Projects
#section("Projects")
#twoline-item(entry1: "Project 1", entry2: "Jan 2023", description: [#lorem(40)])

// project[#lorem(2)][Jan 2023][#lorem(40)]
// subsectionsep
// project[#lorem(2)][][
//   - #lorem(15)
//   - #lorem(15)
// ]
// subsectionsep
// project[#lorem(2)][][#lorem(40)]
// sectionsep
// // Publication
#section("Publications")
#publication("bib.bib", "american-psychological-association")

// Reference
#section("References")
#references(references: ((
  name: "Dr. John Doe",
  position: "Professor",
  department: "Computer Science",
  institution: "University",
  address: "123 Street, City, Country",
  email: "john.doe@university.edu",
), (
  name: "Dr. John Doe",
  department: "Computer Science",
  institution: "University",
  address: "123 Street, City, Country",
  email: "john.doe@university.edu",
), (
  name: "Dr. John Doe",
  position: "Professor",
  department: "Computer Science",
  institution: "University",
  address: "123 Street, City, Country",
  email: "john.doe@university.edu",
),))