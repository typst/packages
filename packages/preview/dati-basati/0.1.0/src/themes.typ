#let themes = (
  "tiw": (
    fill: (
      entities: rgb("#DAE8FC"),
      relations: rgb("#FFE6CC"),
    ),
    stroke: (
      entities: rgb("#6C8EBF"),
      relations: rgb("#D79B00"),
      lines: black,
    ),
  ),
  "snow": (
    fill: (
      entities: aqua.lighten(80%),
      relations: white,
    ),
    stroke: (
      entities: blue.lighten(50%),
      relations: black,
      lines: black,
    ),
  ),
  "ghibli": (
    fill: (
      cardinality: rgb("#FFE066").lighten(40%),
      entities: rgb("#FFE066"),
      relations: rgb("#26C061").lighten(30%),
      attributes: rgb("#FFE066"),
      composite-attributes: rgb("#FFE066"),
      weak-entity: rgb("#FFE066"),
      primary-key: rgb("#FFE066"),
    ),
    stroke: (
      cardinality: rgb("#7F7033") + 0.1pt,
      entities: rgb("#073408"),
      relations: black,
      attributes: rgb("#073408"),
      composite-attributes: rgb("#073408"),
      weak-entity: rgb("#073408"),
      primary-key: rgb("#073408"),
    ),
    radius: (
      entities: 6pt,
      cardinality: 2pt,
    ),
  ),
  "tiramisu": (
    fill: (
      cardinality: rgb("#660B05").lighten(60%),
      entities: rgb("#FFF0C4"),
      relations: rgb("#8C1007").lighten(30%),
      attributes: rgb("#8C1007"),
      weak-entity: rgb("#8C1007"),
      composite-attributes: rgb("#FFF0C4"),
      primary-key: rgb("#8C1007"),
    ),
    stroke: (
      cardinality: none,
      entities: rgb("#3E0703"),
      attributes: rgb("#3E0703"),
      weak-entity: rgb("#3E0703"),
      primary-key: rgb("#3E0703"),
    ),
    radius: (
      entities: 6pt,
      cardinality: 2pt,
    ),
    // text: (
    //   entities: l => pad(x: 0.1em, (
    //     text(
    //       font: "IBM Plex Sans",
    //       weight: "bold",
    //       upper(l),
    //     )
    //   )),
    //   attributes: l => text(font: "IBM Plex Sans", l),
    // ),
    // spacing: (in-between: (x: 1.3em, y: 1.2em)),
  ),
  "futurama": (
    fill: (
      cardinality: rgb("#EF4040"),
      entities: rgb("#FFA732"),
      relations: rgb("#711DB0").lighten(50%),
      attributes: rgb("#FFA400"),
      weak-entity: rgb("#FFA400"),
      primary-key: rgb("#FFA400"),
    ),
    stroke: (
      cardinality: rgb("#711DB0") + 0.1pt,
      entities: rgb("#5E0606"),
      relations: rgb("#5E0606"),
      attributes: rgb("#5E0606"),
      weak-entity: rgb("#5E0606"),
      primary-key: rgb("#5E0606"),
    ),
    radius: (
      entities: 2pt,
    ),
  ),
  "C62-50": (
    fill: (
      cardinality: white,
      entities: rgb("#FFC100"),
      relations: rgb("#d9e0e7"),
      weak-entity: rgb("#335881"),
      primary-key: rgb("#335881"),
    ),
    stroke: (
      cardinality: none,
      entities: rgb("#002e62"),
      relations: rgb("#002e62"),
      attributes: rgb("#002e62"),
      weak-entity: rgb("#002e62"),
      primary-key: rgb("#002e62"),
    ),
    radius: (
      cardinality: 6pt,
      hierarchy: 6pt,
    ),
  ),
  "C62-48": (
    fill: (
      cardinality: red,
      entities: rgb("#002E62"),
      relations: red,
      weak-entity: rgb("#335881"),
      primary-key: rgb("#335881"),
    ),
    stroke: (
      cardinality: rgb("#FFBF00"),
      entities: rgb("#02499b"),
      relations: rgb("#FFBF00"),
      attributes: rgb("#002e62"),
      weak-entity: rgb("#002e62"),
      primary-key: rgb("#002e62"),
    ),
    radius: (
      entities: 3pt,
      cardinality: 6pt,
    ),
    text: (
      entities: l => text(
        fill: rgb("#FEFEFE"),
        top-edge: "bounds",
        weight: 700,
        size: 1.2em,
        smallcaps(l),
      ),
      relations: l => text(
        fill: rgb("#FFBF00"),
        l,
      ),
      cardinality: l => text(
        fill: rgb("#FFBF00"),
        top-edge: "bounds",
        bottom-edge: "bounds",
        l,
      ),
    ),
    spacing: (in-between: (x: 1.1em, y: 1.2em)),
  ),
  "polimi": (
    fill: (
      cardinality: rgb("#E0DCDC"),
      entities: rgb("#98A3B3"),
      relations: rgb("#263F63"),
      composite-attributes: rgb("#536782"),
      weak-entity: rgb("#536782"),
      primary-key: rgb("#536782"),
    ),
    stroke: (
      cardinality: rgb("#102C53") + 0.1pt,
      entities: rgb("#102C53"),
      relations: black,
      attributes: rgb("#102C53"),
      composite-attributes: rgb("#102C53"),
      weak-entity: rgb("#102C53"),
      primary-key: rgb("#102C53"),
    ),
    text: (
      entities: l => pad(x: 0.5em, text(
        size: 1.1em,
        weight: "bold",
        upper(l),
      )),
      relations: l => text(
        fill: rgb("#D3E1E7"),
        l,
      ),
    ),
    spacing: (in-between: (x: 1.2em, y: 1.3em), padding: 12.7pt),
    misc: (weak-entities-stroke: true),
  ),
)
