#import "@preview/readable-classic:0.1.0": *

#show: resume.with(
  name: "Olivia Bennett",
  contact: (
    "Providence, RI",
    "(401) 555-0132",
    "olivia.bennett@example.com",
    "linkedin.com/in/oliviabennett",
  ),
  // "a4" also works; the margins switch to 15 mm.
  paper: "us-letter",
)

= Education

#education(
  school: "Halden College",
  location: "Providence, RI",
  degree: "Bachelor of Arts in Economics, Minor in Statistics",
  date: "Sep 2022 – May 2026",
)[
  - GPA: 3.8/4.0, Economics Department Honors Program
  - Relevant Coursework: Econometrics, Corporate Finance, Game Theory, Financial Accounting, Data Analysis in Python
]

= Experience

#experience(
  company: "Harlan Quay Capital Partners",
  location: "New York, NY",
  title: "Investment Banking Analyst Intern",
  date: "Jun 2025 – Aug 2025",
)[
  - Built three-statement models for two consumer retail clients and updated comparable company sets each week
  - Drafted 20 pages of a sell-side pitch book, including the industry overview and buyer list
  - Checked a 40-tab merger model line by line before it went to the client and found a circular reference in debt schedules
]

#experience(
  company: "Halden College Department of Economics",
  location: "Providence, RI",
  title: "Research Assistant",
  date: "Jan 2024 – May 2025",
)[
  - Cleaned and merged 15 years of county wage data in Stata for a professor's study on minimum wage spillovers
  - Wrote summary tables and charts that appeared in a working paper presented at two conferences
]

#experience(
  company: "Halden College Writing Center",
  location: "Providence, RI",
  title: "Peer Tutor",
  date: "Sep 2023 – Dec 2024",
)[
  - Met with about eight students a week to work on essays, lab reports and cover letters
  - Led two workshops on writing clear policy memos for first-year economics students
]

= Projects & Activities

#activity(
  name: "Halden Investment Club",
  role: "Vice President",
  date: "Sep 2023 – Present",
)[
  - Run weekly stock pitch meetings for 45 members and manage a \$25,000 student portfolio with four sector heads
  - Started a mentoring program that paired 18 first-year members with alumni working in finance
]

#activity(
  name: "Halden Habitat Builders",
  role: "Volunteer Coordinator",
  date: "Sep 2022 – May 2024",
)[
  - Organized monthly build days for about 30 volunteers and kept the sign-up and safety records
]

= Skills

#skills((
  Technical: "Excel, PowerPoint, Python (pandas), Stata, Capital IQ",
  Certifications: "Bloomberg Market Concepts, Wall Street Prep Financial Modeling",
  Languages: "French (fluent), Spanish (basic)",
))
