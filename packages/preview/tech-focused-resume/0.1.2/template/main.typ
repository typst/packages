#import "@preview/tech-focused-resume:0.1.2": *

// Replace these sample values with your name and professional headline.
#let name = "Jane Doe"
#let headline = "Full Stack Developer"
#let author-name-and-headline-uppercase = false

// Add your contact details. Social profile values are usernames or profile paths,
// while personal-site should be a domain or URL.
#let email = "jane.doe@example.com"
#let github = "janedoe"
#let linkedin = "jane-doe"
#let personal-site = "janedoe.dev"
#let show-contact-info-icons = true

// Control whether private contact details are included in the header.
#let location = "San Francisco, CA"
#let phone = "+1 (555) 123-4567"
#let show-sensitive-contact-info = true

// These values become metadata in the generated PDF.
#let pdf-title = "Resume - " + name
#let pdf-description = ""
#let pdf-keywords = "resume, CV, curriculum vitae, professional resume"

// Configure the header, visual style, language, and PDF metadata.
#show: resume.with(
  header-info: (
    style: "row",
    author: (
      name: name,
      headline: headline,
      position: center,
      uppercase: author-name-and-headline-uppercase,
    ),
    contact: (
      show-icons: show-contact-info-icons,
      show-sensitive-info: show-sensitive-contact-info,
      position: horizon,
      gap: 0.5em,
      info: (
        location: location,
        email: email,
        github: github,
        linkedin: linkedin,
        phone: phone,
        personal-site: personal-site,
      ),
    ),
  ),
  style: (
    accent-color: "#26428b",
    font: "New Computer Modern",
    paper: "us-letter",
    font-size: 10pt,
    margin: (
      top: 0.2in,
      bottom: 0.2in,
      left: 0.3in,
      right: 0.5in,
    ),
  ),
  config: (
    lang: "en",
    region: "us",
  ),
  document-metadata: (
    keywords: pdf-keywords,
    title: pdf-title,
    description: pdf-description,
  ),
)


// Add, remove, or reorder sections to match your experience.
#section("Summary")[
  Full stack software developer with a background in web and mobile development. Experienced in building and shipping production applications with TypeScript, React, Next.js, and Node.js, along with backend automation using Python. Comfortable working across the stack, from UI design to API integration and cloud deployment.
]

// Add one `work` entry per position. The content block contains its achievements.
#section("Work Experience")[
  #work(
    title: "Software Engineer",
    tech-stack: "TypeScript, React, Node.js, PostgreSQL",
    location: "San Francisco, CA",
    modality: "Hybrid",
    company: "Acme Corp",
    company-category: "Fintech",
    dates: dates-helper(start-date: "Jan 2024", end-date: "Present"),
    columns: (1.5fr, 1fr),
  )[
    - Migrated a legacy dashboard from jQuery to React and TypeScript, cutting page load time by roughly 40% and reducing reported bugs by half.
    - Built a Python service to generate weekly operations reports from multiple data sources, replacing a manual process and saving the team several hours per week.
    - Designed and implemented a REST API used by both the web and mobile clients, improving consistency and reducing duplicated backend logic.
  ]

  #work(
    title: "Junior Developer",
    tech-stack: "JavaScript, Vue.js, MySQL",
    location: "San Francisco, CA",
    modality: "Remote",
    company: "Bright Labs",
    company-category: "E-commerce",
    dates: dates-helper(start-date: "Jun 2022", end-date: "Dec 2023"),
    columns: (1.5fr, 1fr),
  )[
    - Implemented new features for a customer-facing web application, working closely with designers and senior engineers.
    - Resolved over 100 reported issues, improving overall application stability.
  ]
]

// Use one `edu` entry per school or degree. The content block can list relevant coursework.
#section("Education")[
  #edu(
    institution: "University of Example",
    location: "Boston, MA",
    dates: dates-helper(start-date: "Aug 2019", end-date: "Aug 2023"),
    degree: "B.Sc. in Computer Science",
    columns: (1fr, 1fr),
  )[
    Software Engineering, Artificial Intelligence, Object-Oriented Programming, Distributed Systems, Algorithms, Data Structures, Databases, Computer Networks, Web Development, Discrete Mathematics
  ]

  #edu(
    institution: "Example Technical High School",
    location: "Boston, MA",
    dates: dates-helper(start-date: "Jan 2016", end-date: "Dec 2018"),
    degree: "Technical Diploma in Systems Development",
    columns: (1fr, 1fr),
  )[
    Programming Logic, Databases, Algorithms, Web Development, Mobile Development, Networks, Design
  ]
]

// Use `project` entries for relevant personal, academic, professional projects, or contributions.
#section("Projects and Contributions")[
  #project(
    name: "TaskFlow",
    role: "Lead Developer",
    tagline: "Team task management platform",
    dates: dates-helper(start-date: "Mar 2023", end-date: "Aug 2023"),
    relation: "University of Example",
    relation-type: "Capstone Project",
    url: "https://github.com/janedoe/taskflow",
    columns: (2fr, 1fr),
  )[
    - Led the frontend architecture using React, TypeScript, and Vite, implementing authentication, boards, and real-time updates via WebSocket.
    - Designed and built the platform's real-time notification system, ensuring instant event synchronization across users.
    - Developed a REST API with Node.js, Express, and PostgreSQL to support work planning and tracking features.
    - Containerized the application with Docker and set up CI/CD pipelines via GitHub Actions for automated cloud deployment.
  ]

  #project(
    name: "OpenForms",
    tagline: "Accessible form components for web applications",
    role: "Open Source Contributor",
    dates: "Oct 2024",
    url: "https://github.com/janedoe/openforms",
    columns: (3fr, 1fr),
  )[
    - Improved developer experience by submitting fixes and documentation updates to the project.
    - Collaborated with maintainers through code reviews and issue discussions.
  ]

  #project(
    name: "WeatherNow",
    // role: "",
    tagline: "Minimalist weather forecast app",
    dates: dates-helper(start-date: "Oct 2021", end-date: "Jan 2022"),
    relation: "Personal Project",
    // relation-type: "",
    // url: "",
    columns: (1fr, 1fr),
  )[
    - Built a lightweight weather app using vanilla JavaScript and a public weather API.
    - Focused on fast load times and a clean, minimal interface with no framework overhead.
    - Implemented geolocation-based auto-detection so users get local forecasts without manual search.
    - Presented the project at the school's annual tech fair.
  ]

  #project(
    name: "Budget Tracker",
    // role: "",
    tagline: "Personal finance tracking tool",
    dates: dates-helper(start-date: "Feb 2022", end-date: "Jul 2022"),
    relation: "Personal Project",
    // relation-type: "",
    // url: "",
    columns: (1fr, 1fr),
  )[
    - Built a simple tool to track monthly spending and savings goals.
    - Added category-based reports to help users identify spending patterns.
  ]
]

// `grid-section` places sections side by side; adjust columns to change their relative widths.
#grid-section(
  columns: (3fr, 1fr),
  gutter: 2.5em,
  sections: (
    section("Skills")[
      #skills[
        - *Languages:* TypeScript, JavaScript, Python, Java, HTML/CSS
        - *Frontend:* React, Next.js, Vue.js, Tailwind CSS, Figma
        - *Backend:* Node.js, Express, REST APIs
        - *DevOps & Tools:* Git, GitHub, GitHub Actions, Docker, Vercel
        - *Databases:* PostgreSQL, MySQL
      ]
    ],
    section("Languages")[
      #languages[
        - *English:* Native
        - *Spanish:* Intermediate
      ]
    ],
  ),
)

// List certifications with their issuer, date, and an optional verification link.
#section("Certificates")[
  #certificates(
    name: "AWS Certified Cloud Practitioner",
    issuer: "Amazon Web Services",
    date: "Mar 2025",
    url: "https://aws.amazon.com/certification",
    columns: (1.5fr, 1fr),
  )

  #certificates(
    name: "Python for Data Science, AI & Development",
    issuer: "IBM (Coursera)",
    date: "Jan 2025",
    url: "https://coursera.org/verify/XXXXXXXX",
    columns: (1.5fr, 1fr),
  )

  #certificates(
    name: "Scrum Fundamentals Certified (SFC)",
    issuer: "SCRUMstudy",
    date: "Nov 2023",
    url: "https://scrumstudy.com/certification",
    columns: (1.5fr, 1fr),
  )
]

#section("Extracurriculars")[
  #extracurriculars(
    activity: "Open-source contributor",
    dates: dates-helper(start-date: "2024", end-date: "Present"),
  )
]
