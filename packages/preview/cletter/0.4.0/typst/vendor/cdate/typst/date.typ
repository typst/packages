#import "generated/dates.typ": dates-table

/// Lowercase locale IDs with case-insensitive input; exact code, base language,
/// then English fallback. Explicit overrides always win.
#let base-language(locale) = locale.split("-").at(0)

#let resolve-key(locale) = {
  let lowered = lower(locale)
  let base = base-language(lowered)
  if lowered in dates-table.locales {
    lowered
  } else if base in dates-table.locales {
    base
  } else {
    dates-table.fallback
  }
}

/// February length with the Gregorian leap rule (divisible by 4, except
/// centuries unless divisible by 400).
#let days-in-month(year, month) = {
  if month in (1, 3, 5, 7, 8, 10, 12) {
    31
  } else if month in (4, 6, 9, 11) {
    30
  } else if month == 2 and calc.rem(year, 4) == 0 and (calc.rem(year, 100) != 0 or calc.rem(year, 400) == 0) {
    29
  } else if month == 2 {
    28
  } else {
    0
  }
}

#let is-valid-date(year, month, day) = {
  type(year) == int and type(month) == int and type(day) == int and month >= 1 and month <= 12 and day >= 1 and day <= days-in-month(year, month)
}

#let pad-two(value) = if value < 10 { "0" + str(value) } else { str(value) }

#let pad-year(year) = {
  let text = str(year)
  if year < 0 or year >= 1000 {
    text
  } else if year >= 100 {
    "0" + text
  } else if year >= 10 {
    "00" + text
  } else {
    "000" + text
  }
}

#let render(entry, pattern, year, month, day) = {
  pattern
    .replace("{yyyy}", pad-year(year))
    .replace("{yy}", pad-two(calc.rem(calc.rem(year, 100) + 100, 100)))
    .replace("{month_long}", entry.months_long.at(month - 1))
    .replace("{month_short}", entry.at("months_short", default: ()).at(month - 1, default: ""))
    .replace("{dd}", pad-two(day))
    .replace("{mm}", pad-two(month))
    .replace("{day}", str(day))
    .replace("{month}", str(month))
}

#let format-with(locale, field, year, month, day) = {
  if not is-valid-date(year, month, day) {
    none
  } else {
    let entry = dates-table.locales.at(resolve-key(locale))
    render(entry, entry.at(field), year, month, day)
  }
}

/// Long date: `7. September 2026` (de), `September 7, 2026` (en).
#let long-date(locale, year, month, day) = format-with(locale, "long", year, month, day)

/// Medium date: `07.09.2026` (de), `Sep 7, 2026` (en).
#let medium-date(locale, year, month, day) = format-with(locale, "medium", year, month, day)

/// Short numeric date: `07.09.26` (de), `9/7/26` (en).
#let short-date(locale, year, month, day) = format-with(locale, "short", year, month, day)

/// Month and year for a correspondence dateline: `September 2026`.
#let month-year(locale, year, month) = {
  if type(year) != int or type(month) != int or month < 1 or month > 12 {
    none
  } else {
    let entry = dates-table.locales.at(resolve-key(locale))
    render(entry, entry.month_year, year, month, 1)
  }
}

/// Whether a locale code is supported: present in the supported set
/// directly or through its (lowercased) base language.
#let is-supported(locale) = {
  locale in dates-table.supported or base-language(lower(locale)) in dates-table.supported
}

/// Available lowercase locale IDs, sorted.
#let available-locales() = dates-table.locales.keys().sorted()
