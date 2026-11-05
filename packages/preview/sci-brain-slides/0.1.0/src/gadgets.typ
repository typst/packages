// sci-brain-slides . gadgets
// ============================
// Pure-Typst content components (no CeTZ/pinit dependency). Every gadget is
// palette-aware: call `make(palette)` once and get back a dict `G` of functions
// that already know the active theme's colours.
//
//   #import "@preview/sci-brain-slides:0.1.0": gadgets
//   #let (rail_pull,) = gadgets(palette)
//   #rail_pull[The key insight in one sentence.]
//
// Calls in markup need parentheses around dictionary fields: `#(G.stat_row)(...)`.
//
// Two invariants keep gadgets legible under EVERY palette (incl. dark):
//   1. Soft fills are never `c.lighten(...)` (that walks toward white and
//      produces white-on-white under the dark theme). They mix the accent
//      into `pal.paper` instead . `_tint` below.
//   2. Gadgets bold via `text(weight: "bold")`, never `*...*` markup: touying
//      alternative Touying show-rules may recolor strong text.

#import "scale.typ": sizes as default-sizes
#import "@preview/touying:0.7.4": utils
#import "palettes/brand.typ": on-color

// Running pacing counter, shared across all gadget dicts in this document.
#let _clock = state("sci-brain-slides-clock", (slide: none, minutes: 0))

// Soft fill: mix `k` of colour `c` into the palette's paper. Works on light
// and dark grounds alike (a lighten() would not).
#let _tint(pal, c, k) = color.mix((c, k), (pal.paper, 100% - k))

// Theory-box factory shared by theorem / definition / lemma / example / proof_box.
#let _thm(label, border, pal, sizes) = (title: none, body) => block(
  width: 100%, radius: 3pt, inset: (x: 12pt, y: 9pt),
  stroke: (left: 3pt + border), fill: _tint(pal, border, 10%),
)[
  #text(sizes.normal, weight: "bold", fill: pal.ink)[#label#if title != none [ · #title]]
  #v(3pt)
  #text(sizes.normal, fill: pal.text)[#body]
]

#let make(pal, sizes: default-sizes) = {
  let tint = _tint.with(pal)
  let mono = "DejaVu Sans Mono"
  let on-primary = pal.at("on_primary", default: rgb("#ffffff"))

  let kind-color = (
    info: pal.accent,
    success: pal.success,
    warning: pal.warning,
    danger: pal.warning.darken(18%),
    accent: pal.accent_deep,
  )

  return (
    // ── Callouts ──────────────────────────────────────────────
    "rail_pull": (body) => block(
      width: 100%, inset: (left: 12pt, y: 6pt),
      stroke: (left: 3pt + pal.accent),
    )[#text(sizes.large, style: "italic", fill: pal.ink)[#body]],

    "callout": (label, body, kind: "info", height: auto) => {
      let c = kind-color.at(kind, default: pal.accent)
      // Pass `height` when sibling callouts in a grid must bottom-align .
      // a bare box(height:) around the callout can't stretch its fill.
      block(width: 100%, height: height, radius: 3pt, inset: 10pt,
        stroke: (left: 3pt + c), fill: tint(c, 12%))[
        // Label pulls toward ink so pale accents stay legible at small sizes.
        #text(sizes.normal, weight: "bold", fill: color.mix((c, 65%), (pal.ink, 35%)))[#label]
        #v(2pt)
        #text(sizes.normal, fill: pal.text)[#body]
      ]
    },

    "codebox": (body, size: sizes.normal) => block(
      width: 100%, radius: 4pt, inset: 12pt,
      fill: tint(pal.primary, 7%),
      stroke: 0.5pt + pal.hairline,
    )[
      #set raw(theme: none)
      #text(font: mono, size: size, fill: pal.text)[#body]
    ],

    "quote_pull": (body, source: none) => block(width: 100%, inset: (left: 16pt, y: 8pt))[
      #text(sizes.large, style: "italic", fill: pal.ink)[#quote[#body]]
      #if source != none [#linebreak() #text(sizes.caption, fill: pal.text_soft)[#source]]
    ],

    // ── Figure ────────────────────────────────────────────────
    "figbox": (title, body, caption: none) => block(width: 100%, inset: 0pt)[
      #block(width: 100%, stroke: (bottom: 0.5pt + pal.hairline), inset: (bottom: 6pt))[
        #text(sizes.normal, weight: "bold", fill: pal.ink)[#title]
      ]
      #v(6pt)
      #body
      #if caption != none [
        #v(4pt)
        #text(sizes.caption, fill: pal.text_soft)[#caption]
      ]
    ],

    // Pass image("photo.png") from the deck, so paths resolve in its project.
    "portrait": (src, name, size: 64pt) => block(width: 100%)[
      #align(center)[
        #box(width: size, height: size, clip: true, stroke: 0.5pt + pal.hairline,
          radius: 3pt,
          {
            assert(type(src) == content, message: "portrait expects content; pass image(\"photo.png\") from your deck")
            set image(width: size, height: size, fit: "cover")
            src
          })
        #v(4pt)
        #text(sizes.caption, fill: pal.text)[#name]
      ]
    ],

    "clip_image": (src, top: 0pt, bottom: 0pt, left: 0pt, right: 0pt, width: auto) => {
      assert(type(src) == content, message: "clip_image expects content; pass image(\"figure.png\") from your deck")
      let body = { set image(width: width); src }
      box(clip: true, width: width,
        inset: (top: -top, bottom: -bottom, left: -left, right: -right), body)
    },

    // ── Stats ─────────────────────────────────────────────────
    // A stat is a readable statement, not a dashboard numeral: the quantity
    // ("13 weeks") is emphasised by weight and colour only, at the same scale
    // as its meaning. Keep the unit inside the emphasis (`unit: [weeks]`) .
    // a highlighted bare "13" says nothing . and let the label state what
    // the quantity means. Pass plain values ([13], not [*13*]); [*13*] would
    // be repainted primary by touying's alert.
    "stat": (value, label, unit: none) => align(center, text(sizes.large, fill: pal.text)[
      #text(weight: "bold", fill: pal.accent_deep)[#value#if unit != none [~#unit]] #label
    ]),

    // Each cell is two lines . the quantity (bold accent) over its meaning .
    // top-aligned, so a long label wraps under the quantity instead of
    // raggedly mid-statement across the row.
    "stat_row": (..items) => grid(
      columns: (1fr,) * items.pos().len(), column-gutter: 14pt, align: top,
      ..items.pos().map(it => align(center + top, text(sizes.large, fill: pal.text)[
        #text(weight: "bold", fill: pal.accent_deep)[#it.value#if "unit" in it [~#it.unit]] \
        #it.label
      ])),
    ),

    "spec_list": (..items) => {
      let rows = items.pos().enumerate().map(((i, it)) => block(inset: (bottom: 7pt))[
        #text(sizes.normal, weight: "bold", fill: pal.accent_deep)[#(i + 1).] #h(4pt)
        #text(weight: "bold", fill: pal.text)[#it.term] #h(4pt)
        #text(fill: pal.text_soft)[#it.desc]
        #if "tag" in it [
          #h(4pt) #box(fill: tint(pal.primary, 10%), inset: (x: 5pt, y: 2pt), radius: 2pt)[
            #text(sizes.caption, fill: pal.ink)[→ #it.tag]
          ]
        ]
      ])
      rows.join()
    },

    // ── Theory boxes (hand-rolled, no extra packages) ─────────
    "theorem": _thm("Theorem", pal.primary, pal, sizes),
    "definition": _thm("Definition", pal.accent, pal, sizes),
    "lemma": _thm("Lemma", pal.secondary, pal, sizes),
    "example": _thm("Example", pal.text_soft, pal, sizes),
    "proof_box": _thm("Proof", pal.success, pal, sizes),

    // ── Badges ────────────────────────────────────────────────
    // Badges inherit the surrounding text size . no shrunken chip type.
    "badge": (label, fill: pal.primary, fg: auto) => box(
      fill: fill, inset: (x: 7pt, y: 2.5pt), radius: 2pt,
      text(weight: "bold",
        fill: if fg == auto { on-color(fill) } else { fg })[#label],
    ),

    "tag": (label) => box(
      fill: tint(pal.primary, 10%), inset: (x: 7pt, y: 2.5pt), radius: 8pt,
      stroke: 0.5pt + tint(pal.primary, 35%),
      text(fill: pal.ink)[#label],
    ),

    "time_badge": (label) => box(
      fill: tint(pal.warning, 13%), inset: (x: 7pt, y: 2.5pt), radius: 2pt,
      text(font: mono, weight: "bold", fill: pal.warning)[#label],
    ),

    // ── Structure ─────────────────────────────────────────────
    // data_table: positional rows; the FIRST row is the header. The first
    // column is the row label (sans, left); value columns are mono, centred.
    //   #data_table(("Metric","Before","After"), ("Lat","340","52"), highlight: (0,))
    "data_table": (..rows, highlight: ()) => {
      let all = rows.pos()
      assert(all.len() > 0 and all.first().len() > 0, message: "data_table requires a nonempty header row")
      let head = all.first()
      let body = all.slice(1)
      let ncols = head.len()
      assert(all.all(row => row.len() == ncols), message: "data_table rows must have the same number of cells")
      let hcell = (h) => text(sizes.normal, weight: "bold", fill: pal.text_soft,
        h)
      let cell = (j, it, emph) => {
        let body = text(
          size: sizes.normal,
          weight: if emph { "bold" } else { "regular" },
          fill: if emph { pal.accent_deep } else { pal.text },
        )[#it]
        if j == 0 { body } else { text(font: mono, body) }
      }
      table(
        columns: (auto,) + (1fr,) * calc.max(ncols - 1, 0),
        align: (left + horizon,) + (center + horizon,) * calc.max(ncols - 1, 0),
        stroke: (x: none, y: 0.5pt + pal.hairline),
        inset: (x: 8pt, y: 7pt),
        table.header(..head.map(hcell)),
        ..body.enumerate().map(((i, r)) => {
          let emph = i in highlight
          r.enumerate().map(((j, c)) => cell(j, c, emph))
        }).flatten(),
      )
    },

    "conclusion_grid": (..cards, highlight: none) => {
      let items = cards.pos()
      assert(highlight == none or (type(highlight) == int and highlight >= 0 and highlight < items.len()),
        message: "conclusion_grid highlight must be a valid zero-based card index")
      grid(
        columns: (1fr, 1fr), column-gutter: 8pt, row-gutter: 8pt,
        ..items.enumerate().map(((i, c)) => {
          let is-dark = i == highlight
          let bg = if is-dark { pal.primary } else { pal.paper_bg }
          let fg = if is-dark { on-primary } else { pal.ink }
          let fg-sub = if is-dark { color.mix((on-primary, 70%), (pal.primary, 30%)) }
            else { pal.text_soft }
          block(fill: bg, inset: 12pt, radius: 3pt, width: 100%)[
            #text(sizes.normal, weight: "bold", fill: fg-sub)[#c.label]
            #v(4pt)
            #text(sizes.normal, weight: "bold", fill: fg)[#c.title]
            #v(4pt)
            #text(sizes.normal, fill: fg-sub)[#c.body]
          ]
        }),
      )
    },

    "key_links": (..pairs) => block(width: 100%)[
      #grid(
        columns: 1, row-gutter: 9pt,
        ..pairs.pos().map(((lab, link)) => grid(
          columns: (auto, 1fr), column-gutter: 10pt, align: top,
          text(sizes.normal, weight: "bold", fill: pal.text_soft)[#lab],
          text(sizes.normal, fill: pal.ink)[#link])),
      )
    ],

    // ── Deck chrome / pacing ──────────────────────────────────
    // Section outline for the `== Outline` slide (Typst's #outline() renders a
    // paper-style dotted TOC . wrong register for a deck). Lists level-1
    // headings, column-major, numbered in the accent.
    "toc": (columns: 1, size: sizes.large) => context {
      assert(type(columns) == int and columns > 0, message: "toc columns must be a positive integer")
      let secs = query(heading.where(level: 1)).filter(h => h.outlined)
      let per = calc.max(calc.ceil(secs.len() / columns), 1)
      let entry = (i, h) => grid(columns: (auto, 1fr), column-gutter: 10pt, align: top,
        text(size, weight: "bold", fill: pal.accent_deep)[#(i + 1)],
        text(size, fill: pal.ink)[#h.body])
      grid(
        columns: (1fr,) * columns, column-gutter: 28pt, align: top,
        ..range(columns).map(k => grid(
          columns: 1, row-gutter: 14pt,
          ..secs.enumerate().slice(calc.min(k * per, secs.len()), calc.min((k + 1) * per, secs.len()))
            .map(((i, h)) => entry(i, h)),
        )),
      )
    },

    "pacing": (minutes) => context {
      assert((type(minutes) == int or type(minutes) == float) and minutes >= 0,
        message: "pacing minutes must be a nonnegative number")
      let slide = utils.slide-counter.get().first()
      _clock.update(previous => if previous.slide == slide { previous } else {
        (slide: slide, minutes: previous.minutes + minutes)
      })
      context {
        place(top + right,
          text(sizes.chrome, fill: pal.text_soft, str(_clock.get().minutes) + " min"))
      }
    },

    "kicker": (label) => text(sizes.caption, weight: "bold", fill: pal.accent_deep)[#label],

    "progress_dots": (n, current) => {
      let dots = range(n).map(i => {
        let on = i <= current
        box(inset: (x: 1pt))[
          #box(width: 7pt, height: 7pt, radius: 50%,
            fill: if on { pal.primary } else { pal.hairline })[]
        ]
      })
      dots.join()
    },
  )
}
