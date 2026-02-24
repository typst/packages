# clean-acmart

This template is intended for submitting papers to ACM conferences, include SOSP, EuroSys, ASPLOS, etc.

## Usage

You can use this template in the Typst web app by clicking "Start from template" on the dashboard and searching for `clean-acmart`.

Alternatively, you can use the CLI to kick this project off using the command

```
typst init @preview/clean-acmart:0.0.1
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

The template will initialize your package with a sample call to the `acmart` function in a show rule. If you want to change an existing project to use this template, you can add a show rule like this at the top of your file:

```typ
#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string

#let cuhk = super(sym.suit.spade)
#let title = [
  Insert Your Title Here∗
]
#let authors = (
  // You can use grouped affiliations with mark
  (
    name: [Junliang Hu],
    email: [jlhu\@cse.cuhk.edu.hk],
    mark: cuhk,
  ),
  (
    // Should I use string or content? It doesn't matter
    name: "FirstName1 Surname1",
    email: "email1@email.com",
    mark: super(sym.suit.diamond),
  ),
  (
    // Should I use string or content? It doesn't matter
    name: "FirstName2 Surname2",
    email: "email2@email.com",
    mark: super(sym.suit.diamond),
  ),
  // Or you can put affiliations directly in the author list
  // (
  //   name: [FirstName Surname],
  //   email: [email\@email.com],
  //   // You can put any thing here, and they will automatically be appended below the author name
  //   department: [Department of Computer Science and Engineering],
  //   institute: [The Chinese University of Hong Kong],
  //   city: [Hong Kong],
  // ),
)
#let affiliations = (
  (
    name: [The Chinese University of Hong Kong],
    mark: cuhk,
    department: [Department of Computer Science and Engineering],
    // You can put any thing here, and they will automatically be appended below
    // city: [Hong Kong],
  ),
  (
    name: [Institution/University Name],
    mark: super(sym.suit.diamond),
    department: [Department Name],
  ),
  // More affiliations
)
#let conference = (
  name:  [ACM SIGOPS 31th Symposium on Operating Systems Principles],
  short: [SOSP ’25],
  year:  [2025],
  date:  [October 13–16],
  venue: [Seoul, Republic of Korea],
)
#let doi = "https://doi.org/10.1145/0000000000"
#let ccs = (
  (
    generic: [Software and its engineering],
    specific: ([Virtual machines], [Virtual memory], ),
  ),
  (
    generic: [Computer systems organization],
    specific: ([Heterogeneous (hybrid) systems], ),
  ),
)
#let keywords = ("Virtual machine", "Virtual memory", "Operating system", )

#show: acmart.with(
  title: title,
  authors: authors,
  affiliations: affiliations,
  conference: conference,
  doi: doi,
  copyright: "cc",
  // Set review to submission ID for the review process or to "none" for the final version.
  // review: [\#001],
)


= Abstract
The process of scientific writing is often tangled up with the intricacies of typesetting, leading to frustration and wasted time for researchers. In this paper, we introduce Typst, a new typesetting system designed specifically for scientific writing.
Typst untangles the typesetting process, allowing researchers to compose papers faster. In a series of experiments we demonstrate that Typst offers several advantages, including faster document creation, simplified syntax, and increased ease-of-use.

#acmart-ccs(ccs)
#acmart-keywords(keywords)
#acmart-ref(to-string(title), authors, conference, doi)

= Introduction
Scientific writing is a crucial part of the research process, allowing researchers to share their findings with the wider scientific community. However, the process of typesetting scientific documents can often be a frustrating and time-consuming affair, particularly when using outdated tools such as LaTeX. Despite being over 30 years old, it remains a popular choice for scientific writing due to its power and flexibility. However, it also comes with a steep learning curve, complex syntax, and long compile times, leading to frustration and despair for many researchers @netwok2020 @netwok2022.

== Paper overview
In this paper we introduce Typst, a new typesetting system designed to streamline the scientific writing process and provide researchers with a fast, efficient, and easy-to-use alternative to existing systems. Our goal is to shake up the status quo and offer researchers a better way to approach scientific writing.

By leveraging advanced algorithms and a user-friendly interface, Typst offers several advantages over existing typesetting systems, including faster document creation, simplified syntax, and increased ease-of-use.

To demonstrate the potential of Typst, we conducted a series of experiments comparing it to other popular typesetting systems, including LaTeX. Our findings suggest that Typst offers several benefits for scientific writing, particularly for novice users who may struggle with the complexities of LaTeX. Additionally, we demonstrate that Typst offers advanced features for experienced users, allowing for greater customization and flexibility in document creation.

Overall, we believe that Typst represents a significant step forward in the field of scientific writing and typesetting, providing researchers with a valuable tool to streamline their workflow and focus on what really matters: their research. In the following sections, we will introduce Typst in more detail and provide evidence for its superiority over other typesetting systems in a variety of scenarios.

= Methods <sec:methods>
#set math.equation(numbering: "1.")
#lorem(45)

$ a + b = gamma $ <eq:gamma>

#lorem(80)

#figure(
  placement: none,
  circle(radius: 15pt),
  caption: [A circle representing the Sun.]
) <fig:sun>

In @fig:sun you can see a common representation of the Sun, which is a star that is located at the center of the solar system.

#lorem(120)

#figure(
  caption: [The Planets of the Solar System and Their Average Distance from the Sun],
  placement: top,
  table(
    columns: (6em, auto),
    align: (left, right),
    inset: (x: 8pt, y: 4pt),
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },

    table.header[Planet][Distance (million km)],
    [Mercury], [57.9],
    [Venus], [108.2],
    [Earth], [149.6],
    [Mars], [227.9],
    [Jupiter], [778.6],
    [Saturn], [1,433.5],
    [Uranus], [2,872.5],
    [Neptune], [4,495.1],
  )
) <tab:planets>

In @tab:planets, you see the planets of the solar system and their average distance from the Sun.
The distances were calculated with @eq:gamma that we presented in @sec:methods.

#lorem(240)

#lorem(240)

= Acknowledgement
#lorem(20)

#bibliography("refs.bib", title: "References", style: "association-for-computing-machinery")

#colbreak(weak: true)
#set heading(numbering: "A.a.a")

= Artifact Appendix
In this section we show how to reproduce our findings.
```
