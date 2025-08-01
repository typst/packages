#import "../types.typ": *
#import "../settings.typ": *
#import "../utils.typ": *


/// Display a user's content and any events that they have specified for a week.
#let content_and_events = e.element.declare(
  "content_and_events",
  prefix: PREFIX,
  doc: "A block that includes content and events for a particular week",
  display: it => e.get(get => {
    let opts = get(settings)

    // Split events up by their type
    let events = (holiday: (), homework: (), test: (), other: ())
    for event in it.events {
      let key = event.at("type", default: "other")
      if ("holiday", "homework", "test", "other").contains(key) == false {
        // If the type is not one of the known types, we just put it in "other"
        key = "other"
      }
      if events.at(key, default: none) == none {
        events.insert(key, ())
      }
      events.at(key).push(event)
    }

    // Display holidays first
    events
      .at("holiday")
      .map(h => {
        text(weight: "bold", [#h.name #format_event_date(h) (no classes)\ ])
      })
      .join([])

    // Regular content comes next
    it.content

    parbreak()
    // Then midterms and homeworks
    events
      .at("test")
      .map(e => text(weight: "bold", fill: opts.colors.primary, [
        #e.name #format_event_date(e)\
      ]))
      .join([])
    events
      .at("homework")
      .map(e => text(fill: opts.colors.secondary, [
        #e.name #format_event_date(e)\
      ]))
      .join([])
    events
      .at("other")
      .map(e => text(fill: opts.colors.tertiary, [
        #e.name #format_event_date(e)\
      ]))
      .join([])
  }),
  fields: (
    e.field(
      "content",
      content,
      doc: "Content for the week, such as textbook sections to read or other items that aren't already in `settings.events`",
    ),
    e.field(
      "events",
      e.types.array(event),
      doc: "Events for the week, such as homeworks or midterms. These will be displayed in the timetable.",
    ),
  ),
)


/// Display a weekly timetable for the course.
#let timetable = e.element.declare(
  "timetable",
  prefix: PREFIX,
  doc: "A weekly timetable for the course, including homeworks, midterms, and holidays.",
  display: it => e.get(get => {
    let opts = get(settings)
    let sans = opts.font_sans.font
    // Typst uses `1` to represent Monday
    let week_start_day = (
      "monday": 1,
      "tuesday": 2,
      "wednesday": 3,
      "thursday": 4,
      "friday": 5,
      "saturday": 6,
      "sunday": 7,
    ).at(it.week_start_day, default: 1)
    // Create an array with one day for every day of the semester.
    let all_semester_days = range(
      int((opts.term_end_date - opts.term_start_date).days()) + 1,
    ).map(i => {
      opts.term_start_date + duration(days: i)
    })

    // Find the start of the first full week. Since the week may start on a Monday, but the semester may
    // start on a Tuesday or Wednesday, the first full week may not be at the start of the semester.

    let first_full_week_start_idx = all_semester_days.position(d => {
      // Find the first day that is a week_start_day
      d.weekday() == week_start_day
    })

    let first_partial_week = if first_full_week_start_idx == 0 {
      ()
    } else {
      (all_semester_days.slice(0, first_full_week_start_idx),)
    }
    let all_weeks = (
      first_partial_week
        + all_semester_days
          .slice(
            first_full_week_start_idx,
          )
          .chunks(7)
    )
    let week_boundaries = all_weeks.map(week => (
      start: week.at(0),
      end: week.at(-1),
    ))

    let all_events = (
      opts.events
        + opts.holidays.map(h => {
          // Make sure that every holiday has a type "holiday"
          if h.at("type", default: none) == none {
            h.insert("type", "holiday")
          }
          h
        })
    )

    let weekly_content = week_boundaries
      .enumerate()
      .map(((i, week)) => {
        let events_in_range = all_events.filter(e => {
          // Check if the event is in the range of the week
          date_in_range(e.date, week.start, week.end) == "during"
        })
        (
          // Display number for the week
          week_num: i + 1,
          bounds: week,
          content: it.weekly_data.at(i, default: none),
          events: events_in_range,
        )
      })

    // If there are any events that take place before classes, we add a cell
    // and display them.
    let before_classes_events = all_events.filter(e => {
      date_in_range(e.date, opts.term_start_date, opts.term_start_date) == "before"
    })
    let before_classes = if before_classes_events.len() > 0 {
      (
        sans(text(size: 1.2em, baseline: -.3em, [Before Classes])),
        content_and_events(events: before_classes_events),
      )
    } else { () }

    let after_classes_events = all_events.filter(e => {
      date_in_range(e.date, opts.term_end_date, opts.term_end_date) == "after"
    })
    let after_classes = if after_classes_events.len() > 0 {
      (
        sans(text(size: 1.2em, [After Classes])),
        content_and_events(events: after_classes_events),
      )
    } else { () }


    set list(marker: none, indent: 0pt)
    set par(justify: false)

    show: pad.with(left: -opts.gutter_width)
    table(
      stroke: 0.25pt + gray,
      align: (right, left),
      columns: (opts.gutter_width, 1fr),
      row-gutter: 0.3em,
      ..before_classes,
      ..weekly_content
        .map(data => {
          (
            {
              align(horizon, stack(
                spacing: 0.3em,
                sans(text(size: 1.2em, [Week #data.week_num])),
                text(fill: gray.darken(20%), format_week_range(
                  start: data.bounds.start,
                  end: data.bounds.end,
                )),
              ))
            },
            {
              content_and_events(
                content: data.content,
                events: data.events,
              )
            },
          )
        })
        .join(),
      ..after_classes
    )
  }),
  fields: (
    e.field(
      "weekly_data",
      e.types.array(content),
      doc: "Additional data to be displayed each week. For example, what textbook sections to read or other items that aren't already in `settings.events`.",
    ),
    e.field(
      "week_start_day",
      e.types.union("monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"),
      doc: "The day of the week that the week starts on. Weeks will be counted out as the start day + 7",
      default: "monday",
    ),
  ),
)


/// An example
#{
  show: e.set_(
    settings,
    term_start_date: datetime(year: 2025, month: 1, day: 1),
    term_end_date: datetime(year: 2025, month: 2, day: 28),
    holidays: (
      (
        name: [Special Day],
        date: datetime(year: 2025, month: 2, day: 15),
        key: "special-day",
      ),
    ),
    events: (
      (
        name: [Midterm 1],
        date: datetime(
          year: 2025,
          month: 1,
          day: 7,
          hour: 17,
          minute: 10,
          second: 0,
        ),
        type: "test",
        key: "midterm-1",
      ),
      (
        name: [Homework 1],
        date: datetime(year: 2025, month: 1, day: 22),
        type: "homework",
        key: "hw-1",
      ),
      (
        name: [Homework 2],
        date: datetime(year: 2025, month: 1, day: 29),
        type: "homework",
        key: "hw-2",
      ),
    ),
  )

  timetable(week_start_day: "wednesday", weekly_data: (
    [hi there],
    [This is the first week of the course. We will cover the basics of Typst],
    [This is the first week of the course. We will cover the basics of Typst],
    [This is the first week of the course. We will cover the basics of Typst],
    [This is the first week of the course. We will cover the basics of Typst],
  ))
}
