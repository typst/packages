# measured-jair

A Typst template for the **Journal of Artificial Intelligence Research (JAIR)**.

JAIR ships a LaTeX-only author kit. This package reproduces that layout in
Typst so you can draft and submit in Typst — JAIR accepts submissions as PDF —
without hand-porting a LaTeX class.

It is called *measured* because every dimension in it was measured on PDFs
compiled with the real `jair.cls`, not copied from the class by eye. This is a
community port, not an official JAIR package.

```sh
typst init @preview/measured-jair:0.1.0
```

## Provenance

The template follows `jair.cls` (2025/08/15), the class JAIR adopted for volume
83 onward. `jair.cls` loads `acmart` with `[acmlarge, natbib=false, screen]`,
and acmart in turn loads **`amsart`** at 10pt — *not* `article`. That matters:
amsart's size ladder differs from the familiar one at every step, so a template
built on `article`'s sizes is wrong everywhere.

Every value below was read out of the class files and then **verified by
measuring compiled reference PDFs** — the sample in the JAIR Author Kit and a
second document compiled with `jair.cls` on an unfilled page, so that TeX's
stretchable glue sits at its natural size. Positions were taken from the
glyph outlines of a 600 dpi render, so they do not depend on font metrics.

### Type

| Element | LaTeX | amsart 10pt | Reference | Template |
| --- | --- | --- | --- | --- |
| Body | `\normalsize` | 10 / 12 | 9.96, b2b 11.95 | 9.96, b2b 11.95 |
| Abstract | `\small` | 9 / 11 | 8.97 | 8.97 |
| Sections and subsections | `\large` | 10.95 / 13 | 10.91 | 10.91 |
| Author names | `\Large` | 12 / 14 | 11.96 | 11.96 |
| Title | `\LARGE` | 14.4 / 17 | 14.35 | 14.35 |
| Head, foot, footnotes | `\footnotesize` | 8 / 10 | 7.97 | 7.97 |
| Line numbers (`review`) | `\scriptsize` | 7 / 8 | 6.97 | 6.97 |

jair.cls overrides both `\@secfont` and `\@subsecfont`, so sections and
subsections share one size — unlike stock acmart. Levels 3 and 4 use the
class's run-in faces (sans italic and serif italic, each with a trailing
period); see Known deviations for how far the run-in behavior is reproduced.

### Layout

acmart's dimensions are TeX points (1/72.27 in); Typst's `pt` is the big point
(1/72 in), so every copied value is scaled by 72/72.27. `includeheadfoot` means
the 78pt/114pt margins bound header + text + foot, not the text alone: the 13pt
head and 14pt headsep come out of the top margin.

| Element | Reference | Template |
| --- | --- | --- |
| Page | 612 × 792, two-sided, one column | ✓ |
| Text left edge | 80.7 | 80.7 |
| Running head | 79.70 | 79.70 |
| First body line | 106.93 | 106.86 |
| Title | 103.57 | 103.44 |
| Running foot | 670.35 | 670.37 |
| Line numbers (`review`) | x 54.6, pure red, none on p.1 | x 54.6, pure red, none on the p.1 title block |
| Running-head separator | 7.97 each side of the bullet | 7.97 |
| First-page footnote block | flush at the text edge | flush |

### Vertical spacing

Typst has no stretchable glue and gives text lines a fixed 1em box, so the
class values cannot be copied directly. Each transition below was fitted so
that the ink-to-ink distance matches a `jair.cls` document on an unfilled page.

| Transition | Class value | Reference | Template |
| --- | --- | --- | --- |
| Text → display equation | `0.35\baselineskip` plus stretch | 6.1–6.7 | 6.2 |
| Display equation → text | same | 6.1–6.8 | 6.7 |
| Text → figure | `\intextsep` 12pt | 12.1 | 12.1 |
| Figure → caption | `\abovecaptionskip` 10pt | 13.3 | 13.4 |
| Figure caption → text | | 15.8 | 16.1 |
| Table caption → top rule | | 13.2 | 12.7 |
| Table rule → row → rule | booktabs | 4.7 / 5.3 / 4.9 / 5.4 | 4.1 / 5.9 / 4.7 / 5.6 |
| Subsection → level-3 heading | `-.5\baselineskip` | 7.8 | 7.8 |
| Text → level-4 heading | `-.5\baselineskip` | 8.5 | 8.5 |
| Text → list | `\topsep` = `\smallskipamount` | 4.8 | 4.9 |
| Last author → abstract | | 9.2 | 9.5 |
| Abstract and JAIR blocks | `\medskip` | 7.1 / 7.2 | 6.8 / 7.2 |
| JAIR reference format → first heading | `\bigskip` merged with the section skip | 12.4 | 12.4 |

The baseline grid is pinned with `top-edge`/`bottom-edge` rather than left to
font metrics, so spacing holds at amsart's values whichever font resolves —
checked to give the same grid with Linux Libertine and Libertinus Serif. That
matters on the Typst web app, where the font set differs.

## Usage

```typ
#import "@preview/measured-jair:0.1.0": jair, toprule, midrule, botrule

#show: jair.with(
  title: "Your Article Title",
  short-title: "Short Title",              // running head
  authors: (
    (
      name: "Ada Lovelace",
      affiliation: "Analytical Engine Institute, United Kingdom",
      contact-affiliation: "Analytical Engine Institute, London, United Kingdom",
      email: "ada@example.org",
      orcid: "0000-0000-0000-0000",
      corresponding: true,
    ),
  ),
  short-authors: "Lovelace",               // running head
  abstract: [Your abstract. JAIR prints it with no "Abstract" heading.],
  track: "Insert JAIR Track Name Here",    // omit unless in a special track
  associate-editor: "Insert JAIR AE Name",
  volume: "83", article: "1",
  pubdate: "August 2025", year: "2025",
  doi: "10.1613/jair.1.xxxxx",
  review: true,                            // line numbers, as the JAIR example does
  received: "Received 20 February 2007; accepted 5 June 2009",
  acknowledgements: [Thanks to ...],
  bibliography: bibliography("refs.bib", title: [References],
                             style: "american-psychological-association"),
  appendix: [ = Supplementary material ],
)

= Introduction
...

#figure(
  table(columns: 2, toprule, table.header[*A*][*B*], midrule, [1], [2], botrule),
  caption: [Tables are captioned above.],
)
```

### Parameters

| Parameter | Default | Purpose |
| --- | --- | --- |
| `title` | required | Article title; used in the running head and the JAIR reference format. |
| `short-title` | `title` | Running-head form of the title. Give one whenever the title is longer than a line; the running head does not truncate. |
| `authors` | `()` | Array of dictionaries. `name` (a string) is required; `affiliation`, `email`, `orcid`, `corresponding` and `contact-affiliation` (the longer form printed in the contact footnote) are optional. |
| `short-authors` | derived | Running-head author list. acmart's default is the full names — "A", "A and B", "A, B, and C" — and that is what the template derives; the JAIR sample overrides it with surnames, so pass e.g. `"Xu, Hutter, Hoos & Leyton-Brown"` for that look. |
| `abstract` | `none` | Printed in `\small` with no heading. |
| `track` | `none` | JAIR Track line; printed only when given. |
| `associate-editor` | `"Insert JAIR AE Name"` | JAIR Associate Editor line. Printed unconditionally, as jair.cls does; replace the placeholder. |
| `volume`, `article` | `"1"`, `"1"` | Running head/foot and the reference format. Placeholders until the journal assigns them. |
| `pubdate`, `year` | `none` | Publication month and year for the foot, the reference format and the copyright line. Each is omitted from the output while `none`. |
| `doi` | `none` | Printed in the reference format and the license notice when given. |
| `received` | `none` | Printed in `\small` at the end, e.g. "Received … ; accepted …". |
| `acknowledgements` | `none` | Unnumbered section before the references. |
| `appendix` | `none` | Set after the references, headings lettered. |
| `copyright-holder` | `none` | Replaces "Copyright held by the owner/author(s)." with "*holder*." |
| `review` | `false` | Line numbers restarting on every page, like `\documentclass[review]{jair}`. |
| `anonymous` | `false` | One "ANONYMOUS AUTHOR(S)" line, no contact footnote, "Anonymous" in the running head. JAIR does not use blind review; for preprints or other venues. |
| `bibliography` | `none` | Pass a `bibliography(...)` call. |
| `keywords`, `ccs` | `()`, `none` | Exist because acmart supports them. See the next section. |

Headings: levels 1–3 are numbered (`1`, `1.1`, `1.1.1`), level 4 and below
are not, matching `secnumdepth` 3. Levels 5 and 6 fall back to the level-4
face.

`toprule`, `midrule` and `botrule` are the booktabs rules acmart loads:
0.08em heavy for the top and bottom, 0.05em light in between.

### CCS concepts and keywords

**JAIR's own kit says: "Do not include ACM CCS Concepts or Keywords."** The
`ccs` and `keywords` parameters exist because acmart supports them, and are
left unset in the shipped example. Do not use them for a JAIR submission.

## Citation style

JAIR uses author–year citations (`acmauthoryear` in the LaTeX kit). Typst has
no bundled ACM author–year CSL, so the example uses
`american-psychological-association`, which is close but not identical. For an
exact match, put an ACM author–year CSL file beside your document and pass it
as `style: "acm-author-year.csl"`.

## Fonts

acmart sets JAIR in Linux Libertine, with Linux Biolinum for sans-serif and
Inconsolata for monospace; math is a Libertine-matched face. The template asks
for those first, then for Libertinus, then for TeX Gyre Heros as the sans of
last resort.

Typst's compiler embeds Libertinus Serif, New Computer Modern with its math
face and DejaVu Sans Mono, but **no sans-serif family**. Without one, the
title, byline, headings, running heads and captions silently fall back to the
serif. On a TeX Live machine Linux Biolinum O is present. In the Typst web app
check the font list of your project; if no Biolinum, Libertinus Sans or TeX
Gyre Heros is offered, upload the Linux Biolinum O files (they are free) to
the project.

Typst warns once per use about each family it cannot find; the warnings are
harmless as long as one family per list resolves.

## Known deviations

Stated plainly, because this is a reimplementation and not the class itself:

- **Not byte-identical.** TeX and Typst break lines and hyphenate differently,
  so text will not fall identically even where every dimension matches.
- **No glue.** acmlarge pages are flush-bottom and stretch the space around
  displays, floats and headings to fill each page; Typst pages are
  ragged-bottom and use the fitted natural values above.
- **Run-in headings.** acmart makes levels 3 and 4 run-in: the heading sits on
  the same line as the paragraph that follows it. Typst always starts a new
  paragraph after a heading, so the face, the trailing period and the space
  above are matched but the text begins on the next line.
- **Consecutive lists.** LaTeX puts two `\topsep`s between a list that directly
  follows another; Typst collapses them to one, so that gap is about 2pt
  tighter than in the class.
- **Footnote rules.** acmart draws a full-width rule above the first-page
  contact/copyright block and a 4pc rule above ordinary footnotes. Typst has
  one footnote separator per document, so the 4pc rule is used throughout.
- **CC BY badge** is drawn as a boxed "CC BY" rather than the official 88×31
  image, to keep the package free of binary assets.
- **Line numbers.** acmart's `review` option draws a fixed ruler in the margin,
  numbering 12pt slots regardless of where text actually falls; Typst numbers
  real lines. Color (pure red), size, left alignment, margin position and
  restart on every page match; the numbers correspond to lines rather than
  slots. acmart shows no ruler on page 1; here the title block carries no
  numbers but body lines that start on page 1 do. Hiding them would need a
  per-line `context` lookup of the page counter, which keeps documents of a
  few dozen pages from converging.
- **Author grouping.** acmart can put several authors sharing an affiliation on
  one byline row; here every author gets a line of their own, which is what jair.cls's
  `\@mkauthors@i` does for the journal formats anyway.
- **Theorem environments** are not styled to acmart's `acmplain`/`acmdefinition`.
- **Teaser figures, subtitles and `\titlenote`/`\authornote`** are not
  implemented; the only note mechanism is the corresponding-author asterisk.

## Before you submit

- JAIR accepts **PDF only** at submission; the LaTeX class is used to produce
  the published version. Confirm with the editors if you intend to stay in
  Typst through acceptance.
- Fill in the JAIR associate editor and replace the placeholder DOI.
- JAIR asks authors to be concise but sets no page limit.

## License

MIT for the package (`lib.typ` and the documentation); MIT-0 for everything
under `template/`, so a document started from the template carries no
attribution obligation. Both texts are in `LICENSE`. The layout parameters are
derived from `jair.cls` and `acmart.cls`, both distributed under the LaTeX
Project Public License; no code from either is included.
