#import "@preview/modern-cv:0.9.0": *

#show: coverletter.with(
  author: (
    firstname: "John",
    lastname: "Smith",
    email: "js@gmail.com",
    homepage: "https://example.com",
    phone: "(+1) 111-111-1111",
    github: "DeveloperPaul123",
    linkedin: "John Smith",
    address: "111 Example St. Apt. 111, Example City, EX 11111",
    positions: (
      "Software Engineer",
      "Full Stack Developer",
    ),
    custom: (
      (
        text: "Youtube Channel",
        icon: "youtube",
        link: "http://example.com",
      ),
    ),
  ),
  profile-picture: none,
  language: "sp",
  description: "Cover letter of John",
  keywords: "Software",
)

#hiring-entity-info(
  entity-info: (
    target: "Company Recruitement Team",
    name: "Google, Inc.",
    street-address: "1600 AMPHITHEATRE PARKWAY",
    city: "MOUNTAIN VIEW, CA 94043",
  ),
)

#letter-heading(job-position: "Software Engineer", addressee: "Sir or Madame")

#coverletter-content[
  #lorem(100)
]

#coverletter-content[
  #lorem(90)
]

#coverletter-content[
  #lorem(110)
]
