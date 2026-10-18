#import "@preview/cetz:0.5.2" as cetz

// A function to convert ISO-8601 dates as strings into a datetime element
#let to-datetime(date) = {
  if type(date) == datetime {
    return date
  }
  else {
    let reg-complete = "^([1-2][0-9][0-9][0-9])-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])[T](0[0-9]|[1][0-9]|[2][0-4]):(0[0-9]|[1-5][0-9]):(0[0-9]|[1-5][0-9])|([1-2][0-9][0-9][0-9])-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])[T]((0[0-9]|[1][0-9]|[2][0-4]):(0[0-9]|[1-5][0-9]))|([1-2][0-9][0-9][0-9])-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])[T](0[0-9]|[1][0-9]|[2][0-4])$"
    let reg-minimal = "^([1-2][0-9][0-9][0-9])-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$"
    assert(
      date.match(regex(reg-complete)) != none or (date.match(regex(reg-minimal)) != none and date.len() == 10), 
      message: "A date must be of the form \"yyyy-mm-dd-Thh:mm:ss\", \"yyyy-mm-dd-Thh:mm\", \"yyyy-mm-ddThh\" or \"yyyy-mm-dd\"."
    )
    let split = date.split("T")
    let (_date, _time) = if split.len() == 1 {
      (split.at(0), "00:00:01")
    } else {
      split
    }
    let seq = (_date.split("-") + _time.split(":") + ("0", "0")).map(it => int(it))
    return datetime(
      day: seq.at(2), 
      month: seq.at(1), 
      year: seq.at(0), 
      hour: seq.at(3),
      minute: seq.at(4),
      second: seq.at(5)
    )
  }
}

// A function to change the time in a datetime
#let change-time(_datetime, hour, minute, second) = {
  datetime(
    year: int(_datetime.display("[year]")),
    month: int(_datetime.display("[month]")),
    day: int(_datetime.display("[day]")),
    hour: hour,
    minute: minute,
    second: second,
  )
}

// A function to subdivide a segment in a certain number of parts
#let subdivide(start, end, subdivisions) = {
  assert(start < end, message: "starting number should be < than the ending number")
  assert(type(subdivisions) == int and subdivisions > 0, message: "the number of subdivisions should be an integer")

  let _step = (end - start) / subdivisions
  let pos = ()
  for i in range(0, subdivisions + 1, step: 1) {
    pos.push(start + i * _step)
  }

  return pos
}

// A function that returns the number of weeks between an event's week and the starting week
#let relative-week-number(event, starting-date) = {
  return int(event.start.display("[week_number]")) - int(starting-date.display("[week_number]"))
}

// A function that adds defaults to an event
#let set-defaults-event(event) = {
  return (
    repeat-until: none,
    repeat-frequency: none,
    repeat-edit: (:),
    fill: blue.lighten(70%),
    summary: "",
    description: "",
  ) + event
}

// A function that converts the `start` and `end` of an event to datetime elements. 
#let to-datetime-event(event) = {
  let (start, end) = (event.start, event.end).map(it => if type(it) != datetime {
    to-datetime(it)
  } else {
    it
  })
  return event + (
    start: start,
    end: end
  )
}

// A function that resolves the events spanning on multiple days/weeks
#let resolve-event(event, starting-hour, ending-hour) = {
  let result = ()
  let day = duration(days: 1)
  let current-start = event.start
  while current-start < event.end {
    result.push(event + (
      start: if current-start == event.start {
       event.start 
      } else {
        change-time(
          current-start, 
          int(starting-hour.display("[hour]")),
          int(starting-hour.display("[minute]")),
          int(starting-hour.display("[second]")),
        )
      },
      end: if to-datetime(current-start.display("[year]-[month]-[day]")) < to-datetime(event.end.display("[year]-[month]-[day]")) {
        change-time(
          current-start,
          int(ending-hour.display("[hour]")),
          int(ending-hour.display("[minute]")),
          int(ending-hour.display("[second]")),
        )
      } else {
        event.end
      }
    ))
    current-start = current-start + duration(days: 1)
  }
  return result
}

// A function that resolves periodic events
#let repeat-event(event) = {
  assert(
    event.repeat-until == none or type(event.repeat-frequency) == duration, 
    message: "If repeat-until is not none, then repeat-frequency should be a non empty duration."
  )
  let result = (event + 
    (
      __repeated-event-id__: 0
    ) + event.repeat-edit.at("0", default: (:)),
  )
  let current-start = event.start
  let current-end = event.end
  let id = 1

  // Filter not "deleted" repetitions of the event and adds it to the event list
  while event.repeat-until != none and current-start < to-datetime(event.repeat-until) - duration(days: 7) {
    if event.repeat-edit.at(str(id), default: "keep") != "delete" {
      result.push(event + (
        start: current-start + event.repeat-frequency,
        end: current-end + event.repeat-frequency,
        __repeated-event-id__: id
      ) + event.repeat-edit.at(str(id), default: (:))
      )
    }
    current-start = current-start + event.repeat-frequency
    current-end = current-end + event.repeat-frequency
    id = id + 1
  }
  return result
}

#let get-monday(date) = {
  let day-number = date.weekday()
  return date - duration(days: day-number - 1) 
}

// A function that displays an event
#let add-event(event, days-positions, day-start, day-end, day-start-y, day-end-y, days-width, days-y-position, event-fct) = {
  let length-time-ratio = (day-start-y - day-end-y) / (day-end - day-start).hours()
  let start-time = datetime(
    hour: int(event.start.display("[hour]")),
    minute: int(event.start.display("[minute]")),
    second: int(event.start.display("[second]"))
  )
  let y-start = day-start-y + length-time-ratio * (day-start - start-time).hours()
  let event-duration = (event.end - event.start).hours()
  let height = length-time-ratio * event-duration
  for day in range(event.start.weekday(), event.end.weekday() + 1) {
    let x-start = days-positions.at(day - 1)
    let (x-end, y-end) = (x-start + days-width, y-start - height)
    cetz.draw.content(
      (x-start, if y-start > days-y-position {days-y-position} else {y-start}), 
      (x-end, if y-end < 0pt {0} else {y-end}), 
      event-fct(event) 
    )
  }
}
