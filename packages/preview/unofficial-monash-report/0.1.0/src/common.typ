#import "design.typ": *
#import "page.typ": config, page-style
#import "headings.typ": heading-style
#import "figures.typ": figure-style
#import "code.typ": code-style
#let document-style(o, body) = {
  set text(
    font: o.font, size: o.font-size, fill: monash-black, lang: o.lang, hyphenate: true,
    top-edge: body-top-edge, bottom-edge: body-bottom-edge,
  )
  set par(justify: true, first-line-indent: zero, leading: body-leading, spacing: paragraph-gap)
  set list(marker: rect(
    width: square-bullet-size, height: square-bullet-size, fill: monash-black, stroke: none,
  ))
  set enum(full: true, numbering: (..numbers) => {
    text(
      font: o.heading-font, size: label-size, weight: "bold", fill: o.accent,
      numbering(
        if calc.rem(numbers.pos().len(), 2) == 1 { "(a)" } else { "(i)" },
        numbers.pos().last(),
      ),
    )
  }, indent: zero, body-indent: part-body-indent)
  show math.equation: set text(font: o.math-font)
  show footnote.entry: set text(size: footnote-size)
  set footnote.entry(separator: line(stroke: hairline + monash-black, length: footnote-rule-width))
  show link: set text(fill: o.accent)
  show ref: set text(fill: o.accent)
  show cite: set text(fill: o.accent)
  show: page-style.with(o)
  show: heading-style.with(o)
  show: figure-style.with(o)
  show: code-style.with(o)
  config.update(o)
  body
  config.update(none)
}
