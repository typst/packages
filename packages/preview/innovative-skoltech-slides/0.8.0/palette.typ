/**
 * palette.typ
 */

#let palette = (
  (rgb("#D2DE26"),  rgb("#D9E453"),  "Skolkovo Green"),            // 01
  (rgb("#98DB2C"),  rgb("#A8E155"),  "Skoltech Light Green"),      // 02
  (rgb("#66D92C"),  rgb("#80E054"),  "Skoltech Green"),            // 03
  (rgb("#2EE42E"),  rgb("#5DE857"),  "Skoltech Bright Green"),     // 04
  (rgb("#2EE47A"),  rgb("#51E788"),  "Skoltech Light Mint"),       // 05
  (rgb("#2CD996"),  rgb("#50DEA2"),  "Skoltech Mint"),             // 06
  (rgb("#2EE4B6"),  rgb("#4FE7BE"),  "Skoltech Bright Mint"),      // 07
  (rgb("#2BD6D6"),  rgb("#51DBDA"),  "Skoltech Turquoise"),        // 08
  (rgb("#30C0F0"),  rgb("#5BCAF2"),  "Skoltech Light Blue"),       // 09
  (rgb("#8CB7E9"),  rgb("#9EC2ED"),  "Skoltech Lavender"),         // 10
  (rgb("#308FF0"),  rgb("#54A0F2"),  "Skoltech Blue"),             // 11
  (rgb("#4872F0"),  rgb("#6488F3"),  "Skoltech Navy Blue"),        // 12
  (rgb("#3030F0"),  rgb("#4D52F3"),  "Skoltech Dark Blue"),        // 13
  (rgb("#411BD6"),  rgb("#5D43DD"),  "Skoltech Indigo"),           // 14
  (rgb("#2900CC"),  rgb("#4834D5"),  "Skoltech Sapphire"),         // 15
  (rgb("#6533FF"),  rgb("#7D55FF"),  "Skoltech Violet"),           // 16
  (rgb("#9733FF"),  rgb("#A855FF"),  "Skoltech Deep Violet"),      // 17
  (rgb("#C030F0"),  rgb("#CC54F3"),  "Skoltech Purple"),           // 18
  (rgb("#BC2BD9"),  rgb("#C751E0"),  "Skoltech Dark Purple"),      // 19
  (rgb("#E62EC7"),  rgb("#EB53D0"),  "Skoltech Magenta"),          // 20
  (rgb("#F0308F"),  rgb("#F454A0"),  "Skoltech Ruby"),             // 21
  (rgb("#CC295F"),  rgb("#D34370"),  "Skoltech Wine"),             // 22
  (rgb("#F03050"),  rgb("#F34863"),  "Skoltech Crimson"),          // 23
  (rgb("#E73440"),  rgb("#EA4B54"),  "Skoltech Red"),              // 24
  (rgb("#E63C2D"),  rgb("#EA5244"),  "Skoltech Terracotta"),       // 25
  (rgb("#E6712D"),  rgb("#E97F46"),  "Skoltech Skoltech Orange"),  // 26
  (rgb("#F08F30"),  rgb("#F29B49"),  "Skoltech Light Orange"),     // 27
  (rgb("#F0C030"),  rgb("#F2CA57"),  "Skoltech Gold"),             // 28
  (rgb("#E6D300"),  rgb("#E9DA47"),  "Skoltech Corn Yellow"),      // 29
  (rgb("#F2E100"),  rgb("#F4E649"),  "Skoltech Yellow"),           // 30
)

#let base-colors = palette.map(el => el.at(0))
#let dual-colors = palette.map(el => el.at(1))
#let color-names= palette.map(el => el.at(2))

// Primal and dual colors of Skolkovo (not Skoltech).
#let skolkovo-green = (
  main: base-colors.at(0),
  dual: dual-colors.at(0),
)

#let render-palette(colors: base-colors) = context {
  let elem = text(top-edge: "ascender", bottom-edge: "descender")[x]
  let shape = measure(elem)
  grid(
    columns: 6,
    rows: 5,
    column-gutter: 7.5in / 20,
    row-gutter: 7.5in / 30,
    align: center + horizon,
    ..colors
      .zip(color-names)
      .map(pair => {
        let (color, name) = pair
        let name = name.trim("Skoltech ")
        block(height: 2 * shape.height + 16pt, width: 100%, fill: color, name)
      })
  )
}
