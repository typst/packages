// SPDX-FileCopyrightText: Copyright (C) 2025 Andrew Voynov
//
// SPDX-License-Identifier: AGPL-3.0-only

#let colspan(n, ..args) = table.cell(colspan: n, ..args)
#let rowspan(n, ..args) = table.cell(rowspan: n, ..args)
#let sideways(body) = rotate(-90deg, reflow: true, body)

#let class-formatter(class) = {
  if class.len() == 1 { (rowspan(2, ..class),) } else { class }
}

#let time-data = (
  [I\ 8:30--10:05],
  [II\ 10:20--11:55],
  [III\ 12:10--13:45],
  [IV\ 14:15--15:50],
  [V\ 16:05--17:40],
  [VI\ 17:50--19:25],
  [VII\ 19:35--21:10],
)

#let weekday(time-data: time-data, name, ..classes) = (
  rowspan(classes.pos().len() * 2, sideways(name)),
  ..classes
    .pos()
    .enumerate()
    .map(((i, class)) => (
      rowspan(2, time-data.at(i)),
      class-formatter(class),
    )),
)


#let format-weekdays(zebra-fill: black, zebra-odd: false, ..weekdays) = {
  for (i, weekday) in weekdays.pos().enumerate() {
    let fill = (fill: (auto, zebra-fill).at(calc.rem(i + int(zebra-odd), 2)))
    let (name, ..classes) = weekday
    let total-height = measure(name).height + 5pt * 2
    let class-height = total-height / classes.len()
    (name,)
    classes.map(class => {
      let (name, entries) = class
      (name,)
      let entry-height = class-height / entries.len() - 0.08em
      entries.map(entry => {
        let cell = table.cell
        let body
        if type(entry) == content and entry.func() == table.cell {
          let fields = entry.fields()
          body = fields.remove("body")
          cell = cell.with(..fields)
        } else {
          body = entry
        }
        cell(..fill, block(height: entry-height, body))
      })
    })
  }
}

/// Template function used together with `timetable`.
///
/// - group (str, content): timetable of this group/class
/// - time-data (array): array of timings for each class to show
/// - text-fill (color): `text.fill`
/// - table-fill (color): `table.fill`
/// - table-zebra-fill (color): alternating `table.fill` for readability
/// - table-zebra-odd (bool): whether to use zebra fill for odd weekdays
/// - table-stroke (stroke): `table.stroke`
/// - title (auto, none, str, content): document title
/// - extra-styling (bool): whether to apply extra styling that can't be
///     undone, because of show rule wrapper
/// - sans-font (str): which sans-serif font to use as a part of `extra-styling`
/// - doc (content): document to apply the template to
#let template(
  group: "group name",
  time-data: time-data,
  text-fill: white,
  table-fill: rgb("333"),
  table-zebra-fill: black,
  table-zebra-odd: false,
  table-stroke: 2pt + rgb("b2b2b2"),
  title: auto,
  extra-styling: true,
  sans-font: "Liberation Sans",
  doc,
) = {
  set document(title: "Timetable for " + group) if title == auto
  set document(title: title) if title not in (auto, none)
  set page(width: auto, height: auto, margin: table-stroke.thickness / 2)
  set text(text-fill)
  set table(fill: table-fill, stroke: table-stroke, inset: 6pt)

  show table.cell: it => {
    if not extra-styling { return it }
    set text(font: sans-font) if it.x == 0 or it.y == 0
    set text(weight: "bold") if it.x in range(2) or it.y == 0
    set text(10pt) if it.x == 1
    set text(15pt) if it.x == 0 or it.y == 0
    it
  }

  state("timetable-group").update(group)
  state("timetable-zebra-fill").update(table-zebra-fill)
  state("timetable-zebra-odd").update(table-zebra-odd)
  state("timetable-time-data").update(time-data)

  doc
}

#let unnamed-parameter(name, provided-value) = {
  if provided-value == auto {
    state("timetable-" + name).get()
  } else {
    provided-value
  }
}

#let parameter(name, provided-value) = {
  if provided-value == auto {
    let data = state("timetable-" + name).get()
    if data != none { ((name): data) } else { (:) }
  } else {
    ((name): provided-value)
  }
}

/// A table wrapper for creating class schedule.
///
/// - group (auto, str, content): timetable of this group/class.
///     `auto` uses data from used template, otherwise default is used.
/// - zebra-fill (auto, color): alternating `table.fill` for readability.
///     `auto` uses data from used template, otherwise default is used.
/// - zebra-odd (auto, bool): whether to use zebra fill for odd weekdays.
///     `auto` uses data from used template, otherwise default is used.
/// - time-data (auto, array): array of timings for each class to show.
///     `auto` uses data from used template, otherwise default is used.
/// - data (dictionary): dictionary of weekday as keys and array of classes as
///     values. Each class can be an array of 1 value (class on numerator and
///     denominator week) or 2 values (first class on numerator week, second
///     class on denominator week). Each value can one of: `none`, `str`,
///     `content`.
#let timetable(
  group: auto,
  time-data: auto,
  zebra-fill: auto,
  zebra-odd: auto,
  data: (:),
) = context {
  let group = unnamed-parameter("group", group)
  let zebra-fill = (zebra-fill: unnamed-parameter("zebra-fill", zebra-fill))
  let zebra-odd = parameter("zebra-odd", zebra-odd)
  let time-data = parameter("time-data", time-data)

  table(
    columns: 3,
    align: (x, y) => {
      if y == 0 { center } else { (center, center, right).at(x) } + horizon
    },
    ..if group == none { () } else { (table.header(colspan(2)[], group),) },
    ..format-weekdays(..zebra-fill, ..zebra-odd, ..data
      .pairs()
      .map(((weekday-name, classes)) => weekday(
        ..time-data,
        weekday-name,
        ..classes,
      ))).flatten(),
  )
}

/// SPDX-License-Identifier: MIT-0
///
/// Format entry (class info) in the timetable.
///
/// - class (dictionary): source class data that contains everything necessary
///     for formatting an entry
/// -> content
#let format-entry(class) = {
  let class-type = (
    "lab": "лаб.",
    "seminar": "упр.",
    "lecture": "лекц.",
  )
  let parts = ()
  parts.push(class.discipline.fullName)
  let key = class.discipline.at("actType", default: none)
  if key != none {
    parts.push(class-type.at(key, default: none))
  }
  if class.audiences.len() > 0 {
    let name = class.audiences.first().name
    let match = name.match(regex("(\\d)\\.(\\d)(\\d{2})"))
    if match == none { name } else {
      let (a, b, c) = match.captures
      parts.push("УАК" + a + " " + b + "." + c + "")
    }
  }
  if class.teachers.len() > 0 {
    parts.push({
      class.teachers.first().lastName
      " "
      class.teachers.first().firstName.first()
      ". "
      class.teachers.first().middleName.first()
      "."
    })
  }
  parts.join(" ")
}

/// SPDX-License-Identifier: MIT-0
///
/// Transform source dictionary to `arguments` that can be passed to
/// `timetable`. To modify, simply create your own function from scratch, or
/// copy this one to your project and edit accordingly.
///
/// - source (dictionary): source dictionary. Can be obtained through data
///     loading functions.
/// - format-entry (function): used to format single entry from data. This
///     splits the schedule generation logic from class info generation logic.
/// -> arguments
#let get-timetable-info(source, format-entry: format-entry) = {
  let data = (:)
  let response = source
  let group = response.data.title
  let schedule = response.data.schedule
  for class in schedule {
    let weekday-name = (
      "Понедельник",
      "Вторник",
      "Среда",
      "Четверг",
      "Пятница",
      "Суббота",
    )
    let formatted-entry = format-entry(class)
    let key = weekday-name.at(class.day - 1)
    let value = data.at(key, default: ())
    while class.time > value.len() + 1 {
      value.push((none, none))
    }
    if class.time > value.len() {
      value.push((none, none))
    }
    if class.week == "all" {
      value.at(class.time - 1) = (formatted-entry,)
    } else if class.week == "ch" {
      value.at(class.time - 1).first() = formatted-entry
    } else if class.week == "zn" {
      value.at(class.time - 1).last() = formatted-entry
    } else { panic("unreachable") }
    data.insert(key, value)
  }
  let data = {
    data
      .pairs()
      .map(((key, value)) => (
        key,
        value.map(class => if class == (none, none) { (none,) } else { class }),
      ))
      .to-dict()
  }
  arguments(group: group, data: data)
}
