// Meridian CV. Replace the details below with your own and delete what you do
// not need; every section here is optional. The accent colour is set once, on
// the line after this comment, and everything picks it up from there.

#import "@preview/meridian-cv:0.1.0": *

#let accent = "#33475a"

#show: resume.with(
  author: "Ines Moreau",
  // Libertinus Serif ships with Typst, so this renders the same everywhere
  // without installing anything. Any family you have works too.
  font: "Libertinus Serif",
  font-size: 10.5pt,
  paper: "a4",
  margin: 1.5cm,
)

// The masthead sets flush right; the sections below run flush left. That
// mirrored axis is the design. To fill the empty left side of the header with a
// circular portrait, pass image bytes: `photo: read("portrait.jpg", encoding:
// none)`. A bare path would be resolved inside the package, not next to this file.
#masthead(
  author: "Ines Moreau",
  profession: "Research Fellow in Epidemiology",
  accent-color: accent,
  contact: [
    i.moreau\@example.ac.uk
    #h(0.6em) | #h(0.6em) +44 117 496 0233
    #h(0.6em) | #h(0.6em) Bristol, UK
    #h(0.6em) | #h(0.6em) #link("https://example.ac.uk/moreau")[example.ac.uk/moreau]
  ],
)

#cv-section("Research Interests", accent-color: accent)

Infectious disease modelling, with a focus on how surveillance data behaves when
it is incomplete. Recent work has been on estimating transmission from testing
streams that were never designed to be representative, and on making those
estimates legible to the people who commission them.

#cv-section("Appointments", accent-color: accent)

#meridian-entry(
  title: "Research Fellow",
  subtitle: "Population Health Sciences, University of Bristol",
  dates: "2022 - Present",
  location: "Bristol, UK",
)[
  - Lead modeller on a five-year NIHR programme covering respiratory
    surveillance in England, coordinating four analysts across two sites.
  - Developed the reweighting method now used to correct the programme's
    community testing estimates for differential participation.
  - Supervise two PhD students and one research assistant.
]

#meridian-entry(
  title: "Postdoctoral Researcher",
  subtitle: "MRC Biostatistics Unit, University of Cambridge",
  dates: "2019 - 2022",
  location: "Cambridge, UK",
)[
  - Built the nowcasting pipeline that fed weekly reporting-delay corrections
    into national situational awareness.
  - Co-authored the unit's guidance on communicating uncertainty in short-term
    forecasts, adopted across three subsequent programmes.
]

#cv-section("Education", accent-color: accent)

#meridian-entry(
  title: "PhD Epidemiology",
  subtitle: "London School of Hygiene and Tropical Medicine",
  dates: "2015 - 2019",
  location: "London, UK",
  meta: "Thesis: Estimating transmission from partially observed testing data",
)[]

#meridian-entry(
  title: "MSc Medical Statistics",
  subtitle: "University of Leeds",
  dates: "2014 - 2015",
  location: "Leeds, UK",
)[]

#cv-section("Selected Publications", accent-color: accent)

#meridian-entry(
  title: "Reweighting non-representative community testing streams",
  subtitle: "Moreau I, Achebe N, Lindqvist P",
  dates: "2024",
  meta: "Epidemiology and Infection, 152, e44",
)[]

#meridian-entry(
  title: "Reporting delay and the shape of the epidemic curve",
  subtitle: "Moreau I, Hartley S",
  dates: "2022",
  meta: "Statistics in Medicine, 41(18), 3502",
)[]

#meridian-entry(
  title: "Communicating uncertainty in short-term epidemic forecasts",
  subtitle: "Hartley S, Moreau I, Okonjo A",
  dates: "2021",
  meta: "Journal of the Royal Statistical Society A, 184(3), 891",
)[]

#cv-section("Grants and Awards", accent-color: accent)

#meridian-entry(
  title: "NIHR Advanced Fellowship",
  subtitle: "National Institute for Health and Care Research",
  dates: "2023",
  meta: "GBP 1.1M, principal investigator",
)[]

#meridian-entry(
  title: "Early Career Prize",
  subtitle: "Royal Statistical Society, Medical Section",
  dates: "2021",
)[]

#cv-section("Teaching", accent-color: accent)

#meridian-entry(
  title: "Statistical Modelling for Public Health",
  subtitle: "MSc module lead, University of Bristol",
  dates: "2023 - Present",
)[]

#meridian-entry(
  title: "Introduction to Infectious Disease Modelling",
  subtitle: "Short course convenor, Bristol Medical School",
  dates: "2022 - Present",
)[]

#cv-section("Service", accent-color: accent)

#meridian-entry(
  title: "Associate Editor",
  subtitle: "Epidemics",
  dates: "2023 - Present",
)[]

#meridian-entry(
  title: "Reviewer",
  subtitle: "Lancet Public Health, Statistics in Medicine, Epidemics",
  dates: "2020 - Present",
)[]

#cv-section("Languages", accent-color: accent)

#meridian-language(language: "French", level: "Native")
#meridian-language(language: "English", level: "Fluent")
#meridian-language(language: "Portuguese", level: "Conversational")
