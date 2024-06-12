# icu-datetime

This library is a wrapper around [ICU4X](https://github.com/unicode-org/icu4x)' `datetime` formatting for Typst which provides internationalized formatting for dates, times, and timezones.

As the WASM bundle includes all localization data, it's quite large (about 8 MiB).

## Example

```typ
#import "@preview/icu-datetime:0.1.0": fmt-date, fmt-time, fmt-datetime, experimental
// These functions may change at any time
#import experimental: fmt-timezone, fmt-zoned-datetime

#let day = datetime(
  year: 2024,
  month: 5,
  day: 31,
)
#let time = datetime(
  hour: 18,
  minute: 2,
  second: 23,
)
#let dt = datetime(
  year: 2024,
  month: 5,
  day: 31,
  hour: 18,
  minute: 2,
  second: 23,
)

#fmt-date(day, locale: "de", length: "full") \
#fmt-time(time, locale: "de", length: "medium") \
#fmt-datetime(dt, locale: "fi", date-length: "full") \
#fmt-timezone(
  "-07",
  iana: "America/Los_Angeles",
  local-date: dt,
  zone-variant: "st",
  includes: "specific-non-location-long"
) \
#fmt-zoned-datetime(
  dt,
  (
    offset: "-07",
    iana: "America/Los_Angeles",
    zone-variant: "st", // standard
  )
)
```

<!-- typst c res/example.typ res/example.png --root . -->

![Example](res/example.png)

## API

### `fmt-date`

```typ
#let fmt-date(
  dt,
  locale: "en",
  length: "full"
)
```

Formats a date in some `locale`. Dates are assumed to be ISO dates.

- `dt`: The date to format. This can be a [`datetime`] or a dictionary with `year`, `month`, `day`.
- `locale`: A [Unicode Locale Identifier].
- `length`: The length of the formatted date ("full", "long" (default), "medium", "short", or `none`).

### `fmt-time`

```typ
#let fmt-time(
  dt,
  locale: "en",
  length: "short"
)
```

Formats a time in some `locale`.

- `dt`: The time to format. This can be a [`datetime`] or a dictionary with `hour`, `minute`, `second`, and (optionally) `nanosecond`.
- `locale`: A [Unicode Locale Identifier].
- `length`: The length of the formatted time ("medium", "short" (default), or `none`).

### `fmt-datetime`

```typ
#let fmt-datetime(
  dt,
  locale: "en",
  date-length: "long",
  time-length: "short"
)
```

Formats a date and time in some `locale`. Dates are assumed to be ISO dates.

- `dt`: The date and time to format. This can be a [`datetime`] or a dictionary with `year`, `month`, `day`, `hour`, `minute`, `second`, and (optionally) `nanosecond`.
- `locale`: A [Unicode Locale Identifier].
- `date-length`: The length of the formatted date part ("full", "long" (default), "medium", "short", or `none`).
- `time-length`: The length of the formatted time part ("medium", "short" (default), or `none`).

### `fmt-timezone`

⚠ Warning: This function is experimental and can change at any time.

```typ
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
)
```

Formats a timezone in some `locale`.

- `offset`: A string specifying the GMT offset (e.g. "-07", "Z", "+05", "+0500", "+05:00")

- `iana`: Name of the IANA TZ identifier (e.g. "Brazil/West" - see [IANA](https://www.iana.org/time-zones) and [Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)). This is mutually exclusive with `bcp47`. This identifier will be converted to a BCP-47 ID.
- `bcp47`: Name of the BCP-47 timezone ID (e.g. "iodga" - see [timezone.xml](https://github.com/unicode-org/cldr/blob/main/common/bcp47/timezone.xml)). This is mutually exclusive with `iana`.

- `local-date`: A local date to calculate the metazone-id. This is mutually exclusive with `metazone-id`. When formatting zoned-datetimes this isn't necessary.
- `metazone-id`: A short ID of the metazone. A metazone is a collection of multiple time zones that share the same localized formatting at a particular date and time (e.g. "phil" - see [metaZones.xml](https://github.com/unicode-org/cldr/blob/main/common/supplemental/metaZones.xml) (bottom)).

- `zone-variant`: Many metazones use different names and offsets in the summer than in the winter. In ICU4X, this is called the _zone variant_. Supports `none`, `"st"` (standard), and `"dt"` (daylight).

- `locale`: A [Unicode Locale Identifier]
- `fallback`: The timezone format fallback. Either `"LocalizedGmt"` or a dictionary for an ISO 8601 fallback (e.g. `(iso8601: (format: "basic", minutes: "required", seconds: "never"))`).
- `includes`: An array or a single item (str/dictionary) of part(s) to include - corresponds to calls on [`TimeZoneFormatter`](https://docs.rs/icu/latest/icu/datetime/time_zone/struct.TimeZoneFormatter.html). Valid options are:
  - `generic-location-format` (e.g. "Los Angeles Time")
  - `generic-non-location-long` (e.g. "Pacific Time")
  - `generic-non-location-short` (e.g. "PT")
  - `localized-gmt-format` (e.g. "GMT-07:00")
  - `specific-non-location-long` (e.g. "Pacific Standard Time")
  - `specific-non-location-short` (e.g. "PDT")
  - `iso8601`: A dictionary of ISO 8601 options `(iso8601: (format: "utc-basic", minutes: "optional", seconds: "optional"))` (e.g. "-07:00")

### `fmt-zoned-datetime`

⚠ Warning: This function is experimental and can change at any time.

```typ
#let fmt-zoned-datetime(
  dt,
  zone,

  locale: "en",
  fallback: "localized-gmt",
  date-length: "long",
  time-length: "long"
)
```

Formats a date and a time in a timezone. Dates are assumed to be ISO dates.

- `dt`: The date and time to format. This can be a [`datetime`] or a dictionary with `year`, `month`, `day`, `hour`, `minute`, `second`, and (optionally) `nanosecond`.
- `zone`: The timezone. A dictionary with `offset`, `iana`, `bcp47`, `metazone-id`, and `zone-variant`. The options correspond to the arguments for `fmt-timezone`. Only `offset` is mandatory - the other fields provide supplemental information for named timezones.
- `locale`: A [Unicode Locale Identifier]
- `fallback`: The timezone format fallback. Either `"localized-gmt"` or a dictionary for an ISO 8601 fallback (e.g. `(iso8601: (format: "basic", minutes: "required", seconds: "never"))`).
- `date-length`: The length of the formatted date part ("full", "long" (default), "medium", "short", or `none`).
- `time-length`: The length of the formatted time part ("full", "long" (default), "medium", "short", or `none`).

## Using Locally

Download the [latest release](https://github.com/Nerixyz/icu-typ/releases), unzip it to your [local Typst packages](https://github.com/typst/packages#local-packages), and use `#import "@local/icu-datetime:0.1.0"`.

## Building

To build the library, you need to have [Rust](https://www.rust-lang.org/), [Deno](https://deno.com/), and [`wasm-opt`](https://github.com/WebAssembly/binaryen) installed.

```sh
deno task build
```

While developing, you can symlink the WASM file into the root of the repository (it's in the `.gitignore`):

```sh
# Windows (PowerShell)
New-Item icu-datetime.wasm -ItemType SymbolicLink -Value ./target/wasm32-unknown-unknown/debug/icu_typ.wasm
# Unix
ln -s ./target/wasm32-unknown-unknown/debug/icu_typ.wasm icu-datetime.wasm
```

Use `cargo b --target wasm32-unknown-unknown` to build in debug mode.

[`datetime`]: https://typst.app/docs/reference/foundations/datetime/
[Unicode Locale Identifier]: https://unicode.org/reports/tr35/tr35.html#Unicode_locale_identifier
