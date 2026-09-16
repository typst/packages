#import "./locales.typ": i18n

#let location-to-str(location) = {
  if type(location) == str {
    return location
  } else if type(location) == type((:)) {
    let city = location.at("city", default: "")
    let country = location.at("country", default: "")
    if city != "" and country != "" {
      return city + ", " + country
    } else if city != "" {
      return city
    } else if country != "" {
      return country
    } else {
      return ""
    }
  } else {
    return ""
  }
}

#let date-to-str(
  date: false,
  lang: "en-US",
) = {
  if date == false {
    return i18n.present.at(lang)
  } else if type(date) == str {
    return date
  } else if type(date) == type((:)) {
    let year = date.at("year", default: "")
    let month = date.at("month", default: "")
    let day = date.at("day", default: "")
    if year != "" and month != "" and day != "" {
      return [#year\-#month\-#day]
    } else if year != "" and month != "" {
      return [#year\-#month]
    } else if year != "" {
      return year
    } else {
      return ""
    }
  } else {
    return ""
  }
}
