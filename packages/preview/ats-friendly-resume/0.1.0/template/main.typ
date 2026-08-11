#import "@preview/ats-friendly-resume:0.1.0": *

// Your personal information replace mine with yours (pls don't steal my identity)
#let name = "Ban Gueco"
#let location = "Gotham, Philippines"
// #let email = "example@gmail.com"
// #let phone = "012345672"
#let linkedin = "linkedin.com/in/example"
#let github = "github.com/aybangueco"
#let portfolio = "aybangueco.vercel.app"

#show: resume.with(
  author: name,
  author-position: center,
  // Personal information
  // Below these lines are optional
  // Feel free to comment out and remove them
  location: location,
  // email: email,
  // phone: phone,
  linkedin: linkedin,
  github: github,
  portfolio: portfolio,
  personal-info-position: center,
  // Document formatting and values
  // These are already defined by default, feel free to omit or edit them
  color-enabled: true,
  text-color: "#000080",
  font: "New Computer Modern",
  paper: "us-letter",
  author-font-size: 20pt,
  font-size: 10pt,
  lang: "en",
)

== Technical Skills
- *Programming Languages*: TypeScript, JavaScript, Go, Bash, HTML, CSS
- *Web Technologies*: React, Next.js, Sveltekit, Node.js, Express, Bun, Hono
- *DevOps & Tools*: Postman, Docker, Git, Github Actions

== Experience

// Experience section
// tech-used is optional so feel free to omit it.

#work(
  company: "Meow Solutions",
  role: "Full Stack Developer",
  dates: dates-util(start-date: "Sep 2021", end-date: "Present"),
  location: "Gotham, Philippines",
)
- Integrated meow for the cats.
- Upgraded cars using meow framework.

#work(
  company: "Wayne Solutions",
  role: "Batman's Assistant",
  dates: dates-util(start-date: "Sep 1999"),
  tech-used: "React | TypeScript | Node.js",
  location: "Gotham, Philippines",
)
- Integrated React to Batmobile
- Migrated Cobol system to TypeScript

== Projects

// Projects section
// tech-used is optional so feel free to omit it.

#project(
  name: "Batmobile Management System",
  dates: dates-util(start-date: "Sep 2002", end-date: "March 2003"),
  tech-used: "React | TypeScript | Node.js",
  url: "github.com/aybangueco/batmobile",
)
- Integrated React to Batmobile
- Migrated Cobol system to TypeScript

== Education
#edu(
  institution: "Batman University",
  location: "Gotham, Philippines",
  degree: "Bachelor of Science in Faking Degree",
  dates: dates-util(start-date: "Jun 1995", end-date: "June 1999"),
)
