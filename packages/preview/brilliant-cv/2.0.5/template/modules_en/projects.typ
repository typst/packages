// Imports
#import "@preview/brilliant-cv:2.0.5": cvSection, cvEntry
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvEntry = cvEntry.with(metadata: metadata)


#cvSection("Projects & Associations")

#cvEntry(
  title: [Volunteer Data Analyst],
  society: [ABC Nonprofit Organization],
  date: [2019 - Present],
  location: [New York, NY],
  description: list(
    [Analyze donor and fundraising data to identify trends and opportunities for growth],
    [Create data visualizations and dashboards to communicate insights to the board of directors],
    [Collaborate with other volunteers to develop and implement data-driven strategies],
  ),
)
