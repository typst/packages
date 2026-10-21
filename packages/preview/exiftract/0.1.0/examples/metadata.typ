// A small report built from an image's Exif metadata.

#import "@preview/exiftract:0.1.0": read-exif

#set page(width: 15cm, height: auto, margin: 1.5cm)
#set text(size: 10pt)

#let photo = read("photo.jpg", encoding: none)
#let fields = read-exif(photo)

// read-exif hands over native values; how they read is still up to the
// document. Datetimes get a format, numbers get their unit appended.
#let show-value(field) = {
  let one(value) = if type(value) == datetime {
    // GPSDateStamp carries no time of day, so ask before formatting one.
    if value.hour() == none {
      value.display("[day]/[month]/[year]")
    } else {
      value.display("[day]/[month]/[year] [hour]:[minute]")
    }
  } else if type(value) == angle {
    str(calc.round(value.deg(), digits: 4)) + "°"
  } else if type(value) == bytes {
    raw(str(value))
  } else if type(value) == float and float.is-nan(value) {
    emph("unknown")
  } else {
    str(value)
  }

  let shown = if field.count == 1 or type(field.value) != array {
    one(field.value)
  } else {
    field.value.map(one).join(", ")
  }

  if field.unit == none { shown } else [#shown #field.unit]
}

#let field-named(name) = fields.find(f => f.tag == name)

= #field-named("ImageDescription").value

#grid(
  columns: (auto, 1fr),
  column-gutter: 1em,
  image(bytes(photo), width: 3cm),
  table(
    columns: 2,
    stroke: none,
    align: (right, left),
    ..fields
      .filter(f => f.tag in (
        "Make",
        "Model",
        "DateTimeOriginal",
        "ExposureTime",
        "FNumber",
        "FocalLength",
        "GPSLatitude",
        "GPSLongitude",
      ))
      .map(f => (strong(f.tag), show-value(f)))
      .flatten()
  ),
)

== Every field

#table(
  columns: (auto, auto, auto, 1fr),
  align: (left, left, left, left),
  table.header([*Tag*], [*IFD*], [*Type*], [*Value*]),
  ..fields
    .map(f => (raw(f.tag), f.ifd, raw(str(type(f.value))), show-value(f)))
    .flatten()
)
