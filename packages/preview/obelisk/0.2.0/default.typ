// Paper measures
#let width = 21cm
#let height = width * calc.sqrt(2)
#let def-paper = (width: width, height: height, two-sided: true)

// Paper margins
#let t-margin = width / 9
#let e-margin = width / 4
#let f-margin = width / 6
#let s-margin = width / 9
#let def-margin = (
  t: t-margin,
  f: f-margin,
  e: e-margin,
  s: s-margin,
)

// Text body measures
#let t-width = width - s-margin - e-margin
#let t-height = height - t-margin - f-margin

// Gutter and margin sidenotes
#let half-gutter = 0.3cm
#let e-margin-margin = s-margin / 3

// Text measures
#let text-size = 12pt
#let text-height = 10pt // Approximately the ascender height

// Baseline grid
#let step = 16pt
#let step-num = calc.floor(t-height / step)
#let f-margin = height - t-margin - step-num * step // recalculate bottom margin to align with baseline grid

#let def-texts = (
  size: text-size,
  ascender: text-height,
  step: step,
)
#let def-side = (
  half-gutter: half-gutter,
  margin: e-margin-margin,
)

// Fonts
#let body-font = "TeX Gyre Pagella"
#let math-font = "TeX Gyre Pagella Math"
#let sans-font = "Inter"
#let mono-font = "IBM Plex Mono"
#let def-fonts = (
  body: body-font,
  math: math-font,
  sans: sans-font,
  mono: mono-font,
)

#let def-headers = (
  h2: (
    sym: sym.circle.filled,
    dy: 0pt,
    size: 2,
  ),
  h3: (
    sym: sym.triangle.filled.small.b,
    dy: 0pt,
    size: 1.5,
  ),
)

#let def-deco = (line-number: true)

#let rec-or-default(user, defaults) = {
  if user == none { return defaults }

  if (
    type(user) != dictionary or type(defaults) != dictionary
  ) { return defaults }

  for (key, value) in defaults {
    if type(defaults.at(key)) == dictionary {
      if not user.keys().contains(key) {
        user.insert(key, value)
      } else if type(user.at(key)) == dictionary {
        user.at(key) = rec-or-default(user.at(key), value)
      }
    } else if (
      user.keys().contains(key) and user.at(key) == none
    ) {
      user.at(key) = value
    } else if not user.keys().contains(key) {
      user.insert(key, value)
    }
  }
  return user
}

#let or-default-settings(
  paper,
  margin,
  side,
  texts,
  fonts,
  deco,
  headers,
) = {
  let (
    paper,
    margin,
    side,
    texts,
    fonts,
    deco,
    headers,
  ) = rec-or-default(
    (
      paper: paper,
      margin: margin,
      side: side,
      texts: texts,
      fonts: fonts,
      deco: deco,
      headers: headers,
    ),
    (
      paper: def-paper,
      margin: def-margin,
      side: def-side,
      texts: def-texts,
      fonts: def-fonts,
      deco: def-deco,
      headers: def-headers,
    ),
  )
  let body = (
    width: paper.width - margin.s - margin.e,
    height: paper.height - margin.t - margin.f,
  )
  texts.step-num = calc.floor(body.height / texts.step)
  texts.descender = 0pt
  margin.f = (
    paper.height - margin.t - texts.step-num * texts.step
  )
  body.height = paper.height - margin.t - margin.f
  side.width = margin.e - side.margin - side.half-gutter
  return (
    paper: paper,
    body: body,
    margin: margin,
    side: side,
    texts: texts,
    fonts: fonts,
    deco: deco,
    headers: headers,
  )
}

#let default-settings = state(
  "obelisk:default-settings",
  none,
)
