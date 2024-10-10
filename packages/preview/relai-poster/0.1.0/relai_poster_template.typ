
#import "@preview/cades:0.3.0": qr-code
#let sponsored_by() = {
  grid(
    columns: (55mm,40mm,55mm),
    rows: (25mm),
    align(
      left,
      text(size: 9.4pt, "relAI is supported by the DAAD programme Konrad Zuse Schools of Excellence in Artificial Intelligence, sponsored by the Federal Ministry of Education and Research."),
    ),
    image("resources/bmbf.jpg", height: 2.5cm),
    image("resources/zuse_schools.jpg", height: 2.5cm),
  )
}
#let qr_reference(url:"", label:"") = {
  let url_text = if label.len() > 0 {
    label
  } else {
    url
  }
  grid(
    columns: (30mm),
    align: center,
    gutter: 5mm,
    qr-code(url, width: 25mm),
    link(url, text(url_text, size: 9pt)),
  )
}

#let X_PAGE_MARGIN = 59.4mm

#let universities() = {
  grid(
    columns: (auto,auto),
    gutter: (10mm),
    rows: (25mm),
    image("resources/lmu-cropped.svg", height: 2.5cm),
    image("resources/tum-cropped.svg", height: 2.5cm),
  )
}
#let poster(
  doc,
  title,
  flipped: false,
  // true for landscape, false for portrait
  n_columns: 3,
  authors: (
    ("name": "Max Mustermann", "affiliation": "Musteruni", "email": "max.mustermann@musteruni.de"),
    ("name": "Max Mustermann", "affiliation": "Musteruni", "email": "max.mustermann@musteruni.de"),
    ("name": "Max Mustermann", "affiliation": "Musteruni", "email": "max.mustermann@musteruni.de"),
  ),
  references: (
    ("url": "https://zuseschoolrelai.de", "label": "zuseschoolrelai.de"),
  ),
  font_size: 30pt,
) = {
  set text(
    font: ("Maven Pro", "Arial"),
    fallback: true,
    size: font_size,
  )
  show heading.where(
    level: 1,
  ): it => block(width: 100%)[
    #set text(font_size*5/3, weight: "regular")
    #it
  ]
  set page(
    paper: "a1",
    flipped: flipped,
    header: [
      #grid(
        columns: (310mm,auto),
        rows: (150mm),
        align: (top + left,horizon + center),
        image("resources/relai_logo.png", height: 100%),
        [
          #v(5mm)
          #title

          #grid(
            columns: range(authors.len()).map(i => 1fr),
            rows: (auto),
            gutter: 10mm,
            align: horizon + center,
            ..authors.map(author => [
                #text(author.name, size: 20pt)\
                #text(author.affiliation, size: 15pt)\
                #text(author.email, size: 15pt)
              ]),
          )
        ],
      )
    ],
    footer: pad(
      left: X_PAGE_MARGIN,
      box(
        width: 100%,
        grid(
        columns: (1fr,auto,1fr),
        align: (left,center,right),
        universities(),
        grid(
          columns: references.len(),
          gutter: 5mm,
          ..references.map(r => qr_reference(url:r.url, label:r.label))
        ),
        sponsored_by(),
      )),
    ),
    margin: (left: 0cm, top: 166.66mm, right: X_PAGE_MARGIN),
  )
  pad(left: X_PAGE_MARGIN, columns(n_columns, gutter: 30mm, doc))
}
