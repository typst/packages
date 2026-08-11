// ============================================================
// black-angular-frame -- Example / Demo Presentation
// This file demonstrates all features of the template.
// ============================================================

#import "@preview/black-angular-frame:0.1.0": *

#let presentation-config = (
  title: "Black Angular Frame",
  subtitle: "A Typst Template for Academic Presentations",
  authors: "Author One, Author Two",
  institution: "Institution Name",
  date: "May 2026",
  final-message: "Thank you for your attention",
  primary-color: rgb("#1C1C1C"),
  secondary-color: rgb("#D9D9D9"),
  background-color: rgb("#FFFFFF"),
  font-color: luma(20),
  header-font-color-1: rgb("#999999"),
  header-font-color-2: rgb("#1C1C1C"),
  header-font-color-1-highlight: rgb("#FFFFFF"),
  content-center: 0.3,
  content-upper-padding: 0.05,
  content-lower-padding: 0.05,
  logos: (
    image("assets/typst-logo.png", height: 45pt),
    image("assets/github-logo.png", height: 45pt),
  ),
  TOC: true,
)

#show: black-angular-frame.with(config: presentation-config)

// ============================================================
// CONFIGURATION
// ============================================================
#new-section("Configuration")

#slide(title: "Template Configuration")[
  The template is configured from a single Typst dictionary. The table below lists the keys that can be passed through `config`, the expected value shape, and the defaults used when a key is omitted.

  #v(3pt)

  #let cell(body, fill: white, pos: left, weight: "regular") = baf-table-cell(
    fill: fill,
    stroke: luma(200) + 0.45pt,
    pos: pos,
    inset: (x: 3pt, y: 2pt),
  )[
    #text(font: "IBM Plex Sans", size: 5.6pt, weight: weight, body)
  ]

  #grid(
    columns: (23%, 20%, 20%, 37%),
    cell(fill: rgb("#1C1C1C"), weight: "bold")[#text(fill: white)[Name]],
    cell(fill: rgb("#1C1C1C"), weight: "bold")[#text(fill: white)[Expected value]],
    cell(fill: rgb("#1C1C1C"), weight: "bold")[#text(fill: white)[Default]],
    cell(fill: rgb("#1C1C1C"), weight: "bold")[#text(fill: white)[Description]],

    cell[`title`], cell[String], cell[`""`], cell[Presentation title.],
    cell[`subtitle`], cell[String], cell[`""`], cell[Presentation subtitle.],
    cell[`authors`], cell[String], cell[`""`], cell[Author line shown on the cover and footer.],
    cell[`institution`], cell[String], cell[`""`], cell[Institution shown on the cover and footer.],
    cell[`date`], cell[String], cell[`""`], cell[Date shown on the cover.],
    cell[`final-message`], cell[String], cell[`""`], cell[Message shown on the last slide.],
    cell[`primary-color`], cell[Color], cell[`rgb("#1C1C1C")`], cell[Main bars, highlights, numbering, and accents.],
    cell[`secondary-color`], cell[Color], cell[`rgb("#D9D9D9")`], cell[Secondary header and footer bands.],
    cell[`background-color`], cell[Color], cell[`rgb("#FFFFFF")`], cell[Slide background color.],
    cell[`font-color`], cell[Color], cell[`luma(20)`], cell[Default body text color.],
    cell[`header-font-color-1`],
    cell[Color],
    cell[`_muted-nav(primary-color)`],
    cell[Inactive text in the primary header band and text in the lower footer band.],
    cell[`header-font-color-2`],
    cell[Color],
    cell[`primary-color`],
    cell[Text in the secondary header and footer bands.],
    cell[`header-font-color-1-highlight`],
    cell[Color],
    cell[`rgb("#FFFFFF")`],
    cell[Active text in the primary header band.],
    cell[`content-center`],
    cell[Float 0-1],
    cell[`0.3`],
    cell[Vertical position used to center content; 0 starts at the top, 1 at the bottom.],
    cell[`content-upper-padding`],
    cell[Float 0-1],
    cell[`0.05`],
    cell[Top proportion of the available content area kept empty.],
    cell[`content-lower-padding`],
    cell[Float 0-1],
    cell[`0.05`],
    cell[Bottom proportion of the available content area kept empty.],
    cell[`logos`], cell[`array[content]`], cell[`()`], cell[Logo images or custom content shown on the cover.],
    cell[`TOC`], cell[Bool], cell[`true`], cell[Whether to add the table of contents slide with section links.],
  )

  #v(3pt)
  These names are intentionally presentation-level settings, so changing the theme does not require editing the template internals.
]

#slide(title: "Template Configuration Code")[
  The example presentation stores its theme and metadata in `presentation-config`, then passes that dictionary to the template with `black-angular-frame.with`.

  #v(3pt)

  #code-box(
    "#import \"@preview/black-angular-frame:0.1.0\": *

#let presentation-config = (
  title: \"Black Angular Frame\",
  subtitle: \"A Typst Template for Academic Presentations\",
  authors: \"Author One, Author Two\",
  institution: \"Institution Name\",
  date: \"May 2026\",
  final-message: \"Thank you for your attention\",
  primary-color: rgb(\"#1C1C1C\"),
  secondary-color: rgb(\"#D9D9D9\"),
  background-color: rgb(\"#FFFFFF\"),
  font-color: luma(20),
  header-font-color-1: rgb(\"#999999\"),
  header-font-color-2: rgb(\"#1C1C1C\"),
  header-font-color-1-highlight: rgb(\"#FFFFFF\"),
  content-center: 0.3,
  content-upper-padding: 0.05,
  content-lower-padding: 0.05,
  logos: (\n    image(\"assets/typst-logo.png\", height: 45pt),\n    image(\"assets/github-logo.png\", height: 45pt),\n  ),
  TOC: true,
)

#show: black-angular-frame.with(config: presentation-config)",
    type: "Typst",
    title: "Import and configure the template",
    lang: "typst",
    color: luma(90),
    fill: luma(248),
    text-size: 5.6pt,
  )

  #v(3pt)
  The rest of the document can focus on sections and slides while the template reads these values for the cover, navigation, footer, body text, logos, TOC, and final slide.
]

// ============================================================
// SECTION 1 -- TYPOGRAPHY
// ============================================================
#new-section("Typography")

#slide(title: "Default Fonts")[
  The template uses three IBM Plex families when available, with standard fallback fonts if they are not installed:

  #v(5pt)
  #grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 5pt,
    block(stroke: blue.darken(50%) + 0.6pt, inset: 7pt, width: 100%, text(font: "IBM Plex Serif", size: 11.5pt)[
      *IBM Plex Serif* \
      body text \
      Regular, _italic_, \
      *bold*, _*bold-italic*_
    ]),
    block(stroke: blue.darken(50%) + 0.6pt, inset: 7pt, width: 100%, text(font: "IBM Plex Sans", size: 11.5pt)[
      *IBM Plex Sans* \
      titles & headings \
      Regular, _italic_, \
      *bold*, _*bold-italic*_
    ]),
    block(stroke: blue.darken(50%) + 0.6pt, inset: 7pt, width: 100%, text(font: "IBM Plex Mono", size: 11.5pt)[
      *IBM Plex Mono* \
      code & verbatim \
      Regular, _italic_, \
      *bold*
    ]),
  )
  #v(6pt)
  Inline styling: #text(weight: "bold")[bold], #text(style: "italic")[italic], #text(fill: blue.darken(50%))[colored], #underline[underlined], #text(size: 13pt)[large (13 pt)], #text(size: 7.5pt)[small (7.5 pt)].
]

#slide(title: "Text Sizing and Semantic Emphasis")[
  #v(2pt)
  #text(size: 18pt, weight: "bold", fill: blue.darken(50%))[Headline -- 18 pt bold] \
  #text(size: 14pt, weight: "bold")[Subheading -- 14 pt bold] \
  #text(size: 12pt)[Section heading -- 12 pt regular] \
  #text(size: 10pt)[Body text -- 10 pt (default)] \
  #text(size: 8pt, fill: luma(60))[Caption / footnote -- 8 pt muted]

  #v(8pt)
  Semantic use: #text(style: "italic")[italics for emphasis], #text(weight: "bold")[bold for key terms], #text(fill: red.darken(20%))[red for warnings], #text(fill: green.darken(25%))[green for results]. Combine for #text(style: "italic", weight: "bold", fill: blue.darken(50%))[critical highlighted points].

  #v(4pt)
  Change the global accent via `primary-color`, the secondary bands via `secondary-color`, and the page fill via `background-color`. These parameters propagate through the navigation bar, footer, section dividers, TOC numbering squares, and theorem environments.
]

// ============================================================
// SECTION 2 -- LISTS AND ENUMERATIONS
// ============================================================
#new-section("Lists & Enumerations")

#slide(title: "Bullet Points and Nested Lists")[
  #two-col(
    [
      *Unordered list (three levels):*
      - First top-level item
        - Nested child A
        - Nested child B
          - Deeply nested
          - Another deep item
      - Second top-level item
        - Another child
      - Third top-level item
    ],
    [
      *Ordered enumeration (three levels):*
      + Step one: initialise
        + Sub-step 1a
        + Sub-step 1b
      + Step two: process data
        + Sub-step 2a
          + Detail 2a-i
      + Step three: evaluate output
      + Step four: report results
    ],
  )

  #v(5pt)
  Typst automatically styles bullet symbols and numerals at each nesting depth. Ordered and unordered lists can be freely mixed at any level.
]

// ============================================================
// SECTION 3 -- FIGURES
// ============================================================
#new-section("Figures")

#slide(title: "Inserting and Referencing Figures")[
  #two-col(
    [
      Figures use `#baf-figure(caption: [...])`. The counter resets per section; reference figures by their auto-assigned number. Longer surrounding paragraphs make it easier to inspect the vertical rhythm before and after visual material.

      #v(5pt)
      As shown in *Figure 1*, a colored rectangle acts as a placeholder. In practice pass `image("diagram.svg")` or any Typst content as the figure body. This text intentionally spans multiple lines so the figure margins can be judged against realistic prose.

      #v(4pt)
      *Figure 2* illustrates that captions appear italic below the figure, numbered automatically within the current section. The paragraph below the visual block should feel close enough to belong to the same slide, but not so close that the caption looks cramped.
    ],
    [
      The first placeholder represents a diagram or image inserted into the slide flow. A few lines of prose above it help show how the template separates ordinary text from framed visual content.

      #baf-figure(caption: [Placeholder -- replace with `image("diagram.svg")`.])[
        #rect(
          width: 100%,
          height: 62pt,
          fill: blue.darken(50%).lighten(88%),
          stroke: blue.darken(50%) + 0.8pt,
          align(center + horizon, text(fill: blue.darken(50%), size: 9pt)[Diagram / Image here]),
        )
      ]
      #baf-figure(caption: [Second figure -- captions are italic, automatically numbered.])[
        #rect(
          width: 100%,
          height: 38pt,
          fill: luma(240),
          stroke: luma(190) + 0.6pt,
          align(center + horizon, text(fill: luma(80), size: 9pt)[Another placeholder]),
        )
      ]

      After the second figure, this short paragraph checks the lower margin beneath a caption. It should read as a continuation of the slide narrative rather than as text accidentally attached to the figure.
    ],
  )
]

#slide(title: "Full-Width and Fractional-Width Figures (With Captions)")[
  #two-col(
    [
      A figure can expand to the full width of its column when the content should dominate the layout. This is useful for diagrams, screenshots, or images that need as much horizontal room as possible.

      #baf-figure(caption: [Full-width placeholder figure spanning the whole column.])[
        #rect(
          width: 100%,
          height: 60pt,
          fill: blue.darken(50%).lighten(88%),
          stroke: blue.darken(50%) + 0.8pt,
          align(center + horizon, text(fill: blue.darken(50%), size: 9pt)[Full-width figure]),
        )
      ]

      The caption should stay centered under the figure even when the visual takes the entire available width of the column.
    ],
    [
      Smaller visuals often read better when they keep some white space around them. A fractional-width figure makes that possible while still preserving the same numbering and caption behavior.

      #baf-figure(caption: [Fractional-width placeholder figure centered inside the column.])[
        #align(center, rect(
          width: 68%,
          height: 60pt,
          fill: luma(240),
          stroke: luma(190) + 0.6pt,
          align(center + horizon, text(fill: luma(80), size: 9pt)[Fractional-width figure]),
        ))
      ]

      This example checks that a narrower figure still aligns cleanly in the column and that the caption feels attached to the centered image rather than to the whole column width.
    ],
  )
]

#slide(title: "Full-Width and Fractional-Width Figures (No Captions)")[
  #two-col(
    [
      The same pair can also be shown without captions when the slide is purely illustrative and the surrounding prose already provides enough context for the audience.

      #baf-visual[
        #rect(
          width: 100%,
          height: 60pt,
          fill: blue.darken(50%).lighten(88%),
          stroke: blue.darken(50%) + 0.8pt,
          align(center + horizon, text(fill: blue.darken(50%), size: 9pt)[Full-width figure]),
        )
      ]

      Without a caption, the lower margin should still separate the figure from the next paragraph and keep the slide from feeling cramped.
    ],
    [
      The fractional-width version below uses the same visual content but keeps the narrower footprint. This lets us compare centered image placement with and without the caption layer.

      #baf-visual[
        #rect(
          width: 68%,
          height: 60pt,
          fill: luma(240),
          stroke: luma(190) + 0.6pt,
          align(center + horizon, text(fill: luma(80), size: 9pt)[Fractional-width figure]),
        )
      ]

      The surrounding text remains multi-line on purpose so we can judge the spacing around a centered narrow figure in the same way as we do for captioned figures.
    ],
  )
]

// ============================================================
// SECTION 4 -- TWO-COLUMN LAYOUT
// ============================================================
#new-section("Layouts", slide-title: "Two-Column Layouts")

#slide(title: "Two-Column Layout")[
  #two-col(
    left-width: 50%,
    [
      == Left column

      The `#two-col(left, right)` helper builds a two-column `grid`. Parameters:
      - `left-width` -- fraction of slide width (default 48%)
      - `gutter` -- gap between columns (default 4%)

      #v(4pt)
      Works well for: text + figure, code + output, comparative tables, side-by-side theorem boxes.
    ],
    [
      == Right column

      Any Typst content fits inside a column, including nested `two-col` calls, theorem boxes, figures, and tables.

      #baf-visual[
        #rect(
          width: 100%,
          height: 58pt,
          fill: luma(245),
          stroke: luma(200) + 0.6pt,
          align(center + horizon, text(size: 9pt, fill: luma(60))[Arbitrary block inside a column]),
        )
      ]
    ],
  )
]

// ============================================================
// SECTION 5 -- CODE BLOCKS
// ============================================================
#new-section("Code Blocks", slide-title: "Source Code & Pseudo-code")

#slide(title: "Source Code and Pseudo-code Side by Side")[
  #two-col(
    [
      #code-box(
        "def softmax(x):
    e = np.exp(x - x.max(axis=-1, keepdims=True))
    return e / e.sum(axis=-1, keepdims=True)

def cross_entropy(logits, labels):
    probs = softmax(logits)
    n = labels.shape[0]
    log_p = np.log(probs[range(n), labels])
    return -log_p.mean()",
        type: "Source Code",
        title: "Python",
        lang: "python",
        color: luma(110),
        fill: luma(245),
      )
      Uses `IBM Plex Mono` on a light grey background. Pass a language name to `#code-box(..., lang: "...")` for syntax highlighting.
    ],
    [
      #pseudo-code(
        "Algorithm: Mini-Batch SGD
Input: loss L, data D, lr eta, T, B
-------------------------------------
for t = 1 to T do
  B_t <- sample B examples from D
  g   <- grad_theta L(theta; B_t)
  theta <- theta - eta * g
end for
return theta",
        title: "Mini-Batch SGD",
      )
      Pseudo-code now uses the same framed box language as the theorem environments, with a `type` label and `title`.
    ],
  )
]

// ============================================================
// SECTION 6 -- TABLES
// ============================================================
#new-section("Tables")

#slide(title: "Paper-style and Grid-style Tables (No Captions)")[
  #two-col(
    [
      *Paper style* (booktabs-like -- horizontal rules only)

      This table is introduced by a short paragraph rather than a single label. The extra prose makes the spacing above the table visible in a realistic slide, where a table usually follows a sentence or two of setup.

      #let paper-cell(body, pos: left, header: false, model-col: false, first-data: false) = grid.cell(
        stroke: (
          bottom: if header { 0.6pt } else { none },
          right: if model-col { 0.6pt } else { none },
        ),
        inset: (
          left: 5pt,
          right: 5pt,
          top: if first-data { 6pt } else { 4pt },
          bottom: if header { 7pt } else { 4pt },
        ),
        align: pos,
        text(font: "IBM Plex Serif", body),
      )
      #baf-visual[
        #block(width: 100%, {
          line(length: 100%, stroke: 0.9pt)
          grid(
            columns: (28%, 24%, 24%, 24%),
            paper-cell(header: true, model-col: true)[*Method*],
            paper-cell(header: true, pos: center)[*Acc. (%)*],
            paper-cell(header: true, pos: center)[*F#sub[1]*],
            paper-cell(header: true, pos: center)[*AUC*],

            paper-cell(model-col: true, first-data: true)[Baseline],
            paper-cell(pos: center, first-data: true)[72.3],
            paper-cell(pos: center, first-data: true)[0.701],
            paper-cell(pos: center, first-data: true)[0.743],

            paper-cell(model-col: true)[Model A],
            paper-cell(pos: center)[81.5],
            paper-cell(pos: center)[0.803],
            paper-cell(pos: center)[0.851],

            paper-cell(model-col: true)[Model B],
            paper-cell(pos: center)[*88.9*],
            paper-cell(pos: center)[*0.876*],
            paper-cell(pos: center)[*0.903*],
          )
          line(length: 100%, stroke: 0.9pt)
        })
      ]
      Classic academic style: only top and bottom rules, no vertical lines. The text after the table deliberately runs for a couple of lines so the lower margin can be compared with the upper margin.
    ],
    [
      *Grid style* (full borders, colored header, alternating rows)

      The grid version is meant for dense numeric summaries or dashboard-like reporting. A longer lead-in makes it easier to see whether the table feels attached to the explanation or floats too far away.

      #let grid-cell(body, fill: white, stroke: luma(200) + 0.6pt, pos: center) = baf-table-cell(
        fill: fill,
        stroke: stroke,
        pos: pos,
        body,
      )
      #baf-visual[
        #block(width: 100%, grid(
          columns: (28%, 24%, 24%, 24%),
          grid-cell(fill: blue.darken(50%), pos: left)[#text(fill: white)[Method]],
          grid-cell(fill: blue.darken(50%))[#text(fill: white)[Acc. (%)]],
          grid-cell(fill: blue.darken(50%))[#text(fill: white)[F#sub[1]]],
          grid-cell(fill: blue.darken(50%))[#text(fill: white)[AUC]],

          grid-cell(fill: luma(248), pos: left)[Baseline],
          grid-cell(fill: luma(248))[72.3],
          grid-cell(fill: luma(248))[0.701],
          grid-cell(fill: luma(248))[0.743],

          grid-cell(fill: white, pos: left)[Model A],
          grid-cell(fill: white)[81.5],
          grid-cell(fill: white)[0.803],
          grid-cell(fill: white)[0.851],

          grid-cell(fill: luma(248), pos: left)[Model B],
          grid-cell(fill: luma(248))[*88.9*],
          grid-cell(fill: luma(248))[*0.876*],
          grid-cell(fill: luma(248))[*0.903*],
        ))
      ]
      Dashboard style: solid grid, alternating row shading. This closing note also spans multiple lines, which helps reveal whether the table block leaves enough room before normal prose resumes.
    ],
  )
]

#slide(title: "Paper-style and Grid-style Tables (With Captions)")[
  #two-col(
    [
      *Paper style* (booktabs-like -- horizontal rules only)

      Captions are useful when the table needs to be referenced later in the talk or connected to a source. This paragraph gives the captioned table enough surrounding prose to test both the top margin and the caption spacing.

      #let paper-cell(body, pos: left, header: false, model-col: false, first-data: false) = grid.cell(
        stroke: (
          bottom: if header { 0.6pt } else { none },
          right: if model-col { 0.6pt } else { none },
        ),
        inset: (
          left: 5pt,
          right: 5pt,
          top: if first-data { 6pt } else { 4pt },
          bottom: if header { 7pt } else { 4pt },
        ),
        align: pos,
        text(font: "IBM Plex Serif", body),
      )
      #figure(
        kind: table,
        caption: [Placeholder caption for the paper-style table.],
        {
          block(width: 100%, {
            line(length: 100%, stroke: 0.9pt)
            grid(
              columns: (28%, 24%, 24%, 24%),
              paper-cell(header: true, model-col: true)[*Method*],
              paper-cell(header: true, pos: center)[*Acc. (%)*],
              paper-cell(header: true, pos: center)[*F#sub[1]*],
              paper-cell(header: true, pos: center)[*AUC*],

              paper-cell(model-col: true, first-data: true)[Baseline],
              paper-cell(pos: center, first-data: true)[72.3],
              paper-cell(pos: center, first-data: true)[0.701],
              paper-cell(pos: center, first-data: true)[0.743],

              paper-cell(model-col: true)[Model A],
              paper-cell(pos: center)[81.5],
              paper-cell(pos: center)[0.803],
              paper-cell(pos: center)[0.851],

              paper-cell(model-col: true)[Model B],
              paper-cell(pos: center)[*88.9*],
              paper-cell(pos: center)[*0.876*],
              paper-cell(pos: center)[*0.903*],
            )
            line(length: 100%, stroke: 0.9pt)
          })
        },
      )
      Classic academic style: only top and bottom rules, no vertical lines. With a caption present, the paragraph after the table should sit beneath the full table block rather than feeling glued to the caption.
    ],
    [
      *Grid style* (full borders, colored header, alternating rows)

      The captioned grid table shows how a more operational table behaves inside the same layout. The text before it is intentionally longer so vertical spacing is visible without relying on empty slide area.

      #let grid-cell(body, fill: white, stroke: luma(200) + 0.6pt, pos: center) = baf-table-cell(
        fill: fill,
        stroke: stroke,
        pos: pos,
        body,
      )
      #figure(
        kind: table,
        caption: [Placeholder caption for the grid-style table.],
        {
          block(width: 100%, grid(
            columns: (28%, 24%, 24%, 24%),
            grid-cell(fill: blue.darken(50%), pos: left)[#text(fill: white)[Method]],
            grid-cell(fill: blue.darken(50%))[#text(fill: white)[Acc. (%)]],
            grid-cell(fill: blue.darken(50%))[#text(fill: white)[F#sub[1]]],
            grid-cell(fill: blue.darken(50%))[#text(fill: white)[AUC]],

            grid-cell(fill: luma(248), pos: left)[Baseline],
            grid-cell(fill: luma(248))[72.3],
            grid-cell(fill: luma(248))[0.701],
            grid-cell(fill: luma(248))[0.743],

            grid-cell(fill: white, pos: left)[Model A],
            grid-cell(fill: white)[81.5],
            grid-cell(fill: white)[0.803],
            grid-cell(fill: white)[0.851],

            grid-cell(fill: luma(248), pos: left)[Model B],
            grid-cell(fill: luma(248))[*88.9*],
            grid-cell(fill: luma(248))[*0.876*],
            grid-cell(fill: luma(248))[*0.903*],
          ))
        },
      )
      Dashboard style: solid grid, alternating row shading. This final description should have comfortable breathing room after the caption while still reading as part of the same explanatory unit.
    ],
  )
]

// ============================================================
// SECTION 7 -- DIAGRAMS AND CHARTS (three slides)
// ============================================================
#new-section("Diagrams & Charts")

// ---- Diagram drawing helpers -------------------------------
#let _arrow-head(x, y, dir: "r", color: luma(25)) = {
  if dir == "r" {
    place(top + left, dx: x - 6pt, dy: y - 3pt, polygon((0pt, 0pt), (6pt, 3pt), (0pt, 6pt), fill: color))
  } else if dir == "l" {
    place(top + left, dx: x, dy: y - 3pt, polygon((0pt, 3pt), (6pt, 0pt), (6pt, 6pt), fill: color))
  } else if dir == "d" {
    place(top + left, dx: x - 3pt, dy: y - 6pt, polygon((0pt, 0pt), (6pt, 0pt), (3pt, 6pt), fill: color))
  } else if dir == "u" {
    place(top + left, dx: x - 3pt, dy: y, polygon((0pt, 6pt), (3pt, 0pt), (6pt, 6pt), fill: color))
  } else if dir == "dr" {
    place(top + left, dx: x - 6pt, dy: y - 6pt, polygon((6pt, 6pt), (1pt, 4pt), (4pt, 1pt), fill: color))
  } else if dir == "dl" {
    place(top + left, dx: x, dy: y - 6pt, polygon((0pt, 6pt), (5pt, 4pt), (2pt, 1pt), fill: color))
  } else if dir == "ur" {
    place(top + left, dx: x - 6pt, dy: y, polygon((6pt, 0pt), (1pt, 2pt), (4pt, 5pt), fill: color))
  } else {
    place(top + left, dx: x, dy: y, polygon((0pt, 0pt), (5pt, 2pt), (2pt, 5pt), fill: color))
  }
}

#let _arr-r(x1, y, x2, color: luma(25), weight: 0.8pt, label: none, label-dy: -8pt) = {
  place(top + left, line(start: (x1, y), end: (x2 - 5pt, y), stroke: color + weight))
  _arrow-head(x2, y, dir: "r", color: color)
  if label != none {
    place(top + left, dx: (x1 + x2) / 2 - 6pt, dy: y + label-dy, text(size: 6.4pt, fill: color, label))
  }
}

#let _arr-l(x1, y, x2, color: luma(25), weight: 0.8pt, label: none, label-dy: -8pt) = {
  place(top + left, line(start: (x1, y), end: (x2 + 5pt, y), stroke: color + weight))
  _arrow-head(x2, y, dir: "l", color: color)
  if label != none {
    place(top + left, dx: (x1 + x2) / 2 - 6pt, dy: y + label-dy, text(size: 6.4pt, fill: color, label))
  }
}

#let _arr-v(x, y1, y2, color: luma(25), weight: 0.8pt, label: none, label-dx: 4pt) = {
  if y2 > y1 {
    place(top + left, line(start: (x, y1), end: (x, y2 - 5pt), stroke: color + weight))
    _arrow-head(x, y2, dir: "d", color: color)
  } else {
    place(top + left, line(start: (x, y1), end: (x, y2 + 5pt), stroke: color + weight))
    _arrow-head(x, y2, dir: "u", color: color)
  }
  if label != none {
    place(top + left, dx: x + label-dx, dy: (y1 + y2) / 2 - 4pt, text(size: 6.4pt, fill: color, label))
  }
}

#let _arr-diag(x1, y1, x2, y2, dir, color: luma(25), weight: 0.8pt, label: none, label-dx: 0pt, label-dy: 0pt) = {
  place(top + left, line(start: (x1, y1), end: (x2, y2), stroke: color + weight))
  _arrow-head(x2, y2, dir: dir, color: color)
  if label != none {
    place(top + left, dx: (x1 + x2) / 2 + label-dx, dy: (y1 + y2) / 2 + label-dy, text(size: 6.4pt, fill: color, label))
  }
}

#let _diagram-block(label, w: 52pt, h: 18pt, fill: luma(245), stroke: luma(25), text-size: 6.6pt, radius: 2pt) = box(
  width: w,
  height: h,
  fill: fill,
  stroke: stroke + 0.7pt,
  radius: radius,
  align(center + horizon, text(size: text-size, fill: luma(15), label)),
)

#let transformer-diagram = align(center, {
  let W = 278pt
  let H = 232pt
  let ink = luma(15)
  let block-w = 54pt
  let frame-w = 90pt
  let frame-pad-x = (frame-w - block-w) / 2
  let enc-x = 30pt
  let dec-x = 154pt
  let label-size = 5.7pt
  let small-size = 4.9pt
  let arrow-weight = 0.9pt
  let node-r = 3.5pt
  let positional-center-y = 180pt
  let input-sum-y = positional-center-y
  let nx-y = 118pt
  let decoder-bottom-label-width = 94pt
  let pink = rgb("#F9DCDD")
  let peach = rgb("#FFE3B8")
  let bluefill = rgb("#C5E8F5")
  let normfill = rgb("#F3F5C2")
  let greenfill = rgb("#D8F0D9")
  let violet = rgb("#E4E7F8")

  let encoder = (
    x: enc-x,
    frame-y: 73pt,
    frame-h: 100pt,
    stack-x: enc-x + frame-pad-x,
    nx-x: enc-x - 25pt,
    nx-y: nx-y,
    pos-side: "left",
    pos-label-x: -15pt,
    pos-circle-x: 49pt,
    emb-label: [Input\ Embedding],
    bottom-label: [Inputs],
    bottom-label-x: enc-x + 8pt,
    bottom-label-width: 74pt,
  )
  let decoder = (
    x: dec-x,
    frame-y: 41pt,
    frame-h: 132pt,
    stack-x: dec-x + frame-pad-x,
    nx-x: dec-x + frame-w + 8pt,
    nx-y: nx-y,
    pos-side: "right",
    pos-label-x: 229pt,
    pos-circle-x: 224pt,
    emb-label: [Output\ Embedding],
    bottom-label: [Outputs (shifted right)],
    bottom-label-x: dec-x + frame-pad-x + block-w / 2 - decoder-bottom-label-width / 2,
    bottom-label-width: decoder-bottom-label-width,
  )

  let cx(col) = col.stack-x + block-w / 2
  let cy(layer) = layer.y + layer.h / 2

  let diagram-text(x, y, body, size: label-size, width: auto, align-pos: center) = place(
    top + left,
    dx: x,
    dy: y,
    block(width: width, align(align-pos, text(size: size, fill: ink, body))),
  )
  let diagram-text-centered-on-y(x, center-y, body, size: label-size, width: auto, align-pos: center) = context {
    let label = block(width: width, align(align-pos, text(size: size, fill: ink, body)))
    place(top + left, dx: x, dy: center-y - measure(label).height / 2, label)
  }
  let block-at(x, y, label, fill, h: 16pt, size: label-size) = place(
    top + left,
    dx: x,
    dy: y,
    _diagram-block(label, w: block-w, h: h, fill: fill, stroke: ink, text-size: size, radius: 2.2pt),
  )
  let frame(col) = place(
    top + left,
    dx: col.x,
    dy: col.frame-y,
    block(
      width: frame-w,
      height: col.frame-h,
      stroke: ink + 1.3pt,
      radius: 7pt,
      fill: luma(250),
    ),
  )
  let plus(x, y) = {
    let r = node-r
    let d = 2.45pt
    place(top + left, dx: x - r, dy: y - r, circle(radius: r, stroke: ink + 0.85pt, fill: white))
    place(top + left, line(start: (x - d, y), end: (x + d, y), stroke: ink + 0.65pt))
    place(top + left, line(start: (x, y - d), end: (x, y + d), stroke: ink + 0.65pt))
  }
  let pos-signal(x, y) = {
    let r = node-r
    place(top + left, dx: x - r, dy: y - r, circle(radius: r, stroke: ink + 0.9pt, fill: white))
    place(top + left, curve(
      stroke: ink + 0.65pt,
      fill: none,
      curve.move((x - 2.2pt, y + 1.1pt)),
      curve.cubic((x - 1.2pt, y + 1.1pt), (x - 1.1pt, y - 1.1pt), (x, y)),
      curve.cubic((x + 1.1pt, y + 1.1pt), (x + 1.2pt, y - 1.1pt), (x + 2.2pt, y - 1.1pt)),
    ))
  }
  let poly(points, weight: arrow-weight) = {
    for i in range(points.len() - 1) {
      let a = points.at(i)
      let b = points.at(i + 1)
      place(top + left, line(start: a, end: b, stroke: ink + weight))
    }
  }
  let arrow-head(x, y, dir: "r") = {
    let len = 2.4pt
    let half = 1.5pt
    if dir == "r" {
      place(top + left, polygon((x, y), (x - len, y - half), (x - len, y + half), fill: ink))
    } else if dir == "l" {
      place(top + left, polygon((x, y), (x + len, y - half), (x + len, y + half), fill: ink))
    } else if dir == "d" {
      place(top + left, polygon((x, y), (x - half, y - len), (x + half, y - len), fill: ink))
    } else {
      place(top + left, polygon((x, y), (x - half, y + len), (x + half, y + len), fill: ink))
    }
  }
  let arrow-poly(points, dir: "r") = {
    poly(points)
    let end = points.at(points.len() - 1)
    arrow-head(end.at(0), end.at(1), dir: dir)
  }
  let arr-v(x, y1, y2, weight: arrow-weight) = {
    let len = 2.4pt
    if y2 > y1 {
      place(top + left, line(start: (x, y1), end: (x, y2 - len), stroke: ink + weight))
      arrow-head(x, y2, dir: "d")
    } else {
      place(top + left, line(start: (x, y1), end: (x, y2 + len), stroke: ink + weight))
      arrow-head(x, y2, dir: "u")
    }
  }
  let attention-fork(layer, gap: 6pt) = {
    let xs = (layer.x + 9pt, layer.x + block-w / 2, layer.x + block-w - 9pt)
    let y = layer.y + layer.h + gap
    place(top + left, line(start: (xs.first(), y), end: (xs.last(), y), stroke: ink + arrow-weight))
    for x in xs {
      arr-v(x, y, layer.y + layer.h)
    }
  }
  let branch-y(start, end, pct: 0.3) = start + pct * (end - start)
  let residual(col, layer, norm, branch-from, branch-to, side: "left", branch-pct: 0.3) = {
    let bus = if side == "left" { col.x + 6pt } else { col.x + frame-w - 6pt }
    let by = branch-y(branch-from, branch-to, pct: branch-pct)
    let from = (cx(col), by)
    let mid = (bus, by)
    let into = if side == "left" {
      (norm.x, cy(norm))
    } else {
      (norm.x + block-w, cy(norm))
    }
    arrow-poly((from, mid, (bus, cy(norm)), into), dir: if side == "left" { "r" } else { "l" })
  }
  let column-bottom(col) = {
    let emb-y = 188pt
    let emb-h = 14pt
    let plus-y = positional-center-y
    block-at(col.stack-x, emb-y, col.emb-label, pink, h: emb-h, size: 4.2pt)
    plus(cx(col), plus-y)
    arr-v(cx(col), emb-y + emb-h + 10pt, emb-y + emb-h)
    arr-v(cx(col), emb-y, plus-y + 3.5pt)
    diagram-text(col.bottom-label-x, 221pt, col.bottom-label, size: 7.2pt, width: col.bottom-label-width)
    diagram-text-centered-on-y(col.pos-label-x, positional-center-y, [Positional Embedding], size: 5.0pt, width: 60pt)
    pos-signal(col.pos-circle-x, plus-y)
    if col.pos-side == "left" {
      place(top + left, line(
        start: (col.pos-circle-x + node-r, plus-y),
        end: (cx(col) - node-r, plus-y),
        stroke: ink + arrow-weight,
      ))
    } else {
      place(top + left, line(
        start: (cx(col) + node-r, plus-y),
        end: (col.pos-circle-x - node-r, plus-y),
        stroke: ink + arrow-weight,
      ))
    }
  }
  let sum-to-attention(col, layer, gap: 6pt) = place(
    top + left,
    line(
      start: (cx(col), input-sum-y - 3.5pt),
      end: (cx(col), layer.y + layer.h + gap),
      stroke: ink + arrow-weight,
    ),
  )
  let lower-attn-shift = 3pt

  let enc-layers = (
    (
      key: "attn",
      x: encoder.stack-x,
      y: 138pt + lower-attn-shift,
      h: 16pt,
      label: [Multi-Head\ Attention],
      fill: peach,
      size: 4.5pt,
    ),
    (
      key: "norm1",
      x: encoder.stack-x,
      y: 123pt + lower-attn-shift,
      h: 9pt,
      label: [Add & Norm],
      fill: normfill,
      size: 4.8pt,
    ),
    (key: "ff", x: encoder.stack-x, y: 92pt, h: 15pt, label: [Feed\ Forward], fill: bluefill, size: 4.7pt),
    (key: "norm2", x: encoder.stack-x, y: 77pt, h: 9pt, label: [Add & Norm], fill: normfill, size: 4.8pt),
  )
  let dec-layers = (
    (
      key: "masked",
      x: decoder.stack-x,
      y: 139pt + lower-attn-shift,
      h: 18pt,
      label: [Masked\ Multi-Head\ Attention],
      fill: peach,
      size: 4.0pt,
    ),
    (
      key: "norm1",
      x: decoder.stack-x,
      y: 125pt + lower-attn-shift,
      h: 9pt,
      label: [Add & Norm],
      fill: normfill,
      size: 4.8pt,
    ),
    (key: "cross", x: decoder.stack-x, y: 98pt, h: 14pt, label: [Multi-Head\ Attention], fill: peach, size: 4.2pt),
    (key: "norm2", x: decoder.stack-x, y: 84pt, h: 9pt, label: [Add & Norm], fill: normfill, size: 4.8pt),
    (key: "ff", x: decoder.stack-x, y: 59pt, h: 14pt, label: [Feed\ Forward], fill: bluefill, size: 4.4pt),
    (key: "norm3", x: decoder.stack-x, y: 45pt, h: 9pt, label: [Add & Norm], fill: normfill, size: 4.8pt),
    (key: "linear", x: decoder.stack-x, y: 27pt, h: 9pt, label: [Linear], fill: violet, size: 4.9pt),
    (key: "softmax", x: decoder.stack-x, y: 15.5pt, h: 9pt, label: [Softmax], fill: greenfill, size: 4.9pt),
  )
  let enc(key) = enc-layers.find(layer => layer.key == key)
  let dec(key) = dec-layers.find(layer => layer.key == key)

  box(width: W, height: H, {
    frame(encoder)
    frame(decoder)
    diagram-text(encoder.nx-x, encoder.nx-y, [N×], size: 12pt)
    diagram-text(decoder.nx-x, decoder.nx-y, [N×], size: 12pt)
    diagram-text(decoder.stack-x - 7pt, 0pt, [Output Probabilities], size: 7.2pt, width: block-w + 14pt)

    column-bottom(encoder)
    column-bottom(decoder)

    for layer in enc-layers {
      block-at(layer.x, layer.y, layer.label, layer.fill, h: layer.h, size: layer.size)
    }
    for layer in dec-layers {
      block-at(layer.x, layer.y, layer.label, layer.fill, h: layer.h, size: layer.size)
    }

    attention-fork(enc("attn"))
    attention-fork(dec("masked"))
    sum-to-attention(encoder, enc("attn"))
    sum-to-attention(decoder, dec("masked"))

    residual(
      encoder,
      enc("attn"),
      enc("norm1"),
      input-sum-y - 3.5pt,
      enc("attn").y + enc("attn").h + 6pt,
      side: "left",
      branch-pct: 0.65,
    )
    residual(encoder, enc("ff"), enc("norm2"), enc("norm1").y, enc("ff").y + enc("ff").h, side: "left", branch-pct: 0.5)
    residual(
      decoder,
      dec("masked"),
      dec("norm1"),
      input-sum-y - 3.5pt,
      dec("masked").y + dec("masked").h + 6pt,
      side: "right",
      branch-pct: 0.65,
    )
    residual(decoder, dec("cross"), dec("norm2"), dec("norm1").y, dec("cross").y + dec("cross").h, side: "right")
    residual(
      decoder,
      dec("ff"),
      dec("norm3"),
      dec("norm2").y,
      dec("ff").y + dec("ff").h,
      side: "right",
      branch-pct: 0.5,
    )

    arr-v(cx(encoder), enc("attn").y, enc("norm1").y + enc("norm1").h)
    arr-v(cx(encoder), enc("norm1").y, enc("ff").y + enc("ff").h)
    arr-v(cx(encoder), enc("ff").y, enc("norm2").y + enc("norm2").h)
    arr-v(cx(decoder), dec("masked").y, dec("norm1").y + dec("norm1").h)
    let cross-input-xs = (
      dec("cross").x + 9pt,
      dec("cross").x + block-w / 2,
      dec("cross").x + block-w - 9pt,
    )
    let cross-right-route-y = branch-y(dec("norm1").y, dec("cross").y + dec("cross").h, pct: 0.3) - 4pt
    arrow-poly(
      (
        (cx(decoder), dec("norm1").y),
        (cx(decoder), cross-right-route-y),
        (cross-input-xs.last(), cross-right-route-y),
        (cross-input-xs.last(), dec("cross").y + dec("cross").h),
      ),
      dir: "u",
    )
    arr-v(cx(decoder), dec("cross").y, dec("norm2").y + dec("norm2").h)
    arr-v(cx(decoder), dec("norm2").y, dec("ff").y + dec("ff").h)
    arr-v(cx(decoder), dec("ff").y, dec("norm3").y + dec("norm3").h)
    arr-v(cx(decoder), dec("norm3").y, dec("linear").y + dec("linear").h)
    arr-v(cx(decoder), dec("linear").y, dec("softmax").y + dec("softmax").h)
    arr-v(cx(decoder), dec("softmax").y, 10pt)

    let enc-out-x = cx(encoder)
    let enc-out-y = enc("norm2").y
    let enc-route-y = encoder.frame-y - 5pt
    let enc-dec-route-x = (encoder.x + frame-w + decoder.x) / 2
    let cross-in-y = dec("cross").y + dec("cross").h + 5pt
    poly((
      (enc-out-x, enc-out-y),
      (enc-out-x, enc-route-y),
      (enc-dec-route-x, enc-route-y),
      (enc-dec-route-x, cross-in-y),
      (cross-input-xs.at(1), cross-in-y),
    ))
    arr-v(cross-input-xs.at(1), cross-in-y, dec("cross").y + dec("cross").h)
    arrow-poly(
      (
        (enc-dec-route-x, cross-in-y),
        (cross-input-xs.at(0), cross-in-y),
        (cross-input-xs.at(0), dec("cross").y + dec("cross").h),
      ),
      dir: "u",
    )
  })
})


#let closed-loop-diagram = align(center, {
  let W = 248pt
  let H = 112pt
  let ink = luma(0)
  let stroke = ink + 1.0pt
  let label(x, y, body, size: 7.2pt) = place(top + left, dx: x, dy: y, text(size: size, fill: ink, body))
  let arrow-r(x1, y, x2) = {
    place(top + left, line(start: (x1, y), end: (x2 - 5pt, y), stroke: stroke))
    _arrow-head(x2, y, dir: "r", color: ink)
  }
  let arrow-l(x1, y, x2) = {
    place(top + left, line(start: (x1, y), end: (x2 + 5pt, y), stroke: stroke))
    _arrow-head(x2, y, dir: "l", color: ink)
  }
  let arrow-u(x, y1, y2) = {
    place(top + left, line(start: (x, y1), end: (x, y2 + 5pt), stroke: stroke))
    _arrow-head(x, y2, dir: "u", color: ink)
  }
  let arrow-d(x, y1, y2) = {
    place(top + left, line(start: (x, y1), end: (x, y2 - 5pt), stroke: stroke))
    _arrow-head(x, y2, dir: "d", color: ink)
  }
  let labeled-arrow(x1, y1, x2, y2, body, label-dx: 0pt, label-dy: 0pt, label-size: 8pt) = {
    if y1 == y2 and x2 > x1 {
      arrow-r(x1, y1, x2)
    } else if y1 == y2 and x2 < x1 {
      arrow-l(x1, y1, x2)
    } else if x1 == x2 and y2 > y1 {
      arrow-d(x1, y1, y2)
    } else if x1 == x2 and y2 < y1 {
      arrow-u(x1, y1, y2)
    } else {
      place(top + left, line(start: (x1, y1), end: (x2, y2), stroke: stroke))
    }
    if body != none {
      label((x1 + x2) / 2 + label-dx, (y1 + y2) / 2 + label-dy, body, size: label-size)
    }
  }


  let sys-box(x, y, label, w: 26pt, h: 26pt) = {
    place(
      top + left,
      dx: x,
      dy: y,
      box(
        width: w,
        height: h,
        fill: white,
        stroke: ink + 1.2pt,
        align(center + horizon, text(size: 8pt, fill: ink, label)),
      ),
    )
  }

  let sum-sign(x, y, body) = place(
    top + left,
    dx: x,
    dy: y,
    box(width: 5.5pt, height: 5.5pt, align(center + horizon, text(size: 5.8pt, fill: ink, body))),
  )
  let sum-node(x, y, kind: "feedback") = {
    let r = 10pt
    let d = 7.1pt
    let signs = if kind == "disturbance" {
      ((-8.6pt, -3.0pt, [+]), (-2.8pt, -8.6pt, [+]))
    } else {
      ((-8.6pt, -3.0pt, [+]), (-2.8pt, 3.2pt, [−]))
    }
    place(top + left, dx: x - r, dy: y - r, circle(radius: r, stroke: ink + 1.0pt, fill: white))
    place(top + left, line(start: (x - d, y - d), end: (x + d, y + d), stroke: ink + 0.65pt))
    place(top + left, line(start: (x - d, y + d), end: (x + d, y - d), stroke: ink + 0.65pt))
    for (sx, sy, sign) in signs {
      sum-sign(x + sx, y + sy, sign)
    }
  }
  box(width: W, height: H, {
    let y = 42pt
    let s1 = 48pt
    let s2 = 154pt
    let low = 85pt
    let arrow-len = 30pt
    let disturbance-arrow-len = 20pt
    let node-r = 10pt
    let box-w = 26pt
    let k-x = s1 + node-r + arrow-len
    let g-x = s2 + node-r + arrow-len
    let branch = g-x + box-w + arrow-len / 2
    let h-x = 144pt

    sum-node(s1, y)
    label(k-x - 4pt, 17pt, [Controller], size: 7pt)

    sys-box(k-x, 29pt, [$K(z)$])
    // sys-box(50pt, 29pt, [$K(z)$])

    sum-node(s2, y, kind: "disturbance")
    label(g-x - 11pt, 17pt, [Target System], size: 7pt)
    sys-box(g-x, 29pt, [$G(z)$])
    sys-box(h-x, 72pt, [$H(z)$])
    label(h-x - 7pt, 103pt, [Transducer], size: 7pt)

    labeled-arrow(s1 - node-r - arrow-len, y, s1 - node-r, y, [$R(z)$], label-dx: -10pt, label-dy: -10pt)
    labeled-arrow(s1 + node-r, y, k-x, y, [$E(z)$], label-dx: -10pt, label-dy: -10pt)
    labeled-arrow(k-x + box-w, y, s2 - node-r, y, [$U(z)$], label-dx: -10pt, label-dy: -10pt)
    labeled-arrow(s2 + node-r, y, g-x, y, [$V(z)$], label-dx: -10pt, label-dy: -10pt)
    labeled-arrow(g-x + box-w, y, g-x + box-w + arrow-len, y, [$Y(z)$], label-dx: -10pt, label-dy: -10pt)
    labeled-arrow(s2, y - node-r - disturbance-arrow-len, s2, y - node-r, [$D(z)$], label-dx: -9pt, label-dy: -21pt)
    place(top + left, line(start: (branch, y), end: (branch, low), stroke: stroke))
    arrow-l(branch, low, h-x + box-w)
    place(top + left, line(start: (h-x, low), end: (s1, low), stroke: stroke))
    arrow-u(s1, low, 52pt)
    label(94pt, 90pt, [$W(z)$], size: 8pt)
  })
})



#let kernel-image-diagram = align(center, {
  let W = 220pt
  let H = 86pt
  let ink = luma(15)
  let label-size = 9pt
  let node(x, y, w, h, body, size) = place(
    top + left,
    dx: x - w / 2,
    dy: y - h / 2,
    box(width: w, height: h, align(center + horizon, text(size: size, fill: ink, body))),
  )
  let arrow-r(x1, y, x2, body, label-dx: 0pt, label-dy: -13pt) = {
    place(top + left, line(start: (x1, y), end: (x2 - 5pt, y), stroke: ink + 0.8pt))
    _arrow-head(x2, y, dir: "r", color: ink)
    place(top + left, dx: (x1 + x2) / 2 + label-dx, dy: y + label-dy, text(size: label-size, fill: ink, body))
  }
  let arrow-v(x, y1, y2, body, label-dx: 7pt, label-dy: -4pt) = {
    if y2 > y1 {
      place(top + left, line(start: (x, y1), end: (x, y2 - 5pt), stroke: ink + 0.8pt))
      _arrow-head(x, y2, dir: "d", color: ink)
    } else {
      place(top + left, line(start: (x, y1), end: (x, y2 + 5pt), stroke: ink + 0.8pt))
      _arrow-head(x, y2, dir: "u", color: ink)
    }
    place(top + left, dx: x + label-dx, dy: (y1 + y2) / 2 + label-dy, text(size: label-size, fill: ink, body))
  }
  box(width: W, height: H, {
    let top-y = 20pt
    let bot-y = 68pt
    let left-x = 66pt
    let right-x = 162pt
    let g-w = 24pt
    let gp-w = 30pt
    let q-w = 92pt
    let im-w = 58pt
    let g-arrow-w = 20pt
    let gp-arrow-w = 24pt
    let q-arrow-w = 74pt
    let im-arrow-w = 42pt
    let node-h = 18pt

    node(left-x, top-y, g-w, node-h, [$G$], 18pt)
    node(right-x, top-y, gp-w, node-h, [$G'$], 18pt)
    node(left-x, bot-y, q-w, node-h, [$G slash ker phi$], 16pt)
    node(right-x, bot-y, im-w, node-h, [$im phi$], 16pt)

    arrow-r(left-x + g-arrow-w / 2 + 2pt, top-y, right-x - gp-arrow-w / 2 + 1pt, [$phi$], label-dx: -4pt)
    arrow-v(left-x, top-y + node-h / 2 + 2pt, bot-y - node-h / 2 + 1pt, [$-$], label-dx: -13pt)
    arrow-r(
      left-x + q-arrow-w / 2 + 2pt,
      bot-y,
      right-x - im-arrow-w / 2 + 1pt,
      [$overline(phi)$],
      label-dx: -8pt,
      label-dy: 5pt,
    )
    arrow-v(right-x, bot-y - node-h / 2 + 1pt, top-y + node-h / 2 + 2pt, [inc], label-dx: 7pt)
  })
})

#let weighted-transition-graph = align(center, {
  let W = 176pt
  let H = 162pt
  let ink = luma(25)
  let edge = rgb("#C66A00")
  let node-r = 13pt
  let nodes = (
    P: (x: 17pt, y: 99pt),
    B: (x: 64pt, y: 58pt),
    D: (x: 110pt, y: 17pt),
    C: (x: 110pt, y: 98pt),
    M: (x: 64pt, y: 139pt),
    L: (x: 158pt, y: 139pt),
  )
  let pos(name) = nodes.at(name)
  let arrow-dir(dx, dy) = {
    let ax = calc.abs(dx)
    let ay = calc.abs(dy)
    if ax < ay * 0.45 {
      if dy > 0pt { "d" } else { "u" }
    } else if ay < ax * 0.45 {
      if dx > 0pt { "r" } else { "l" }
    } else if dx > 0pt and dy > 0pt {
      "dr"
    } else if dx < 0pt and dy > 0pt {
      "dl"
    } else if dx > 0pt and dy < 0pt {
      "ur"
    } else {
      "ul"
    }
  }
  let node(x, y, short) = {
    place(top + left, dx: x - node-r, dy: y - node-r, box(
      width: 2 * node-r,
      height: 2 * node-r,
      radius: node-r,
      stroke: ink + 0.7pt,
      fill: white,
      align(center + horizon, text(size: 8.8pt, style: "italic", short)),
    ))
  }
  let node-by-name(name, body) = {
    let p = pos(name)
    node(p.x, p.y, body)
  }
  let label-at(x, y, body) = {
    place(top + left, dx: x - 7.5pt, dy: y - 5pt, box(
      width: 15pt,
      height: 10pt,
      fill: white,
      inset: 0pt,
      align(center + horizon, text(size: 7.6pt, fill: ink, body)),
    ))
  }
  let edge-line(a, b, label: none, label-dx: 0pt, label-dy: 0pt, both: false) = {
    let pa = pos(a)
    let pb = pos(b)
    let dx = pb.x - pa.x
    let dy = pb.y - pa.y
    let ndx = dx / 1pt
    let ndy = dy / 1pt
    let len = calc.sqrt(ndx * ndx + ndy * ndy)
    let ux = ndx / len
    let uy = ndy / len
    let sx = pa.x + ux * (node-r + 1pt)
    let sy = pa.y + uy * (node-r + 1pt)
    let ex = pb.x - ux * (node-r + 1pt)
    let ey = pb.y - uy * (node-r + 1pt)

    place(top + left, line(start: (sx, sy), end: (ex, ey), stroke: edge + 0.85pt))
    _arrow-head(ex, ey, dir: arrow-dir(dx, dy), color: edge)
    if both {
      _arrow-head(sx, sy, dir: arrow-dir(-dx, -dy), color: edge)
    }
    if label != none {
      label-at((sx + ex) / 2 + label-dx, (sy + ey) / 2 + label-dy, label)
    }
  }
  let edge-curve(a, b, label: none, label-dx: 0pt, label-dy: 0pt) = {
    let pa = pos(a)
    let pb = pos(b)
    let c1x = W + 18pt
    let c1y = H - 42pt
    let c2x = W + 8pt
    let c2y = 22pt
    let sdx = (c1x - pa.x) / 1pt
    let sdy = (c1y - pa.y) / 1pt
    let slen = calc.sqrt(sdx * sdx + sdy * sdy)
    let sx = pa.x + sdx / slen * (node-r + 1pt)
    let sy = pa.y + sdy / slen * (node-r + 1pt)
    let edx = (c2x - pb.x) / 1pt
    let edy = (c2y - pb.y) / 1pt
    let elen = calc.sqrt(edx * edx + edy * edy)
    let ex = pb.x + edx / elen * (node-r + 1pt)
    let ey = pb.y + edy / elen * (node-r + 1pt)

    place(top + left, curve(
      stroke: edge + 0.85pt,
      fill: none,
      curve.move((sx, sy)),
      curve.cubic((c1x, c1y), (c2x, c2y), (ex, ey)),
    ))
    _arrow-head(ex, ey, dir: "l", color: edge)
    if label != none {
      let mx = 0.125 * sx + 0.375 * c1x + 0.375 * c2x + 0.125 * ex
      let my = 0.125 * sy + 0.375 * c1y + 0.375 * c2y + 0.125 * ey
      label-at(mx + label-dx, my + label-dy, label)
    }
  }
  box(width: W, height: H, {
    edge-line("D", "B", label: [10])
    edge-line("B", "P", label: [10])
    edge-line("P", "M", label: [4])
    edge-line("B", "M", label: [5], both: true)
    edge-line("C", "B", label: [3])
    edge-line("M", "C", label: [9])
    edge-line("D", "C", label: [4], both: true)
    edge-line("L", "M", label: [10])
    edge-curve("L", "D", label: [10])

    node-by-name("P", [$P$])
    node-by-name("B", [$B$])
    node-by-name("D", [$D$])
    node-by-name("C", [$C$])
    node-by-name("M", [$M$])
    node-by-name("L", [$L$])
  })
})

// ---- Chart slide 1: Transformer + Dynamic system -----------
#slide(title: "Block Diagrams")[
  #two-col(
    left-width: 49%,
    [
      Transformer encoder-decoder stack with attention, feed-forward blocks, residual paths, and layer normalisation.

      #baf-diagram(caption: [Transformer encoder-decoder block diagram (Vaswani et al., 2017).])[
        #transformer-diagram
      ]
    ],
    [
      A closed-loop controller compares the reference signal with the measured output, drives the plant, and routes the response through a feedback transducer.

      #baf-diagram(
        caption: [Closed-loop control system with controller, plant, disturbance input, and feedback transducer.],
      )[
        #closed-loop-diagram
      ]
      The disturbance $D(z)$ enters before the plant, while $H(z)$ shapes the measured feedback signal $W(z)$ returned to the summing junction.
    ],
  )
]

// ---- Chart slide 2: Linear algebra + Graph -----------------
#slide(title: "Linear Algebra Diagram and Transition Graph")[
  #two-col(
    left-width: 49%,
    [
      For a homomorphism $phi: G -> G'$, the *kernel* determines the quotient $G slash ker phi$, while the *image* is the subgroup of reachable outputs in $G'$.

      #baf-diagram(caption: [Kernel-image decomposition for a homomorphism $phi: G -> G'$.])[
        #kernel-image-diagram
      ]
      The induced map $overline(phi)$ sends cosets modulo $ker phi$ onto $im phi$, and the inclusion embeds that image back into $G'$.
    ],
    [
      A weighted directed graph encodes reachable states as nodes and transition costs as labels on the arcs. This version keeps the notation compact to match the reference diagram.

      #baf-diagram(caption: [Weighted directed transition graph; edge labels denote transition costs.])[
        #weighted-transition-graph
      ]
      Parallel and long-range transitions are shown with separate arrows, making bidirectional moves and high-cost paths visible at a glance.
    ],
  )
]

// ---- Chart slide 3: Line chart + Histogram -----------------
#let accuracy-chart = align(center, {
  let W = 248pt
  let H = 126pt
  let pl = 32pt
  let pr = 13pt
  let pt = 21pt
  let pb = 24pt
  let iw = W - pl - pr
  let ih = H - pt - pb
  let xs = (0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0)
  let ya = (0.52, 0.57, 0.63, 0.70, 0.76, 0.81, 0.85, 0.88, 0.90, 0.91, 0.92)
  let yb = (0.48, 0.51, 0.55, 0.60, 0.65, 0.69, 0.73, 0.76, 0.79, 0.81, 0.83)
  let yc = (0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50)
  let xmin = 0.0
  let xmax = 5.0
  let ymin = 0.44
  let ymax = 0.96
  let px(xi) = pl + (xi - xmin) / (xmax - xmin) * iw
  let py(yi) = pt + (ymax - yi) / (ymax - ymin) * ih
  let tick-label(x, y, width, body, size: 5.4pt, fill: luma(70)) = {
    place(top + left, dx: x - width / 2, dy: y - 4.5pt, box(
      width: width,
      height: 9pt,
      inset: 0pt,
      align(center + horizon, text(size: size, fill: fill, body)),
    ))
  }
  let line-legend-item(x, y, col, body, text-width: 18pt) = {
    place(top + left, line(start: (x, y), end: (x + 9pt, y), stroke: col + 1.1pt))
    place(top + left, dx: x + 12pt, dy: y - 6.5pt, box(
      width: text-width,
      height: 13pt,
      inset: 0pt,
      align(left + horizon, text(size: 5.3pt, fill: luma(45), body)),
    ))
  }
  let mkpath(ys, col) = {
    let pts = xs.zip(ys).map(p => (px(p.first()), py(p.last())))
    curve(
      stroke: col + 1.35pt,
      fill: none,
      curve.move(pts.first()),
      ..pts.slice(1).map(curve.line),
    )
  }
  let markers(ys, col) = {
    for (xv, yv) in xs.zip(ys) {
      place(top + left, dx: px(xv) - 1.6pt, dy: py(yv) - 1.6pt, circle(radius: 1.6pt, fill: white, stroke: col + 0.7pt))
    }
  }
  box(width: W, height: H, stroke: luma(180) + 0.45pt, fill: luma(252), {
    place(top + left, dx: 8pt, dy: 5pt, text(size: 6.8pt, weight: "bold", fill: luma(25))[Validation accuracy by epoch])
    place(top + left, dx: W - 91pt, dy: 5pt, box(width: 83pt, height: 13pt, fill: white, stroke: luma(220) + 0.35pt, {
      line-legend-item(5pt, 6.5pt, blue.darken(50%), [A], text-width: 8pt)
      line-legend-item(28pt, 6.5pt, red.darken(20%), [B], text-width: 8pt)
      line-legend-item(52pt, 6.5pt, luma(150), [base], text-width: 17pt)
    }))
    place(top + left, dx: pl + 3pt, dy: pt + 3pt, text(size: 5.2pt, fill: luma(75))[Accuracy])
    for yi in (0.5, 0.6, 0.7, 0.8, 0.9) {
      place(top + left, line(start: (pl, py(yi)), end: (W - pr, py(yi)), stroke: luma(222) + 0.45pt))
      tick-label(pl / 2, py(yi), pl - 8pt, str(yi))
    }
    place(top + left, line(start: (pl, pt), end: (pl, H - pb), stroke: luma(95) + 0.65pt))
    place(top + left, line(start: (pl, H - pb), end: (W - pr, H - pb), stroke: luma(95) + 0.65pt))
    for xi in (0, 1, 2, 3, 4, 5) {
      place(top + left, line(
        start: (px(float(xi)), H - pb),
        end: (px(float(xi)), H - pb + 2pt),
        stroke: luma(95) + 0.45pt,
      ))
      tick-label(px(float(xi)), H - pb + 8pt, 12pt, str(xi))
    }
    place(top + left, dx: W / 2 - 12pt, dy: H - 9pt, text(size: 5.5pt, fill: luma(65))[Epoch])
    place(top + left, mkpath(ya, blue.darken(50%)))
    place(top + left, mkpath(yb, red.darken(20%)))
    place(top + left, mkpath(yc, luma(160)))
    markers(ya, blue.darken(50%))
    markers(yb, red.darken(20%))
  })
})

#let grouped-bar-chart = align(center, {
  let W = 248pt
  let H = 126pt
  let pl = 32pt
  let pr = 12pt
  let pt = 21pt
  let pb = 26pt
  let iw = W - pl - pr
  let ih = H - pt - pb
  let baseline = H - pb
  let years = (2020, 2021, 2022, 2023, 2024)
  let va = (62, 67, 71, 74, 78)
  let vb = (55, 58, 61, 65, 69)
  let maxv = 85.0
  let bw = 10.5pt
  let gap = 4pt
  let group-w = 2 * bw + gap
  let group-step = iw / years.len()
  let ca = blue.darken(50%)
  let cb = red.darken(20%)
  let py(score) = baseline - (float(score) / maxv) * ih
  let group-center(i) = pl + (float(i) + 0.5) * group-step
  let group-left(i) = group-center(i) - group-w / 2
  let bar-center(i, which) = group-left(i) + if which == "a" { bw / 2 } else { bw + gap + bw / 2 }
  let tick-label(x, y, width, body, size: 5.2pt, fill: luma(70)) = {
    place(top + left, dx: x - width / 2, dy: y - 4.5pt, box(
      width: width,
      height: 9pt,
      inset: 0pt,
      align(center + horizon, text(size: size, fill: fill, body)),
    ))
  }
  let value-label(x, y, body, fill) = {
    place(top + left, dx: x - 7pt, dy: y - 9pt, box(
      width: 14pt,
      height: 8pt,
      inset: 0pt,
      align(center + horizon, text(size: 4.8pt, fill: fill, body)),
    ))
  }
  let swatch-legend-item(x, y, col, body, text-width: 8pt) = {
    place(top + left, dx: x, dy: y - 2.5pt, rect(width: 6pt, height: 5pt, fill: col))
    place(top + left, dx: x + 9pt, dy: y - 6.5pt, box(
      width: text-width,
      height: 13pt,
      inset: 0pt,
      align(left + horizon, text(size: 5.3pt, fill: luma(45), body)),
    ))
  }
  box(width: W, height: H, stroke: luma(180) + 0.45pt, fill: luma(252), {
    place(top + left, dx: 8pt, dy: 5pt, text(size: 6.8pt, weight: "bold", fill: luma(25))[Mean score by cohort])
    place(top + left, dx: W - 58pt, dy: 5pt, box(width: 50pt, height: 13pt, fill: white, stroke: luma(220) + 0.35pt, {
      swatch-legend-item(5pt, 6.5pt, ca, [A])
      swatch-legend-item(27pt, 6.5pt, cb, [B])
    }))
    place(top + left, dx: pl + 3pt, dy: pt + 3pt, text(size: 5.2pt, fill: luma(75))[Score])
    for score in (20, 40, 60, 80) {
      let yp = py(score)
      place(top + left, line(start: (pl, yp), end: (W - pr, yp), stroke: luma(222) + 0.45pt))
      tick-label(pl / 2, yp, pl - 8pt, str(score))
    }
    place(top + left, line(start: (pl, pt), end: (pl, baseline), stroke: luma(95) + 0.65pt))
    place(top + left, line(start: (pl, baseline), end: (W - pr, baseline), stroke: luma(95) + 0.65pt))
    for (i, yr) in years.enumerate() {
      let a = va.at(i)
      let b = vb.at(i)
      let x0 = group-left(i)
      let ya = py(a)
      let yb = py(b)
      place(top + left, dx: x0, dy: ya, rect(width: bw, height: baseline - ya, fill: ca))
      place(top + left, dx: x0 + bw + gap, dy: yb, rect(width: bw, height: baseline - yb, fill: cb))
      tick-label(group-center(i), baseline + 8pt, group-step - 2pt, str(yr), size: 5.1pt, fill: luma(55))
      value-label(bar-center(i, "a"), ya, str(a), ca)
      value-label(bar-center(i, "b"), yb, str(b), cb)
    }
    place(top + left, dx: W / 2 - 9pt, dy: H - 9pt, text(size: 5.5pt, fill: luma(65))[Year])
  })
})

#slide(title: "Model Accuracy and Cohort Scores (No Captions)")[
  #two-col(
    left-width: 49%,
    [
      The accuracy curves compare Model A, Model B, and a 50% baseline across epochs $x in [0,5]$. Model A stays ahead throughout, while both learned models rise well above the baseline.

      #baf-visual[#accuracy-chart]
      At epoch 5, *Model A* reaches 92% and *Model B* reaches 83%. Their gap grows up to epoch 3 and then narrows from 12 to 9 percentage points by the final epoch.
    ],
    [
      The grouped bars compare mean test scores for Group A and Group B from 2020 to 2024. Both cohorts improve each year, with *Group A* leading every annual pair.

      #baf-visual[#grouped-bar-chart]
      Scores rise from 62 to 78 for *Group A* and from 55 to 69 for *Group B*. The gap widens from 7 points in 2020 to 9 points in 2024.
    ],
  )
]

#slide(title: "Model Accuracy and Cohort Scores (With Captions)")[
  #two-col(
    left-width: 49%,
    [
      The accuracy curves compare Model A, Model B, and a 50% baseline across epochs $x in [0,5]$. Model A stays ahead throughout, while both learned models rise well above the baseline.

      #baf-figure(caption: [Accuracy vs. epoch for Model A, Model B, and random baseline.])[
        #accuracy-chart
      ]
      At epoch 5, *Model A* reaches 92% and *Model B* reaches 83%. Their gap grows up to epoch 3 and then narrows from 12 to 9 percentage points by the final epoch.
    ],
    [
      The grouped bars compare mean test scores for Group A and Group B from 2020 to 2024. Both cohorts improve each year, with *Group A* leading every annual pair.

      #baf-figure(caption: [Mean test score by group and year (2020-2024).])[
        #grouped-bar-chart
      ]
      Scores rise from 62 to 78 for *Group A* and from 55 to 69 for *Group B*. The gap widens from 7 points in 2020 to 9 points in 2024.
    ],
  )
]

// ============================================================
// SECTION 8 -- THEOREM-STYLE BOXES
// ============================================================
#new-section("Theorem-style Boxes")

#slide(title: "Definitions, Theorems, and Lemmas")[
  #two-col(
    left-width: 49%,
    [
      #definition(name: "Metric Space")[
        A *metric space* $(M, d)$ is a set $M$ with $d: M times M -> RR_(>=0)$ satisfying non-negativity, identity ($d(x,y)=0 <=> x=y$), symmetry, and the triangle inequality.
      ]
      #theorem(name: "Banach Fixed-Point Theorem")[
        Let $(M, d)$ be complete and $f: M -> M$ a contraction with constant $k < 1$. Then $f$ has a *unique* fixed point $x^* in M$.
      ]
      #lemma()[
        Any contraction $f$ on $(M,d)$ is uniformly continuous and extends uniquely to the completion $overline(M)$.
      ]
    ],
    [
      #corollary(name: "Picard-Lindelof")[
        Under Lipschitz continuity in $y$, the IVP $dot(y)=f(t,y)$, $y(t_0)=y_0$ has a unique local solution.
      ]
      #proof[
        Apply Banach's theorem to the Picard operator $T phi = y_0 + integral_(t_0)^t f(s,phi(s)) d s$, which is contractive on $C([t_0-delta, t_0+delta])$ for small $delta > 0$.
      ]
      #remark(name: "Completeness is necessary")[
        On $(0,1)$ with $f(x)=x/2$, the fixed point $0$ lies outside the space -- Banach's theorem fails.
      ]
    ],
  )
]

#slide(title: "Examples, Exercises, Propositions, and Custom Boxes")[
  #two-col(
    left-width: 49%,
    [
      #example(name: "Euclidean Space")[
        $RR^n$ with $d(x,y)=norm(x-y)_2$ is complete. The iteration $x_(k+1)=A x_k+b$ converges iff $rho(A)<1$, to the unique solution of $x=A x+b$.
      ]
      #exercise()[
        Show that $ZZ_p$ is complete under the $p$-adic metric and use Banach's theorem to prove Hensel's lemma.
      ]
      #proposition(name: "Closed Subsets are Complete")[
        A closed subset of a complete metric space is itself a complete metric space.
      ]
    ],
    [
      #baf-box("note", name: "Implementation tip", color: green.darken(30%))[
        Monitor $norm(x_(k+1)-x_k)$ as a stopping criterion. A-priori error: $norm(x_k - x^*) <= k^m/(1-k) norm(x_1-x_0)$.
      ]
      #baf-box("warning", name: "Common pitfall", color: red.darken(20%))[
        Contraction ($k<1$) is strictly stronger than nonexpansive ($k=1$). Rotations on $S^1$ are nonexpansive but have no fixed points.
      ]
      #baf-box("custom", name: "Any label works", color: purple.darken(15%))[
        Use `#baf-box("kind", name: "...", color: ...)` for any label and color -- observations, facts, algorithms, warnings.
      ]
    ],
  )
]

#slide(title: "Custom Box Widths")[
  #baf-box("custom", name: "Default width", color: purple.darken(15%))[
    This box uses the default width, so it fills the available slide content area. It is the recommended form when the material belongs to the main flow of the slide.
  ]

  #align(center)[
    #baf-box("custom", name: "Narrow custom width", color: purple.darken(15%), width: 62%)[
      This box has a smaller explicit width. It is useful for short claims, reminders, or side notes that should not dominate the slide.
    ]
  ]

  #baf-box("custom", name: "Short content, default width", color: purple.darken(15%))[
    A short phrase.
  ]
]

#slide(title: "Full-Width Mathematical Proof")[
  #theorem(name: "Cauchy-Schwarz Inequality")[
    For all vectors $u, v in RR^n$,
    #baf-equation[$
      abs(u dot v) <= norm(u) norm(v).
    $]
  ]

  #proof[
    If $v = 0$, the claim is immediate, so assume $v != 0$. For every real $t$, the squared norm of $u - t v$ is non-negative:

    #baf-equation[$
      0 <= norm(u - t v)^2 = norm(u)^2 - 2 t (u dot v) + t^2 norm(v)^2.
    $]

    Choose the minimising value $t = (u dot v) / norm(v)^2$. Substitution gives

    #baf-equation[$
      0 <= norm(u)^2 - (u dot v)^2 / norm(v)^2.
    $]

    Multiplying by the positive number $norm(v)^2$, we obtain

    #baf-equation[$
      (u dot v)^2 <= norm(u)^2 norm(v)^2.
    $]

    Taking square roots on both sides yields $abs(u dot v) <= norm(u) norm(v)$. Equality occurs precisely when the non-negative quadratic has a zero at its minimum, which means $u - t v = 0$ for some scalar $t$; equivalently, the two vectors are linearly dependent.
  ]
]

#slide(title: "Narrow Mathematical Proof")[
  Proof environments fill the available content width by default, matching the rhythm of ordinary slide material. When a shorter line length reads better, pass an explicit `width` and center the proof as below.

  #align(center)[
    #proof(width: 68%)[
      We prove Young's inequality in its weighted quadratic form. Let $a, b >= 0$ and fix $epsilon > 0$. Since every square is non-negative,

      #baf-equation[$
        0 <= (sqrt(epsilon) a - b / sqrt(epsilon))^2.
      $]

      Expanding the square gives

      #baf-equation[$
        0 <= epsilon a^2 - 2 a b + b^2 / epsilon.
      $]

      Rearranging terms and dividing by $2$ yields

      #baf-equation[$
        a b <= epsilon a^2 / 2 + b^2 / (2 epsilon).
      $]

      This form is especially useful when a product term must be absorbed into a coercive estimate: one chooses $epsilon$ small enough for the first term and pays for it in the second term.
    ]
  ]
]

#slide(title: "Theorem Box with Internal Proof")[
  #theorem(name: "Cauchy-Schwarz Inequality")[
    For all vectors $u, v in RR^n$,
    #baf-equation[$
      abs(u dot v) <= norm(u) norm(v).
    $]

    #proof[
      If $v = 0$, the claim is immediate. Otherwise, the quadratic expression $norm(u - t v)^2$ is non-negative for every $t in RR$. Expanding and choosing $t = (u dot v) / norm(v)^2$ gives
      #baf-equation[$
        0 <= norm(u)^2 - (u dot v)^2 / norm(v)^2.
      $]
      Multiplying by $norm(v)^2$ and taking square roots yields the desired inequality.
    ]
  ]
]

#slide(title: "Exercise Box with Solution")[
  #exercise(name: "Spectral radius criterion")[
    Let $A in RR^(n times n)$ and suppose $norm(A) < 1$ for a matrix norm compatible with the vector norm. Prove that $I - A$ is invertible and derive a convergent series for its inverse.

    #box-separator("Solution", color: orange.darken(20%))

    Since $norm(A^k) <= norm(A)^k$, the Neumann series $sum_(k=0)^infinity A^k$ converges absolutely. Multiplying partial sums by $I-A$ gives $I - A^(m+1)$, which tends to $I$. Thus,
    #baf-equation[$
      (I - A)^(-1) = sum_(k=0)^infinity A^k.
    $]
  ]
]

#slide(title: "Exercise Box with Two Solutions")[
  #exercise(name: "Arithmetic-geometric mean")[
    Prove that for $x, y >= 0$ one has $sqrt(x y) <= (x + y) / 2$.

    #box-separator("Solution 1", color: orange.darken(20%))

    The square $(sqrt(x) - sqrt(y))^2$ is non-negative, so $x + y - 2 sqrt(x y) >= 0$.

    #box-separator("Solution 2", color: orange.darken(20%))

    The function $log$ is concave on $(0, infinity)$. Applying Jensen's inequality to $x$ and $y$ gives
    #baf-equation[$
      log((x + y) / 2) >= (log x + log y) / 2 = log(sqrt(x y)).
    $]
  ]
]

#slide(title: "Theorem, Text, and Lemma")[
  The next result is stated in the same theorem-style box used throughout the template. The surrounding prose is deliberately included to show how normal paragraphs sit before, between, and after formal statements.

  #theorem(name: "Compactness criterion")[
    Every sequence in a compact metric space has a convergent subsequence whose limit belongs to the same space.
  ]

  This theorem is often the bridge between qualitative assumptions and quantitative estimates. The intermediate text lets the slide show how ordinary prose separates theorem-style boxes without requiring a two-column layout.

  #lemma(name: "Closed image of a convergent sequence")[
    If $x_n -> x$ and $F$ is closed, then every sequence contained in $F$ can only converge to a point of $F$.
  ]

  Together, the theorem and lemma give a compact workflow: first extract convergence, then use closedness to keep the limiting object inside the admissible set. This final paragraph checks the lower spacing after the last formal box.
]

// ============================================================
// Thank you
// ============================================================
#final-slide
