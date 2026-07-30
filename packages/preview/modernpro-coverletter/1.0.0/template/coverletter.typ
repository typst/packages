#import "@preview/modernpro-coverletter:1.0.0": *
#import "profile.typ": profile

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
