# icu-datetime

<!-- markdownlint-disable-file MD033 -->
<!-- markdownlint-configure-file { "no-duplicate-heading": { "siblings_only": true } } -->

This library is a wrapper around [ICU4X](https://github.com/unicode-org/icu4x)' `datetime` formatting for Typst which provides internationalized formatting for dates, times, and timezones.

As the WASM bundle includes all localization data, it's quite large (about 8 MiB).

See [nerixyz.github.io/icu-typ](https://nerixyz.github.io/icu-typ) for a full API reference with more examples.

## Example

```typ
#import "@preview/icu-datetime:0.1.2": fmt-date, fmt-time, fmt-datetime, experimental
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
#let tz = (
  offset: "-07",
  iana: "America/Los_Angeles",
  zone-variant: "st", // standard
)

= Dates
#fmt-date(day, locale: "km", length: "full") \
#fmt-date(day, locale: "af", length: "full") \
#fmt-date(day, locale: "za", length: "full") \

= Time
#fmt-time(time, locale: "id", length: "medium") \
#fmt-time(time, locale: "en", length: "medium") \
#fmt-time(time, locale: "ga", length: "medium") \

= Date and Time
#fmt-datetime(dt, locale: "ru", date-length: "full") \
#fmt-datetime(dt, locale: "en-US", date-length: "full") \
#fmt-datetime(dt, locale: "zh-Hans-CN", date-length: "full") \
#fmt-datetime(dt, locale: "ar", date-length: "full") \
#fmt-datetime(dt, locale: "fi", date-length: "full")

= Timezones (experimental)
#fmt-timezone(
  ..tz,
  local-date: datetime.today(),
  format: "specific-non-location-long"
) \
#fmt-timezone(
  ..tz,
  format: (
    iso8601: (
      format: "utc-extended",
      minutes: "required",
      seconds: "optional",
    )
  )
)

= Zoned Datetimes (experimental)
#fmt-zoned-datetime(dt, tz) \
#fmt-zoned-datetime(dt, tz, locale: "lv") \
#fmt-zoned-datetime(dt, tz, locale: "en-CA-u-hc-h24-ca-buddhist")
```

<!-- typst c res/example.typ res/example.png --root . -->

![Example](res/example.png)

Locales must be [Unicode Locale Identifier]s.
Use [`locale-info(locale)`](https://nerixyz.github.io/icu-typ/locale-info/) to get information on how a locale is parsed.
Unicode extensions are supported, so you can, for example, set the hour cycle with `hc-h12` or set the calendar with `ca-buddhist` (e.g. `en-CA-u-hc-h24-ca-buddhist`).

## Documentation

Documentation can be found on [nerixyz.github.io/icu-typ](https://nerixyz.github.io/icu-typ).

## Using Locally

Download the [latest release](https://github.com/Nerixyz/icu-typ/releases), unzip it to your [local Typst packages](https://github.com/typst/packages#local-packages), and use `#import "@local/icu-datetime:0.1.2"`.

## Building

To build the library, you need to have [Rust](https://www.rust-lang.org/), [just](https://just.systems/), and [`wasm-opt`](https://github.com/WebAssembly/binaryen) installed.

```sh
just build
# to deploy the package locally, use `just deploy`
```

While developing, you can symlink the WASM file into the root of the repository (it's in the `.gitignore`):

```sh
# Windows (PowerShell)
New-Item icu-datetime.wasm -ItemType SymbolicLink -Value ./target/wasm32-unknown-unknown/debug/icu_typ.wasm
# Unix
ln -s ./target/wasm32-unknown-unknown/debug/icu_typ.wasm icu-datetime.wasm
```

Use `cargo b --target wasm32-unknown-unknown` to build in debug mode.

[Unicode Locale Identifier]: https://unicode.org/reports/tr35/tr35.html#Unicode_locale_identifier
