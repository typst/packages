#import "vita.typ": *

//
// Assuming an icons directory exists, filled with SVG files,
// you can use the `decorated` function like so!
//
// email: decorated("icons/mail.svg", link("mailto:you@provider.domain", `you@provider.domain`)),
//

//
// Style
//

#show: modern.with(
  name: "Elle Woods",
  title: "Technical Résumé",
  email: decorated("icons/mail.svg", link("mailto:elle@woods.email", `elle@woods.email`)),
  phone: decorated("icons/phone.svg", link("tel:+1234567898", `+1 (123) 456-7898`)),
  theme: rgb(200, 150, 180),
  body: stack(spacing: 3em, experiences(), degrees(), skills()),
  side: stack(spacing: 3em, projects(header: "Court Cases"), socials(header: "Personal Media"),
  ),
)

//
// Content
//

#experience(
  "Supreme Court",
  role: ("Associate Justice"),
  start: "October 2023",
  stop: "Present"
)[
- Wrote $3$ opinions, co-signed 7 other opinions without ethics violations or appearances of impropriety
- First to expand court wardrobe to pink & lavender robes
]

#experience(
  "Federal Court",
  role: ("Federal Judge"),
  start: "September 2022",
  stop: "October 2023"
)[
- Ruled on $159$ cases; was objectivelly just and fair every time
- Wrote $98273$ pages of opinions; no spelling mistakes
]

#experience(
  "Woods Legal",
  role: ("Partner & Founder"),
  start: "August 2020",
  stop: "September 2022"
)[
- Undefeated court record with cases spanning real estate law, common law, criminal law, and more
- Founded firm; $5$ stars on Yelp, no poor reviews
]

#experience(
  "Calahan Legal",
  role: "Intern",
  start: "May 2019",
  stop: "May 2020",
)[
- Successfully defended Sister wrongfully acused of murder; did so prior to earning degree
- Exposed boss for the creep he was; ruined future chance at political office
]


#degree(
  "J.D.", "Law",
  school: "Harvard",
  stop: "May 2020",
)[
- Valedictorian of spring class of 2020
]

#degree(
  "B.S.", "Fashion Merchandising",
  school: "UCLA",
  stop: "May 2017",
)[
- Funneled beer; earned 4.0 GPA
- Sorority President
]

#skill("Writing")[
- Can write briefs with eyes closed
]

#skill("Fashion")[
- Good at fashion idk
]


#project(
  `Case 1`,
  description: "Solved this case."
)

#social(
  link("https://github.com/fake/ellewoods", `@elle`),
  icon: "icons/github.svg",
)

#social(
  link("https://www.linkedin.com/in/fake/ellewoods/", `in/ellewoods`),
  icon: "icons/linkedin.svg",
)

#social(
  link("https://elle.woods.fashionlaw", `elle.woods.fashionlaw`),
  icon: "icons/home.svg",
)
