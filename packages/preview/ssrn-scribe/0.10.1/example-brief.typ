#import "@preview/ssrn-scribe:0.10.1": paper

#show: paper.with(
  meta: (
    title: [Quiet Floors, Longer Sessions?],
    subtitle: [A pilot study of library soundscapes],
    authors: (
      (
        name: "Maya Chen",
        affiliation: "Northbridge University",
        email: "maya.chen@example.edu",
        note: "Corresponding author. All names, institutions, and results in this example are fictional.",
      ),
      (
        name: "Elias Hart",
        affiliation: "Northbridge University",
      ),
    ),
    date: "June 2026",
    abstract: [
      This fictional crossover pilot examines whether quieter library zones are
      associated with longer uninterrupted study sessions. Forty-eight
      volunteers completed matched reading tasks in quiet and conversational
      sound conditions. The example demonstrates an inline title, concise
      front matter, and the default academic typography.
    ],
    keywords: [library soundscapes, sustained attention, crossover design],
  ),
  theme: (
    font: ("Times New Roman", "Libertinus Serif"),
    heading-font: ("Times New Roman", "Libertinus Serif"),
  ),
  layout: (
    maketitle: false,
    density: "balanced",
  ),
)

= Introduction

University libraries increasingly divide space into quiet, collaborative, and
mixed-use zones. These labels are easy to understand, but their relationship
to sustained study is rarely measured under comparable task conditions. This
pilot asks whether the same reader works for longer before taking a break when
ambient conversation is reduced.

= Study design

Each participant completes two twenty-minute reading sessions one week apart.
The order of the quiet and conversational conditions is randomized. The primary
outcome is uninterrupted reading time; secondary outcomes are comprehension and
self-reported effort. Room temperature, illumination, and task difficulty are
held constant across sessions.

= Analysis plan

The primary estimate is the within-participant difference in uninterrupted
reading time. We would report the mean difference with a confidence interval,
inspect order effects, and repeat the analysis after excluding sessions with
technical interruptions. Because the sample is small and drawn from volunteers,
the study is descriptive rather than population-representative.

= Limitations

Short laboratory-style sessions cannot reproduce the full social context of a
library visit. A larger follow-up should include longer tasks, multiple campuses,
and direct measurement of the acoustic environment.
