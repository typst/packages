#import "layers.typ": generate-legend

#let format-legend-pairs(materials, format-text: (it) => text(it)) = {
  let legend-pairs = generate-legend(materials).pairs()
  let formatted-pairs = ()
  for p in legend-pairs {
    p.at(0) = format-text(p.at(0))
    formatted-pairs.push(
      grid(
        columns: (1fr, 1fr),
        column-gutter: 10%,
        align: horizon,
        ..p.rev()
      )
    )
  }
  formatted-pairs
}

#let format-legend(columns: 1, column-gutter: 10%, row-gutter: 2.5%, materials: (:), format-text: (it) => text(it)) = {
  grid(
    columns: columns,
    column-gutter: column-gutter, 
    row-gutter: row-gutter,
    ..format-legend-pairs(materials, format-text: format-text)
  )
}

#let modded-zip(..args) = {
  let arrays = args.pos()
  let length = calc.max(..arrays.map(arr => arr.len()))
  let output = ()
  for i in range(0,length) {
    let group = ()
    for a in arrays {
      if (i >= a.len()) {
        continue
      }
      group.push(a.at(i))
    }
    output.push(group)
  }
  output
}
#let step-diagram(device-steps: (), step-desc: (), legend: [], columns: 1, column-gutter: 5%, row-gutter: 5%) = {
  grid(
    columns: columns,
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    ..modded-zip(device-steps, step-desc).map(
      pair => [
        #block()[
          #if pair.len() == 2 [
            #pair.at(0)
            #pair.at(1)
          ] else [
            #pair.at(0)
          ]
        ]
      ]
    ),
    legend
  )
}
