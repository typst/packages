#import "@preview/toy-cv:0.1.0": *

#let main-color = rgb("#E40019")

#let left-content = [
  #contact-section(main-color: main-color, i18n: "en", contact-entries: (
    (
      logo-name: "envelope",
      logo-link: "mailto:john.doe@example.com",
      logo-text: "john.doe@example.com",
    ),
    (
      logo-name: "github",
      logo-link: "https://github.com/404",
      logo-text: "GitHub - John Doe",
      logo-font: "Font Awesome 6 Brands",
    ),
    (
      logo-name: "location-dot",
      logo-text: "Moon",
    ),
    (
      logo-name: "phone",
      logo-link: "tel:+1234567890",
      logo-text: "+1 234 567 890",
    ),
    (
      logo-name: "linkedin",
      logo-link: "https://www.linkedin.com/in/johndoe/",
      logo-text: "LinkedIn - John Doe",
      logo-font: "Font Awesome 6 Brands",
    ),
    (
      logo-name: "globe",
      logo-link: "https://johndoe.com",
      logo-text: "johndoe.com",
    ),
    (
      logo-name: "car",
      logo-text: "Driving License",
    ),
    (
      logo-name: "graduation-cap",
      logo-text: "Master's Degree in Computer Science",
    ),
    (
      logo-text: "20 years old",
      logo-name: "cake-candles",
    ),
  ))
  #v(1fr)
  #left-section(title: "Languages", [
    French (Native)\
    English (Fluent)\
    Spanish (Intermediate)\
    German (Basic)
  ])
  #v(1fr)
  #left-section(title: "Skills & Knowledge", [
    *Programming tools :*
    Python, JavaScript, Django, Flask, React, Node.js, Docker, Kubernetes

    *Cloud platforms :*
    AWS, Google Cloud Platform, Azure

    *Databases :*
    PostgreSQL, MySQL, MongoDB

    *Version control :*
    Git, GitHub, GitLab

    *Methodologies :*
    Agile, Scrum, DevOps

    *Soft skills :*
    Teamwork, Problem-solving, Communication, Adaptability, Time Management
  ])
  #v(1fr)
  #left-section(title: "Certifications", [
    Certified Kubernetes Administrator (CKA)\
    AWS Certified Solutions Architect\
    Google Professional Cloud Architect
  ])
  #v(1fr)
  #left-section(title: "Interests", [
    Open Source Contributions,
    Cloud Computing,
    Artificial Intelligence,
    Hiking,
    Photography
  ])
]


#show: cv.with(
  title: "John Doe",
  subtitle: [
    Young graduate in Computer Science from the University of Technology\
    *Available from January 2024 for a full-time position*\
  ],
  avatar: image("assets/avatar.png"),
  avatar-size: 2.2cm,
  left-content: left-content,
)


#right-column-subtitle("Professional Experience")
#cv-entry(
  title: [
    *Developer*, Engineering Internship
  ],
  date: "2020 - Present",
  subtitle: [Tech Innovations, Paris, France],
  [
    - Developed and maintained web applications using Python and Django.
    - Collaborated with product managers to gather requirements and deliver features.
    - Implemented RESTful APIs and integrated third-party services.
  ],
)

#v(1fr)

#cv-entry(
  title: [
    *Software Engineer Intern*, Summer Internship
  ],
  date: "2019",
  subtitle: [Tech Solutions, San Francisco, CA],
  [
    - Assisted in the development of a cloud-based application using Python and Docker.
    - Conducted testing and debugging to ensure software quality.
    - Participated in daily stand-ups and sprint planning meetings.
  ],
)

#v(1fr)

#cv-entry(
  title: [
    *Junior Developer*, Freelance
  ],
  date: "2018 - 2019",
  subtitle: [Self-employed, Remote],
  [
    - Developed small-scale web applications for local businesses.
    - Managed project timelines and client communications.
    - Gained experience in full-stack development with a focus on user experience.
  ],
)

#v(1fr)

#right-column-subtitle("Projects")
#cv-entry(
  title: [
    *Open Source Contributor*, Various Projects
  ],
  date: "2017 - Present",
  subtitle: [GitHub],
  [
    - Contributed to multiple open source projects, primarily in Python and JavaScript.
    - Improved documentation and fixed bugs in popular libraries.
    - Engaged with the community through pull requests and issue discussions.
  ],
)

#v(1fr)

#cv-entry(
  title: [
    *Personal Project*, Portfolio Website
  ],
  date: "2021",
  subtitle: [johndoe.com],
  [
    - Designed and developed a personal portfolio website to showcase projects and skills.
    - Implemented responsive design principles for optimal viewing on various devices.
  ],
)

#v(1fr)

#right-column-subtitle("Education")

#cv-entry(
  title: [
    *Master's Degree in Computer Science*
  ],
  date: "2018 - 2020",
  subtitle: [University of Technology, Paris, France],
  [
    - Specialized in Software Engineering and Cloud Computing.
    - Completed a thesis on "Scalable Web Applications using Microservices Architecture".
  ],
)

#v(1fr)

#cv-entry(
  title: [
    *Bachelor's Degree in Information Technology*
  ],
  date: "2015 - 2018",
  subtitle: [University of Science, Paris, France],
  [
    - Focused on Software Development and Database Management.
    - Engaged in group projects to develop practical software solutions.
  ],
)

#v(1fr)

#cv-entry(
  title: [
    *High School Diploma*
  ],
  date: "2012 - 2015",
  subtitle: [High School of Excellence, Paris, France],
  [
    - Graduated with honors in Science and Mathematics.
    - Active member of the coding club and participated in regional competitions.
  ],
)
