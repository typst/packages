#let dayNames =  toml("dayName.toml") 
#let monthNames = toml("monthName.toml")

#let firstLetterToUpper(string) = (
  string.replace(regex("^\w"), m=>{upper(m.text)})
) 

#let dayName(weekday, lang: "en", upper: false) = (
  let weekdayToStr = str(weekday),
  if upper == true {
    return firstLetterToUpper(dayNames.at(lang).at(weekdayToStr))
  } else {
    return dayNames.at(lang).at(weekdayToStr)
  }
)

#let monthName(month, lang: "en", upper: false) = (
  let monthToStr = str(month),
  if upper == true {
    return firstLetterToUpper(monthNames.at(lang).at(monthToStr))
  } else {
    return monthNames.at(lang).at(monthToStr)
  }
)

#let writtenDate(date, lang: "en") = (
  return [#dayName(date.weekday, lang: lang) #date.day #monthName(date.month, lang: lang) #date.year]
)
