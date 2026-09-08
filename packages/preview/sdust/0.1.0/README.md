# sdust

Ready-to-use, SDU-branded document frontpages for coursework at the
University of Southern Denmark (Syddansk Universitet) — a title page and
sane base styling for every kind of hand-in, so you can start writing
instead of rebuilding the institutional layout.

![Lecture notes, exercise, and assignment cover pages produced by sdust](https://raw.githubusercontent.com/simo899t/sdust/master/preview.png)

## Quick start

```typst
#import "@preview/sdust:0.1.0": *

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
#import "@preview/sdust:0.1.0": *
#show: page-setup

= First Section
```

## The SDU logo

The SDU logo is a controlled brand asset (`grafiskcenter@sdu.dk`) and is
**not bundled**. No logo is drawn unless you pass one; download it from
SDUnet and hand it in:

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
| `submission` | Lightweight hand-in title card                  |
| `exam`       | Exam submissions                                |

Common named arguments: `title`, `subtitle`, `author` (string or array),
`supervisor`, `course`, `date`, `logo`, `outline`, `outline-depth`.
`thesis` also takes `department:` and `programme:`; `project` takes
`group:`, `abstract:` and `keywords:`; `exam` takes `duration:`,
`student-number:` and more.

## Theorem-style cards

Coloured titled cards for notes and exercises — `theorem`, `definition`,
`example`, `proof` and `corollary`, plus the exercise pair
`question` / `answer`:

```typst
#theorem(title: "Theorem 1.1 (Cheeger)")[
  For a $d$-regular graph, $lambda_2 / 2 <= h(G) <= sqrt(2 lambda_2)$.
]

#definition(title: "Definition 1.2 (Spectral gap)")[
  The _spectral gap_ of $G$ is $gamma = lambda_2 - lambda_1$.
]

#example(title: "Example 1.3")[
  The complete graph $K_n$ has $lambda_2 = n$, so $gamma = n$.
]

#proof[
  Expand the Rayleigh quotient over the space orthogonal to $bold(1)$.
]  // ends with a QED tombstone

#question(title: "Exercise 4")[
  Show that a tree on $n$ vertices has exactly $n - 1$ edges.
]
#answer[
  Induction on $n$. Removing a leaf gives a tree on $n - 1$ vertices
  with, by hypothesis, $n - 2$ edges.
]
```

![theorem, definition, example, proof and question/answer blocks](https://raw.githubusercontent.com/simo899t/sdust/master/cards.png)

The title argument is optional (`#theorem[...]` defaults to "Theorem"),
and `block` gives the plain `QED`-terminated card.

## Also exported

`base-style`, `bib` (Chicago author–date bibliography), `word-count` /
`total-words`, the branding constants `sdu-red` and `sdu-university`, and
the Faculty of Science department names `imada`, `bmb`, `biology`, `fkf`
(pass one as `department:` on `thesis`).

## ACM / CHI papers

sdust does not reproduce the ACM class. For an ACM paper — including CHI
(`format: "manuscript"` for review, `format: "sigconf"` for camera-ready) —
use [`faithful-acmart`](https://typst.app/universe/package/faithful-acmart).

## License

MIT — see [`LICENSE`](LICENSE).
