#import "@preview/modernpro-cv:1.0.0": *

#show: cv-double.with(
  name: [#lorem(2)], //name:"" or name:[]
  address: [#lorem(4)],
  lastupdated: "true",
  date: "2023.4.7",
  contacts: (
    (text: "08856", link: ""),
    (text: "example.com", link: "https://www.example.com"),
    (text: "github.com", link: "https://www.github.com"),
    (text: "123@example.com", link: "mailto:123@example.com"),
  ),
  bibfile: [bib.json],
  [
    //About
    #section("About")
    #descript[#lorem(50)]
    #sectionsep
    #section("Education")
    #subsection[#lorem(4)\ ]
    #term[xxxx-xxxx][UK]
    #subsectionsep
    #subsection[#lorem(4)\ ]
    #term[xxxx-xxxx][UK]
    #sectionsep
    #section("Skills")
    #descript("Programming Languages")
    #info[Python, C++, Java, JavaScript, HTML, CSS, SQL, LaTeX]
    #subsectionsep
    #descript("Frameworks")
    #info[React, Node.js, Express, Flask, Django, Bootstrap, jQuery]
    #subsectionsep
    #descript("Tools")
    #info[Git, GitHub, Docker, AWS, Heroku, MongoDB, MySQL, PostgreSQL, Redis, Linux]
    #sectionsep
    // Award
    #section("Awards")
    #awarddetail[2018][Scholarship][University]
    #awarddetail[2017][Grant][Organisation]
    #awarddetail[2016][Scholarship][University]
    #sectionsep
  ],
  [
    //Experience
    #section("Experience")
    #jobtitle[#lorem(4)][#lorem(2)]
    #term[xxxx-xxxx][UK]
    #jobdetail[
      - #lorem(10)
      - #lorem(10)
      - #lorem(10)
      - #lorem(10)
    ]
    #subsectionsep
    #jobtitle[#lorem(4)][#lorem(2)]
    #term[xxxx-xxxx][]
    #jobdetail[#lorem(30)]
    #subsectionsep
    // Projects
    #section("Projects")
    #descript[#lorem(2)]
    #info[#lorem(40)]
    #subsectionsep
    #descript[#lorem(2)]
    #info[#lorem(40)]
    #subsectionsep
    #descript[#lorem(2)]
    #info[#lorem(40)]
    #sectionsep
    // Publication
    #section("Publications")
    #publication("bib.bib", "chicago-author-date")
  ],
)

