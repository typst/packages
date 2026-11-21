#import "@preview/ucph-lehmann-thesis:0.1.0" as ul
// The requirements for what a thesis must contain vary between programmes.
// Check the rules at your own study office before you submit.

#show: ul.thesis.with(
  lang: "en", // "en" or "da"
  type: [Master's thesis], // e.g. [Bachelor's project], [PhD thesis], [Speciale]
  title: [Title of the thesis],
  subtitle: [Subtitle],
  authors: ((name: "Your Name", id: "abc123"),), // `id` is optional (KU-id or exam number)
  advisors: ("Advisor Name",),
  date: datetime.today(),
  faculty: [Faculty of Social Sciences],
  department: [Department of Economics],
  description: [A one-sentence description of the thesis.],
  // cover-image: image("cover.jpg"),
  abstracts: (
    en: [#lorem(120)],
    da: [#lorem(120)],
  ),
  // preface: [#lorem(80)],
  character-count: true,
  // list-of-figures: true,
  // list-of-tables: true,
  // twoside: true, // for double-sided printing (chapters start on odd pages, good if your thesis needs to be printed as a book)
)

= Introduction

#lorem(80) A reference looks like this: @boserup1965.

== Background

#lorem(120)

= Data and method

#lorem(100)

$ y_(i t) = alpha_i + x_(i t) beta + epsilon_(i t) $ <eq:model>

@eq:model is numbered within the chapter.

= Results

#figure(
  rect(width: 80%, height: 40mm, fill: luma(235), stroke: none),
  caption: [A placeholder figure.],
) <fig:placeholder>

#lorem(100)

= Conclusion

#lorem(100)

#bibliography("refs.bib", style: "harvard-cite-them-right")

#show: ul.appendix

= Additional tables

#lorem(60)
