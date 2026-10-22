// A small, data-driven poetry book template.

#let _page-profile(format) = {
  let paper = format.paper
  let margin = if paper == "a6" {
    (left: 18mm, right: 14mm, top: 16mm, bottom: 15mm)
  } else if paper == "a5" {
    (left: 20mm, right: 17mm, top: 19mm, bottom: 18mm)
  } else {
    (left: 22mm, right: 20mm, top: 21mm, bottom: 20mm)
  }
  (
    paper: paper,
    margin: margin,
    title-size: if paper == "a6" { 16pt } else if paper == "a5" { 18pt } else { 20pt },
    chapter-size: if paper == "a6" { 22pt } else if paper == "a5" { 26pt } else { 30pt },
    author-size: if paper == "a6" { 8.5pt } else { 9.5pt },
    poem-gap: if paper == "a6" { 9pt } else if paper == "a5" { 12pt } else { 15pt },
  )
}

#let _vertical-text(value, size, fill: black, spacing: 0.1em) = stack(
  dir: ttb,
  spacing: spacing,
  ..value.clusters().map(ch => text(
    font: ("STKaiti", "KaiTi", "Noto Serif CJK SC"),
    size: size,
    fill: fill,
  )[#ch]),
)

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

#let _author-line(poem, size) = if poem.author != "" {
  text(size: size, fill: luma(92), font: ("STKaiti", "KaiTi", "Noto Serif CJK SC"))[
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
      text(font: py-font, size: py-size, fill: py-fill)[#reading#h(0.05em)]
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
) = block(width: 100%, height: 1.62 * size)[
  #place(center + top)[
    #_ruby-line(
      ((str(poem.number) + "．", ""),),
      size: size,
      py-size: py-size,
      hanzi-font: title-font,
      hanzi-fill: rgb("#B33A20"),
      box-height: 1.62,
    )
    #_ruby-line(
      py-data.title,
      size: size,
      py-size: py-size,
      hanzi-font: title-font,
      hanzi-fill: rgb("#B33A20"),
      py-fill: luma(105),
      box-height: 1.62,
    )
  ]
  #place(center + bottom)[
    #heading(level: 4, outlined: true, bookmarked: true)[
      #text(fill: rgb(0, 0, 0, 0))[#poem.number．#poem.title]
    ]
  ]
]

#let _short-notes(notes, size) = if notes.len() > 0 {
  v(0.65em)
  line(length: 100%, stroke: 0.6pt + luma(205))
  v(0.35em)
  for (index, note) in notes.enumerate() {
    text(size: size, fill: luma(78))[
      注#(index + 1)　#note.headword：#note.text
    ]
    linebreak()
  }
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
) = {
  let py-data = _poem-pinyin(pinyin, poem)
  let use-pinyin = pinyin-mode and py-data != none
  let title-size = format.at("title_size", default: 16) * 1pt
  let title-py-size = format.at("title_pinyin_size", default: 8) * 1pt
  let author-size = format.at("author_size", default: 9.5) * 1pt
  let author-py-size = format.at("author_pinyin_size", default: 6.6) * 1pt
  let body-size = format.body_size * 1pt
  let body-py-size = format.at("pinyin_size", default: 7.7) * 1pt
  let page-width = if profile.paper == "a6" {
    105mm
  } else if profile.paper == "a5" {
    148mm
  } else {
    210mm
  }
  let content-width = page-width - profile.margin.left - profile.margin.right
  let column-width = if format.columns == 2 {
    (content-width - format.gutter_pt * 1pt) / 2
  } else {
    content-width
  }
  context {
    // A poem is long when at least one of its lines would wrap in the
    // current column. This is evaluated per edition, so single-column,
    // double-column and pinyin layouts can disagree.
    let is-long = poem.lines.enumerate().any(pair => {
      let index = pair.at(0)
      let line = pair.at(1)
      let item = if use-pinyin and py-data.at("lines", default: none) != none {
        _ruby-line(
          py-data.lines.at(index),
          size: body-size,
          py-size: body-py-size,
          hanzi-font: body-font,
          hanzi-fill: black,
          py-fill: luma(95),
          box-height: 1.55,
        )
      } else {
        text(font: body-font, size: body-size)[#line]
      }
      measure(item).width > column-width
    })
    block(
      width: 100%,
      breakable: is-long or poem.lines.len() > 4,
      inset: (x: 0pt, y: 0pt),
    )[
      #v(0pt)
      #align(center)[
        #if use-pinyin and py-data.at("title", default: none) != none {
          _pinyin-title(
            poem,
            py-data,
            size: title-size,
            py-size: title-py-size,
            title-font: title-font,
          )
        } else {
          heading(level: 4, outlined: true, bookmarked: true)[
            #poem.number．#poem.title
          ]
        }
        #if poem.at("poem_id", default: "") != "" {
          label("poem-" + poem.poem_id)
        }
        #v(0.08em)
        #if use-pinyin and py-data.at("author", default: none) != none {
          _ruby-line(
            py-data.author,
            size: author-size,
            py-size: author-py-size,
            hanzi-font: title-font,
            hanzi-fill: luma(92),
            py-fill: luma(120),
            box-height: 1.55,
          )
        } else {
          _author-line(poem, author-size)
        }
        #v(0.8em)
      ]
      #set par(
        justify: false,
        leading: if pinyin-mode { 0.65em } else { (format.leading - 1.0) * 1em },
        spacing: 0.8em,
      )
      #if is-long {
        set par(
          justify: if pinyin-mode { false } else { true },
          first-line-indent: 2em,
          spacing: 0.7em,
        )
        align(left)[
          #if use-pinyin and py-data.at("lines", default: none) != none {
            for (index, _line) in poem.lines.enumerate() {
              _ruby-line(
                py-data.lines.at(index),
                size: body-size,
                py-size: body-py-size,
                hanzi-font: body-font,
                hanzi-fill: black,
                py-fill: luma(95),
                box-height: 1.55,
              )
              parbreak()
            }
          } else {
            for line in poem.lines {
              text(size: body-size)[#line]
              parbreak()
            }
          }
        ]
      } else {
        align(center)[
          #if use-pinyin and py-data.at("lines", default: none) != none {
            for pairs in py-data.lines {
              _ruby-line(
                pairs,
                size: body-size,
                py-size: body-py-size,
                hanzi-font: body-font,
                hanzi-fill: black,
                py-fill: luma(95),
                box-height: 1.55,
              )
              linebreak()
            }
          } else {
            text(size: body-size)[
              #for line in poem.lines {
                line
                linebreak()
              }
            ]
          }
        ]
      }
      #if note-mode == "short" {
        _short-notes(poem.notes, format.note_size * 1pt)
      }
      #v(profile.poem-gap)
    ]
  }
}

#let _book-cover(book, profile, mode, asset-root) = {
  let branding = book.at("branding", default: (:))
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
      box(fill: white, inset: 3mm, radius: 50%)[
        #_school-mark(book, width: 13mm, asset-root: asset-root)
      ],
    )
  } else {
    ()
  }
  let school-cell = if has-school {
    (
      [
        #if branding.at("school_name", default: "") != "" {
          text(fill: white, size: 10pt, weight: "medium")[#branding.at("school_name", default: "")]
        }
        #if branding.at("school_name_en", default: "") != "" {
          v(0.2em)
          text(fill: white.transparentize(12%), size: 7.5pt)[#branding.at("school_name_en", default: "")]
        }
      ],
    )
  } else {
    ()
  }
  page(
    paper: profile.paper,
    margin: 0pt,
    columns: 1,
    fill: rgb("#FAF7F0"),
    numbering: none,
  )[
    #_torn-band(rgb("#ED6C32"))
    #place(top + right, dx: -20mm, dy: 20mm)[
      #align(center)[
        #if slogan != "" {
          _vertical-text(slogan, 10pt, fill: rgb("#C4512D"))
          v(0.8em)
        }
        #_vertical-text(book.metadata.title, 30pt, fill: rgb("#E44F24"), spacing: 0.08em)
      ]
    ]
    #place(top + left, dx: 20mm, dy: 24mm)[
      #rect(width: 30mm, height: 1.6pt, fill: rgb("#ED6C32"))
      #v(0.8em)
      #text(size: 10pt, fill: luma(100), tracking: 0.1em)[#book.metadata.edition]
    ]
    #place(left + horizon, dx: 20mm)[
      #block(width: 42%, inset: (x: 4mm, y: 4mm))[
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
          text(font: ("STKaiti", "KaiTi"), size: 16pt, fill: luma(110))[
            #for (index, line) in cover-lines.enumerate() {
              if index > 0 { linebreak() }
              line
            }
          ]
        }
      ]
    ]
    #if has-logo or has-school {
      place(bottom + left, dx: 18mm, dy: -13mm)[
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

#let _title-page(book, profile, mode) = {
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
  page(
    paper: profile.paper,
    margin: 0pt,
    columns: 1,
    fill: rgb("#FCFAF5"),
    numbering: none,
  )[
    #place(top + right, dx: -25mm, dy: 26mm)[
      #align(center)[
        #if slogan != "" {
          _vertical-text(
            slogan,
            9.5pt,
            fill: rgb("#C4512D"),
          )
          v(0.7em)
        }
        #_vertical-text(
          book.metadata.title,
          27pt,
          fill: rgb("#E44F24"),
        )
      ]
    ]
    #place(top + left, dx: 22mm, dy: 24mm)[
      #rect(width: 28mm, height: 1.4pt, fill: rgb("#ED6C32"))
      #if book.metadata.at("review_mode", default: false) {
        v(3mm)
        text(size: 9pt, fill: rgb("#B33A20"))[
          #book.metadata.at("review_label", default: "审核稿") · 请勿付印
        ]
      }
    ]
    #if subtitle != "" {
      place(bottom + left, dx: 22mm, dy: -28mm)[
        #text(size: 10pt, fill: luma(100), tracking: 0.1em)[#subtitle]
      ]
    }
    #if mode == "personal" {
      place(bottom + right, dx: -28mm, dy: -28mm)[
        #block(inset: 4mm)[
          #text(font: ("STKaiti", "KaiTi"), size: 14pt, fill: luma(45))[
            班级：#(if class-name == "" { box(width: 32mm, stroke: (bottom: 0.6pt + luma(70))) } else { class-name })
            #v(1.4em)
            姓名：#(if student == "" { box(width: 32mm, stroke: (bottom: 0.6pt + luma(70))) } else { student })
          ]
        ]
      ]
    }
  ]
}

#let _preface-page(book, profile) = if book.front_matter.at("preface", default: "") != "" {
  page(
    paper: profile.paper,
    margin: profile.margin,
    columns: 1,
)[
    #align(center)[
      #block(width: 84%, inset: (x: 4mm, y: 0pt))[
        #align(center)[
          #text(
            font: ("STKaiti", "KaiTi"),
            size: 26pt,
            fill: rgb("#D5672D"),
          )[#book.front_matter.at("title", default: "卷首语")]
        ]
        #v(1.7em)
        #align(left)[
          #set par(
            justify: true,
            first-line-indent: 2em,
            leading: 0.9em,
            spacing: 1.1em,
          )
          #set text(size: 12.5pt, fill: luma(35))
          #for paragraph in book.front_matter.paragraphs {
            paragraph
            parbreak()
          }
        ]
      ]
    ]
  ]
}

#let _famous-lines-heading() = align(left)[
  #text(
    font: ("STKaiti", "KaiTi"),
    size: 18pt,
    fill: rgb("#D5672D"),
  )[【古诗词名句】]
  #line(length: 100%, stroke: 0.8pt + rgb("#DBA17C"))
]

#let _famous-lines-page(book, profile) = if book.features.at("famous_lines", default: false) {
  let lines = book.appendix.famous_lines
  let per-page = 7
  for start in range(0, lines.len(), step: per-page) {
    page(
      paper: profile.paper,
      margin: profile.margin,
      columns: 1,
    )[
      #_famous-lines-heading()
      #v(1.2em)
      #for item in lines.slice(start, calc.min(start + per-page, lines.len())) {
        block(width: 88%, breakable: false)[
          #text(font: ("STKaiti", "KaiTi"), size: 15pt, fill: luma(30))[#item.quote]
          #v(0.45em)
          #align(right)[
            #text(size: 12pt, fill: luma(60))[——#item.source]
          ]
        ]
        v(1.25em)
      }
    ]
  }
}

#let _poet-page(book, profile) = if book.features.at("poet_bio", default: false) {
  page(
    paper: profile.paper,
    margin: profile.margin,
    columns: 1,
  )[
    #align(left)[
      #text(
        font: ("STKaiti", "KaiTi"),
        size: 18pt,
        fill: rgb("#D5672D"),
      )[#book.appendix.at("poet_heading", default: "【诗人简介】")]
    ]
    #line(length: 100%, stroke: 0.8pt + rgb("#DBA17C"))
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
            font: ("STKaiti", "KaiTi"),
            size: 14pt,
            fill: rgb("#D5672D"),
            weight: "medium",
          )[#group]
          v(0.45em)
        }
        #text(
          font: ("STKaiti", "KaiTi"),
          size: 15pt,
          fill: rgb("#D5672D"),
          weight: "medium",
        )[#poet.name（#poet.years）]
        #v(0.15em)
        #set par(justify: true, leading: 0.55em, spacing: 0.9em)
        #text(size: 11pt)[#poet.bio]
      ]
      v(0.9em)
    }
  ]
}

#let _author-index-page(book, profile) = if book.features.at("author_index", default: false) {
  page(
    paper: profile.paper,
    margin: profile.margin,
    columns: 1,
  )[
    #align(left)[
      #text(
        font: ("STKaiti", "KaiTi"),
        size: 18pt,
        fill: rgb("#D5672D"),
      )[【诗人索引】]
    ]
    #line(length: 100%, stroke: 0.8pt + rgb("#DBA17C"))
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
            font: ("STKaiti", "KaiTi"),
            size: 10.5pt,
            fill: rgb(181, 83, 43),
          )[#item.name#text(
            size: 9pt,
            fill: rgb(181, 83, 43).transparentize(35%),
          )[（#item.dynasty）]],
          context text(
            size: 9.5pt,
            fill: luma(52),
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
                font: ("STKaiti", "KaiTi"),
                size: 14pt,
                fill: rgb("#D5672D"),
                weight: "medium",
              )[#initial]
              #v(0.1em)
              #line(length: 100%, stroke: 0.5pt + rgb("#DBA17C"))
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

#let _end-page(book, profile) = {
  let motto = book.at("branding", default: (:)).at("end_motto", default: "诗心常在　书香长伴")
  page(
    paper: profile.paper,
    margin: 0pt,
    columns: 1,
    fill: rgb("#F8F4EC"),
    numbering: none,
  )[
    #place(center + horizon)[
      #block(width: 72%, inset: 12mm)[
        #align(center)[
          #text(
            font: ("STKaiti", "KaiTi"),
            size: 26pt,
            fill: rgb("#DDA777"),
          )[诗]
          #v(1.2em)
          #if motto != "" {
            text(size: 10pt, fill: luma(105), tracking: 0.18em)[#motto]
          }
        ]
      ]
    ]
  ]
}

#let _back-cover(book, profile, asset-root) = {
  let branding = book.at("branding", default: (:))
  let slogan = branding.at("slogan", default: "")
  let motto = branding.at("motto", default: "")
  let has-logo = branding.at("logo", default: "") != ""
  let has-school = branding.at("school_name", default: "") != "" or branding.at("school_name_en", default: "") != ""
  let logo-cell = if has-logo {
    (
      box(fill: white, inset: 3mm, radius: 50%)[
        #_school-mark(book, width: 13mm, asset-root: asset-root)
      ],
    )
  } else {
    ()
  }
  let school-cell = if has-school {
    (
      [
        #if branding.at("school_name", default: "") != "" {
          text(fill: white, size: 10pt, weight: "medium")[#branding.at("school_name", default: "")]
        }
        #if branding.at("school_name_en", default: "") != "" {
          v(0.2em)
          text(fill: white.transparentize(12%), size: 7.5pt)[#branding.at("school_name_en", default: "")]
        }
      ],
    )
  } else {
    ()
  }
  page(
    paper: profile.paper,
    margin: 0pt,
    columns: 1,
    fill: rgb("#FAF7F0"),
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

#let _chapter-cover(chapter, profile) = page(
  paper: profile.paper,
  margin: 0pt,
  columns: 1,
  fill: rgb(chapter.bg_color),
  numbering: none,
)[
  #place(center + horizon)[
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
]

#let _toc-page(book, profile, columns) = page(
  paper: profile.paper,
  margin: profile.margin,
  columns: 1,
  numbering: none,
)[
  #align(center)[
    #text(
      font: ("STKaiti", "KaiTi"),
      size: 30pt,
      fill: rgb("#A7351D"),
    )[目录]
  ]
  #v(1.6em)
  #show outline.entry.where(level: 1): it => {
    let color = if it.element.body == [第二章 兰亭漫读] {
      rgb(111, 150, 55)
    } else {
      rgb(213, 103, 45)
    }
    set text(
      font: ("STKaiti", "KaiTi"),
      size: 14pt,
      fill: color,
      weight: "bold",
    )
    it
  }
  #show outline.entry.where(level: 2): set text(
    font: ("STKaiti", "KaiTi"),
    size: 11.5pt,
    fill: rgb(111, 150, 55),
  )
  #show outline.entry.where(level: 3): set text(
    font: ("Noto Serif CJK SC", "SimSun"),
    size: 10.8pt,
    fill: luma(45),
  )
  #show outline.entry.where(level: 4): set text(
    font: ("Noto Serif CJK SC", "SimSun"),
    size: 10.5pt,
    fill: luma(38),
  )
  #show outline.entry: it => {
    show text.where(fill: rgb(0, 0, 0, 0)): inner => text(fill: luma(38))[
      #inner.text
    ]
    it
  }
  #outline(title: none, depth: 4, indent: auto)
]

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
) = {
  if book == none {
    panic("poem-book requires a book dictionary or JSON file")
  }
  let base-format = if format == none { book.format } else { format }
  let actual-format = if pinyin-mode {
    base-format + (
      columns: 1,
      body_size: 14.0,
      leading: 2.2,
      note_size: 10.5,
      title_size: 18.0,
      title_pinyin_size: 8.0,
      author_size: 11.0,
      author_pinyin_size: 6.6,
      pinyin_size: 7.7,
    )
  } else {
    base-format
  }
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
  let profile = _page-profile(actual-format)

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
  )
  set par(justify: false)
  set heading(numbering: none)
  show heading.where(level: 1): it => text(
    font: ("STKaiti", "KaiTi"),
    size: profile.chapter-size,
    fill: white,
  )[#it.body]
  show heading.where(level: 4): it => text(
    size: 16pt,
    weight: "medium",
    fill: rgb("#B33A20"),
    font: ("STKaiti", "KaiTi", "Noto Serif CJK SC"),
  )[#it.body]
  show heading.where(level: 2): it => align(center)[
    #text(
      font: ("STKaiti", "KaiTi"),
      size: 15pt,
      fill: rgb(111, 150, 55),
      weight: "medium",
    )[#it.body]
  ]
  show heading.where(level: 3): it => align(center)[
    #text(
      font: ("STKaiti", "KaiTi"),
      size: 12pt,
      fill: luma(48),
    )[#it.body]
  ]
  set columns(gutter: actual-format.gutter_pt * 1pt)
  set page(
    paper: profile.paper,
    margin: profile.margin,
    columns: actual-format.columns,
    numbering: "1",
    footer: context align(center)[
      #let review-label = book.metadata.at("review_label", default: "")
      #if review-label != "" {
        text(size: 8.5pt, fill: luma(150))[#review-label · ]
      }
      #text(size: 8.5pt, fill: luma(120))[#counter(page).display()]
    ],
  )

  _book-cover(book, profile, actual-cover-mode, asset-root)
  _title-page(book, profile, actual-cover-mode)
  if actual-features.at("front_matter", default: false) {
    _preface-page(book, profile)
  }
  _toc-page(book, profile, actual-format.columns)
  for chapter in book.chapters {
    _chapter-cover(chapter, profile)
    page(
      paper: profile.paper,
      margin: profile.margin,
      columns: actual-format.columns,
    )[
      #let last-topic = ""
      #let last-subtopic = ""
      #for poem in chapter.poems {
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
        )
      }
    ]
  }
  if actual-features.at("poet_bio", default: false) {
    _poet-page(book, profile)
  }
  if actual-features.at("famous_lines", default: false) {
    _famous-lines-page(book, profile)
  }
  if actual-features.at("author_index", default: false) {
    _author-index-page(book, profile)
  }
  if actual-features.at("end_page", default: false) {
    _end-page(book, profile)
  }
  if actual-features.at("back_cover", default: false) {
    _back-cover(book, profile, asset-root)
  }
}
