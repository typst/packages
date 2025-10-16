#import "@preview/upm-report:0.1.0": upm-report

#show: upm-report.with(
  title: "This is an Example Thesis Title That You Should Replace",
  author: "Jane Example Student",
  supervisor: "Prof. Example McSupervisor",
  date: datetime(year: 2025, month: 6, day: 15),

  university: "Universidad Politécnica de Madrid",
  school-name: "E.T.S. de Ingeniería de Sistemas Informáticos",
  school-address: "Campus Sur UPM, Carretera de Valencia (A-3), km. 7\n28031, Madrid, España",
  school-abbr: "ETSISI",
  report-type: "Bachelor's thesis",
  degree-name: "Grado en Ingeniería del Software",

  acknowledgements: "Thanks to my family, friends, and colleagues for their support.",
  abstract-en: "This thesis explores the fascinating world of example topics. It provides insights and analysis on various aspects of the subject matter, aiming to contribute to the existing body of knowledge.",
  keywords-en: "example, thesis, typst, template",

  bibliography-file: "../template/references.bib",
  bibliography-style: "ieee",
)

= Introduction

Hello! This is where your introduction goes. Replace this text with your actual introduction.

You can cite things like this @fakebook2024, and it will appear in your bibliography at the end.

== A Subsection

You can have subsections too. Put your real content here instead of this placeholder text.

Here go some images and tables to show in the lists:

#figure(
  image("assets/placehodler.png", width: 80%),
  caption: [This is my figure caption],
)

#figure(
  image("assets/placehodler.png", width: 80%),
  caption: [This is my figure caption 2],
)

#figure(
  image("assets/placehodler.png", width: 80%),
  caption: [This is my figure caption 3],
)

#figure(
  image("assets/placehodler.png", width: 80%),
  caption: [This is my figure caption 4],
)

#figure(
  table(
    columns: 3,
    [Header 1], [Header 2], [Header 3],
    [Data 1], [Data 2], [Data 3],
  ),
  caption: [This is my table caption],
)

#figure(
  table(
    columns: 3,
    [Header 1], [Header 2], [Header 3],
    [Data 1], [Data 2], [Data 3],
  ),
  caption: [This is my table caption 2],
)
#figure(
  table(
    columns: 3,
    [Header 1], [Header 2], [Header 3],
    [Data 1], [Data 2], [Data 3],
  ),
  caption: [This is my table caption 3],
)
#figure(
  table(
    columns: 3,
    [Header 1], [Header 2], [Header 3],
    [Data 1], [Data 2], [Data 3],
  ),
  caption: [This is my table caption 4],
)


== Lists Work Too

Here's how to make a list:

- First item goes here
- Second item goes here
- Third item is also here

And numbered lists:

+ Step one of something
+ Step two of something
+ Step three of something

= Literature Review

This is where you'd discuss what other people have written about your topic @anotherfakebook2023.

You can have *bold text* and _italic text_ and even `code snippets` if you need them.

= Methodology

Explain how you did your work here. This section should describe your approach in detail.

== Your Subsection Title

Replace this with your actual methodology content.

= Results

Present your findings in this chapter. You could include tables, figures, and analysis here.

= Discussion

Discuss what your results mean and compare them with other work @yetanotherfake2022.

= Conclusions

Summarize your work and its contributions here.

== Future Work

Describe what could be done next to extend this work.
