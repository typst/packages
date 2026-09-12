#import "@preview/modernpro-coverletter:1.0.0": *

// Edit identity and contacts here. Keeping them beside the statement content
// makes this starter a self-contained document with no personal-data imports.
#let profile = (
  name: [Your Name],
  role: [Your Current Role],
  address: [City, Country],
  contacts: (
    (text: [you\@example.edu], link: "mailto:you@example.edu"),
    (text: [your-site.example], link: "https://your-site.example"),
    (text: [ORCID~0000-0000-0000-0000], link: "https://orcid.org/0000-0000-0000-0000"),
  ),
)

// Research, teaching, or diversity statement. Shares the header, type scale,
// and colour of the cover letter and of modernpro-cv. A compact continuation
// header with page numbering appears automatically from page 2.
#show: statement.with(
  profile: profile,
  title: [Research Statement],
)

= Research agenda

Introduce the question that connects your work and explain why it matters.

= Current programme

Describe your strongest projects, methods, and contributions.

= Future work

Set out the next phase of the programme and the environment it needs to succeed.
