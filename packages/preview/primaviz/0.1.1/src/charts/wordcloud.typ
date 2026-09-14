// wordcloud.typ - Word cloud chart (flowing text layout)
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-wordcloud-data
#import "../primitives/container.typ": chart-container

/// Renders a word cloud where each word's font size is proportional to its weight.
///
/// Words are sorted by weight descending and laid out using Typst's natural
/// text flow within a fixed-size container. Larger words dominate visually,
/// creating the characteristic word-cloud appearance.
///
/// - data (dictionary): Must contain a `words` array of dictionaries,
///   each with `text` (string) and `weight` (number) keys.
/// - width (length): Chart width
/// - height (length): Chart height
/// - min-size (length): Font size for the lowest-weight word
/// - max-size (length): Font size for the highest-weight word
/// - title (none, content): Optional chart title
/// - padding (length): Inner padding around the word area
/// - theme (none, dictionary): Theme overrides
/// -> content
#let word-cloud(
  data,
  width: 300pt,
  height: 200pt,
  min-size: 8pt,
  max-size: 36pt,
  title: none,
  padding: 8pt,
  theme: none,
) = {
  validate-wordcloud-data(data, "word-cloud")
  let t = resolve-theme(theme)
  let words = data.words

  if words.len() == 0 { return }

  // Sort by weight descending
  let sorted-words = words.sorted(key: w => -w.weight)

  // Find weight range for size mapping
  let max-weight = sorted-words.at(0).weight
  let min-weight = sorted-words.last().weight
  let weight-range = max-weight - min-weight
  if weight-range == 0 { weight-range = 1 }

  // Font weight alternation for visual variety
  let font-weights = ("bold", "regular", "bold", "medium", "regular")

  chart-container(width, height, title, t, extra-height: 10pt)[
    #box(width: width, height: height, clip: true, inset: padding)[
      #set align(center)
      #set par(leading: 2pt, spacing: 4pt)
      #for (i, w) in sorted-words.enumerate() {
        // Map weight to font size linearly
        let frac = (w.weight - min-weight) / weight-range
        let size = min-size + frac * (max-size - min-size)
        let color = get-color(t, i)
        let fw = font-weights.at(calc.rem(i, font-weights.len()))
        box(inset: (x: 3pt, y: 1pt))[
          #text(size: size, fill: color, weight: fw)[#w.text]
        ]
      }
    ]
  ]
}
