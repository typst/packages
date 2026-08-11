# ethz-cadmo-inspired-thesis

A template for writing a (bachelor's) thesis at ETH Zürich.

It provides general styling and some useful helper functions.

It is an **unofficial** Typst adaptation of the [CADMO LaTeX thesis
template](https://cadmo.ethz.ch/education/thesis/template.html) which is maintained by
Kostas Lakis at CADMO (Center for Algorithms, Discrete Mathematics and
Optimization), ETH Zürich. It is not affiliated with or endorsed by CADMO or
ETH Zürich.

## Usage

Start a new thesis from this template with:

```sh
typst init @preview/ethz-cadmo-inspired-thesis
```

or directly with:

```typ
#show: setup.with(
  "My Thesis Title", // title
  "Jane Doe", // author
  ("Advisor One", "Advisor Two"), // advisors
  thesis-type: "Bachelor Thesis",
  department: "Department of Computer Science",
  bib: bibliography("bib.bib", title: none),
)
```

## Configuration

The template exports `setup`, applied as a show rule at the top of your
document:

| Parameter     | Type                 | Default Value                      | Description / Note                     |
| :------------ | :------------------- | :--------------------------------- | :------------------------------------- |
| `title`       | content \| str       | _Required_                         | The title of the thesis                |
| `author`      | str                  | _Required_                         | The author's name                      |
| `advisors`    | array of str         | _Required_                         | List of academic advisors              |
| `department`  | str                  | `"Department of Computer Science"` | The academic department                |
| `thesis-type` | str                  | `"Bachelor Thesis"`                | The degree level or type of thesis     |
| `date`        | datetime             | `datetime.today()`                 | Date of publication/submission         |
| `bib`         | bibliography \| none | `none`                             | Takes a Typst `bibliography()` element |
| `dev`         | bool                 | `false`                            | Force Work in Progress (WiP) mode      |
| `doc`         | content              | _Required_                         | The rest of the document content       |

Applied with `#show: setup.with(...)`, it sets up the page and general structure needed for a thesis.

If `bib` is set, a `References` chapter with that bibliography is appended at the
very end. If you need the bibliography to appear before an appendix, leave `bib: none` and place the bibliography
yourself instead (see [Bibliography and appendix](#bibliography-and-appendix)).

## Fonts

The template typesets in **TeX Gyre Pagella**. Typst cannot bundle a font into a
package and load it automatically, so the font has to be available at compile
time.

Download the OTF files from the official GUST e-foundry page and install them, or place them on your `--font-path`:

<https://www.gust.org.pl/projects/e-foundry/tex-gyre/pagella>

The font is distributed under the GUST Font License.

## Document structure

| Helper                | Purpose                                                                                                                                 |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `frontchapter(title)` | An unnumbered level-1 heading for front matter such as _Abstract_ or _Acknowledgments_.                                                 |
| `#show: mainmatter`   | Starts the numbered body: resets the page and chapter counters and switches to arabic page numbers. Apply once, after the front matter. |
| `#show: appendix`     | Switches heading numbering to letters (`A`, `A.1`, `A.2`, …). Apply once, at the start of the appendix.                                 |

Headings render as:

- **Level 1**: a centered `Chapter N` label above the title, framed by rules
  (the label is omitted for unnumbered chapters).
- **Level 2 / 3**: bold section and subsection titles.

The running header shows `Chapter N - N.M Section Title` and is hidden on pages
that begin a new chapter.

### Bibliography and appendix

To keep the references and appendix out of the word count, wrap them in a
`<no-wc>`-labelled block and set `bib: none`:

```typ
#[
  #set page(numbering: "1")
  #heading(level: 1, numbering: none)[References]
  #bibliography("bib.bib", title: none)

  #include "chapters/appendix.typ"
] <no-wc>
```

An appendix file then looks like:

```typ
#show: appendix
#frontchapter[Appendix]

== First Appendix Section   // numbered "A"
=== A Subsection            // numbered "A.1"
```

## Theorem environments

All environments take a body and an optional `name`, and are numbered
`chapter.n`, resetting at every chapter:

```typ
#theorem(name: "Fermat")[
  There are no positive integers $a, b, c$ with $a^n + b^n = c^n$ for $n > 2$.
]

#proof[
  The margin is too small. #h(1fr)  // proof already appends a QED square
]
```

Available: `theorem`, `lemma`, `corollary`, `proposition`, `definition`,
`example`, `remark`, `claim`, and `proof`.

## Code listings

`code` renders a single raw block with line numbers, in a rounded gray frame:

````typ
#code(
  ```rust
  fn main() {
      println!("hello");
  }
  ```,
  filename: "main.rs",     // optional file label in the header
  projectname: "my-crate", // optional right-aligned label
  start: 1,                // first line number
  breakable: false,        // allow the listing to split across pages
)
````

`code-file` embeds code read from a file, optionally limited to a line range.
The caller reads the file so Typst tracks it as a dependency:

```typ
#code-file(
  read("../src/lib.rs"),
  lang: "rust",
  from: 10, to: 25,        // inclusive, 1-indexed; line numbers stay aligned to the file
  filename: "lib.rs",
)
```

To keep parts of a file out of the listing (for example a test-harness preamble
that has to stay in the file to keep it runnable), wrap them between a line
containing `<hide>` and a line containing `</hide>`. Both marker lines and
everything between them are dropped from the display, and the remaining lines
are renumbered contiguously from `start`. Because the markers live in comments,
the source file still compiles and runs unchanged:

```rust
// <hide>
//@compile-flags: -Zmiri-tree-borrows
// </hide>
use std::io::Read; // shown as line 1
```

Hiding is meant for file-only preambles and is not combined with `from`/`to`.

`multi-code` shows several excerpts of the same listing separated by a dashed
"…" line, for skipping over irrelevant lines. It takes an array of
`(raw, start-line)` tuples:

````typ
#multi-code((
  (```rust
  fn first() {}
  ```, 1),
  (```rust
  fn later() {}
  ```, 42),
))
````

Inside any listing, the token `<fakebreak>` is replaced by a newline, which lets
you force a break within a single source line.

## Utilities

`breakable-id(n)` returns a string with zero-width spaces inserted after every
`-` and `_`, so long identifiers (package names, crate names, symbol paths)
can break across lines without an explicit hyphen:

```typ
#raw(breakable-id("my-very-long-crate-name"))   // breaks at each `-`
#breakable-id("some_module::long_symbol")        // use in any content
```

`display-pr(url)` displays a GitHub or GitLab Pull Request in a shorter, more readable format.

## Cross references

`nameref(label)` links to a labelled heading and prints its supplement, number
and title, e.g. `#nameref(<sec-method>)` → "Section 3.2: Method". For unnumbered
headings it falls back to the heading text alone.

```typ
== Method <sec-method>
...
As shown in #nameref(<sec-method>), ...
```

## TODOs and WiP mode

`todo(body, inline: false)` marks unfinished work:

```typ
#todo[rewrite this paragraph]           // block
Some text #todo(inline: true)[fix ref]. // inline
```

While any `TODO` is present (or `dev: true` is passed to `setup`), the document
is in **work in progress** mode: the title page shows a red _Work in Progress_
banner and every running header shows `WIP · N words`. Once the last `TODO` is
removed, both disappear automatically.

## Colours

This template also exposes some colours. The official ETH colours can be found at `eth`. The custom colours used for some functions can be found at `custom`.

## Exports

`setup`, `mainmatter`, `appendix`, `frontchapter`, `display-pr`, `nameref`, `todo`,
`code`, `code-file`, `multi-code`, `breakable-id`, `theorem`, `lemma`, `corollary`,
`proposition`, `definition`, `example`, `remark`, `claim`, `proof`, `eth`, `custom`.

## Contribution

I'm always open to contributions / feedback. As the repo currently only tracked in typst packages, just send me an email with a diff / comment and I will integrate it: mail@dominik-schwaiger.ch

## Full Example

A full example how the template can be used can be found here: https://gitlab.dominik-schwaiger.ch/quio/bachelor-thesis/-/tree/main/Thesis?ref_type=heads

## Acknowledgments

This template is a Typst port of the [CADMO LaTeX thesis
template](https://cadmo.ethz.ch/education/thesis/template.html) by Kostas Lakis
(CADMO, ETH Zürich).

Many thanks to [VirtCode](https://github.com/VirtCode), whose work the
code-listing helpers are based on.

The body font is [TeX Gyre
Pagella](https://www.gust.org.pl/projects/e-foundry/tex-gyre/pagella) by the
GUST e-foundry, distributed under the GUST Font License.
