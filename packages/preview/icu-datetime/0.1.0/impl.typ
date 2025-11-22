#let plug = plugin("icu-datetime.wasm")

/// Creates a dictionary from a datetime or echos a dictionary passed as `dt`.
#let datetime-to-dict(dt) = {
  if type(dt) == datetime {
     (
      year: dt.year(),
      month: dt.month(),
      day: dt.day(),
      hour: dt.hour(),
      minute: dt.minute(),
      second: dt.second(),
    )
  } else if type(dt) == dictionary {
    dt
  } else {
    panic("Invalid datetime specification - expected type datetime or dictionary - got " + type(dt))
  }
}

/// Creates a timezone specification to pass to WASM.
///
/// `offset`: A string specifying the GMT offset (e.g. "-07", "Z", "+05", "+0500", "+05:00")
///
/// `iana`: Name of the IANA TZ identifier (e.g. "Brazil/West" - see https://www.iana.org/time-zones and https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). This is mutually exclusive with `bcp47`. This identifier will be converted to a BCP-47 ID.
/// `bcp47`: Name of the BCP-47 timezone ID (e.g. "iodga" - see https://github.com/unicode-org/cldr/blob/main/common/bcp47/timezone.xml). This is mutually exclusive with `iana`.
///
/// `local-date`: A local date to calculate the metazone-id. This is mutually exclusive with `metazone-id`. When formatting zoned-datetimes this isn't necessary.
/// `metazone-id`: A short ID of the metazone. A metazone is a collection of multiple time zones that share the same localized formatting at a particular date and time (e.g. "phil" - see https://github.com/unicode-org/cldr/blob/main/common/supplemental/metaZones.xml (bottom)).
///
/// `zone-variant`: Many metazones use different names and offsets in the summer than in the winter. In ICU4X, this is called the _zone variant_. Supports `none`, `"st"` (standard), and `"dt"` (daylight).
#let make-timezone-dict(
  offset,

  iana: none,
  bcp47: none,

  local-date: none,
  metazone-id: none,

  zone-variant: none,
) = {
  assert(type(offset) == str)

  assert(iana == none or type(iana) == str)
  assert(bcp47 == none or type(bcp47) == str)
  assert(not (iana != none and bcp47 != none))

  assert(metazone-id == none or type(metazone-id) == str)
  assert(not (metazone-id != none and local-date != none))

  assert(zone-variant == none or type(zone-variant) == str or type(zone-variant) == bytes)

  let tz = (
    offset: offset,
  )

  if iana != none {
    tz.insert("timezone-id", (iana: iana))
  } else if bcp47 != none {
    tz.insert("bcp47", (bcp47: bcp47))
  }

  if metazone-id != none {
    tz.insert("metazone", (id: metazone-id))
  } else if local-date != none {
    let dt = datetime-to-dict(local-date)

    assert(
      type(dt.year) == int and 
      type(dt.month) == int and 
      type(dt.day) == int and
      type(dt.hour) == int and 
      type(dt.minute) == int and 
      type(dt.second) == int
    )
    tz.insert("metazone", (local-date: dt))
  }

  if zone-variant != none {
    tz.insert("zone-variant", if type(zone-variant) == str {
      bytes(zone-variant)
    } else { zone-variant })
  }

  tz
}

/// Formats a date in some `locale`. Dates are assumed to be ISO dates.
///
/// `dt`: The date to format. This can be a `datetime` or a dictionary with `year`, `month`, `day`.
/// `locale`: A Unicode Locale Identifier (see https://unicode.org/reports/tr35/tr35.html#Unicode_locale_identifier).
/// `length`: The length of the formatted date ("full", "long" (default), "medium", "short", or `none`).
#let fmt-date(
  dt,
  locale: "en",
  length: "full"
) = {
  assert(type(locale) == str)

  let opts = (locale: locale, length: length)
  let dt = datetime-to-dict(dt)

  assert(
    type(dt.year) == int and 
    type(dt.month) == int and 
    type(dt.day) == int
  )
  str(plug.format_date(bytes(cbor.encode(dt)), bytes(cbor.encode(opts))))
}

/// Formats a time in some `locale`.
///
/// `dt`: The time to format. This can be a `datetime` or a dictionary with `hour`, `minute`, `second`, and (optionally) `nanosecond`.
/// `locale`: A Unicode Locale Identifier (see https://unicode.org/reports/tr35/tr35.html#Unicode_locale_identifier).
/// `length`: The length of the formatted time ("medium", "short" (default), or `none`).
#let fmt-time(
  dt,
  locale: "en",
  length: "short"
) = {
  assert(type(locale) == str)

  let opts = (locale: locale, length: length)
  let dt = datetime-to-dict(dt)

  assert(
    type(dt.hour) == int and 
    type(dt.minute) == int and 
    type(dt.second) == int
  )
  str(plug.format_time(bytes(cbor.encode(dt)), bytes(cbor.encode(opts))))
}

/// Formats a date and time in some `locale`. Dates are assumed to be ISO dates.
///
/// `dt`: The date and time to format. This can be a `datetime` or a dictionary with `year`, `month`, `day`, `hour`, `minute`, `second`, and (optionally) `nanosecond`.
/// `locale`: A Unicode Locale Identifier (see https://unicode.org/reports/tr35/tr35.html#Unicode_locale_identifier).
/// `date-length`: The length of the formatted date part ("full", "long" (default), "medium", "short", or `none`).
/// `time-length`: The length of the formatted time part ("medium", "short" (default), or `none`).
#let fmt-datetime(
  dt,
  locale: "en",
  date-length: "long",
  time-length: "short"
) = {
  assert(type(locale) == str)
  assert(type(date-length) == str)
  assert(type(time-length) == str)

  let opts = (
    locale: locale,
    date: date-length,
    time: time-length
  )
  let dt = datetime-to-dict(dt)

  assert(
    type(dt.year) == int and 
    type(dt.month) == int and 
    type(dt.day) == int and
    type(dt.hour) == int and 
    type(dt.minute) == int and 
    type(dt.second) == int
  )
  str(plug.format_datetime(bytes(cbor.encode(dt)), bytes(cbor.encode(opts))))
}

/// Formats a timezone in some `locale`.
///
/// `offset`: A string specifying the GMT offset (e.g. "-07", "Z", "+05", "+0500", "+05:00")
///
/// `iana`: Name of the IANA TZ identifier (e.g. "Brazil/West" - see https://www.iana.org/time-zones and https://en.wikipedia.org/wiki/List_of_tz_database_time_zones). This is mutually exclusive with `bcp47`. This identifier will be converted to a BCP-47 ID.
/// `bcp47`: Name of the BCP-47 timezone ID (e.g. "iodga" - see https://github.com/unicode-org/cldr/blob/main/common/bcp47/timezone.xml). This is mutually exclusive with `iana`.
///
/// `local-date`: A local date to calculate the metazone-id. This is mutually exclusive with `metazone-id`. When formatting zoned-datetimes this isn't necessary.
/// `metazone-id`: A short ID of the metazone. A metazone is a collection of multiple time zones that share the same localized formatting at a particular date and time (e.g. "phil" - see https://github.com/unicode-org/cldr/blob/main/common/supplemental/metaZones.xml (bottom)).
///
/// `zone-variant`: Many metazones use different names and offsets in the summer than in the winter. In ICU4X, this is called the _zone variant_. Supports `none`, `"st"` (standard), and `"dt"` (daylight).
///
/// `locale`: A Unicode Locale Identifier (see https://unicode.org/reports/tr35/tr35.html#Unicode_locale_identifier)
/// `fallback`: The timezone format fallback. Either `"LocalizedGmt"` or a dictionary for an ISO 8601 fallback (e.g. `(iso8601: (format: "basic", minutes: "required", seconds: "never"))`).
/// `includes`: An array or a single item (str/dictionary) of part(s) to include - corresponds to calls on `TimeZoneFormatter` (https://docs.rs/icu/latest/icu/datetime/time_zone/struct.TimeZoneFormatter.html). Valid options are:
///   `generic-location-format` (e.g. "Los Angeles Time")
///   `generic-non-location-long` (e.g. "Pacific Time")
///   `generic-non-location-short` (e.g. "PT")
///   `localized-gmt-format` (e.g. "GMT-07:00")
///   `specific-non-location-long` (e.g. "Pacific Standard Time")
///   `specific-non-location-short` (e.g. "PDT")
///   `iso8601`: A dictionary of ISO 8601 options `(iso8601: (format: "utc-basic", minutes: "optional", seconds: "optional"))` (e.g. "-07:00")
#let fmt-timezone(
  offset,

  iana: none,
  bcp47: none,

  local-date: none,
  metazone-id: none,

  zone-variant: none,

  locale: "en",
  fallback: "localized-gmt",
  includes: ()
) = {
  assert(type(includes) == array or type(includes) == str or type(includes) == dictionary)
  assert(type(locale) == str)

  let tz = make-timezone-dict(
    offset,
    iana: iana,
    bcp47: bcp47,
    local-date: local-date,
    metazone-id: metazone-id,
    zone-variant: zone-variant
  )

  let opts = (
    locale: locale,
    fallback: fallback,
    includes: if type(includes) == array { includes } else { (includes,) },
  )
  str(plug.format_timezone(bytes(cbor.encode(tz)), bytes(cbor.encode(opts))))
}

/// Formats a date and a time in a timezone. Dates are assumed to be ISO dates.
///
/// `dt`: The date and time to format. This can be a `datetime` or a dictionary with `year`, `month`, `day`, `hour`, `minute`, `second`, and (optionally) `nanosecond`.
/// `zone`: The timezone. A dictionary with `offset`, `iana`, `bcp47`, `metazone-id`, and `zone-variant`. The options correspond to the arguments for `fmt-timezone`. Only `offset` is mandatory - the other fields provide supplemental information for named timezones.
/// `locale`: A Unicode Locale Identifier (see https://unicode.org/reports/tr35/tr35.html#Unicode_locale_identifier)
/// `fallback`: The timezone format fallback. Either `"LocalizedGmt"` or a dictionary for an ISO 8601 fallback (e.g. `(iso8601: (format: "basic", minutes: "required", seconds: "never"))`).
/// `date-length`: The length of the formatted date part ("full", "long" (default), "medium", "short", or `none`).
/// `time-length`: The length of the formatted time part ("full", "long" (default), "medium", "short", or `none`).
#let fmt-zoned-datetime(
  dt,
  zone,

  locale: "en",
  fallback: "localized-gmt",
  date-length: "long",
  time-length: "long"
) = {
  assert(type(zone) == dictionary)
  assert(type(locale) == str)
  assert(type(date-length) == str)
  assert(type(time-length) == str)

  let dt = datetime-to-dict(dt)
  let tz = make-timezone-dict(
    zone.offset,
    iana: zone.at("iana", default: none),
    bcp47: zone.at("bcp47", default: none),
    local-date: none,
    metazone-id: zone.at("metazone-id", default: none),
    zone-variant: zone.at("zone-variant", default: none),
  )

  let spec = (
    datetime: dt,
    timezone: tz,
  )

  let opts = (
    locale: locale,
    fallback: fallback,
    date: date-length,
    time: time-length,
  )
  str(plug.format_zoned_datetime(bytes(cbor.encode(spec)), bytes(cbor.encode(opts))))
}
