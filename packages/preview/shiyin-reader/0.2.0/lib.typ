// A small, data-driven poetry book template.

#import "themes.typ": school, kindle, palettes, resolve-theme

#let _page-profile(format, theme: school) = {
  let paper = format.paper
  // Kindle Paperwhite 6th gen: 758 x 1024 px at 212 ppi = 90.8 x 122.7 mm.
  // A dedicated page size keeps the PDF at a 1:1 pixel mapping on device.
  let kindle-size = (width: 90.8mm, height: 122.7mm)
  let auto-margin = if paper == "kindle" {
    (left: 8mm, right: 8mm, top: 8mm, bottom: 7mm)
  } else if paper == "a6" {
    (left: 18mm, right: 14mm, top: 16mm, bottom: 15mm)
  } else if paper == "a5" {
    (left: 20mm, right: 17mm, top: 19mm, bottom: 18mm)
  } else {
    (left: 22mm, right: 20mm, top: 21mm, bottom: 20mm)
  }
  let auto-chapter-size = if paper == "kindle" {
    18pt
  } else if paper == "a6" {
    22pt
  } else if paper == "a5" {
    26pt
  } else {
    30pt
  }
  let theme-margin = if paper == "a4" and theme.at("margin-a4", default: none) != none {
    theme.margin-a4
  } else {
    theme.margin
  }
  // A design profile can pin the reading margins independently of the theme.
  let format-margin = if format.at("margin_left_pt", default: none) != none {
    (
      left: format.margin_left_pt * 1pt,
      right: format.margin_right_pt * 1pt,
      top: format.margin_top_pt * 1pt,
      bottom: format.margin_bottom_pt * 1pt,
    )
  } else {
    none
  }
  (
    paper: paper,
    page-args: if paper == "kindle" { kindle-size } else { (paper: paper) },
    width: if paper == "kindle" {
      kindle-size.width
    } else if paper == "a6" {
      105mm
    } else if paper == "a5" {
      148mm
    } else {
      210mm
    },
    height: if paper == "kindle" {
      kindle-size.height
    } else if paper == "a6" {
      148mm
    } else if paper == "a5" {
      210mm
    } else {
      297mm
    },
    margin: if format-margin != none {
      format-margin
    } else if theme-margin != none {
      theme-margin
    } else {
      auto-margin
    },
    title-size: if paper == "kindle" {
      15pt
    } else if paper == "a6" {
      16pt
    } else if paper == "a5" {
      18pt
    } else {
      20pt
    },
    chapter-size: if paper == "a4" and theme.at("chapter-size-a4", default: none) != none {
      theme.chapter-size-a4
    } else if theme.chapter-size != none {
      theme.chapter-size
    } else {
      auto-chapter-size
    },
    author-size: if paper == "kindle" {
      8pt
    } else if paper == "a6" {
      8.5pt
    } else {
      9.5pt
    },
    poem-gap: if paper == "kindle" {
      7pt
    } else if paper == "a6" {
      9pt
    } else if paper == "a5" {
      12pt
    } else {
      15pt
    },
  )
}

#let _vertical-text(
  value,
  size,
  fill: black,
  spacing: 0.1em,
  font: ("STKaiti", "KaiTi", "Noto Serif CJK SC"),
) = stack(
  dir: ttb,
  spacing: spacing,
  ..value.clusters().map(ch => text(
    font: font,
    size: size,
    fill: fill,
  )[#ch]),
)

// A poem line normally holds a couplet ("两个黄鹂鸣翠柳，一行白鹭上青天。").
// Two-column A5 pages are narrower than that couplet, so split at clause
// punctuation while keeping the mark on the preceding clause. Leading short
// exclamations (the three "鹅，" in 咏鹅) stay together with the next clause.
#let _split-clauses(line) = {
  let parts = ()
  let current = ""
  for ch in line.clusters() {
    current += ch
    if ch in ("，", "；", "：") {
      parts.push(current)
      current = ""
    }
  }
  if current != "" {
    parts.push(current)
  }
  if parts.len() <= 1 {
    return (line,)
  }
  let result = ()
  let index = 0
  while index < parts.len() {
    let part = parts.at(index)
    if part.codepoints().len() <= 2 and index + 1 < parts.len() {
      let merged = part
      let next = index + 1
      while next < parts.len() and parts.at(next).codepoints().len() <= 2 {
        merged += parts.at(next)
        next += 1
      }
      result.push(merged)
      index = next
    } else {
      result.push(part)
      index += 1
    }
  }
  result
}

// Split a pinyin pair array at the same clause boundaries as _split-clauses.
// Each pair belongs to exactly one hanzi (punctuation included), so the clause
// lengths give the slice offsets directly.
#let _split-py-clauses(pairs, clauses) = {
  let result = ()
  let offset = 0
  for clause in clauses {
    let next = offset + clause.codepoints().len()
    result.push(pairs.slice(offset, next))
    offset = next
  }
  result
}

#let _torn-band(color) = layout(size => {
  let w = size.width
  let h = size.height
  place(
    top + left,
    polygon(
      fill: color,
      (0pt, h * 0.615),
      (w * 0.03, h * 0.612),
      (w * 0.06, h * 0.617),
      (w * 0.09, h * 0.611),
      (w * 0.12, h * 0.616),
      (w * 0.15, h * 0.609),
      (w * 0.18, h * 0.613),
      (w * 0.21, h * 0.607),
      (w * 0.24, h * 0.612),
      (w * 0.27, h * 0.608),
      (w * 0.30, h * 0.614),
      (w * 0.33, h * 0.606),
      (w * 0.36, h * 0.611),
      (w * 0.39, h * 0.607),
      (w * 0.42, h * 0.613),
      (w * 0.45, h * 0.605),
      (w * 0.48, h * 0.610),
      (w * 0.51, h * 0.604),
      (w * 0.54, h * 0.609),
      (w * 0.57, h * 0.603),
      (w * 0.60, h * 0.608),
      (w * 0.63, h * 0.602),
      (w * 0.66, h * 0.607),
      (w * 0.69, h * 0.601),
      (w * 0.72, h * 0.606),
      (w * 0.75, h * 0.603),
      (w * 0.78, h * 0.608),
      (w * 0.81, h * 0.602),
      (w * 0.84, h * 0.607),
      (w * 0.87, h * 0.603),
      (w * 0.90, h * 0.609),
      (w * 0.93, h * 0.605),
      (w * 0.96, h * 0.610),
      (w, h * 0.607),
      (w, h),
      (0pt, h),
    ),
  )
})

#let _school-mark(book, width: 19mm, asset-root: "") = {
  let logo = book.at("branding", default: (:)).at("logo", default: "")
  if logo == "" or logo == none {
    none
  } else if type(logo) == str {
    let logo-path = if asset-root == "" { logo } else { asset-root + "/" + logo }
    image(logo-path, width: width)
  } else {
    logo
  }
}

#let _brand(book, key, default: "") = {
  book.at("branding", default: (:)).at(key, default: default)
}

#let _author-line(
  poem,
  size,
  font: ("STKaiti", "KaiTi", "Noto Serif CJK SC"),
  fill: luma(92),
) = if poem.author != "" {
  text(size: size, fill: fill, font: font)[
    #poem.author
  ]
}

#let _poem-pinyin(pinyin, poem) = if pinyin == none {
  none
} else {
  pinyin.poems.at(poem.at("poem_id", default: ""), default: none)
}

// Each character is its own box so pinyin can overhang neighbouring glyphs
// while the line still breaks between characters in long prose passages.
#let _ruby-line(
  chars,
  size: 1em,
  py-size: 0.55em,
  hanzi-font: ("Noto Serif CJK SC", "SimSun"),
  py-font: ("Noto Sans CJK SC", "Noto Serif CJK SC"),
  hanzi-fill: black,
  py-fill: luma(95),
  box-height: 1.55,
) = context {
  let index = 0
  while index < chars.len() {
    let hanzi = chars.at(index).at(0)
    let reading = chars.at(index).at(1)
    index += 1
    // Attach punctuation and other unannotated glyphs to the preceding box so
    // a closing mark never starts a wrapped line of prose.
    let trailing = ""
    while index < chars.len() and chars.at(index).at(1) == "" {
      trailing += chars.at(index).at(0)
      index += 1
    }
    let hz = text(font: hanzi-font, size: size, fill: hanzi-fill)[#hanzi]
    let trail = text(font: hanzi-font, size: size, fill: hanzi-fill)[#trailing]
    let py = if reading == "" {
      none
    } else {
      text(font: py-font, size: py-size, fill: py-fill)[#reading#h(0.18em)]
    }
    let hz-width = measure(hz).width
    let py-width = if py == none { 0pt } else { measure(py).width }
    let trail-width = measure(trail).width
    let char-width = calc.max(hz-width, py-width) + 0.02 * size
    box(
      width: char-width + trail-width,
      height: box-height * size,
      align(left + bottom)[
        #if py != none {
          place(top + left, dx: (char-width - py-width) / 2)[#py]
        }
        #box(
          width: char-width,
          height: box-height * size,
          align(center + bottom)[#hz],
        )
        #place(left + bottom, dx: char-width)[#trail]
      ],
    )
  }
}

// The visible title is ruby; the outline entry is a transparent copy of the
// same heading. _toc-page recolours that copy so the contents stay readable.
#let _pinyin-title(
  poem,
  py-data,
  size: 18pt,
  py-size: 8pt,
  title-font: ("STKaiti", "KaiTi", "Noto Serif CJK SC"),
  fill: rgb("#B33A20"),
  py-fill: luma(105),
) = block(width: 100%, height: 1.62 * size)[
  #place(center + top)[
    #_ruby-line(
      ((str(poem.number) + "．", ""),),
      size: size,
      py-size: py-size,
      hanzi-font: title-font,
      hanzi-fill: fill,
      box-height: 1.62,
    )
    #_ruby-line(
      py-data.title,
      size: size,
      py-size: py-size,
      hanzi-font: title-font,
      hanzi-fill: fill,
      py-fill: py-fill,
      box-height: 1.62,
    )
  ]
  #place(center + bottom)[
    #heading(level: 4, outlined: true, bookmarked: true)[
      #text(fill: rgb(0, 0, 0, 0))[#poem.number．#poem.title]
    ]
  ]
]

#let _short-notes(
  notes,
  size,
  theme: school,
  rule: none,
  label: none,
  leading: none,
  compact: false,
) = if notes.len() > 0 {
  let use-rule = if rule == none { theme.note-rule } else { rule }
  let use-label = if label == none { theme.note-label } else { label }
  if use-rule {
    v(if compact { 0.5em } else { 0.65em })
    line(length: 100%, stroke: 0.6pt + theme.rule-fill)
    v(if compact { 0.2em } else { 0.35em })
  } else {
    v(if compact { 0.2em } else { 0.35em })
  }
  // `set par` must be unconditional inside the content block: wrapping it in
  // `if` (or leaving it at function-call level) stops it from reaching the
  // following loop, which silently left note leading at the default.
  let note-leading = if leading == none { 0.65 } else { leading }
  block(width: 100%)[
    // Notes stay flush left even when the poem panel is centred (two-up large
    // print), so multi-line notes do not get a ragged centre axis.
    #set align(left)
    #set par(leading: note-leading * 1em)
    #for (index, note) in notes.enumerate() {
      text(font: theme.body-font, size: size, fill: theme.note-fill)[
        #if use-label [注#(index + 1)　]
        #note.headword：#note.text
      ]
      linebreak()
    }
  ]
}

#let _poem-block(
  poem,
  format,
  note-mode,
  profile,
  pinyin: none,
  pinyin-mode: false,
  body-font: ("Noto Serif CJK SC", "SimSun"),
  title-font: ("STKaiti", "KaiTi", "Noto Serif CJK SC"),
  theme: school,
  compact: false,
) = {
  let py-data = _poem-pinyin(pinyin, poem)
  let use-pinyin = pinyin-mode and py-data != none
  let title-size = format.at("title_size", default: 16) * 1pt
  let title-py-size = format.at("title_pinyin_size", default: 8) * 1pt
  let author-size = format.at("author_size", default: 9.5) * 1pt
  let author-py-size = format.at("author_pinyin_size", default: 6.6) * 1pt
  let body-size = format.body_size * 1pt
  let body-py-size = format.at("pinyin_size", default: 7.7) * 1pt
  // School theme: three independent gaps.
  // 1) title -> author, 2) author -> body (pinyin needs more room for ruby),
  // 3) extra paragraph gap for long, left-aligned texts (pinyin is looser).
  let title-author-gap = if theme.name != "school" { 0.35 * body-size } else { 0.42em }
  let author-body-gap = if theme.name != "school" {
    0.55 * body-size
  } else if pinyin-mode {
    0.35em
  } else {
    0.12em
  }
  // Dense-page mode only tightens auxiliary spacing. Body size, leading and
  // pinyin stay at the large-print values so the poem itself remains 24pt.
  if compact {
    title-author-gap *= 0.75
    author-body-gap *= 0.75
  }
  let long-paragraph-gap = if pinyin-mode { 0.40em } else { 0.7em }
  let page-width = profile.width
  let content-width = page-width - profile.margin.left - profile.margin.right
  let column-width = if format.columns == 2 {
    (content-width - format.gutter_pt * 1pt) / 2
  } else {
    content-width
  }
  // A5 two-column columns are narrower than a seven-character couplet, so split
  // at clause punctuation. A4 two-column columns are wide enough to keep the
  // couplet on one line.
  let long-couplet = poem.lines.any(line => line.codepoints().len() > 16)
  // Kindle single-column pinyin pages are narrow: a seven-character couplet
  // plus its ruby overhang can exceed the text width. Split at clause
  // punctuation, and split the pinyin pairs at the same boundaries.
  let split-clauses = (
    theme.split-clauses and format.columns == 2 and not pinyin-mode and (column-width < 55mm or long-couplet)
  ) or (profile.paper == "kindle" and pinyin-mode)
  let display-lines = if split-clauses {
    poem.lines.map(_split-clauses).flatten()
  } else {
    poem.lines
  }
  let py-lines = if use-pinyin { py-data.at("lines", default: none) } else { none }
  let display-items = if split-clauses {
    poem.lines.enumerate().map(pair => {
      let index = pair.at(0)
      let clauses = _split-clauses(pair.at(1))
      let pairs = if py-lines != none and index < py-lines.len() {
        _split-py-clauses(py-lines.at(index), clauses)
      } else {
        none
      }
      clauses.enumerate().map(item => (
        text: item.at(1),
        py: if pairs != none { pairs.at(item.at(0)) } else { none },
      ))
    }).flatten()
  } else {
    poem.lines.enumerate().map(pair => (
      text: pair.at(1),
      py: if py-lines != none and pair.at(0) < py-lines.len() {
        py-lines.at(pair.at(0))
      } else {
        none
      },
    ))
  }
  context {
    // A poem is long when at least one of its display lines would wrap in the
    // current column. In two-column Kami editions the couplets are split into
    // clauses first, so a normal quatrain stays a centred short poem.
    let is-long = if profile.paper == "kindle" and split-clauses {
      false
    } else if split-clauses {
      poem.at("is_long", default: false) or display-lines.any(line => {
        measure(text(font: body-font, size: body-size)[#line]).width > column-width
      })
    } else {
      poem.lines.any(line => line.codepoints().len() > 28) or poem.lines.enumerate().any(pair => {
        let index = pair.at(0)
        let line = pair.at(1)
        let item = if use-pinyin and py-data.at("lines", default: none) != none {
          _ruby-line(
            py-data.lines.at(index),
            size: body-size,
            py-size: body-py-size,
            hanzi-font: body-font,
            hanzi-fill: theme.text-fill,
            py-fill: theme.pinyin-fill,
            box-height: 1.55,
          )
        } else {
          text(font: body-font, size: body-size, fill: theme.text-fill)[#line]
        }
        measure(item).width > column-width
      })
    }
    let kami-title-size = format.at("poem_title_size", default: 16) * 1pt
    let title-parts = poem.title.split("（")
    let has-title-note = title-parts.len() > 1
    let title-main = title-parts.at(0)
    let title-note = if has-title-note {
      "（" + title-parts.slice(1).join("（")
    } else {
      ""
    }
    let title-full-measure = measure(
      text(
        font: title-font,
        size: kami-title-size,
        weight: theme.title-weight,
      )[#(str(poem.number) + "．" + poem.title)],
    ).width
    let full-title-fits = title-full-measure <= column-width
    let fitted-one-line-size = if full-title-fits {
      kami-title-size
    } else {
      let fitted = kami-title-size * (column-width / title-full-measure)
      if fitted > 10.5pt { fitted } else { 10.5pt }
    }
    let slight-shrink = not full-title-fits and fitted-one-line-size >= 0.95 * kami-title-size
    let split-title = has-title-note and not full-title-fits
    let two-line-title = not full-title-fits and not has-title-note and not slight-shrink
    let title-main-measure = measure(
      text(
        font: title-font,
        size: kami-title-size,
        weight: theme.title-weight,
      )[#(str(poem.number) + "．" + title-main)],
    ).width
    let parenthetical-size = if split-title and title-main-measure > column-width {
      let fitted = kami-title-size * (column-width / title-main-measure) * 0.98
      if fitted > 13pt { fitted } else { 13pt }
    } else {
      kami-title-size
    }
    let title-chars = poem.title.clusters()
    let title-mid = if title-chars.len() < 2 {
      1
    } else {
      int(calc.ceil(title-chars.len() / 2))
    }
    let title-split-index = if title-mid < 1 {
      1
    } else if title-mid >= title-chars.len() {
      title-chars.len() - 1
    } else if title-chars.at(title-mid - 1) == "日" {
      title-mid
    } else if title-chars.at(title-mid) == "日" {
      title-mid + 1
    } else {
      title-mid
    }
    let title-dot-parts = poem.title.split("·")
    let title-line-1 = if title-dot-parts.len() > 1 {
      title-dot-parts.at(0) + "·"
    } else {
      title-chars.slice(0, title-split-index).join("")
    }
    let title-line-2 = if title-dot-parts.len() > 1 {
      title-dot-parts.slice(1).join("·")
    } else {
      title-chars.slice(title-split-index, title-chars.len()).join("")
    }
    let title-line-1-measure = measure(
      text(
        font: title-font,
        size: kami-title-size,
        weight: theme.title-weight,
      )[#(str(poem.number) + "．" + title-line-1)],
    ).width
    let title-line-2-measure = measure(
      text(
        font: title-font,
        size: kami-title-size,
        weight: theme.title-weight,
      )[#title-line-2],
    ).width
    let two-line-measure = if title-line-1-measure > title-line-2-measure {
      title-line-1-measure
    } else {
      title-line-2-measure
    }
    let two-line-size = if two-line-measure > column-width {
      let fitted = kami-title-size * (column-width / two-line-measure) * 0.98
      if fitted > 13pt { fitted } else { 13pt }
    } else {
      kami-title-size
    }
    let one-line-title-size = if slight-shrink {
      fitted-one-line-size * 0.98
    } else {
      kami-title-size
    }
    let keep-core = profile.paper == "kindle" and not is-long and poem.lines.len() <= 4
    let poem-gap = if format.at("poem_gap", default: none) != none {
      format.poem_gap * 1pt
    } else {
      profile.poem-gap
    }
    let core = [
      #v(if profile.paper == "kindle" { 0pt } else if theme.name != "school" { 1.2 * body-size } else { 0pt })
      #block(sticky: true, width: 100%)[
        #align(center)[
          #if use-pinyin and py-data.at("title", default: none) != none {
            _pinyin-title(
              poem,
              py-data,
              size: title-size,
              py-size: title-py-size,
              title-font: title-font,
              fill: theme.title-fill,
              py-fill: theme.title-pinyin-fill,
            )
          } else if theme.name != "school" {
            if split-title {
              text(
                font: title-font,
                size: parenthetical-size,
                fill: theme.title-fill,
                weight: theme.title-weight,
              )[#poem.number．#title-main]
              linebreak()
              text(
                font: title-font,
                size: 0.8 * parenthetical-size,
                fill: theme.author-fill,
                weight: theme.title-weight,
              )[#title-note]
            } else if two-line-title {
              text(
                font: title-font,
                size: two-line-size,
                fill: theme.title-fill,
                weight: theme.title-weight,
              )[#poem.number．#title-line-1]
              linebreak()
              text(
                font: title-font,
                size: two-line-size,
                fill: theme.title-fill,
                weight: theme.title-weight,
              )[#title-line-2]
            } else {
              text(
                font: title-font,
                size: one-line-title-size,
                fill: theme.title-fill,
                weight: theme.title-weight,
              )[#poem.number．#poem.title]
            }
            place(center + bottom)[
              #heading(level: 4, outlined: true, bookmarked: true)[
                #text(fill: rgb(0, 0, 0, 0))[#poem.number．#poem.title]
              ]
            ]
          } else {
            heading(level: 4, outlined: true, bookmarked: true)[
              #poem.number．#poem.title
            ]
          }
          #if poem.at("poem_id", default: "") != "" {
            label("poem-" + poem.poem_id)
          }
          #v(title-author-gap)
          #if use-pinyin and py-data.at("author", default: none) != none {
            _ruby-line(
              py-data.author,
              size: author-size,
              py-size: author-py-size,
              hanzi-font: title-font,
              hanzi-fill: theme.author-fill,
              py-fill: theme.author-pinyin-fill,
              box-height: 1.55,
            )
          } else {
            _author-line(poem, author-size, font: theme.serif, fill: theme.author-fill)
          }
          #v(author-body-gap)
        ]
      ]
      #set par(
        justify: false,
        leading: if pinyin-mode {
          if theme.name != "school" { 0.55em } else { 0.65em }
        } else {
          (format.leading - 1.0) * 1em
        },
        spacing: 0.8em,
      )
      #if is-long {
        set par(
          justify: if pinyin-mode { false } else { true },
          first-line-indent: (amount: 2em, all: true),
          spacing: long-paragraph-gap,
        )
        align(left)[
          #if use-pinyin and py-data.at("lines", default: none) != none {
            for (index, _line) in poem.lines.enumerate() {
              _ruby-line(
                py-data.lines.at(index),
                size: body-size,
                py-size: body-py-size,
                hanzi-font: body-font,
                hanzi-fill: theme.text-fill,
                py-fill: theme.pinyin-fill,
                box-height: 1.55,
              )
              parbreak()
            }
          } else {
            for line in poem.lines {
              text(font: body-font, size: body-size, fill: theme.text-fill)[#line]
              parbreak()
            }
          }
        ]
      } else {
        align(center)[
          #if use-pinyin and py-data.at("lines", default: none) != none {
            for item in display-items {
              if item.py != none {
                _ruby-line(
                  item.py,
                  size: body-size,
                  py-size: body-py-size,
                  hanzi-font: body-font,
                  hanzi-fill: theme.text-fill,
                  py-fill: theme.pinyin-fill,
                  box-height: 1.55,
                )
              } else {
                text(font: body-font, size: body-size, fill: theme.text-fill)[#item.text]
              }
              linebreak()
            }
          } else {
            text(font: body-font, size: body-size, fill: theme.text-fill)[
              #for line in display-lines {
                line
                linebreak()
              }
            ]
          }
        ]
      }
    ]
    block(
      width: 100%,
      breakable: if profile.paper == "kindle" { true } else { is-long or poem.lines.len() > 4 },
      inset: (x: 0pt, y: 0pt),
    )[
      #if keep-core { block(breakable: false)[#core] } else { core }
      #if note-mode == "short" {
        _short-notes(
          poem.notes,
          format.note_size * 1pt,
          theme: theme,
          rule: format.at("note_rule", default: theme.note-rule),
          label: format.at("note_label", default: theme.note-label),
          leading: if compact {
            0.25
          } else {
            format.at(
              "note_leading",
              default: if pinyin-mode { 0.65 } else { format.leading - 1.0 },
            )
          },
          compact: compact,
        )
      }
      #v(if profile.paper == "kindle" {
        0pt
      } else if theme.poem-gap != none {
        theme.poem-gap * body-size
      } else {
        poem-gap
      })
    ]
  }
}

#let _running-header(label, theme: school) = context {
  let page-no = counter(page).get().first()
  align(if calc.odd(page-no) { right } else { left })[
    #text(
      size: 8pt,
      fill: theme.at("header-fill", default: theme.page-number-fill),
    )[#label]
  ]
}

#let _chapter-header(theme: school) = context {
  let page-no = counter(page).get().first()
  let chapters = query(metadata).filter(item =>
    item.value.at("kind", default: "") == "chapter"
    and item.location().page() <= page-no
  )
  if chapters.len() > 0 {
    let chapter = chapters.last().value
    let topics = query(heading.where(level: 2)).filter(h => h.location().page() <= page-no)
    let topic-heading-here = topics.filter(h => h.location().page() == page-no).len() > 0
    let topic = if topics.len() > 0 and not topic-heading-here { topics.last().body } else { none }
    let fallback = chapter.at("subname", default: "").replace("（", "").replace("）", "")
    let label = if topic-heading-here {
      [#chapter.name]
    } else if topic != none {
      [#chapter.name · #topic]
    } else if fallback != "" {
      [#chapter.name · #fallback]
    } else {
      [#chapter.name]
    }
    _running-header(label, theme: theme)
  }
}

#let _book-cover(book, profile, mode, asset-root) = {
  let for-kindle = profile.paper == "kindle"
  let branding = book.at("branding", default: (:))
  let version = book.metadata.at("version", default: "")
  let slogan = branding.at("slogan", default: "")
  let cover-lines = branding.at("cover_lines", default: ())
  let cover-lines = if cover-lines == none or cover-lines == "" {
    ()
  } else if type(cover-lines) == str {
    (cover-lines,)
  } else {
    cover-lines
  }
  let has-logo = branding.at("logo", default: "") != ""
  let has-school = branding.at("school_name", default: "") != "" or branding.at("school_name_en", default: "") != ""
  let logo-cell = if has-logo {
    (
      box(fill: white, inset: if for-kindle { 2mm } else { 3mm }, radius: 50%)[
        #_school-mark(book, width: if for-kindle { 10mm } else { 13mm }, asset-root: asset-root)
      ],
    )
  } else {
    ()
  }
  let school-cell = if has-school {
    (
      [
        #if branding.at("school_name", default: "") != "" {
          text(fill: white, size: if for-kindle { 9pt } else { 10pt }, weight: "medium")[#branding.at("school_name", default: "")]
        }
        #if branding.at("school_name_en", default: "") != "" {
          v(0.2em)
          text(fill: white.transparentize(12%), size: if for-kindle { 6.5pt } else { 7.5pt })[#branding.at("school_name_en", default: "")]
        }
      ],
    )
  } else {
    ()
  }
  page(
    ..profile.page-args,
    margin: 0pt,
    columns: 1,
    fill: rgb("#FAF7F0"),
    header: none,
    numbering: none,
  )[
    #_torn-band(rgb("#ED6C32"))
    #place(
      top + right,
      dx: if for-kindle { -10mm } else { -20mm },
      dy: if for-kindle { 10mm } else if profile.paper == "a5" { 17mm } else { 20mm },
    )[
      #align(center)[
        #if slogan != "" {
          _vertical-text(
            slogan,
            if for-kindle { 8pt } else { 10pt },
            fill: if for-kindle { luma(55) } else { rgb("#C4512D") },
          )
          v(0.8em)
        }
        #_vertical-text(
          book.metadata.title,
          if for-kindle { 19pt } else if profile.paper == "a5" { 27pt } else { 30pt },
          fill: if for-kindle { luma(20) } else { rgb("#E44F24") },
          spacing: 0.08em,
        )
      ]
    ]
    #place(
      top + left,
      dx: if for-kindle { 12mm } else { 20mm },
      dy: if for-kindle { 12mm } else { 24mm },
    )[
      #rect(
        width: if for-kindle { 22mm } else { 30mm },
        height: 1.6pt,
        fill: rgb("#ED6C32"),
      )
      #v(0.8em)
      #text(size: if for-kindle { 8pt } else { 10pt }, fill: luma(100), tracking: 0.1em)[#book.metadata.edition#if version != "" [ · #version]]
    ]
    #place(left + horizon, dx: if for-kindle { 12mm } else { 20mm })[
      #block(width: if for-kindle { 40% } else { 42% }, inset: (x: 4mm, y: 4mm))[
        #if mode == "personal" {
          let student = book.metadata.at("student_name", default: "")
          let class-name = book.metadata.at("class_name", default: "")
          text(font: ("STKaiti", "KaiTi"), size: 15pt, fill: luma(45))[
            #(if class-name == "" { "班级：" } else { "班级：" + class-name })
            #if class-name == "" {
              box(width: 24mm, stroke: (bottom: 0.6pt + luma(70)))
            }
            #linebreak()
            #(if student == "" { "姓名：" } else { "姓名：" + student })
            #if student == "" {
              box(width: 24mm, stroke: (bottom: 0.6pt + luma(70)))
            }
          ]
        } else {
          text(
            font: ("STKaiti", "KaiTi"),
            size: if for-kindle { 12pt } else { 16pt },
            fill: if for-kindle { luma(45) } else { luma(110) },
          )[
            #for (index, line) in cover-lines.enumerate() {
              if index > 0 { linebreak() }
              line
            }
          ]
        }
      ]
    ]
    #if has-logo or has-school {
      place(
        bottom + left,
        dx: if for-kindle { 8mm } else { 18mm },
        dy: if for-kindle { -8mm } else { -13mm },
      )[
        #grid(
          columns: if has-logo {
            if for-kindle { (14mm, 1fr) } else { (19mm, 1fr) }
          } else {
            (1fr,)
          },
          column-gutter: 4mm,
          align: horizon,
          ..logo-cell,
          ..school-cell,
        )
      ]
    }
  ]
}

#let _title-page(book, profile, mode, theme: school) = {
  let slogan = _brand(book, "slogan")
  let student = book.metadata.at("student_name", default: "")
  let class-name = book.metadata.at("class_name", default: "")
  let volume = book.metadata.at("volume", default: "")
  let edition = book.metadata.at("edition", default: "")
  let subtitle = if volume != "" and edition != "" {
    volume + " · " + edition
  } else {
    volume + edition
  }
  let styled = theme.name != "school"
  let for-kindle = profile.paper == "kindle"
  page(
    ..profile.page-args,
    margin: 0pt,
    columns: 1,
    fill: if styled { theme.page-fill } else { rgb("#FCFAF5") },
    footer: if styled { none } else { auto },
    header: none,
    numbering: none,
  )[
    #place(
      top + right,
      dx: if for-kindle { -10mm } else { -25mm },
      dy: if for-kindle { 10mm } else { 26mm },
    )[
      #align(center)[
        #if slogan != "" {
          _vertical-text(
            slogan,
            if for-kindle { 8pt } else { 9.5pt },
            fill: if styled { theme.author-fill } else { rgb("#C4512D") },
            font: theme.serif,
          )
          v(0.7em)
        }
        #_vertical-text(
          book.metadata.title,
          if for-kindle { 19pt } else if styled { if profile.paper == "a4" { 30pt } else { 24pt } } else { 27pt },
          fill: if styled { theme.title-fill } else { rgb("#E44F24") },
          font: theme.serif,
        )
      ]
    ]
    #place(
      top + left,
      dx: if for-kindle { 12mm } else { 22mm },
      dy: if for-kindle { 12mm } else { 24mm },
    )[
      #rect(
        width: if for-kindle { 22mm } else { 28mm },
        height: if styled { 0.5pt } else { 1.4pt },
        fill: if styled { theme.rule-fill } else { rgb("#ED6C32") },
      )
      #if book.metadata.at("review_mode", default: false) {
        v(3mm)
        text(size: 9pt, fill: if styled { theme.author-fill } else { rgb("#B33A20") })[
          #book.metadata.at("review_label", default: "审核稿") · 请勿付印
        ]
      }
    ]
    #if subtitle != "" {
      place(
        bottom + left,
        dx: if for-kindle { 10mm } else { 22mm },
        dy: if for-kindle { -14mm } else { -28mm },
      )[
        #text(
          size: 10pt,
          fill: if styled { theme.author-fill } else { luma(100) },
          tracking: 0.1em,
        )[#subtitle]
      ]
    }
    #if mode == "personal" {
      place(
        bottom + right,
        dx: if for-kindle { -10mm } else { -28mm },
        dy: if for-kindle { -14mm } else { -28mm },
      )[
        #block(inset: 4mm)[
          #text(
            font: theme.serif,
            size: 14pt,
            fill: if styled { theme.text-fill } else { luma(45) },
          )[
            班级：#(if class-name == "" { box(width: 32mm, stroke: (bottom: 0.6pt + luma(70))) } else { class-name })
            #v(1.4em)
            姓名：#(if student == "" { box(width: 32mm, stroke: (bottom: 0.6pt + luma(70))) } else { student })
          ]
        ]
      ]
    }
  ]
}

#let _preface-page(
  book,
  profile,
  theme: school,
  body-size: 12.5pt,
  body-font: ("Noto Serif CJK SC", "SimSun"),
  scale: 1.0,
) = if book.front_matter.at("preface", default: "") != "" {
  let styled = theme.name != "school"
  let content-width = profile.width - profile.margin.left - profile.margin.right
  let content-height = profile.height - profile.margin.top - profile.margin.bottom
  let content = block(width: content-width * 0.88, inset: (x: 2mm, y: 0pt))[
    #align(center)[
      #text(
        font: theme.serif,
        size: if styled {
          if profile.paper == "a4" and theme.at("preface-title-size-a4", default: none) != none {
            theme.preface-title-size-a4
          } else {
            theme.preface-title-size
          }
        } else {
          theme.preface-title-size * scale
        },
        fill: theme.preface-title,
        weight: if styled { theme.title-weight } else { "regular" },
        tracking: 0.1em,
      )[#book.front_matter.at("title", default: "卷首语")]
      #v(0.7em)
      #line(
        length: if styled { 20mm } else { 24mm * scale },
        stroke: (if styled { 0.5pt } else { 0.8pt * scale }) + theme.preface-title,
      )
    ]
    #v(if styled { 1.1em } else if body-size >= 20pt { 1em } else { 1.35em })
    #align(left)[
      #set par(
        justify: true,
        first-line-indent: (amount: 2em, all: true),
        leading: if styled { 0.55em } else if body-size >= 20pt { 0.85em } else { 1.15em },
        spacing: if styled { 0.8em } else if body-size >= 20pt { 1em } else { 1.3em },
      )
      #set text(
        font: body-font,
        size: if styled { body-size } else if body-size >= 20pt { 20pt } else { 14pt },
        fill: theme.preface-text-fill,
      )
      #for paragraph in book.front_matter.paragraphs {
        paragraph
        parbreak()
      }
    ]
  ]
  page(
    ..profile.page-args,
    margin: profile.margin,
    columns: 1,
    fill: theme.page-fill,
    header: none,
)[
    // Short prefaces look best as a single centred block: the title and body
    // are balanced against the page instead of leaving a large blank tail.
    // Long prefaces must flow from the top and may span pages; placing them
    // would clip the overflow on small Kindle pages.
    #context {
      if measure(content).height <= content-height {
        place(center + horizon, content)
      } else {
        align(center, content)
      }
    }
  ]
}

#let _famous-lines-heading(profile, theme: school, scale: 1.0) = align(left)[
  #text(
    font: theme.serif,
    size: if theme.name != "school" and profile.paper == "a4" {
      theme.appendix-title-size-a4
    } else if theme.name != "school" {
      theme.appendix-title-size
    } else {
      theme.appendix-title-size * scale
    },
    fill: theme.appendix-title,
    weight: if theme.name != "school" { theme.title-weight } else { "regular" },
  )[【古诗词名句】]
  #line(
    length: 100%,
    stroke: (if theme.name != "school" { 0.5pt } else { 0.8pt * scale }) + theme.appendix-accent,
  )
]

#let _famous-lines-page(
  book,
  profile,
  theme: school,
  body-size: 13pt,
  scale: 1.0,
) = if book.features.at("famous_lines", default: false) {
  let styled = theme.name != "school"
  let lines = book.appendix.famous_lines
  let per-page = if styled {
    if profile.paper == "a4" {
      if body-size >= 14pt { 8 } else { 9 }
    } else {
      6
    }
  } else {
    calc.max(2, int(calc.floor(7 / scale)))
  }
  for start in range(0, lines.len(), step: per-page) {
    page(
      ..profile.page-args,
      margin: profile.margin,
      columns: 1,
      fill: theme.page-fill,
      header: _running-header("附录 · 古诗词名句", theme: theme),
    )[
      #_famous-lines-heading(profile, theme: theme, scale: scale)
      #v(1.2em)
      #for item in lines.slice(start, calc.min(start + per-page, lines.len())) {
        block(width: 88%, breakable: false)[
          #text(
            font: theme.serif,
            size: if styled { body-size } else { 15pt * scale },
            fill: if styled { theme.text-fill } else { theme.famous-lines-fill },
          )[#item.quote]
          #v(0.45em)
          #align(right)[
            #text(
              size: if styled { 10.5pt } else { 12pt * scale },
              fill: if styled { theme.author-fill } else { theme.famous-source-fill },
            )[——#item.source]
          ]
        ]
        v(1.25em)
      }
    ]
  }
}

#let _poet-page(
  book,
  profile,
  theme: school,
  body-size: 11pt,
  scale: 1.0,
) = if book.features.at("poet_bio", default: false) {
  let styled = theme.name != "school"
  page(
    ..profile.page-args,
    margin: profile.margin,
    columns: 1,
    fill: theme.page-fill,
    header: _running-header("附录 · 诗人简介", theme: theme),
  )[
    #align(left)[
      #text(
        font: theme.serif,
        size: if styled {
          if profile.paper == "a4" and theme.at("appendix-title-size-a4", default: none) != none {
            theme.appendix-title-size-a4
          } else {
            theme.appendix-title-size
          }
        } else {
          theme.appendix-title-size * scale
        },
        fill: theme.appendix-title,
        weight: if styled { theme.title-weight } else { "regular" },
      )[#book.appendix.at("poet_heading", default: "【诗人简介】")]
    ]
    #line(
      length: 100%,
      stroke: (if styled { 0.5pt } else { 0.8pt * scale }) + theme.appendix-accent,
    )
    #v(1.1em)
    #for (index, poet) in book.appendix.poets.enumerate() {
      let group = poet.at("group", default: "")
      let previous-group = if index == 0 {
        none
      } else {
        book.appendix.poets.at(index - 1).at("group", default: "")
      }
      let starts-group = group != "" and group != previous-group
      block(breakable: false)[
        #if starts-group {
          v(if index == 0 { 0em } else { 0.9em })
          text(
            font: theme.serif,
            size: if styled { 13pt } else { 14pt * scale },
            fill: theme.appendix-name,
            weight: theme.title-weight,
          )[#group]
          v(0.45em)
        }
        #if styled {
          text(
            font: theme.serif,
            size: 13pt,
            fill: theme.appendix-name,
            weight: theme.title-weight,
          )[#poet.name]
          if poet.at("years", default: "") != "" [
            #text(
              font: theme.serif,
              size: 10.5pt,
              fill: theme.author-fill,
            )[（#poet.years）]
          ]
        } else {
          text(
            font: theme.serif,
            size: 15pt * scale,
            fill: theme.poet-name-fill,
            weight: "medium",
          )[#poet.name（#poet.years）]
        }
        #v(0.15em)
        #set par(
          justify: true,
          leading: if scale > 1.2 { 0.65em } else { 0.55em },
          spacing: if scale > 1.2 { 0.7em } else { 0.9em },
        )
        #text(
          font: theme.body-font,
          size: if styled { body-size } else { 11pt * scale },
          fill: if styled { theme.text-fill } else { theme.poet-bio-fill },
        )[#poet.bio]
      ]
      v(0.9em)
    }
  ]
}

#let _author-index-page(
  book,
  profile,
  theme: school,
  scale: 1.0,
) = if book.features.at("author_index", default: false) {
  let styled = theme.name != "school"
  page(
    ..profile.page-args,
    margin: profile.margin,
    columns: 1,
    fill: theme.page-fill,
    header: _running-header("附录 · 诗人索引", theme: theme),
  )[
    #align(left)[
      #text(
        font: theme.serif,
        size: if styled {
          if profile.paper == "a4" and theme.at("appendix-title-size-a4", default: none) != none {
            theme.appendix-title-size-a4
          } else {
            theme.appendix-title-size
          }
        } else {
          theme.appendix-title-size * scale
        },
        fill: theme.appendix-title,
        weight: if styled { theme.title-weight } else { "regular" },
      )[【诗人索引】]
    ]
    #line(
      length: 100%,
      stroke: (if styled { 0.5pt } else { 0.8pt * scale }) + theme.appendix-accent,
    )
    #v(0.9em)
    #let initials = ()
    #for item in book.appendix.author_index {
      let initial = item.at("initial", default: "")
      if not initials.contains(initial) {
        initials.push(initial)
      }
    }
    #for (group-index, initial) in initials.enumerate() {
      let items = book.appendix.author_index.filter(
        item => item.at("initial", default: "") == initial,
      )
      let rows = items
        .map(item => (
          text(
            font: theme.serif,
            size: 10.5pt * scale,
            fill: if styled { theme.appendix-name } else { theme.index-name-fill },
          )[#item.name#text(
            size: 9pt * scale,
            fill: if styled { theme.author-fill } else { theme.index-dynasty-fill },
          )[（#item.dynasty）]],
          context text(
            font: theme.body-font,
            size: 9.5pt * scale,
            fill: if styled { theme.author-fill } else { theme.index-poem-fill },
          )[
            #for (index, poem) in item.poems.enumerate() {
              if index > 0 { [、] }
              [#poem.title#box[（第 #ref(label("poem-" + poem.poem_id), supplement: none, form: "page") 页）]]
            }
          ],
        ))
        .flatten()
      let header = if initial == "" {
        ()
      } else {
        (
          table.header(
            table.cell(
              colspan: 2,
              align: left,
              inset: (x: 2pt, top: 5pt, bottom: 2pt),
            )[
              #text(
                font: theme.serif,
                size: if styled { 13pt } else { 14pt * scale },
                fill: if styled { theme.appendix-name } else { theme.index-initial-fill },
                weight: theme.title-weight,
              )[#initial]
              #v(0.1em)
              #line(
                length: 100%,
                stroke: 0.5pt + theme.appendix-accent,
              )
            ],
          ),
        )
      }
      if group-index > 0 {
        v(0.25em)
      }
      table(
        columns: (31%, 69%),
        stroke: none,
        inset: (x: 2pt, y: 3pt),
        ..header,
        ..rows,
      )
    }
  ]
}

// Endnotes for readings that are disputed, commonly misread, or not yet
// unified across textbooks. Kept at the back so the poem pages stay clean.
#let _reading-notes-page(
  book,
  profile,
  theme: school,
  scale: 1.0,
) = if book.features.at("reading_notes", default: false) {
  let data = book.appendix.reading_notes
  let styled = theme.name != "school"
  page(
    ..profile.page-args,
    margin: profile.margin,
    columns: 1,
    fill: theme.page-fill,
    header: _running-header("后注 · 多音字备查", theme: theme),
  )[
    #set par(justify: true, leading: 0.62em)
    #align(left)[
      #text(
        font: theme.serif,
        size: if styled {
          if profile.paper == "a4" and theme.at("appendix-title-size-a4", default: none) != none {
            theme.appendix-title-size-a4
          } else {
            theme.appendix-title-size
          }
        } else {
          theme.appendix-title-size * scale
        },
        fill: theme.appendix-title,
        weight: if styled { theme.title-weight } else { "regular" },
      )[#data.heading]
      #h(0.6em)
      #text(
        font: theme.serif,
        size: 14pt * scale,
        fill: theme.author-fill,
      )[#data.subtitle]
    ]
    #line(
      length: 100%,
      stroke: (if styled { 0.5pt } else { 0.8pt * scale }) + theme.appendix-accent,
    )
    #v(0.7em)
    #text(
      font: theme.body-font,
      size: 11pt * scale,
      fill: theme.text-fill,
    )[#data.intro]
    #v(0.9em)
    #for group in data.groups [
      #for (item-index, item) in group.items.enumerate() [
        // Keep the group heading together with its first entry.
        #block(breakable: false)[
          #if item-index == 0 [
            #text(
              font: theme.serif,
              size: 14pt * scale,
              fill: theme.appendix-name,
              weight: "medium",
            )[#group.heading]
            #v(0.35em)
          ]
          #text(
            font: theme.serif,
            size: 13pt * scale,
            fill: theme.appendix-name,
            weight: "medium",
          )[#item.poem#h(0.8em)#item.word]
          #v(0.12em)
          #layout(size => {
            let main = text(
              font: theme.body-font,
              size: 11pt * scale,
              fill: theme.text-fill,
            )[正文：#item.reading]
            if item.at("alternative", default: "") != "" {
              let alt = text(
                font: theme.body-font,
                size: 11pt * scale,
                fill: theme.author-fill,
              )[另读：#item.alternative]
              // Keep pinyin phrases unbroken: drop 另读 to its own line when
              // the combined line would wrap mid-reading.
              if measure(main + h(1em) + alt).width <= size.width {
                main
                h(1em)
                alt
              } else {
                main
                linebreak()
                alt
              }
            } else {
              main
            }
          })
          #v(0.1em)
          #text(
            font: theme.body-font,
            size: 10.5pt * scale,
            fill: theme.author-fill,
          )[#item.note]
        ]
        #v(0.7em)
      ]
      #v(0.2em)
    ]
  ]
}

#let _end-page(book, profile, theme: school, scale: 1.0) = {
  let styled = theme.name != "school"
  let motto = book.at("branding", default: (:)).at("end_motto", default: "诗心常在　书香长伴")
  page(
    ..profile.page-args,
    margin: 0pt,
    columns: 1,
    fill: if styled { theme.page-fill } else { theme.end-page-fill },
    footer: if styled { none } else { auto },
    header: none,
    numbering: none,
  )[
    #place(center + horizon)[
      #block(width: 72%, inset: 12mm)[
        #align(center)[
          #text(
            font: theme.serif,
            size: if styled {
              if profile.paper == "a4" and theme.at("end-mark-size-a4", default: none) != none {
                theme.end-mark-size-a4
              } else {
                theme.end-mark-size
              }
            } else {
              theme.end-mark-size * scale
            },
            fill: theme.end-mark,
          )[诗]
          #v(1.2em)
          #if motto != "" {
            text(
              font: theme.body-font,
              size: 10pt * scale,
              fill: theme.end-motto,
              tracking: 0.18em,
            )[#motto]
          }
        ]
      ]
    ]
  ]
}

#let _back-cover(book, profile, asset-root) = {
  let for-kindle = profile.paper == "kindle"
  let branding = book.at("branding", default: (:))
  let slogan = branding.at("slogan", default: "")
  let motto = branding.at("motto", default: "")
  let has-logo = branding.at("logo", default: "") != ""
  let has-school = branding.at("school_name", default: "") != "" or branding.at("school_name_en", default: "") != ""
  let logo-cell = if has-logo {
    (
      box(fill: white, inset: if for-kindle { 2mm } else { 3mm }, radius: 50%)[
        #_school-mark(book, width: if for-kindle { 10mm } else { 13mm }, asset-root: asset-root)
      ],
    )
  } else {
    ()
  }
  let school-cell = if has-school {
    (
      [
        #if branding.at("school_name", default: "") != "" {
          text(fill: white, size: if for-kindle { 9pt } else { 10pt }, weight: "medium")[#branding.at("school_name", default: "")]
        }
        #if branding.at("school_name_en", default: "") != "" {
          v(0.2em)
          text(fill: white.transparentize(12%), size: if for-kindle { 6.5pt } else { 7.5pt })[#branding.at("school_name_en", default: "")]
        }
      ],
    )
  } else {
    ()
  }
  page(
    ..profile.page-args,
    margin: 0pt,
    columns: 1,
    fill: rgb("#FAF7F0"),
    header: none,
    numbering: none,
  )[
    #_torn-band(rgb("#ED6C32"))
    #place(top + left, dx: 20mm, dy: 24mm)[
      #if slogan != "" {
        text(fill: rgb("#D5672D"), size: 9pt)[#slogan]
        v(0.45em)
      }
      #text(fill: rgb("#E44F24"), size: 22pt, font: ("STKaiti", "KaiTi"))[
        #book.metadata.title
      ]
    ]
    #place(top + right, dx: -28mm, dy: 24mm)[
      #if motto != "" {
        _vertical-text(motto, 13pt, fill: rgb("#C4512D"))
      }
    ]
    #if has-logo or has-school {
      place(bottom + left, dx: 18mm, dy: -14mm)[
        #grid(
          columns: if has-logo { (19mm, 1fr) } else { (1fr,) },
          column-gutter: 4mm,
          align: horizon,
          ..logo-cell,
          ..school-cell,
        )
      ]
    }
  ]
}

#let _chapter-cover(chapter, profile, theme: school) = {
  let styled = theme.name != "school"
  page(
    ..profile.page-args,
    margin: 0pt,
    columns: 1,
    fill: if styled { theme.chapter-cover-fill } else { rgb(chapter.bg_color) },
    footer: if styled { none } else { auto },
    header: none,
    numbering: none,
  )[
    #metadata((kind: "chapter", name: chapter.name, subname: chapter.subname))
    #if styled {
      place(center + horizon)[
        #grid(
          columns: (0.75pt, auto),
          column-gutter: 6mm,
          align: horizon,
          rect(
            width: 0.75pt,
            height: if profile.paper == "a4" { 30mm } else { 22mm },
            fill: theme.title-fill,
          ),
          block[
            #block(above: 0pt, below: 0pt)[
              #heading(level: 1, outlined: true, bookmarked: true)[#chapter.name]
            ]
            #v(0.7em)
            #text(
              font: theme.serif,
              size: if profile.paper == "a4" { theme.chapter-sub-size-a4 } else { 10.5pt },
              fill: theme.chapter-sub,
            )[#chapter.subname]
          ],
        )
      ]
    } else {
      place(center + horizon)[
        #block(
          width: 68%,
          inset: (x: 12mm, y: 15mm),
          stroke: 0.8pt + white.transparentize(35%),
        )[
          #align(center)[
            #block(above: 0pt, below: 0pt)[
              #heading(level: 1, outlined: true, bookmarked: true)[#chapter.name]
            ]
            #v(1em)
            #text(size: 13pt, fill: white.transparentize(12%))[#chapter.subname]
          ]
        ]
      ]
    }
  ]
}

#let _toc-page(book, profile, columns, theme: school, scale: 1.0) = {
  let styled = theme.name != "school"
  page(
    ..profile.page-args,
    margin: profile.margin,
    columns: 1,
    fill: theme.page-fill,
    header: none,
    numbering: none,
  )[
    #align(center)[
      #text(
        font: theme.serif,
        size: if styled {
          if profile.paper == "a4" and theme.at("toc-title-size-a4", default: none) != none {
            theme.toc-title-size-a4
          } else {
            theme.toc-title-size
          }
        } else {
          theme.toc-title-size * scale
        },
        fill: theme.toc-title,
        weight: if styled { theme.title-weight } else { "regular" },
      )[目录]
    ]
    #v(1.6em)
    #show outline.entry.where(level: 1): it => {
      let color = if styled {
        theme.toc-level-1
      } else if it.element.body == [第二章 兰亭漫读] {
        theme.toc-chapter-2-fill
      } else {
        theme.toc-chapter-1-fill
      }
      set text(
        font: theme.serif,
        size: if styled {
          if profile.paper == "a4" { theme.toc-level-1-size-a4 } else { 13pt }
        } else {
          14pt * scale
        },
        fill: color,
        weight: if styled { theme.title-weight } else { "bold" },
      )
      it
    }
    #show outline.entry.where(level: 2): set text(
      font: theme.serif,
      size: if styled {
        if profile.paper == "a4" { theme.toc-level-2-size-a4 } else { 11pt }
      } else {
        11.5pt * scale
      },
      fill: theme.toc-level-2,
    )
    #show outline.entry.where(level: 3): set text(
      font: if styled { theme.body-font } else { theme.body-font },
      size: if styled {
        if profile.paper == "a4" { theme.toc-level-3-size-a4 } else { 10.5pt }
      } else {
        10.8pt * scale
      },
      fill: theme.toc-level-3,
    )
    #show outline.entry.where(level: 4): set text(
      font: if styled { theme.body-font } else { theme.body-font },
      size: if styled {
        if profile.paper == "a4" { theme.toc-level-4-size-a4 } else { 10.5pt }
      } else {
        10.5pt * scale
      },
      fill: theme.toc-level-4,
    )
    #show outline.entry: it => {
      show text.where(fill: rgb(0, 0, 0, 0)): inner => text(
        fill: theme.toc-level-4,
      )[#inner.text]
      it
    }
    #outline(title: none, depth: 4, indent: auto)
  ]
}

#let _topic-heading(topic, chapter) = heading(
  level: 2,
  outlined: true,
  bookmarked: true,
)[
  #topic
]

#let _subtopic-heading(subtopic, chapter) = heading(
  level: 3,
  outlined: true,
  bookmarked: true,
)[
  #subtopic
]

// Build one poem together with the topic/subtopic headings that introduce it.
#let _poem-item(
  poem,
  chapter,
  format,
  note-mode,
  profile,
  show-topic: false,
  show-subtopic: false,
  pinyin: none,
  pinyin-mode: false,
  body-font: (),
  title-font: (),
  theme: school,
  compact: false,
) = [
  #if show-topic and poem.at("topic", default: "") != "" {
    _topic-heading(poem.topic, chapter)
  }
  #if show-subtopic and poem.at("subtopic", default: "") != "" {
    _subtopic-heading(poem.subtopic, chapter)
  }
  #_poem-block(
    poem,
    format,
    note-mode,
    profile,
    pinyin: pinyin,
    pinyin-mode: pinyin-mode,
    body-font: body-font,
    title-font: title-font,
    theme: theme,
    compact: compact,
  )
]

// Large-print pagination: stack up to `poems_per_page` short poems in equal
// panels. A poem that does not fit a panel (four or more display lines, a
// long poem, or a topic heading that pushes it over) gets a full page.
//
// With `compact_fit`, a poem that misses its panel by a small amount is
// measured again with tighter note/heading spacing. Body size and pinyin stay
// at their full large-print values; only auxiliary whitespace shrinks.
#let _poem-pages-2up(
  chapter,
  format,
  note-mode,
  profile,
  pinyin: none,
  pinyin-mode: false,
  body-font: (),
  title-font: (),
  theme: school,
) = {
  let per-page = int(format.at("poems_per_page", default: 2))
  let compact-fit = format.at("compact_fit", default: false)
  let panel-gap = format.at("panel_gap", default: 8 * 72 / 25.4) * 1pt
  let content-height = profile.height - profile.margin.top - profile.margin.bottom
  let content-width = profile.width - profile.margin.left - profile.margin.right
  // A sub-millimetre safety margin keeps exact-height grids from overflowing
  // because of rounding in the page content region.
  let panel-height = (content-height - panel-gap * (per-page - 1)) / per-page - 0.6mm
  context {
    let items = ()
    let last-topic = ""
    let last-subtopic = ""
    for poem in chapter.poems {
      let topic = poem.at("topic", default: "")
      let subtopic = poem.at("subtopic", default: "")
      let show-topic = topic != "" and topic != last-topic
      if show-topic {
        last-topic = topic
        last-subtopic = ""
      }
      let show-subtopic = subtopic != "" and subtopic != last-subtopic
      if show-subtopic {
        last-subtopic = subtopic
      }
      let content = _poem-item(
        poem,
        chapter,
        format,
        note-mode,
        profile,
        show-topic: show-topic,
        show-subtopic: show-subtopic,
        pinyin: pinyin,
        pinyin-mode: pinyin-mode,
        body-font: body-font,
        title-font: title-font,
        theme: theme,
      )
      let compact-content = if compact-fit {
        _poem-item(
          poem,
          chapter,
          format,
          note-mode,
          profile,
          show-topic: show-topic,
          show-subtopic: show-subtopic,
          pinyin: pinyin,
          pinyin-mode: pinyin-mode,
          body-font: body-font,
          title-font: title-font,
          theme: theme,
          compact: true,
        )
      } else {
        content
      }
      // Measure at the real text width: at the document top level the
      // available width is zero, which would wrap every character.
      items.push((
        content: content,
        compact-content: compact-content,
        height: measure(block(width: content-width)[#content]).height,
        compact-height: if compact-fit {
          measure(block(width: content-width)[#compact-content]).height
        } else {
          measure(block(width: content-width)[#content]).height
        },
      ))
    }
    let groups = ()
    let pending = none
    for item in items {
      let fits-normal = item.height <= panel-height
      let fits-compact = compact-fit and item.compact-height <= panel-height
      if pending == none {
        if fits-normal or fits-compact {
          pending = item
        } else {
          groups.push((kind: "full", items: (item,)))
        }
      } else {
        let previous = pending
        if previous.height <= panel-height and item.height <= panel-height {
          groups.push((kind: "pair", mode: "normal", items: (previous, item)))
          pending = none
        } else if (
          compact-fit
            and previous.compact-height <= panel-height
            and item.compact-height <= panel-height
        ) {
          groups.push((kind: "pair", mode: "compact", items: (previous, item)))
          pending = none
        } else {
          groups.push((kind: "single", items: (previous,)))
          if fits-normal or fits-compact {
            pending = item
          } else {
            groups.push((kind: "full", items: (item,)))
            pending = none
          }
        }
      }
    }
    if pending != none {
      groups.push((kind: "single", items: (pending,)))
    }

    for group in groups {
      if group.kind == "pair" {
        let use-compact = group.mode == "compact"
        let first = if use-compact {
          group.items.at(0).compact-content
        } else {
          group.items.at(0).content
        }
        let second = if use-compact {
          group.items.at(1).compact-content
        } else {
          group.items.at(1).content
        }
        page(..profile.page-args, margin: profile.margin, columns: 1)[
          #grid(
            rows: (panel-height, panel-height),
            row-gutter: panel-gap,
            block(height: panel-height)[#align(center + horizon)[#first]],
            block(height: panel-height)[#align(center + horizon)[#second]],
          )
        ]
      } else if group.kind == "single" {
        page(..profile.page-args, margin: profile.margin, columns: 1)[
          #block(height: 100%)[
            #align(center + horizon)[#group.items.at(0).content]
          ]
        ]
      } else {
        // Full-page poems stay in normal flow so a very long poem can break
        // onto a second page instead of overflowing a fixed panel.
        pagebreak(weak: true)
        group.items.at(0).content
        pagebreak(weak: true)
      }
    }
  }
}

#let poem-book(
  body,
  book: none,
  format: none,
  notes: none,
  fonts: none,
  features: (:),
  cover-mode: none,
  asset-root: "",
  pinyin: none,
  pinyin-mode: false,
  design: "school",
  palette: none,
) = {
  if book == none {
    panic("poem-book requires a book dictionary or JSON file")
  }
  let theme = resolve-theme(design: design, palette: palette)
  let base-format = if format == none { book.format } else { format }
  let actual-format = if pinyin-mode {
    base-format + (
      columns: 1,
      body_size: base-format.at("pinyin_body_size", default: 14.0),
      leading: base-format.at("pinyin_leading", default: 2.2),
      note_size: base-format.at("pinyin_note_size", default: 10.5),
      title_size: base-format.at("pinyin_title_size", default: 18.0),
      title_pinyin_size: base-format.at("pinyin_title_pinyin_size", default: 8.0),
      author_size: base-format.at("pinyin_author_size", default: 11.0),
      author_pinyin_size: base-format.at("pinyin_author_pinyin_size", default: 6.6),
      pinyin_size: base-format.at("pinyin_size", default: 7.7),
    )
  } else {
    base-format
  }
  let aux-scale = actual-format.at("aux_scale", default: 1.0)
  let poems-per-page = int(actual-format.at("poems_per_page", default: 1))
  let actual-notes = if notes == none { book.notes } else { notes }
  let actual-fonts = if fonts == none { book.fonts } else { fonts }
  let actual-features = if features == (:) {
    book.at("features", default: (:))
  } else {
    features
  }
  let book = book + (features: actual-features)
  let actual-cover-mode = if cover-mode == none {
    book.metadata.at("cover_mode", default: "general")
  } else {
    cover-mode
  }
  let profile = _page-profile(actual-format, theme: theme)

  let volume = book.metadata.at("volume", default: "")
  set document(
    title: book.metadata.title + (if volume == "" { "" } else { " · " + volume }),
    author: book.metadata.at("author", default: book.metadata.title),
  )
  set text(
    lang: "zh",
    region: "cn",
    font: actual-fonts.body,
    size: actual-format.body_size * 1pt,
    fill: theme.text-fill,
  )
  set par(justify: false)
  set heading(numbering: none)
  show heading.where(level: 1): it => if theme.name != "school" {
    text(
      font: theme.serif,
      size: profile.chapter-size,
      fill: theme.chapter-title,
      weight: theme.title-weight,
    )[#it.body]
  } else {
    text(
      font: ("STKaiti", "KaiTi"),
      size: profile.chapter-size,
      fill: white,
    )[#it.body]
  }
  show heading.where(level: 4): it => if theme.name != "school" {
    block(above: 0pt, below: 0pt)[
      #text(
        size: actual-format.at("poem_title_size", default: 16) * 1pt,
        weight: theme.title-weight,
        fill: theme.title-fill,
        font: theme.serif,
      )[#it.body]
    ]
  } else {
    block(above: 0pt, below: 0.1em)[
      #text(
        size: actual-format.at("poem_title_size", default: 16) * 1pt,
        weight: "medium",
        fill: rgb("#B33A20"),
        font: ("STKaiti", "KaiTi", "Noto Serif CJK SC"),
      )[#it.body]
    ]
  }
  show heading.where(level: 2): it => align(center)[
    #if theme.name != "school" {
      text(
        font: theme.serif,
        size: if profile.paper == "a4" { theme.topic-size-a4 } else { theme.topic-size },
        fill: theme.topic-fill,
        weight: theme.title-weight,
      )[#it.body]
    } else {
      text(
        font: ("STKaiti", "KaiTi"),
        size: 15pt * aux-scale,
        fill: theme.topic-fill,
        weight: "medium",
      )[#it.body]
    }
  ]
  show heading.where(level: 3): it => align(center)[
    #if theme.name != "school" {
      text(
        font: theme.serif,
        size: if profile.paper == "a4" { theme.subtopic-size-a4 } else { theme.subtopic-size },
        fill: theme.subtopic-fill,
        weight: theme.title-weight,
      )[#it.body]
    } else {
      text(
        font: ("STKaiti", "KaiTi"),
        size: 12pt * aux-scale,
        fill: theme.subtopic-fill,
      )[#it.body]
    }
  ]
  // Kindle pages are short; tighter topic/subtopic spacing keeps the first
  // poem of a topic on the same page whenever it fits. Large print uses the
  // same idea so a heading does not push a short poem out of its panel.
  let compact-headings = profile.paper == "kindle" or aux-scale > 1.2
  show heading.where(level: 2): set block(
    above: if compact-headings { 0.7em } else { auto },
    below: if compact-headings { 0.2em } else { auto },
  )
  show heading.where(level: 3): set block(
    above: if compact-headings { 0.4em } else { auto },
    below: if compact-headings { 0.1em } else { auto },
  )
  set columns(gutter: actual-format.gutter_pt * 1pt)
  set page(
    ..profile.page-args,
    margin: profile.margin,
    columns: actual-format.columns,
    fill: theme.page-fill,
    numbering: "1",
    header: _chapter-header(theme: theme),
    footer: context {
      let page-no = counter(page).get().first()
      align(if calc.odd(page-no) { right } else { left })[
        #text(
          size: 8.5pt,
          fill: theme.at("footer-fill", default: theme.page-number-fill),
        )[#counter(page).display()]
      ]
    },
  )

  _book-cover(book, profile, actual-cover-mode, asset-root)
  _title-page(book, profile, actual-cover-mode, theme: theme)
  if actual-features.at("front_matter", default: false) {
    _preface-page(
      book,
      profile,
      theme: theme,
      body-size: actual-format.body_size * 1pt,
      body-font: actual-fonts.body,
      scale: aux-scale,
    )
  }
  _toc-page(
    book,
    profile,
    actual-format.columns,
    theme: theme,
    scale: aux-scale,
  )
  for chapter in book.chapters {
    _chapter-cover(chapter, profile, theme: theme)
    if poems-per-page >= 2 and profile.paper != "kindle" {
      _poem-pages-2up(
        chapter,
        actual-format,
        actual-notes.mode,
        profile,
        pinyin: pinyin,
        pinyin-mode: pinyin-mode,
        body-font: actual-fonts.body,
        title-font: actual-fonts.title,
        theme: theme,
      )
    } else {
      page(
        ..profile.page-args,
        margin: profile.margin,
        columns: actual-format.columns,
      )[
        #let last-topic = ""
        #let last-subtopic = ""
        #for (poem-index, poem) in chapter.poems.enumerate() {
          // On the 6-inch page a poem plus its notes rarely shares a page well.
          // Start every poem on a fresh page so one poem's notes can never sit
          // above the next poem's title.
          if profile.paper == "kindle" and poem-index > 0 {
            pagebreak(weak: true)
          }
          let topic = poem.at("topic", default: "")
          let subtopic = poem.at("subtopic", default: "")
          if topic != "" and topic != last-topic {
            _topic-heading(topic, chapter)
            last-topic = topic
            last-subtopic = ""
          }
          if subtopic != "" and subtopic != last-subtopic {
            _subtopic-heading(subtopic, chapter)
            last-subtopic = subtopic
          }
          _poem-block(
            poem,
            actual-format,
            actual-notes.mode,
            profile,
            pinyin: pinyin,
            pinyin-mode: pinyin-mode,
            body-font: actual-fonts.body,
            title-font: actual-fonts.title,
            theme: theme,
          )
        }
      ]
    }
  }
  if actual-features.at("poet_bio", default: false) {
    _poet-page(
      book,
      profile,
      theme: theme,
      body-size: actual-format.body_size * 1pt,
      scale: aux-scale,
    )
  }
  if actual-features.at("famous_lines", default: false) {
    _famous-lines-page(
      book,
      profile,
      theme: theme,
      body-size: actual-format.body_size * 1pt,
      scale: aux-scale,
    )
  }
  if actual-features.at("author_index", default: false) {
    _author-index-page(book, profile, theme: theme, scale: aux-scale)
  }
  if actual-features.at("reading_notes", default: false) {
    _reading-notes-page(book, profile, theme: theme, scale: aux-scale)
  }
  if actual-features.at("end_page", default: false) {
    _end-page(book, profile, theme: theme, scale: aux-scale)
  }
  if actual-features.at("back_cover", default: false) {
    _back-cover(book, profile, asset-root)
  }
}
