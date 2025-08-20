#import "@preview/modernpro-cv:1.0.1": *

#show: cv-double(
  font-type: "PT Sans",
  continue-header: "true",
  name: [#lorem(2)],
  address: [#lorem(4)],
  lastupdated: "true",
  pagecount: "true",
  date: "2024-07-03",
  contacts: (
    (text: "08856", link: ""),
    (text: "example.com", link: "https://www.example.com"),
  ),
  left: [
    #section[about]
    #descript[#lorem(50)]
    #sectionsep
    #section("Skills")
    #oneline-title-item(
      title: "Programming Languages",
      content: [Python, C++, Java, JavaScript, HTML, CSS, SQL, LaTeX],
    )
    #sectionsep
    // Award
    #section("Awards")
    #award(award: "Scholarship", date: "2018", institution: "University")
    #sectionsep
  ],

  right: [
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
      entry3: "https://www.example.com",
      entry4: "UK",
      description: [
        - #lorem(20)
        - #lorem(10)
      ],
    )
    #subsectionsep
    #twoline-item(
      entry1: "Project 2",
      entry2: "Jan 2023",
      description: [#lorem(40) \ ],
    )
    #sectionsep
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
  ],
)


