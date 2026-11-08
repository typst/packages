#import "generated/closing.typ": closing-table

/// Lowercase locale IDs with case-insensitive input; exact code, base language,
/// then English fallback. Explicit overrides always win.
#let base-language(locale) = locale.split("-").at(0)

#let resolve-key(locale) = {
  let lowered = lower(locale)
  let base = base-language(lowered)
  if lowered in closing-table.locales {
    lowered
  } else if base in closing-table.locales {
    base
  } else {
    closing-table.fallback
  }
}

#let closing(locale, override: none) = {
  if override != none {
    override
  } else {
    closing-table.locales.at(resolve-key(locale), default: "")
  }
}

/// Available lowercase locale IDs, sorted.
#let available-locales() = closing-table.locales.keys().sorted()
