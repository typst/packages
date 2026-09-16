// ============================================================
// gh-minimal-slides — GitHub-readme-style slide library for Typst (Touying)
// ------------------------------------------------------------
// Ported from a React/HTML reference deck. One file, no transitive
// imports beyond `@preview/touying`. Use it like:
//
//   #import "@preview/touying:0.7.3": *
//   #import "@preview/gh-minimal-slides:0.1.0" as gh
//
//   #show: gh.register.with(theme: "dark", accent: "purple", density: "comfy")
//
//   #gh.cover-slide(title: [Title], badges: ("v1.0.0", "MIT", "build: passing"))
//   #gh.content-slide(title: [List])[
//   - first
//   - second
//   ]
//   ...
//
// All public API is at the bottom. Sections in this file:
//   1. Palette tokens (light/dark)
//   2. Accent presets
//   3. Type / spacing presets (comfy/compact)
//   4. Resolution + state plumbing
//   5. Reusable building blocks (code, links, syntax helpers)
//   6. Internal layout helpers (frame chrome, headings, pills)
//   7. Slide functions
//   8. register() — the Touying entry point
// ============================================================

#import "@preview/touying:0.7.3": *

// ------------------------------------------------------------
// 1. PALETTE
// ------------------------------------------------------------

#let gh-light = (
  bg-canvas:        rgb("#ffffff"),
  bg-canvas-subtle: rgb("#f6f8fa"),
  bg-neutral-muted: rgb("#eaeef2"),
  fg-default:       rgb("#1f2328"),
  fg-muted:         rgb("#59636e"),
  fg-subtle:        rgb("#818b98"),
  border-default:   rgb("#d1d9e0"),
  border-muted:     rgb(209, 217, 224, 180),  // #d1d9e0 @ ~70% alpha
  success:          rgb("#1a7f37"),
  warning:          rgb("#9a6700"),
  danger:           rgb("#cf222e"),
)

#let gh-dark = (
  bg-canvas:        rgb("#0d1117"),
  bg-canvas-subtle: rgb("#151b23"),
  bg-neutral-muted: rgb("#212830"),
  fg-default:       rgb("#f0f6fc"),
  fg-muted:         rgb("#9198a1"),
  fg-subtle:        rgb("#6e7681"),
  border-default:   rgb("#3d444d"),
  border-muted:     rgb(61, 68, 77, 128),     // #3d444d @ ~50% alpha
  success:          rgb("#3fb950"),
  warning:          rgb("#d29922"),
  danger:           rgb("#f85149"),
)

// ------------------------------------------------------------
// 2. ACCENTS
// ------------------------------------------------------------

#let gh-accents = (
  blue:   (light: rgb("#0969da"), dark: rgb("#4493f8")),
  green:  (light: rgb("#1a7f37"), dark: rgb("#3fb950")),
  purple: (light: rgb("#8250df"), dark: rgb("#a371f7")),
  pink:   (light: rgb("#bf3989"), dark: rgb("#db61a2")),
  orange: (light: rgb("#bc4c00"), dark: rgb("#db6d28")),
  mono:   (light: rgb("#1f2328"), dark: rgb("#f0f6fc")),
)

// ------------------------------------------------------------
// 3. TYPE & SPACING
// ------------------------------------------------------------
//
// Page is 1152 x 648 pt (Touying default 16:9). All sizes derived from
// the JSX TYPE_SCALE in pixels at 1920 x 1080, scaled by 0.75 so the
// proportional weights survive the smaller surface.

#let _ts-comfy = (
  hero:      84pt,    // 112px
  title:     48pt,    // 64px
  subtitle:  33pt,    // 44px
  body:      25.5pt,  // 34px
  small:     21pt,    // 28px
  mono:      22.5pt,  // 30px
  micro:     19.5pt,  // 26px — chrome / breadcrumb / pills
  stat:      72pt,    // 96px — used by stats cards
  twocol-stat: 60pt,  // 80px
  kicker:    21pt,    // 28px (uppercase tracked)
)

#let _ts-compact = (
  hero:      72pt,
  title:     42pt,
  subtitle:  30pt,
  body:      22.5pt,
  small:     19.5pt,
  mono:      19.5pt,
  micro:     18pt,
  stat:      66pt,
  twocol-stat: 54pt,
  kicker:    19.5pt,
)

#let _sp-comfy = (
  pad-top:    112pt,  // 150px
  pad-bottom: 60pt,   // 80px
  pad-x:      90pt,   // 120px
  title-gap:  39pt,   // 52px
  item-gap:   21pt,   // 28px
  section-gap: 54pt,  // 72px
  chrome-top: 30pt,   // 40px from top edge
)

#let _sp-compact = (
  pad-top:    97pt,
  pad-bottom: 48pt,
  pad-x:      75pt,
  title-gap:  30pt,
  item-gap:   15pt,
  section-gap: 42pt,
  chrome-top: 24pt,
)

// ------------------------------------------------------------
// 4. RESOLUTION + STATE
// ------------------------------------------------------------

#let _resolve(theme, accent, density, title) = {
  let palette = if theme == "dark" { gh-dark } else { gh-light }
  let accent-key = if accent in gh-accents { accent } else { "blue" }
  let accent-color = gh-accents.at(accent-key).at(theme)
  let ts = if density == "compact" { _ts-compact } else { _ts-comfy }
  let sp = if density == "compact" { _sp-compact } else { _sp-comfy }
  (
    theme:   theme,
    palette: palette,
    accent:  accent-color,
    ts:      ts,
    sp:      sp,
    title:   title,
  )
}

// Live theme state. Set by register(); read inside each slide via
// `context _gh-state.get()`. Default keeps things sane if a slide
// function is invoked without a register call (e.g. quick scratch use).
#let _gh-state = state("gh-theme", _resolve("light", "blue", "comfy", none))

// Pad an integer to two digits as a string.
#let _pad2(n) = if n < 10 { "0" + str(n) } else { str(n) }

// Default fonts. Inter + JetBrains Mono are widely installable; fallbacks
// follow GitHub's own system stack.
#let _font-sans = ("Inter", "Helvetica Neue", "Arial")
#let _font-mono = ("JetBrains Mono", "SF Mono", "Menlo")

// ------------------------------------------------------------
// 5. PUBLIC BUILDING BLOCKS
// ------------------------------------------------------------

// GitHub syntax-theme colors. Each helper picks light or dark variants
// from the active theme, matching the JSX overrides in readme-slides.html.
#let _syntax = (
  light: (
    keyword: rgb("#cf222e"),
    string:  rgb("#0a3069"),
    number:  rgb("#0550ae"),
    comment: rgb("#6e7781"),
  ),
  dark: (
    keyword: rgb("#ff7b72"),
    string:  rgb("#a5d6ff"),
    number:  rgb("#79c0ff"),
    comment: rgb("#8b949e"),
  ),
)
#let _syn(key, b, style: none) = context {
  let ctx = _gh-state.get()
  let fill = _syntax.at(ctx.theme).at(key)
  if style == none { text(fill: fill, b) }
  else { text(fill: fill, style: style, b) }
}
#let c-keyword(b) = _syn("keyword", b)
#let c-string(b)  = _syn("string",  b)
#let c-number(b)  = _syn("number",  b)
#let c-comment(b) = _syn("comment", b, style: "italic")

// Inline pill for `code` mentions inside body text.
#let code-inline(body) = context {
  let ctx = _gh-state.get()
  box(
    fill: ctx.palette.bg-neutral-muted,
    inset: (x: 6pt, y: 2pt),
    outset: (y: 1pt),
    radius: 4pt,
    text(font: _font-mono, size: 0.96em, fill: ctx.palette.fg-default, body),
  )
}

// Accent-colored span. No underline (matches the JSX <Link> component).
#let gh-link(body) = context {
  let ctx = _gh-state.get()
  text(fill: ctx.accent, body)
}

#let _semantic-color(value, ctx, fallback: none) = {
  if type(value) == color { value }
  else if value == "accent" { ctx.accent }
  else if value == "success" { ctx.palette.success }
  else if value == "warning" { ctx.palette.warning }
  else if value == "danger" { ctx.palette.danger }
  else if fallback != none { fallback }
  else { ctx.palette.fg-muted }
}

// Compact terminal/code block. Inherits the active light/dark slide theme.
// Fenced code blocks use this chrome while preserving Typst's native raw
// syntax highlighting. Use `lines` for terminal output or manual rows.
#let terminal-block(
  title: none,
  lang: none,
  prompt: none,
  lines: none,
  line-numbers: false,
  body: none,
) = context {
  let ctx = _gh-state.get()
  let has-header = title != none or lang != none or prompt != none
  let terminal-bg = ctx.palette.bg-canvas-subtle
  let terminal-bar = ctx.palette.bg-neutral-muted
  let terminal-stroke = ctx.palette.border-muted
  let terminal-fg = ctx.palette.fg-default
  let terminal-muted = ctx.palette.fg-subtle
  block(
    stroke: 1pt + terminal-stroke,
    radius: 6pt,
    fill: terminal-bg,
    width: 100%,
    clip: true,
    inset: 0pt,
  )[
    #if has-header {
      block(
        width: 100%,
        fill: terminal-bar,
        inset: (x: 14pt, y: 7pt),
        stroke: (bottom: 1pt + terminal-stroke),
      )[
        #grid(columns: (1fr, auto),
          if prompt != none {
            text(font: _font-mono, size: ctx.ts.micro,
                 fill: terminal-fg, prompt)
          } else if title != none {
            text(font: _font-mono, size: ctx.ts.micro,
                 fill: terminal-fg, title)
          } else { [] },
          if lang != none {
            text(font: _font-mono, size: ctx.ts.micro,
                 fill: terminal-muted, lang)
          } else { [] },
        )
      ]
    }
    #block(width: 100%, inset: (x: 14pt, top: 4pt, bottom: 18pt))[
      #set text(font: _font-mono, size: ctx.ts.mono, fill: terminal-fg)
      #set par(leading: 0.56em)
      #if body != none {
        body
      } else {
        let line-body(ln) = {
          if type(ln) == str and ln == "" {
            box(height: 0.75em)
          } else {
            block(width: 100%)[#ln]
          }
        }
        let render-line(i, ln) = {
          if line-numbers {
            grid(columns: (26pt, 1fr), gutter: 12pt,
              align(right + top, text(fill: terminal-muted, str(i + 1))),
              line-body(ln),
            )
          } else {
            grid(columns: (1fr,), line-body(ln))
          }
        }
        stack(
          spacing: 6.5pt,
          ..lines.enumerate().map(((i, ln)) => render-line(i, ln)),
        )
      }
    ]
  ]
}

// Compatibility wrapper. Prefer `terminal-block` for new code/terminal UI.
#let code-block(filename: none, lang: none, lines: (), line-numbers: false) = {
  terminal-block(title: filename, lang: lang, lines: lines, line-numbers: line-numbers)
}

// ------------------------------------------------------------
// 6. INTERNAL LAYOUT HELPERS
// ------------------------------------------------------------

// h1 / h2 mimic markdown header rendering: bottom hairline rule.
#let _h1(body, ctx) = block(
  width: 100%,
  inset: (bottom: 8pt),
  stroke: (bottom: 1pt + ctx.palette.border-muted),
)[
  #set text(size: ctx.ts.title, weight: 600, fill: ctx.palette.fg-default,
            top-edge: "ascender")
  #set par(leading: 0.45em)
  #body
]

#let _h2(body, ctx) = block(
  width: 100%,
  inset: (bottom: 6pt),
  stroke: (bottom: 1pt + ctx.palette.border-muted),
)[
  #set text(size: ctx.ts.subtitle, weight: 600, fill: ctx.palette.fg-default,
            top-edge: "ascender")
  #set par(leading: 0.45em)
  #body
]

// Pill chip used by cover-slide badges.
#let _pill(body, color: none, ctx: none) = {
  let c = if color == none { ctx.palette.fg-muted } else { color }
  box(
    fill: ctx.palette.bg-neutral-muted,
    stroke: 1pt + ctx.palette.border-muted,
    inset: (x: 11pt, y: 4pt),
    radius: 999pt,
    text(font: _font-mono, size: ctx.ts.micro, fill: c, body),
  )
}

// Top header — deck title left (muted grey), `nn / nn` right (subtle).
// The deck title comes from register()'s `title` arg and is shared across
// every chromed slide; per-slide H2 headings remain in the body.
#let _header(n, total, ctx) = context {
  let resolved-n = if n == auto { utils.slide-counter.get().first() } else { n }
  let resolved-total = if total == auto { utils.last-slide-counter.final().first() } else { total }
  block(width: 100%)[
    #grid(columns: (1fr, auto), align: (left + horizon, right + horizon),
      text(size: ctx.ts.micro, fill: ctx.palette.fg-muted, ctx.title),
      if resolved-n != none and resolved-total != none {
        text(font: _font-mono, size: ctx.ts.micro, fill: ctx.palette.fg-subtle,
          _pad2(resolved-n) + " / " + _pad2(resolved-total))
      } else { [] },
    )
  ]
}

// Generic frame: outer slide insets, optional deck-title header. Body
// receives the full content area below the header.
#let _frame(n: auto, total: auto, body) = context {
  let ctx = _gh-state.get()
  let show-header = n != none and ctx.title != none
  block(
    width: 100%,
    height: 100%,
    inset: (
      top:    if show-header { ctx.sp.chrome-top } else { ctx.sp.pad-top },
      bottom: ctx.sp.pad-bottom,
      x:      ctx.sp.pad-x,
    ),
  )[
    #if show-header {
      _header(n, total, ctx)
      v(ctx.sp.pad-top - ctx.sp.chrome-top - ctx.ts.micro - 8pt)
    }
    #body
  ]
}

// ------------------------------------------------------------
// 7. SLIDE FUNCTIONS
// ------------------------------------------------------------
//
// All slide functions wrap `touying-slide-wrapper` so they integrate with
// Touying's slide-counting and config inheritance. Layout decisions all
// happen inside a `context` block reading `_gh-state` so theme switches
// at register-time cascade through every slide without per-call args.

// 01 — Cover.
// `badges`: array of (text, kind?) where kind is one of "default",
//   "accent", "success" — controls color. Plain strings get "default".
#let cover-slide(
  title: [A minimal\ readme-style\ slide gallery.],
  kicker: "# README.md",
  badges: ("v1.0.0", ("MIT license", "accent"), ("build: passing", "success"), "docs"),
  footer-left: "@author · 2026",
  footer-right: "↓ scroll  ·  → next",
) = touying-slide-wrapper(self => {
  touying-slide(self: self, context {
    let ctx = _gh-state.get()
    let badge-of(b) = {
      let txt = if type(b) == array { b.at(0) } else { b }
      let kind = if type(b) == array { b.at(1) } else { "default" }
      let color = if kind == "accent" { ctx.accent }
                  else if kind == "success" { ctx.palette.success }
                  else { ctx.palette.fg-muted }
      _pill(txt, color: color, ctx: ctx)
    }
    let badges-row = {
      for (i, b) in badges.enumerate() {
        badge-of(b)
        if i + 1 < badges.len() { h(8pt) }
      }
    }
    block(
      width: 100%, height: 100%,
      inset: (top: ctx.sp.pad-top, bottom: ctx.sp.pad-bottom, x: ctx.sp.pad-x),
    )[
      #stack(
        text(font: _font-mono, size: ctx.ts.micro, fill: ctx.accent,
             tracking: 0.5pt, kicker),
        v(1fr),
        block(width: 100%)[
          #set text(size: ctx.ts.hero, weight: 700, fill: ctx.palette.fg-default,
                    tracking: -1.5pt, top-edge: "ascender")
          #set par(leading: 0.4em)
          #title
        ],
        v(ctx.sp.title-gap),
        block(width: 100%, badges-row),
        v(1fr),
        block(width: 100%, grid(columns: (1fr, auto),
          text(font: _font-mono, size: ctx.ts.micro,
               fill: ctx.palette.fg-muted, footer-left),
          text(font: _font-mono, size: ctx.ts.micro,
               fill: ctx.palette.fg-muted, footer-right),
        )),
      )
    ]
  })
})

// 02 — Section divider.
#let section-slide(
  number: "01",
  kicker: "Chapter",
  title: [Getting started],
  n: auto,
  total: auto,
) = touying-slide-wrapper(self => {
  touying-slide(self: self, _frame(n: n, total: total,
    block(width: 100%, height: 100%)[
      #context {
        let ctx = _gh-state.get()
        stack(
          v(1fr),
          // § number
          text(font: _font-mono, size: ctx.ts.subtitle, fill: ctx.accent,
               "§ " + number),
          v(24pt),
          // kicker
          text(size: ctx.ts.kicker, fill: ctx.palette.fg-muted,
               tracking: 2.5pt, upper(kicker)),
          v(24pt),
          // hero title
          block(width: 100%)[
            #set text(size: ctx.ts.hero, weight: 700, fill: ctx.palette.fg-default,
                      tracking: -1.5pt, top-edge: "ascender")
            #set par(leading: 0.4em)
            #title
          ],
          v(20pt),
          // 60% width hairline
          box(width: 60%, height: 1pt, fill: ctx.palette.border-muted),
          v(1fr),
        )
      }
    ]
  ))
})

// 03 — Deprecated legacy bullet list. Prefer `content-slide` with normal
// Typst list markup and callback-style animation for new slides.
// `items`: array of (label, body) tuples or (label: ..., body: ...) dicts.
#let bullet-slide(
  title: [Unordered list],
  items: (),
  incremental: false,
  n: auto,
  total: auto,
) = touying-slide-wrapper(outer-self => {
  let repeat-count = if incremental { items.len() + 1 } else { auto }
  touying-slide(self: outer-self, repeat: repeat-count, sub-self => _frame(n: n, total: total,
    context {
      let ctx = _gh-state.get()
      // Item shapes accepted:
      //   - `(label, body)`              — label/body split (bold label, em-dash, muted body)
      //   - `(label: ..., body: ...)`    — same, dict form
      //   - any single content `[...]`   — plain bullet, user controls all formatting inline
      let render-item(it) = {
        let is-label-body = (
          type(it) == dictionary
            or (type(it) == array and it.len() == 2)
        )
        block(width: 100%, inset: (bottom: ctx.sp.item-gap))[
          #grid(
            columns: (32pt, 1fr), gutter: 0pt,
            text(font: _font-mono, size: ctx.ts.body,
                 fill: ctx.palette.fg-subtle, "•"),
            if is-label-body {
              let (lbl, body) = if type(it) == dictionary {
                (it.at("label"), it.at("body"))
              } else { it }
              {
                set text(size: ctx.ts.body, fill: ctx.palette.fg-default)
                set par(leading: 0.5em)
                text(weight: 600, lbl)
                text[ ]
                text(fill: ctx.palette.fg-muted)[— ]
                text(fill: ctx.palette.fg-muted, body)
              }
            } else {
              {
                set text(size: ctx.ts.body, fill: ctx.palette.fg-default)
                set par(leading: 0.5em)
                it
              }
            },
          )
        ]
      }
      _h2(title, ctx)
      v(ctx.sp.title-gap)
      if incremental {
        for (i, it) in items.enumerate() {
          utils.uncover(self: sub-self, str(i + 2) + "-", render-item(it))
        }
      } else {
        for it in items { render-item(it) }
      }
    }
  ))
})

// 04 — Legacy accent-numbered list. Prefer `content-slide` with Typst's
// native `+` enum markup for ordinary numbered lists. Keep this when you
// specifically want tuple-shaped label/body items or incremental reveals.
#let ordered-slide(
  title: [Installation],
  items: (),
  incremental: false,
  n: auto,
  total: auto,
) = touying-slide-wrapper(outer-self => {
  let repeat-count = if incremental { items.len() + 1 } else { auto }
  touying-slide(self: outer-self, repeat: repeat-count, sub-self => _frame(n: n, total: total,
    context {
      let ctx = _gh-state.get()
      let render-item(i, it) = {
        let (lbl, body) = if type(it) == dictionary {
          (it.at("label"), it.at("body"))
        } else { it }
        block(width: 100%, inset: (bottom: ctx.sp.item-gap))[
          #grid(
            columns: (54pt, 1fr), gutter: 0pt,
            text(font: _font-mono, size: ctx.ts.body, weight: 600,
                 fill: ctx.accent, str(i + 1) + "."),
            {
              set text(size: ctx.ts.body, fill: ctx.palette.fg-default)
              set par(leading: 0.5em)
              block(below: 10pt)[#text(weight: 600, lbl)]
              block(above: 2pt)[#text(fill: ctx.palette.fg-muted, body)]
            },
          )
        ]
      }
      _h2(title, ctx)
      v(ctx.sp.title-gap)
      if incremental {
        for (i, it) in items.enumerate() {
          utils.uncover(self: sub-self, str(i + 2) + "-", render-item(i, it))
        }
      } else {
        for (i, it) in items.enumerate() { render-item(i, it) }
      }
    }
  ))
})

// 05 — Blockquote.
#let quote-slide(
  title: [Blockquote],
  body: [],
  attribution: none,
  n: auto,
  total: auto,
) = touying-slide-wrapper(self => {
  touying-slide(self: self, _frame(n: n, total: total,
    context {
      let ctx = _gh-state.get()
      block(width: 100%, height: 100%)[
        #set align(horizon)
        #stack(spacing: 30pt,
          _h2(title, ctx),
          block(
            width: 100%,
            inset: (left: 24pt, top: 6pt, bottom: 6pt),
            stroke: (left: 4pt + ctx.palette.border-default),
          )[
            #set text(size: 36pt, fill: ctx.palette.fg-muted, weight: 400)
            #set par(leading: 0.5em)
            #body
          ],
          if attribution != none {
            text(font: _font-mono, size: ctx.ts.small,
                 fill: ctx.palette.fg-subtle, attribution)
          },
        )
      ]
    }
  ))
})

// 06 — Legacy code block slide. Prefer `content-slide` with
// `terminal-block` for new code and terminal UI.
#let code-slide(
  title: [Code block],
  filename: none,
  lang: none,
  lines: (),
  line-numbers: false,
  caption: none,
  n: auto,
  total: auto,
) = touying-slide-wrapper(self => {
  touying-slide(self: self, _frame(n: n, total: total,
    context {
      let ctx = _gh-state.get()
      stack(
        _h2(title, ctx),
        v(ctx.sp.title-gap),
        terminal-block(title: filename, lang: lang, lines: lines, line-numbers: line-numbers),
        if caption != none {
          stack(
            v(12pt),
            text(size: ctx.ts.small, style: "italic",
                 fill: ctx.palette.fg-muted, caption),
          )
        },
      )
    }
  ))
})

// 07 — Table.
// `headers`: array of strings. `rows`: array of arrays (cells per row).
// `value-colors`: optional dict mapping the value of column 0 to a color
//   or semantic color name (`"accent"`, `"success"`, `"warning"`, `"danger"`).
//   When set, column-0 cells render in mono + the matched color.
#let table-slide(
  title: [Endpoints],
  headers: ("Method", "Path", "Status", "Description"),
  rows: (),
  columns: none,
  value-colors: none,
  method-colors: none,
  animation: false,
  n: auto,
  total: auto,
) = touying-slide-wrapper(outer-self => {
  let repeat-count = if animation and rows.len() > 0 { rows.len() + 1 } else { auto }
  touying-slide(self: outer-self, repeat: repeat-count, sub-self => _frame(n: n, total: total,
    context {
      let ctx = _gh-state.get()
      let resolved-colors = if value-colors != none { value-colors }
      else if method-colors != none { method-colors }
      else {
        (
          GET:    "accent",
          POST:   "success",
          PATCH:  "warning",
          DELETE: "danger",
        )
      }
      let resolved-columns = if columns != none { columns }
      else if headers.len() == 4 { (1.2fr, 3fr, 1fr, 4fr) }
      else { range(headers.len()).map(_ => 1fr) }
      // Tabular `grid.cell` directly inside grid lets the column widths
      // (fractions) actually allocate space — wrapping each cell in a
      // block(width: 100%) collapses auto columns to their min content.
      let header-cell(h) = grid.cell(
        fill: ctx.palette.bg-neutral-muted,
        inset: (x: 16pt, y: 12pt),
        stroke: (bottom: 1pt + ctx.palette.border-muted),
      )[
        #text(size: ctx.ts.body, weight: 600, fill: ctx.palette.fg-default, h)
      ]
      let body-cell(i, j, cell) = {
        let mono = j == 0 or j == 1 or j == 2
        let color = if j == 0 and type(cell) == str and cell in resolved-colors {
          _semantic-color(resolved-colors.at(cell), ctx)
        } else if j == 3 {
          ctx.palette.fg-muted
        } else {
          ctx.palette.fg-default
        }
        let weight = if j == 0 { 600 } else { 400 }
        grid.cell(
          inset: (x: 16pt, y: 12pt),
          stroke: if i > 0 { (top: 1pt + ctx.palette.border-muted) } else { none },
        )[
          #text(
            size: ctx.ts.body,
            font: if mono { _font-mono } else { _font-sans },
            fill: color, weight: weight, cell,
          )
        ]
      }
      let header-cells = headers.map(header-cell)
      let body-cells = rows.enumerate().map(((i, row)) => {
        let row-cells = row.enumerate().map(((j, cell)) => body-cell(i, j, cell))
        if animation {
          row-cells.map(cell => utils.uncover(self: sub-self, str(i + 2) + "-", cell))
        } else {
          row-cells
        }
      }).flatten()
      stack(
        _h2(title, ctx),
        v(ctx.sp.title-gap),
        block(
          stroke: 1pt + ctx.palette.border-muted,
          radius: 6pt,
          clip: true,
          width: 100%,
          grid(
            columns: resolved-columns,
            ..header-cells,
            ..body-cells,
          ),
        ),
      )
    }
  ))
})

// 08 — Two-column comparison cards.
// Each side: (kicker, color, stat, body). `color` can be a semantic color
// name (`"accent"`, `"success"`, `"warning"`, `"danger"`) or a custom rgb.
#let two-col-slide(
  title: [Before & after],
  left:  ("Before", "danger",  "12m 04s", [Slow.]),
  right: ("After",  "success", "1m 47s",  [Fast.]),
  n: auto,
  total: auto,
) = touying-slide-wrapper(self => {
  touying-slide(self: self, _frame(n: n, total: total,
    context {
      let ctx = _gh-state.get()
      let card(side) = {
        let (k, color, stat, body) = side
        block(
          stroke: 1pt + ctx.palette.border-muted,
          radius: 8pt,
          fill: ctx.palette.bg-canvas-subtle,
          width: 100%,
          inset: 28pt,
        )[
          #stack(spacing: 18pt,
            text(font: _font-mono, size: ctx.ts.micro,
                 fill: _semantic-color(color, ctx), tracking: 1pt, upper(k)),
            text(size: ctx.ts.twocol-stat, font: _font-mono, weight: 700,
                 fill: ctx.palette.fg-default, stat),
            text(size: ctx.ts.small, fill: ctx.palette.fg-muted, body),
          )
        ]
      }
      stack(
        _h2(title, ctx),
        v(ctx.sp.title-gap),
        grid(
          columns: (1fr, 1fr), gutter: 30pt,
          card(left), card(right),
        ),
      )
    }
  ))
})

// 09 — Image / figure with caption.
// `body` is any content — typically `image("path")` or a placeholder
// block. `caption` accepts content (use #gh-link inline if you want a
// link).
#let image-slide(
  title: [Figure 1 — system overview],
  body: none,
  caption: [],
  placeholder-text: "[ architecture diagram ]",
  n: auto,
  total: auto,
) = touying-slide-wrapper(self => {
  touying-slide(self: self, _frame(n: n, total: total,
    context {
      let ctx = _gh-state.get()
      let figure-body = if body != none { body } else {
        block(
          width: 100%, height: 350pt,
          stroke: 1pt + ctx.palette.border-muted,
          radius: 8pt,
          fill: ctx.palette.bg-canvas-subtle,
        )[
          #set align(center + horizon)
          #text(font: _font-mono, size: ctx.ts.micro,
                fill: ctx.palette.fg-muted, tracking: 1pt, placeholder-text)
        ]
      }
      stack(
        _h2(title, ctx),
        v(ctx.sp.title-gap),
        figure-body,
        v(12pt),
        text(size: ctx.ts.small, style: "italic",
             fill: ctx.palette.fg-muted, caption),
      )
    }
  ))
})

// 10 — Stats grid (2 x 2).
// Each stat: (value, label, delta).
#let stats-slide(
  title: [Q1 metrics],
  stats: (),
  n: auto,
  total: auto,
) = touying-slide-wrapper(self => {
  touying-slide(self: self, _frame(n: n, total: total,
    context {
      let ctx = _gh-state.get()
      let card(s) = {
        let (value, lbl, delta) = s
        block(
          stroke: 1pt + ctx.palette.border-muted,
          radius: 8pt,
          width: 100%,
          inset: (x: 28pt, y: 24pt),
        )[
          #grid(columns: (auto, 1fr), gutter: 12pt, align: bottom + left,
            text(size: ctx.ts.stat, weight: 700, tracking: -1.5pt,
                 fill: ctx.palette.fg-default, value),
            text(font: _font-mono, size: ctx.ts.micro,
                 fill: ctx.palette.success, "↑ " + delta),
          )
          #v(8pt)
          #text(size: ctx.ts.small, tracking: 1.2pt,
                fill: ctx.palette.fg-muted, upper(lbl))
        ]
      }
      // Make a 2-column grid of cards.
      stack(
        _h2(title, ctx),
        v(ctx.sp.title-gap),
        grid(
          columns: (1fr, 1fr),
          gutter: 24pt,
          ..stats.map(card),
        ),
      )
    }
  ))
})

// 11 — Task list.
// Each task: (done, label, meta).
#let task-slide(
  title: [Task list — v1 milestone],
  tasks: (),
  n: auto,
  total: auto,
) = touying-slide-wrapper(self => {
  touying-slide(self: self, _frame(n: n, total: total,
    context {
      let ctx = _gh-state.get()
      stack(
        _h2(title, ctx),
        v(ctx.sp.title-gap),
        ..tasks.map(t => {
          let (done, lbl, meta) = t
          (
            block(width: 100%, inset: (bottom: ctx.sp.item-gap))[
              #grid(
                columns: (28pt, 1fr, auto),
                column-gutter: 18pt,
                align: horizon + left,
                // checkbox
                box(
                  width: 22pt, height: 22pt,
                  radius: 4pt,
                  stroke: 2pt + (if done { ctx.palette.success } else { ctx.palette.border-default }),
                  fill: if done { ctx.palette.success } else { white.transparentize(100%) },
                )[
                  #if done {
                    set align(center + horizon)
                    text(fill: ctx.palette.bg-canvas, weight: 700,
                         size: ctx.ts.small, "✓")
                  }
                ],
                text(
                  size: ctx.ts.body,
                  fill: if done { ctx.palette.fg-muted } else { ctx.palette.fg-default },
                  if done { strike(lbl) } else { lbl },
                ),
                text(font: _font-mono, size: ctx.ts.micro,
                     fill: ctx.palette.fg-subtle, meta),
              )
            ],
          )
        }).flatten(),
      )
    }
  ))
})

// 12 — Alert callouts.
// Each alert: (kind, color, body) where kind is e.g. "NOTE" / "TIP" /
// "WARNING" / "CAUTION" and color is one of
// ctx.palette.{success,warning,danger} or ctx.accent or a raw color.
#let alert-slide(
  title: [Alert callouts],
  alerts: (),
  n: auto,
  total: auto,
) = touying-slide-wrapper(self => {
  touying-slide(self: self, _frame(n: n, total: total,
    context {
      let ctx = _gh-state.get()
      stack(
        _h2(title, ctx),
        v(ctx.sp.title-gap),
        ..alerts.map(a => {
          let (kind, color, body) = a
          let c = _semantic-color(color, ctx, fallback: ctx.accent)
          (
            block(width: 100%, inset: (bottom: 16pt))[
              #block(
                fill: ctx.palette.bg-canvas-subtle,
                stroke: (left: 4pt + c),
                inset: (left: 22pt, right: 22pt, top: 16pt, bottom: 16pt),
                radius: (right: 6pt),
                width: 100%,
              )[
                #stack(spacing: 6pt,
                  text(font: _font-mono, size: ctx.ts.micro,
                       weight: 700, fill: c, tracking: 1.5pt,
                       "▲ " + upper(kind)),
                  text(size: ctx.ts.small, fill: ctx.palette.fg-default, body),
                )
              ]
            ],
          )
        }).flatten(),
      )
    }
  ))
})

// Top-level animation steps in a normal Typst body. Intro content before the
// first list item is static; each list item is one step; trailing content
// after the list is one final step.
#let _animation-steps(body) = {
  if repr(body.func()) == "sequence" {
    let children = body.fields().children
    let item-count = children
      .filter(child => repr(child.func()) == "item")
      .len()
    let seen-item = false
    let has-trailing = false
    for child in children {
      if repr(child.func()) == "item" {
        seen-item = true
      } else if seen-item and repr(child) != "[ ]" {
        has-trailing = true
      }
    }
    item-count + if has-trailing { 1 } else { 0 }
  } else if repr(body.func()) == "item" {
    1
  } else {
    0
  }
}

// Reveal top-level list items one by one, then reveal trailing content after
// the list. Non-list intro content remains visible on every subslide.
#let _animate-top-level-items(body, self) = {
  if repr(body.func()) == "sequence" {
    let out = ()
    let i = 0
    let seen-item = false
    let tail = ()
    for child in body.fields().children {
      if repr(child.func()) == "item" {
        seen-item = true
        i += 1
        out.push(utils.uncover(self: self, str(i + 1) + "-", child))
      } else if seen-item {
        tail.push(child)
      } else {
        out.push(child)
      }
    }
    if tail.len() > 0 and tail.any(child => repr(child) != "[ ]") {
      out.push(utils.uncover(self: self, str(i + 2) + "-", tail.sum(default: none)))
    } else {
      out.push(tail.sum(default: none))
    }
    out.sum(default: none)
  } else if repr(body.func()) == "item" {
    utils.uncover(self: self, "2-", body)
  } else {
    body
  }
}

// 13 — Free-form content slide.
// Use normal Typst markup in `body`, including nested lists.
#let content-slide(
  title: [Content],
  n: auto,
  total: auto,
  repeat: auto,
  animation: false,
  body,
) = touying-slide-wrapper(outer-self => {
  let repeat-count = if animation and type(body) != function {
    let steps = _animation-steps(body)
    if steps > 0 { steps + 1 } else { repeat }
  } else {
    repeat
  }
  touying-slide(self: outer-self, repeat: repeat-count, sub-self => _frame(n: n, total: total,
    context {
      let ctx = _gh-state.get()
      let rendered-body = if type(body) == function {
        body(sub-self)
      } else if animation {
        _animate-top-level-items(body, sub-self)
      } else {
        body
      }
      stack(
        _h2(title, ctx),
        v(ctx.sp.title-gap),
        block(width: 100%)[
          #set text(size: ctx.ts.body, fill: ctx.palette.fg-default)
          #set par(leading: 0.55em)
          #rendered-body
        ],
      )
    }
  ))
})

// 14 — Closing slide.
// `links`: array of strings or content; each becomes "→ <link>".
#let closing-slide(
  kicker: "## Thanks",
  title: [Questions?],
  links: ("docs/", "issues/", "contact.md"),
  n: auto,
  total: auto,
) = touying-slide-wrapper(self => {
  touying-slide(self: self, _frame(n: n, total: total,
    context {
      let ctx = _gh-state.get()
      block(width: 100%, height: 100%)[
        #set align(horizon)
        #stack(spacing: 30pt,
          text(font: _font-mono, size: ctx.ts.micro, fill: ctx.accent, kicker),
          block(width: 100%)[
            #set text(size: ctx.ts.hero, weight: 700,
                      fill: ctx.palette.fg-default,
                      tracking: -1.5pt, top-edge: "ascender")
            #set par(leading: 0.4em)
            #title
          ],
          box(width: 100%, height: 1pt, fill: ctx.palette.border-muted),
          block(width: 100%)[
            #for (i, lnk) in links.enumerate() [
              #text(font: _font-mono, size: ctx.ts.small,
                    fill: ctx.palette.fg-muted)[→ ]
              #text(font: _font-mono, size: ctx.ts.small, fill: ctx.accent, lnk)
              #if i + 1 < links.len() { h(28pt) }
            ]
          ],
        )
      ]
    }
  ))
})

// ------------------------------------------------------------
// 8. REGISTER — Touying entry point
// ------------------------------------------------------------

#let register(
  theme: "light",          // "light" | "dark"
  accent: "blue",          // "blue" | "green" | "purple" | "pink" | "orange" | "mono"
  density: "comfy",        // "comfy" | "compact"
  aspect-ratio: "16-9",    // "16-9" | "4-3"
  title: none,             // deck title shown as the small grey header on every chromed slide
  ..args,
  body,
) = {
  let ctx = _resolve(theme, accent, density, title)
  let (w, h) = if aspect-ratio == "4-3" { (1024pt, 768pt) }
               else { (1152pt, 648pt) }
  show: touying-slides.with(
    config-page(
      width: w, height: h,
      margin: 0pt,
      fill: ctx.palette.bg-canvas,
      header: none, footer: none,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(
          font: _font-sans,
          weight: 400,
          size: ctx.ts.body,
          fill: ctx.palette.fg-default,
        )
        set par(leading: 0.55em)
        show raw.where(block: false): it => code-inline(it.text)
        show raw.where(block: true): it => terminal-block(
          lang: it.lang,
          body: it,
        )
        // Push live ctx into state so every slide's `context` block resolves it.
        _gh-state.update(_ => ctx)
        body
      },
    ),
    ..args,
  )
  body
}
