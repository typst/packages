# How Sheaffer is organized and where to customize it

This guide shows which files to edit to change the look and content of the
template. Almost all layout settings live in `src/`.

## Project map

```text
src/
  lib.typ            public entry point: exports the package functions
  _constants.typ     color, fonts, indents, and spacing
  _style.typ         main typography, headings, links, and headers/footers
  _title_page.typ    title page
  _theorems.typ      theorems, definitions, proofs, and other blocks
  _epigraph.typ      epigraphs

template/
  main.typ           starter sheaf theory conspectus

typst.toml           package name, version, and metadata
Justfile             build, install, and preview commands
scripts/             package and local-version removal scripts
.github/workflows/   package publishing
```

`template/main.typ` is the sample for **new** documents. After `typst init` it is
copied to a separate folder, for example `my-notes`. Changes to the original
template do not overwrite an already created document.

## What to change

### Accent color

Open `src/_constants.typ` and change `ACCENT`:

```typst
#let ACCENT = color.rgb("#e73")
```

Ready-made palette options (`BLUE`, `ORANGE`, `CYAN`, `VERMILION`, `GRAY`) are
declared next to it. `ACCENT` is used in accent lines and margin notes. All local
links (footnote numbers, theorem references, pages, and chapters) are
`VERMILION`, external URLs are `BLUE`. Syntax highlighting is also built from the
palette (`_code-theme` in `_style.typ`): keywords `BLUE`, strings `VERMILION`,
functions `ORANGE`, numbers `CYAN`, comments a darkened `GRAY`.

All palette colors are exposed through the package's public interface, so you can
use them in your document without editing the source:

```typst
#import "@preview/sheaffer-notes:0.1.1": BLUE, ACCENT

#text(fill: BLUE)[Blue text] and #wrappar(color: BLUE)[a blue note].
```

### Paper size and margins

The page size and margins are set in `template/main.typ`:

```typst
#set page(
  width: 176mm,
  height: 250mm,
  margin: (top: 18mm, bottom: 20mm, left: 21mm, right: 17mm),
)
```

This is portrait ISO B5. Change the width, height, and margins here. To change
the page of an already created document, edit the corresponding block in
`my-notes/main.typ`.

Set the page and margins **before** `#show: style`: the style adds only headers
and footers and does not override the page geometry.

### Fonts, indents, and spacing

In `src/_constants.typ`:

- `FONTS.body` — body text;
- `FONTS.heading` — headings;
- `FONTS.math` — math;
- `FONTS.code` — code blocks and external URLs;
- `INDENT` — first-line and list indent;
- `LEADING` — leading within paragraphs;
- `SPACING` — space between paragraphs.

By default body text and headings use `New Computer Modern`, math uses
`New Computer Modern Math`, and code uses `JetBrains Mono`.

You can change fonts directly in the document without touching the package: pass
a dictionary to `style`. You only need to specify the keys you change; the rest
come from `FONTS`:

```typst
#show: style.with(fonts: (
  body: "STIX Two Text",
  math: "Stix Two Math",
))
```

The same `FONTS` dictionary is exported from the package if you only need read
access: `#import "@preview/sheaffer-notes:0.1.1": FONTS`.

Use font names available in your Typst installation.

Vertical spacing between blocks is set in `_style.typ`: display equations use
`LEADING` above, theorem-like blocks use `SPACING` (zero if a chapter or section
heading is above or it is the top of a page), proofs use `SPACING` before, and
display lists use `2 × LEADING` after. A level-three heading has `1em` above. An
inline enum remains part of the paragraph and does not get display-list spacing.

### Headings, links, and headers/footers

The settings live in `src/_style.typ`:

- `_style-heading` controls chapters, sections, and subsections;
- `_style-link` controls the appearance of links;
- `_header`, `_footer` control headers, footers, and page numbers;
- `_style-body` controls body text and lists;
- `_style-figures` controls figures, tables, and captions.

The current color of lines and accent elements comes from `ACCENT`, local links
from `VERMILION`, and external URLs from `BLUE` (all in `_constants.typ`). If you
change the order or logic of the `show` rules, keep `#show: style` at the end of
your document settings: the spacing handler must remain last. Body text uses a
1.4em first-line indent.

The header is shifted down from the center of the top margin by `HEADER-DY`
(3mm), declared in `_constants.typ`. The margins and text block are unchanged, so
the gap between the header and the text shrinks by the same amount.

First-line indent is enabled (`first-line-indent: (amount: 1.4em, all: false)` in
`_style-body`): Typst applies it to consecutive paragraphs. The spacing handler
inserts a zero-width space after a theorem (a workaround for typst#3206) so that
the paragraph after a theorem gets an indent like a normal consecutive
paragraph.

Subsections (`===`) are automatically placed in a block as wide as the heading,
but no wider than half the line. The following paragraph wraps around the block;
after its bottom edge the rest of the paragraph continues at full width.

```typst
=== Flabby sheaves
Here begins a paragraph that automatically wraps around the heading block.
```

Subsubsections (`====`) remain inline headings. Write the text on the next line
without a blank line:

```typst
==== Refinement
I continue writing my text here.
```

For a short note in the outer column, use `wrappar` directly before the paragraph
that should wrap around it:

```typst
#wrappar[A short margin note.]
This paragraph will wrap around the note. #lorem(40)
```

The side is chosen automatically based on the page number. The note width is the
smaller of its natural width and a limit that defaults to 60% of the line. The
limit is set with the `width` parameter, which accepts a fraction or an absolute
length: `#wrappar(width: 45%)[...]` or `#wrappar(width: 7cm)[...]`. By default
the note text is printed in `ACCENT`, at `0.8em`, with a small inset and no
background; the top inset is zero so the note aligns with the first line of the
paragraph. The inset on the page-edge side is also zero, so the note text sits
flush with the outer margin; the other sides are set by `inset`. Note text is not
justified.

`wrapnote` is the same note but with the footnote counter: at the declaration
point an inline superscript marker appears, taken from the `footnote` counter,
and the same number appears at the start of the note; the note is set in `BLUE`.
`wrapnote` and ordinary footnotes share one counter and reset together at the
start of a chapter; `wrapnote` does not appear in the footnote list at the bottom
of the page — the text lives only in the margin. The number is anchored at the
note's position in the text, so the numbers follow source order even if a
footnote sits inside the wrapped paragraph. As with `wrappar`, place the note
directly before the paragraph that should wrap around it:

```typst
#wrapnote[A margin note.]
This paragraph wraps around the note. #lorem(30)
```

The marker behaves like a footnote: `text#wrapnote[...]` inserts the number right
after the word, and the note wraps around the next paragraph:

```typst
Caveat#wrapnote[A margin clarification.] continuation of the paragraph.
```

The `width`, `size`, and `inset` parameters of `wrapnote` are the same as for
`wrappar`; there is no need to set a color — it is always `BLUE`.

You can refer to a note with a footnote: label it and put `#footnote(<wn1>)` in
the text — the marker repeats the note's number in blue and links to it:

```typst
#wrapnote[A remark on the spot.] <wn1>
A paragraph with a named footnote.#footnote(<wn1>) continuation.
```

### Number in place, text separately

Sometimes you need the number in the middle of a sentence and the note text
below, next to a whole paragraph. LaTeX does this with `\footnotemark` and
`\footnotetext`. Here it is `wrapnotemark` and `wrapnote`: `wrapnotemark()`
places a blue superscript number, taking the value of the footnote counter, and
draws nothing in the margin; the next `#wrapnote[...]` in the text takes that
same number instead of the next counter value, so the pair shares one number, and
the note itself does not get a second inline marker:

```typst
A mark#wrapnotemark() in a sentence. A footnote#footnote[An ordinary footnote.]

#wrapnote[The note text wraps around this paragraph.]
The paragraph that wraps around it. #lorem(30)
```

Numbers from `wrapnotemark` share the counter with ordinary footnotes and
`wrapnote` and reset with them at the start of a chapter. Pairs are matched in
order: the first mark to the first note, the second to the second, and so on; a
mark without a note simply has no margin text.

### Theorems and other math blocks

`src/_theorems.typ` contains `theorem`, `proposition`, `lemma`, `corollary`,
`definition`, `proof`, `example`, `solution`, and `remark`.

- To rename a block label, change the line with its name, for example
  `thm-env("Theorem")`.
- The kind word ("Theorem", "Lemma", "Proposition", "Corollary", "Definition")
  and the number are bold in normal case via `fmt: strong` (the default);
  smallcaps is not used. Proof, remark, and solution use an italic label
  (`fmt: emph`), and examples use plain text (`fmt: it => it`).
- To change the heading style, set the `fmt` parameter of the corresponding
  `thm-env`.
- To change the content style, set the `body-fmt` parameter.

`src/lib.typ` is the public list of package functions. If you add a new function
in a separate module and want to call it in your document with `*`, export it
there.

### Condition lists and inline enum

For multi-level conditions use `conditions`: inside it the normal Typst `+`
syntax works, and nested levels keep their indentation:

```typst
#conditions[
  + First condition
    + Nested refinement
  + Second condition
]
```

For an enumeration right inside a paragraph use `inline-enum`. Items use the
normal `+` syntax; by default labels are letters, items are separated by
semicolons, and the last item is preceded by a separator and the conjunction
"and":

```typst
Properties: #inline-enum[
  + continuity
  + differentiability
  + integrability
].
```

You can change the numbering pattern with `numbering-style`, for example to
`"(i)"`. The `separator` parameter sets the separator between items, including
before the conjunction; `conjunction` sets the conjunction before the last item.

### References to document elements

Ordinary `@label` references are automatically rendered in parentheses with an
abbreviated type: `(see Thm. 1.2)`, `(see Fig. 1)`, `(see Tab. 1)`,
`(see Eq. 1)`. Chapters, sections, and equations use the supplements `Ch.`,
`Sec.`, and `Eq.` respectively. Page references via
`#ref(<label>, form: "page")` are rendered as `(see p. 5)`.

In internal references only the numbers are highlighted in `VERMILION`, for
example `(see Eq. 8)`. External URLs stay blue (`BLUE`).

Display equations are numbered automatically and continuously: `(1)`, `(2)`,
`(3)`, and so on throughout the document. A label is needed only to reference an
equation. To leave a specific equation unnumbered, use
`#math.equation(numbering: none)` or place it in a block with numbering disabled.

To group references by type use `refs`, passing labels in the desired order:

```typst
#refs(<tab_one>, <tab_three>, <tab_four>, <fig_seven>)
```

The result: `(see Tab. 1, 3, 4 and Fig. 7)`. The numbers remain links; external
URLs and bibliography citations keep their own styling.

### Footnotes

Footnotes are numbered within a chapter and remain clickable. Only the number is
highlighted in the accent color — both in the text and in the footnote list; the
footnote text itself uses the body color:

```typst
Text with a footnote#footnote[An explanation.] and a reference to it.
```

To reference a footnote, label it and use `@fn` or `#footnote(<fn>)`:

```typst
Text#footnote[An explanation.] <fn>
Repeated reference: @fn.
```

### Title page and document content

The title page layout is defined in `src/_title_page.typ`. Set its text, the
document title, and the author via `#set document(...)` and `#title-page(...)`
in `template/main.typ` or in your own `my-notes/main.typ`.

Change the structure of the starter document — chapters, formula examples, and
demo blocks — in `template/main.typ`. This affects new projects. For your current
notes, edit `my-notes/main.typ`.

## Package and version

`typst.toml` configures the package name, version, author, description, and
repository link. The packaging scripts read the name and version from this file.
When releasing a new version, keep the version number in sync with the import in
`template/main.typ` and create a matching Git tag `v...`.

The registry repository for publishing is set in
`.github/workflows/release.yml` (`REGISTRY_REPO`). The workflow also requires the
GitHub secret `REGISTRY_TOKEN`.

## Applying changes and checking

`template/main.typ` imports `@preview/sheaffer-notes`, so to test the package that
is actually imported, first install a local preview copy, then build the
document:

```sh
just install-preview
typst compile --root . template/main.typ /tmp/sheaffer-notes.pdf
```

`just install` installs the library into the `@local` namespace and is needed to
test imports from `@local/sheaffer-notes`. To create a new document from the
template, run `typst init @preview/sheaffer-notes:0.1.1 my-notes`; you can build
it with `typst compile my-notes/main.typ`.

To rebuild the template preview after changing the layout or the starter
document, run:

```sh
just thumbnail
```

The command creates `thumbnail.png` and `thumbnail_pages.png`. It requires Typst,
ImageMagick, and `optipng`.
