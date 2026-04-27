#import "@preview/tiaoma:0.3.0"

#let _plugin = plugin("./materialize.wasm")

#let matter-qr-code-to-manual-code(qrcode) = {
  str(_plugin.matter_qr_code_to_manual_code(bytes(qrcode)))
}

#let matter-qr-code(
  qrcode,
  style: "vertical",
  heading: "Matter",
  min-size: 0mm,
  spacing: auto,
  inset: auto,
  stroke: 1pt,
  radius: 1.5mm,
  foreground-color: auto,
  background-color: none,
) = context {
  let if-auto(x, default) = if (x == auto) { default } else { x }
  let spacing = if-auto(spacing, if style == "vertical" { 3mm } else { 2mm })
  let inset = if-auto(inset, spacing)
  let foreground-color = if-auto(foreground-color, text.fill)
  let stroke = if stroke == none { none } else { stroke + foreground-color }
  let leading = calc.min(par.leading.to-absolute(), spacing / 2)

  set text(fill: foreground-color)
  set par(leading: leading)

  let manual-code = text(
    number-width: "tabular",
    kerning: false,
  )[#matter-qr-code-to-manual-code(qrcode)]

  let content = if style == "horizontal" {
    set align(right)
    stack(spacing: spacing, heading, manual-code)
  } else {
    manual-code
  }
  let content-size = measure({
    set par(leading: leading)
    content
  })
  let qr-size = calc.max(
    if style == "vertical" { content-size.width } else { content-size.height },
    min-size - 2 * inset,
  )
  let qr-code = tiaoma.qrcode(qrcode, width: qr-size, options: (
    fg-color: foreground-color,
  ))

  block(
    breakable: false,
    fill: background-color,
    stroke: stroke,
    radius: radius,
    inset: inset,
    {
      if style == "vertical" {
        set align(center)
        stack(
          spacing: spacing,
          heading,
          qr-code,
          content,
        )
      } else if style == "horizontal" {
        stack(
          dir: ltr,
          spacing: spacing,
          qr-code,
          content,
        )
      } else {
        panic("Invalid style")
      }
    },
  )
}
