#let data = toml("translations/cldr-dates.toml")

#let get-day-name = (
  weekday,
  lang: "en",
  usage: "stand-alone",
  width: "wide",
) => {
  let weekday_type = type(weekday)

  // Only accept int or str
  if not (weekday_type == int or weekday_type == str) {
    panic("Invalid weekday type: must be an integer or a string, got " + str(type(weekday)))
  } else {
    if weekday_type == int {
      if not (weekday >= 1 and weekday <= 7) {
        panic("Invalid weekday: " + str(weekday) + " (must be 1–7)")
      }
    } else {
      if not (weekday >= "1" and weekday <= "7") {
        panic("Invalid weekday: " + weekday + " (must be \"1\"–\"7\")")
      }
    }
  }

  let weekday_str = str(weekday)

  if not data.keys().contains(lang) {
    panic("Unknown language: " + lang)
  }
  let days = data.at(lang).at("days")
  if not days.keys().contains(usage) {
    panic("Invalid day usage: " + usage + " (must be 'format' or 'stand-alone')")
  }
  let day_usage = days.at(usage)
  if not day_usage.keys().contains(width) {
    panic("Invalid day width: " + width + " (must be 'wide', 'abbreviated', 'narrow')")
  }
  let width_map = day_usage.at(width)
  if not width_map.keys().contains(weekday_str) {
    panic("No day name for weekday " + weekday_str + " in language " + lang + ", usage " + usage + ", width " + width)
  }
  return width_map.at(weekday_str)
}

#let get-month-name = (
  month,
  lang: "en",
  usage: "stand-alone", // "format" or "stand-alone"
  width: "wide", // "wide", "abbreviated", "narrow"
) => {
  let month_type = type(month)

  // Only accept int or str
  if not (month_type == int or month_type == str) {
    panic("Invalid month type: must be an integer or a string, got " + str(type(month)))
  } else {
    if month_type == int {
      if not (month >= 1 and month <= 12) {
        panic("Invalid month: " + str(month) + " (must be 1–12)")
      }
    } else {
      if not (month >= "1" and month <= "12") {
        panic("Invalid month: " + month + " (must be \"1\"–\"12\")")
      }
    }
  }

  let month_str = str(month)

  if not data.keys().contains(lang) {
    panic("Unknown language: " + lang)
  }
  let months = data.at(lang).at("months")
  if not months.keys().contains(usage) {
    panic("Invalid month usage: " + usage + " (must be 'format' or 'stand-alone')")
  }
  let month_usage = months.at(usage)
  if not month_usage.keys().contains(width) {
    panic("Invalid month width: " + width + " (must be 'wide', 'abbreviated', 'narrow')")
  }
  let width_map = month_usage.at(width)
  if not width_map.keys().contains(month_str) {
    panic("No month name for month " + month_str + " in language " + lang + ", usage " + usage + ", width " + width)
  }
  return width_map.at(month_str)
}

#let get-date-pattern = (
  pattern-type,
  lang: "en",
) => {
  if not data.keys().contains(lang) {
    panic("Unknown language: " + lang)
  }
  let patterns = data.at(lang).at("patterns")
  // If pattern_type is a known key, return the pattern from data.
  // Otherwise, if a string, treat as custom pattern and return as-is.
  if patterns.keys().contains(pattern-type) {
    return patterns.at(pattern-type)
  } else if (type(pattern-type) == str) {
    return pattern-type
  } else {
    panic("Invalid pattern type: must be a string or a known pattern key, got " + str(type(pattern-type)))
  }
}
