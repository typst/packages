
// default theme and layout functions
// imports utils

#import "utils.typ": *

#let _default-container = (
  x: 0,
  y: 0,
  width: 1189,
  height: 841,
)

#let _default-frames = (
  outlook: (x: 629, y: 601, width: 500, height: 180),
  methods: (x: 847, y: 60, width: 272, height: 405),
  illustration: (x: 629, y: 479, width: 500, height: 108),
  description: (x: 629, y: 60, width: 189, height: 405),
  introduction: (x: 186, y: 657, width: 374, height: 124),
  details: (x: 66, y: 669, width: 106, height: 100),
  subtitle: (x: 66, y: 618, width: 494, height: 25),
  title: (x: 60, y: 563, width: 500, height: 55),
  cover-image: (x: 60, y: 60, width: 500, height: 500),
)

#let _page-foreground(bleed: 8.5pt, trim: 29.5pt, frames: none) = {
  // outer
  crop-marks(
    distance: trim - bleed,
    offset: 0pt,
    length: trim - bleed - 0pt,
    stroke: .5pt + black,
  )
  if frames != none {
    // debug boxes

    frames.pairs()
      .map(f => place(dx: f.at(1).x * 1mm, dy: f.at(1).y * 1mm, rect(
        width: f.at(1).width * 1mm,
        height: f.at(1).height * 1mm,
        stroke: (dash: "dashed"),
      )))
      .join()
  }

  // inner with outline
  crop-marks(distance: trim, length: trim + 2pt, stroke: 2pt + white)
  crop-marks(distance: trim, length: trim + 2pt, stroke: 0.5pt + black)
}


#let theme-helper(
  palette: (
    base: luma(10%),
    fg: black,
    bg: white,
    highlight: rgb("#E75731ff"),
    contrast: rgb("#3A4D6Eff"),
    melon: rgb("#FEBFAAff"),
  ),
  fonts: (
    base: ("Source Sans Pro", "Noto Serif CJK SC"), // for chinese characters
    raw: "Source Code Pro",
    math: (
      "Fira Math",
      "New Computer Modern Math",
    ), // good to have safe fallback
  ),
  overrides: (:),
) = {
  let tmp-theme = (
    palette: palette,
    text: (
      title: (
        font: fonts.base,
        size: 180pt,
        weight: "thin",
        features: (smcp: 1, c2sc: 1, onum: 1),
        tracking: 4pt,
        fill: palette.contrast,
      ),
      subtitle: (
        size: 54pt,
        weight: 200,
        tracking: 0pt,
        fill: palette.highlight.darken(40%),
        features: (smcp: 1, c2sc: 1, onum: 1),
      ),
      author: (
        size: 28pt,
        weight: "regular",
        fill: palette.highlight.darken(40%),
      ),
      affiliation: (
        font: fonts.raw,
        weight: 300,
        fill: palette.highlight.darken(40%),
        size: 20pt,
        features: (smcp: 0, c2sc: 1, onum: 1),
      ),
      date: (
        font: fonts.raw,
        fill: palette.highlight.darken(40%), size: 20pt),
      credit: (
        font: fonts.base,
        size: 16pt,
        weight: 300,
        fill: palette.highlight.darken(40%),
      ),
      heading: (
        size: 30pt,
        font: fonts.base,
        weight: "regular",
        features: (smcp: 1, c2sc: 1, onum: 1),
        fill: palette.highlight.darken(40%),
      ),
      subheading: (
        size: 26pt,
        font: fonts.base,
        features: (smcp: 1, c2sc: 1, onum: 1),
        weight: "regular",
        fill: palette.highlight.darken(40%),
      ),
      introduction: (
        size: 22pt,
        font: fonts.base,
      ),
      outlook: (fill: luma(30%)),
      default: (
        size: 22pt,
        font: fonts.base,
      ),
      raw: (font: fonts.raw),
      math: (font: fonts.math),
    ),
    par: (
      title: (leading: 0.5em),
      subtitle: (:),
      author: (leading: 0.8em),
      affiliation: (leading: 0.8em),
      date: (leading: 0.8em),
      credit: (:),
      heading: (:),
      subheading: (:),
      introduction: (:),
      outlook: (justify: false),
      default: (justify: true, leading: 0.52em),
      raw: (:),
      math: (:),
    ),
  )

  // merge theme with overrides
  return dict-merge(tmp-theme, overrides)
}

#let _default-theme = theme-helper()

// from a theme list, create element-specific styles
#let create-styles(
  theme: _default-theme,
  tags: (
    // at a minimum, must have default par and text fields
    "default",
    "raw",
    "math",
  ),
) = {
  for t in tags {
    let tmp-text = if t in theme.text.keys() {
      theme.text.at(t)
    } else {
      theme.text.default
    }
    let tmp-par = if t in theme.par.keys() {
      theme.par.at(t)
    } else {
      theme.par.default
    }
    ((t): show-set(text-args: tmp-text, par-args: tmp-par))
  }
}


#let _page-background = {
  let padding = 1cm
  let col1 = _default-theme.palette.melon.darken(1%)
  let col2 = _default-theme.palette.contrast.lighten(60%)
  let col3 = _default-theme.palette.contrast.lighten(98%)
  let col4 = _default-theme.palette.melon

  // right page
  place(right + top, rect(width: 50%, height: 100%, fill: col1.desaturate(80%).lighten(20%)))

  // coloured frame around whole poster
  let xmid = (_default-container.width/2 - 12.5) * 1mm
  let xrig = (_default-container.width - 25) * 1mm
  let ybot = (_default-container.height - 25) * 1mm

    // left page
  place(dx: 12.5mm, dy: 12.5mm, 
  // rect(
  //   stroke: col4 + 10pt,
  //   width: (_default-container.width - 25) * 1mm,
  //   height: (_default-container.height - 25) * 1mm,
  // )
  
  curve(
  fill: none,
  stroke: col1.desaturate(80%).lighten(20%) + 10pt,
  curve.move((xmid, 0mm)),
  curve.line((0mm, 0mm)),
  curve.line((0mm, ybot)),
  curve.line((xmid, ybot)),
)
  )

    // right page
  place(dx: 12.5mm, dy: 12.5mm, 
  curve(
  fill: none,
  stroke: white + 10pt,
  curve.move((xmid, 0mm)),
  curve.line((xrig, 0mm)),
  curve.line((xrig, ybot)),
  curve.line((xmid, ybot)),
)
)

  // details box
  place(
    left + top,
    dx: _default-frames.details.x * 1mm - padding,
    dy: _default-frames.details.y * 1mm - padding,
    rect(
      width: _default-frames.details.width * 1mm + padding,
      stroke: (left: (thickness: 2mm, paint: col2.transparentize(40%))),
      height: _default-frames.details.height * 1mm + 2 * padding,
      fill: col2.transparentize(100%),
      radius: 0mm,
    ),
  )

  //methods box
  place(
    left + top,
    dx: _default-frames.methods.x * 1mm - padding,
    dy: _default-frames.methods.y * 1mm - padding,
    rect(
      width: _default-frames.methods.width * 1mm + 2 * padding,
      height: _default-frames.methods.height * 1mm + 1.2 * padding,
      fill: col3,
      radius: 5mm,
    ),
  )
}
