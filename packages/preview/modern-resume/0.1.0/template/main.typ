#import "@preview/modern-resume:0.1.0": modern-resume, experience-work, experience-edu, project, pill

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
)

== Education

#experience-edu(
  title: "Master's degree",
  subtitle: "University of Sciences",
  task-description: [
    - Short summary of the most important courses
    - Explanation of master thesis topic
  ],
  date-from: "10/2021",
  date-to: "07/2023",
)

#experience-edu(
  title: "Bachelor's degree",
  subtitle: "University of Sciences",
  task-description: [
    - Short summary of the most important courses
    - Explanation of bachelor thesis topic
  ],
  date-from: "09/2018",
  date-to: "07/2021",
)

#experience-edu(
  title: "College for Science",
  subtitle: "College of XY",
  task-description: [
    - Short summary of the most important courses
  ],
  date-from: "09/2018",
  date-to: "07/2021",
)

== Work experience

#experience-work(
  title: "Data Scientist",
  subtitle: "Some Company",
  facility-description: "Company operating in sector XY",
  task-description: [
    - Short summary of your responsibilities
  ],
  date-from: "08/2021",
)

#experience-work(
  title: "Full Stack Software Engineer",
  subtitle: [#link("https://www.google.com")[Some IT Company]],
  facility-description: "Company operating in sector XY",
  task-description: [
    - Short summary of your responsibilities
  ],
  date-from: "09/2018",
  date-to: "07/2021",
)

#experience-work(
  title: "Internship",
  subtitle: [#link("https://www.google.com")[Some IT Company]],
  facility-description: "Company operating in sector XY",
  task-description: [
    - Short summary of your responsibilities
  ],
  date-from: "09/2015",
  date-to: "07/2016",
)

#colbreak()

== Skills

#pill("Teamwork", fill: true)
#pill("Critical thinking", fill: true)
#pill("Problem solving", fill: true)

== Projects

#project(
  title: [#link("https://www.google.com")[Project 1]],
  description: [
    - #lorem(20)
  ],
  date-from: "08/2022",
)

#project(
  title: "Project 2",
  subtitle: "Data Visualization, Data Engineering",
  description: [
    - #lorem(20)
  ],
  date-from: "08/2022",
  date-to: "09/2022",
)

== Certificates

#project(
  title: "Certificate of XY",
  subtitle: "Issued by authority XY",
  date-from: "08/2022",
  date-to: "09/2022",
)

#project(
  title: "Certificate of XY",
  subtitle: "Issued by authority XY",
  date-from: "05/2021",
)

#project(
  title: "Certificate of XY",
  subtitle: "Issued by authority XY",
)

== Languages

#pill("German (native)")
#pill("English (C1)")

== Interests

#pill("Maker-culture")
#pill("Science")
#pill("Sports")
