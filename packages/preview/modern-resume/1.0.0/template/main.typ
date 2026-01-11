#import "@preview/modern-resume:1.0.0": modern-resume, experience, project, pill

#let custom-theme = (
  primary: rgb("#313C4E"),
  secondary: rgb("#222A33"),
  accentColor: rgb("#449399"),
  textPrimary: rgb("#000000"),
  textSecondary: rgb("#7C7C7C"),
  textMuted: rgb("#ffffff"),
)

#show: modern-resume.with(
  author: "John Doe",
  job-title: "Data Scientist",
  bio: lorem(5),
  avatar: image("avatar.png"),
  contact-options: (
    email: link("mailto:john.doe@gmail.com")[john.doe\@gmail.com],
    mobile: "+43 1234 5678",
    location: "Austria",
    linkedin: link("https://www.linkedin.com/in/jdoe")[linkedin/jdoe],
    github: link("https://github.com/jdoe")[github.com/jdoe],
    website: link("https://jdoe.dev")[jdoe.dev],
  ),
  theme: custom-theme,
)

== Education

#experience(
  title: "Master's degree",
  subtitle: "University of Sciences",
  task-description: [
    - Short summary of the most important courses
    - Explanation of master thesis topic
  ],
  date-from: "10/2021",
  date-to: "07/2023",
  label: "Courses",
  theme: custom-theme,
)

#experience(
  title: "Bachelor's degree",
  subtitle: "University of Sciences",
  task-description: [
    - Short summary of the most important courses
    - Explanation of bachelor thesis topic
  ],
  date-from: "09/2018",
  date-to: "07/2021",
  label: "Courses",
  theme: custom-theme,
)

#experience(
  title: "College for Science",
  subtitle: "College of XY",
  task-description: [
    - Short summary of the most important courses
  ],
  date-from: "09/2018",
  date-to: "07/2021",
  label: "Courses",
  theme: custom-theme,
)

== Work experience

#experience(
  title: "Data Scientist",
  subtitle: "Some Company",
  facility-description: "Company operating in sector XY",
  task-description: [
    - Short summary of your responsibilities
  ],
  date-from: "08/2021",
  label: "Achievements/Tasks",
  theme: custom-theme,
)

#experience(
  title: "Full Stack Software Engineer",
  subtitle: [#link("https://www.google.com")[Some IT Company]],
  facility-description: "Company operating in sector XY",
  task-description: [
    - Short summary of your responsibilities
  ],
  date-from: "09/2018",
  date-to: "07/2021",
  label: "Achievements/Tasks",
  theme: custom-theme,
)

#experience(
  title: "Internship",
  subtitle: [#link("https://www.google.com")[Some IT Company]],
  facility-description: "Company operating in sector XY",
  task-description: [
    - Short summary of your responsibilities
  ],
  date-from: "09/2015",
  date-to: "07/2016",
  label: "Achievements/Tasks",
  theme: custom-theme,
)

#colbreak()

== Skills

#pill("Teamwork", fill: true, theme: custom-theme)
#pill("Critical thinking", fill: true, theme: custom-theme)
#pill("Problem solving", fill: true, theme: custom-theme)

== Projects

#project(
  title: [#link("https://www.google.com")[Project 1]],
  description: [
    - #lorem(20)
  ],
  date-from: "08/2022",
  theme: custom-theme,
)

#project(
  title: "Project 2",
  subtitle: "Data Visualization, Data Engineering",
  description: [
    - #lorem(20)
  ],
  date-from: "08/2022",
  date-to: "09/2022",
  theme: custom-theme,
)

== Certificates

#project(
  title: "Certificate of XY",
  subtitle: "Issued by authority XY",
  date-from: "08/2022",
  date-to: "09/2022",
  theme: custom-theme,
)

#project(
  title: "Certificate of XY",
  subtitle: "Issued by authority XY",
  date-from: "05/2021",
  theme: custom-theme,
)

#project(
  title: "Certificate of XY",
  subtitle: "Issued by authority XY",
  theme: custom-theme,
)

== Languages

#pill("German (native)", theme: custom-theme)
#pill("English (C1)", theme: custom-theme)

== Interests

#pill("Maker-culture", theme: custom-theme)
#pill("Science", theme: custom-theme)
#pill("Sports", theme: custom-theme)
