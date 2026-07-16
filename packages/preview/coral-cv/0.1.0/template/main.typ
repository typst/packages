// Start here: replace every example value with your own details.
#import "@preview/coral-cv:0.1.0": resume, work, edu, project, dates-helper

#show: resume.with(
  author: "YOUR NAME",
  font: "Libertinus Serif",
  location: "Auckland, New Zealand",
  email: "hello@example.com",
  phone: "+64 21 000 0000",
  linkedin: "linkedin.com/in/your-name",
  github: "github.com/your-name",
  personal-site: "yourname.dev",
)

== Profile

Product-minded professional with experience turning complex problems into clear, useful outcomes. Replace this concise summary with the value you bring to your next role.

== Experience

#work(
  title: "Senior Product Designer",
  company: "Studio North",
  location: "Auckland, NZ",
  dates: dates-helper(start-date: "Mar 2022", end-date: "Present"),
)
- Led end-to-end design for a customer platform used by 30,000+ people.
- Partnered with engineering and research to reduce onboarding time by 35%.
- Built a reusable design system that improved consistency across product teams.

#work(
  title: "Product Designer",
  company: "Harbour Digital",
  location: "Wellington, NZ",
  dates: dates-helper(start-date: "Jan 2020", end-date: "Feb 2022"),
)
- Shaped digital services from discovery through launch for public and private clients.

== Education

#edu(
  institution: "University of Auckland",
  degree: "Bachelor of Design",
  location: "Auckland, NZ",
  dates: "2016 — 2019",
)

== Selected Projects

#project(
  name: "Portfolio website",
  role: "Designer & developer",
  url: "yourname.dev",
  dates: "2025",
)
- Designed and built a responsive portfolio to communicate case studies clearly.

== Skills

*Design:* Product strategy, UX research, interaction design, prototyping, design systems
#linebreak()
*Tools:* Figma, FigJam, Adobe Creative Suite, HTML/CSS, Git
