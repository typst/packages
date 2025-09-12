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

/// Formats a date, time, or timezone.
///
/// If `date-fields`, `time-precision`, and `zone-style` all use their default values (`auto`),
/// then the format will be automatically selected based on the provided `dt` and `zone`:
/// - If `dt` has date fields, then `date-fields` will be set to "YMD"
/// - If `dt` has time fields, then `time-precision` will be set to "minute"
/// - If `zone` has a value, then `zone-style` will be set to "localized-offset-short"
///
/// - dt (dictionary, datetime): The date and time to format. This can be a `datetime` or a dictionary with `year`, `month`, `day`, `hour`, `minute`, `second`, and (optionally) `nanosecond`.
/// - zone (dictionary, none): The timezone. A dictionary with `offset`, `iana`, `bcp47`, `metazone-id`, and `zone-variant`. The options correspond to the arguments for `fmt-timezone`. Only `offset` is mandatory - the other fields provide supplemental information for named timezones.
/// - locale (str): A Unicode Locale Identifier (see https://unicode.org/reports/tr35/tr35.html#Unicode_locale_identifier)
/// - length (str, none): The length of the formatted date part ("long", "medium" (default), "short", or `none`). The avialable options are also provided in `length` as a dictionary.
/// - date-fields (str, none, auto): The fields of the date to include in the formatted string. "D" (day of month), "MD", "YMD", "DE", "MDE", "YMDE", "E" (weekday), "M" (month), "YM", "Y" (year), `none`, or `auto` (default, see function documentation).
/// - time-precision (str, none, auto): How precise to display the time. "hour", "minute", "second", "subsecond{n}" (n subsecond digits), "minute-optional" ("hour" if `minutes == 0`, otherwise "minute"), `none`, or `auto` (default, see function documentation).
/// - zone-style (str, none): How to format the timezone (if any). "specific-long", "specific-short", "localized-offset-long", "localized-offset-short",  "generic-long", "generic-short", "location", "exemplar-city", `none`, or `auto` (default, see function documentation).
/// - alignment (str, none): How to align (pad) the formatted string. "auto", "column", or `none` (default, implies "auto").
/// - year-style (str, none): How to format the year and the era. "auto", "full", "with-era", `none` (default, implies "auto").
/// - experimental-pattern (str, none): Specifies the pattern to format that date as. This is mutually exclusive with all other named arguments except `zone` and `locale`. This argument is experimental. The calendar selection is implemented manually due to missing functionality in ICU4X. **This is a low-level utility that assumes the pattern is already localized for the target locale.** The full list of placeholders can be found on https://unicode.org/reports/tr35/tr35-dates.html#table-date-field-symbol-table. Note that this argument doesn't check that the date and time are fully specified. If some fields are left out, they're default initialized.
#let fmt(
  dt,
  zone: none,
  locale: "en",
  length: none,
  date-fields: auto,
  time-precision: auto,
  zone-style: auto,
  alignment: none,
  year-style: none,
  experimental-pattern: none,
) = {
  assert(type(locale) == str)

  let spec = datetime-to-dict(dt)
  if zone != none {
    spec.insert("zone", zone)
  }

  if experimental-pattern != none {
    return str(plug.format_pattern(cbor.encode(spec), bytes(locale), bytes(experimental-pattern)))
  }

  // only pick a format if all three are `auto`
  if date-fields == auto and time-precision == auto and zone-style == auto {
    let has-date = (
      spec.at("year", default: none) != none
        and spec.at("month", default: none) != none
        and spec.at("day", default: none) != none
    )
    let has-time = (
      spec.at("hour", default: none) != none
        and spec.at("minute", default: none) != none
        and spec.at("second", default: none) != none
    )
    let has-zone = zone != none

    if has-date {
      date-fields = "YMD"
    }
    if has-time {
      time-precision = "minute"
    }
    if has-zone {
      zone-style = "localized-offset-short"
    }
  }

  if date-fields == auto {
    date-fields = none
  }
  if time-precision == auto {
    time-precision = none
  }
  if zone-style == auto {
    zone-style = none
  }

  let opts = (
    length: length,
    date-fields: date-fields,
    time-precision: time-precision,
    zone-style: zone-style,
    alignment: alignment,
    year-style: year-style,
  )
  str(plug.format(cbor.encode(spec), bytes(locale), cbor.encode(opts)))
}

/// Gets information about ICU4X' understanding of the `locale`
///
/// `locale`: A Unicode Locale Identifier (see https://unicode.org/reports/tr35/tr35.html#Unicode_locale_identifier)
#let locale-info(locale) = {
  assert(type(locale) == str)

  cbor(plug.locale_info(bytes(locale)))
}
