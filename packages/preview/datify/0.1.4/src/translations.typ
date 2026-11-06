#import "utils.typ": first-letter-to-upper
#import "config.typ": default-date-lang

#let day-names = toml("translations/day_name.toml")
#let month-names = toml("translations/month_name.toml")

#let day-name = (weekday, ..args) => {
  let lang = default-date-lang
  let upper = false
  for arg in args.pos() {
    if type(arg) == str {
      lang = arg
    } else if type(arg) == bool {
      upper = arg
    }
  }
  let weekday-to-str = str(weekday)
  let name = day-names.at(lang).at(weekday-to-str)
  if upper {
    return first-letter-to-upper(name)
  } else {
    return name
  }
}

#let month-name = (month, ..args) => {
  let lang = default-date-lang
  let upper = false
  for arg in args.pos() {
    if type(arg) == str {
      lang = arg
    } else if type(arg) == bool {
      upper = arg
    }
  }
  let month-to-str = str(month)
  let name = month-names.at(lang).at(month-to-str)
  if upper {
    return first-letter-to-upper(name)
  } else {
    return name
  }
}
