// Sample article for the elsevier-cas-unofficial template, ported from Elsevier's
// cas-dc-sample.tex. Set `layout: "sc"` for the single-column format.
#import "@preview/elsevier-cas-unofficial:0.1.0": *

#show: article.with(
  layout: "dc",
  title: [This is a specimen $a_b$ title],
  short-title: [Leveraging social media news],
  short-authors: [J.K. Krishnan et al.],
  title-notes: (
    [This document is the results of the research project funded by the National Science Foundation.],
    [The second title footnote which is a longer text matter to fill through the whole text width and overflow into another line in the footnotes area of the first page.],
  ),
  authors: (
    (
      name: "J.K. Krishnan",
      affiliations: (1, 3),
      prefix: [Sir],
      role: [Researcher],
      orcid: "0000-0001-0000-0000",
      corresponding: 1,
      footnotes: 1,
      email: "jkk@example.in",
      url: "www.jkkrishnan.in",
      credit: [Conceptualization of this study, Methodology, Software],
    ),
    (name: "Han Thane", affiliations: (2, 4), style: "chinese"),
    (
      name: (given: "William", family: "J. Hansen"),
      affiliations: (2, 3),
      role: [Co-ordinator],
      suffix: [Jr],
      footnotes: 2,
      email: "wjh@example.org",
      url: "https://www.university.org",
      credit: [Data curation, Writing - Original draft preparation],
    ),
    (
      name: "T. Rafeeq",
      affiliations: (1, 3),
      corresponding: 2,
      footnotes: (1, 3),
      email: "t.rafeeq@example.in",
      url: "www.campus.in",
    ),
  ),
  affiliations: (
    "1": (
      organization: [Department of Physics, J.K. Institute of Science],
      addressline: [Jawahar Nagar],
      city: [Trivandrum],
      // citysep: none, // uncomment if no comma is needed between city and postcode
      postcode: [695013],
      state: [Kerala],
      country: [India],
    ),
    "2": (
      organization: [World Scientific University],
      addressline: [Street 29],
      postcode: [1011 NX],
      postcodesep: none,
      city: [Amsterdam],
      country: [The Netherlands],
    ),
    "3": (
      organization: [University of Intelligent Studies],
      addressline: [Street 15],
      city: [Jabaldesh],
      postcode: [825001],
      state: [Orissa],
      country: [India],
    ),
  ),
  corresponding-notes: (
    [Corresponding author],
    [Principal corresponding author],
  ),
  author-notes: (
    [This is the first author footnote, but is common to third author as well.],
    [Another author footnote, this is a very long footnote and it should be a really long footnote. But this footnote is not yet sufficiently long enough to make two lines of footnote text.],
  ),
  nonum-notes: (
    [This note has no numbers. In this work we demonstrate $a_b$ the formation Y\_1 of a new type of polariton on the interface between a cuprous oxide slab and a polystyrene micro-sphere placed on the slab.],
  ),
  abstract: [
    This template helps you to create a properly formatted Typst manuscript. \
    `abstract: [...]` and `keywords: (...)` contain the abstract and keywords respectively. \
    Each keyword is a separate entry of the `keywords` array.
  ],
  keywords: (
    [quadrupole exciton],
    [polariton],
    [#smallcaps[wgm]],
    [#smallcaps[bec]],
  ),
  graphical-abstract: image("figs/cas-grabs.pdf"),
  highlights: (
    [Research highlights item 1],
    [Research highlights item 2],
    [Research highlights item 3],
  ),
)

#let theorem = new-theorem("theorem", [Theorem])
#let lemma = new-theorem("lemma", [Lemma], counter: "theorem")
#let rmk = new-definition("rmk", [Remark])
#let pf = new-proof("pf", [Proof])

= Introduction

The Elsevier cas-dc class is based on the standard article class and supports almost all of the functionality of that class. In addition, it features commands and options to format the

- document style
- baselineskip
- front matter
- keywords and MSC codes
- theorems, definitions and proofs
- lables of enumerations
- citation style and labeling.

This template depends on the following packages for its proper functioning:

+ `elsevier-cas-unofficial` for the page layout and front matter;
+ Typst's built-in `bibliography` for citation processing;
+ the `fleqn` option for left aligned equations;
+ `image` for graphics inclusion;
+ `link` if hyperlinking is required in the document;

All the above are part of any standard Typst installation. Therefore, the users need not be bothered about downloading any extra packages.

= Installation

The package is available on Typst Universe as `@preview/elsevier-cas-unofficial`. Create a new project from the template with `typst init @preview/elsevier-cas-unofficial`, or import it with `#import "@preview/elsevier-cas-unofficial:0.1.0": *` in an existing document. The LaTeX original is available at the author resources page at Elsevier (http://www.elsevier.com/locate/latex).

= Front matter

The author names and affiliations could be formatted in two ways:
#enum(numbering: "(1)")[Group the authors per affiliation.][
  Use footnotes to indicate the affiliations.
]
See the front matter of this document for examples. You are recommended to conform your choice to the journal you are submitting to.

= Bibliography styles

There are various bibliography styles available. You can select the style of your choice with `#set bibliography(style: ...)`. These styles are Elsevier styles based on standard styles like Harvard and Vancouver. Please use a BibTeX or Hayagriva file to generate your bibliography and include DOIs whenever available.

Here are two sample references: @Fortunato2010; @Fortunato2010 @NewmanGirvan2004; @Fortunato2010 @Vehlowetal2013.

= Floats

Figures may be included using the function `image` in combination with or without its several options to further control graphic. Typst accepts figures in the PNG, JPEG, GIF, SVG, WebP and PDF formats.

#figure(
  image("figs/cas-munnar-2024.jpg", width: 90%),
  caption: [The beauty of Munnar, Kerala. (See also @tbl1).],
) <FIG:1>

The `table` function is handy for marking up tabular material. The `toprule`, `midrule` and `bottomrule` helpers draw booktabs-style rules.

#figure(
  caption: [This is a test caption. This is a test caption. This is a test caption. This is a test caption. Use `scope: "parent"` if you want a two column spanned table.],
  // Like `\begin{table}[width=.9\linewidth]`: the caption takes the width
  // of the block around the table.
  block(width: 90%, table(
    columns: 4 * (1fr,),
    toprule,
    [Col 1], [Col 2], [Col 3], [Col4],
    midrule,
    ..range(5).map(_ => ([12345], [12345], [123], [12345])).flatten(),
    bottomrule,
  )),
) <tbl1>

= Theorem and theorem like environments

`elsevier-cas-unofficial` provides a few shortcuts to format theorems and theorem-like environments with ease. It provides three functions to define theorem or theorem-like environments:

```typ
#let theorem = new-theorem(
  "theorem", [Theorem])
#let lemma = new-theorem(
  "lemma", [Lemma], counter: "theorem")
#let rmk = new-definition("rmk", [Remark])
#let pf = new-proof("pf", [Proof])
```

The `new-theorem` function formats a theorem in LaTeX's default style with italicized font, bold font for theorem heading and theorem number at the right hand side of the theorem heading. It also optionally accepts a `title` which will be printed as an extra heading in parentheses.

```typ
#theorem[
  For system (8), consensus can be achieved with
  $norm(T_(omega z)) ...$
  $ .... $
] <thm1>
```

#theorem[
  For system (8), consensus can be achieved with $norm(T_(omega z)) ...$
  $ .... $ <eq10>
] <thm1>

The `new-definition` function is the same in all respects as its `new-theorem` counterpart except that the font shape is roman instead of italic. Both `new-definition` and `new-theorem` automatically define counters for the environments defined, and the environments can be referenced: see @thm1.

#rmk[This is a remark, typeset upright.]

The `new-proof` function defines proof environments with upright font shape. No counters are defined.

#pf(title: [of @thm1])[The proof is left to the reader. #qed]

#figure(
  image("figs/cas-munnar-2024.jpg", width: 90%),
  caption: [The beauty of Munnar, Kerala. (See also @tbl1).],
  placement: top,
  scope: "parent",
) <FIG:2>

= Enumerated and Itemized Lists

Typst's `enum` function accepts a `numbering` pattern, so that you can change the list counter type and its attributes.

```typ
#set enum(numbering: "1.")
+ The item counter is suffixed
  by a period.
+ Use `a)` for alphabetical and
  `(i)` for roman counters.
  #set enum(numbering: "a)")
  + Another level of list.
  + One more item.
```

Further, the numbering pattern allows one to prefix a string like "Step" to all the item numbers.

```typ
#set enum(numbering: "Step 1.")
+ This is the first step.
+ Obviously this is the second step.
+ The final step.
```

= Cross-references

In electronic publications, articles may be internally hyperlinked. Hyperlinks are generated from proper cross-references in the article. For example, the words #text(fill: luma(20%))[Fig. 1] will never be more than simple text, whereas the proper cross-reference `@FIG:1` may be turned into a hyperlink to the figure itself: @FIG:1. In the same way, the words #text(fill: blue)[Ref. [1]] will fail to turn into a hyperlink; the proper cross-reference is `@Fortunato2010`. Cross-referencing is possible in Typst for sections, subsections, formulae, figures, tables, and literature references.

= Bibliography

The bibliography style is set with `#set bibliography(style: ...)`. The template defaults to `"elsevier-harvard"` (author–year), the scheme of `cas-model2-names.bst`; this sample uses the numbered `"elsevier-with-titles"` style.

In the author–year scheme, the citation forms of Typst's `cite` function give the natbib variants:

- Parenthetical: `@WB96` produces (Wettig & Brown, 1996).
- Textual: `#cite(<ESG96>, form: "prose")` produces Elson et al. (1996).
- An affix and part of a reference: `@Gea97[Ch. 2]` produces (Governato et al., 1997, Ch. 2).

In the numbered scheme of citation, `@<label>` is used, since the textual forms have no relevance in the numbered scheme.

#show: appendix

= My Appendix

Appendix sections are started with `#show: appendix`.

`#print-credits()` is used after appendix sections to list author credit taxonomy contribution roles given as `credit` in the author list.

#print-credits()

#bibliography("refs.bib", style: "elsevier-with-titles")

#bio[
  Author biography without author photo.
  #range(26).map(_ => [Author biography.]).join(" ")
]

#bio(image("figs/cas-pic1.pdf"))[
  Author biography with author photo.
  #range(26).map(_ => [Author biography.]).join(" ")
]

#bio(image("figs/cas-pic1.pdf"))[
  Author biography with author photo.
  #range(11).map(_ => [Author biography.]).join(" ")
]
