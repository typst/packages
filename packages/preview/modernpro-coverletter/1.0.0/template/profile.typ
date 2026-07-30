// Your identity, defined once. This dictionary has the same shape as the one
// modernpro-cv takes, so a single copy can drive your CV, cover letter, and
// every statement in the same application.
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
