#import "@preview/crisp-cv:1.0.0": *

// This section defines the content of the header as well as global configuration values.
#show: cv.with(
  name: "John Doe",
  contact: (
    "1847 Maple Crescent, Ottawa",
    "+1 (613) 555-1337",
    link("mailto:john.doe@mailbox.ca"),
  ),
  links: (
    link("https://gitlab.com/jdoe")[gitlab.com/jdoe],
    link("https://linkedin.com/in/johndoe")[linkedin.com/in/johndoe],
  ),
  // The following configuration dictionary is entirely optional.
  // Feel free to remove it in its entirety or only keep the you need.
  config: (
    paper: "a4",
    page-margin: 0.6in,
    font: "Source Sans Pro",
    font-size: 11pt,
    show-footer: true,
    // If you want to override the embedded title of the PDF file and the title shown in the footer, uncomment and edit the following line:
    // file-title: "CV Your Name",
  ),
)

/* Starting here, you can customize the contents of your CV as you wish.
 * The template provides the following features:
 * - Headings with "=" are rendered in smallcaps and with a divider line below.
 * - #skills() can be used to display a table-like listing of your skillset.
 * - #record() can be used to provide details on a single employment or a record in your education.
 * - #badge() can be used to display arbitrary text in a badge to highlight, for example, a reference or a skill.
 * Note that you can put any other content below a heading too, you do not have to stick with these predefined blocks.
 */

= Skills
#skills(
  ("Natural Languages", [English _(native)_, French _(professional)_, Spanish _(basic)_]),
  ("Programming Languages", "Rust, Java, Python, TypeScript, JavaScript, C/C++"),
  ("Technologies", "Git, Kubernetes, Ansible, PostgreSQL, Redis"),
  (
    "Security",
    "Application Security, Threat Modeling, IAM, Delegated Authorization, SSDLC, Supply Chain Security, Post-Quantum Cryptography",
  ),
  ("Project Management", "GitLab, GitHub, Jira, Confluence, Agile Development / Scrum"),
)

= Professional Experience
#record(
  primary: "Senior Security Software Engineer",
  secondary: "Cipher & Sons Security Consulting Ltd.",
  location: "Toronto, ON, Canada",
  timespan: "April 2022 - Present",
)[
  - Designed and implemented secure backend services in Rust and Java for enterprise customers.
  - Led threat modeling workshops during architecture reviews.
  - Introduced automated SAST and dependency scanning into CI/CD pipelines.
  - Performed security code reviews and mentored developers on secure coding practices.
  - Coordinated responsible vulnerability disclosure with client engineering teams.
]

#record(
  primary: "Application Security Engineer",
  secondary: "NullPointer Insurance Group",
  location: "Dublin, Ireland",
  timespan: "August 2019 - March 2022",
)[
  - Embedded security into agile development teams.
  - Built internal tooling for vulnerability management using Python.
  - Conducted penetration testing of web applications and REST APIs.
  - Reduced critical security findings by introducing secure coding guidelines.
  #badge("References available upon request")
]

#record(
  primary: "Software Engineer",
  secondary: "ByteShield Technologies",
  location: "Cork, Ireland",
  timespan: "July 2017 - July 2019",
)[
  - Developed Java microservices for cloud-hosted applications.
  - Implemented authentication and authorization features using OAuth2 and OIDC.
  - Automated testing and deployment workflows using GitLab CI.
]

#record(
  primary: "Security Software Engineering Intern",
  secondary: "Hack to the Future Labs",
  location: "Galway, Ireland",
  timespan: "May 2016 - August 2016",
)[
  - Assisted in developing internal security assessment tools.
  - Documented security findings for customer reports.
]

= Education
#record(
  primary: "Bachelor of Science in Computer Science",
  secondary: "University College Cork",
  location: "Cork, Ireland",
  timespan: "2013 - 2017",
)[
  - Focus: Software Engineering and Computer Security
  - Final Year Project: _Static Analysis Techniques for Detecting Security Vulnerabilities in Web Applications_
]

#record(
  primary: "Leaving Certificate",
  secondary: "St. Brendan's Community College",
  location: "Cork, Ireland",
  timespan: "2013",
)[]
