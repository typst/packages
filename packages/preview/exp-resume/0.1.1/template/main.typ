#import "@preview/exp-resume:0.1.1": *

// Replace the example values below with your own information.
#let name = "John Doe"
#let location = "Null Island, AT"
#let email = "john.doe@example.com"
#let email-text = "john.doe[at]email.com"
#let github = "github.com/johndoe"
#let github-text = "gh/johndoe"
#let linkedin = "linkedin.com/in/johndoe"
#let linkedin-text = "in/johndoe"
#let phone = "+1 (555) 010-0101"
#let personal-site = "johndoe.dev"
#let personal-site-text = "johndoe.dev"

#show: resume.with(
  author: name,
  // All the lines below are optional. Comment out any value you do not need.
  location: location,
  email: email,
  email-text: email-text,
  github: github,
  github-text: github-text,
  linkedin: linkedin,
  linkedin-text: linkedin-text,
  phone: phone,
  personal-site: personal-site,
  personal-site-text: personal-site-text,
  accent-color: "#000000",
  font: "New Computer Modern",
  paper: "us-letter",
  author-position: center,
  personal-info-position: center,
)

/*
 * Lines that start with == are formatted into section headings.
 * Available formatting functions include:
 * #summary(body)
 * #edu(dates: "", degree: "", institution: "", location: "", consistent: false)
 * #work(company: "", dates: "", location: "", title: "")
 * #project(name: "", technologies: "", links: ())
 * #certificates(name: "", issuer: "", url: "", url-text: "", date: "")
 * #skills(category: "", items: "")
 * #extracurriculars(activity: "", dates: "")
 *
 * Generic layout helpers:
 * #generic-two-by-two(top-left: "", top-right: "", bottom-left: "", bottom-right: "")
 * #generic-one-by-two(left: "", right: "")
 * #dates-helper(start-date: "", end-date: "")
 * #linked-text(value, link-prefix: "", text: "")
 * #default-spacing  // resume.with(spacing: (...)) overrides
 */

== Summary

#summary[Engineer who ships reliable systems, writes boringly good docs, and consults rubber ducks before merging.]

== Education

#edu(
  institution: "University of Hypothetical Sciences",
  location: "Null Island, AT",
  dates: dates-helper(start-date: "Aug 2019", end-date: "May 2023"),
  degree: "B.S. Computer Science",
)
- GPA: 3.9/4.0 | Coursework: Algorithms, Distributed Systems, Databases

== Experience

#work(
  title: "Senior Bug Whisperer",
  location: "Remote",
  company: "Infinite Loop Inc.",
  dates: dates-helper(start-date: "Jul 2023", end-date: "Present"),
)
- Built reliable services and cut deploy anxiety with predictable CI
- Wrote runbooks so clear that on-call stopped being a contact sport

#work(
  title: "Software Engineering Intern",
  location: "Byteburg, CA",
  company: "Stack Overflow Overflow",
  dates: dates-helper(start-date: "May 2022", end-date: "Aug 2022"),
)
- Shipped internal tools and turned a 12-step release into one command

== Projects

#project(
  name: "RubberDuckDB",
  technologies: "Go, SQLite, gRPC",
  links: (
    (url: "github.com/johndoe/rubberduckdb", text: "Github"),
    (url: "rubberduckdb.johndoe.dev", text: "Live"),
  ),
)
- Toy database with snapshots, polite errors, and too many duck puns

#project(
  name: "CommitMessageGenerator",
  technologies: "Python, FastAPI, Redis",
  links: (
    (url: "github.com/johndoe/commit-msg-gen", text: "Github"),
  ),
)
- Generates commit messages from "fix typo" to Shakespearean tragedy

== Certificates

#certificates(
  name: "Certified Cloud Whisperer",
  issuer: "Example Institute",
  url: "example.com/cert/cloud",
  url-text: "Credential",
  date: "Jun 2024",
)

#certificates(
  name: "Kubernetes Trouble Tourist",
  issuer: "CNCF Fan Club",
  date: "Jan 2023",
)

== Activities

#extracurriculars(
  activity: "Open Source Mentoring Collective",
  dates: dates-helper(start-date: "Jan 2022", end-date: "Present"),
)
- Mentored newcomers and reviewed first-time contributor PRs

== Skills

#skills(
  category: "Languages",
  items: "Python, Go, TypeScript, SQL, Bash",
)

#skills(
  category: "Technologies",
  items: "FastAPI, React, PostgreSQL, Redis, Docker, Kubernetes",
)

#skills(
  category: "Tools",
  items: "Linux, GitHub Actions, Neovim, rubber ducks",
)
