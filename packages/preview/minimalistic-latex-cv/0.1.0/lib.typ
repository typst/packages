#let cv(
  name: "",
  metadata: (),
  photo: none,
  lang: "en",
  body,
) = {
  set document(author: name, title: name + " CV")
  set page(
   margin: (x: 30pt, y: 30pt),
  )
  set text(0.9em, font: "New Computer Modern", lang: lang)
  show heading.where(level: 1): it => {
    set text(0.9em, weight: "light")
    smallcaps(it)
    v(-13pt)
    line(length: 100%, stroke: 0.5pt)
    v(3pt)
  }
  show list.item: it => {
    block(inset: (left: 10pt))[#it]
  }
  set par(justify: true)
  if photo != none {
    text(1.7em, weight: "bold", name)
    v(-10pt)
    set image(width: 20%)
    photo
    place(
      top + right,
      {
        for data in metadata {
          align(end, text(upper(data.at(0).slice(0, 1)) + data.at(0).slice(1) + ": " + data.at(1)))
          v(-6pt)
        }
      },
    )
  } else {
    align(center, text(2.2em, weight: "bold", name))
    if metadata.len() != 0 {
      v(-15pt)
      align(center, text(0.9em, metadata.values().join(" | ")))
    }
  }
  body
}

#let entry(
  title: str,
  name: str,
  date: str,
  location: str,
) = {
  grid(
    columns: (50%, 50%),
    rows: (auto, auto, auto, auto),
    row-gutter: 6pt,
    text(weight: "bold", title),
    align(end, date),
    text(style: "italic", name),
    align(end, text(style: "italic", location))
  )
  v(-15pt)
}
