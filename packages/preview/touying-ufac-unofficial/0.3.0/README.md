# touying-ufac-unofficial

<p align="center">
  <a href="https://typst.app/universe/package/touying-ufac-unofficial"><img src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Flucaslrodri%2Ftouying-ufac-unofficial%2Fmain%2Ftypst.toml&amp;query=%24.package.version&amp;label=Typst%20Universe&amp;logo=typst&amp;color=239dad" alt="Version on Typst Universe"></a>
  <a href="https://github.com/lucaslrodri/touying-ufac-unofficial/blob/v0.3.0/docs/manual.pdf"><img src="https://img.shields.io/badge/manual-PDF-orange" alt="Manual (PDF)"></a>
  <a href="https://typst.app/"><img src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Flucaslrodri%2Ftouying-ufac-unofficial%2Fmain%2Ftypst.toml&amp;query=%24.package.compiler&amp;prefix=%E2%89%A5%20&amp;label=Typst&amp;logo=typst&amp;color=239dad" alt="Minimum Typst version"></a>
  <a href="https://typst.app/universe/package/touying"><img src="https://img.shields.io/badge/Touying-0.7.4-blue" alt="Touying version: 0.7.4"></a>
  <a href="https://github.com/lucaslrodri/touying-ufac-unofficial/blob/v0.3.0/LICENSE"><img src="https://img.shields.io/badge/license-MIT%20AND%20MIT--0-green" alt="License: MIT and MIT-0"></a>
  <a href="https://github.com/lucaslrodri/touying-ufac-unofficial/tree/v0.3.0/skills"><img src="https://img.shields.io/badge/skill-Claude%20Code-D97757?logo=claude&amp;logoColor=white" alt="Skill for Claude Code"></a>
</p>

<p align="center"><img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/flavors.png" alt="The covers of a lecture, the work of students for a course and a thesis defense" width="760"></p>

Slides for the [Federal University of Acre (UFAC)](https://www.ufac.br/), Brazil, in [Typst](https://typst.app/) with [Touying](https://touying-typ.github.io/). For lectures and academic presentations, from coursework to thesis defenses.

[Manual (PDF)](https://github.com/lucaslrodri/touying-ufac-unofficial/blob/v0.3.0/docs/manual.pdf) · [Example decks](https://github.com/lucaslrodri/touying-ufac-unofficial/tree/v0.3.0/example) · [Skill for AI agents](https://github.com/lucaslrodri/touying-ufac-unofficial/tree/v0.3.0/skills) · [Changelog](https://github.com/lucaslrodri/touying-ufac-unofficial/blob/v0.3.0/CHANGELOG.md)

## Start

```sh
typst init @preview/touying-ufac-unofficial:0.3.0
```

This creates a deck from the template. In the new folder, `typst watch main.typ` compiles it. The theme needs the font *New Computer Modern Sans*, which Typst does not bundle: see *Install the font* in the [manual](https://github.com/lucaslrodri/touying-ufac-unofficial/blob/v0.3.0/docs/manual.pdf).

<!-- template:begin (generated from template/main.typ by scripts/readme.sh: do not edit by hand) -->
````typst
// Starting deck for the touying-ufac-unofficial theme. Syntax: the manual, docs/manual.pdf; whole decks: example/ (a
// lecture, coursework, a thesis defense), both at https://github.com/lucaslrodri/touying-ufac-unofficial/tree/v0.3.0
#import "@preview/touying:0.7.4": *
#import "@preview/touying-ufac-unofficial:0.3.0": *

#show: ufac-theme.with(
  aspect-ratio: "16-9",
  lang: "en",   // "pt-br" (default), "en" or "es"
  config-info(
    flavor: "lecture",   // or "coursework", "tcc", "dissertation", "thesis": start from example/coursework.typ, tcc.typ
    subject: [Subject name],                  // or Touying's `title:`
    subject-code: [CODE or Department],       // or `short-title:`
    unit-title: [Title of the teaching unit], // or `subtitle:`
    unit: [Teaching unit I],                  // or `short-subtitle:`
    author: [Prof. Dr. Your Name],
    // counter-prefix: [2.],   // "Exercise 2.N" in the second unit; the flavor "lecture" gives [1.]
  ),
)

#title-slide()

== Slide title
=== Subtitle

Text.
````

![The 2 pages of template/main.typ](https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/template.png)
<!-- template:end -->

## Choose a flavor

`flavor` in `config-info` sets where the authors go on the cover, the tag on the cover of a thesis defense and the numbering of the exercises and examples, unless the deck sets them itself.

| `flavor` | For |
| --- | --- |
| `"lecture"` (default) | a lecture of a course |
| `"coursework"` | the work of students for a course |
| `"tcc"`, `"dissertation"`, `"thesis"` | the defense of an undergraduate thesis, a master's dissertation or a doctoral thesis |

## Choose a cover style

`cover-style` in `ufac-theme` sets the background of the cover and of the closing slide.

| `"bubbles"` (default) | `"gradient"` | `"plain"` |
| --- | --- | --- |
| <img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/cover-style-bubbles.png" width="240" alt="The cover with the cover style bubbles"> | <img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/cover-style-gradient.png" width="240" alt="The cover with the cover style gradient"> | <img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/cover-style-plain.png" width="240" alt="The cover with the cover style plain"> |

## Elements

Headings make the slides, and a few Markdown-like shorthands make arrow lists, emphases, boxes and quotes. Every detail is in the [manual](https://github.com/lucaslrodri/touying-ufac-unofficial/blob/v0.3.0/docs/manual.pdf).

| Preview | Element |
| --- | --- |
| <img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/element-slide.png" width="340" alt="A slide with a subtitle, arrows, a box and a tip"> | **Slides.** `==` opens a slide and `===` adds a subtitle. `---` goes on to a new page. `->` at the start of a paragraph makes a list with arrows. |
| <img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/element-section.png" width="340" alt="A section slide with a figure on the right"> | **Sections.** `= Title` opens a section slide; an image after it goes on the right. |
| <img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/element-exercise.png" width="340" alt="An exercise with its answer"> | **Exercises and examples.** `== Title <exercise>` or `<example>`, numbered. `#answer` (in an exercise) or `#solution` (in an example) opens the answer or the solution; `#answer(sep: ":")` writes "Answer:". |
| <img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/element-emphasis.png" width="340" alt="Arrows with bold, italic, alert, highlight and underline"> | **Emphasis.** `*bold*`, `_italic_`, `~~alert~~`, `==highlight==` and `~underline~`. The last three take plain text only; for markup inside, use `#alert[..]`, `#highlight[..]` and `#underline[..]`. |
| <img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/element-boxes.png" width="340" alt="A box, a quotation and an equation box"> | **Boxes.** `> text` makes a box and `> $ .. $` an equation box. `"A quotation."` alone in a paragraph is a quote. |
| <img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/element-callouts.png" width="340" alt="Callouts: caution, tip, reminder (#remark), note, example and examples"> | **Callouts.** `#caution`, `#tip`, `#remark` (Reminder), `#note`, `#example` and `#examples`. |
| <img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/element-table.png" width="340" alt="A table with a blue header"> | **Tables.** The header row is blue; in a cell with `table.cell(fill: colors.secondary-lighter)`, the bold text takes a darker tone of the fill. |
| <img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/element-code.png" width="340" alt="Python code and its output"> | **Code.** A fenced `python`, `typst`, `matlab`, `bash` or `sh` block shows its language; a `text` block is the output. |
| <img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/element-ending.png" width="340" alt="The closing slide"> | **Closing slide.** `#ending-slide[Thank you!][Subtitle][Body]`. |

## Examples

Three example decks:

| Preview | Deck |
| --- | --- |
| <img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/deck-lecture.png" width="400" alt="The cover and an example with its solution of the lecture deck"> | **[lecture](https://github.com/lucaslrodri/touying-ufac-unofficial/blob/v0.3.0/example/lecture.typ)** ([PDF](https://github.com/lucaslrodri/touying-ufac-unofficial/blob/v0.3.0/docs/decks/lecture.pdf)): a lecture with an outline, step-by-step reveals, exercises and code. |
| <img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/deck-coursework.png" width="400" alt="The cover and an example with a formula of the coursework deck"> | **[coursework](https://github.com/lucaslrodri/touying-ufac-unofficial/blob/v0.3.0/example/coursework.typ)** ([PDF](https://github.com/lucaslrodri/touying-ufac-unofficial/blob/v0.3.0/docs/decks/coursework.pdf)): the work of students, with the students and the teacher under their labels on the cover. |
| <img src="https://raw.githubusercontent.com/lucaslrodri/touying-ufac-unofficial/v0.3.0/docs/readme/deck-tcc.png" width="400" alt="The cover and the slide of the problem of the tcc deck"> | **[tcc](https://github.com/lucaslrodri/touying-ufac-unofficial/blob/v0.3.0/example/tcc.typ)** ([PDF](https://github.com/lucaslrodri/touying-ufac-unofficial/blob/v0.3.0/docs/decks/tcc.pdf)): the defense of an undergraduate thesis. |

<!-- examples:begin (generated from the decks of example/ by scripts/readme.sh: do not edit by hand) -->
<details>
<summary>Show the code of example/lecture.typ</summary>

````typst
// Example deck of the touying-ufac-unofficial theme: a lecture of a course, with the aliases of a course (`subject`,
// `subject-code`, `unit`, `unit-title`, `semester`) and the prefix of its unit (`counter-prefix`), a slide revealed
// step by step, exercises and examples with their solutions, callouts and the closing slide.
#import "@preview/touying:0.7.4": *
#import "@preview/touying-ufac-unofficial:0.3.0": *

#show: ufac-theme.with(
  lang: "en",
  config-info(
    flavor: "lecture",
    subject: [Introductory Astronomy],
    subject-code: [AST101],
    unit: [Unit II],
    unit-title: [The solar system],
    semester: [2026.2],
    author: [Prof. Dr. Your Name],
    counter-prefix: [2.],   // the second unit: "Exercise 2.1"
  ),
)

#title-slide()

== Contents
#outline()

= The planets

== Orbits
=== Kepler's laws
-> The planets move on ellipses, with the Sun at a focus
-> A planet sweeps equal areas in equal times
-> The square of the period grows with the cube of the orbit

> == Definition
> An astronomical unit (au) is the mean distance from the Earth to the Sun, about $1.5 times 10^8$ km.

#tip[In years and astronomical units, Kepler's third law is just $T^2 = a^3$.]

// Touying's animations: a `#pause` in a paragraph of its own between two lines, then `#uncover(3)` around a box,
// which shows on the third step
== One step at a time
-> The orbit of a planet is an ellipse

#pause

-> The Sun sits at one of its foci

#uncover(3)[
  #emph-box(title: [Kepler's first law])[The planets move on ellipses, with the Sun at one focus.]
]

== The period of Mars <example>
Mars orbits the Sun at $a = 1.52$ au. How long is its year?

#pause
#solution
From $T^2 = a^3$:

$ T = sqrt(1.52^3) approx 1.87 "years" $

== Jupiter and Saturn <exercise>
Find the period of:

+ Jupiter, at $5.2$ au
+ Saturn, at $9.5$ au
+ an asteroid at $2.8$ au

#answer
About $11.9$, $29.3$ and $4.7$ years.

= On the computer

== The periods in Python
```python
planets = {"Mercury": 0.39, "Earth": 1.00, "Mars": 1.52}

for name, a in planets.items():
    print(name, round(a ** 1.5, 2))
```
```text
Mercury 0.24
Earth 1.0
Mars 1.87
```

#tip[`a ** 1.5` is the same as `sqrt(a ** 3)`.]

#ending-slide[Thank you!][Next lecture: the Moon][Read chapter 3 of the book.]
````

</details>

<details>
<summary>Show the code of example/coursework.typ</summary>

````typst
// Example deck of the touying-ufac-unofficial theme: the work of students for a course (`flavor: "coursework"`), with
// the students and the teacher under their labels on the cover (the layout "stack" of the flavor) and `#info`.
#import "@preview/touying:0.7.4": *
#import "@preview/touying-ufac-unofficial:0.3.0": *

#show: ufac-theme.with(
  lang: "en",
  config-info(
    flavor: "coursework",
    subject: [Applied Statistics],
    subject-code: [STA210],
    unit-title: [How long does it take to get to class?],
    author: [_Students_ \ First Student, Second Student \ _Teacher_ \ Prof. Dr. Teacher Name],
    year: 2026,
  ),
)

#title-slide()

== The survey
#cols(columns: (3fr, 2fr))[
  -> 40 students answered a short form
  -> Each one gave the time from home to class
  -> On foot, by bike, by bus or by car

  The mean is #eq-box[$overline(x) = 1/n sum_i x_i$].
][
  #emph-box(title: [Course])[
    #info("subject") (#info("subject-code")), #info("year").
  ]
]

== The spread <example>
Five students took 10, 15, 20, 25 and 30 minutes. Find the mean and the standard deviation.

#solution
$ overline(x) = 20 "min", quad s = sqrt((100 + 25 + 0 + 25 + 100) / 4) approx 7.9 "min" $

#caution[The sample standard deviation divides by $n - 1$, not by $n$.]

#ending-slide()
````

</details>

<details>
<summary>Show the code of example/tcc.typ</summary>

````typst
// Example deck of the touying-ufac-unofficial theme: the defense of an undergraduate thesis (`flavor: "tcc"`), with
// the student and the advisors under their labels, the cover style "gradient" and the tag of the work on the cover.
#import "@preview/touying:0.7.4": *
#import "@preview/touying-ufac-unofficial:0.3.0": *

#show: ufac-theme.with(
  lang: "en",
  cover-style: "gradient",
  config-info(
    flavor: "tcc",
    title: [Recognizing bird songs in city parks],
    course: [Bachelor's in Biology],
    author: [_Student_ \ Student Name \ _Advisor_ \ Prof. Dr. Advisor Name \ _Co-advisor_ \ Prof. Dr. Co-advisor Name],
    date: [December 2026],
    contact: [`student.name@example.com`],
  ),
)

#title-slide()

= Introduction

== The problem
-> City parks are full of birds, heard more often than seen
-> Telling the songs apart by ear takes years of practice
-> A phone can record them, and a program can name the species

#cols(divider: true)[
  #tag[goal]

  Name the species from a short recording.
][
  #tag(color: colors.quaternary)[result]

  A classifier evaluated on 300 recordings.
]

= Method

== The recordings
#table(columns: 3, table.header([Set], [Recordings], [Accuracy]),
  [Training], [1200], [--],
  [Validation], [300], [0.88],
  [Test], [300], [0.86],
)

#note[The accuracy is the share of recordings named right (0 to 1).]

= Conclusion

== Contributions
- A set of 1800 labeled recordings of 25 species
- A classifier with an accuracy of 0.86 on the test set
- The code, open

#ending-slide[Thank you!][Questions?][#info("contact")]
````

</details>
<!-- examples:end -->

## License

The theme is [MIT](LICENSE). The [template](template/) is [MIT-0](LICENSE-MIT-0): a deck made from it needs no attribution.

The icons in [assets/icons/](assets/icons/) come from [Octicons](https://primer.style/octicons/) (© GitHub Inc., MIT License), [Phosphor](https://phosphoricons.com/) (MIT License), [Devicon](https://devicon.dev/) (MIT License), [Simple Icons](https://simpleicons.org/) (CC0), [Material Icon Theme](https://github.com/material-extensions/vscode-material-icon-theme) (MIT License) and [VSCode Icons](https://github.com/vscode-icons/vscode-icons) (MIT License), in [Iconify](https://iconify.design/) format.

The UFAC logo ([assets/ufac-logo.svg](assets/ufac-logo.svg)) belongs to the [Federal University of Acre](https://www.ufac.br/). This theme is unofficial: the university does not endorse it.
