#let label(body) = {
  text(
    size: .9em,
    fill: rgb("#333"),
    body
  )
}

#let text-field(body) = {
  block(width: 100%, stroke: (bottom: 1pt + gray), pad(bottom: 2mm, body))
}

#let detail-box(heading, name, date-of-birth, address) = {
  text(weight: "semibold", heading)
  grid(
    columns: (1fr, 3fr),
    gutter: 10pt,
    label("Name"),
    text-field(name),
    label("Geburtsdatum"),
    text-field(date-of-birth),
    label("Anschrift"),
    text-field(address)
  )
}

/// This function takes your whole document as its `body` and formats it as a
/// letter of attorney ("Vollmacht").
///
/// The default font is set to _Source Sans 3_ without hyphenation. The body
/// text will be justified.
///
/// - font (string, array): Font used throughout the letter.
///
/// - margin (dictionary): The margin of the letter.
///
///   The dictionary can contain the following fields: _left_, _right_, _top_, _bottom_.\
///   Missing fields will be set to the default.
///
/// - folding-marks (boolean): The folding marks that will be displayed at the left margin.
/// - hole-mark (boolean): The hole mark that will be displayed at the left margin.
///
/// - subject (string, none): The subject and document title.
/// - date (string, none): The date of signing.
/// - location (string, none): The location of signing.
///
/// - grantor (dictionary): The grantor. Three fields: name, date-of-birth and address, all of them strings.
/// - grantee (dictionary): The grantee. Three fields: name, date-of-birth and address, all of them strings.
///
/// - extra-fields (array, none): Extra fields to show above your text. The array has consist of arrays with 1-2 elements each.
///
///   Example:
///   ```typ
///   (
///     ([Tracking number], [123456]),
///     ([Some other field without filled-out value]),
///   )
///   ```
///
/// - body (content, none): The content of the letter.
/// -> content
#let vollmacht(
  font: "Source Sans Pro",
  margin: (
    left:   25mm,
    right:  20mm,
    top:    20mm,
    bottom: 20mm,
  ),

  subject: "Umfang der Vollmacht",
  folding-marks: true,
  hole-mark: true,

  grantor: (
    name: none,
    date-of-birth: none,
    address: none,
  ),
  grantee: (
    name: none,
    date-of-birth: none,
    address: none,
  ),

  extra-fields: none,

  date: none,
  location: none,

  body,
) = {
  set document(title: subject)
  set text(font: font, hyphenate: false)

  margin = (
    left:   margin.at("left",   default: 25mm),
    right:  margin.at("right",  default: 20mm),
    top:    margin.at("top",    default: 20mm),
    bottom: margin.at("bottom", default: 20mm),
  )

  set page(
    paper: "a4",
    margin: margin,

    background: {
      if folding-marks {
        // folding mark 1
        place(top + left, dx: 5mm, dy: 87mm, line(
            length: 2.5mm,
            stroke: 0.25pt + black
        ))

        // folding mark 2
        place(top + left, dx: 5mm, dy: 87mm + 105mm, line(
            length: 2.5mm,
            stroke: 0.25pt + black
        ))
      }

      if hole-mark {
        // hole mark
        place(left + top, dx: 5mm, dy: 148.5mm, line(
          length: 4mm,
          stroke: 0.25pt + black
        ))
      }
    }
  )

  title("Vollmacht")
  v(1em)
  detail-box("Vollmachtgeber:in", grantor.name, grantor.date-of-birth, grantor.address)
  v(1em)
  detail-box("Vollmachtnehmer:in", grantee.name, grantee.date-of-birth, grantee.address)
  v(1em)
  text(weight: "semibold", subject)
  if (extra-fields != none) and (extra-fields.len() > 0) {
    v(1em)
    grid(
      columns: (1fr, 3fr),
      gutter: 10pt,
      ..extra-fields.map(extra-field => {
        if type(extra-field) == array {
          if extra-field.len() == 0 {
            panic("extra-field entries must have 1-2 entries, found one with 0")
          }
          if extra-field.len() > 2 {
            panic("extra-field entries must have 1-2 entries, found one with more")
          }

          let (key, value) = extra-field
          (label(key), text-field(value))
        } else {
          // only one entry, use as label
          (label(extra-field), text-field(""))
        }
      }).flatten()
    )
  }
  body
  v(2em)
  grid(
    columns: (1fr, 1fr),
    column-gutter: 5mm,
    row-gutter: 2mm,
    align: bottom,
    text-field({
      if location != none {
        location
      }
      if (location != none) and (date != none) {
        ", "
      }
      if date != none {
        date
      }
    }),
    text-field(""),
    label("Ort, Datum"),
    label("Unterschrift Vollmachtgeber:in"),
  )
}
