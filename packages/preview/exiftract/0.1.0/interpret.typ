// The interpreting layer, applied by `read-exif` unless `return-raw` is set.
// Not part of the package's API: import `read-exif` from `lib.typ` instead.
//
// Exif stores everything as integers, rationals and byte strings. This turns
// those into the Typst type that carries the same meaning, but only where the
// Exif specification fixes the unit for *every* field of that kind — see the
// `unit` member and the README for where it deliberately stops.

// Units the specification fixes outright, by tag name. Tags whose unit comes
// from a neighbouring field are handled in `_unit-of` instead.
#let _units = (
  ImageWidth: "pixels",
  ImageLength: "pixels",
  RelatedImageWidth: "pixels",
  RelatedImageLength: "pixels",
  PixelXDimension: "pixels",
  PixelYDimension: "pixels",
  ExposureTime: "s",
  ShutterSpeedValue: "EV",
  ApertureValue: "EV",
  BrightnessValue: "EV",
  ExposureBiasValue: "EV",
  MaxApertureValue: "EV",
  SubjectDistance: "m",
  FocalLength: "mm",
  FocalLengthIn35mmFilm: "mm",
  FlashEnergy: "BCPS",
  Temperature: "°C",
  Humidity: "%",
  Pressure: "hPa",
  WaterDepth: "m",
  Acceleration: "mGal",
  GPSHPositioningError: "m",
  GPSAltitude: "m",
  GPSTimeStamp: "h, min, s",
)

// Tags holding a plain angle in degrees.
#let _angles = (
  "CameraElevationAngle",
  "GPSTrack",
  "GPSImgDirection",
  "GPSDestBearing",
)

// Sexagesimal coordinates, and the neighbouring field giving their hemisphere.
#let _coordinates = (
  GPSLatitude: "GPSLatitudeRef",
  GPSLongitude: "GPSLongitudeRef",
  GPSDestLatitude: "GPSDestLatitudeRef",
  GPSDestLongitude: "GPSDestLongitudeRef",
)

#let _date-times = ("DateTime", "DateTimeOriginal", "DateTimeDigitized")

// Values of ResolutionUnit and FocalPlaneResolutionUnit.
#let _resolution-units = ("2": "inch", "3": "cm")

// Values of GPSSpeedRef and GPSDestDistanceRef.
#let _speed-units = (K: "km/h", M: "mph", N: "knots")
#let _distance-units = (K: "km", M: "miles", N: "nautical miles")

#let _leap-year(year) = {
  calc.rem(year, 4) == 0 and (calc.rem(year, 100) != 0 or calc.rem(year, 400) == 0)
}

#let _days-in-month(year, month) = {
  let days = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31).at(month - 1)
  if month == 2 and _leap-year(year) { 29 } else { days }
}

#let _valid-date(year, month, day) = {
  year >= 1 and month >= 1 and month <= 12 and day >= 1 and day <= _days-in-month(year, month)
}

/// Parses `"2024:05:17 09:30:00"`, the Exif date-time format. Returns `none`
/// for anything else, including the blank `"    :  :     :  :  "` that stands
/// for an unset field, and for dates that do not exist.
#let _parse-date-time(text) = {
  if type(text) != str { return none }
  let found = text.match(regex("^\s*(\d{4}):(\d{2}):(\d{2})[ T](\d{2}):(\d{2}):(\d{2})\s*$"))
  if found == none { return none }
  let (year, month, day, hour, minute, second) = found.captures.map(int)
  if not _valid-date(year, month, day) { return none }
  if hour > 23 or minute > 59 or second > 59 { return none }
  datetime(
    year: year,
    month: month,
    day: day,
    hour: hour,
    minute: minute,
    second: second,
  )
}

/// Parses `"2024:05:17"`, the format of GPSDateStamp.
#let _parse-date(text) = {
  if type(text) != str { return none }
  let found = text.match(regex("^\s*(\d{4}):(\d{2}):(\d{2})\s*$"))
  if found == none { return none }
  let (year, month, day) = found.captures.map(int)
  if not _valid-date(year, month, day) { return none }
  datetime(year: year, month: month, day: day)
}

/// Divides one `(numerator, denominator)` pair. Exif uses `0/0` for "unknown",
/// which becomes `float.nan` rather than a division by zero.
#let _divide(pair) = {
  if type(pair) != array or pair.len() != 2 { return pair }
  let (numerator, denominator) = pair
  if denominator == 0 { float.nan } else { numerator / denominator }
}

/// Turns a field's rationals into floats, leaving every other type alone.
#let _to-float(field) = {
  if field.type not in ("rational", "srational") { return field.value }
  if field.value == none { none } else if field.count == 1 { _divide(field.value) } else {
    field.value.map(_divide)
  }
}

/// Degrees, minutes and seconds plus a hemisphere, as a signed angle.
#let _to-angle(parts, hemisphere) = {
  let parts = if type(parts) == array { parts } else { (parts,) }
  let degrees = parts.at(0, default: 0.0)
  let minutes = parts.at(1, default: 0.0)
  let seconds = parts.at(2, default: 0.0)
  let sign = if hemisphere in ("S", "W") { -1 } else { 1 }
  sign * (degrees + minutes / 60 + seconds / 3600) * 1deg
}

/// The bytes of an `UNDEFINED` field, which `read-exif` reports as byte values.
#let _to-bytes(field) = {
  if field.value == none { bytes(()) } else if field.count == 1 {
    bytes((field.value,))
  } else { bytes(field.value) }
}

/// The unit of a field whose unit lives in a neighbouring field.
#let _unit-of(field, neighbour) = {
  // The neighbour's value as a dictionary key, or "" when it is missing.
  let key(tag) = {
    let found = neighbour(tag)
    if found == none or found.value == none { "" } else { str(found.value) }
  }
  if field.tag in ("XResolution", "YResolution") {
    "pixels per " + _resolution-units.at(key("ResolutionUnit"), default: "unit")
  } else if field.tag in ("FocalPlaneXResolution", "FocalPlaneYResolution") {
    "pixels per " + _resolution-units.at(key("FocalPlaneResolutionUnit"), default: "unit")
  } else if field.tag == "GPSSpeed" {
    _speed-units.at(key("GPSSpeedRef"), default: none)
  } else if field.tag == "GPSDestDistance" {
    _distance-units.at(key("GPSDestDistanceRef"), default: none)
  } else {
    _units.at(field.tag, default: none)
  }
}

/// Interprets one field. `neighbour` looks a tag up in the same image
/// directory, which is where Exif keeps the hemisphere and unit of a value.
#let _interpret-field(field, neighbour) = {
  let value = _to-float(field)
  let unit = _unit-of(field, neighbour)

  if field.type == "undefined" {
    value = _to-bytes(field)
  } else if field.tag in _date-times {
    let parsed = _parse-date-time(value)
    if parsed != none { value = parsed }
  } else if field.tag == "GPSDateStamp" {
    let parsed = _parse-date(value)
    if parsed != none { value = parsed }
  } else if field.tag in _coordinates {
    let hemisphere = neighbour(_coordinates.at(field.tag))
    value = _to-angle(value, if hemisphere == none { none } else { hemisphere.value })
    unit = none
  } else if field.tag in _angles and type(value) in (int, float) {
    value = value * 1deg
    unit = none
  } else if field.tag == "GPSAltitude" and type(value) == float {
    // GPSAltitudeRef 1 means the altitude is measured downwards.
    let below = neighbour("GPSAltitudeRef")
    if below != none and below.value == 1 { value = -value }
  }

  field + (value: value, unit: unit)
}

/// Interprets raw fields.
///
/// Every field keeps its `tag`, `ifd`, `number`, `type` and `count`; `value`
/// becomes the Typst type that carries its meaning, and a `unit` member is
/// added — a string such as `"mm"`, or `none` when the value is dimensionless
/// or its type already says the unit.
///
/// - fields (array): Raw fields, as the plugin reports them.
/// -> array
#let interpret(fields) = {
  if type(fields) != array {
    panic("interpret expects the array from read-exif, found " + str(type(fields)))
  }
  let index = fields.map(f => (f.ifd + "/" + f.tag, f)).to-dict()
  fields.map(field => _interpret-field(
    field,
    tag => index.at(field.ifd + "/" + tag, default: none),
  ))
}
