// Milanovic Resume: one page, one column, ATS-friendly.
// Replace the placeholder text and delete what you don't need. Keep it on one page.
//
// Font: Source Sans 3 (free, OFL). Packages can't ship fonts, so add it yourself:
//   - typst.app: upload the .otf files from https://github.com/adobe-fonts/source-sans/releases to this project
//   - CLI: install the font, or run `typst compile --font-path <folder with the .otf files> main.typ`
#import "@preview/milanovic-resume:1.0.0": *

#show: resume.with(
  name: "Your Name",
  contact: (
    [City, Country],
    link("mailto:you@example.com")[you\@example.com],
    [+1 555 010 0000],
    link("https://www.linkedin.com/in/your-handle")[linkedin.com/in/your-handle],
    link("https://github.com/your-handle")[github.com/your-handle],
  ),
  headline: "Target Role, e.g. Senior Backend Engineer",
  tagline: "One line with your strongest result, e.g. Ships payment APIs that handle 2M transactions a day",
  keywords: ("Role", "Main language", "Main platform"),
  paper: "a4", // or "us-letter"
)

// Optional. One to three sentences: role, scope, two numbers. Delete for junior roles.
#summary[
  Backend engineer with 6 years building high-traffic APIs in Go and PostgreSQL. Cut p95 latency
  from 900 ms to 180 ms and led the migration of 40 services to Kubernetes with zero downtime.
]

= Skills
// Ten items, the ones the job description asks for first.
#skills(
  [Language 1, Language 2],
  [Framework or runtime],
  [Database / storage],
  [Cloud platform],
  [CI/CD and tooling],
  [Architecture style],
  [Testing approach],
  [Observability stack],
  [Security / compliance],
  [Soft skill backed by evidence],
)

= Professional Experience

// Full job title, company with its legal form (Inc., LLC, GmbH), dates as Mon YYYY.
#job("Company Inc.", title: "Full Job Title", location: "City, Country", dates: "Mar 2023 – Present")[
  // Verb first, result last, a number in between.
  - Built X that did Y, measured by Z.
  - Reduced A by N% by changing B.
  - Led a team of N to deliver C in M weeks.
]

#job("Company LLC", title: "Full Job Title", location: "City, Country", dates: "Jun 2020 – Feb 2023")[
  - Result with a number.
  - Result with a number.
]

// Projects work well for juniors, career switchers and open-source maintainers.
= Selected Projects
#project(
  "Project name",
  info: link("https://github.com/your-handle/project")[github.com/your-handle/project],
  stack: "Go, PostgreSQL, Docker",
)[
  - What it does and who uses it, with a number: stars, users, requests per second.
]

= Education
- #education("Degree", school: "University", year: "Year")

= Certifications
#inline[Certification][Certification]

= Languages
#inline[Language (native)][Language (C1)]
