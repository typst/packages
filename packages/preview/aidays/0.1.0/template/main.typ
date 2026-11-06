// Copyright 2026 Olivier D'Ancona (@ODAncona).
// SPDX-License-Identifier: MIT-0
#import "@preview/aidays:0.1.0": *

#let accepted = sys.inputs.at("accepted", default: "false") == "true"
#show: aidays.with(
  title: [Your Paper Title],
  short-title: [Your Short Paper Title],
  accepted: accepted,
  font: sys.inputs.at("font", default: "Times New Roman"),
  authors: (
    (name: "First Author", affiliations: ("university",),
      email: "first.author@example.org", corresponding: true),
    (name: "Second Author", affiliations: ("university", "company")),
  ),
  affiliations: (
    university: [Department, University, City, Region, Country],
    company: [Company, City, Region, Country],
  ),
  keywords: ("artificial intelligence", "machine learning"),
  abstract: [
    Write a self-contained summary of your work in one paragraph. Introduce
    the problem and its motivation. Explain the proposed approach. Present
    your main findings. Describe their significance and scope.
  ],
)

= Introduction
Present the problem, the research context, and your contributions. Cite
relevant work, for example @langley00.

= Method
Explain the approach and provide enough detail for others to reproduce it.

= Experiments
Describe the datasets, baselines, evaluation protocol, and results.

= Conclusion
Discuss what the findings establish and what remains unresolved.

#unnumbered[Limitations]
Describe the limitations of your work.

#unnumbered[Ethical Statement]
Discuss the ethical considerations relevant to your research.

#unnumbered[AI Use Statement]
Disclose whether and how generative AI tools were used, naming the tools and
their tasks. Follow the conference instructions for the declaration if none
were used.

#acknowledgements[
  Thank contributors and acknowledge funding. This block appears only in the
  accepted version.
]

#bibliography("main.bib")

// Optional appendix, included in the same PDF:
// #appendix[
//   = Additional Details
//   Add supplementary proofs, implementation details, or experiments.
// ]
