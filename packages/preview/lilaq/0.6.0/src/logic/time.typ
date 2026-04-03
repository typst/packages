#let reference-datetime = datetime(year: 0, month: 1, day: 1, hour: 0, minute: 0, second: 0)
#let reference-time = datetime(hour: 0, minute: 0, second: 0)
#let reference-date = datetime(year: 0, month: 1, day: 1)

#let to-seconds(..datetimes, return-mode: false) = {
  datetimes = datetimes.pos()
  if datetimes.len() == 0 { return () }
  assert(
    datetimes.all(dt => type(dt) == datetime),
    message: "When passing datetime values, all entries need to be of type datetime"
  )

  let reference
  let mode
  let dt = datetimes.first()
  let assert-same-type = assert.with(
    message: "All datetimes must be of the same type (all time, all date, or all datetime)."
  )
  if dt.hour() == none {
    mode = "date"
    reference = reference-date
    assert-same-type(datetimes.all(dt => dt.hour() == none))
  } else if dt.year() == none {
    mode = "time"
    reference = reference-time
    assert-same-type(datetimes.all(dt => dt.year() == none))
  } else {
    mode = "datetime"
    reference = reference-datetime
    assert-same-type(datetimes.all(dt => dt.hour() != none and dt.year() != none))
  }

  let seconds = datetimes.map(dt => (dt - reference).seconds())
  if return-mode {
    (mode: mode, seconds: seconds)
  } else {
    seconds
  }
}


#let to-datetime(..seconds, mode: "datetime") = {
  seconds = seconds.pos()
  let reference = if mode == "datetime" {
    reference-datetime
  } else if mode == "date" {
    reference-date
  } else if mode == "time" {
    reference-time
  } else {
    assert(false, "Unsupported mode")
  }

  
  seconds.map(seconds => reference + duration(seconds: int(seconds)))
}


#to-seconds(
  datetime(year: 2025, month: 8, day: 4),
  datetime(year: 2025, month: 8, day: 7),
  // reference-datetime
)
#to-seconds(
  // reference-time,
  reference-datetime,
  reference-datetime
)


#let with(
  date, 
  year: auto, month: auto, day: auto,
  hour: auto, minute: auto, second: auto
) = {
  if year == auto { year = date.year() }
  if month == auto { month = date.month() }
  if day == auto { day = date.day() }

  if hour == auto { hour = date.hour() }
  if minute == auto { minute = date.minute() }
  if second == auto { second = date.second() }
  
  let has-date = (year, month, day).any(x => x != none)
  let has-time = (hour, minute, second).any(x => x != none)
  if has-date and has-time {
    datetime(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second
    )
  } else if has-date {
    datetime(
      year: year,
      month: month,
      day: day
    )
  } else {
    datetime(
      hour: hour,
      minute: minute,
      second: second
    )
  }
}


#assert.eq(
  with(datetime(year: 2002, month: 3, day: 3), year: 1999),
  datetime(year: 1999, month: 3, day: 3)
)
#assert.eq(
  with(datetime(year: 2002, month: 3, day: 3), year: 1999, month: 12),
  datetime(year: 1999, month: 12, day: 3)
)
#assert.eq(
  with(datetime(year: 2002, month: 3, day: 3), day: 31, month: 12),
  datetime(year: 2002, month: 12, day: 31)
)

#assert.eq(
  with(datetime(hour: 2, minute: 22, second: 8), second: 7),
  datetime(hour: 2, minute: 22, second: 7)
)
#assert.eq(
  with(datetime(hour: 2, minute: 22, second: 8), minute: 27),
  datetime(hour: 2, minute: 27, second: 8)
)
#assert.eq(
  with(datetime(hour: 2, minute: 22, second: 8), hour: 7),
  datetime(hour: 7, minute: 22, second: 8)
)
