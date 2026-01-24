// citeproc-typst - Date Formatting
//
// Uses Typst's native datetime for formatting

#import "../core/mod.typ": zero-pad
#import "../parsing/locales.typ": lookup-term

// =============================================================================
// Module-level constants (avoid recreating on each call)
// =============================================================================

// Date parsing regex patterns
#let _iso-date-pattern = regex("^(\\d{4})[-/](\\d{1,2})(?:[-/](\\d{1,2}))?$")
#let _year-only-pattern = regex("^(\\d{4})$")
#let _text-date-pattern = regex(
  "^([A-Za-z]+)\\s+(?:(\\d{1,2}),?\\s+)?(\\d{4})$",
)
#let _any-year-pattern = regex("(\\d{4})")
#let _full-iso-pattern = regex("\\d{4}-\\d{2}-\\d{2}")

// Month name to number mapping
#let _month-map = (
  "january": 1,
  "february": 2,
  "march": 3,
  "april": 4,
  "may": 5,
  "june": 6,
  "july": 7,
  "august": 8,
  "september": 9,
  "october": 10,
  "november": 11,
  "december": 12,
  "jan": 1,
  "feb": 2,
  "mar": 3,
  "apr": 4,
  "jun": 6,
  "jul": 7,
  "aug": 8,
  "sep": 9,
  "oct": 10,
  "nov": 11,
  "dec": 12,
)

/// Get ordinal suffix for a day number using locale terms
///
/// Uses CSL ordinal term priority:
/// 1. ordinal-10 through ordinal-99 (last-two-digits matching)
/// 2. ordinal-00 through ordinal-09 (last-digit matching)
/// 3. Generic "ordinal" term
///
/// - day: Day number (1-31)
/// - ctx: Context with locale terms
/// Returns: Ordinal suffix string
#let _get-day-ordinal-suffix(day, ctx) = {
  let last-two = calc.rem(day, 100)
  let last-one = calc.rem(day, 10)

  // Try ordinal-10 through ordinal-99 first
  if last-two >= 10 {
    let key = "ordinal-" + zero-pad(last-two, 2)
    let suffix = lookup-term(ctx, key, form: "long", plural: false)
    if suffix != "" and suffix != key {
      return suffix
    }
  }

  // Try ordinal-00 through ordinal-09
  let single-key = "ordinal-" + zero-pad(last-one, 2)
  let single-suffix = lookup-term(ctx, single-key, form: "long", plural: false)
  if single-suffix != "" and single-suffix != single-key {
    return single-suffix
  }

  // Fallback to generic ordinal term
  let generic = lookup-term(ctx, "ordinal", form: "long", plural: false)
  if generic != "" and generic != "ordinal" {
    return generic
  }

  // Ultimate fallback: English ordinals
  if day == 1 or day == 21 or day == 31 { "st" } else if day == 2 or day == 22 {
    "nd"
  } else if day == 3 or day == 23 { "rd" } else { "th" }
}

/// Parse a date string into a datetime object
///
/// Handles formats like:
/// - "2024" -> datetime(year: 2024)
/// - "2024-05" -> datetime(year: 2024, month: 5)
/// - "2024-05-15" -> datetime(year: 2024, month: 5, day: 15)
#let parse-date-string(date-str) = {
  if date-str == "" or date-str == none { return none }

  let s = str(date-str).trim()

  // Try ISO format: YYYY-MM-DD or YYYY/MM/DD
  let iso-match = s.match(_iso-date-pattern)
  if iso-match != none {
    let captures = iso-match.captures
    let year = int(captures.at(0))
    let month = if captures.len() > 1 and captures.at(1) != none {
      int(captures.at(1))
    } else { none }
    let day = if captures.len() > 2 and captures.at(2) != none {
      int(captures.at(2))
    } else { none }

    if month != none and day != none {
      // Validate day using Typst's native datetime arithmetic
      // Get last day of month by going to first of next month minus 1 day
      let (next-year, next-month) = if month == 12 { (year + 1, 1) } else {
        (year, month + 1)
      }
      let last-day-of-month = (
        datetime(year: next-year, month: next-month, day: 1) - duration(days: 1)
      ).day()
      let safe-day = calc.min(day, last-day-of-month)
      return datetime(year: year, month: month, day: safe-day)
    } else if month != none {
      return datetime(year: year, month: month, day: 1)
    } else {
      return datetime(year: year, month: 1, day: 1)
    }
  }

  // Try just year
  let year-match = s.match(_year-only-pattern)
  if year-match != none {
    return datetime(year: int(year-match.captures.at(0)), month: 1, day: 1)
  }

  // Try "Month Year" or "Month Day, Year"
  let text-match = s.match(_text-date-pattern)
  if text-match != none {
    let captures = text-match.captures
    let month-name = lower(captures.at(0))
    let month = _month-map.at(month-name, default: none)
    if month != none {
      let year = int(captures.at(2))
      let day = if captures.at(1) != none { int(captures.at(1)) } else { 1 }
      return datetime(year: year, month: month, day: day)
    }
  }

  // Fallback: try to extract year
  let any-year = s.match(_any-year-pattern)
  if any-year != none {
    return datetime(year: int(any-year.captures.at(0)), month: 1, day: 1)
  }

  none
}

/// Parse BibTeX date fields into a datetime object
///
/// BibTeX can have:
/// - year = {2024}
/// - month = {may} or month = {5}
/// - day = {15}
/// - date = {2024-05-15}  (biblatex)
#let parse-bibtex-date(fields) = {
  // Try biblatex date field first
  let date-field = fields.at("date", default: "")
  if date-field != "" {
    let parsed = parse-date-string(date-field)
    if parsed != none { return parsed }
  }

  // Fall back to year/month/day fields
  let year-str = fields.at("year", default: "")
  if year-str == "" { return none }

  let year = int(year-str)
  if year == none { return none }

  let month = 1
  let month-str = fields.at("month", default: "")
  if month-str != "" {
    // Month might be name or number
    let lower-month = lower(str(month-str))
    let month-num = _month-map.at(lower-month, default: none)
    if month-num != none {
      month = month-num
    } else {
      let parsed = int(month-str)
      if parsed != none { month = parsed }
    }
  }

  let day = 1
  let day-str = fields.at("day", default: "")
  if day-str != "" {
    let parsed = int(day-str)
    if parsed != none { day = parsed }
  }

  datetime(year: year, month: month, day: day)
}

/// Check if date has specific component
/// (We track this via metadata since datetime always has all components)
#let date-has-component(fields, component) = {
  if component == "year" {
    fields.at("year", default: "") != "" or fields.at("date", default: "") != ""
  } else if component == "month" {
    (
      fields.at("month", default: "") != ""
        or fields.at("date", default: "").contains("-")
    )
  } else if component == "day" {
    (
      fields.at("day", default: "") != ""
        or fields.at("date", default: "").matches(_full-iso-pattern) != none
    )
  } else {
    false
  }
}

/// Format a date-part using Typst's native datetime
///
/// - dt: datetime object
/// - name: "year", "month", or "day"
/// - form: CSL form ("numeric", "numeric-leading-zeros", "ordinal", "long", "short")
/// - ctx: Context for locale terms (used for ordinals)
#let format-date-part(dt, name, form, ctx) = {
  if dt == none { return "" }

  if name == "year" {
    // Note: year-suffix is NOT added here - it's handled by CSL's <text variable="year-suffix"/>
    dt.display("[year]")
  } else if name == "month" {
    if form == "numeric" {
      dt.display("[month padding:none]")
    } else if form == "numeric-leading-zeros" {
      dt.display("[month]")
    } else if form == "short" {
      dt.display("[month repr:short]")
    } else if form == "long" {
      dt.display("[month repr:long]")
    } else {
      dt.display("[month]")
    }
  } else if name == "day" {
    if form == "numeric" {
      dt.display("[day padding:none]")
    } else if form == "numeric-leading-zeros" {
      dt.display("[day]")
    } else if form == "ordinal" {
      let day = dt.day()
      // CSL locale option: limit-day-ordinals-to-day-1
      // If true, only day 1 uses ordinal form, others use numeric
      let limit-ordinals = ctx.at("limit-day-ordinals-to-day-1", default: false)
      if limit-ordinals and day != 1 {
        str(day)
      } else {
        // Use locale-aware ordinal suffixes
        let suffix = _get-day-ordinal-suffix(day, ctx)
        str(day) + suffix
      }
    } else {
      dt.display("[day]")
    }
  } else {
    ""
  }
}

/// Format a complete date
///
/// - dt: datetime object
/// - form: "numeric" or "text"
/// - date-parts: "year", "year-month", or "year-month-day"
/// - ctx: Context for locale
#let format-date-with-form(dt, form, date-parts, ctx) = {
  if dt == none { return [] }

  // Determine which parts to show
  let show-year = true
  let show-month = date-parts == "year-month" or date-parts == "year-month-day"
  let show-day = date-parts == "year-month-day"

  // Note: year-suffix is NOT added here - it's handled by CSL's <text variable="year-suffix"/>

  if form == "text" {
    // Text format: "January 15, 2024" or "January 2024" or "2024"
    if show-day and show-month {
      dt.display("[month repr:long] [day padding:none], [year]")
    } else if show-month {
      dt.display("[month repr:long] [year]")
    } else {
      dt.display("[year]")
    }
  } else {
    // Numeric format: "2024-01-15" or "2024-01" or "2024"
    if show-day and show-month {
      dt.display("[year]-[month]-[day]")
    } else if show-month {
      dt.display("[year]-[month]")
    } else {
      dt.display("[year]")
    }
  }
}

/// Main date formatting function for CSL
///
/// - date: datetime object or date string or fields dict
/// - attrs: Date formatting attributes from CSL
/// - ctx: Context
#let format-date(date, attrs, ctx) = {
  // Parse if needed
  let dt = if type(date) == datetime {
    date
  } else if type(date) == str {
    parse-date-string(date)
  } else if type(date) == dictionary {
    parse-bibtex-date(date)
  } else {
    none
  }

  if dt == none { return [] }

  let form = attrs.at("form", default: "numeric")
  let date-parts = attrs.at("date-parts", default: "year-month-day")

  format-date-with-form(dt, form, date-parts, ctx)
}
