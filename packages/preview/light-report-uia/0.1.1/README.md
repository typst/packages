# light-report-uia
Unofficial report template for reports at the University of Agder.

Supports both norwegian and english.

Usage:
```
#import "@preview/light-report-uia:0.1.1": report

// CHANGE THESE
#show: report.with(
  title: "New project",
  authors: (
    "Lars Larsen",
    "Lise Lisesen",
    "Knut Knutsen",
  ),
  group-name: "Group 14",
  course-code: "IKT123-G",
  course-name: "Course name",
  date: "august 2024",
  lang: "en", // use "no" for norwegian
  references: bibliography("references.yml"),
)
// then do anything
```