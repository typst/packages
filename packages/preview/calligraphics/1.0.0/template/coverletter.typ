#import "@preview/calligraphics:1.0.0": *

#show: coverletter.with(
  author: (
    firstname: "Jane",
    lastname: "Doe",
    email: "contact@example.org",
    phone: "+336 66 66 66 66",
    address: "City, Country",
    github: "Github",
    positions: ("Job researcher",),
  ),
  description: "Cover letter",
  font: ("Source Sans Pro", "Source Sans 3"),
  entity-info: (
    target: "Company recruitement team",
    name: "Company name",
    street-address : "1, street",
    city: "City",
  ),
  job-position: "the post",
  addressee: "reader",
)

#lorem(35)

#lorem(60)

#lorem(50)

#lorem(40)

#lorem(70)
