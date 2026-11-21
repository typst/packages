// Resolve settings.yaml into typed Typst values and unit-bearing lengths.
// YAML stores plain numbers; conversion to pt, in and em happens here.
#let resolve-settings(data) = {
  let page-data = data.at("page", default: (:))
  let typography-data = data.at("typography", default: (:))
  let text-data = typography-data.at("text", default: (:))
  let math-data = typography-data.at("math", default: (:))
  let code-data = typography-data.at("code", default: (:))
  let paragraph-data = typography-data.at("paragraph", default: (:))
  let cover-data = data.at("cover", default: (:))
  let bibliography-data = data.at("bibliography", default: (:))

  let font-size = text-data.at("size-pt", default: 10) * 1pt
  let math-size-value = math-data.at("size-pt", default: none)

  (
    language: data.at("language", default: "es"),
    page: (
      paper: page-data.at("paper", default: "us-letter"),
      margin: page-data.at("margin-in", default: 1) * 1in,
      page-numbers: page-data.at("page-numbers", default: true),
    ),
    typography: (
      font: text-data.at("font", default: "New Computer Modern"),
      font-size: font-size,
      top-edge: text-data.at("top-edge-em", default: 0.8) * 1em,
      bottom-edge: text-data.at("bottom-edge-em", default: -0.2) * 1em,
      math-font: math-data.at("font", default: "New Computer Modern Math"),
      math-size: if math-size-value == none { none } else { math-size-value * 1pt },
      code-font: code-data.at("font", default: "DejaVu Sans Mono"),
      code-inline-size: font-size * code-data.at("inline-size-em", default: 0.85),
      code-block-size: code-data.at("block-size-pt", default: 9) * 1pt,
      justify: paragraph-data.at("justify", default: false),
      leading: paragraph-data.at("leading-em", default: 1) * 1em,
      paragraph-spacing: paragraph-data.at("spacing-em", default: 1) * 1em,
      first-line-indent: paragraph-data.at("first-line-indent-in", default: 0.5) * 1in,
      heading-leading: paragraph-data.at("heading-leading-em", default: 1) * 1em,
      heading-spacing: paragraph-data.at("heading-spacing-em", default: 1) * 1em,
    ),
    cover: (
      top-space: cover-data.at("top-space-em", default: 3) * 1em,
    ),
    bibliography: (
      style: bibliography-data.at("style", default: "apa"),
      full: bibliography-data.at("full", default: false),
    ),
  )
}
