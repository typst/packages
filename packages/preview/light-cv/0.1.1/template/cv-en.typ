#import "@preview/light-cv:0.1.0": *
#import "@preview/fontawesome:0.1.0": *

#show: cv

#let icons = (
  phone: fa-phone(),
  homepage: fa-home(fill: colors.accent),
  linkedin: fa-linkedin(fill: colors.accent),
  github: fa-github(fill: colors.accent),
  xing: fa-xing(),
  mail: fa-envelope(fill: colors.accent)
)

#header(
  full-name: [John Doe],
  job-title: [Software Engineer with a passion for JavaScript],
  socials: (
    (
      icon: icons.github,
      text: [JohnDoe],
      link: "https://github.com"
    ),
    (
      icon: icons.homepage,
      text: [johndoe.com],
      link: "johndoe.com"
    ),
    (
      icon: icons.mail,
      text: [john.doe\@email.com],
      link: "mailto://john.doe@email.com"
    ),
    (
      icon: icons.linkedin,
      text: [John Doe],
      link: "https://linkedin.com/"
    )
  ),
  profile-picture: image("media/avatar.jpeg")
)

#section("Professional Experience")
#entry(
  title: "Data Analyst", 
  company-or-university: "BetaSoft Technologies", 
  date: "2023 - Today", 
  location: "San Francisco, CA", 
  logo: image("media/ucla.png"),
  description: list(
    [Analyzed large datasets using SQL and Python to extract actionable insights, leading to optimized marketing strategies and increased revenue],
    [Designed and implemented data visualization dashboards using Tableau, improving data accessibility and decision-making processes.],
    [Collaborated with stakeholders to define key performance metrics and develop automated reporting solutions, streamlining data analysis processes]
  )
)
#entry(
  title: "Cybersecurity Consultant", 
  company-or-university: "Gamma Systems Inc.", 
  date: "2020 - 2022", 
  location: " London, UK", 
  logo: image("media/ucla.png"),
  description: list(
    [Conducted penetration testing and vulnerability assessments for client networks, identifying and mitigating security risks],
    [Developed and implemented cybersecurity policies and procedures to ensure compliance with industry standards and regulations],
    [Provided cybersecurity training and awareness programs for employees, reducing the risk of security incidents due to human error]
  )
)


#section("Education")
#entry(
  title: "Master of Science in Computer Science", 
  company-or-university: "University of California", 
  date: "09/2020 - 09/2022", 
  location: "Los Angeles, USA", 
  logo: "media/ucla.png",
  description: list(
    [Thesis: Exploring Deep Learning Techniques for Natural Language Understanding in Chatbots],
    [Minor: Mathematics],
    [GPA: 4.0]
  )
)
#entry(
  title: "Bachelor of Science in Computer Science", 
  company-or-university: "University of California", 
  date: "09/2017 - 09/2020", 
  location: "Los Angeles, USA", 
  logo: image("media/ucla.png"), 
  description: list(
    [Thesis: Design and Implementation of a Secure File Sharing System Using Blockchain Technology],
    [Minor: Mathematics],
    [GPA: 3.5]
  )
)

#section("Programming Expertise")
#entry(
  title: "Chatbot for Mental Health Support", 
  company-or-university: "Personal Project", 
  date: "2023 - 2024", 
  location: "", 
  logo: image("media/ucla.png"), 
  description: list(
    [Developed a chatbot using Python and the TensorFlow library for natural language processing],
    [Implemented sentiment analysis to assess the emotional state of users during conversations],
    [Integrated with external APIs to provide resources and guidance for mental health support based on user responses]
  )
)
#entry(
  title: "Smart Home Automation System", 
  company-or-university: "Personal Project", 
  date: "2020", 
  location: "", 
  logo: image("media/ucla.png"), 
  description: list(
    [Designed a smart home automation system using Raspberry Pi and Arduino microcontrollers],
    [Implemented sensors for monitoring temperature, humidity, and motion detection within the home environment],
    [Developed a web-based dashboard using HTML, CSS, and JavaScript to control and monitor connected devices remotely]
  )
)

#pagebreak()
#header(
  full-name: [John Doe],
  job-title: [Software Engineer with a passion for JavaScript],
  socials: (
    (
      icon: icons.github,
      text: [JohnDoe],
      link: "https://github.com"
    ),
    (
      icon: icons.homepage,
      text: [johndoe.com],
      link: "johndoe.com"
    ),
    (
      icon: icons.mail,
      text: [john.doe\@email.com],
      link: "mailto://john.doe@email.com"
    ),
    (
      icon: icons.linkedin,
      text: [John Doe],
      link: "https://linkedin.com/"
    )
  ),
  profile-picture: image("media/avatar.jpeg")
)

#section("Skills & Interests")
#skill(
  category: "Technology",
  skills: ("Cybersecurity", "Cloud Computing", "Internt of Things", "Svelte")
)
#skill(
  category: "Languages",
  skills: ("English (native)", "French (fluent)", "Chinese (Basics)")
)
#skill(
  category: "Sports",
  skills: ("Gym", "Baseball", "Cricekt")
)
#skill(
  category: "Interests",
  skills: ("Photography", "Travel", "Music")
)