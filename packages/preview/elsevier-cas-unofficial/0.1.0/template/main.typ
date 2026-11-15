#import "@preview/elsevier-cas-unofficial:0.1.0": *

#show: article.with(
  // "dc" for double-column journals (cas-dc), "sc" for single-column (cas-sc)
  layout: "dc",
  title: [Title of the article],
  // Running head and the author part of the footer
  short-title: [Short title],
  short-authors: [F. Author et al.],
  // Notes attached to the title, marked ⋆, ⋆⋆, ...
  title-notes: ([This work was funded by the Example Research Council.],),
  authors: (
    (
      name: "First Author",
      affiliations: 1, // ids from `affiliations`, printed as letters a, b, ...
      corresponding: true, // mark ∗, text given by `corresponding-notes`
      footnotes: 1, // numbers of `author-notes`
      email: "first.author@example.org",
      orcid: "0000-0000-0000-0000",
      credit: [Conceptualization, Methodology, Writing -- original draft],
    ),
    (
      name: "Second Author",
      affiliations: (1, 2),
      email: "second.author@example.org",
      credit: [Software, Writing -- review & editing],
    ),
  ),
  affiliations: (
    "1": (
      organization: [Department of Physics, Example University],
      addressline: [1 Example Street],
      city: [Example City],
      postcode: [12345],
      country: [Country],
    ),
    "2": [Example Institute, Other City, Country],
  ),
  author-notes: ([Present address: Example Laboratory, Country.],),
  abstract: [
    State briefly the purpose of the research, the principal results and the
    main conclusions. The abstract should be understandable on its own.
  ],
  keywords: ([First keyword], [Second keyword], [Third keyword]),
  // Research highlights and graphical abstract, each on its own page
  // highlights: ([First highlight], [Second highlight], [Third highlight]),
  // graphical-abstract: image("graphical-abstract.png"),
)

// Theorem-like environments, if needed
#let theorem = new-theorem("theorem", [Theorem])
#let lemma = new-theorem("lemma", [Lemma], counter: "theorem")
#let definition = new-definition("definition", [Definition])
#let proof = new-proof("proof", [Proof])

= Introduction <sec:intro>

Introduce the problem and review previous work @shannon1948. Cite with
`@key`, refer to sections, figures, tables and equations with `@label`.

= Methods

== A subsection

Display equations are numbered and aligned to the left:
$ H = - sum_i p_i log p_i $ <eq:entropy>
where $p_i$ is the probability of the $i$-th outcome. Refer to it as
@eq:entropy.

#figure(
  rect(width: 100%, height: 3cm, stroke: 0.5pt + gray),
  // image("figure.png", width: 100%),
  caption: [Caption of the figure.],
) <fig:example>

#figure(
  caption: [Caption of the table.],
  // @typstyle off
  table(
    columns: 3,
    toprule,
    [Column 1], [Column 2], [Column 3],
    midrule,
    [a], [b], [c],
    [d], [e], [f],
    bottomrule,
  ),
) <tab:example>

= Results

Describe the results, e.g. in @fig:example and @tab:example.

= Conclusions

Summarize the main conclusions.

#show: appendix

= Additional material

Appendix sections are numbered A, B, ...

#print-credits()

#bibliography("refs.bib")

// Author biographies, if required by the journal
// #bio(image("photo.jpg"))[Short biography of the first author.]
