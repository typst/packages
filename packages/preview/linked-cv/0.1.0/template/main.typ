#import "@preview/linked-cv:0.1.0": *

#show: linked-cv.with(
  firstname: "Your",
  lastname: "Name",
  socials: (
    email: "hello@example.com",
    mobile: "01234 567890",
    github: "your-github-username",
    linkedin: "your-linkedin-username",
  ),
  accent-colour: colours.accent,
  fonts: (
    headings: "Roboto",
    body: "Source Sans Pro",
  ),
)

#set text(size: 8pt, hyphenate: false)
#set par(justify: true, leading: 0.52em)

#typography.summary(lorem(35))

#components.section("Experience")

#components.employer-info(
  image("img/squircle.svg"),
  name: "OpenAI",
  duration: ("01-2023", "current"),
)

#frame.connected-frames(
  "company-id",
  (
    title: "Lead Software Engineer",
    duration: ("01-2023", "current"),
    body: [
      #components.workstream(
        title: "Project Name",
        tech-stack: ("python", "typescript", "react", "postgresql")
      )
      - #lorem(15)
      - #lorem(35)
      - #lorem(25)
    ]
  ),
  (
    title: "Software Engineer",
    duration: ("01-2023", "current"),
    body: [
      #components.workstream(
        title: "Project Name",
        tech-stack: ("python", "typescript", "react", "postgresql")
      )
      - #lorem(40)
      - #lorem(20)
      - #lorem(30)
    ]
  ),
)

#components.section("Qualifications")

#table(
  columns: (30%, 15%, 15%, 40%),
  align: (left, left, left, right),
  stroke: none,

  ..(("Qualification", "Grade", "Date", "Institution").map(typography.table-header)),

  table.hline(stroke: 0.5pt + colours.gray.lighten(60%)),

  ..(for item in (
    ("Mathematics", "1st", "—", "University of Exeter"),
    ("Machine Learning", "—", "09-2023", "Microsoft Azure"),
    ("Artificial Intelligence", "98%", "02-2025", "OpenAI"),
  ) {
    components.qualification(..item)
  })
)
