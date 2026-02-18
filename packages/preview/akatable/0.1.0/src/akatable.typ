#let formats = (
  booktabs: (
    top-stroke: 1.5pt,
    mid-stroke: 0.75pt,
    bottom-stroke: 1.5pt,
    caption-label: (nr) => [Table #nr],
    caption-sep: ": ",
    caption-title-transform: (title) => title,
    caption-align: left,
  ),
  apa: (
    top-stroke: 1pt,
    mid-stroke: 1pt,
    bottom-stroke: 1pt,
    caption-label: (nr) => text(weight: "bold")[Table #nr],
    caption-sep: "\n",
    caption-title-transform: (title) => emph(title),
    caption-align: left,
  ),
  ieee: (
    top-stroke: 1.5pt,
    mid-stroke: 0.75pt,
    bottom-stroke: 1.5pt,
    caption-label: (nr) => upper[TABLE #numbering("I", nr)],
    caption-sep: "\n",
    caption-title-transform: (title) => upper(title),
    caption-align: center,
  ),
  acs: (
    top-stroke: 1.5pt,
    mid-stroke: 0.75pt,
    bottom-stroke: 1.5pt,
    caption-label: (nr) => text(weight: "bold")[Table #nr.],
    caption-sep: " ",
    caption-title-transform: (title) => title,
    caption-align: left,
  ),
  nature: (
    top-stroke: 1.5pt,
    mid-stroke: 0.75pt,
    bottom-stroke: 1.5pt,
    caption-label: (nr) => text(weight: "bold")[Table #nr],
    caption-sep: " | ",
    caption-title-transform: (title) => title,
    caption-align: left,
  ),
  elsevier: (
    top-stroke: 1.5pt,
    mid-stroke: 0.75pt,
    bottom-stroke: 1.5pt,
    caption-label: (nr) => [Table #nr.],
    caption-sep: " ",
    caption-title-transform: (title) => title,
    caption-align: left,
  ),
  chicago: (
    top-stroke: 1pt,
    mid-stroke: 1pt,
    bottom-stroke: 1pt,
    caption-label: (nr) => [Table #nr.],
    caption-sep: " ",
    caption-title-transform: (title) => title,
    caption-align: left,
  ),
  acm: (
    top-stroke: 1.5pt,
    mid-stroke: 0.75pt,
    bottom-stroke: 1.5pt,
    caption-label: (nr) => text(weight: "bold")[Table #nr.],
    caption-sep: " ",
    caption-title-transform: (title) => title,
    caption-align: left,
  ),
)

#let academic-table(
  caption,
  cells,
  format: "apa",
  header: (),
  footer: (),
  label: none,
  ..args
) = {
  let columns = args.named().at("columns", default: 1)
  let preset = formats.at(format)

  set figure.caption(position: top)

  show figure.caption: cap => {
    set align(preset.caption-align)
    let label-content = (preset.caption-label)(int(cap.counter.display()))
    let title-content = (preset.caption-title-transform)(cap.body)
    if preset.caption-sep == "\n" {
      label-content
      linebreak()
      title-content
    } else {
      label-content
      preset.caption-sep
      title-content
    }
  }

  [
    #figure(
      table(
        columns: columns,
        ..args,
        stroke: none,
        table.header(
          table.hline(stroke: preset.top-stroke),
          ..header,
          table.hline(stroke: preset.mid-stroke),
        ),
        ..cells,
        if footer != () {
          table.footer(
            table.hline(stroke: preset.bottom-stroke),
            ..footer,
            table.hline(stroke: preset.bottom-stroke),
          )
        } else {
          table.hline(stroke: preset.bottom-stroke)
        },
      ),
      caption: caption,
    ) #label
  ]
}
