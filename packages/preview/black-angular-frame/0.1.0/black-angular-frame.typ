// ============================================================
// black-angular-frame -- Typst presentation template
// Formal academic presentation theme for Typst
// Usage:
//   #import "black-angular-frame.typ": *
//   #show: black-angular-frame.with(config: (title: "My Talk", ...))
//   #slide(title: "First")[...]
// ============================================================

// ---- Internal state ----------------------------------------
#let _baf-tc = state("_baf-tc", rgb("#1C1C1C"))
#let _baf-sc = state("_baf-sc", rgb("#D9D9D9"))
#let _baf-bg = state("_baf-bg", white)
#let _baf-w = state("_baf-w", 254mm)
#let _baf-h = state("_baf-h", 143mm)
#let _baf-ft = state("_baf-ft", none)
#let _baf-fst = state("_baf-fst", none)
#let _baf-title = state("_baf-title", "")
#let _baf-subt = state("_baf-subt", "")
#let _baf-inst = state("_baf-inst", none)
#let _baf-auth = state("_baf-auth", none)
#let _baf-fc = state("_baf-fc", luma(20))
#let _baf-hfc1 = state("_baf-hfc1", rgb("#999999"))
#let _baf-hfc2 = state("_baf-hfc2", rgb("#1C1C1C"))
#let _baf-hfc1h = state("_baf-hfc1h", white)
#let _baf-final = state("_baf-final", "")
#let _baf-cctr = state("_baf-cctr", 0.3)
#let _baf-cupad = state("_baf-cupad", 0.05)
#let _baf-clpad = state("_baf-clpad", 0.05)
#let _baf-pages = state("_baf-pages", ())
#let _baf-sec-targets = state("_baf-sec-targets", ())

#let _sec-ctr = counter("_baf-sec")
#let _fig-ctr = counter("_baf-fig")
#let _cur-sec = state("_baf-cursec", "")
#let _toc-data = state("_baf-toc", ())

#let _thm-ctrs = (
  theorem: counter("_baf-thm"),
  lemma: counter("_baf-lem"),
  corollary: counter("_baf-cor"),
  proposition: counter("_baf-prp"),
  definition: counter("_baf-def"),
  example: counter("_baf-exa"),
  exercise: counter("_baf-exr"),
  remark: counter("_baf-rmk"),
)

// ---- Color helpers -----------------------------------------
#let _lmix(c, pct) = color.mix((c, 100% - pct), (white, pct))
#let _title-bg(c) = _lmix(c, 88%)
#let _sub-hdr(c) = _lmix(c, 40%)
#let _soft-rule(c) = _lmix(c, 72%)
#let _muted-nav(c) = color.mix((white, 55%), (c, 45%))

// ---- Font stacks -------------------------------------------
#let _sans = ("IBM Plex Sans", "Liberation Sans", "DejaVu Sans")
#let _serif = ("IBM Plex Serif", "Liberation Serif", "DejaVu Serif")
#let _mono = ("IBM Plex Mono", "Liberation Mono", "DejaVu Sans Mono")

#let _slide-x-margin = 22.4pt
#let _single-col-x-margin = 2 * _slide-x-margin
#let _nav-compact-threshold = 4
#let _cover-image-gap = 18pt

#let _clamp01(value) = {
  if value < 0 { 0 } else if value > 1 { 1 } else { value }
}

// ============================================================
// Shared chrome
// ============================================================

#let _single-line(content) = {
  if content == none { none } else if type(content) == str { content.replace("\n", " ") } else { content }
}

#let _fit-ellipsis(value, remaining, width, text-width, suffix: "...") = {
  if remaining <= 0 { suffix } else {
    let omitted = value.len() - remaining
    let candidate = if omitted < suffix.len() {
      value.slice(0, remaining) + value.slice(remaining)
    } else {
      value.slice(0, remaining) + suffix
    }
    if text-width(candidate) <= width {
      candidate
    } else {
      _fit-ellipsis(value, remaining - 1, width, text-width, suffix: suffix)
    }
  }
}

#let _ellipsis-text(
  content,
  width,
  font: _sans,
  size: 10pt,
  fill: black,
  reserve: 8pt,
) = context {
  let effective-width = calc.max(0pt, width - reserve)
  let text-width = value => measure(text(font: font, size: size, fill: fill, value)).width
  let value = _single-line(content)

  if value == none or type(value) != str or text-width(value) <= effective-width {
    text(font: font, size: size, fill: fill, value)
  } else {
    let suffix = "..."
    text(
      font: font,
      size: size,
      fill: fill,
      _fit-ellipsis(value, value.len(), effective-width, text-width, suffix: suffix),
    )
  }
}

#let _nav-dot(active: false, color, inactive-fill: auto, active-fill: white) = box(
  width: 6.2pt,
  height: 6.2pt,
  inset: 0pt,
  align(center + horizon, circle(
    radius: 2pt,
    fill: if active { active-fill } else { none },
    stroke: if active { none } else { (if inactive-fill == auto { _muted-nav(color) } else { inactive-fill }) + 0.7pt },
  )),
)

#let _cover-image-item(logo, height: 45pt) = {
  if type(logo) == str {
    image(logo, height: height)
  } else {
    logo
  }
}

#let _cover-image-row(logos, height: 45pt) = {
  grid(
    columns: logos.map(_ => auto),
    column-gutter: _cover-image-gap,
    align: horizon,
    ..logos.map(logo => _cover-image-item(logo, height: height)),
  )
}

#let _register-page(section: none, intro: false) = {
  _baf-pages.update(p => p + ((section: section, intro: intro),))
}

#let _register-section-target(title, loc) = {
  if title != none and title != "" {
    _baf-sec-targets.update(t => {
      if t.find(entry => entry.title == title) == none {
        t + ((title: title, loc: loc),)
      } else {
        t
      }
    })
  }
}

#let _header-band(
  w,
  section,
  slide-title: none,
  primary,
  secondary,
  header-font-color-1: auto,
  header-font-color-2: auto,
  header-font-color-1-highlight: white,
) = context {
  let hfc1 = if header-font-color-1 == auto { _muted-nav(primary) } else { header-font-color-1 }
  let hfc2 = if header-font-color-2 == auto { primary } else { header-font-color-2 }
  let titles = _toc-data.final().filter(e => e.kind == "section").map(e => e.title)
  let sec-targets = _baf-sec-targets.final()
  let pages = _baf-pages.final()
  let page-no = counter(page).get().first()
  let nav-margin = 22.4pt
  let nav-top = 3.425pt
  let nav-bottom = 2.025pt
  let nav-item-x-inset = 0.4pt
  let active-dot-index = {
    if (
      page-no <= pages.len()
        and section != none
        and section != ""
        and not pages.at(page-no - 1, default: (intro: false)).intro
    ) {
      let seen = 0
      for (idx, entry) in pages.enumerate() {
        if entry.section == section and not entry.intro {
          seen += 1
        }
        if idx + 1 == page-no { break }
      }
      if seen == 0 { none } else { seen }
    } else {
      none
    }
  }
  let nav-slide-count(title) = {
    calc.max(1, pages.filter(entry => entry.section == title and not entry.intro).len())
  }
  let nav-progress-label(title) = {
    let slide-count = nav-slide-count(title)
    let current-page = pages.at(page-no - 1, default: (intro: false))
    let is-current-section = section == title
    let is-section-slide = is-current-section and active-dot-index != none
    if is-section-slide {
      str(active-dot-index) + "/" + str(slide-count)
    } else {
      str(slide-count)
    }
  }
  let nav-progress-width(title) = {
    let slide-count = nav-slide-count(title)
    if slide-count > _nav-compact-threshold {
      let label-width = measure(text(font: _sans, size: 6.8pt, nav-progress-label(title))).width
      6.2pt + 1.6pt + label-width
    } else {
      6.2pt * slide-count + 1.4pt * calc.max(0, slide-count - 1)
    }
  }
  let nav-title-width(title, item-width) = {
    let inner-width = calc.max(0pt, item-width - 2 * nav-item-x-inset)
    let value = _single-line(title)
    if value == none or type(value) != str {
      0pt
    } else {
      let raw-width = measure(text(font: _sans, size: 7.1pt, value)).width
      calc.min(raw-width, inner-width)
    }
  }
  let nav-visible-width(title, item-width) = {
    calc.max(nav-title-width(title, item-width), nav-progress-width(title))
  }
  let nav-item(title, item-width) = {
    let slide-count = nav-slide-count(title)
    let target = sec-targets.rev().find(entry => entry.title == title)
    block(
      width: item-width,
      inset: (left: nav-item-x-inset, right: nav-item-x-inset, top: 1.3pt, bottom: 1.1pt),
      {
        layout(size => {
          let title-fill = if section == title { header-font-color-1-highlight } else { hfc1 }
          let current-page = pages.at(page-no - 1, default: (intro: false))
          let is-current-section = section == title
          let is-section-intro = is-current-section and current-page.intro
          let is-section-slide = is-current-section and active-dot-index != none
          let use-compact-progress = slide-count > _nav-compact-threshold
          let progress-label = nav-progress-label(title)
          let progress-fill = if is-current-section { header-font-color-1-highlight } else { hfc1 }

          let title-content = if target != none {
            link(target.at("loc"))[
              #_ellipsis-text(
                title,
                size.width,
                font: _sans,
                size: 7.1pt,
                fill: title-fill,
              )
            ]
          } else {
            _ellipsis-text(
              title,
              size.width,
              font: _sans,
              size: 7.1pt,
              fill: title-fill,
            )
          }

          let progress-content = if use-compact-progress {
            grid(
              columns: (auto, auto),
              column-gutter: 1.6pt,
              align: horizon,
              _nav-dot(
                active: is-section-slide or is-section-intro,
                primary,
                inactive-fill: hfc1,
                active-fill: header-font-color-1-highlight,
              ),
              move(
                dy: -0.2pt,
                text(font: _sans, fill: progress-fill, size: 6.8pt, progress-label),
              ),
            )
          } else {
            box[
              #for dot-idx in range(slide-count) {
                _nav-dot(
                  active: is-section-slide and active-dot-index == dot-idx + 1,
                  primary,
                  inactive-fill: hfc1,
                  active-fill: header-font-color-1-highlight,
                )
                if dot-idx + 1 < slide-count { h(1.4pt) }
              }
            ]
          }

          grid(
            columns: (1fr,),
            rows: (8.6pt, 6.2pt),
            row-gutter: 0pt,
            block(
              width: 100%,
              height: 8.6pt,
              align(left + horizon, title-content),
            ),
            block(
              width: 100%,
              height: 6.2pt,
              align(left + horizon, move(dy: 2pt, progress-content)),
            ),
          )
        })
      },
    )
  }
  stack(
    dir: ttb,
    spacing: 0pt,
    block(
      width: w,
      height: 24.75pt,
      fill: primary,
      inset: (x: 0pt, y: 0pt),
      {
        if titles != () {
          layout(size => {
            let usable-width = size.width - 2 * nav-margin
            let positions = if titles.len() == 1 {
              (0.5,)
            } else if titles.len() == 2 {
              (1 / 3, 2 / 3)
            } else if titles.len() == 3 {
              (1 / 4, 1 / 2, 3 / 4)
            } else {
              range(titles.len()).map(idx => (idx + 0.5) / titles.len())
            }
            let item-width = if titles.len() == 1 {
              calc.min(usable-width, 260pt)
            } else if titles.len() == 2 {
              calc.min(usable-width / 3, 210pt)
            } else if titles.len() == 3 {
              calc.min(usable-width / 4, 160pt)
            } else {
              usable-width / titles.len()
            }
            let relative-lefts = positions.map(pos => usable-width * pos - item-width / 2)
            let first-left = relative-lefts.at(0)
            let last-left = relative-lefts.at(relative-lefts.len() - 1)
            let last-title = titles.at(titles.len() - 1)
            let last-visible-width = nav-visible-width(last-title, item-width)
            let centering-shift = (
              (
                usable-width - first-left - last-left - last-visible-width - 2 * nav-item-x-inset
              )
                / 2
            )
            for (idx, title) in titles.enumerate() {
              place(
                top + left,
                dx: nav-margin + centering-shift + relative-lefts.at(idx),
                dy: nav-top,
                nav-item(title, item-width),
              )
            }
          })
        }
      },
    ),
    if slide-title != none {
      block(
        width: w,
        height: 25.5pt,
        fill: secondary,
        inset: (left: _single-col-x-margin, right: _single-col-x-margin, top: 0pt, bottom: 0pt),
        block(
          width: 100%,
          height: 100%,
          align(horizon, align(left, text(font: _sans, fill: hfc2, size: 14pt, slide-title))),
        ),
      )
    },
  )
}
#let _footer-band(
  w,
  left-top,
  right-top,
  left-bottom,
  page-no,
  primary,
  secondary,
  header-font-color-1: auto,
  header-font-color-2: auto,
  header-font-color-1-highlight: white,
) = {
  let hfc1 = if header-font-color-1 == auto { _muted-nav(primary) } else { header-font-color-1 }
  let hfc2 = if header-font-color-2 == auto { primary } else { header-font-color-2 }
  stack(
    dir: ttb,
    spacing: 0pt,
    block(width: w, height: 14.1pt, fill: secondary, inset: (left: 22.4pt, right: 22.4pt, top: 0pt, bottom: 0pt), {
      grid(
        columns: (1fr, 36%),
        column-gutter: 10pt,
        block(
          width: 100%,
          height: 100%,
          align(horizon, align(left, if _single-line(left-top) != none {
            text(font: _sans, fill: hfc2, size: 7pt, _single-line(left-top))
          } else { [] })),
        ),
        block(
          width: 100%,
          height: 100%,
          align(horizon, align(right, if _single-line(right-top) != none {
            text(font: _sans, fill: hfc2, size: 7pt, _single-line(right-top))
          } else { [] })),
        ),
      )
    }),
    block(width: w, height: 15.51pt, fill: primary, inset: (left: 22.4pt, right: 22.4pt, top: 0pt, bottom: 0pt), {
      grid(
        columns: (1fr, 36%),
        column-gutter: 10pt,
        block(
          width: 100%,
          height: 100%,
          align(horizon, align(left, if _single-line(left-bottom) != none {
            move(dy: 0pt, text(font: _sans, fill: hfc1, size: 7pt, _single-line(left-bottom)))
          } else { [] })),
        ),
        block(
          width: 100%,
          height: 100%,
          align(horizon, align(right, move(dy: 0.2pt, text(
            font: _sans,
            fill: hfc1,
            size: 6.8pt,
            _single-line(page-no),
          )))),
        ),
      )
    }),
  )
}

#let _slide-body-area(w, h, body) = context {
  let center = _clamp01(_baf-cctr.get())
  let upper = _clamp01(_baf-cupad.get())
  let lower = _clamp01(_baf-clpad.get())
  let usable-ratio = calc.max(0, 1 - upper - lower)

  block(
    width: w,
    height: h,
    inset: (x: _single-col-x-margin, y: 0pt),
    clip: true,
    layout(size => {
      let content-width = size.width
      let inner-top = size.height * upper
      let inner-height = size.height * usable-ratio
      let content = block(width: content-width, body)
      let measured = measure(content)
      let free-height = calc.max(0pt, inner-height - measured.height)
      let dy = inner-top + if center <= 0 { 0pt } else { free-height * center }
      place(top + left, dy: dy, content)
    }),
  )
}

// ============================================================
// Public API -- layout helpers
// ============================================================

/// Two-column layout inside a slide.
/// #two-col([left content], [right content], left-width: 50%)
#let two-col(left, right, gutter: 22.4pt, left-width: 48%) = {
  block(
    width: 100%,
    grid(
      columns: (left-width, 1fr),
      column-gutter: gutter,
      grid.cell(align: top + start)[#left],
      grid.cell(align: top + start)[#right],
    ),
  )
}

// ============================================================
// Figure
// ============================================================

#let _visual-y-margin = 15.75pt
#let _caption-gap = 2.3pt
#let _diagram-caption-gap = _caption-gap
#let _table-caption-gap = 6pt
#let _table-after-caption-margin = _visual-y-margin

/// Generic visual block without a caption.
#let baf-visual(body) = block(
  width: 100%,
  above: _visual-y-margin,
  below: _visual-y-margin,
  align(center, body),
)

/// Cell helper for grid-built tables. Uses the template's table font.
#let baf-table-cell(body, fill: none, stroke: none, pos: left, inset: (x: 5pt, y: 4pt)) = block(
  width: 100%,
  fill: fill,
  stroke: stroke,
  inset: inset,
  align(pos, text(font: _sans, body)),
)

/// Numbered figure with optional italic caption.
/// Counters reset per section.
#let baf-figure(body, caption: none, caption-gap: _caption-gap) = {
  _fig-ctr.step()
  block(above: _visual-y-margin, below: _visual-y-margin, spacing: 0pt, width: 100%, {
    align(center, body)
    if caption != none {
      v(caption-gap)
      align(center, context text(size: 0.72em, style: "italic", [*Figure #_fig-ctr.display().* #caption]))
    }
  })
}

/// Diagram figure with template-level caption spacing.
#let baf-diagram(body, caption: none) = baf-figure(
  caption: caption,
  caption-gap: _diagram-caption-gap,
  body,
)

// ============================================================
// Theorem-style boxes
// ============================================================
#let _panel-box(type-label, title, color, body, body-fill: none, width: 100%) = block(
  width: width,
  breakable: false,
  above: _visual-y-margin,
  below: _visual-y-margin,
  stroke: color + 0.8pt,
  fill: body-fill,
  inset: 0pt,
  spacing: 0pt,
  align(top + left, stack(
    dir: ttb,
    spacing: 0pt,
    if title != none {
      grid(
        columns: (auto, 1fr),
        column-gutter: 0pt,
        block(
          fill: color,
          inset: (left: 5pt, right: 5pt, top: 3.5pt, bottom: 5.3pt),
          text(font: _sans, fill: white, weight: "bold", size: 0.80em, type-label),
        ),
        block(
          fill: _sub-hdr(color),
          inset: (left: 5pt, right: 5pt, top: 3.5pt, bottom: 5.3pt),
          width: 100%,
          text(font: _sans, fill: white, size: 0.80em, title),
        ),
      )
    } else {
      block(
        width: 100%,
        fill: color,
        inset: (left: 5pt, right: 5pt, top: 3.5pt, bottom: 5.3pt),
        text(font: _sans, fill: white, weight: "bold", size: 0.80em, type-label),
      )
    },
    if body-fill != none {
      block(width: 100%, height: 1.2pt, fill: body-fill)
    },
    block(
      width: 100%,
      inset: (left: 5pt, right: 5pt, top: 5pt, bottom: 7pt),
      fill: body-fill,
      align(left, body),
    ),
  )),
)

#let _tbox(kind, name, color, body, width: 100%) = {
  let ctr = _thm-ctrs.at(kind, default: _thm-ctrs.theorem)
  ctr.step()
  let cap = upper(kind.first()) + kind.slice(1)
  context {
    let sec = _sec-ctr.get().first()
    let num = ctr.get().first()
    _panel-box([#cap #sec.#num], name, color, body, width: width)
  }
}

/// Theorem box
#let theorem(name: none, color: blue.darken(50%), width: 100%, body) = {
  _tbox("theorem", name, color, body, width: width)
}
/// Lemma box
#let lemma(name: none, color: blue.darken(30%), width: 100%, body) = { _tbox("lemma", name, color, body, width: width) }
/// Corollary box
#let corollary(name: none, color: blue.darken(40%), width: 100%, body) = {
  _tbox("corollary", name, color, body, width: width)
}
/// Proposition box
#let proposition(name: none, color: teal.darken(30%), width: 100%, body) = {
  _tbox("proposition", name, color, body, width: width)
}
/// Definition box
#let definition(name: none, color: purple.darken(20%), width: 100%, body) = {
  _tbox("definition", name, color, body, width: width)
}
/// Example box
#let example(name: none, color: green.darken(30%), width: 100%, body) = {
  _tbox("example", name, color, body, width: width)
}
/// Exercise box
#let exercise(name: none, color: orange.darken(20%), width: 100%, body) = {
  _tbox("exercise", name, color, body, width: width)
}
/// Remark box
#let remark(name: none, color: luma(90), width: 100%, body) = { _tbox("remark", name, color, body, width: width) }

/// Generic custom box -- any kind label and color.
/// #baf-box("warning", name: "Watch out", color: red)[...]
#let baf-box(kind, name: none, color: blue.darken(50%), width: 100%, body) = {
  _tbox(kind, name, color, body, width: width)
}

/// Full-width separator for use inside theorem-style boxes.
#let box-separator(label, color: luma(80)) = {
  v(5pt)
  move(
    dx: -5pt,
    block(
      width: 100% + 10pt,
      fill: color,
      inset: (x: 5pt, y: 3pt),
      text(font: _sans, fill: white, weight: "bold", size: 0.80em, label),
    ),
  )
  v(5pt)
}

/// Display equation with the same vertical rhythm as visual boxes.
#let baf-equation(body) = block(
  width: 100%,
  above: _visual-y-margin,
  below: _visual-y-margin,
  align(center, body),
)

/// Proof environment with QED box.
#let proof(width: 100%, body) = {
  block(
    width: width,
    inset: (x: 6pt, y: 5pt),
    above: _visual-y-margin,
    below: _visual-y-margin,
    stroke: (left: luma(80) + 2pt),
    spacing: 0.4em,
    align(left, text(style: "italic", [_Proof._ ]) + body + h(1fr) + box(width: 6pt, height: 6pt, fill: luma(80))),
  )
}

// ============================================================
// Code and pseudo-code boxes
// ============================================================

/// Generic code-style box with theorem-like header.
/// #code-box("print('hi')", type: "Code", title: "Python", lang: "python")
#let code-box(
  code,
  type: "Code",
  title: none,
  lang: none,
  color: blue.darken(50%),
  fill: luma(245),
  text-size: 8pt,
) = {
  _panel-box(
    type,
    title,
    color,
    block(
      width: 100%,
      inset: 0pt,
      spacing: 0pt,
      move(
        dy: -1.6pt,
        text(
          font: _mono,
          size: text-size,
          if lang == none { raw(code) } else { raw(lang: lang, code) },
        ),
      ),
    ),
    body-fill: fill,
  )
}

/// Pseudo-code box with theorem-like header.
/// #pseudo-code("for i <- 1 to n", title: "Mini-Batch SGD")
#let pseudo-code(
  code,
  type: "Pseudo-code",
  title: none,
  color: teal.darken(30%),
  fill: luma(252),
  text-size: 8pt,
) = {
  code-box(
    code,
    type: type,
    title: title,
    color: color,
    fill: fill,
    text-size: text-size,
  )
}

// ============================================================
// Section management
// ============================================================

/// Register a subsection in the TOC (does not create a slide).
#let new-subsection(title) = {
  _toc-data.update(t => t + ((kind: "sub", title: title),))
}

// ============================================================
// Slide functions
// ============================================================

/// Standard content slide.
/// #slide(title: "My Slide")[Content]
#let slide(title: none, section: auto, show-title-band: auto, body) = {
  context {
    let tc = _baf-tc.get()
    let sc = _baf-sc.get()
    let bg = _baf-bg.get()
    let w = _baf-w.get()
    let h = _baf-h.get()
    let ft = _baf-ft.get()
    let auth = _baf-auth.get()
    let inst = _baf-inst.get()
    let hfc1 = _baf-hfc1.get()
    let hfc2 = _baf-hfc2.get()
    let hfc1h = _baf-hfc1h.get()
    let cur = _cur-sec.get()
    let sec = if section == auto { cur } else { section }
    let header-title = if show-title-band == auto {
      if sec == none or sec == "" { none } else { title }
    } else if show-title-band and title != none {
      title
    } else {
      none
    }

    let header-h = if header-title == none { 24.75pt } else { 50.25pt }
    let footer-h = 29.61pt
    let avail = h - header-h - footer-h
    let slide-loc = here()
    _register-section-target(sec, slide-loc)
    _register-page(section: sec)

    page(
      width: w,
      height: h,
      margin: 0pt,
      background: rect(width: 100%, height: 100%, fill: bg),
      header: none,
      footer: none,
      {
        place(
          top + left,
          float: false,
          _header-band(
            w,
            if sec == none { "" } else { sec },
            slide-title: header-title,
            tc,
            sc,
            header-font-color-1: hfc1,
            header-font-color-2: hfc2,
            header-font-color-1-highlight: hfc1h,
          ),
        )
        place(
          bottom + left,
          float: false,
          _footer-band(
            w,
            auth,
            inst,
            ft,
            counter(page).display() + " / " + str(counter(page).final().first()),
            tc,
            sc,
            header-font-color-1: hfc1,
            header-font-color-2: hfc2,
            header-font-color-1-highlight: hfc1h,
          ),
        )
        place(
          top + left,
          dy: header-h,
          float: false,
          _slide-body-area(w, avail, body),
        )
      },
    )
  }
}

/// Section divider slide (typically called right after new-section).
#let section-slide(sec-title) = {
  context {
    let tc = _baf-tc.get()
    let sc = _baf-sc.get()
    let bg = _baf-bg.get()
    let w = _baf-w.get()
    let h = _baf-h.get()
    let ft = _baf-ft.get()
    let auth = _baf-auth.get()
    let inst = _baf-inst.get()
    let hfc1 = _baf-hfc1.get()
    let hfc2 = _baf-hfc2.get()
    let hfc1h = _baf-hfc1h.get()
    let nav-sec = {
      let cur = _cur-sec.get()
      if cur == none or cur == "" { sec-title } else { cur }
    }
    let sec-loc = here()
    _register-page(section: nav-sec, intro: true)
    _register-section-target(nav-sec, sec-loc)

    page(
      width: w,
      height: h,
      margin: 0pt,
      background: rect(width: 100%, height: 100%, fill: bg),
      header: none,
      footer: none,
      {
        place(
          top + left,
          float: false,
          _header-band(
            w,
            nav-sec,
            tc,
            sc,
            header-font-color-1: hfc1,
            header-font-color-2: hfc2,
            header-font-color-1-highlight: hfc1h,
          ),
        )
        place(
          bottom + left,
          float: false,
          _footer-band(
            w,
            auth,
            inst,
            ft,
            counter(page).display() + " / " + str(counter(page).final().first()),
            tc,
            sc,
            header-font-color-1: hfc1,
            header-font-color-2: hfc2,
            header-font-color-1-highlight: hfc1h,
          ),
        )
        block(
          width: w,
          height: h - 24.75pt - 29.61pt,
          align(center + horizon, block(
            width: 65%,
            stroke: tc + 0.8pt,
            inset: 0pt,
            {
              block(
                width: 100%,
                fill: tc,
                inset: (x: 12pt, y: 4pt),
                context {
                  let n = _sec-ctr.get().first()
                  text(font: _sans, fill: hfc1h, size: 8pt, [Section #n])
                },
              )
              block(
                width: 100%,
                height: 38pt,
                inset: (x: 12pt, y: 0pt),
                align(horizon, move(dy: -3pt, text(font: _sans, size: 15pt, weight: "bold", fill: tc, sec-title))),
              )
            },
          )),
        )
      },
    )
  }
}

/// Declare a new section and render its intro slide.
#let new-section(title, slide-title: auto) = {
  _sec-ctr.step()
  for (_, c) in _thm-ctrs { c.update(0) }
  _fig-ctr.update(0)
  _cur-sec.update(title)
  _toc-data.update(t => t + ((kind: "section", title: title),))
  section-slide(if slide-title == auto { title } else { slide-title })
}

/// Final message slide.
#let final-slide = context {
  let tc = _baf-tc.get()
  let sc = _baf-sc.get()
  let bg = _baf-bg.get()
  let w = _baf-w.get()
  let h = _baf-h.get()
  let ft = _baf-ft.get()
  let auth = _baf-auth.get()
  let inst = _baf-inst.get()
  let hfc1 = _baf-hfc1.get()
  let hfc2 = _baf-hfc2.get()
  let hfc1h = _baf-hfc1h.get()
  let final-message = _baf-final.get()
  _register-page()

  page(
    width: w,
    height: h,
    margin: 0pt,
    background: rect(width: 100%, height: 100%, fill: bg),
    header: none,
    footer: none,
    {
      place(
        top + left,
        float: false,
        _header-band(
          w,
          "",
          tc,
          sc,
          header-font-color-1: hfc1,
          header-font-color-2: hfc2,
          header-font-color-1-highlight: hfc1h,
        ),
      )
      place(
        bottom + left,
        float: false,
        _footer-band(
          w,
          auth,
          inst,
          ft,
          counter(page).display() + " / " + str(counter(page).final().first()),
          tc,
          sc,
          header-font-color-1: hfc1,
          header-font-color-2: hfc2,
          header-font-color-1-highlight: hfc1h,
        ),
      )
      block(
        width: w,
        height: h - 24.75pt - 29.61pt,
        align(center + horizon, text(font: _serif, size: 24pt, style: "italic", fill: tc, final-message)),
      )
    },
  )
}

// ============================================================
// Main entry point  --  use via:
//   #show: black-angular-frame.with(config: (title: "...", ...))
// ============================================================
#let black-angular-frame(
  config: (:),
  title: none,
  subtitle: none,
  institution: none,
  institute: none,
  date: none,
  authors: none,
  final-message: none,
  primary-color: none,
  secondary-color: none,
  background-color: none,
  font-color: none,
  header-font-color-1: none,
  header-font-color-2: none,
  header-font-color-1-highlight: none,
  content-center: none,
  content-upper-padding: none,
  content-lower-padding: none,
  logos: none,
  ratio: 16 / 9,
  title-color: none,
  bg-color: none,
  toc: none,
  footer-title: auto,
  footer-subtitle: auto,
  logo: none,
  cover-images: none,
  cover-image-height: 45pt,
  body,
) = {
  let cfg-title = config.at("title", default: if title == none { "" } else { title })
  let cfg-subtitle = config.at("subtitle", default: if subtitle == none { "" } else { subtitle })
  let cfg-authors = config.at("authors", default: if authors == none { "" } else { authors })
  let cfg-institution = config.at(
    "institution",
    default: if institution != none { institution } else if institute != none { institute } else { "" },
  )
  let cfg-date = config.at("date", default: if date == none { "" } else { date })
  let cfg-final-message = config.at(
    "final-message",
    default: if final-message == none { "" } else { final-message },
  )
  let cfg-primary = config.at(
    "primary-color",
    default: if primary-color != none { primary-color } else if title-color != none { title-color } else {
      rgb("#1C1C1C")
    },
  )
  let cfg-secondary = config.at(
    "secondary-color",
    default: if secondary-color == none { rgb("#D9D9D9") } else { secondary-color },
  )
  let cfg-background = config.at(
    "background-color",
    default: if background-color != none { background-color } else if bg-color != none { bg-color } else {
      rgb("#FFFFFF")
    },
  )
  let cfg-font-color = config.at(
    "font-color",
    default: if font-color == none { luma(20) } else { font-color },
  )
  let cfg-hfc1 = config.at(
    "header-font-color-1",
    default: if header-font-color-1 == none { _muted-nav(cfg-primary) } else { header-font-color-1 },
  )
  let cfg-hfc2 = config.at(
    "header-font-color-2",
    default: if header-font-color-2 == none { cfg-primary } else { header-font-color-2 },
  )
  let cfg-hfc1h = config.at(
    "header-font-color-1-highlight",
    default: if header-font-color-1-highlight == none { white } else { header-font-color-1-highlight },
  )
  let cfg-content-center = config.at(
    "content-center",
    default: if content-center == none { 0.3 } else { content-center },
  )
  let cfg-content-upper-padding = config.at(
    "content-upper-padding",
    default: if content-upper-padding == none { 0.05 } else { content-upper-padding },
  )
  let cfg-content-lower-padding = config.at(
    "content-lower-padding",
    default: if content-lower-padding == none { 0.05 } else { content-lower-padding },
  )
  let cfg-logos = config.at(
    "logos",
    default: if logos != none { logos } else if cover-images != none { cover-images } else if logo != none {
      (logo,)
    } else { () },
  )
  let cfg-toc = config.at("TOC", default: if toc == none { true } else { toc })

  let ft = if footer-title == auto { cfg-title } else { footer-title }
  let fst = if footer-subtitle == auto { cfg-subtitle } else { footer-subtitle }
  let inst = if cfg-institution == "" { none } else { cfg-institution }
  let subt = if cfg-subtitle == "" { none } else { cfg-subtitle }
  let date-text = if cfg-date == "" { none } else { cfg-date }
  let cover-imgs = if cfg-logos == none {
    ()
  } else if type(cfg-logos) == array {
    cfg-logos
  } else {
    (cfg-logos,)
  }
  let auth = if cfg-authors != "" and cfg-authors != none {
    let al = if type(cfg-authors) == array { cfg-authors } else { (cfg-authors,) }
    al.join([,  ])
  } else { none }

  let w = if ratio > (16 / 9 - 0.01) { 254mm } else { 190mm }
  let h = w / ratio

  // Push config into state so slide() can read it contextually
  _baf-tc.update(cfg-primary)
  _baf-sc.update(cfg-secondary)
  _baf-bg.update(cfg-background)
  _baf-w.update(w)
  _baf-h.update(h)
  _baf-ft.update(ft)
  _baf-fst.update(fst)
  _baf-title.update(cfg-title)
  _baf-subt.update(cfg-subtitle)
  _baf-inst.update(inst)
  _baf-auth.update(auth)
  _baf-fc.update(cfg-font-color)
  _baf-hfc1.update(cfg-hfc1)
  _baf-hfc2.update(cfg-hfc2)
  _baf-hfc1h.update(cfg-hfc1h)
  _baf-final.update(cfg-final-message)
  _baf-cctr.update(cfg-content-center)
  _baf-cupad.update(cfg-content-upper-padding)
  _baf-clpad.update(cfg-content-lower-padding)

  // Global text defaults
  set text(font: _serif, size: 10.5pt, fill: cfg-font-color)
  set figure(gap: _caption-gap)
  show figure.where(kind: table): it => block(
    above: _visual-y-margin,
    below: _table-after-caption-margin,
    {
      set figure(gap: _table-caption-gap)
      it
    },
  )
  show figure.caption.where(kind: table): it => {
    v(_table-caption-gap)
    align(center, text(size: 0.72em, style: "italic", [*#it.supplement #it.counter.display().* #it.body]))
  }
  show table.cell: set text(font: _sans)
  show table: it => figure(kind: table, caption: [Table caption.], gap: _table-caption-gap, it)
  set par(justify: true, leading: 0.55em, spacing: 0.65em)
  set list(indent: 6pt)
  set enum(indent: 6pt)
  set page(width: w, height: h, margin: 0pt, header: none, footer: none)

  // ---- Title slide -----------------------------------------
  page(
    width: w,
    height: h,
    margin: 0pt,
    background: rect(width: 100%, height: 100%, fill: cfg-background),
    header: none,
    footer: none,
    {
      _register-page()
      place(
        top + left,
        float: false,
        _header-band(
          w,
          "",
          cfg-primary,
          cfg-secondary,
          header-font-color-1: cfg-hfc1,
          header-font-color-2: cfg-hfc2,
          header-font-color-1-highlight: cfg-hfc1h,
        ),
      )
      place(
        bottom + left,
        float: false,
        _footer-band(
          w,
          auth,
          inst,
          ft,
          context counter(page).display() + " / " + str(counter(page).final().first()),
          cfg-primary,
          cfg-secondary,
          header-font-color-1: cfg-hfc1,
          header-font-color-2: cfg-hfc2,
          header-font-color-1-highlight: cfg-hfc1h,
        ),
      )
      block(
        width: w,
        height: h - 24.75pt - 29.61pt,
        align(center + horizon, {
          block(
            width: 84%,
            fill: cfg-primary,
            inset: (x: 14pt, y: 10pt),
            align(center + horizon, {
              set text(font: _sans, fill: cfg-hfc1h)
              text(size: 19pt, cfg-title)
              if subt != none {
                linebreak()
                v(4pt)
                text(size: 11pt, subt)
              }
            }),
          )
          v(12pt)
          if auth != none {
            text(font: _sans, size: 11pt, auth)
            linebreak()
            v(6pt)
          }
          if inst != none {
            text(font: _sans, size: 9.5pt, inst)
            linebreak()
            v(6pt)
          }
          if date-text != none {
            text(font: _sans, size: 10pt, date-text)
            linebreak()
          }
          v(26pt)
          if cover-imgs != () {
            _cover-image-row(cover-imgs, height: cover-image-height)
          }
        }),
      )
    },
  )

  // ---- TOC slide -------------------------------------------
  if cfg-toc {
    slide(title: "Table of Contents", section: none, show-title-band: false, {
      context {
        let entries = _toc-data.final()
        let sec-targets = _baf-sec-targets.final()
        let sec-n = 0
        text(font: _sans, size: 14pt, weight: "bold", fill: cfg-primary, [Table of Contents])
        v(8pt)
        for e in entries {
          if e.kind == "section" {
            sec-n += 1
            let target = sec-targets.rev().find(entry => entry.title == e.title)
            let number-cell = box(
              width: 16pt,
              height: 16pt,
              fill: cfg-primary,
              align(center + horizon, text(font: _sans, fill: cfg-hfc1h, size: 8pt, weight: "bold", str(sec-n))),
            )
            let title-cell = align(left + horizon, text(
              font: _sans,
              size: 10pt,
              weight: "bold",
              fill: cfg-primary,
              e.title,
            ))
            v(3pt)
            grid(
              columns: (18pt, 1fr),
              column-gutter: 4pt,
              if target != none { link(target.at("loc"))[#number-cell] } else { number-cell },
              if target != none { link(target.at("loc"))[#title-cell] } else { title-cell },
            )
          } else {
            pad(left: 22pt, text(font: _sans, size: 9pt, fill: luma(40), "- " + e.title))
          }
        }
      }
    })
  }

  // ---- User content ----------------------------------------
  body
}
