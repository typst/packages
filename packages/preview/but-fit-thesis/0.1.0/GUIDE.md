# Writing the BUT FIT Thesis using Typst

#### Authors: Vladimír Veselý, Michal Koutenský

This template visuals and content are based on [https://cs.overleaf.com/latex/templates/fit-but-thesis-template-2025/mmphstqxpwpg](https://cs.overleaf.com/latex/templates/fit-but-thesis-template-2025/mmphstqxpwpg).

A practical guide for writing a thesis with the `but-fit-thesis` package. Paths
such as `thesis.typ`, `chapters/` or `bib/` are relative to your thesis project
(created by `typst init`, or the `template/` folder in this repository). All
Typst and bibliography examples below were compiled with the Typst version used
here (0.15, via tinymist 0.15.8).

- [1. Quick start](#1-quick-start)
- [2. Repository layout](#2-repository-layout)
- [3. Typst for LaTeX users](#3-typst-for-latex-users)
- [4. Building blocks](#4-building-blocks)
- [5. Notes and drafting](#5-notes-and-drafting)
- [6. Bibliography](#6-bibliography)
- [7. Zotero: automatic bibliography](#7-zotero-automatic-bibliography)
- [8. Tools](#8-tools)
- [9. Pitfalls](#9-pitfalls)
- [10. Writing conventions](#10-writing-conventions)
- [11. Learning resources](#11-learning-resources)
- [License](#license)

---

## 1. Quick start

```bash
./build.sh              # template/thesis.typ -> thesis.pdf
./build.sh -w           # rebuild on every save (Ctrl+C to stop)
./build.sh -w -o        # same, and open the PDF after the first build
```

`build.sh` uses `typst` if it is on `PATH`, otherwise `tinymist` (from `PATH`
or the copy Zed downloads with its Typst extension). It works in Git Bash on
Windows, on Linux and on macOS.

**On NixOS / with Nix**, enter the development shell first; it provides
`typst` (with the `drafting` package), `tinymist`, `hayagriva` and
`poppler-utils`:

```bash
nix develop             # or let direnv do it: `direnv allow` once (.envrc has `use flake`)
./build.sh -w
```

**PDF viewer:** use one that reloads changed files and does not lock them,
e.g. SumatraPDF on Windows, Okular/Zathura on Linux, or a browser. Foxit and
Acrobat lock the file, so the next build fails (`build.sh` tells you so).

### Live preview in the editor

| Editor | Setup | Preview |
|---|---|---|
| **VSCodium / VS Code** | Install the *Tinymist Typst* extension (Open VSX / Marketplace). | Preview icon in the editor title bar, or *Typst Preview* in the command palette. Clicking in the preview jumps to the source and vice versa. |
| **Zed** | The *Typst* extension (already installed) runs tinymist as the language server: completion, diagnostics, go-to-definition for labels and citations. | Zed has no embedded preview; run `tinymist preview --open --font-path fonts thesis.typ` in a terminal for a live, incrementally updated preview in the browser. |

In Git Bash, without Nix, the tinymist binary from Zed can be found like this:

```bash
TINYMIST=$(ls -d ~/AppData/Local/Zed/extensions/work/typst/tinymist-v*/tinymist | tail -n 1)
"$TINYMIST" preview --open --font-path fonts thesis.typ
```

**Fonts in the editor:** this repository keeps two fonts in `fonts/`
(see [Fonts](#fonts)). `build.sh` passes them to Typst automatically; for the
editor preview, add the folder to tinymist's settings, otherwise the title
page and code fall back to other fonts:

- VSCodium / VS Code (`.vscode/settings.json` or user settings):
  `"tinymist.fontPaths": ["${workspaceFolder}/fonts"]`
- Zed (`.zed/settings.json`):
  `{ "lsp": { "tinymist": { "settings": { "fontPaths": ["fonts"] } } } }`

---

## 2. Repository layout

```
typst.toml                package manifest (Typst Universe)
lib.typ                   package entry point: exports fit-thesis and appendix
src/
  fit-thesis.typ          the thesis template (FIT BUT look, see below)
  assets/vut-logo-*.svg   VUT logo for the title page (colour / black-and-white)
template/                 the starter project that `typst init` copies:
  thesis.typ              main file: template settings, chapter list, bibliography
  common.typ              shared helpers (note commands); import it in every chapter
  chapters/               one file per chapter, converted from the LaTeX template's sample text
  figures/                images (PNG, JPG, SVG, PDF)
  bib/
    bibliography.yaml     hand-written references in Hayagriva YAML
    template.bib          references cited by the sample chapters (from the LaTeX template)
    iso-690-2022-numeric-ntk.csl   citation style (ČSN ISO 690:2022, numeric)
thumbnail.png             preview of the title page for Typst Universe
docs/guide.md             this guide
fonts/                    Open Sans Bold, New Computer Modern Mono (+ licences), not part of the package
extras/logos/             further FIT/VUT logos, not part of the package
build.sh                  build script (serves this checkout as @preview/but-fit-thesis)
zotero-sync.sh            downloads the Zotero collection via the Web API
zotero.env                Zotero API credentials (git-ignored, create it yourself)
flake.nix, nix/           Nix dev shell and formatter
LICENSE                   licence (CC BY-SA 4.0; template/ under MIT-0)
```

`template/thesis.typ` imports the package as `@preview/but-fit-thesis:0.1.0`;
`build.sh` makes that import resolve to this checkout (through the git-ignored
`.typst-packages/` folder), so changes in `src/` show up immediately.

The sample chapters are the FIT LaTeX template's example text (in English),
kept as a demonstration of the Typst template; replace them with your own
chapters and drop `bib/template.bib` from `#bibliography(...)` once nothing
cites it.

### Adding a chapter

1. Create `chapters/09-something.typ`:

   ```typst
   #import "../common.typ": *

   = Something
   <ch:something>

   Text…
   ```

2. Add `#include "chapters/09-something.typ"` to `thesis.typ`, in reading order.

Each chapter starts with a level-1 heading (`=`); sections are `==`, subsections `===`.

### The template (`src/fit-thesis.typ`)

A Typst re-implementation of the official FIT BUT LaTeX thesis template
(`fitthesis.cls`, 2025 edition), measured against its PDF output: same
A4 text block (15.2 × 23 cm, 3.46 cm left margin), 11pt Computer Modern text
on a 13.6pt grid, title page with the VUT logo in Open Sans Bold capitals,
abstract/keywords/reference page, declaration page, "Chapter 1" headings,
LaTeX-style contents with dot leaders, captions, footnotes and link colours
(red cross-references, green citations, blue URLs).

Options, set in `thesis.typ`:

| Option | Meaning |
|---|---|
| `type` | `"habilitation"`, `"phd"`, `"master"`, `"bachelor"`, `"term"`: the thesis type on the title page and in the reference |
| `lang` | `"en"` or `"cs"`: main language. The other one is used for the small secondary lines on the title page and the second abstract |
| `title`, `abstract`, `keywords` | `(en: [...], cs: [...])` |
| `author`, `supervisor` | `(name: "…", surname: "…", before: "Ing.", after: "Ph.D.")`; `before`/`after` (degrees) are optional, `supervisor` defaults to none |
| `faculty`, `department` | `"FIT"`; `"UIFS"`, `"UPSY"`, `"UITS"`, `"UPGM"`, or `(en: [...], cs: [...])`; `none` omits the line |
| `year`, `date` | year on the title page; date under the declaration |
| `declaration`, `acknowledgement` | content; leave out to skip the page |
| `list-of-figures`, `list-of-tables` | add the lists after the contents (default off) |
| `outline-depth` | heading levels in the contents (default 2, as in the FIT template) |
| `print` | black links and the black-and-white logo for the printed copy |
| `twoside` | alternating margins and front matter on odd pages, for duplex printing |

What the template does for you:

- `=` chapters start on a new page as "Chapter 1"; `==` and `===` are numbered
  (1.1, 1.1.1); `====` and deeper are unnumbered, like in the LaTeX template.
- Figures, tables, listings and equations are numbered per chapter (Figure 2.1,
  equation (2.1)); tables get the caption above, everything else below.
- Tables are drawn booktabs-style (rules above, below and under the first row).
  For a different look pass `stroke:` to the individual `table(...)`.
- Appendices: after the bibliography, `#show: appendix`; the following chapters
  become "Appendix A", "Appendix B", … with figures numbered A.1, A.2, …

---

## 3. Typst for LaTeX users

| LaTeX | Typst |
|---|---|
| `\chapter{X}`, `\section{X}`, `\subsection{X}` | `= X`, `== X`, `=== X` |
| `\label{sec:x}` | `<sec:x>` (right after the heading/figure) |
| `\ref{x}`, `\autoref{x}` | `@x` (renders e.g. "Figure 1", "Chapter 2") |
| `\cite{k}` | `@k` |
| `\cite[p.~5]{k}` | `@k[p.~5]` |
| `\emph{x}`, `\textbf{x}`, `\texttt{x}` | `_x_`, `*x*`, `` `x` `` |
| `itemize` / `enumerate` | lines starting with `- ` / `+ ` |
| `description` | `/ Term: description` |
| `\footnote{x}` | `#footnote[x]` |
| `\url{u}`, `\href{u}{t}` | `#link("u")`, `#link("u")[t]`; bare `https://…` links automatically |
| `$x^2$` | `$x^2$` |
| `\[ x^2 \]`, `equation` | `$ x^2 $` (spaces inside the dollars make it a block) |
| `\includegraphics[width=.8\linewidth]{f}` | `#image("f", width: 80%)` |
| `\newpage` | `#pagebreak()` |
| `\\` | `\` at the end of a line, or `#linebreak()` |
| `\newcommand{\btc}{BTC}` | `#let btc = [BTC]`, used as `#btc` |
| `\usepackage{x}` | `#import "@preview/x:1.2.3": *` |
| `\input{f}` | `#include "f.typ"` |
| `% comment` | `// comment`, `/* block */` |
| `~`, `--`, `---` | the same: `~`, `--`, `---` |
| `\%`, `\&` | `%`, `&` (no escaping needed) |

Typst has three modes: **markup** (normal text), **code** (after `#`, or inside
`{ }`) and **math** (inside `$ $`). `[ … ]` is a content block, so
`#footnote[text]` passes markup as an argument.

Settings are changed with *set rules* and *show rules*, which apply from that
point to the end of the enclosing block or file:

```typst
#set par(justify: false)                        // ragged right from here on
#show "Bitcoin Core": it => emph(it)            // every occurrence in italics
#show figure.where(kind: image): set figure(placement: auto)  // let images float
```

---

## 4. Building blocks

### Figures

```typst
#figure(
  image("/figures/diagram.png", width: 60%),
  caption: [Transaction graph of the analysed wallet.],
) <fig:diagram>

As @fig:diagram shows, …
```

- Paths starting with `/` are relative to the repository root, so they work
  the same from every chapter. Paths without `/` are relative to the current file
  (from `chapters/` that would be `"../figures/diagram.png"`).
- Prefer vector formats (SVG, PDF) for diagrams, PNG for screenshots.
- `placement: top` (or `bottom`) lets a figure float to the top/bottom of the page.

### Tables

```typst
#figure(
  table(
    columns: 3,
    align: (left, right, right),
    table.header([*Chain*], [*Block time*], [*Fee*]),
    [Bitcoin], [10 min], [high],
    [Monero], [2 min], [low],
  ),
  caption: [Comparison of selected blockchains.],
) <tab:costs>
```

### Code listings

````typst
#figure(
  ```python
  def balance(utxos):
      return sum(u.value for u in utxos)
  ```,
  caption: [Computing a balance.],
) <lst:balance>
````

Syntax highlighting works for common languages (Python, Rust, Go, JavaScript,
JSON, …). Inline code: `` `bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh` ``,
which is also the safest way to write addresses and hashes (see [Pitfalls](#9-pitfalls)).

### Math

```typst
The balance of address $a$ is
$ B(a) = sum_(u in U(a)) v(u) $ <eq:balance>
where … (see @eq:balance).
```

Display equations are numbered per chapter automatically, and `@eq:balance`
renders as "(2.1)", like `\eqref` in LaTeX. Math syntax differs from LaTeX: `sum_(i=1)^n`, `frac(a, b)` or `a / b`,
`alpha`, `RR`, `arrow.r`, `x^(2n)`. Symbol names: <https://typst.app/docs/reference/symbols/sym/>.

### Cross-references and footnotes

```typst
See @ch:forensics, @fig:diagram, @tab:costs, @lst:balance and @eq:balance.
Custom word: @fig:diagram[Fig.]      // -> "Fig. 2.1"
A remark.#footnote[Footnote text.]
```

`@ch:…` renders as "Chapter N", `@sec:…` as "Section N.M", appendices as
"Appendix A" (set by the template).

### Acronyms (optional: `glossarium` package)

Blockchain texts are full of acronyms (UTXO, PoW, DAG, …). The `glossarium`
package expands an acronym on first use and builds a list of abbreviations:

```typst
#import "@preview/glossarium:0.5.10": make-glossary, register-glossary, print-glossary, gls, glspl
#show: make-glossary
#let glossary = (
  (key: "utxo", short: "UTXO", long: "unspent transaction output"),
  (key: "pow", short: "PoW", long: "proof of work"),
)
#register-glossary(glossary)

First @utxo (-> "unspent transaction output (UTXO)"), again @utxo (-> "UTXO"),
plural @utxo:pl (-> "UTXOs").

#print-glossary(glossary)   // the list itself, e.g. before the bibliography
```

Put the import, `#show` and `#register-glossary` into `thesis.typ` and the
`glossary` list into its own file. With Nix, also add `glossarium` to
`typst.withPackages` in `nix/devshells/default.nix`; if the version packaged in
nixpkgs differs from the one in the import, Typst downloads the requested one.

### Your own commands

```typst
#let btc = [BTC]
#let addr(a) = raw(a)                   // monospace, no markup interpretation
#let todo(body) = inline-vv[TODO: #body]
```

Put shared ones into `common.typ` so all chapters see them.

---

## 5. Notes and drafting

`common.typ` defines comment commands based on the `drafting` package:

```typst
#inline-vv[A note on its own line, inside the text.]
#margin-vv[A note in the margin.]
#margin-vv[highlighted phrase][Comment about the highlighted phrase.]
```

- **List of all notes:** put `#note-outline()` somewhere (e.g. after the
  contents) while drafting.
- **Final version:** uncomment `#set-margin-note-defaults(hidden: true)` in
  `thesis.typ`; all notes disappear.
- **Co-authors or reviewers** get their own colour. Add a line to `todoColors`
  in `common.typ` and copy the two `.with(...)` definitions:

  ```typst
  #let todoColors = (
    VV: rgb("#f88605"),
    XY: rgb("#1f77b4"),
  )
  #let margin-xy = margin-note.with(stroke: todoColors.XY, fill: todoColors.XY.lighten(90%))
  #let inline-xy = inline-note.with(stroke: todoColors.XY, fill: todoColors.XY.lighten(90%))
  ```

- Margin notes can cause the warnings *document did not converge* / *rect
  position did not stabilize*. They are harmless and disappear once the notes
  are hidden.

---

## 6. Bibliography

References live in `bib/bibliography.yaml` in **Hayagriva** format, Typst's
native YAML format. They are formatted by the CSL style
`bib/iso-690-2022-numeric-ntk.csl` (ČSN ISO 690:2022, numeric citations, NTK
variant). The style was patched so that digital reports, web pages and posts
without a place of publication do not get "s.l.", and so that the "[1]" labels
hang in their own column like in the FIT LaTeX template
(`second-field-align="flush"` on `<bibliography>`). Keep that attribute when
switching to another numeric style.

### Citing

```typst
Bitcoin~@nakamoto2008 introduced …                 // [1]
… as described in @narayanan2016[p.~42].           // [2 p. 42]
Several studies @moser2018 @meiklejohn2013 @kumar2017 …   // [3–5]
Nakamoto~@nakamoto2008 proposed …                  // name written by hand
```

- Only cited entries are printed. For "print everything", use
  `#bibliography(..., full: true)`.
- `#cite(<key>, form: "prose")` exists, but with this ISO 690 style it renders
  as "NAKAMOTO, Satoshi. [1]". Writing the name yourself (last line above) reads better.
- A typo in a key gives `error: label <key> does not exist in the document`.

### Entry templates

Field reference: <https://github.com/typst/hayagriva/blob/v0.10.1/docs/file-format.md>.
These templates render correctly with the ISO 690 style (double-check the
metadata against the publisher before use):

```yaml
# Journal article: the journal is the `parent` (periodical)
moser2018:
  type: article
  title: An Empirical Analysis of Traceability in the Monero Blockchain
  author:
    - Möser, Malte
    - Soska, Kyle
    # … all authors, "Last, First"; the style shortens to "et al." itself
  date: 2018-07
  page-range: 143-163
  serial-number:
    doi: 10.1515/popets-2018-0025
  parent:
    type: periodical
    title: Proceedings on Privacy Enhancing Technologies
    volume: 2018
    issue: 3

# Conference paper: the proceedings are the `parent`
meiklejohn2013:
  type: article
  title: "A Fistful of Bitcoins: Characterizing Payments Among Men with No Names"
  author:
    - Meiklejohn, Sarah
    - Pomarole, Marjori
    - Jordan, Grant
    - Levchenko, Kirill
    - McCoy, Damon
    - Voelker, Geoffrey M.
    - Savage, Stefan
  date: 2013-10
  page-range: 127-140
  serial-number:
    doi: 10.1145/2504730.2504747
  parent:
    type: proceedings
    title: Proceedings of the 2013 Conference on Internet Measurement Conference (IMC '13)
    publisher:
      name: Association for Computing Machinery
      location: New York, NY

# Book
narayanan2016:
  type: book
  title: "Bitcoin and Cryptocurrency Technologies: A Comprehensive Introduction"
  author:
    - Narayanan, Arvind
    - Bonneau, Joseph
    - Felten, Edward
    - Miller, Andrew
    - Goldfeder, Steven
  date: 2016
  publisher:
    name: Princeton University Press
    location: Princeton, NJ
  serial-number:
    isbn: 978-0-691-17169-2

# Thesis
doe2025:
  type: thesis
  title: Thesis Title
  author: Doe, Jane
  date: 2025
  genre: Doctoral thesis
  publisher:
    name: Brno University of Technology, Faculty of Information Technology
    location: Brno
  url:
    value: https://example.org/thesis
    date: 2026-10-15            # access date -> "[Accessed 2026-10-15]"

# Whitepaper / technical report (also RFCs: genre "RFC 8484", publisher IETF)
nakamoto2008:
  type: report
  title: "Bitcoin: A Peer-to-Peer Electronic Cash System"
  author: Nakamoto, Satoshi
  date: 2008-10-31
  genre: Whitepaper
  publisher: Bitcoin.org
  url:
    value: https://bitcoin.org/bitcoin.pdf
    date: 2026-10-15

# Web page / specification (BIPs, EIPs, documentation)
bip32:
  type: web
  title: "BIP 32: Hierarchical Deterministic Wallets"
  author: Wuille, Pieter
  date: 2012-02-11
  publisher:
    name: Bitcoin Improvement Proposals
  url:
    value: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
    date: 2026-10-15

# EU legislation: an "article" in the Official Journal
mica2023:
  type: article
  title: >-
    Regulation (EU) 2023/1114 of the European Parliament and of the Council of
    31 May 2023 on markets in crypto-assets
  author:
    - name: European Parliament          # organisations use `name:`
    - name: Council of the European Union
  date: 2023-06-09
  page-range: 40-205
  parent:
    type: periodical
    title: Official Journal of the European Union L
    publisher:
      name: Publications Office of the European Union
    issue: 150
  url: http://data.europa.eu/eli/reg/2023/1114/oj

# Software
bitcoinCore:
  type: repository
  title: Bitcoin Core
  author:
    - name: Bitcoin Core contributors
  date: 2026
  url:
    value: https://github.com/bitcoin/bitcoin
    date: 2026-10-15
```

YAML gotchas:

- Quote titles that contain `:` (`"Bitcoin: A …"`); use `>-` for long titles.
- Dates are `YYYY`, `YYYY-MM` or `YYYY-MM-DD`.
- Quote ISBNs (`'978-…'`) if a YAML editor complains.
- Keys are `authorYEAR` in lower case (`nakamoto2008`); add a suffix for
  collisions (`buterin2014a`, `buterin2014b`) or use a short name for
  specifications (`bip32`, `mica2023`).

### Getting entries without typing them

**From a DOI:** doi.org returns BibTeX, which Hayagriva converts:

```bash
curl -sLH "Accept: application/x-bibtex" https://doi.org/10.1145/2504730.2504747 > /tmp/entry.bib
hayagriva /tmp/entry.bib >> bib/bibliography.yaml   # hayagriva is in the Nix shell
```

Then review the entry (key, title capitalisation, `parent`) by hand. DBLP and
Google Scholar ("Cite → BibTeX") also provide BibTeX.

**Zotero:** keep the references in Zotero and let them flow into the thesis
automatically, see [section 7](#7-zotero-automatic-bibliography).

**Different citation style:** download a `.csl` file (e.g. from
<https://www.zotero.org/styles>) into `bib/` and change `style:` in
`thesis.typ`. Typst also has built-in styles, e.g. `style: "ieee"`.

---

## 7. Zotero: automatic bibliography

Goal: you manage references only in Zotero; the thesis picks up every
addition or correction without any manual export.

```
Zotero desktop ── Better BibTeX "Keep updated" export ──┐
                                                        ├──► bib/zotero.bib ──► ./build.sh -w ──► thesis.pdf
zotero.org ────── ./zotero-sync.sh (Web API) ───────────┘
```

Typst reads BibLaTeX `.bib` files directly, so no conversion is needed.
`bib/zotero.bib` is generated (never edit it by hand); entries that are not in
Zotero can still go into `bib/bibliography.yaml`, and Typst combines both.

### One-time setup

1. **Zotero 8 and Better BibTeX.** Install the
   [Better BibTeX](https://retorque.re/zotero-better-bibtex/installation/)
   plug-in (BBT). It generates citation keys and keeps an exported `.bib` file
   up to date. Zotero 8 stores the keys in its own *Citation Key* field (shown
   in the item pane) and syncs them like any other field.

2. **A collection for the thesis.** Create a collection, e.g. *Thesis*,
   and keep all its references directly in it (subcollections are not part of
   the Web API export below). Adding items is quickest with the
   [Zotero Connector](https://www.zotero.org/download/connectors) browser
   extension (one click on a publisher or DOI page) or with *Add Item by
   Identifier* (the magic-wand button: paste a DOI, ISBN or arXiv ID).

3. **Citation key format.** *Settings → Better BibTeX → Citation keys*, set the
   formula to

   ```
   auth.lower + year
   ```

   which gives `nakamoto2008`, the convention used in this guide (BBT adds
   `a`, `b`, … to duplicates). Set it before you start citing: changing the
   formula later does not rename existing keys (only *right-click → Better
   BibTeX → Refresh* does), so citations in the text stay valid.

4. **Leaner export.** *Settings → Better BibTeX → Export*, "fields to omit from
   export": `abstract, file, keywords`. The bibliography does not use them and
   the file stays small and readable in diffs.

5. **Automatic export.** Right-click the collection → *Export Collection…* →
   format **Better BibLaTeX** → tick **Keep updated** → save as
   `bib/zotero.bib` in this repository
   (e.g. `C:\path\to\repository\bib\zotero.bib`). In *Settings →
   Better BibTeX → Automatic export*, choose **On change**; the same tab lists
   the export, where it can be changed or removed later.

6. **Tell Typst about it.** In `thesis.typ`:

   ```typst
   #bibliography(("bib/bibliography.yaml", "bib/zotero.bib"), style: "bib/iso-690-2022-numeric-ntk.csl")
   ```

### Daily workflow

1. Run `./build.sh -w` (and keep the PDF open in a non-locking viewer).
2. Add or fix a reference in Zotero. Within seconds BBT rewrites
   `bib/zotero.bib`, `build.sh` notices the change and rebuilds the PDF.
3. Cite it with its key: `@nakamoto2008`. The key is in the item pane
   (*Citation Key*).
4. Commit `bib/zotero.bib` together with the chapters, so that other machines
   (and reviewers) can build the thesis without Zotero.

**Citation picker (optional).** BBT's "cite as you write" endpoint opens
Zotero's search box and returns Typst citations; with `clipboard=yes` they land
on the clipboard, ready to paste:

```bash
curl -s "http://127.0.0.1:23119/better-bibtex/cayw?format=typst&clipboard=yes"
```

Bind it to a key in your editor, e.g. as a Zed task (`.zed/tasks.json`, run
via *task: spawn*):

```json
[
  {
    "label": "Zotero: pick citation",
    "command": "curl -s 'http://127.0.0.1:23119/better-bibtex/cayw?format=typst&clipboard=yes'",
    "hide": "always"
  }
]
```

### Without Zotero desktop: `zotero-sync.sh`

On a machine without Zotero (the NixOS box, CI), `./zotero-sync.sh` downloads
the same collection from zotero.org through the
[Zotero Web API](https://www.zotero.org/support/dev/web_api/v3/basics) and
writes `bib/zotero.bib`. It only rewrites the file when something changed, so a
running `./build.sh -w` rebuilds exactly when needed. Zotero desktop must have
sync enabled (*Settings → Sync*) for the items to be on zotero.org.

Setup, once per machine:

1. Create a key at <https://www.zotero.org/settings/keys> → *Create new private
   key*, with read-only access to your library. The same page shows your user
   ID ("Your userID for use in API calls is …"); it is a number, not your
   username. The API also tells you which user a key belongs to:

   ```bash
   curl -s https://api.zotero.org/keys/<API key>      # → {"userID": 1234567, "username": "…", …}
   ```

2. Find the collection **key** (8 characters, not the collection's name): open
   the collection in the web library, it is the last part of the URL
   (`…/collections/ABCD2345`); or list all collections with their keys:

   ```bash
   curl -s -H "Zotero-API-Key: <API key>" "https://api.zotero.org/users/<userID>/collections?limit=100" \
     | python -c "import sys, json; [print(c['key'], c['data']['name']) for c in json.load(sys.stdin)]"
   ```

3. Put both into `zotero.env` in the repository root. This file is git-ignored;
   never commit API keys:

   ```bash
   ZOTERO_LIBRARY=users/1234567      # or groups/<groupID> for a group library
   ZOTERO_COLLECTION=ABCD2345        # empty = the whole library
   ZOTERO_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxx
   ```

Then:

```bash
./zotero-sync.sh                               # one-off: "bib/zotero.bib updated (42 entries)"
while ./zotero-sync.sh; do sleep 60; done      # keep syncing (second terminal, next to ./build.sh -w)
```

Notes:

- **Same keys as on the desktop.** The Web API export uses the stored
  *Citation Key* field, i.e. the BBT keys synced from your desktop. Items added
  only on zotero.org have no stored key yet and get a generated one (like
  `nakamoto_bitcoin_2008`) until Zotero desktop with BBT assigns theirs.
- **One producer per file.** BBT and the Web API format the `.bib` slightly
  differently. Commit the file written by BBT on your main machine; use
  `zotero-sync.sh` where Zotero is not installed and do not commit its output
  there, otherwise every switch produces a noisy diff.
- **CI.** The same two commands work in a GitLab CI job: store
  `ZOTERO_LIBRARY`, `ZOTERO_COLLECTION` and `ZOTERO_API_KEY` as masked CI/CD
  variables and run `./zotero-sync.sh && ./build.sh` (the job image needs
  `bash`, `curl` and `typst`). With a pipeline schedule this gives a fresh PDF
  every night.

### Tips for entries in Zotero

- The ISO 690 output is only as good as the Zotero fields: *Place* and
  *Publisher* for books and reports, *DOI*/*ISBN* where available, and
  *Accessed* for web pages and online-only documents (it becomes
  "[Accessed …]").
- Use the matching item type: *Journal Article*, *Conference Paper* (fill the
  *Proceedings Title*), *Book*, *Report* (whitepapers, RFCs; set *Report
  Type*/*Report Number*), *Web Page*, *Thesis*. Check unusual types such as
  legislation in the PDF.
- A key that changed in Zotero (e.g. after *Refresh*) shows up as
  `error: label <key> does not exist in the document`; use the new key or set
  the old one back in the *Citation Key* field.
- The same key in `bib/bibliography.yaml` and `bib/zotero.bib` stops the build
  with `error: duplicate bibliography keys: …`: keep the entry in Zotero and
  delete the hand-written one.

---

## 8. Tools

| Task | Command |
|---|---|
| Build / watch | `./build.sh`, `./build.sh -w` |
| Download the Zotero collection | `./zotero-sync.sh` (see [section 7](#7-zotero-automatic-bibliography)) |
| Live preview in a browser | `tinymist preview --open thesis.typ` |
| Format all sources | `nix fmt` (typstyle with one sentence per line, plus nixfmt) |
| Lint | `tinymist lint thesis.typ` |
| Convert BibTeX → Hayagriva | `hayagriva refs.bib > refs.yaml` |
| List fonts Typst can see | `typst fonts` |
| Check fonts embedded in the PDF | `pdffonts thesis.pdf` (poppler-utils) |
| Page count, metadata | `pdfinfo thesis.pdf` |
| PDF/A for archiving (if required) | `typst compile --font-path fonts --pdf-standard a-2b thesis.typ` (same flags for `tinymist compile`) |

### Fonts

Body text and math use **New Computer Modern** (built into Typst; the same
design as LaTeX's Latin Modern). The title page needs **Open Sans Bold** and
code/URLs **New Computer Modern Mono**. In the web app, upload the font files
into the project if they are not offered; on the command line, install them or
pass a folder with them via `--font-path`.
Without them, the title page falls back to New Computer Modern and code to
DejaVu Sans Mono, with an `unknown font family` warning.

Typst packages cannot ship fonts, so this repository keeps them in `fonts/`
(free licences, see the README there); `build.sh` exports
`TYPST_FONT_PATHS=fonts`. When calling Typst yourself, add `--font-path fonts`,
and configure the editor as shown in [Live preview](#live-preview-in-the-editor).
Downloads: Open Sans <https://fonts.google.com/specimen/Open+Sans>, New Computer
Modern <https://ctan.org/pkg/newcomputermodern>.

### Formatting

`nix fmt` runs treefmt with typstyle using `--wrap-text=sentence`, which puts
every sentence on its own line (see [conventions](#10-writing-conventions)). Run
it before committing. Editors can format through tinymist (typstyle) as well,
but without the sentence wrapping configured here.

### Packages

Packages come from Typst Universe (<https://typst.app/universe/>) and are
downloaded on first use into the local cache. Useful ones for this thesis:

| Package | Purpose |
|---|---|
| `glossarium` | acronyms and glossary (see above) |
| `fletcher` | diagrams with nodes and arrows (transaction graphs, architectures) |
| `cetz` | general drawing (TikZ-like) |
| `lilaq` | data plots |
| `codly` | nicer code listings (line numbers, highlights) |
| `subpar` | sub-figures (a), (b) |

Check the current version on each package's Universe page and pin it in the import.

---

## 9. Pitfalls

| Problem | Fix |
|---|---|
| `veselyv@fit.vut.cz` → *label `<fit.vut.cz>` does not exist* | `@` starts a reference: write `veselyv\@fit.vut.cz` |
| "Figure Figure 1" | `@fig:x` already contains the word: write `@fig:x`, not `Figure~@fig:x` |
| Text suddenly italic or bold | `_` and `*` are markup: put identifiers, hashes and addresses in backticks or escape them (`\_`, `\*`) |
| `$100` starts math, `C#` starts code | escape: `\$100`, `C\#` |
| `<` followed by text and `>` becomes a label | escape: `\<` |
| Citation wraps to the next line alone | non-breaking space: `text~@key` |
| Image not found from a chapter | use root-relative `/figures/x.png` |
| Entry missing in the bibliography | it is not cited anywhere, or use `full: true` |
| `unknown font family` warnings | Open Sans / New Computer Modern Mono are not installed or not passed to Typst (`--font-path fonts`, see [Fonts](#fonts)) |
| Build fails, PDF "used by another process" | close the PDF in Foxit/Acrobat, use a non-locking viewer |
| `duplicate bibliography keys` | the key is both in `bib/bibliography.yaml` and in Zotero; delete one |
| New Zotero item does not appear | it is not cited yet, or the auto-export is paused (*Settings → Better BibTeX → Automatic export*) |

---

## 10. Writing conventions

- **One sentence per line.** Diffs and reviews then show changed sentences,
  not reflowed paragraphs. A blank line starts a new paragraph. `nix fmt`
  enforces this.
- **Label prefixes:** `ch:` chapters, `sec:` sections, `fig:` figures, `tab:`
  tables, `lst:` listings, `eq:` equations. Readable names
  (`fig:monero-ring-signature`) beat numbers.
- **One chapter per file**, figures in `figures/`, nothing absolute outside the repository.
- **Notes instead of comments** for open issues (`#inline-vv[…]`); they stay
  visible in the draft PDF, and `#note-outline()` collects them.
- **Git:** commit sources, not the PDF (`thesis.pdf` is git-ignored).

---

## 11. Learning resources

- Typst tutorial: <https://typst.app/docs/tutorial/>
- Guide for LaTeX users: <https://typst.app/docs/guides/guide-for-latex-users/>
- Reference documentation: <https://typst.app/docs/reference/>, e.g.
  [figure](https://typst.app/docs/reference/model/figure/),
  [table](https://typst.app/docs/reference/model/table/),
  [cite](https://typst.app/docs/reference/model/cite/),
  [bibliography](https://typst.app/docs/reference/model/bibliography/)
- Hayagriva file format: <https://github.com/typst/hayagriva/blob/v0.10.1/docs/file-format.md>
- FIT BUT thesis guidelines and the LaTeX template the Typst template follows:
  <https://www.fit.vut.cz/study/theses/>, rendered example:
  <https://cs.overleaf.com/latex/templates/fit-but-thesis-template-2025/mmphstqxpwpg>
- Packages: <https://typst.app/universe/>, in particular
  [drafting](https://typst.app/universe/package/drafting),
  [glossarium](https://typst.app/universe/package/glossarium)
- Tinymist (language server, preview, VS Code extension): <https://github.com/Myriad-Dreamin/tinymist>
- Community: forum <https://forum.typst.app/>, curated list <https://github.com/qjcg/awesome-typst>
- Citation styles: <https://www.zotero.org/styles>
- Better BibTeX for Zotero: <https://retorque.re/zotero-better-bibtex/>
  ([automatic export](https://retorque.re/zotero-better-bibtex/exporting/auto/),
  [citation keys](https://retorque.re/zotero-better-bibtex/citing/),
  [cite as you write](https://retorque.re/zotero-better-bibtex/citing/cayw/))
- Zotero Web API: <https://www.zotero.org/support/dev/web_api/v3/basics>

---

## License

This package is licensed under [MIT-0](https://opensource.org/license/mit-0);
see [LICENSE](LICENSE). Third-party parts keep their own licences: the VUT
logos and the citation style in `template/bib/`.
