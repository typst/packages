// Paper measures
#let width = 21cm
#let height = width * calc.sqrt(2)

// Paper margins
#let t-margin = width / 9
#let e-margin = width / 4
#let f-margin = width / 6
#let s-margin = width / 9

// Text body measures
#let t-width = width - s-margin - e-margin
#let t-height = height - t-margin - f-margin

// Gutter and margin sidenotes
#let half-gutter = 0.3cm
#let e-margin-margin = s-margin / 3

// Text measures
#let text-size = 12pt
#let text-height = 9pt // Approximately the ascender height

// Baseline grid
#let step = 16pt
#let step-num = calc.floor(t-height / step)
#let f-margin = height - t-margin - step-num * step // recalculate bottom margin to align with baseline grid

#let box-top-outset = text-height + half-gutter
#let margin-w = e-margin - half-gutter - e-margin-margin

// Fonts
#let body-font = "TeX Gyre Pagella"
#let math-font = "TeX Gyre Pagella Math"
#let sans-font = "Switzer"
#let mono-font = "IBM Plex Mono"

#let or-default(dict, ..default) = {
  return (:..default.named(), ..dict)
}

#let or-default-settings(
  paper,
  margin,
  side,
  texts,
  fonts,
) = {
  let paper = or-default(paper, width: width, height: height);
  let margin = or-default(margin, t: t-margin, f: f-margin, e: e-margin, s: s-margin);
  let body = (width: paper.width - margin.e - margin.s, height: paper.height - margin.t - margin.f);
  let texts = or-default(texts, size: text-size, ascender: text-height, step: step, step-num: step-num);
  texts.step-num = calc.floor(body.height / texts.step);
  margin.f = paper.height - margin.t - texts.step-num * texts.step;
  body.height = paper.height - margin.t - margin.f;
  let side = or-default(side, half-gutter: half-gutter, margin: e-margin-margin, width: 0pt);
  side.width = margin.e - side.half-gutter - side.margin;
  let fonts = or-default(fonts, body: body-font, math: math-font, sans: sans-font, mono: mono-font);
  return (
    paper: paper,
    body: body,
    margin: margin,
    side: side,
    texts: texts,
    fonts: fonts,
  )
}

#let default-settings = state("obelisk:default-settings", none)
