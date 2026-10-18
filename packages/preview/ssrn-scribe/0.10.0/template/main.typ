#import "@preview/ssrn-scribe:0.10.0": paper

#show: paper.with(
  meta: (
    title: [Your Paper Title],
    authors: (
      (
        name: "Your Name",
        affiliation: "Your Institution",
        email: "you@example.edu",
      ),
    ),
    abstract: [Briefly state the question, method, main result, and contribution.],
    keywords: [Keyword one, Keyword two, Keyword three],
  ),
  theme: (
    font: ("Times New Roman", "Libertinus Serif"),
    heading-font: ("Times New Roman", "Libertinus Serif"),
  ),
  layout: (
    maketitle: true,
    density: "balanced",
  ),
)

= Introduction
Introduce the research question and explain why it matters.

= Method
Describe the data, design, and analysis.

= Results
Report the main findings.

= Conclusion
Summarize the contribution and its limitations.
