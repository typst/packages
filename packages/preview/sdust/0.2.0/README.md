# sdust

Ready-to-use, SDU-branded document frontpages for coursework at the
University of Southern Denmark (Syddansk Universitet), a title page and page setup for every kind of hand-in.

![Thesis, lecture-note, exercise and assignment cover pages produced by sdust](https://raw.githubusercontent.com/simo899t/sdust/6c20cbe78d53dfde5d88046bb29b4d58843cd669/preview.png)

## Quick start

```typst
#import "@preview/sdust:0.2.0": *

#show: note.with(
  title:  "Analysis & Topology",
  course: "MM537 — Metric Spaces",
  author: "Firstname Lastname",
  date:   "Autumn 2026",
)

= Open and closed sets
Your content here.
```

Every template renders an A4 cover page in the SDU layout with the SDU red
accent, sets up 1.5 line spacing, numbered headings and a centred
`current/total` page number, and (optionally) an outline.

Want the styling without a cover page? Use `page-setup`:

```typst
#import "@preview/sdust:0.2.0": *
#show: page-setup

= First Section
```

## The logo

The SDU logo is a controlled brand asset and is therefore
**not bundled**. No logo is drawn unless you pass one, one can download it from
SDUs own website:

```typst
#show: thesis.with(
  logo: image("sdu-logo.png", width: 12em),
  // ...
)
```

`logo: none` (the default) omits it entirely.

## Templates

| Function     | For                                             |
| ------------ | ----------------------------------------------- |
| `page-setup` | Base styling only, no cover page                |
| `thesis`     | Bachelor's / Master's thesis title page         |
| `note`       | Lecture notes                                   |
| `exercise`   | Exercise sheets                                 |
| `assignment` | Assignments                                     |
| `project`    | Group / solo project reports                    |
| `basic`      | Just title, authors and date, no cover page     |
| `submission` | Lightweight hand-in title card                  |
| `exam`       | Exam submissions                                |
| `research`   | arXiv/ICML-style paper, two columns by default  |

Common named arguments: `title`, `subtitle`, `author` (string or array),
`supervisor`, `course`, `date`, `logo`, `outline`, `outline-depth`.
`thesis` also takes `department:` and `programme:`; `project` takes
`group:`, `abstract:`, `keywords:`, `info-width:` and `author-dots:`;
`research` takes `affiliations:` (array), `abstract:`, `keywords:`,
`columns:`, `running-title:` and `repo:` (URL), and authors as dicts
`(name:, affiliation: 1 | (1, 2), equal: true, email:)`; `exam` takes `duration:`,
`student-number:` and more.

See the [**manual (PDF)**](https://github.com/simo899t/sdust/blob/6c20cbe78d53dfde5d88046bb29b4d58843cd669/docs/manual.pdf) for every parameter of every template and block, with defaults.

## Page cards

Coloured titled cards for notes and exercises — `theorem`, `definition`,
`example`, `proof` and `corollary`, plus exercise pair
`question` / `answer`:

```typst
#theorem(title: "Theorem 1.1 (Cheeger)")[
  For a $d$-regular graph, $lambda_2 / 2 <= h(G) <= sqrt(2 lambda_2)$.
]

#definition(title: "Definition 1.2 (Spectral gap)")[
  The _spectral gap_ of $G$ is 
  #boxed[$ gamma = lambda_2 - lambda_1 $].
]

#example(title: "Example 1.3")[
  The complete graph $K_n$ has $lambda_2 = n$, so $gamma = n$.
]

#proof[
  Expand the Rayleigh quotient over the space orthogonal to $bold(1)$. #QED
]

#question(title: "Exercise 4")[
  Show that a tree on $n$ vertices has exactly $n - 1$ edges.
]
#answer[
  Induction on $n$. Removing a leaf gives a tree on $n - 1$ vertices
  with, by hypothesis, $n - 2$ edges.
]
```

![theorem, definition, example, proof and question/answer blocks](https://raw.githubusercontent.com/simo899t/sdust/6c20cbe78d53dfde5d88046bb29b4d58843cd669/cards.png)

The title argument is optional (`#theorem[...]` defaults to "Theorem").

The cards use fixed light fills and are meant for print / PDF; they do not
adapt to a dark editor preview.

## Boxing an equation

`boxed` frames a key result. A block equation is centred like a normal
display equation; anything else is framed inline. Optional `fill:`,
`stroke:` (thickness), `stroke-color:`, `inset:`, `radius:`.

```typst
#boxed($ e^(i pi) + 1 = 0 $)

the bound #boxed($O(n log n)$) is tight

#boxed(fill: rgb("#fff8e1"), $ sum_(k=1)^n k = (n(n+1)) / 2 $)
```

## Also exported

`base-style`, `bib` (Chicago author–date bibliography), `word-count` /
`total-words`, the branding constants `sdu-red` and `sdu-university`, and
the Faculty of Science department names `imada`, `bmb`, `biology`, `fkf`
(pass one as `department:` on `thesis`).

## ACM / CHI papers

sdust does not reproduce the ACM class. For an ACM paper, including CHI
(`format: "manuscript"` for review, `format: "sigconf"` for camera-ready) —
use [`faithful-acmart`](https://typst.app/universe/package/faithful-acmart).

## License

MIT — see [`LICENSE`](LICENSE).
