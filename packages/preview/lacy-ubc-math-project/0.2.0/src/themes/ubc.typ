///////////////
/* Resources */
///////////////

#import "../defaults.typ": question-container

//SOURCE: https://assets.brand.ubc.ca/downloads/ubc_brand_identity_rules.pdf
#let palette = (
  ubc: (
    white: rgb(0xff, 0xff, 0xff),
    blue-main: rgb(0x00, 0x21, 0x45),
    blue-naval-night: rgb(0x01, 0x1E, 0x42),
    blue-london-rain: rgb(0x00, 0x55, 0xb7),
    blue-vanadyl: rgb(0x00, 0xa7, 0xe1),
    blue-summer-sky: rgb(0x40, 0xb4, 0xe5),
    blue-norfolk-sky: rgb(0x6e, 0xc4, 0xe8),
    blue-effervescence: rgb(0x97, 0xd4, 0xe9),
  ),
  stsc: (
    blue-main: rgb(0x00, 0x88, 0xcc),
    cyan-know-my-campus: rgb(0x15, 0x94, 0xa6),
    orange-plan-for-success: rgb(0xff, 0x82, 0x00),
    green-live-well-to-learn-well: rgb(0x58, 0xa2, 0x29),
    red-have-some-fun: rgb(0xcb, 0x1d, 0x38),
    violet-build-my-career: rgb(0x50, 0x15, 0x8b),
    blue-manage-my-courses-money-n-enrolment: rgb(0x23, 0x49, 0x9c),
  ),
  apsc: (
    engi: (
      red-japanese-carmine: rgb(0xa6, 0x19, 0x2e),
      red-titans: rgb(0xc8, 0x10, 0x2E),
      red-maximum: rgb(0xdA, 0x29, 0x1c),
    ),
    nurs: (
      indigo-persian: rgb(0x33, 0x00, 0x72),
      purple-rebecca: rgb(0x58, 0x2c, 0x83),
      purple-maximum: rgb(0x6d, 0x20, 0x77),
    ),
    sala: (
      green-dark-jungle: rgb(0x14, 0x1f, 0x19),
      green-phthalo: rgb(0x19, 0x30, 0x1c),
      green-dark-sea: rgb(0x89, 0xc9, 0x92),
    ),
    scrp: (
      orange-sinopia: rgb(0xdc, 0x44, 0x05),
      orange-persimmon: rgb(0xe3, 0x52, 0x05),
      orange-carrot: rgb(0xED, 0x8B, 0x00),
    ),
  ),
)

#let font = (
  primary-prop: "Whitney",
  primary: "Open Sans",
  secondary-prop: "Guardian Egyptian",
  secondary: "Merriweather",
  code: "Fira Code",
  cjk: (
    sc: "Noto Sans CJK SC",
    tc: "Noto Sans CJK TC",
    hk: "Noto Sans CJK HK",
    jp: "Noto Sans CJK JP",
    kr: "Noto Sans CJK KR",
  ),
  office: "Arial",
  editorial: "Lora",
)

#let prop-config(theme, major, minor) = (
  theme
    .pairs()
    .map(((k, v)) => (
      k,
      v
        + (
          if k in ("link", "ref") {
            none
          } else {
            (
              color-major: major,
              color-minor: minor,
            )
          }
        ),
    ))
    .to-dict()
)

/////////////
/* Configs */
/////////////

#let font-major = font.primary
#let font-minor = font.secondary

#let light-major = palette.ubc.blue-main
#let light-minor = palette.ubc.blue-london-rain

#let dark-major = palette.ubc.white
#let dark-minor = palette.ubc.blue-effervescence

#let ubc-light = (
  global: (
    font-major: font.primary,
    font-minor: font.secondary,
    background: box(fill: palette.ubc.white, width: 100%, height: 100%),
    rule: body => {
      show heading: set text(font: font.secondary)
      body
    },
  ),
  question: (
    numbering: (
      "1.",
      "(a)",
      "i.",
    ),
    container: (func, args, items, config: (:)) => question-container(
      func,
      args + (inset: (x: .35em, y: .3em)),
      items,
      config: config,
    ),
  ),
  solution: (
    stroke-major: 1pt + palette.ubc.blue-effervescence,
    stroke-minor: .8pt + palette.ubc.blue-effervescence.transparentize(50%),
  ),
  link: (
    color-major: palette.ubc.blue-vanadyl,
  ),
  ref: (
    color-major: palette.ubc.blue-vanadyl,
  ),
  raw: (:),
  math: (:),
  title: (
    format: it => text(font: font.secondary, size: 1.5em, weight: "bold", upper(it)),
  ),
)

#{
  ubc-light = prop-config(ubc-light, light-major, light-minor)
}

#let ubc-dark = ubc-light
#{
  ubc-dark.global.background = box(fill: palette.ubc.blue-naval-night, width: 100%, height: 100%)
  ubc-dark.link.color-major = palette.ubc.blue-summer-sky
  ubc-dark.ref.color-major = palette.ubc.blue-summer-sky
  ubc-dark.solution.stroke-major = 1pt + palette.ubc.blue-norfolk-sky
  ubc-dark.solution.stroke-minor = .8pt + palette.ubc.blue-norfolk-sky.transparentize(50%)

  ubc-dark = prop-config(ubc-dark, dark-major, dark-minor)
}
