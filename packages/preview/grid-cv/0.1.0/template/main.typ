// Grid CV. Replace the details below with your own and delete what you do
// not need; every section here is optional. The accent colour is set once, on
// the line after this comment, and everything picks it up from there.

#import "@preview/grid-cv:0.1.0": *

#let accent = "#2c5f6e"

#show: resume.with(
  author: "Tomas Berg",
  // New Computer Modern ships with Typst, so this renders the same everywhere
  // without installing anything. Any family you have works too.
  font: "New Computer Modern",
  font-size: 10.5pt,
  paper: "a4",
  margin: 1.5cm,
)

#masthead(
  author: "Tomas Berg",
  profession: "Data Analyst",
  accent-color: accent,
  contact: [
    tomas.berg\@example.com
    #h(0.6em) | #h(0.6em) +44 131 496 0412
    #h(0.6em) | #h(0.6em) Edinburgh, UK
    #h(0.6em) | #h(0.6em) #link("https://example.com/tomas")[example.com/tomas]
  ],
)

#cv-section("Profile", accent-color: accent)

Analyst working where reporting meets forecasting, mostly for operations teams
who need a number they can act on before the week ends. Comfortable owning a
question from the raw table through to the meeting where it gets decided, and
just as happy deleting a report nobody reads as building a new one.

#cv-section("Experience", accent-color: accent)

#grid-entry(
  title: "Data Analyst",
  subtitle: "Ferrier Logistics",
  dates: "2022 - Present",
  location: "Edinburgh, UK",
)[
  - Rebuilt the depot forecasting model, cutting mean absolute error on
    next-week volume from 18% to 7% across 40 sites.
  - Replaced a fortnightly hand-built deck with a self-serve dashboard now used
    by every regional manager, saving roughly two days a month.
  - Found and corrected a duplicate-scan bug that had overstated throughput by
    4% for the previous three quarters.
  - Ran the analytics side of the WMS migration, reconciling 11 years of history.
]

#grid-entry(
  title: "Analyst",
  subtitle: "Northgate Retail Group",
  dates: "2019 - 2022",
  location: "Glasgow, UK",
)[
  - Built the promotional-uplift model the buying team still uses to size orders.
  - Automated the weekly margin pack in SQL and Python, retiring 30 spreadsheets.
  - Trained 12 colleagues to self-serve in the BI tool, halving ad-hoc requests.
  - Set the definitions behind the weekly KPI set, ending a long argument about
    which of three "revenue" figures the board should be looking at.
]

#grid-entry(
  title: "Graduate Analyst",
  subtitle: "Corrigan Insurance",
  dates: "2018 - 2019",
  location: "Glasgow, UK",
)[
  - Supported claims reporting and built the first automated fraud-flag summary.
  - Wrote the SQL style guide the analytics team adopted the following year.
]

#cv-section("Projects", accent-color: accent)

#grid-entry(
  title: "depot-sim",
  subtitle: "Open-source discrete-event simulation for warehouse staffing",
  dates: "2023",
  meta: "Python, 300+ stars",
)[
  - Models shift patterns against forecast volume so planners can test a roster
    before committing to it.
]

#cv-section("Education", accent-color: accent)

#grid-entry(
  title: "University of Edinburgh",
  subtitle: "MSc Statistics with Data Science",
  dates: "2017 - 2018",
  location: "Edinburgh, UK",
)[]

#grid-entry(
  title: "University of Glasgow",
  subtitle: "BSc Mathematics",
  dates: "2014 - 2017",
  location: "Glasgow, UK",
)[]

#cv-section("Certifications", accent-color: accent)

#grid-entry(
  title: "Professional Data Engineer",
  subtitle: "Google Cloud",
  dates: "2023",
)[]

#cv-section("Skills", accent-color: accent)

#skill-grid((
  "SQL and window functions",
  "Python: pandas, scikit-learn",
  "dbt and Airflow",
  "BigQuery and Postgres",
  "Power BI and Looker",
  "Forecasting and time series",
  "Experiment design",
  "Git and code review",
  "Statistical modelling in R",
  "Stakeholder reporting",
))

#cv-section("Languages", accent-color: accent)

#grid-language(language: "English", level: "Native")
#grid-language(language: "Swedish", level: "Fluent")
#grid-language(language: "French", level: "Conversational")
