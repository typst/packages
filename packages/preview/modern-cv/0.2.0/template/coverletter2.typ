#import "@preview/modern-cv:0.2.0":*

#show: coverletter.with(
  author: (
    firstname: "John", 
    lastname: "Smith",
    email: "js@gmail.com", 
    phone: "(+1) 111-111-1111",
    github: "DeveloperPaul123",
    linkedin: "John Smith",
    address: "111 Example St. Apt. 111, Example City, EX 11111",
    positions: (
      "Software Engineer",
      "Full Stack Developer"
    )
  ),
  profile_picture: none
)

#hiring-entity-info(
  entity_info: (
    target: "Company Recruitement Team",
    name: "Google, Inc.",
    street_address: "1600 AMPHITHEATRE PARKWAY",
    city: "MOUNTAIN VIEW, CA 94043"
  )
)

#letter-heading(
  job_position: "Software Engineer",
  addressee: "Sir or Madame"
)

#coverletter-content[
    #lorem(100)
]

#coverletter-content[
  #lorem(90)
]

#coverletter-content[
  #lorem(110)
]
