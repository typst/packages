#import "@preview/modern-resume:0.1.0": modern-resume, workExperience, educationalExperience, project, pill

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

#educationalExperience(
  title: "Master's degree",
  subtitle: "University of Sciences",
  taskDescription: [
    - Short summary of the most important courses
    - Explanation of master thesis topic
  ],
  dateFrom: "10/2021",
  dateTo: "07/2023",
)

#educationalExperience(
  title: "Bachelor's degree",
  subtitle: "University of Sciences",
  taskDescription: [
    - Short summary of the most important courses
    - Explanation of bachelor thesis topic
  ],
  dateFrom: "09/2018",
  dateTo: "07/2021",
)

#educationalExperience(
  title: "College for Science",
  subtitle: "College of XY",
  taskDescription: [
    - Short summary of the most important courses
  ],
  dateFrom: "09/2018",
  dateTo: "07/2021",
)

== Work experience

#workExperience(
  title: "Data Scientist",
  subtitle: "Some Company",
  facilityDescription: "Company operating in sector XY",
  taskDescription: [
    - Short summary of your responsibilities
  ],
  dateFrom: "08/2021",
)

#workExperience(
  title: "Full Stack Software Engineer",
  subtitle: [#link("https://www.google.com")[Some IT Company]],
  facilityDescription: "Company operating in sector XY",
  taskDescription: [
    - Short summary of your responsibilities
  ],
  dateFrom: "09/2018",
  dateTo: "07/2021",
)

#workExperience(
  title: "Internship",
  subtitle: [#link("https://www.google.com")[Some IT Company]],
  facilityDescription: "Company operating in sector XY",
  taskDescription: [
    - Short summary of your responsibilities
  ],
  dateFrom: "09/2015",
  dateTo: "07/2016",
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
  dateFrom: "08/2022",
)

#project(
  title: "Project 2",
  subtitle: "Data Visualization, Data Engineering",
  description: [
    - #lorem(20)
  ],
  dateFrom: "08/2022",
  dateTo: "09/2022",
)

== Certificates

#project(
  title: "Certificate of XY",
  subtitle: "Issued by authority XY",
  dateFrom: "08/2022",
  dateTo: "09/2022",
)

#project(
  title: "Certificate of XY",
  subtitle: "Issued by authority XY",
  dateFrom: "05/2021",
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
