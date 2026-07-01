
#let extract-year(x) = x.slice(0,4)
#let extract-month(x) = x.slice(5,7)
#let extract-day(x) = x.slice(8,10)

#let extract-hour(x) = x.slice(11,13)
#let extract-minute(x) = x.slice(14,16)
#let extract-second(x) = x.slice(17,19)

#let as-date-time(x) = datetime(
  day: int(extract-day(x)),
  month: int(extract-month(x)),
  year: int(extract-year(x)),
  hour: int(extract-hour(x)),
  minute: int(extract-minute(x)),
  second: int(extract-second(x)),)

  
#let as-date(x) = datetime(
  day: int(extract-day(x)),
  month: int(extract-month(x)),
  year: int(extract-year(x)))
  

#let parse-date-time(x) = {
  
  assert(x.len() == 10 or x.len() == 19, message: "date or datetime required")
  
  if x.len() == 10 { // simple date
    as-date(x)
  } else { // date and time
    as-date-time(x)
  }
}

// utility copied from
// https://github.com/HPDell/typst-cineca/blob/main/util/utils.typ#L65
#let get-month-days(month, year) = {
  if month in (1,3,5,7,8,10,12) {
    return 31
  } else if month in (4,6,9,11) {
    return 30
  } else {
    if (calc.fract(year / 4) == 0.0) and (calc.fract(year / 400) != 0.0) {
      return 29
    } else {
      return 28
    }
  }
}

#let epoch = datetime(year: 1970, month: 01, day: 01, hour: 0, minute: 0, second: 0)

#let unix-to-datetime(stamp, offset: duration(days: 0)) = {
  let dt = epoch + duration(seconds: int(stamp/1000)) + duration(hours: 12) + offset // NZ
  dt.display()
}
