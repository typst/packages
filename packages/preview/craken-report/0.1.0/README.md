# Captain Craken lab reports

Lab reports in the Captain Craken house style. You get an A4 page with the text across the full width, a cover that's set up from a few fields, and numbered sections. It also handles figures, charts drawn in Typst, tables, code listings, equations and footnotes, with the same fonts and colours as the Craken books.

Tested with Typst 0.15.1.

## Start a report

```sh
typst init @preview/craken-report:0.1.0 my-lab
cd my-lab
typst watch report.typ        # or: typst compile report.typ
```

This gives you a sample `report.typ` that uses every feature, along with `figures/`, `data/` and `code/` folders. Keep what you need and delete the rest. In the Typst web app, choose *Start from template* and search for `craken-report`.

For a dark copy to read on screen:

```sh
typst compile --input theme=lantern report.typ report-dark.pdf
```

## Fonts

The report is set in Fraunces Soft, Newsreader Text, DM Mono and STIX Two Math, the same fonts as the Craken books. Typst packages can't ship fonts, so download them once: [craken-report-fonts.zip](https://github.com/TheCaptainCraken/craken-report/releases/download/v0.1.0/craken-report-fonts.zip). They're all under the SIL Open Font License.

- **On your computer:** install the `.ttf` files (double-click them, or copy them to `~/.local/share/fonts` on Linux). Or keep them in a folder and pass `--font-path path/to/fonts` to `typst compile` and `typst watch`.
- **In the web app:** upload the `.ttf` files anywhere in your project. The web app picks them up.

Without them the report still compiles, in Libertinus Serif, with a warning for each missing font.

## The cover

```typst
#import "@preview/craken-report:0.1.0": *

#show: report.with(
  course: "HPC",                      // kicker and header: "HPC · Lab 2"
  lab: "Lab 2",
  title: [Parallel programming with OpenMP],
  subtitle: [Solving the heat equation],
  authors: (
    (name: "Ada Lovelace", id: "s1815", email: "ada@example.edu"),
    (name: "Alan Turing", id: "s1912", email: "alan@example.edu"),
  ),                                  // or just names: ("Ada Lovelace", "Alan Turing")
  group: "Group 5",
  academic-year: "2026/2027 Q1",
  date: datetime(year: 2026, month: 10, day: 29),   // auto (default): today
)
```

Every field is optional. If you leave one out, its line disappears from the cover. These are the other settings:

| Setting | What it does |
| --- | --- |
| `kicker: [...]` | The line above the title. By default it's `course · lab`. |
| `short-title: [...]` | The title in the page header, if the full one is too long. |
| `fields: (("Professor", [Jane Doe]),)` | More labelled lines on the cover, after group and year. |
| `logo: read("figures/logo.png", encoding: none)` | A logo at the top right of the cover. Set its size with `logo-width: 28mm`. |
| `contents: true` | Adds a contents page after the cover. |
| `cover: false` | Skips the cover entirely. |
| `heading-numbering: "a)"` | Numbers sections a), b), c), one per question, with subsections a.1. It also accepts any Typst numbering, or `none`. |
| `equation-numbers: "all"` | Numbers every display equation. By default, only labelled ones get a number. |
| `justify: false` | Sets the text ragged right. By default it's justified and hyphenated. |
| `lang: "es"` and `labels: (authors: [Autores], group: [Grupo], academic-year: [Curso], contents: [Índice])` | Changes the language and translates the words the template adds. |

## Writing

| You write | You get |
| --- | --- |
| `= Title`, `== Title`, `=== Title` | Numbered section, subsection and sub-subsection (1, 1.1, 1.1.1) |
| `#lede[…]` | An opening paragraph, a step larger |
| `#dfn[term]` | A new term, in italic semibold |
| `#footnote[…]` | A footnote with its number in rust |
| `$ … $ <eq:name>` | A display equation, numbered (1) because it has a label |
| `#figure(image("figures/x.png", width: 70%), caption: […]) <fig:x>` | Figure 1, with the caption below |
| `#figure(table(…), caption: […]) <tab:x>` | Table 1, with the caption above, hairlines and tabular figures |
| `table-section(5)[Group name]` | A row inside a table that heads a group of rows |
| `#listing(caption: […], lang: [C], numbers: true)[```c …```]` | Listing 1: a code box with its caption above |
| `#code(title: [solver.c], lang: [C])[```c …```]` | A titled code box without a number |
| `#raw(lines(read("code/solver.c"), 11, 36), lang: "c", block: true)` | Lines 11–36 of a source file. Add `first-line: 11` to the listing to keep the file's line numbers. |
| `- item`, `+ item` | Coral dot bullets, and numbered items with numbers in rust |
| `#sbreak()` | A break inside a section: three suckers |
| `#show: appendix` | Everything after it is numbered A, B, … |
| `@fig:x`, `@tab:x`, `@eq:x`, `@lst:x`, `@sec:x` | Clickable references, in rust |

Images sit side by side with a grid inside one figure:

```typst
#figure(
  grid(columns: 2, gutter: 1em, image("figures/a.png"), image("figures/b.png")),
  caption: [Left: Jacobi. Right: Gauss–Seidel.],
)
```

## Charts

Charts are drawn in Typst, so they don't need a package or an internet connection. The series run coral, moss, amber, then ink-soft. Each chart has gridlines in `rule`, and each line is labelled at its end, so there's no legend to decode.

```typst
#let data = csv("data/speedup.csv", row-type: dictionary)

#figure(
  plot(
    x-label: [Threads], y-label: [Speed-up],
    x-scale: "log2",                      // "linear", "log2" or "log10"
    y-ticks: (0, 4, 8, 12, 16),           // auto by default
    series: (
      (label: [Jacobi], points: csv-points(data, x: "threads", y: "jacobi")),
      (label: [Measured], points: ((1, 1.0), (2, 1.7), (4, 2.9)), line: false),  // dots only
      (label: [Ideal], fn: p => p, dashed: true, color: palette.ink-soft),        // a function
    ),
  ),
  caption: [Speed-up against the sequential code.],
) <fig:speedup>

#figure(
  bar-chart(
    categories: ([v1], [v2], [swap]),
    series: (
      (label: [4 threads], values: (3.1, 3.4, 3.6)),
      (label: [8 threads], values: (5.2, 6.1, 6.7)),
    ),
    y-label: [Speed-up],
    values: true,                         // print each bar's value
  ),
  caption: [Speed-up of the three versions.],
)
```

`plot` also takes `width`, `height`, `x-min`, `x-max`, `y-min`, `y-max`, `x-ticks` and `x-grid: true`. Ticks can be numbers or `(value, [label])` pairs. `legend: "top"` puts a key above the chart instead of labels at the line ends. Series without a colour take the next one in order.

The colours are also exported as `palette.coral`, `palette.rust` and so on, along with `ink-line`, so you can draw your own diagrams that match.

## Files

- `craken-report.typ`: the template.
- `template/`: what `typst init` copies into a new report. It's a sample report that uses every feature.
- `themes/`: the syntax colours for code, in Paper and Lantern.

The [GitHub repository](https://github.com/TheCaptainCraken/craken-report) also has the fonts and `install.sh`, which installs the package and the fonts on Linux and macOS for working offline.

## License

The code and the starter files are under [MIT-0](LICENSE): use, change and share them however you like, no credit needed. The fonts are under the SIL Open Font License.
