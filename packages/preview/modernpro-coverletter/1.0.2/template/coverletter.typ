#import "@preview/modernpro-coverletter:1.0.2": *

// Edit identity and contacts here. Keeping them beside the letter content
// makes this starter a self-contained document with no personal-data imports.
#let profile = (
  name: [Your Name],
  role: [Your Current Role],
  address: [City, Country],
  contacts: (
    (text: [name\@candidate.invalid], link: "mailto:name@candidate.invalid"),
    (text: [site.candidate.invalid], link: "https://site.candidate.invalid"),
    (text: [Fictional ID~0000-0000], link: "https://registry.example.invalid/0000-0000"),
  ),
)

// Academic cover letter. Everything below `profile` and `recipient` is optional:
//   preset: "compact" | "default" | "relaxed"   vertical rhythm
//   accent: rgb("#1e3a5f")                      the one colour in the document
#show: coverletter.with(
  profile: profile,
  recipient: (
    name: [Recipient Name],
    role: [Recipient Role],
    department: [Department],
    organization: [Institution],
    address: [City, Country],
    date: [1 January 2026],
    subject: [Application for Position Title],
    greeting: [Dear Members of the Committee,],
  ),
  closing: (
    supplements: ([Enclosure: Curriculum vitae],),
  ),
)

State the position you are applying for, your current role, and the central fit
between your work and the department.

Describe your strongest research contribution and the next question you plan
to pursue.

Summarize your teaching or professional contribution, then close with a concise
statement of interest.
