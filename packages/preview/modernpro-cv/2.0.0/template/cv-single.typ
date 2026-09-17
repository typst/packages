#import "@preview/modernpro-cv:2.0.0": *

// Edit identity and contacts here. Keeping them beside the CV content makes
// this starter a self-contained document with no application-specific imports.
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

// Single-column academic CV. Everything below `profile` is optional:
//   preset: "compact" | "default" | "relaxed"   vertical rhythm
//   accent: rgb("#1e3a5f")                      the one colour in the document
//   layout: (continue-header: true)              compact identity from page 2
//   columns: 2                                  two-column variant, see cv-double.typ
#show: cv.with(profile: profile)

#section("Research Profile")
#summary[
  One or two sentences on the question that connects your work and the methods
  you use to answer it.
]
#section-gap

#section("Academic Appointments")
#experience(
  title: "Your Position",
  institution: [Institution, Department],
  location: "City, Country",
  date: "2023-present",
  details: [
    - One line on what you lead, build, or supervise.
  ],
)
#section-gap

#section("Education")
#education(
  institution: [University],
  major: [PhD in Your Field],
  date: "2016-2020",
  location: "City, Country",
  description: [Thesis: your thesis title.],
)
#section-gap

#section("Selected Publications")
#entry(
  title: [Paper title],
  right: "2025",
  meta: [Author list, Journal Name 8(2)],
)
#section-gap

#section("Research Funding")
#entry(
  title: [Grant title],
  right: "2024-2027",
  meta: [Funder; your role],
  location: [Amount],
)
#section-gap

#section("Teaching and Service")
#detail-line(title: "Teaching", content: [Courses you lead and supervision you provide.])
#detail-line(title: "Service", content: [Committees, review work, and outreach.])
#section-gap

#section("References")
#reference-list(references: (
  (
    name: "Referee Name",
    position: "Their Role",
    department: "Department",
    institution: "Institution",
    address: "City, Country",
    email: "referee@example.edu",
  ),
  (
    name: "Second Referee",
    position: "Their Role",
    department: "Department",
    institution: "Institution",
    address: "City, Country",
    email: "second@example.edu",
  ),
))
