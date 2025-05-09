#import "@preview/fantastic-cv:0.1.0": *

#let name = "Austin Yu"
#let location = "Bay Area, CA"
#let email = "yuxm.austin1023@gmail.com"
#let phone = "+1 (xxx) xxx-xxxx"
#let url = "www.google.com"

// [{network: str, username: str, url: str}]
#let profiles = (
  (
    network: "GitHub",
    username: "austinyu",
    url: "github.com",
  ),
  (
    network: "LinkedIn",
    username: "xinmiao-yu-619128174",
    url: "linkedin.com/in",
  ),
)

/*
[
  {
    institution: str,
    location: str,
    url: str,
    area: str,
    studyType: str,
    startDate: str,
    endDate: str,
    score: str,
    courses: [str],
  }
]
*/
#let educations = (
  (
    institution: "Stanford University",
    location: "Stanford, CA",
    url: "stanford.edu",
    area: "Physics and Computer Science",
    studyType: "Bachelor of Science",
    startDate: "2019-09-01",
    endDate: "2023-06-01",
    score: "3.9/4.0",
    courses: (
      "Data Structures",
      "Algorithms",
      "Operating Systems",
      "Computer Networks",
      "Quantum Mechanics",
      "Linear Algebra",
      "Machine Learning",
      "Multivariable Calculus",
    ),
  ),
  (
    institution: "University of California, Berkeley",
    location: "Berkeley, CA",
    url: "berkeley.edu",
    area: "Computer Science",
    studyType: "Master of Science",
    startDate: "2023-08-01",
    endDate: "2025-05-01",
    score: "4.0/4.0",
    courses: (
      "Advanced Machine Learning",
      "Distributed Systems",
      "Cryptography",
      "Artificial Intelligence",
      "Database Systems",
      "Convex Optimization",
      "Natural Language Processing",
      "Computer Vision",
    ),
  ),
)


/*
[
  {
    name: str,
    location: str,
    url: str,
    description: str,
    position: str,
    startDate: str,
    endDate: str,
    highlights: [str],
  }
]
*/
#let works = (
  (
    name: "Microsoft",
    location: "Redmond, WA",
    url: "microsoft.com",
    description: "Azure Cloud Services Team",
    position: "Software Engineer Intern",
    startDate: "2023-05-15",
    endDate: "2023-08-15",
    highlights: (
      "Developed a distributed caching solution for Azure Functions, reducing cold start latency by 30% and improving overall performance for serverless applications.",
      "Implemented a monitoring dashboard using Power BI to visualize key performance metrics, enabling proactive issue detection and resolution.",
      "Collaborated with a team of engineers to refactor legacy code, improving maintainability and reducing technical debt by 25%.",
      "Contributed to the design and development of a new API gateway, enhancing scalability and security for cloud-based applications.",
      "Presented project outcomes to senior engineers and received commendation for delivering impactful solutions under tight deadlines.",
    ),
  ),
  (
    name: "Amazon",
    location: "Seattle, WA",
    url: "amazon.com",
    description: "Alexa Smart Home Team",
    position: "Software Development Engineer Intern",
    startDate: "2022-06-01",
    endDate: "2022-09-01",
    highlights: (
      "Designed and implemented a feature to integrate third-party smart home devices with Alexa, increasing compatibility by 20%.",
      "Optimized voice recognition algorithms, reducing error rates by 15% and improving user satisfaction.",
      "Developed automated testing frameworks to ensure the reliability of new integrations, achieving 90% test coverage.",
      "Worked closely with product managers to define feature requirements and deliver a seamless user experience.",
      "Participated in code reviews and contributed to team-wide best practices for software development.",
    ),
  ),
  (
    name: "Tesla",
    location: "Palo Alto, CA",
    url: "tesla.com",
    description: "Autopilot Software Team",
    position: "Software Engineer Intern",
    startDate: "2021-06-01",
    endDate: "2021-08-31",
    highlights: (
      "Developed and tested computer vision algorithms for lane detection, improving accuracy by 25% in challenging driving conditions.",
      "Enhanced the performance of real-time object detection systems, reducing processing latency by 10%.",
      "Collaborated with hardware engineers to optimize sensor data processing pipelines for autonomous vehicles.",
      "Conducted extensive simulations to validate new features, ensuring compliance with safety standards.",
      "Documented technical findings and contributed to research papers on advancements in autonomous driving technology.",
    ),
  ),
)

/*
[
  {
    name: str,
    url: str,
    source_code: str,
    roles: [str],
    startDate: str,
    endDate: str,
    description: str,
    highlights: [str],
  }
]
*/
#let projects = (
  (
    name: "Hyperschedule",
    url: "hyperschedule.io",
    source_code: "",
    roles: ("Individual Contributor", "Maintainer"),
    startDate: "2022-01-01",
    endDate: "2023-06-01",
    description: "Developed and maintained an open-source scheduling tool used by students across the Claremont Consortium, leveraging TypeScript, React, and MongoDB.",
    highlights: (
      "Implemented new features such as course filtering and schedule sharing, improving user experience and engagement.",
      "Collaborated with a team of contributors to address bugs and optimize performance, reducing load times by 40%.",
      "Coordinated with college administrators to ensure accurate and timely release of course data.",
    ),
  ),
  (
    name: "Claremont Colleges Course Registration",
    url: "",
    source_code: "github.com/claremont-colleges",
    roles: ("Individual Contributor", "Maintainer"),
    startDate: "2021-09-01",
    endDate: "2022-12-01",
    description: "Contributed to the development of a course registration platform for the Claremont Colleges, streamlining the enrollment process for thousands of students.",
    highlights: (
      "Designed and implemented a user-friendly interface for course selection, increasing adoption rates by 25%.",
      "Optimized backend systems to handle peak traffic during registration periods, ensuring system stability.",
      "Provided technical support and documentation to assist users and administrators with platform usage.",
    ),
  )
)

/*
[
  {
    organization: str,
    position: str,
    url: str,
    startDate: str,
    endDate: str,
    summary: str,
    location: str,
    highlights: [str],
  }
]
*/
#let volunteers = (
  (
    organization: "Bay Area Homeless Shelter",
    position: "Volunteer Coordinator",
    url: "",
    startDate: "2023-01-01",
    endDate: "2023-05-01",
    summary: "Coordinated volunteer efforts to support homeless individuals in the Bay Area, providing essential services and resources.",
    location: "Bay Area, CA",
    highlights: (
      "Managed a team of 20+ volunteers to organize weekly meal services",
      "Collaborated with a team of volunteers to sort and package food donations, ensuring efficient distribution to partner agencies.",
      "Participated in community education initiatives, promoting awareness of food insecurity and available resources.",
    ),
  ),
  (
    organization: "Stanford University",
    position: "Volunteer Tutor",
    url: "stanford.edu",
    startDate: "2023-06-01",
    endDate: "2023-09-01",
    location: "Stanford, CA",
    summary: "Provided tutoring support to high school students in mathematics and science subjects, fostering academic growth and confidence.",
    highlights: (
      "Developed personalized lesson plans and study materials to address individual student needs.",
      "Facilitated group study sessions, encouraging collaboration and peer learning.",
      "Received positive feedback from students and parents for effective teaching methods and dedication to student success.",
    ),
  ),
)

/*
[
  {
    title: str,
    date: str,
    url: str,
    awarder: str,
    summary: str,
  }
]
*/
#let awards = (
  (
    title: "Best Student Award",
    date: "2023-05-01",
    url: "stanford.edu",
    awarder: "Stanford University",
    summary: "",
  ),
  (
    title: "Dean's List",
    date: "2023-05-01",
    url: "",
    awarder: "Stanford University",
    summary: "Achieved Dean's List status for maintaining a GPA of 3.9 or higher.",
  ),
  (
    title: "Outstanding Research Assistant",
    date: "2023-05-01",
    url: "stanford.edu",
    awarder: "",
    summary: "Recognized for exceptional contributions to research projects in the Physics and Computer Science departments.",
  ),
  (
    title: "Best Paper Award",
    date: "2023-05-01",
    url: "berkeley.edu",
    awarder: "University of California, Berkeley",
    summary: "Received Best Paper Award at the UC Berkeley Graduate Research Symposium.",
  ),
)

/*
[
  {
    name: str,
    issuer: str,
    url: str,
    date: str,
  }
]
*/
#let certificates = (
  (
    name: "AWS Certified Solutions Architect",
    issuer: "",
    url: "aws.amazon.com/certification/certified-solutions-architect-associate/",
    date: "2023-05-01",
  ),
  (
    name: "Google Cloud Professional Data Engineer",
    issuer: "Google Cloud",
    url: "cloud.google.com/certification/data-engineer/",
    date: "2023-05-01",
  ),
  (
    name: "Microsoft Certified: Azure Fundamentals",
    issuer: "Microsoft",
    url: "learn.microsoft.com/en-us/certifications/azure-fundamentals/",
    date: "2023-05-01",
  ),
  (
    name: "Certified Kubernetes Administrator (CKA)",
    issuer: "Linux Foundation",
    url: "",
    date: "2023-05-01",
  ),
  (
    name: "Certified Ethical Hacker (CEH)",
    issuer: "",
    url: "www.eccouncil.org/programs/certified-ethical-hacker-ceh/",
    date: "2023-05-01",
  ),
)

/*
[
  {
    name: str,
    publisher: str,
    releaseDate: str,
    url: str,
    summary: str,
  }
]
*/
#let publications = (
  (
    name: "Understanding Quantum Computing",
    publisher: "Springer",
    releaseDate: "2023-05-01",
    url: "arxiv.org/abs/quantum-computing",
    summary: "A comprehensive overview of quantum computing principles and applications.",
  ),
  (
    name: "Machine Learning for Beginners",
    publisher: "O'Reilly Media",
    releaseDate: "2023-05-01",
    url: "",
    summary: "",
  ),
  (
    name: "Advanced Algorithms in Python",
    publisher: "Packt Publishing",
    releaseDate: "2023-05-01",
    url: "packt.com/advanced-algorithms-python",
    summary: "A deep dive into advanced algorithms and data structures using Python.",
  ),
  (
    name: "Data Science Handbook",
    publisher: "Springer",
    releaseDate: "2023-05-01",
    url: "",
    summary: "A practical guide to data science methodologies and tools.",
  ),
)

/*
[
  {
    title: str,
    highlights: [
      {
        summary: str,
        description: str,
      }
    ]
  }
]
*/
#let custom_sections = (
  (
    title: "Programming Languages",
    highlights: (
      (
        summary: "Languages",
        description: "Python, Java, C++, JavaScript, TypeScript",
      ),
      (
        summary: "Frameworks",
        description: "React, Node.js, Express, Flask, Django",
      ),
      (
        summary: "Databases",
        description: "MySQL, MongoDB, PostgreSQL",
      ),
      (
        summary: "Tools",
        description: "Git, Docker, Kubernetes, AWS, GCP",
      )
    )
  ),
  (
    title: "Skills",
    highlights: (
      (
        summary: "Soft Skills",
        description: "Teamwork, Communication, Problem Solving, Time Management",
      ),
      (
        summary: "Technical Skills",
        description: "Data Structures, Algorithms, Software Development, Web Development",
      ),
      (
        summary: "Languages",
        description: "English (Fluent), Spanish (Conversational)",
      )
    )
  ),
)

#let render_font = "New Computer Modern"
#let render_size = 10pt
#let render_size_title = render_size * 1.5
#let render_size_section = render_size * 1.3
#let render_size_entry = render_size * 1.1
#let render_page_paper = "a4"
#let render_margin = (
  top: 0.5in,
  bottom: 0.5in,
  left: 0.5in,
  right: 0.5in,
)
#let render_accent_color = "#26428b"

#let render_space_between_highlight = -0.5em
#let render_space_between_sections = -0.5em

#show: config.with(
  font: render_font,
  font_size: render_size,
  page_paper: render_page_paper,
  margin: render_margin,
  accent_color: render_accent_color,
  space_between_sections: render_space_between_sections,
  space_between_highlight: render_space_between_highlight,
)

#section_basic_info(
  name: name,
  location: location,
  email: email,
  phone: phone,
  url: url,
  profiles: profiles,
)

#section_education(educations)

#section_work(works)

#section_project(projects)

#section_volunteer(volunteers)

#section_award(awards)

#section_certificate(certificates)

#section_publication(publications)

#sections_custom(custom_sections)
