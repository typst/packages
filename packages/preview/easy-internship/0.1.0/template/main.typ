#import "@preview/easy-internship:0.1.0": report

#show: report.with(
  title: [Internship Report],
  subtitle: [Software Engineering Intern · Spring 2026],
  author: "Jane Doe",
  language: "en",
  school-logo: image("school-logo.svg"),
  company-logo: image("company-logo.svg"),
  keywords: ("internship", "report"),
  bibliography: bibliography("refs.bib"),
)

#heading(numbering: none)[Acknowledgments]
#lorem(60)

= Introduction
This report describes the internship context, the work carried out and the
lessons learned. @activities lists the main tasks.

= Activities <activities>
- Implemented internal tooling
- Wrote technical documentation
- Took part in code reviews

#figure(
  table(
    columns: (2fr, 1fr),
    table.header[*Task*][*Hours*],
    [Development], [120],
    [Documentation], [24],
    [Testing], [18],
  ),
  caption: [Time spent per task.],
)

= Key Learnings
#highlight[Clear documentation] made the biggest difference. Literate
programming @knuth1984 is a good read on the topic.

$ sum_(i=1)^n i = (n(n+1)) / 2 $

= Conclusion
#lorem(40)
