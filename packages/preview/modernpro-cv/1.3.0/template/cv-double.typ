#import "@preview/modernpro-cv:1.3.0": *
#import "@preview/fontawesome:0.6.0": *

#show: cv-double(
  font-type: "PT Sans",
  continue-header: "true",
  margin: (left: 1.5cm, right: 1.5cm, top: 2.2cm, bottom: 1.8cm),
  name: [#lorem(2)],
  address: [#lorem(4)],
  lastupdated: "true",
  pagecount: "true",
  date: [2024-07-03],
  contacts: (
    (text: [#fa-icon("location-dot") UK]),
    (text: [#fa-icon("mobile") 123-456-789], link: "tel:123-456-789"),
    (text: [#fa-icon("link") example.com], link: "https://www.example.com"),
  ),
  left: [
    #let left-sections = (
      section-block("about", title: "About")[
        #descript[#lorem(40)]
      ],
      section-block("skills", title: "Skills")[
        #oneline-title-item(
          title: "Programming Languages",
          content: [Python, C++, Java, JavaScript, HTML, CSS, SQL, LaTeX],
        )
        #oneline-title-item(
          title: "Frameworks",
          content: [React, Node.js, Express, Flask, Django, Bootstrap, jQuery],
        )
      ],
      section-block("awards", title: "Awards")[
        #award(award: "Scholarship", date: "2018", institution: "University")
      ],
    )

    #let left-order = ("about", "skills", "awards")

    #render-sections(sections: left-sections, order: left-order)
  ],

  right: [
    #let right-sections = (
      section-block("experience", title: "Experience")[
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
        #subsectionsep
        #job(
          position: "Software Engineer",
          institution: [#lorem(4)],
          location: "UK",
          date: "xxxx-xxxx",
        )
      ],
      section-block("projects", title: "Projects")[
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
      ],
      section-block("education", title: "Education")[
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
      ],
      section-block("publications", title: "Publications", separator: false)[
        + @singh1981asymptotic
        + @singh1981asymptotic
      ],
      section-block("references", title: "References", separator: false)[
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
      ],
    )

    #let right-order = (
      "experience",
      "projects",
      "education",
      "publications",
      "references",
    )

    #render-sections(sections: right-sections, order: right-order)

    // Keep this at the end
    #show bibliography: none
    #bibliography("bib.bib", style: "chicago-author-date")
  ],
)
