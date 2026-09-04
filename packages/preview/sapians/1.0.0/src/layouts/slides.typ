#import "../tokens.typ": *
#import "../components/index.typ": *
#import "../dynamic.typ": *
#import "../pdfpc.typ": *

// Page geometry per aspect ratio. Every family is laid out against the 16:9
// content box; taller pages keep that box and letterbox it (see `_page-setup`).
#let _aspect-ratios = (
  "16-9": (width: 160mm, height: 90mm),
  "16-10": (width: 160mm, height: 100mm),
)

// The page height the families are designed for. On a taller page the content
// band stays 90mm and is centred, so no family has to know the aspect ratio.
#let _content-band = 90mm

// Resolved page geometry, published for components that need the real numbers:
// `(width:, height:, band:, margin:, aspect-ratio:)`.
#let slide-dims = state(
  "sapians-slide-dims",
  (
    width: 160mm,
    height: 90mm,
    band: _content-band,
    margin: (x: 10mm, y: 6mm),
    aspect-ratio: "16-9",
  ),
)

// Resolve an aspect ratio name into the page geometry.
#let _page-setup(aspect-ratio) = {
  if aspect-ratio not in _aspect-ratios {
    panic(
      "unknown aspect-ratio "
        + repr(aspect-ratio)
        + " — sapians-slides supports "
        + _aspect-ratios.keys().map(repr).join(", ")
        + " (\"16-9\" is 160×90mm, \"16-10\" is 160×100mm)",
    )
  }
  let (width, height) = _aspect-ratios.at(aspect-ratio)
  // Letterbox: the extra height becomes margin, so the 140×78mm content box of
  // the 16:9 layout is reproduced exactly and centred vertically.
  let margin = (x: 10mm, y: 6mm + (height - _content-band) / 2)
  (
    width: width,
    height: height,
    band: _content-band,
    margin: margin,
    aspect-ratio: aspect-ratio,
  )
}

/// The SAPIANS slide engine: sets the deck-wide page geometry, base
/// typography, and the dynamics/pdfpc state, then renders `body`. Apply it
/// once per document with a show rule, before any `slide`/`slide-*` call —
/// it sets page-level rules, so it cannot be called from inside another
/// container (a card, a box, ...) or from a live doc example; see the
/// usage snippet below.
///
/// ```typ
/// #import "@preview/sapians-slides:0.2.0": *
///
/// #show: sapians-slides.with(
///   title: "Deck Title",
///   author: "Author Name",
///   aspect-ratio: "16-9",
/// )
///
/// #slide-cover(title: "SAPIANS", subtitle: "A one-line thesis.")
/// ```
/// -> content
#let sapians-slides(
  /// Document title, forwarded to `set document(title: ...)`. -> str
  title: "SAPIANS Presentation",

  /// Document author, forwarded to `set document(author: ...)`. Defaults
  /// to `"SAPIANS"` when `none`. -> none | str
  author: none,

  /// Document language, forwarded to `set text(lang: ...)`. -> str
  lang: "en",

  /// Page aspect ratio: `"16-9"` (160×90mm) or `"16-10"` (160×100mm). In
  /// 16:10 the slide content keeps its 16:9 box, centred vertically in a
  /// 90mm band, so no family has to know the page size. -> str
  aspect-ratio: "16-9",

  /// Whether to render the deck in handout mode: every slide collapses to
  /// a single page with all of its steps revealed. Can also be turned on
  /// from the command line with `--input handout=true`; the two are
  /// ORed together, so the command line can force handout mode on but
  /// never off. -> bool
  handout: false,

  /// Deck content: the sequence of `slide`/`slide-*` calls. Supplied
  /// automatically by `#show: sapians-slides.with(...)`. -> content
  body,
) = {
  set document(title: title, author: if author != none { author } else {
    "SAPIANS"
  })

  let dims = _page-setup(aspect-ratio)

  set page(
    width: dims.width,
    height: dims.height,
    margin: dims.margin,
    fill: sapians-paper,
  )

  // Typography defaults
  set text(
    font: font-sans,
    fill: sapians-text-dark,
    size: font-size-body,
    lang: lang,
  )

  set par(leading: 0.48em)

  // Invisible preamble: state for the dynamics, geometry for components and
  // the pdfpc collector. None of it produces a frame, so no blank first page.
  _handout.update(resolve-handout(handout))
  slide-dims.update(dims)
  context pdfpc-file(here())

  body
}

// Emit one physical page. This is the primitive every family builds on; the
// public `slide()` wraps it in the step driver.
//
// - min-steps: raise the step count of the enclosing slide (used by families
//   whose slot arrays contain `pause`). The update is emitted in the flow just
//   before the page — it renders nothing, so it neither creates a page nor
//   disturbs the layout, and unlike a `place`d update its position in document
//   order is unambiguous (out-of-flow updates make the step count oscillate).
#let _slide-page(dark: false, note: none, min-steps: 1, body) = {
  let bg = if dark { sapians-dark } else { sapians-paper }
  let text-fill = if dark { sapians-text-light } else { sapians-text-dark }

  if min-steps > 1 { update-steps(min-steps) }

  page(fill: bg)[
    #place(top + left, pdfpc-page-markers(note: note))
    #set text(fill: text-fill)
    #body
  ]
}

/// The raw slide canvas with the theme applied but none of the 10 family
/// layouts. Use it for the rare slide the family taxonomy doesn't cover —
/// see `docs/slides.md` for the taxonomy — and consider proposing a new
/// family (see the design-change issue form) if you reach for it twice.
/// Like the families, it sets page-level rules internally, so it cannot be
/// called from inside another container (a card, a box, ...) or from a
/// live doc example; see the usage snippet below.
///
/// ```typ
/// #slide(dark: true, note: "Close on the one sentence to remember.")[
///   #slide-header(title: "TOPIC", counter: "20 / 20", dark: true)
///   #place(top + left, dx: 2mm, dy: 20mm)[
///     #text(size: 16pt, weight: "bold", fill: sapians-text-light)[
///       A closing line the taxonomy has no slot for.
///     ]
///   ]
/// ]
/// ```
/// -> content
#let slide(
  /// Whether the slide sits on the dark canvas; swaps the background and
  /// text colors for the dark palette. -> bool
  dark: false,

  /// Speaker note exported to the pdfpc sidecar as this slide's note.
  /// Omitted entirely when `none`. -> none | str
  note: none,

  /// Number of subslides (steps) to render. With `auto`, the `uncover()`
  /// and `only()` calls (or a manual call to `update-steps()`) inside
  /// `body` decide the count; pass an integer to pin it explicitly.
  /// -> auto | int
  subslides: auto,

  /// Slide content, placed directly on the page. -> content
  body,
) = stepped-slide(
  steps: subslides,
  _ => _slide-page(dark: dark, note: note, body),
)

// -------------------------------------------------------------
// 10 SAPIANS SLIDE FAMILIES (REFINED PROPORTIONS)
// -------------------------------------------------------------

/// Family 01: cover slide — full-bleed title, subtitle, byline. Use it for
/// the opening slide and for section breaks; per the deck-composition
/// rule, open dark and close dark (see `slide-takeaway`), with every
/// other family on the light canvas in between. It sets page-level rules
/// internally, so it cannot be called from inside another container or
/// from a live doc example; see the usage snippet below.
///
/// ```typ
/// #slide-cover(
///   title: "SAPIANS",
///   subtitle: "A Clear, One-Line Statement\nof What This Deck Argues",
///   author: "Author Name",
///   affiliation: "Your Team or Institution",
///   dark: true,
///   note: "Welcome the audience and state the one thing to remember.",
/// )
/// ```
/// -> content
#let slide-cover(
  /// Deck or slide title, shown large at the top-left. -> str
  title: "",

  /// Supporting line shown under the title. Omitted entirely when empty;
  /// `"\n"` starts a new line. -> str
  subtitle: "",

  /// Author name shown at the bottom-left. Omitted entirely when empty.
  /// -> str
  author: "",

  /// Affiliation shown under the author, in the muted tone. Omitted
  /// entirely when empty. -> str
  affiliation: "",

  /// Whether the slide sits on the dark canvas; swaps title, subtitle,
  /// author, and affiliation colors for the dark palette. -> bool
  dark: true,

  /// Speaker note exported to the pdfpc sidecar for this slide. Omitted
  /// entirely when `none`. -> none | str
  note: none,

  /// Number of subslides (steps) to render; with `auto` this family
  /// always resolves to a single step, since it has no reveal slot.
  /// -> auto | int
  subslides: auto,
) = stepped-slide(steps: subslides, _ => _slide-page(dark: dark, note: note)[
  #place(top + left, dx: 8mm, dy: 20mm)[
    #text(size: font-size-display, weight: "bold", fill: if dark {
      sapians-text-light
    } else { sapians-text-dark })[#title]
  ]
  #if subtitle != "" [
    #place(top + left, dx: 8mm, dy: 34mm)[
      #text(size: 11.5pt, weight: "regular", fill: if dark {
        sapians-text-light
      } else { sapians-text-dark })[#subtitle]
    ]
  ]
  #place(bottom + left, dx: 8mm, dy: -8mm)[
    #if author != "" [
      #text(size: 8.5pt, weight: "medium", fill: if dark {
        sapians-muted-light
      } else { sapians-muted-dark })[#author] \
    ]
    #if affiliation != "" [
      #v(0.8mm)
      #text(size: 7.2pt, weight: "regular", fill: if dark {
        sapians-muted-light
      } else { sapians-muted-dark })[#affiliation]
    ]
  ]
])

/// Family 02: problem / hero statement slide — a headline claim, one
/// supporting sentence, and a dark question card, with room for a
/// supporting `visual` on the right. Use it to frame the problem and the
/// question the deck answers, typically right after `slide-cover`. It
/// sets page-level rules internally, so it cannot be called from inside
/// another container or from a live doc example; see the usage snippet
/// below.
///
/// ```typ
/// #slide-problem(
///   title: "TOPIC",
///   section: "DIAGNOSIS",
///   counter: "02 / 06",
///   hero: "State the problem\nin one strong sentence.",
///   subtext: "One supporting sentence explaining why it matters.",
///   question-label: "THE QUESTION",
///   question: "What is the single question\nthis deck answers?",
///   visual: block(
///     fill: sapians-white,
///     stroke: stroke-light,
///     radius: radius-sm,
///     inset: 4mm,
///     [A short, memorable statement that frames the argument.],
///   ),
/// )
/// ```
/// -> content
#let slide-problem(
  /// Slide title, shown bold at the top-left by `slide-header`. -> str
  title: "",

  /// Uppercase section tag shown next to the title. -> str
  section: "THE PROBLEM",

  /// Page counter text shown at the top-right, e.g. `"02 / 10"`. Omitted
  /// entirely when empty. -> str
  counter: "",

  /// Headline claim, shown large under the header. `"\n"` starts a new
  /// line. -> str
  hero: "",

  /// Supporting sentence shown under `hero`, in the muted tone. -> str
  subtext: "",

  /// The question shown inside the dark card. -> str
  question: "",

  /// Uppercase kicker shown above `question` inside the dark card.
  /// -> str
  question-label: "THE QUESTION",

  /// Supporting visual placed to the right of the hero/question column
  /// (chart, card, diagram, ...). Omitted entirely when `none`.
  /// -> none | content
  visual: none,

  /// Speaker note exported to the pdfpc sidecar for this slide. Omitted
  /// entirely when `none`. -> none | str
  note: none,

  /// Number of subslides (steps) to render; with `auto` this family
  /// always resolves to a single step, since it has no reveal slot.
  /// -> auto | int
  subslides: auto,
) = stepped-slide(steps: subslides, _ => _slide-page(dark: false, note: note)[
  #slide-header(title: title, section: section, counter: counter)
  #place(top + left, dx: 2mm, dy: 14mm)[
    #block(width: 66mm)[
      #text(size: font-size-h1, weight: "bold", fill: sapians-text-dark)[#hero]
      #v(2.5mm)
      #text(size: font-size-body, fill: sapians-muted-dark)[#subtext]
      #v(3.5mm)
      #dark-card(
        kicker-title: question-label,
        width: 100%,
        [
          #text(
            size: 7.8pt,
            weight: "bold",
            fill: sapians-text-light,
          )[#question]
        ],
      )
    ]
  ]
  #if visual != none [
    #place(top + left, dx: 74mm, dy: 15mm)[
      #block(width: 66mm)[#visual]
    ]
  ]
])

/// Family 03: definition split slide — a headline concept on the left and
/// a stack of `(kicker, value)` rows on the right. Use it for a concept
/// plus its named parts (a term and its components, an acronym and its
/// letters, ...). It sets page-level rules internally, so it cannot be
/// called from inside another container or from a live doc example; see
/// the usage snippet below.
///
/// ```typ
/// #slide-definition(
///   title: "TOPIC",
///   section: "ARCHITECTURE",
///   counter: "03 / 06",
///   hero: "Name the core idea\nin one line.",
///   explanation: "One sentence expanding the idea.",
///   definitions: (
///     ("PART ONE", "What it does"),
///     ("PART TWO", "What it does"),
///     pause,
///     ("PART THREE", "What it does"),
///     ("PART FOUR", "What it does"),
///   ),
///   note: "Walk through the first two, pause, then reveal the rest.",
/// )
/// ```
/// -> content
#let slide-definition(
  /// Slide title, shown bold at the top-left by `slide-header`. -> str
  title: "",

  /// Uppercase section tag shown next to the title. -> str
  section: "DEFINITION",

  /// Page counter text shown at the top-right, e.g. `"03 / 10"`. Omitted
  /// entirely when empty. -> str
  counter: "",

  /// Headline concept name, shown large on the left column. `"\n"`
  /// starts a new line. -> str
  hero: "",

  /// Supporting sentence shown under `hero`, in the muted tone. -> str
  explanation: "",

  /// Definition rows shown on the right, each a `(kicker, value)` pair —
  /// an uppercase tag and its bold value, e.g. `("PART ONE", "What it
  /// does")`. May contain the `pause` sentinel: every `pause` starts a
  /// new step, and the rows after it keep their box but stay hidden
  /// until then. -> array
  definitions: (),

  /// Speaker note exported to the pdfpc sidecar for this slide. Omitted
  /// entirely when `none`. -> none | str
  note: none,

  /// Number of subslides (steps) to render. With `auto`, the number of
  /// `pause` sentinels in `definitions` decides the count; pass an
  /// integer to pin it explicitly. -> auto | int
  subslides: auto,
) = {
  let split = pause-levels(definitions)
  stepped-slide(steps: subslides, _ => _slide-page(
    dark: false,
    note: note,
    min-steps: split.steps,
  )[
    #slide-header(title: title, section: section, counter: counter)
    #place(top + left, dx: 2mm, dy: 14mm)[
      #block(width: 64mm)[
        #text(
          size: font-size-h1,
          weight: "bold",
          fill: sapians-text-dark,
        )[#hero]
        #v(3mm)
        #text(size: font-size-body, fill: sapians-muted-dark)[#explanation]
      ]
    ]
    #place(top + left, dx: 72mm, dy: 14mm)[
      #block(width: 68mm)[
        #stack(
          spacing: 2.0mm,
          ..split
            .items
            .enumerate()
            .map(((i, d)) => reveal-at(
              split.levels.at(i),
              def-row(d.at(0), d.at(1), width: 100%),
            )),
        )
      ]
    ]
  ])
}

/// Family 04: equation journal slide — one boxed formula followed by a
/// numbered list of annotations. Use it for the single formula that
/// deserves the whole room, walked through term by term. It sets
/// page-level rules internally, so it cannot be called from inside
/// another container or from a live doc example; see the usage snippet
/// below.
///
/// ```typ
/// #slide-equation(
///   title: "TOPIC",
///   section: "THE OBJECTIVE",
///   counter: "04 / 10",
///   hero: "A fixed equation slide.",
///   equation: $ xi(x) = limits("arg min")_(g in G) cal(L)(f, g, pi_x) + Omega(g) $,
///   steps: (
///     "First step annotation.",
///     pause,
///     "Second step annotation.",
///   ),
/// )
/// ```
/// -> content
#let slide-equation(
  /// Slide title, shown bold at the top-left by `slide-header`. -> str
  title: "",

  /// Uppercase section tag shown next to the title. -> str
  section: "THE OBJECTIVE",

  /// Page counter text shown at the top-right, e.g. `"04 / 10"`. Omitted
  /// entirely when empty. -> str
  counter: "",

  /// Headline shown above the equation box. `"\n"` starts a new line.
  /// -> str
  hero: "",

  /// The formula, shown centered inside a bordered, shaded box, e.g.
  /// `$ y = f(x) $`. Omitted entirely when `none`. -> none | content
  equation: none,

  /// Annotation lines shown below the equation as a numbered list. May
  /// contain the `pause` sentinel: every `pause` starts a new step, and
  /// the annotations after it keep their box but stay hidden until then.
  /// -> array
  steps: (),

  /// Speaker note exported to the pdfpc sidecar for this slide. Omitted
  /// entirely when `none`. -> none | str
  note: none,

  /// Number of subslides (steps) to render. With `auto`, the number of
  /// `pause` sentinels in `steps` decides the count; pass an integer to
  /// pin it explicitly. -> auto | int
  subslides: auto,
) = {
  let split = pause-levels(steps)
  stepped-slide(steps: subslides, _ => _slide-page(
    dark: false,
    note: note,
    min-steps: split.steps,
  )[
    #slide-header(title: title, section: section, counter: counter)
    #place(top + left, dx: 2mm, dy: 14mm)[
      #text(size: font-size-h1, weight: "bold", fill: sapians-text-dark)[#hero]
    ]
    #if equation != none [
      #place(top + left, dx: 2mm, dy: 24mm)[
        #block(
          width: 138mm,
          fill: sapians-code-bg,
          radius: radius-sm,
          stroke: stroke-light,
          inset: (x: 5mm, y: 3.5mm),
        )[
          #align(center)[
            #text(size: 11.5pt, fill: sapians-text-dark)[#equation]
          ]
        ]
      ]
    ]
    #place(top + left, dx: 4mm, dy: 44mm)[
      #block(width: 134mm)[
        #stack(
          spacing: 2.8mm,
          ..split
            .items
            .enumerate()
            .map(((i, s)) => reveal-at(
              split.levels.at(i),
              step-item(i + 1, s),
            )),
        )
      ]
    ]
  ])
}

/// Family 05: three-column mechanism slide (Model | Code | Idea). Use it
/// to walk a mechanism through its three faces at once: a conceptual
/// column, a code listing, and a dark takeaway card. It sets page-level
/// rules internally, so it cannot be called from inside another container
/// or from a live doc example; see the usage snippet below.
///
/// ```typ
/// #slide-three-column(
///   title: "TOPIC",
///   section: "MECHANISM",
///   counter: "04 / 06",
///   column1-title: "THE CONCEPT",
///   column1-content: block(
///     fill: sapians-white,
///     stroke: stroke-light,
///     radius: radius-sm,
///     inset: 3.5mm,
///     height: 100%,
///     [Concept headline],
///   ),
///   column1-caption: "One-line caption.",
///   column2-title: "THE CODE",
///   column2-code: [
///     #raw("#slide-cover(title: \"SAPIANS\")", lang: "typst", block: true)
///   ],
///   column3-title: "THE TAKEAWAY",
///   column3-hero: "The point, in 3 words.",
///   column3-sub: "One sentence connecting concept and code.",
///   column3-footer: "Footer annotation.",
/// )
/// ```
/// -> content
#let slide-three-column(
  /// Slide title, shown bold at the top-left by `slide-header`. -> str
  title: "",

  /// Uppercase section tag shown next to the title. -> str
  section: "HOW IT WORKS",

  /// Page counter text shown at the top-right, e.g. `"05 / 10"`. Omitted
  /// entirely when empty. -> str
  counter: "",

  /// Uppercase label above the first column. -> str
  column1-title: "THE MODEL",

  /// Content of the first column (diagram, card, ...), given a 38mm
  /// height. Omitted entirely when `none`. -> none | content
  column1-content: none,

  /// Small caption shown under the first column's content, in the muted
  /// tone. Omitted entirely when `none`. -> none | content
  column1-caption: none,

  /// Uppercase label above the second column. -> str
  column2-title: "THE CODE",

  /// Code (or any content) shown inside the second column's `code-box`.
  /// Omitted entirely when `none`. -> none | content
  column2-code: none,

  /// Uppercase label above the third column, also used as the dark
  /// card's kicker. -> str
  column3-title: "THE IDEA",

  /// Headline shown inside the third column's dark card. -> str
  column3-hero: "",

  /// Supporting sentence shown under `column3-hero`, in the muted tone.
  /// -> str
  column3-sub: "",

  /// Bold footer line shown at the bottom of the third column's card.
  /// -> str
  column3-footer: "",

  /// Speaker note exported to the pdfpc sidecar for this slide. Omitted
  /// entirely when `none`. -> none | str
  note: none,

  /// Number of subslides (steps) to render; with `auto` this family
  /// always resolves to a single step, since it has no reveal slot.
  /// -> auto | int
  subslides: auto,
) = stepped-slide(steps: subslides, _ => _slide-page(dark: false, note: note)[
  #slide-header(title: title, section: section, counter: counter)
  #place(top + left, dx: 0mm, dy: 11mm)[
    #grid(
      columns: (44mm, 44mm, 48mm),
      gutter: 3.5mm,
      [
        #caps-label(column1-title)
        #v(1.8mm)
        #block(width: 100%, height: 38mm)[#column1-content]
        #if column1-caption != none [
          #v(0.8mm)
          #small-text(column1-caption)
        ]
      ],
      [
        #caps-label(column2-title)
        #v(1.8mm)
        #code-box(width: 100%, height: 50mm)[#column2-code]
      ],
      [
        #caps-label(column3-title)
        #v(1.8mm)
        #dark-card(
          width: 100%,
          height: 50mm,
          [
            #kicker(column3-title)
            #v(4mm)
            #text(
              size: 8.5pt,
              weight: "bold",
              fill: sapians-text-light,
            )[#column3-hero]
            #v(2.5mm)
            #text(size: 6.0pt, fill: sapians-muted-light)[#column3-sub]
            #v(6mm)
            #text(
              size: 7.2pt,
              weight: "bold",
              fill: sapians-text-light,
            )[#column3-footer]
          ],
        )
      ],
    )
  ]
])

/// Family 06: evidence graph / full-bleed slide — a short hero and
/// subtext column next to a large `graphic`. Use it when a chart or
/// figure IS the argument; per the composition rule, give `graphic` 60%+
/// of the slide, and reach for `slide-problem` with a `visual` instead if
/// the chart is merely illustrative. It sets page-level rules internally,
/// so it cannot be called from inside another container or from a live
/// doc example; see the usage snippet below.
///
/// ```typ
/// #slide-evidence(
///   title: "TOPIC",
///   section: "MECHANISM",
///   counter: "06 / 10",
///   hero: "A fixed evidence hero.",
///   subtext: "Fixed evidence subtext.",
///   graphic: image("fig-mechanism.svg", width: 70mm),
/// )
/// ```
/// -> content
#let slide-evidence(
  /// Slide title, shown bold at the top-left by `slide-header`. -> str
  title: "",

  /// Uppercase section tag shown next to the title. -> str
  section: "MECHANISM",

  /// Page counter text shown at the top-right, e.g. `"06 / 10"`. Omitted
  /// entirely when empty. -> str
  counter: "",

  /// Headline shown above `subtext`. `"\n"` starts a new line. -> str
  hero: "",

  /// Supporting sentence shown under `hero`, in the muted tone. -> str
  subtext: "",

  /// The chart, figure, or diagram that carries the argument, placed to
  /// the right of the hero/subtext column. Omitted entirely when `none`.
  /// -> none | content
  graphic: none,

  /// Speaker note exported to the pdfpc sidecar for this slide. Omitted
  /// entirely when `none`. -> none | str
  note: none,

  /// Number of subslides (steps) to render; with `auto` this family
  /// always resolves to a single step, since it has no reveal slot.
  /// -> auto | int
  subslides: auto,
) = stepped-slide(steps: subslides, _ => _slide-page(dark: false, note: note)[
  #slide-header(title: title, section: section, counter: counter)
  #place(top + left, dx: 2mm, dy: 14mm)[
    #block(width: 58mm)[
      #text(size: font-size-h1, weight: "bold", fill: sapians-text-dark)[#hero]
      #v(3mm)
      #text(size: font-size-body, fill: sapians-muted-dark)[#subtext]
    ]
  ]
  #if graphic != none [
    #place(top + left, dx: 64mm, dy: 13mm)[
      #block(width: 76mm)[#graphic]
    ]
  ]
])

/// Family 07: limitation compare slide — a numbered list of points next
/// to two labeled visuals and a conclusion line. Use it to compare two
/// regimes side by side (narrow vs wide, before vs after, ...) or to
/// state a limitation with the evidence for it. It sets page-level rules
/// internally, so it cannot be called from inside another container or
/// from a live doc example; see the usage snippet below.
///
/// ```typ
/// #slide-limitation(
///   title: "TOPIC",
///   section: "LIMITS",
///   counter: "07 / 10",
///   hero: "Fixed limits hero.",
///   points: ("First limit.", pause, "Second limit."),
///   visual1: rect(width: 38mm, height: 26mm, fill: sapians-card-bg),
///   label1: "NARROW",
///   sub1: "kernel = 0.20",
///   visual2: rect(width: 38mm, height: 26mm, fill: sapians-card-bg),
///   label2: "WIDE",
///   sub2: "kernel = 0.60",
///   conclusion-title: "Fixed conclusion.",
///   conclusion-sub: "Fixed conclusion subtext.",
/// )
/// ```
/// -> content
#let slide-limitation(
  /// Slide title, shown bold at the top-left by `slide-header`. -> str
  title: "",

  /// Uppercase section tag shown next to the title. -> str
  section: "LIMITATIONS",

  /// Page counter text shown at the top-right, e.g. `"07 / 10"`. Omitted
  /// entirely when empty. -> str
  counter: "",

  /// Headline shown above the point list. `"\n"` starts a new line.
  /// -> str
  hero: "",

  /// Bullet lines shown as a numbered list on the left. May contain the
  /// `pause` sentinel: every `pause` starts a new step, and the points
  /// after it keep their box but stay hidden until then. -> array
  points: (),

  /// First visual, shown above `label1`/`sub1`. Omitted entirely when
  /// `none`. -> none | content
  visual1: none,

  /// Uppercase label under `visual1`. -> str
  label1: "NARROW",

  /// Small caption next to `label1`, in the muted tone. -> str
  sub1: "kernel = 0.20",

  /// Second visual, shown above `label2`/`sub2`. Omitted entirely when
  /// `none`. -> none | content
  visual2: none,

  /// Uppercase label under `visual2`. -> str
  label2: "WIDE",

  /// Small caption next to `label2`, in the muted tone. -> str
  sub2: "kernel = 0.60",

  /// Bold conclusion line shown under the two visuals. -> str
  conclusion-title: "",

  /// Supporting sentence shown under `conclusion-title`, in the muted
  /// tone. -> str
  conclusion-sub: "",

  /// Speaker note exported to the pdfpc sidecar for this slide. Omitted
  /// entirely when `none`. -> none | str
  note: none,

  /// Number of subslides (steps) to render. With `auto`, the number of
  /// `pause` sentinels in `points` decides the count; pass an integer to
  /// pin it explicitly. -> auto | int
  subslides: auto,
) = {
  let split = pause-levels(points)
  stepped-slide(steps: subslides, _ => _slide-page(
    dark: false,
    note: note,
    min-steps: split.steps,
  )[
    #slide-header(title: title, section: section, counter: counter)
    #place(top + left, dx: 2mm, dy: 14mm)[
      #block(width: 50mm)[
        #text(
          size: font-size-h1,
          weight: "bold",
          fill: sapians-text-dark,
        )[#hero]
        #v(3mm)
        #stack(
          spacing: 2.2mm,
          ..split
            .items
            .enumerate()
            .map(((i, p)) => reveal-at(
              split.levels.at(i),
              step-item(i + 1, p),
            )),
        )
      ]
    ]
    #place(top + left, dx: 58mm, dy: 14mm)[
      #block(width: 82mm)[
        #grid(
          columns: (1fr, 1fr),
          gutter: 3.5mm,
          [
            #block(width: 100%)[#visual1]
            #v(0.8mm)
            #kicker(label1) #h(1.5mm) #small-text(sub1)
          ],
          [
            #block(width: 100%)[#visual2]
            #v(0.8mm)
            #kicker(label2) #h(1.5mm) #small-text(sub2)
          ],
        )
        #v(2.5mm)
        #text(
          size: 7.5pt,
          weight: "bold",
          fill: sapians-text-dark,
        )[#conclusion-title]
        #v(0.8mm)
        #text(size: 6.0pt, fill: sapians-muted-dark)[#conclusion-sub]
      ]
    ]
  ])
}

/// Family 08: contrast slide (Not This vs This) — a headline followed by
/// a muted "not this" card next to a high-contrast dark "this" card. Use
/// it to correct a common misreading; per the composition rule, aim for
/// at most one per talk — it's a scalpel, not a format. It sets
/// page-level rules internally, so it cannot be called from inside
/// another container or from a live doc example; see the usage snippet
/// below.
///
/// ```typ
/// #slide-contrast(
///   title: "GUIDELINES",
///   section: "DECISION",
///   counter: "05 / 06",
///   hero: "What do we optimize for?",
///   not-this-content: [A common but wrong interpretation.],
///   this-content: [The correct interpretation, stated as concretely.],
///   not-this-label: "NOT THIS",
///   this-label: "THIS",
///   this-sub: "CLARITY > NOISE",
/// )
/// ```
/// -> content
#let slide-contrast(
  /// Slide title, shown bold at the top-left by `slide-header`. -> str
  title: "",

  /// Uppercase section tag shown next to the title. -> str
  section: "INTERPRETATION",

  /// Page counter text shown at the top-right, e.g. `"08 / 10"`. Omitted
  /// entirely when empty. -> str
  counter: "",

  /// Headline shown above the two cards. `"\n"` starts a new line.
  /// -> str
  hero: "",

  /// Content of the muted "not this" card. -> str | content
  not-this-content: "",

  /// Content of the dark, high-contrast "this" card. -> str | content
  this-content: "",

  /// Uppercase label on the "not this" card. -> str
  not-this-label: "NOT THIS",

  /// Uppercase label on the "this" card. -> str
  this-label: "THIS",

  /// Uppercase sub-label shown below the "this" content. Omitted
  /// entirely when `none`. -> none | str
  this-sub: "LOCAL ≠ GLOBAL",

  /// Speaker note exported to the pdfpc sidecar for this slide. Omitted
  /// entirely when `none`. -> none | str
  note: none,

  /// Number of subslides (steps) to render; with `auto` this family
  /// always resolves to a single step, since it has no reveal slot.
  /// -> auto | int
  subslides: auto,
) = stepped-slide(steps: subslides, _ => _slide-page(dark: false, note: note)[
  #slide-header(title: title, section: section, counter: counter)
  #place(top + left, dx: 2mm, dy: 14mm)[
    #text(size: font-size-h1, weight: "bold", fill: sapians-text-dark)[#hero]
  ]
  #place(top + left, dx: 2mm, dy: 28mm)[
    #block(width: 138mm)[
      #contrast-pair(
        not-this-content,
        this-content,
        not-this-label: not-this-label,
        this-label: this-label,
        this-sub: this-sub,
      )
    ]
  ]
])

/// Family 09: dark takeaway slide — a headline and subtext next to a
/// boxed key-takeaway card, on the dark canvas. Use it for the closing
/// synthesis; per the composition rule, open dark (`slide-cover`), close
/// dark with this family, and keep every other family on the light
/// canvas in between. It sets page-level rules internally, so it cannot
/// be called from inside another container or from a live doc example;
/// see the usage snippet below.
///
/// ```typ
/// #slide-takeaway(
///   title: "TOPIC",
///   section: "NEXT STEPS",
///   counter: "06 / 06",
///   hero: "Close with the single\nsentence they should remember.",
///   subtext: "One line about what happens next.",
///   takeaway-title: "START NOW",
///   takeaway-text: "TYPE: typst watch main.typ",
/// )
/// ```
/// -> content
#let slide-takeaway(
  /// Slide title, shown bold at the top-left by `slide-header`. -> str
  title: "",

  /// Uppercase section tag shown next to the title. -> str
  section: "CONCLUSION",

  /// Page counter text shown at the top-right, e.g. `"09 / 10"`. Omitted
  /// entirely when empty. -> str
  counter: "",

  /// Headline shown above `subtext`. `"\n"` starts a new line. -> str
  hero: "",

  /// Supporting sentence shown under `hero`, in the muted tone. -> str
  subtext: "",

  /// Uppercase kicker shown above `takeaway-text` inside the boxed card.
  /// -> str
  takeaway-title: "KEY TAKEAWAY",

  /// Bold text shown inside the boxed card. -> str
  takeaway-text: "",

  /// Speaker note exported to the pdfpc sidecar for this slide. Omitted
  /// entirely when `none`. -> none | str
  note: none,

  /// Number of subslides (steps) to render; with `auto` this family
  /// always resolves to a single step, since it has no reveal slot.
  /// -> auto | int
  subslides: auto,
) = stepped-slide(steps: subslides, _ => _slide-page(dark: true, note: note)[
  #slide-header(title: title, section: section, counter: counter, dark: true)
  #place(top + left, dx: 2mm, dy: 16mm)[
    #block(width: 68mm)[
      #text(size: 13.5pt, weight: "bold", fill: sapians-text-light)[#hero]
      #v(2.5mm)
      #text(size: 7.0pt, fill: sapians-muted-light)[#subtext]
    ]
  ]
  #place(top + left, dx: 74mm, dy: 16mm)[
    #block(width: 64mm)[
      #block(
        fill: rgb("221F1C"),
        stroke: stroke-dark,
        radius: radius-sm,
        inset: 4.0mm,
        width: 100%,
      )[
        #kicker(takeaway-title, dark: true)
        #v(2.5mm)
        #text(
          size: 9.0pt,
          weight: "bold",
          fill: sapians-text-light,
        )[#takeaway-text]
      ]
    ]
  ]
])

/// Family 10: component index / summary slide — a 2×2 grid of kicker +
/// title (+ optional description) cards. Use it for an agenda, a
/// roadmap, or an architecture overview: any set of 3-4 named parts shown
/// together rather than walked one at a time. It sets page-level rules
/// internally, so it cannot be called from inside another container or
/// from a live doc example; see the usage snippet below.
///
/// ```typ
/// #slide-index(
///   title: "SAPIANS",
///   section: "ROADMAP",
///   counter: "10 / 10",
///   items: (
///     ("01", "First item", "Fixed description."),
///     pause,
///     ("02", "Second item", "Fixed description."),
///     ("03", "Third item"),
///     ("04", "Fourth item"),
///   ),
/// )
/// ```
/// -> content
#let slide-index(
  /// Slide title, shown bold at the top-left by `slide-header`. -> str
  title: "SAPIANS",

  /// Uppercase section tag shown next to the title. -> str
  section: "ROADMAP",

  /// Page counter text shown at the top-right, e.g. `"10 / 10"`. Omitted
  /// entirely when empty. -> str
  counter: "",

  /// Cards shown in a 2×2 grid, each a `(kicker, title)` or `(kicker,
  /// title, description)` tuple, e.g. `("01", "First item", "What it
  /// does")` — the description is optional per item. May contain the
  /// `pause` sentinel: every `pause` starts a new step, and the cards
  /// after it keep their box but stay hidden until then. -> array
  items: (),

  /// Speaker note exported to the pdfpc sidecar for this slide. Omitted
  /// entirely when `none`. -> none | str
  note: none,

  /// Number of subslides (steps) to render. With `auto`, the number of
  /// `pause` sentinels in `items` decides the count; pass an integer to
  /// pin it explicitly. -> auto | int
  subslides: auto,
) = {
  let split = pause-levels(items)
  stepped-slide(steps: subslides, _ => _slide-page(
    dark: false,
    note: note,
    min-steps: split.steps,
  )[
    #slide-header(title: title, section: section, counter: counter)
    #place(top + left, dx: 2mm, dy: 14mm)[
      #grid(
        columns: (1fr, 1fr),
        gutter: 5mm,
        ..split
          .items
          .enumerate()
          .map(((i, item)) => reveal-at(
            split.levels.at(i),
            block(
              fill: sapians-white,
              stroke: stroke-light,
              radius: radius-sm,
              inset: 3.0mm,
              width: 100%,
              [
                #grid(
                  columns: (auto, 1fr),
                  gutter: 2.5mm,
                  kicker(item.at(0)),
                  [
                    #text(
                      size: 7.5pt,
                      weight: "bold",
                      fill: sapians-text-dark,
                    )[#item.at(1)]
                    #if item.len() > 2 [
                      #v(0.8mm)
                      #text(size: 6.0pt, fill: sapians-muted-dark)[#item.at(2)]
                    ]
                  ],
                )
              ],
            ),
          ))
      )
    ]
  ])
}
