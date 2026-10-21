#import "@preview/resume-ofa:0.1.0": *

#show: resume.with(
  author: "Jordan Lee",
  email: "jordan.lee@example.com",
  github: "github.com/jordan-lee",
  linkedin: "linkedin.com/in/jordan-lee",
  location: "Austin, TX",
  accent-color: "#315A7D",
  font-size: 9pt,
  paper: "us-letter",
)

== Profile

Software engineer focused on reliable systems, thoughtful interfaces, and practical automation.

== Experience

#work(
  title: "Software Engineer",
  company: "Example Systems",
  dates: dates-helper(start-date: "2023", end-date: "Present"),
  location: "Austin, TX",
)
- Built maintainable services and tooling used by cross-functional engineering teams.
- Improved delivery workflows through automated testing, observability, and documentation.

== Education

#edu(
  degree: "B.S. in Computer Science",
  institution: "Example University",
  dates: dates-helper(start-date: "2019", end-date: "2023"),
  gpa: "GPA: 3.9/4.0",
  consistent: true,
)

== Projects

#project(
  name: "Open Source Toolkit",
  org: "Community Project",
  dates: "2022 - 2023",
)
- Created a documented tool that helps users solve a recurring workflow problem.

== Skills

#skills(category: "Programming", items: "Python, TypeScript, SQL, Rust")
#skills(category: "Tools", items: "Git, Linux, CI/CD, Testing")

== Languages

#language(language: "English", proficiency: "Native")
#language(language: "Spanish", proficiency: "Professional")
