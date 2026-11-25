// na-frame user guide (English edition).
// Compile with:  typst compile doc-en.typ
// Keep this file in the package root (next to lib.typ).

#import "@preview/na-frame:0.1.0": *

#set page(paper: "a4", margin: (x: 20mm, y: 22mm), numbering: "1")
#set text(font: ("New Computer Modern", "Libertinus Serif"), lang: "en", dir: ltr, size: 11pt)
#set par(leading: 0.7em, justify: true)
#set heading(numbering: "1.1")
#show heading: set block(above: 1.4em, below: 0.8em)
#show heading.where(level: 1): set text(size: 18pt, fill: rgb("#4B0082"))
#show heading.where(level: 2): set text(size: 14pt, fill: rgb("#4B0082"))
#show raw: set text(font: ("DejaVu Sans Mono", "Liberation Mono"), size: 9pt)
#show raw.where(block: false): box.with(fill: luma(238), inset: (x: 3pt), outset: (y: 3pt), radius: 2pt)

// Shows the code, then its live result.
#let scope = dictionary(lib)
#let demo(code) = block(width: 100%, above: 1em, below: 1em)[
  #block(width: 100%, fill: luma(246), stroke: 0.5pt + luma(200), radius: 2pt, inset: 8pt)[
    #set par(leading: 0.5em, justify: false)
    #raw(code.text, lang: "typ", block: true)
  ]
  #v(1mm)
  #eval(code.text, mode: "markup", scope: scope)
]

#let note(body) = block(width: 100%, fill: rgb("#FFF8E1"), stroke: (left: 2.5pt + rgb("#E0A800")),
  inset: 9pt, radius: 2pt, above: 1em, below: 1em)[#body]

// ───────────── Cover ─────────────
#align(center)[
  #v(8mm)
  #text(size: 30pt, weight: "bold", fill: rgb("#4B0082"))[na-frame]
  #v(2mm)
  #text(size: 16pt)[Professional frames for Typst]
  #v(1mm)
  #text(size: 12pt, fill: luma(90))[User guide · version 0.1.0]
]
#v(6mm)
#outline(indent: 1.2em, depth: 2)
#pagebreak()

= What is na-frame?

`na-frame` is a Typst library that provides *#frames.len() ready-made frames* (definition, theorem, exercise, property, notebook, paper, ribbon...) for Arabic (RTL) and Latin (LTR) documents, all through the same interface.

- Every frame can break across pages (`breakable`) unless stated otherwise.
- Every frame takes a title, a color and secondary colors; titles can contain math or any other content.
- All frame definitions live in a single file: `lib.typ`.
- Arabic and Latin frames can be mixed in one document (the `dir` parameter).

= Installation

== Manual installation

Typst looks for packages inside its data directory, in `packages/<namespace>/<name>/<version>/`. Here we use the short namespace `na`. Installing there lets you import `na-frame` from any document, without copying the folder each time.

+ Find Typst's `packages` directory for your system (table below, up to `packages/`). Create the folders if they do not exist yet.
+ Inside it create `na/na-frame/0.1.0/`. The last folder name *must equal* the `version` field of `typst.toml`.
+ Copy the *contents* of the package into that folder (`typst.toml`, `lib.typ`, `doc.typ`, `doc-en.typ`, `examples/`...). `typst.toml` and `lib.typ` must sit directly inside `0.1.0/`, not in a sub-folder.
+ Import the package by name from any document, as shown below.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [OS], [Path],
  [Linux], [`~/.local/share/typst/packages/na/na-frame/0.1.0/`],
  [macOS], [`~/Library/Application Support/typst/packages/na/na-frame/0.1.0/`],
  [Windows], [`%APPDATA%\typst\packages\na\na-frame\0.1.0\`],
)

The final layout must look like this:

```
typst/packages/na/na-frame/0.1.0/
├── typst.toml
├── lib.typ
├── doc.typ
├── doc-en.typ
└── examples/
```

On Linux, if `XDG_DATA_HOME` is set, replace `~/.local/share` by that directory.

=== Importing the installed package

Use the `@na` namespace, the package name and the exact version:

```typ
#import "@na/na-frame:0.1.0": *

#set text(lang: "en", dir: ltr)

#theorem-frame(title: [Pythagorean theorem])[
  $ a^2 + b^2 = c^2 $
]
```

The import works with the Typst CLI (`typst compile`, `typst watch`) and with editors that use it (VS Code Tinymist, etc.). The Typst web app cannot use packages installed this way.

If you get _package not found_, check that the path matches the table, that the folder is named `0.1.0`, and that the version in the import equals the one in `typst.toml`.

== Installing from the Typst package repository (once accepted)

Once the package is accepted into the official Typst package repository (Typst Universe), no manual installation is needed: just import it, and Typst downloads it automatically on first use and keeps it in its cache. The namespace here is `@preview`, not `@na`.

```typ
#import "@preview/na-frame:0.1.0": *

#set text(lang: "en", dir: ltr)

#theorem-frame(title: [Pythagorean theorem])[
  $ a^2 + b^2 = c^2 $
]
```

This import works with the Typst CLI, with editors (VS Code Tinymist, etc.) and also with the Typst web app. You can find the package and its latest version on its Typst Universe page (`typst.app/universe`).

#note[As long as the package has not yet been accepted into the repository, use the manual installation above with the `@na` namespace.]

#note[Importing with `*` brings in every frame plus `palette`, `frame`, `frames` and `exercise-counter`.]

= Quick start

Every frame is a function: the *content comes last* (in square brackets) after the named parameters:

#demo(```typ
#theorem-frame(title: [Pythagorean theorem])[
  In a right triangle, the square of the hypotenuse equals
  the sum of the squares of the other two sides:
  $ a^2 + b^2 = c^2 $
]
```)

If you omit `title`, a default title in the document language is used (for example "Theorem" in English, «مبرهنة» in Arabic):

#demo(```typ
#blue-frame[
  A function maps each element to at most one element.
]
```)

= Common parameters

Most frames share these parameters (a few are simpler: `warning-note` and `homework-sheet` have no title, `ribbon-banner` and `arched-ribbon` have no body):

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [Parameter], [Meaning],
  [`title`], [The title. `auto` selects a default title for the document language.],
  [`color`], [Frame color (and the secondary fill in some frames).],
  [`title-color`], [Title tab color. `auto` means the same as `color`.],
  [`title-text-color`], [Title text color.],
  [`breakable`], [Allows the frame to break across pages (default `true`).],
  [`dir`], [`auto` (document direction), `rtl` or `ltr`.],
  [`lang`], [Frame language (defaults to `ar` with rtl and `en` with ltr).],
)

#note[Default colors differ from frame to frame, and some frames have extra parameters of their own (see the chapter "Frame-specific parameters").]

= Colors and titles

== The palette

`palette` holds ready-made colors: `blue`, `red`, `crimson`, `green`, `teal`, `orange`, `purple`, `indigo`, `gold` and `gray`.

#demo(```typ
#blue-frame(title: [Definition], color: palette.teal)[
  Frame color taken from the ready-made palette.
]

#blue-frame(title: [Definition], color: rgb("#8a2be2"))[
  Or any color of your own.
]
```)

== Title colors

#demo(```typ
#theorem-frame(
  title: [Theorem],
  color: palette.indigo,
  title-color: palette.purple,
  title-text-color: yellow,
)[
  Indigo frame, purple title tab and yellow title text.
]
```)

== Titles with math

A title is ordinary Typst content, so it can contain equations and formatting:

#demo(```typ
#green-frame(title: [Exercise #sym.star], subtitle: [4 points])[
  Compute: $ lim_(x -> 0) (sin x) / x $
]
```)

= Breaking across pages

Frames can break across pages by default, and the title stays attached to the first line. To prevent breaking:

```typ
#theorem-frame(breakable: false)[ This frame is never split. ]
```

#note[`warning-note` has a fixed width (`170mm`) and cannot break across pages. `practical-notebook` defaults to `width: auto`: the full available width, aligned with the other frames (the rings stick out 4 mm into the margin); it does not break across pages. `sheet-frame` is full width and breaks across pages (`breakable: true`).]

= Arabic and Latin frames in one file

`dir` sets a frame's direction and `lang` its language:

#demo(```typ
#theorem-frame(dir: rtl, title: [مبرهنة])[
  صندوق عربي داخل مستند لاتيني: $ a^2 + b^2 = c^2 $
]

#frame("blue", dir: rtl, title: [تعريف])[تعريف باتجاه RTL.]
```)

The opposite case (a Latin frame inside an Arabic document) works the same way with `dir: ltr`.

#note[In a Latin document (`dir: ltr`) the frames with a title tab put it on the *left*; in an Arabic document (`dir: rtl`) it stays on the right. This holds for every tabbed frame (`tab-frame`, `curved-tab-frame`, `speech-frame`, `rounded-tab-frame`, `exam-frame`, `right-rule-frame`, `folded-corner-frame`, `subtitle-frame`, `outlined-tab-frame`, `inset-tab-frame`, `numbered-frame`, `property-frame`, `exercise-card`, `sheet-frame`...): ornaments, side rules, shadows and the secondary subtitle are mirrored together with the tab. Frames whose title is centered are unchanged.]

= Calling by name: frame

`frame` calls any frame by its registered name from the `frames` dictionary:

#demo(```typ
#frame("shadow", title: [Example], color: palette.crimson)[
  The same as `shadow-frame`, but called by name.
]
```)

This is handy when the style is a variable:

```typ
#let style = "blue"
#frame(style, title: [Definition])[ ... ]
```

To list all available names: `#frames.keys()`.

= Frame guide

== Definitions, theorems and properties

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [Frame], [Description],
  [`theorem-frame`], [Red title tab hanging on a light frame (theorem).],
  [`blue-frame`], [Rounded frame with a curved title (definition).],
  [`flag-frame`], [Flag-shaped title (property).],
  [`proof-frame`], [Rounded frame with a title tab (proof).],
  [`gradient-frame`], [Gradient-colored title (remark).],
  [`chapter-frame`], [Title tab with an arrow (chapter outline).],
  [`ribbon-frame`], [Wide ribbon with folded ends (reminder).],
  [`shadow-frame`], [Layered shadow and a folded corner (example).],
  [`board-frame`], [Bevelled board frame; the title is plain text, no tab.],
  [`property-frame`], [Property frame with two small badges.],
  [`folded-definition-frame`], [Folded title tab.],
  [`corner-rule-frame`], [Title and subtitle on opposite sides.],
  [`properties-frame`], [Thick frame with title and subtitle.],
  [`centered-info-frame`], [Title centered between two bands.],
  [`ribbon-notes-frame`], [Gradient header ribbon with a caption and a colored tag (important notes).],
  [`double-tab-frame`], [Two tabs: main title and subtitle.],
  [`tab-frame`, `curved-tab-frame`, `rounded-tab-frame`], [Title tabs in different shapes.],
  [`right-rule-frame`, `folded-corner-frame`, `subtitle-frame`], [Side rules, folded corners and a subtitle.],
  [`outlined-tab-frame`, `inset-tab-frame`], [Outlined or inset title tabs.],
  [`speech-frame`], [Speech-bubble shape.],
  [`warning-note`], [Yellow note with a free vertical title (fixed width).],
  [`grid-notebook-frame`], [Blue grid notebook with rings and a curved title badge.],
  [`prerequisites-frame`], [Card of red-labeled items with a folded corner and rings (prerequisites).],
  [`folded-ribbon-frame`], [Sheet with a wide notched ribbon and two folded corners.],
  [`hanging-tab-frame`], [Sheet with a top rule and a curved hanging title tab.],
  [`winged-tab-frame`], [Centered title label with two pointed wings and a dotted border.],
  [`badge-notebook-frame`], [Two-layer card with a slanted title badge and a gold underline.],
)

#demo(```typ
#centered-info-frame(title: [Important])[
  A title centered between two bands.
]

#double-tab-frame(title: [Property], subtitle: [Complex modulus])[
  Two title tabs: a main one and a secondary one.
]

#board-frame(title: [Board])[
  A bevelled board frame; the title is plain text.
]
```)

=== The `warning-note` frame in detail

A yellow note with a folded corner at the bottom-left and a golden vertical strip on the right where a *free* title is written sideways. The note's height follows its text automatically (25mm minimum) and it cannot break across pages.

*Title:* write whatever you like in `title`. If you omit it, the word "Note" appears («ملاحظة» in an Arabic document). A long title makes both the strip and the note grow.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [Parameter], [Meaning],
  [`title`], [The free vertical title. Default `auto` ("Note").],
  [`title-color`], [Title color (default white).],
  [`title-size`], [Title size (default `10pt`).],
  [`title-font`], [Title font (default `"Noto Kufi Arabic"`).],
  [`width`], [Note width (default `170mm`).],
  [`body-color`], [Paper color (default light yellow).],
)

#demo(```typ
#warning-note[Important notice.]

#warning-note(title: [Very important])[
  A free title typed by the user, shown vertically on the strip.
]

#warning-note(title: [Tip], title-color: rgb("#4a2c00"), body-color: rgb("#e6f4ea"))[
  Custom title color and paper color.
]
```)

== Exercises

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [Frame], [Description and special parameters],
  [`green-frame`], [Green exercise. `subtitle`: side text (e.g. the points).],
  [`numbered-exercise-frame`], [Automatic numbering "Exercise 1, 2...". `subtitle`: points, `third-title`: third title.],
  [`numbered-frame`], [Numbered tab such as "Exercise 02". `number`: the number, `subtitle`: a subtitle.],
  [`exercise-card`], [Exercise card with an icon. `points`, `subtitle`, `icon` (`true`/`false`).],
  [`exam-frame`], [Exam exercise. `number`: the number, `source`: origin such as "Baccalaureate 2010".],
  [`framed-exercise`], [Green-and-gold framed exercise; the title is free text, no numbering. `title`, `title-color`, `title-size`.],
  [`sheet-frame`], [Sheet with a large title; breaks across pages. `width`, `body-height` (default `auto`), `title-size`, `breakable`.],
)

=== Automatic numbering

`numbered-exercise-frame` increments a counter on every call. To restart it, use the exported counter `exercise-counter`:

#demo(```typ
#exercise-counter.update(0)

#numbered-exercise-frame(subtitle: [4 points], third-title: [Complex numbers])[
  Numbering is automatic.
]

#numbered-exercise-frame(subtitle: [3 points])[
  A second exercise that gets number 2.
]
```)

=== The other exercise frames

#demo(```typ
#numbered-frame(number: [02], subtitle: [Functions review])[
  Exercise text.
]

#exercise-card(points: [6 points], subtitle: [The questions are independent.])[
  Exercise text.
]

#exam-frame(number: 3, source: [Baccalaureate 2010])[
  Exercise text.
]
```)

== Notebooks and papers

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [Frame], [Description],
  [`paper-frame`, `sticky-frame`], [Pinned paper with a curled corner, and a yellow sticky note.],
  [`notebook-frame`], [Notebook with metal rings.],
  [`notebook-page-frame`], [Ruled notebook page with a binding on the end side.],
  [`torn-paper-frame`], [Paper with torn edges and a shadow. `subtitle`.],
  [`side-notebook-frame`, `binder-notebook-frame`], [Notebooks with a side binding or rings.],
  [`practical-notebook`], [Practical-work notebook with a pencil and rings (automatic full width).],
  [`homework-sheet`, `homework-sheet-modern`], [Homework sheet (name and date fields).],
)

== Batch 4 frames

Four new frames, taken from sheet designs that all used to be called `homework-sheet-modern` and from a ring-less variant of `practical-notebook`; each now has its own name. All accept `title`, `color`, `breakable`, `dir` and `lang`. Each has an Arabic layout (ribbon, tab or badge on the right) and a Latin layout (`dir: ltr`) in which the drawing is mirrored and the text is not, with an English default title.

=== `folded-ribbon-frame`: the folded ribbon

A sheet with a thin frame. A wide ribbon with a notched, pointed end sits on its top corner and sticks out slightly past the edge; two small triangles behind it make it look folded over the sheet. The title is inside the ribbon in bold white. Good for homework sheets and series titles.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [Parameter], [Meaning],
  [`title`], [Title (default "الواجب المنزلي" or Homework).],
  [`color`], [Frame and ribbon color (default dark red `#780505`).],
  [`title-color`], [Ribbon color only (`auto` = `color`).],
  [`title-text-color`], [Title text color (white).],
  [`fold-color`], [Color of the two fold triangles (violet).],
  [`paper-color`], [Sheet background (white).],
  [`ribbon-width`], [Ribbon width (default `100mm`).],
  [`breakable`], [May break across pages (default `true`).],
)

#demo(```typ
#folded-ribbon-frame(title: [Homework no. 1], dir: ltr)[
  Simplify $sqrt(sqrt(3^8))$, then name the smallest set it belongs to.
]

#folded-ribbon-frame(title: [الواجب المنزلي رقم 1], dir: rtl, color: palette.indigo)[
  الشريط على اليمين في النسخة العربية.
]
```)

=== `hanging-tab-frame`: the hanging tab

A sheet with a top rule only; a curved title tab (rounded on one side, slanted on the other) hangs over the rule, starting above it and dropping slightly below. The tab width and height follow the title automatically. The tab is on the right in Arabic and on the left in Latin. With no side or bottom frame it suits long exercises that run over several pages.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [Parameter], [Meaning],
  [`title`], [Title (default "تمرين" or Exercise).],
  [`color`], [Top rule and tab color (default black).],
  [`title-color`], [Tab color only (`auto` = `color`).],
  [`title-text-color`], [Title text color (white).],
  [`paper-color`, `breakable`], [Sheet background; breaking across pages.],
)

#demo(```typ
#hanging-tab-frame(title: [Logarithm exercise], dir: ltr, color: palette.teal)[
  Solve in $RR$: $ln(x) + ln(x - 1) = ln(6)$.
]

#hanging-tab-frame(title: [تمرين في الدوال اللوغاريتمية], dir: rtl)[
  حل في $RR$ المعادلة: $ln(x) + ln(x - 1) = ln(6)$.
]
```)

=== `winged-tab-frame`: the winged label

A sheet with a thin frame; centered on its top edge is the title in a white rectangle with a dotted inner border, flanked by two pointed wings in the frame color. The design is symmetric, so Arabic and Latin differ only in text direction. The title text takes the frame color by default.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [Parameter], [Meaning],
  [`title`], [Title (default "ملاحظة" or Note).],
  [`color`], [Frame, wings and dotted border color (default black).],
  [`title-color`], [Wings and borders only (`auto` = `color`).],
  [`title-text-color`], [Title text color (`auto` = wing color).],
  [`tab-fill`], [Title rectangle background (white).],
  [`paper-color`, `breakable`], [Sheet background; breaking across pages.],
)

#demo(```typ
#winged-tab-frame(title: [Remark], dir: ltr, color: palette.indigo)[
  A centered label with two pointed wings.
]

#winged-tab-frame(title: [ملاحظة], dir: rtl, color: palette.crimson)[
  لسان في الوسط بجناحين.
]
```)

=== `badge-notebook-frame`: the badge notebook

A two-layer card: a softly bordered sheet over a dark back layer that shows as a 2 mm heel, a slanted dark title badge in the top corner with a short gold bar under it, and a thin footer line with a gold dot. The corners are asymmetric (strongly rounded on two opposite ones). It differs from `practical-notebook` by having no rings. Default width is `auto` (full available width); pass a fixed `width` if you prefer. In Latin the badge moves to the left and the heel is mirrored.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [Parameter], [Meaning],
  [`title`, `title-font`, `title-size`, `title-color`], [Title, its font, size and text color.],
  [`title-box-color`], [Badge and back-layer color (dark teal).],
  [`accent-color`], [Gold bar and dot color.],
  [`paper-color`, `border-color`, `text-fill`], [Sheet, border and body-text colors.],
  [`width`], [`auto` (default) or a fixed length.],
  [`height`, `min-height`], [Height and minimum height (`60mm`).],
)

#demo(```typ
#badge-notebook-frame(title: [Practical work], dir: ltr)[
  In this activity we organise our ideas and apply what we learned step by step.
]

#badge-notebook-frame(title: [أعمال تطبيقية], dir: rtl, title-box-color: rgb("#5d2490"))[
  الشارة والكعب على اليمين في النسخة العربية.
]
```)

#note[With `width: auto` the frame is drawn in a region whose width is computed from its container, so it does not break between pages. To allow breaking, pass a fixed `width`.]

== The `ribbon-notes-frame` ("Important notes") frame

A one-piece gradient header ribbon: a main title on one side, and under the opposite side a small caption ("Add to") with a colored gradient tag ("your notes") hanging from it. In an Arabic document the main title is on the right and the tag on the left; in a Latin document (`dir: ltr`) the whole ribbon is mirrored (the drawing only, never the text), so the title sits on the left and the tag on the right.

*Titles:* `title`, `subtitle` and `tag-title` are all yours. When omitted, the defaults appear ("ملاحظات هامة" / "أضف إلى" / "معلوماتك" in an Arabic document, Important notes / Add to / your notes in a Latin one). Pass `subtitle: []` or `tag-title: []` to hide the caption or the tag. Minimum width: `70mm`.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [Parameter], [Meaning],
  [`title`], [Main title in the ribbon.],
  [`subtitle`], [Small caption (Add to).],
  [`tag-title`], [Text of the colored tag (your notes).],
  [`color`], [Frame color (default purple `4B0082`).],
  [`title-color`], [Ribbon color (`auto` = frame color).],
  [`title-text-color`], [Title text color (default white).],
  [`background`], [Gradient background color of the frame.],
  [`subtitle-color`], [Caption text color.],
  [`tag-color`, `tag-end-color`, `tag-text-color`], [Start and end of the tag gradient, and its text color.],
  [`title-size`, `title-raise`], [Title size and vertical raise (in `ribbon-notes-frame` the default is `0mm`: the title is exactly centered in its frame).],
)

#demo(```typ
#ribbon-notes-frame(title: [Important notes])[
  Let $z$ be a nonzero complex number written in trigonometric form:
  $ z = r (cos(theta) + i sin(theta)). $

  #list(marker: text(fill: palette.purple)[▶],
    [The modulus of $z$ is $r$, where $r > 0$.],
    [For every natural number $n$: $z^n = r^n (cos(n theta) + i sin(n theta))$.],
  )
]

#ribbon-notes-frame(
  title: [Reminder], subtitle: [Remember], tag-title: [The rule],
  color: palette.teal, background: rgb("#DDF3EC"),
)[
  Your own titles and colors.
]
```)

== The `grid-notebook-frame` (blue notebook) frame

A notebook with a millimetre grid (squares every 1 mm), a double red margin and metal binding rings, topped by a curved blue title badge flush with the edge of the frame. It differs from `practical-notebook` by its badge (curved, no pencil) and its blue colors. In an Arabic document the badge and rings are on the right; in a Latin document (`dir: ltr`) the binding and badge are mirrored together (the drawing only, never the text).

The title is yours in `title` (default "تمرين تطبيقي" or Applied exercise). Default width is `auto`: it fills the available width like the other frames (no `width` needed); pass a length such as `width: 150mm` for a fixed width. The height follows the content (minimum `min-height: 60mm`).

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [Parameter], [Meaning],
  [`title`, `title-font`, `title-size`, `title-color`], [Title, its font, size and text color.],
  [`accent-color`], [Badge color (default dark blue).],
  [`width`], [`auto` (default) = full available width, paper border aligned with the other frames (the rings stick out 4 mm into the margin); or a fixed length.],
  [`height`, `min-height`], [Height and minimum height.],
  [`ring-spacing`], [Distance between rings (default `12mm`).],
  [`paper-color`, `border-color`, `wire-color`, `hole-color`], [Paper, frame, wire and hole colors.],
  [`rule-color`, `fine-rule-color`, `margin-color`], [Grid line and margin colors.],
)

#demo(```typ
#grid-notebook-frame(title: [Applied exercise])[
  Write the steps clearly, then check the result.
]

#grid-notebook-frame(title: [تمرين تطبيقي], dir: rtl)[
  التجليد والشارة على اليمين في النسخة العربية.
]
```)

== The `prerequisites-frame` frame

A gradient sheet with a folded bottom corner and a soft shadow, with wire rings on its edge (more rings as it gets taller). The content is a list of items, each with a red label, passed in `items` as `(label, content)` pairs; you may add plain text after them. It has no title and cannot break across pages. In a Latin document (`dir: ltr`) the rings move to the left and the folded corner to the right.

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [Parameter], [Meaning],
  [`items`], [Array of `([label], [content])` pairs.],
  [`label-color`], [Label color (default red).],
  [`color`], [Frame color.],
  [`fill-color`], [End color of the gradient (light sky blue).],
  [`fold-color`, `fold-border-color`], [Folded corner color and border.],
  [`shadow-color`], [Shadow color.],
  [`wire-color`, `ring-spacing`, `ring-out`], [Ring color, spacing and how far they stick out of the edge.],
)

#demo(```typ
#prerequisites-frame(items: (
  ([Prior knowledge], [Pythagorean theorem, point transformations.]),
  ([Target skills], [Use transformation properties to solve problems.]),
  ([Tools], [Textbook, geometry tools, GeoGebra.]),
))
```)

== Ribbons (titles without content)

`ribbon-banner` and `arched-ribbon` take only a title and have no body:

#demo(```typ
#ribbon-banner(title: [Chapter title])

#arched-ribbon(title: [Chapter title])
```)

== Side-binding style frames

A colored title bar above a page with a metal side binding, with the title centered in the bar. This is `spiral-banner-frame`, and the frames that used to be ornamental now use the same style:

`lace-frame`, `illuminated-frame`, `geometric-frame`, `math-cover-frame`, `vintage-frame`, `jewel-frame`, `star-chain-frame`, `lantern-frame`, `botanical-frame`, `emerald-frame`, `right-scroll-frame`, `bevel-frame`

Each has a different default color. They accept `title`, `color`, `title-color`, `title-text-color` and `breakable`, and silently ignore any other old parameter (`footer`, `series`...).

#demo(```typ
#spiral-banner-frame(title: [Frame title])[
  A title bar and a side binding.
]

#emerald-frame(title: [Remark])[
  The same style in an emerald color.
]

#spiral-banner-frame(title-color: palette.crimson, frame-color: rgb("#FDECEC"))[
  Custom colors.
]
```)

= Frame-specific parameters

Some frames accept extra parameters. The main ones:

#table(
  columns: (auto, 1fr), inset: 7pt, stroke: 0.5pt + luma(200),
  [Frame], [Parameters],
  [`shadow-frame`], [`frame-color`, `frame-width`, `shadow-color`, `shadow-size`, `background`, `fold-size`],
  [`corner-rule-frame`], [`subtitle`, `subtitle-color`, `background`, `border-thickness`, `title-size`],
  [`properties-frame`], [`subtitle`, `subtitle-color`, `background`, `frame-width`, `title-size`],
  [`folded-definition-frame`], [`frame-color`, `background`, `title-size`],
  [`centered-info-frame`], [`frame-color`, `background`, `band-thickness`, `title-size`],
  [`double-tab-frame`], [`subtitle`, `title-border-color`, `frame-color`, `subtitle-color`, `subtitle-background`, `subtitle-border-color`, `background`],
  [`torn-paper-frame`], [`subtitle`, `subtitle-color`, `frame-color`, `background`, `outside-color`, `shadow-color`],
  [`spiral-banner-frame`], [`frame-color` (paper color), `binding-color` (wire color), `title-size`, `title-raise`],
  [`notebook-page-frame`], [`text-color`, `paper-color`, `rule-color`, `major-rule-color`, `binding-color`, `title-size`],
  [`numbered-exercise-frame`], [`subtitle`, `third-title`, `secondary-color`, `number-color`, `title-size`, `title-raise`, `number-raise`, `subtitle-raise`],
  [`property-frame`], [`badge-top`, `badge-bottom`, `badge-color`],
  [`tab-frame`], [`title-width` (`auto` by default: the tab is at least `25mm` wide like `curved-tab-frame` and grows with the title, and its height follows the title, with 1 mm above and 5 mm below it so the title always shows in full, centered horizontally; or a fixed length), `background`, `border-color`],
  [`exam-frame`], [`number`, `source`, `title-background`, `number-color`, `background`],
  [`sheet-frame`], [`width`, `body-height`, `border-color`, `title-border-color`, `shadow-color`, `body-color`, `title-size`, `breakable`],
  [`warning-note`], [`title`, `title-color`, `title-size`, `title-font`, `width`, `body-color`],
  [`practical-notebook`], [`width` (`auto` by default, or a length), `height`, `min-height`, `ring-spacing`, `paper-color`, `border-color`, `wire-color` and more (see the signature in `lib.typ`)],
  [`ribbon-banner`, `arched-ribbon`], [`title`, `color`, `text-color`, `border-color`, `title-size`],
  [`ribbon-notes-frame`], [`subtitle`, `tag-title`, `background`, `subtitle-color`, `tag-color`, `tag-end-color`, `tag-text-color`, `title-size`, `title-raise`],
  [`grid-notebook-frame`], [`accent-color`, `ring-spacing`, `paper-color`, `border-color`, `wire-color`, `rule-color`, `margin-color`, ...],
  [`folded-ribbon-frame`], [`color`, `title-color`, `title-text-color`, `fold-color`, `paper-color`, `ribbon-width`],
  [`hanging-tab-frame`], [`color`, `title-color`, `title-text-color`, `paper-color`],
  [`winged-tab-frame`], [`color`, `title-color`, `title-text-color`, `tab-fill`, `paper-color`],
  [`badge-notebook-frame`], [`title-box-color`, `accent-color`, `paper-color`, `border-color`, `text-fill`, `width`, `height`, `min-height`],
  [`prerequisites-frame`], [`items`, `label-color`, `color`, `fill-color`, `fold-color`, `shadow-color`, `wire-color`, `ring-spacing`, `ring-out`],
)

#note[The full signature of every frame is in `lib.typ`, at the function named `<name>-raw`; read the default values there.]

= Tips and troubleshooting

- *Arabic font:* set an Arabic font in your document, for example `#set text(font: "Noto Naskh Arabic", lang: "ar", dir: rtl)`. Language and direction affect the default title and the placement of ornaments.
- *"needs at least … mm of width" error:* some frames require a minimum width (`double-tab-frame` 60mm, `centered-info-frame` 40mm, `numbered-exercise-frame` 90mm). Do not place them in very narrow columns.
- *Frame inside a table or grid:* pass `breakable: false` so the frame behaves as a single block.
- *Title slightly high or low:* centering relies on font metrics. For fine adjustment use `title-raise`, `number-raise` and `subtitle-raise` where available.
- *See every frame:* try `examples/demo-ar.typ` (Arabic) and `examples/demo-en.typ` (Latin).
