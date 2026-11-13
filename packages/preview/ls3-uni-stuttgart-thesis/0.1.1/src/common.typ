// LS3 brand definitions shared by the public templates.
//
// Colors, font stacks, the content-block helper, and the thesis branding
// preset. Each package carries a copy as src/common.typ, kept in sync by
// scripts/sync-common.sh and checked by scripts/check.sh.

// === LS3 brand colors ===
#let colors = (
  anthrazit:  rgb(62, 68, 76),
  mittelblau: rgb(0, 81, 158),
  hellblau:   rgb(0, 190, 255),
  blue:       rgb(130, 176, 226),
  block-body: rgb(231, 232, 233),
)

// === Type stacks ===
// Sans stack uses TeX Gyre Heros, a free Helvetica clone. The typst.app
// web app has it built in. Locally, install it or pass
// `--font-path fonts` in this repo.
#let fonts = (
  sans: ("TeX Gyre Heros",),
  // Serif stack for templates that want a LaTeX-like look. New Computer
  // Modern ships with Typst, Latin Modern Roman is what the LaTeX thesis
  // template uses via lmodern.
  serif: ("New Computer Modern", "Latin Modern Roman"),
  // DejaVu Sans Mono ships with Typst.
  mono: ("DejaVu Sans Mono",),
)

// === Beamer-style block helper, was ls3-block in legacy poster.typ ===
// Named content-block to avoid shadowing Typst's built-in block element.
// Note: title-color is ignored when header-fill is set (header text is always white).
#let content-block(
  title: none,
  fill: colors.block-body,
  header-fill: none,
  title-color: colors.mittelblau,
  radius: 3pt,
  body,
) = {
  let has-header = header-fill != none
  block(
    fill: fill,
    width: 100%,
    inset: if has-header { 0pt } else { (x: 18pt, y: 14pt) },
    radius: radius,
    clip: has-header,
    breakable: true,
  )[
    #if title != none and has-header {
      block(
        fill: header-fill,
        width: 100%,
        inset: (x: 18pt, y: 10pt),
        text(weight: "bold", fill: white, size: 1.05em, title),
      )
    }
    #block(breakable: true, inset: if has-header { (x: 18pt, y: 14pt) } else { 0pt })[
      #if title != none and not has-header {
        text(weight: "bold", fill: title-color, size: 1.05em, title)
        v(6pt)
      }
      #body
    ]
  ]
}

// === Branding preset for the thesis template ===
// Consumed by the thesis template when no explicit branding is passed.
// The thesis template imports the logo function separately rather than
// storing it in the branding dictionary, since Typst's dot syntax does
// not work on hyphenated dictionary keys storing callable values.
#let branding = (
  colors: colors,
  fonts: fonts,
  institution: "University of Stuttgart",
)
