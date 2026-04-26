#import "@preview/modernpro-cv:1.0.2": *

#import "@preview/fontawesome:0.5.0": *

#show: cv-single.with(
  font-type: "PT Serif",
  continue-header: "false",
  name: [John Doe],
  address: [123 Street, City, Country],
  lastupdated: "true",
  pagecount: "true",
  date: [2024-07-03],
  contacts: (
    (text: [#fa-icon("location-dot") UK]),
    (text: [#fa-icon("mobile") 123-456-789], link: "tel:123-456-789"),
    (text: [#fa-icon("link") example.com], link: "https://www.example.com"),
  ),
)

// about
#section[about]
#descript[#lorem(50)]
#sectionsep
#section("Education")
#education(
  institution: [#lorem(4)],
  major: [#lorem(2)],
  date: "xxxx-xxxx",
  location: "UK",
  description: [
    - #lorem(10),
    - #lorem(10),
    - #lorem(10),
  ],
)
#subsectionsep
#education(
  institution: [#lorem(4)],
  major: [#lorem(2)],
  date: "xxxx-xxxx",
  location: "UK",
)

#section("Skills")
#oneline-title-item(
  title: "Programming Languages",
  content: [Python, C++, Java, JavaScript, HTML, CSS, SQL, LaTeX],
)
#sectionsep
// Award
#section("Awards")
#award(
  award: "Scholarship",
  date: "2018",
  institution: "University",
)
#sectionsep
//Experience
#section("Experience")
#job(
  position: "Software Engineer",
  institution: [#lorem(4)],
  location: "UK",
  date: "xxxx-xxxx",
  description: [
    - #lorem(10),
    - #lorem(10),
    - #lorem(10),
  ],
)
#sectionsep
// Projects
#section("Projects")
#twoline-item(
  entry1: "Project 1",
  entry2: "Jan 2023",
  description: [#lorem(40)],
)
// Publication
#section("Publications")

+ @singh1981asymptotic
+ @singh1981asymptotic

#sectionsep
// Reference
#section("References")
#references(references: (
  (
    name: "Dr. John Doe",
    position: "Professor",
    department: "Computer Science",
    institution: "University",
    address: "123 Street, City, Country",
    email: "john.doe@university.edu",
  ),
  (
    name: "Dr. John Doe",
    department: "Computer Science",
    institution: "University",
    address: "123 Street, City, Country",
    email: "john.doe@university.edu",
  ),
))

// Keep this at the end
#show bibliography: none
#bibliography("bib.bib", style: "chicago-author-date")