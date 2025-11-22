
/// parse datetime string in RFC 3339 format. *NOT* ISO 8601!
///
/// === The rule of RFC 3339:
///  ```
///  date-fullyear  = 4DIGIT
///  date-month     = 2DIGIT  ; 01-12
///  date-mday      = 2DIGIT  ; 01-28, 01-29, 01-30, 01-31 based on month/year
///  time-hour      = 2DIGIT  ; 00-23
///  time-minute    = 2DIGIT  ; 00-59
///  time-second    = 2DIGIT  ; 00-58, 00-59, 00-60 based on leap second rules
///  time-secfrac   = "." 1*DIGIT
///  time-numoffset = ("+" / "-") time-hour ":" time-minute
///  time-offset    = "Z" / time-numoffset
///  full-date      = date-fullyear "-" date-month "-" date-mday
///  full-time      = partial-time time-offset
///  date-time      = full-date "T" full-time
///  ```
///
/// - date-str (str): a datetime string in RFC 3339 format
/// - offset (duration): time offset of output datetime
/// -> datetime
#let parse-rfc3339(date-str, offset: duration(hours: 0, minutes: 0)) = {
  assert(type(date-str) == str)
  date-str = date-str.trim()

  // parse year, 4 digit
  let year = int(date-str.slice(0, 4))
  assert(date-str.at(4) == "-")
  date-str = date-str.slice(5)

  // parse month, 2 digit
  let month = int(date-str.slice(0, 2))
  assert(date-str.at(2) == "-")
  date-str = date-str.slice(3)

  // parse day, 2 digit
  let day = int(date-str.slice(0, 2))
  assert(date-str.at(2) == "T")
  date-str = date-str.slice(3)

  // parse hour, 2 digit
  let hour = int(date-str.slice(0, 2))
  assert(date-str.at(2) == ":")
  date-str = date-str.slice(3)

  // parse minute, 2 digit
  let minute = int(date-str.slice(0, 2))
  assert(date-str.at(2) == ":")
  date-str = date-str.slice(3)

  // parse second, 2 digit
  let second = int(date-str.slice(0, 2))
  date-str = date-str.slice(2)

  let date = datetime(year: year, month: month, day: day, hour: hour, minute: minute, second: second)

  if date-str.at(0) != "Z" {
    assert(date-str.starts-with("+") or date-str.starts-with("-"))
    let offset-strs = date-str.split(":")
    assert(offset-strs.len() == 2)
    let offset-hour = int(offset-strs.at(0))
    let offset-minute = int(offset-strs.at(1))
    offset = duration(hours: offset-hour, minutes: offset-minute) - offset
  }

  return date - offset
}

