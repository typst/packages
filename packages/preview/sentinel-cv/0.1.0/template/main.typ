// Sentinel CV. Replace the details below with your own and delete what you do
// not need; every section here is optional. The accent colour is set once, on
// the line after this comment, and everything picks it up from there.

#import "@preview/sentinel-cv:0.1.0": *

#let accent = "#26428b"

// Unlike most CV packages, the contact details belong on the show rule rather
// than in a separate header call: the name, location and contact line are part
// of the document shell.
#show: resume.with(
  author: "Margaret Okafor",
  location: "Leeds, UK",
  phone: "+44 113 496 0771",
  email: "margaret.okafor@example.com",
  social-links: (
    ("example.com/okafor", "example.com/okafor"),
    ("linkedin.com/in/example", "linkedin.com/in/example"),
  ),
  accent-color: accent,
  // New Computer Modern ships with Typst, so this renders the same everywhere
  // without installing anything. Any family you have works too.
  font: "New Computer Modern",
  font-size: 10pt,
  paper: "a4",
  margin: 0.5in,
)

#cv-section("Profile", accent-color: accent)

Chartered civil engineer with fourteen years on highway and drainage schemes,
most of them public sector and most of them constrained by something other than
engineering. Comfortable explaining to a committee why the cheaper option costs
more over thirty years.

#cv-section("Experience", accent-color: accent)

#entry-heading(
  main: "Principal Engineer",
  dates: format-dates("2021", "Present"),
  description: "Harlow and Vance Consulting",
  bottom-right: "Leeds, UK",
  accent-color: accent,
)
- Technical lead on a GBP 40M flood alleviation scheme covering 9 km of urban
  watercourse, delivered to programme and GBP 1.2M under budget.
- Introduced a standard drainage design review that cut late-stage design
  changes by around a third across the team's last eleven projects.
- Line manage six engineers and hold the practice's graduate development scheme.

#entry-heading(
  main: "Senior Engineer",
  dates: format-dates("2016", "2021"),
  description: "Calderbank Infrastructure",
  bottom-right: "Manchester, UK",
  accent-color: accent,
)
- Led detailed design for three highway improvement schemes, including a grade
  separated junction carrying 34,000 vehicles a day.
- Wrote the practice's approach to SuDS adoption, later cited in two local
  authority design guides, and ran the contractor interface through
  construction on two schemes.

// An entry with no bullets after it is perfectly fine; nothing is left hanging.
#entry-heading(
  main: "Graduate then Design Engineer",
  dates: format-dates("2011", "2016"),
  description: "Northern Counties Council",
  bottom-right: "Leeds, UK",
  accent-color: accent,
)

#cv-section("Education", accent-color: accent)

#entry-heading(
  main: "MEng Civil Engineering, First Class",
  dates: format-dates("2007", "2011"),
  description: "University of Sheffield",
  bottom-right: "Sheffield, UK",
  accent-color: accent,
)

#cv-section("Professional Qualifications", accent-color: accent)

#cv-certification(
  title: "Chartered Engineer (CEng MICE)",
  organization: "Institution of Civil Engineers",
  date: "2016",
  accent-color: accent,
)

#cv-certification(
  title: "NEC4 Accredited Project Manager",
  organization: "Institution of Civil Engineers",
  date: "2020",
  accent-color: accent,
)

#cv-section("Publications", accent-color: accent)

#cv-publication(
  title: "Adoption barriers for sustainable drainage in retrofit schemes",
  authors: "Okafor M, Rutherford J",
  date: "2023",
  url: "example.com/papers/suds-adoption",
  url_name: "Proceedings of the ICE, Water Management",
  accent-color: accent,
)

#cv-publication(
  title: "Whole-life cost in highway drainage option appraisal",
  authors: "Okafor M",
  date: "2019",
  url_name: "Municipal Engineer, 172(4)",
  accent-color: accent,
)

#cv-section("Awards", accent-color: accent)

#cv-award(
  title: "Regional Project of the Year",
  organization: "ICE Yorkshire and Humber",
  date: "2024",
  description: "For the Aire Valley flood alleviation scheme.",
  accent-color: accent,
)

#cv-section("Skills", accent-color: accent)

*Technical* \
Flood modelling (TUFLOW, InfoWorks ICM), highway design (Civil 3D), NEC4
contract administration, whole-life costing, CDM 2015 designer duties.

*Professional* \
Committee reporting, stakeholder consultation, expert witness experience,
graduate mentoring.
