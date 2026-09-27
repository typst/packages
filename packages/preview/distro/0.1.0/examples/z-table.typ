#import "@preview/distro:0.1.0": normal

= Standard Normal distribution $Z$-table

#let Z = normal.new(mean: 0, std: 1)
#let linspace = (start, stop, num) => {
  let step = (stop - start) / (num - 1)
  range(0, num).map(v => start + v * step)
}

#let bases = linspace(-3, 3, 61)
#let cents = range(0, 10).map(i => i * 0.01)

#table(
  columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
  align: horizon,
  table.header(
    [$z$],
    ..linspace(0, 0.09, 10).map(c => [#(calc.round(c, digits: 2))]),
  ),
  ..(
    bases
      .map(b => (
        [#(calc.round(b, digits: 1))],
        ..(cents.map(c => [#calc.round(normal.cdf(Z)(b + c), digits: 5)])),
      ))
      .flatten()
  ),
)
