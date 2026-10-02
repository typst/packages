/// Epigraphs / inspirational chapter quotes

#import "_constants.typ": LEADING

/// Chapter beginning epigraph / inspirational quote.
///
/// - body (content): Quote body
/// - attribution (content): Author / attribution of the quote
/// -> content
#let epigraph(body, attribution: []) = {
  let attribution-formatted = {
    set text(size: 0.8em)
    attribution
  }
  let body-formatted = {
    v(0.5em)
    set text(size: 0.9em, hyphenate: false, costs: (runt: 1000%))
    align(left, {
      show: emph
      body
    })
  }

  align(
    right,
    block(
      width: 18em,
      quote(
        block: true,
        attribution: attribution-formatted,
        body-formatted,
      ),
    ),
  )
}
