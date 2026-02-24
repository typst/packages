#import "@preview/modern-cv:0.8.0": *

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
    website: "https://www.github.com/DeveloperPaul123",
    positions: (
      "Software Engineer",
      "Full Stack Developer",
    ),
  ),
  profile-picture: image("./profile.png"),
  // change this to match the language available in 'lang.toml'
  language: "en",
  font: "Times New Roman",
  // Remove the following line to show the footer
  // Or set the value to `true`
  show-footer: false,
  // set this to `none` to show the default or remove it completely
  closing: [],
  // see typst "page" documentation for more options
  paper-size: "us-gov-legal"
)

#hiring-entity-info(entity-info: (
  target: "Company Recruitement Team",
  name: "Google, Inc.",
  street-address: "1600 AMPHITHEATRE PARKWAY",
  city: "MOUNTAIN VIEW, CA 94043",
))

#letter-heading(
  job-position: "Software Engineer",
  addressee: "Sir or Madame",
)

= About Me
#coverletter-content[
  #lorem(80)
]

= Why Google?
#coverletter-content[
  #lorem(90)
]

= Why Me?
#coverletter-content[
  #lorem(100)
]
