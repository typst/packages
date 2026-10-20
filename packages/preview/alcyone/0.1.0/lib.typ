// --- Hash generator ---
#let seed-bytes(value) = {
  let data = bytes(repr(value))
  let modulus = 2147483647 // 2^31 - 1 (Mersenne prime)

  // Fold the input bytes into a single seed (djb2-style rolling hash)
  let acc = 5381
  for b in data {
    acc = calc.rem(acc * 33 + b, modulus)
  }
  if acc == 0 { acc = 1 } // Avoid the LCG's fixed point

  // Expand the seed into a 32-byte pseudo-random digest via a Park–Miller/Lehmer LCG
  let state = acc
  let out = ()
  for _ in range(32) {
    state = calc.rem(state * 48271, modulus)
    out.push(calc.rem(state, 256))
  }
  out
}

// --- Circles background ---
#let procedural-circles(
  seed-text,
  width,
  height,
  palette: auto,
  count: none,
  transparency: none,
  accent: none,
  background-color: none,
  font-color: none,
) = {
  let resolved-palette = if palette == auto {
    (
      accent,
      color.mix(
        (accent, 3),
        (background-color, 2),
        space: oklab,
      ),
      color.mix(
        (accent, 1),
        (background-color, 1),
        space: oklab,
      ),
      color.mix((accent, 2), (font-color, 1), space: oklab),
      color.mix((accent, 1), (font-color, 1), space: oklab),
    )
  } else {
    palette
  }
  let digest = seed-bytes(seed-text)
  let n = digest.len()
  let scale = (width + height) / 2
  box(width: width, height: height, clip: false, {
    for i in range(count) {
      let o = calc.rem(i * 3, n)
      let bx = digest.at(o)
      let by = digest.at(calc.rem(o + 1, n))
      let br = digest.at(calc.rem(o + 2, n))
      let x = (bx / 255) * width
      let y = (by / 255) * height
      let radius = scale * (0.08 + 0.16 * (br / 255))
      place(
        top + left,
        dx: x - radius / 2,
        dy: y - radius / 2,
        circle(
          radius: radius,
          fill: resolved-palette
            .at(calc.rem(i, resolved-palette.len()))
            .transparentize(transparency),
          stroke: none,
        ),
      )
    }
  })
}

#let slides(
  // --- Metadata ---
  title: none,
  subtitle: none,
  author: none,
  date: none,

  // --- Appearance ---
  accent: gradient.linear(
    rgb("#AA86CF"),
    rgb("#d56199"),
    angle: 45deg,
  ),
  background-color: rgb("#F5F5F4"),
  font-color: rgb("#555555"),
  font-face: "Roboto Flex",
  font-size: 20pt,
  mono-font-face: "Adwaita Mono",

  // --- Procedural background ---
  background-generator: procedural-circles.with(count: 5),

  // --- Layout ---
  content-align: start + top,
  paper-size: "presentation-16-9",

  // --- Presentation ---
  footer-label: none,
  language: "en",
  outline-page: false,
  outline-page-heading: auto,
  title-page: true,

  // --- Content ---
  body,
) = {
  // --- Derived type scale (major third × 1.25) ---
  let type-scale = 1.25
  let fine-size = font-size * calc.pow(type-scale, -2)
  let caption-size = font-size * calc.pow(type-scale, -1)
  let lead-size = font-size * calc.pow(type-scale, 1)
  let heading-size = font-size * calc.pow(type-scale, 2)
  let display-size = font-size * calc.pow(type-scale, 3)
  let title-size = font-size * calc.pow(type-scale, 4)

  // --- Derived colors ---
  let accent-flat = if type(accent) == gradient {
    accent.sample(50%)
  } else {
    accent
  }
  let combined-font-accent = color.mix(
    (
      accent-flat,
      2,
    ),
    (background-color, 7),
    space: oklab,
  )
  let combined-font-background-color = color.mix(
    (font-color, 1),
    (background-color, 1),
    space: oklab,
  )
  let secondary-background-color = color.mix(
    (font-color, 1),
    (background-color, 8),
    space: oklab,
  )

  // --- Custom font styles ---
  let superheavy(body) = text(
    variations: (wght: 1000, wdth: 151, YOPQ: 100),
    upper(body),
  )

  // --- Background transparency ---
  let content-background-transparency = 95%
  let feature-background-transparency = 55%

  // --- Background generator ---
  let procedural-background(seed-text, ..overrides) = context {
    background-generator(
      seed-text,
      page.width,
      page.height,
      accent: accent-flat,
      background-color: background-color,
      font-color: font-color,
      ..overrides,
    )
  }
  let resolve-background(
    value,
    seed-text,
    ..overrides,
  ) = {
    if value == none {
      none
    } else if value == auto {
      procedural-background(seed-text, ..overrides)
    } else {
      value
    }
  }

  // --- Derived units ---
  let unit = font-size * 1.7
  // Side margin for body content
  let margin-x = unit * 1.5
  // Header bar height
  let bar-top = unit * 2
  // Footer bar height
  let bar-bottom = unit

  // --- Derived lengths ---
  // Breathing room between bars and body
  let gap = unit * 0.6
  // Top page margin (bar + gap)
  let margin-top = bar-top + gap
  // Bottom page margin (bar + gap)
  let margin-bottom = bar-bottom + gap

  // --- Derived metadata ---
  let authors = if author == none {
    ()
  } else if type(author) == str or type(author) == dictionary {
    (author,)
  } else {
    author
  }
  let author-names = authors.map(a => if type(a) == str {
    a
  } else if type(a) == dictionary {
    a.name
  } else if a.len() == 1 {
    a.at(0)
  } else if a.at(0).contains("@") {
    a.at(1)
  } else {
    a.at(0)
  })
  let author-emails = authors.map(a => if type(a) == str {
    none
  } else if type(a) == dictionary {
    a.email
  } else if a.len() == 1 {
    none
  } else if a.at(0).contains("@") {
    a.at(0)
  } else {
    a.at(1)
  })
  let date-value = if date == none {
    datetime.today()
  } else if type(date) == datetime {
    date
  } else if type(date) == dictionary {
    date.value
  } else {
    date.at(0)
  }
  let date-format = if date == none or type(date) == datetime {
    "[day] [month repr:long] [year]"
  } else if type(date) == dictionary {
    date.format
  } else {
    date.at(1)
  }

  // --- Document metadata ---
  if author-names.len() > 0 {
    set document(
      title: title,
      author: author-names,
      date: date-value,
    )
  } else {
    set document(
      title: title,
      date: date-value,
    )
  }

  // --- Type config ---
  set text(
    fill: font-color,
    font: font-face,
    lang: language,
    size: font-size,
    variations: (
      wdth: 85,
      GRAD: -100,
      XTRA: 425,
    ),
  )
  show raw: set text(font: mono-font-face)
  set align(content-align)

  // ── Lists config ---
  let marker-width = 0.5em
  set list(
    body-indent: unit / 2,
    marker: (
      box(width: marker-width, text(
        fill: accent-flat,
        weight: "bold",
        "•",
      )),
      box(width: marker-width, text(
        fill: accent-flat,
        weight: "bold",
        "‣",
      )),
      box(width: marker-width, text(
        fill: accent-flat,
        weight: "bold",
        "–",
      )),
    ),
  )
  set enum(
    body-indent: unit / 2,
    number-align: start,
    numbering: (..nums) => box(
      width: marker-width,
      text(
        fill: accent-flat,
        weight: "medium",
        numbering(
          "1.a.i.",
          ..nums,
        ),
      ),
    ),
  )
  set terms(
    separator: h(marker-width, weak: true),
  )
  show terms.item: it => par(
    hanging-indent: unit / 2 + marker-width,
    {
      text(
        weight: "medium",
        fill: accent-flat,
        it.term,
      )
      h(marker-width)
      it.description
    },
  )

  // --- Figure caption config ---
  show figure.caption: it => {
    text(size: caption-size, {
      strong({
        it.supplement
        " "
        context it.counter.display(it.numbering)
        ": "
      })
      it.body
    })
  }

  // --- Code config ---
  show raw.where(block: true): block.with(
    inset: (x: unit / 2, y: unit / 2),
    width: 100%,
    fill: color
      .mix((accent-flat, 3), (background-color, 1), space: oklab)
      .transparentize(90%),
  )
  show raw.where(block: true): set par(justify: false)

  // --- Tables config ---
  set table(
    inset: (x: gap / 2, y: gap / 2),
    stroke: none,
    fill: (x, y) => if y == 0 {
      color
        .mix((accent-flat, 3), (font-color, 1), space: oklab)
        .transparentize(50%)
    } else if calc.odd(y) {
      secondary-background-color.transparentize(50%)
    } else if calc.even(y) {
      background-color.transparentize(50%)
    } else {
      none
    },
  )
  show table.cell: set text(size: caption-size)
  show table.cell.where(y: 0): it => {
    text(
      weight: "bold",
      fill: background-color,
      it,
    )
  }

  // --- Content slide ---
  set page(
    paper: paper-size,
    margin: (
      top: margin-top,
      bottom: margin-bottom,
      x: margin-x,
    ),
    fill: background-color,
    background: context {
      let current = here().page()
      let h = query(heading.where(level: 2))
        .rev()
        .find(x => x.location().page() <= current)
      let seed-text = if h != none {
        (h.body, current)
      } else {
        "content-page-" + str(current)
      }
      procedural-background(
        seed-text,
        transparency: content-background-transparency,
      )
    },
    header-ascent: 0mm,
    header: context {
      let current = here().page()
      let h = query(heading.where(level: 2))
        .rev()
        .find(x => x.location().page() <= current)
      if h != none and h.location().page() == current {
        place(dx: -margin-x, dy: gap, block(
          width: page.width,
          height: bar-top,
          inset: (left: margin-x, y: margin-x),
          align(horizon, text(
            size: lead-size,
            superheavy(h.body),
          )),
        ))
      }
    },
    footer-descent: 0mm,
    footer: context place(bottom, dx: -margin-x, box(
      width: page.width,
      height: bar-bottom,
      {
        place(left + horizon, dx: margin-x, text(
          size: fine-size,
          weight: "medium",
          fill: combined-font-background-color,
          footer-label,
        ))
        place(right + horizon, dx: -margin-x, text(
          size: fine-size,
          weight: "medium",
          fill: combined-font-background-color,
          counter(
            page,
          ).display(),
        ))
      },
    )),
  )

  // --- Section slide ---
  show heading.where(level: 1): it => page(
    background: procedural-background(
      it.body,
      transparency: feature-background-transparency,
    ),
    margin: 0%,
    fill: accent,
    header: none,
    footer: none,
    {
      align(center + horizon, {
        text(
          size: heading-size,
          fill: background-color,
          superheavy(it.body),
        )
      })
    },
  )

  // --- Slide header ---
  show heading.where(level: 2): it => pagebreak(weak: true)

  // --- Sub-section heading ---
  show heading.where(level: 3): set text(fill: accent-flat)

  // --- Figure slide ---
  show figure: it => page(
    margin: (
      top: margin-bottom,
      bottom: margin-bottom,
      x: margin-x,
    ),
    {
      place(center + horizon, block({
        it.body
        it.caption
      }))
    },
  )

  // --- Quote slide ---
  show quote.where(block: true): it => page(
    background: procedural-background(
      (it.body, it.attribution),
      transparency: feature-background-transparency,
    ),
    margin: 23%,
    header: none,
    footer: none,
    fill: accent,
    place(center + horizon, block({
      text(
        fill: background-color,
        size: lead-size,
        it.body,
      )
      if it.attribution != none {
        align(right, text(
          fill: combined-font-accent,
          size: caption-size,
          text("— " + it.attribution),
        ))
      }
    })),
  )

  // --- Title slide ---
  if title-page == true {
    page(
      background: resolve-background(
        auto,
        (title, subtitle),
        transparency: feature-background-transparency,
      ),
      margin: 0%,
      header: none,
      footer: none,
      fill: accent,
      {
        align(center + horizon, {
          v(3fr)
          box(width: 75%, align(left, {
            text(
              size: title-size,
              fill: background-color,
              superheavy(title),
            )
            linebreak()
            text(
              size: font-size,
              fill: combined-font-accent,
              subtitle,
            )
            v(15pt)
            if author-names.len() > 0 {
              text(
                size: caption-size,
                weight: "bold",
                fill: background-color,
                {
                  for (i, name) in author-names.enumerate() {
                    let last = i == author-names.len() - 1
                    if i > 0 {
                      if last {
                        if author-names.len() == 2 {
                          " and "
                        } else {
                          ", and "
                        }
                      } else {
                        ", "
                      }
                    }
                    let email = author-emails.at(i)
                    if email != none {
                      link(
                        "mailto:" + email,
                        name,
                      )
                    } else {
                      name
                    }
                  }
                },
              )
            }
            if author-names.len() > 0 and date != none {
              linebreak()
            }
            text(
              size: caption-size,
              fill: combined-font-accent,
              {
                if date != none {
                  date-value.display(date-format)
                }
              },
            )
          }))
          v(2fr)
        })
      },
    )
  }

  // --- Contents page ---
  show outline: set align(horizon)
  show outline: set heading(level: 2)
  if outline-page == true {
    outline(title: outline-page-heading)
  }

  // --- Bibliography page ---
  show bibliography: set heading(level: 2)
  show bibliography: set par(
    leading: font-size * 2 / 3,
    spacing: font-size * 2 / 3,
  )
  show bibliography: set text(size: caption-size)

  // --- Document body ---
  body
}

