# kaodiss

A [Typst](https://typst.app) template for dissertations, theses and books,
based on the [kaobook](https://github.com/fmarotta/kaobook) LaTeX class by
Federico Marotta, which in turn grew out of the doctoral thesis of Ken Arroyo
Ohori and the Tufte-LaTeX classes. kaodiss reimplements kaobook's design in
Typst, without code from kaobook (see [Acknowledgements](#acknowledgements)).

[![Chapter page of the example document](https://raw.githubusercontent.com/BWeigell/kaodiss/main/thumbnail.png)](https://github.com/BWeigell/kaodiss/releases/latest/download/kaodiss-example.pdf)

📄 **[Example document (PDF, 35 pages)](https://github.com/BWeigell/kaodiss/releases/latest/download/kaodiss-example.pdf)**: the document that
`typst init` creates, showing every element of the template.

## Features

**📐 The margin does the work.** Sidenotes instead of footnotes, margin notes
and margin figures, captions beside the figure, and a small table of contents
on every chapter page. Wide figures and tables span text and margin.

**🎓 Everything a thesis needs.** Title page with supervisors and date of
defence on its back, abstracts in two languages, acknowledgements, lists of
figures, tables, listings and algorithms, appendix and statutory declaration.
All of it is optional: leave it out, and you have a book.

**📚 Citations that point back.** Typst's `@key` syntax in three styles
(author–year after biblatex-nature, DIN alphanumeric, IEEE), and every
bibliography entry shows the pages on which it is cited.

**🔤 Abbreviations without bookkeeping.** `@api` is written out the first time
and short afterwards; the list at the end contains only the abbreviations you
used, with their pages. A glossary works the same way.

**🎨 Your colours.** Black and grey like kaobook by default, or five accent
colours of your choice, three ready-made palettes and three box styles for
challenges, objectives, definitions and theorems.

**🌍 English and German**, with the matching hyphenation, quotation marks and
terms, and a second language for the second abstract.

**✍️ Calm writing in VS Code.** A writing font, a centred text column, a word
count and local spelling and grammar checks, without code clutter or AI
suggestions while you type.

## Quick start

1. Install the fonts (see [Fonts](#fonts) below; on macOS:
   `brew install --cask font-tex-gyre-pagella font-tex-gyre-pagella-math font-tex-gyre-heros`).
2. Install Typst 0.15 or newer (`brew install typst`, `winget install Typst.Typst`,
   or see [typst.app](https://github.com/typst/typst#installation)) and, for VS
   Code, the Tinymist extension.
3. Start a new document from the template and compile it:

   ```sh
   typst init @preview/kaodiss:0.1.0 my-thesis
   cd my-thesis
   typst compile main.typ
   ```

In the [Typst web app](https://typst.app), choose "Start from template" and
search for kaodiss. If the TeX Gyre fonts are not available there, upload the
`.otf` files to the project.

### Installing from source

To use a version that is not (yet) on Typst Universe, clone or download the
[repository](https://github.com/BWeigell/kaodiss) and install it as the local
package `@local/kaodiss:0.1.0`:

```sh
sh kaodiss/scripts/install-local.sh
typst init @local/kaodiss:0.1.0 my-thesis
```

On Windows, copy the folder to
`%APPDATA%\typst\packages\local\kaodiss\0.1.0` (so that `typst.toml` ends up
directly in `0.1.0`) and replace `@preview/kaodiss` by `@local/kaodiss` in the
imports of the new document. `install-local.sh --link` instead links the folder
as `@preview/kaodiss:0.1.0`, for working on the template itself.

### Fonts

The template uses TeX Gyre Pagella (text), TeX Gyre Pagella Math (equations)
and TeX Gyre Heros (title page), as kaobook with newpxtext does. The fonts are
not included; install them once on your system:

- macOS (Homebrew):
  `brew install --cask font-tex-gyre-pagella font-tex-gyre-pagella-math font-tex-gyre-heros`
- Debian/Ubuntu: `sudo apt install fonts-texgyre fonts-texgyre-math`
- Windows and others: download the OpenType files from the GUST e-foundry
  ([Pagella](https://www.gust.org.pl/projects/e-foundry/tex-gyre/pagella),
  [Heros](https://www.gust.org.pl/projects/e-foundry/tex-gyre/heros),
  [Pagella Math](https://www.gust.org.pl/projects/e-foundry/tg-math)) or from
  CTAN ([tex-gyre](https://ctan.org/pkg/tex-gyre),
  [tex-gyre-math](https://ctan.org/pkg/tex-gyre-math)) and install them by
  double click.

Instead of installing them, you can also put the `.otf` files in a folder and
pass it to Typst: `typst compile --font-path <folder> main.typ`, or in VS Code
`"tinymist.fontPaths": ["<folder>"]`. Check with `typst fonts` that
"TeX Gyre Pagella" is listed. Without the fonts, Typst falls back to Palatino
or Libertinus and the layout changes.

## Usage

```typ
#import "@preview/kaodiss:0.1.0": *

#show: kaodiss.with(
  lang: "en",                      // or "de"
  title: [Title of the Thesis],
  subtitle: [Subtitle],
  author: "Jane Doe",
  degree: "Doctor of Philosophy (Ph.D.)",
  university: "Example University",
  department: "Department of Computer Science",
  chair: "Research Group on Example Systems",
  place: "Example City",
  date: datetime(year: 2026, month: 10, day: 1),
  // logos: (image("figures/logo.pdf", height: 40mm),),
  supervisors: ([Prof. A \ Department \ University],),
  advisors: ([Prof. B \ Department \ University],),
  abstract: include "chapters/abstract.typ",
  abstract-2: include "chapters/zusammenfassung.typ",  // optional
  abstract-2-lang: "de",
  acknowledgements: include "chapters/acknowledgements.typ",
  bibliography: bibliography("references.bib"),
  abbreviations: (ai: ("AI", "Artificial Intelligence")),
)

#part[Introduction and Foundations]
= Introduction
...
```

The document consists of
- **front matter** (wide layout, no running heads): title page, its back
  side, abstract, abstract in a second language, acknowledgements, contents and (optionally)
  the lists of figures, tables and listings;
- **main matter** (1.5-column layout): parts, chapters, running heads;
- **back matter** (wide layout): bibliography, abbreviations, glossary,
  (optionally) the lists, appendix and declaration.

### Books and other documents

Everything that belongs to a thesis is optional. For a book, set
`degree-type: none` and leave out `supervisors`, `advisors`, `defense`,
`abstract` and `declaration`; the title page then shows title, subtitle,
author, date, logos and publisher-like lines (`university`, `department`,
`chair` can hold any text).

### Parameters

| Parameter | Default | Meaning |
|---|---|---|
| `lang` | `"en"` | Language of the template's terms: `"en"` or `"de"` |
| `title`, `subtitle`, `author` | | Title page and PDF metadata |
| `degree-type`, `degree-for`, `degree` | `"Dissertation"`, auto, `none` | Lines above the title ("Dissertation / for the degree of / …") |
| `university`, `department`, `chair` | `none` | Lines at the bottom of the title page |
| `place`, `date` | `none`, today | Year on the title page, copyright line |
| `logos` | `()` | First image in the middle of the title page, further ones below the institution |
| `supervisors`, `advisors` | `()` | Arrays of content, printed on the back of the title page |
| `defense`, `transparency`, `copyright`, `title-back-extra` | | Further entries on the back of the title page |
| `abstract`, `acknowledgements` | `none` | Front matter chapters |
| `abstract-2`, `abstract-2-lang`, `abstract-2-title` | `none`, `"de"`, auto | Second abstract in another language, set with that language's hyphenation and quotes; heading from the built-in terms (`"en"`, `"de"`) or `abstract-2-title` |
| `bibliography` | `none` | `bibliography("references.bib")` |
| `citation-style` | `"nature-authoryear"` | `"nature-authoryear"`, `"alphadin"`, `"ieee"`, or a CSL file as bytes |
| `backrefs` | `true` | "(cited on pages 3, 17)" after every bibliography entry |
| `abbreviations`, `glossary` | `(:)` | See below |
| `lists` | `("figures", "tables", "listings")` | Lists to print; also `"algorithms"`. Empty lists are left out |
| `lists-position` | `"front"` | `"front"` (after the table of contents, as in kaobook) or `"back"` (after the bibliography) |
| `appendix` | `none` | Content of the appendix (chapters numbered A, B, …) |
| `appendix-before-bibliography` | `false` | Position of the appendix |
| `declaration`, `declaration-position` | `none`, `"back"` | Statutory declaration |
| `toc-depth`, `numbering-depth` | `3`, `3` | Levels in the table of contents / numbered levels |
| `margin-toc` | `true` | Section list in the margin of each chapter page |
| `colors` | `none` | Accent colours, see below |
| `box-style` | `"tinted"` | `"tinted"`, `"bar"` or `"banner"` |
| `draft` | `false` | Shows the text block and the margin column |

### Elements

| Element | Usage |
|---|---|
| Part | `#part[Title]` or `#part[Title][Second line]` |
| Chapter motto | `#epigraph(attribution: [Name #cite(<key>, form: "year")])["Quote"]` |
| Sidenote | `#sidenote[...]`; `#footnote[...]` gives the same result |
| Margin note | `#marginnote[...]` (unnumbered) |
| Margin figure | `#marginfigure(image(...), caption: [...], label: <fig:x>)` |
| Wide figure/table | `#wide[#figure(...)]` |
| booktabs rules | `toprule`, `midrule`, `bottomrule` inside `table(...)` |
| Run-in heading | `#paragraph[Title.] Text …` |
| Boxes | `#challenge[...]`, `#objective[...]` |
| Theorems | `#definition(title: [...])[...]`, `#corollary`, `#theorem`, `#lemma`, `#proposition`, `#example`, `#remark` |
| Algorithms | `#algorithm(..., caption: [...])` (e.g. with the `lovelace` package) |
| TODO | `#todo[...]` (red, in the margin) |
| Signature | `#signature(place: "City", date: [...], author: "...")` |

Figures put their caption into the margin, aligned with their bottom; tables
and listings align it with their top. Figures, tables, listings and equations
are numbered per chapter.

### Colours

Five accent colours with fixed roles; without a setting everything is black
and grey as in kaobook (only citation years are blue).

| Role | Colours |
|---|---|
| `primary` | numbers of chapters, sections and parts, margin table of contents, chapter and running-head rules, list markers, sidenote numbers, rules of code listings |
| `link` | years in citations, cross-references, URLs |
| `challenge` | Challenge boxes |
| `objective` | Objective boxes |
| `definition` | Definition, corollary, theorem, lemma, proposition, example and remark boxes |

```typ
colors: (primary: rgb("#1d4e89"), challenge: rgb("#b5403a")),  // missing roles keep the default
colors: "ocean",                                               // or "forest", "berry"
colors: palettes.ocean + (challenge: rgb("#c0392b")),         // adapt a palette
box-style: "tinted",                                           // or "bar", "banner"
```

`box-style` selects the look of all boxes: `"tinted"` (light background,
coloured title and rule; the default), `"bar"` (white with a coloured bar on
the left) or `"banner"` (title on a full-colour bar). Dark colours work best,
because the banner title is set in white.

### Abbreviations and glossary

```typ
abbreviations: (
  ai: ("AI", "Artificial Intelligence"),
  api: (short: "API", long: "Application Programming Interface",
        long-plural: "Application Programming Interfaces"),
),
glossary: (
  oracle: (name: "Oracle", description: [A human annotator ...]),
),
```

Abbreviations can also be loaded from a file: `abbreviations: yaml("abbreviations.yaml")`.

In the text, `@ai` prints "Artificial Intelligence (AI)" the first time and
"AI" afterwards. `@ai[pl]`, `@ai[long]`, `@ai[short]` and `@ai[full]` select
a form; `#acs`, `#acl`, `#acf`, `#acp` do the same as functions. The lists at
the end contain only entries that are used, with all pages on which they occur.
Do not use the key of an abbreviation as a label for anything else.

### Citation styles

- `"nature-authoryear"`: the biblatex setup `bibstyle=nature`,
  `citestyle=authoryear`, `maxcitenames=1`, `sorting=nyt` and `backref=true`.
  Author and year in the text ("Settles 2009", "Adadi *et al.* 2018"); only the
  year is coloured, as biblatex links only the year. The bibliography is
  numbered and sorted by author, in the style of biblatex-nature.
- `"alphadin"`: DIN 1505-2 alphanumeric ("[Set09]"), common in German-speaking
  countries.
- `"ieee"`: numeric ("[1]").

All three styles print back references ("cited on page …").

## Writing in VS Code

The template ships a `.vscode` folder (copied by `typst init`) that turns VS
Code into a calmer writing environment for `.typ` files; other file types keep
your normal settings.

- Editor font [IBM Plex Mono](https://github.com/IBM/plex) (install it once:
  `brew install --cask font-ibm-plex-mono`, `sudo apt install fonts-ibm-plex`,
  or from the [releases](https://github.com/IBM/plex/releases); without it VS
  Code uses Menlo or its normal font), larger line height, soft wrap at 80 characters, no minimap, line
  numbers or code decorations, no word suggestions and no AI inline
  suggestions while typing.
- Zen mode (`Cmd/Ctrl+K Z`) centres the text column; `View: Toggle Centered
  Layout` does the same without hiding the rest of VS Code.
- Status bar: compile status, words and characters (Tinymist).
- Spelling and grammar with [LTeX+](https://ltex-plus.github.io/ltex-plus/)
  (LanguageTool, runs locally). The document language is set by
  `ltex.language`; a single file switches with a first line
  `// LTeX: language=de-DE` (as in `chapters/zusammenfassung.typ`). Setting
  `ltex.additionalRules.motherTongue` to your native language adds warnings
  about false friends. Words added with "Add to dictionary" are stored in
  `.vscode/ltex.dictionary.en-US.txt`.
- The extensions Tinymist and LTeX+ are recommended when the folder is opened.

## Differences to LaTeX

- LaTeX stretches the space between paragraphs so that every page ends at the
  same height (`\flushbottom`). Typst cannot do this, so pages end where the
  last line ends, and a page break may fall one line earlier or later than in
  LaTeX.
- microtype's font expansion is approximated by Typst's character-level
  justification (`par.justification-limits`).
- Hyphenation patterns differ slightly from TeX's.

## Files

```
lib.typ               entry point, the kaodiss() function
src/metrics.typ       all measurements (page, type sizes, spacing)
src/i18n.typ          English and German terms
src/page.typ          layouts, running heads, empty pages
src/headings.typ      parts, chapters, sections, margin table of contents
src/notes.typ         sidenotes and margin notes
src/figures.typ       figures, captions, tables, listings
src/boxes.typ         challenge/objective boxes and theorems
src/abbreviations.typ abbreviations and glossary
src/bibliography.typ  citation styles and back references
src/lists.typ         table of contents and lists of figures etc.
src/frontmatter.typ   title page and its back side
src/theme.typ         accent colours, palettes
csl/                  citation styles
themes/kaolst.tmTheme code colours (Pygments default, as in minted)
template/             example document (typst init)
```

## Acknowledgements

kaodiss would not exist without
[kaobook](https://github.com/fmarotta/kaobook) by Federico Marotta, which is
in turn based on the doctoral thesis of
[Ken Arroyo Ohori](https://3d.bk.tudelft.nl/ken/en/) and on the
[Tufte-LaTeX](https://tufte-latex.github.io/tufte-latex/) classes. kaodiss is an
independent implementation of kaobook's design in Typst: it contains no code
from kaobook, and the layout values in `src/metrics.typ` were taken from
kaobook's documentation and measured in PDFs typeset with it. kaobook itself is
distributed under the LaTeX Project Public License 1.3c.

Thanks also to the authors of
[marginalia](https://github.com/nleanba/typst-marginalia), which places the
notes in the margin, of the Citation Style Language styles that the citation
styles are based on ([citationstyles.org](https://citationstyles.org/)), of the
TeX Gyre fonts (GUST e-foundry) and of IBM Plex (IBM).

## Related projects

- [haobook](https://github.com/ParaN3xus/haobook), a book template inspired
  by kaobook with margin notes, margin captions and a margin table of
  contents. kaodiss is an independent implementation that adds what a thesis
  needs (title page and its back side, abbreviations, back references in the
  bibliography, boxes, German) and follows kaobook's measurements and fonts
  more closely.
- [bookly](https://typst.app/universe/package/bookly), a book template with a
  Tufte-style mode.
- [tufte-memo](https://typst.app/universe/package/tufte-memo) and
  [toffee-tufte](https://typst.app/universe/package/toffee-tufte), Tufte-style
  documents with sidenotes.

## Licences

See `LICENSE` for the details.

- Template code: MIT.
- `template/` (the example document copied by `typst init`): MIT-0, so
  documents created from it need not carry any licence notice.
- `csl/`: CC BY-SA 3.0. The styles are modified versions of the Nature, IEEE
  and DIN 1505-2 (alphanumeric) styles of the
  [Citation Style Language](https://citationstyles.org/) project, taken from
  its [style repository](https://github.com/citation-style-language/styles);
  each file names its original authors and links to the style it is based on.
  The modifications are under the same licence.
- No fonts are included. The fonts that the template uses have their own
  licences (TeX Gyre: GUST Font License; IBM Plex Mono: SIL Open Font
  License 1.1).
- Dependency (downloaded by Typst, not included):
  [marginalia](https://typst.app/universe/package/marginalia), Unlicense.
