# User guide

[README](../README.md) · [API reference](api.md) · [Examples](../examples/README.md)

## Install locally

Import the published package with a namespace:

```typst
#import "@preview/comicscript:0.3.0" as hq
```

This import becomes available once the submission is accepted. For a local
source checkout, keep `lib.typ` and `src` together and use a relative import
such as `#import "comicscript/lib.typ" as hq`. The namespace prevents the English
`page` alias from shadowing Typst's built-in `page`.
Set paper, margins, font family, and document language yourself:

```typst
#set page(paper: "a4", margin: 20mm, numbering: "1")
#set text(size: 11pt, lang: "en")
```

Examples use the versioned package import too. For pre-publication testing,
see the isolated package-registry instructions in the development guide.

## Write pages, rows, and panels

The hierarchy is **page → row → panel**. A page needs a positive narrative page
number and at least one row. A row needs at least one panel. A panel needs only
its visual description; everything else is optional.

```typst
#let p1 = hq.page(
  1,
  title: [A sensor test],
  hq.row(
    hq.panel[A sensor switches on.],
    hq.panel[A second indicator lights up.],
  ),
)
```

Children are positional arguments, not `rows:` or `panels:` fields. Combine
pages in an array: `#let pages = (p1, p2)`. Single-item arrays need a comma:
`(p1,)`. Constructors return dictionaries, not visible content; call
`hq.render(pages)` to produce a document.

## Add text in reading order

```typst
hq.panel(
  texts: (
    hq.caption[The next morning...],
    hq.speech("Alex")[Is the sensor connected?],
    hq.speech("Sam", mode: "thought")[That light is blinking.],
    hq.sound[BEEP!],
  ),
)[A sensor flashes above the test bench.]
```

The array specifies reading order, not physical balloon positions. Describe
placement in `composition` when necessary. Common speech modes are `normal`,
`thought`, `off-panel`, and `whisper`; other nonempty mode strings are accepted.
Leave `texts` empty for a silent panel. An unfinished description can be `[]`;
editorial view warns about it rather than inventing missing content.

## Add composition, references, and notes

```typst
hq.panel(
  id: "sensor-check",
  shot: "wide shot",
  composition: [Keep the indicator above the control panel.],
  references: ([Control panel diagram.],),
  notes: (
    hq.note("continuity")[The power cable remains on the left.],
    hq.note("subtext")[Alex does not trust the reading yet.],
    hq.note("alternative", status: "discarded")[Start with a close-up.],
  ),
)[Alex checks the test bench.]
```

Content fields accept ordinary Typst content, including emphasis, links, and
images. A reference image can be passed as:

```typst
references: ([#image("references/sensor.png", width: 40mm)],),
```

The caller's `image` expression determines path resolution. A filename string
is displayed as text, not automatically loaded.

Notes belong to their page, row, or panel, so moving a panel moves its notes.
Common categories are `problem`, `idea`, `alternative`, `continuity`, `subtext`,
`clue`, `reference`, `decision`, `composition`, and `technical`. Custom nonempty
categories work too. Note status is `open`, `resolved`, or `discarded`,
independent of category. Page status is separate, free-form metadata.

## Select a view

### Script

```typst
#hq.render(pages, mode: "script")
```

Shows descriptions, shots, composition, references, and script text. Hides
notes, objectives, page statuses, IDs, and editorial warnings.

### Editorial

```typst
#hq.render(pages, mode: "editorial", note-statuses: ("open",))
```

Adds notes at all three levels, objectives, statuses, IDs, and review warnings.
By default, all note statuses appear. The call above shows only open notes.
Keep one data source rather than copying the script into separate drafts.

### Layout

```typst
#hq.render(pages, mode: "layout",
  layout-width: 140mm, layout-height: 180mm, layout-summaries: true)
```

Draws fixed-size geometric panels. Descriptions never enlarge the geometry.
Defaults are 140mm × 180mm with 3mm gutters. Labels identify row and panel;
summaries use the first eight static words of the description. Very small
cells omit summaries or labels to preserve geometry.

Choose absolute dimensions that fit the usable paper area, including title
and caption. The defaults fit the A4/20mm-margin examples. Only horizontal
rows with variable-width panels are supported; panels cannot span rows.

### Production

```typst
#hq.render(pages, mode: "production")
```

Shows descriptions, shots, composition, references, texts, IDs, weights, and
selected artist-facing notes. Only `composition`, `continuity`, `reference`,
and `technical` notes in `open` or `resolved` status are included, at all three
levels. English values are normalized by `hq.note` before filtering.

Other categories, discarded notes, objectives, page statuses, and editorial
warnings are excluded. This is an explicit category filter: the package does
not infer whether a note's contents are private.

## Proportions, numbers, and identity

Weights default to 1 and must be finite positive numbers. In a row, weights
2, 1, 1 allocate 50%, 25%, 25% of the width available after gutters. Row
weights determine relative heights in layout view. Textual views show
proportions and relevant weights without imposing physical panel dimensions.

Row numbering restarts on each narrative page. Panel numbering restarts in
each row. Reference a position using page + row + panel, or assign an explicit
ID. IDs are optional nonempty strings, unique across all rows and panels
passed to a renderer or report. An explicit ID survives moving a panel;
position-based numbers change. Automatically persistent IDs are not provided.

Repeated narrative page numbers are allowed to preserve alternative versions;
use titles or notes to distinguish them. Narrative and physical PDF page
numbers are separate. In textual views, a narrative page can span sheets.
Panels that fit a full usable sheet stay together; longer panels can continue
across sheets. Configure physical numbering with Typst's `set page`.

## Visual system

- `PÁGINA N` is warm orange-beige at 22pt. The optional page title below it is
  22pt in textual views and 20pt in layout view.
- Each textual panel has one left-aligned teal header combining row, panel,
  and width percentage. Non-default weights add `PESO L/Q`, in row/panel order.
  IDs appear below it in editorial and production views.
- Borders are dark, with rounded corners. Outer panels use 1.5pt borders;
  internal boxes generally use 1pt borders and 5pt corner radii.
- Inside panels, the most frequent visible box type uses the full inner width.
  Each lower frequency tier reduces width by 1cm; ties keep equal widths.
  The minimum width is 60% of the available inner width.
- Note categories count together as the note box type. Page and row notes do
  not enter this count; hidden notes do not count either.
- Speeches and references align left; shots, captions, and warnings align
  center; composition, notes, and sounds align right. Text stays left-aligned.
- Shots and composition have separate boxes. Reports do not use the internal
  panel frequency-width system.

English aliases do not localize PDF labels. This release provides English
authoring commands while keeping the printed interface in Portuguese.

## Reports

```typst
#hq.narrative-map(pages)
#pagebreak()
#hq.pending-notes(pages)
#pagebreak()
#hq.dialogues(pages)
#pagebreak()
#hq.dialogues(pages, character: "Sam")
#pagebreak()
#hq.text-report(pages, word-limit: 60)
```

The map lists page numbers, panel counts, titles, objectives, and statuses.
Pending notes include open notes, grouped by page and location. Dialogue
reports include speeches and thoughts but not captions or sounds. Character
filtering uses the exact string, including case.

Text reports count all `texts` elements and their static words per panel.
The threshold marks panels for review; it is not a writing rule. Set
`word-limit: none` to retain counts without the review marker.

## Command-line inputs

Read an input in the main file:

```typst
#hq.render(pages, mode: sys.inputs.at("mode", default: "script"))
```

Then choose a view without editing page data:

```sh
typst compile main.typ script.pdf --input mode=script
typst compile main.typ editorial.pdf --input mode=editorial
typst compile main.typ layout.pdf --input mode=layout
typst compile main.typ production.pdf --input mode=production
```

The main file chooses the input key. The Portuguese examples
read `modo` with values such as `roteiro`, `esquema`, and
`producao`. The English example reads `mode`. CLI keys are not automatically
translated by the package.

## Validation and troubleshooting

| Symptom | Check |
| --- | --- |
| Import outside project root | Use `--root .` from the package folder or set the editor project root |
| Dictionary text instead of a script | Constructors return data; call `hq.render` |
| Missing row or panel | Pass children positionally, not as `rows:` or `panels:` |
| Single-item array rejected | Write `(item,)`, not `(item)` |
| Duplicate ID | Rows and panels share one ID namespace across supplied pages |
| Note absent from production | Check its canonical category and status |
| Layout exceeds the paper | Reduce layout dimensions or increase usable paper area |
| English field access fails | Internal fields remain Portuguese, such as `page.linhas` |

Constructors reject invalid child types, empty pages/rows, invalid page numbers,
nonpositive or nonfinite weights, invalid note statuses, and unsupported fields.
Rendering rejects unknown modes and duplicate explicit IDs. Error messages may
be in Portuguese because aliases delegate to the canonical validators.

An empty visual description is an editorial warning, not a compilation error.
Editorial view also warns when static words in a panel's text elements exceed
the configured threshold (60 by default). Warnings appear in the PDF, not as
CLI diagnostics.

Counts use whitespace-separated static text, including common emphasis and
link bodies. They do not evaluate `context`, images, or formulas. A visual
field containing only an image can receive a missing-static-description
warning. This is an editorial aid rather than semantic script analysis.
