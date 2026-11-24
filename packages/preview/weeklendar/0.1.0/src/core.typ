#import "@preview/cetz:0.5.2" as cetz
#import "func.typ": *

// A default function formatting the title
#let default-title-fct(monday) = {
  let sunday =  monday + duration(days: 6)
  grid(
    columns: 1fr,
    align: center,
    inset: 15pt,
    [
      #set text(20pt)
       Week of #(monday).display("[day]") to #sunday.display("[day] [month repr:long] [year]")
    ],
  )
}

// A default function formatting the days
#let default-days-fct(monday, day-list, day-number) = {
  grid(
    columns: 1fr,
    align: center,
    [*#day-list.at(day-number)*],
  )
}

// A default function formatting the times
#let default-time-fct(time) = {
  time.display("[hour]:[minute]")
}

// A default function formatting the events
#let default-event-fct(event) = {
  rect(
    width: 100%, 
    height: 100%,
    fill: event.fill, 
    stroke: black + .5pt,
    inset: (x: 5pt, y: 2pt),
  )[
    #grid(
      columns: 1fr, // makes content really centered
      rows: (auto, 1fr, auto), // makes the event's box take all the allocated vertical space
      inset: 5pt,
      align: (x, y) => {
        if y == 0 { top + center }
        else if y == 1 { horizon + center }
        else { bottom + center }
      },
      [ #text(size: 1.1em)[*#event.summary*] ],
      [ #event.description ],
      [ #event.start.display("[hour]:[minute]") - #event.end.display("[hour]:[minute]") ]
    )
  ]
}

// A function that constructs a week's timetable title
#let build-week-title(
  monday,
  title-fct: auto,
  debug: false,
  padding: 0pt,
)= {
  block(
    width: 100%,
    stroke: if debug {red} else {none},
    below: padding,
  )[
    #{
      if title-fct != auto {
        title-fct(monday)
      } 
      else {
        default-title-fct(monday)
      }
    }
  ]
}

// A function that constructs a week's calendar page
#let build-week(
  week-number,
  page,
  starting-date,
  days,
  time,
  title-fct,
  debug: false,
  events: (),
  event-fct: (event) => []
) = {

  // Generate a new page for the week's timetable
  std.page(
    margin: page.margin,
    height: page.height,
    width: page.width,
    {
      context{

        // Measure and build the week's title
        let monday = get-monday(starting-date) + week-number * duration(days: 7)

        let title = build-week-title(
          monday,
          debug: debug,
          padding: page.margin.top,
          title-fct: title-fct
        )
        
        let title-dimensions = measure(width: page.width - (page.margin.left + page.margin.right), title)
          
        title

        // Compute the timetable's height and width
        let timetable = (
          height: page.height - (page.margin.bottom + title-dimensions.height + 2*page.margin.top),
          width: page.width - (page.margin.left + page.margin.right)
        )

        // Measure the time-slice dimensions
        let time-dimensions = measure({
          for i in range(0, time.number) {
            block(
              inset: 0pt,
              stroke: if debug {red} else {none}
            )[
              #align(center)[
                #{
                  if time.fct != auto {
                    (time.fct)(time.start + i*duration(hours: 1))
                  } else {
                    default-time-fct(time.start + i*duration(hours: 1))
                  }
                }
              ]
            ]
          }
        })

        // Compute time-slices starting position and width
        let time = time + (
          x-position: time-dimensions.width + 2*time.pad,
          width: (timetable.width - time-dimensions.width - 3*time.pad) / days.list.len()
        )

        // Measure the days box height
        let days-dimensions = measure(
          for i in range(0, days.list.len()) {
            box(
              width: time.width,
              stroke: if debug {red} else {none}, 
              inset: (x: 15pt, y: 0pt),
            )[
              #{
                if days.fct != auto {
                  (days.fct)(monday, days.list, i)
                } else {
                  default-days-fct(monday, days.list, i)
                }
              }
            ]
          }
        )

        // Compute the days horizontal positions, as well as the days' height and width
        let days = days + (
          positions : 
            subdivide(
            time.x-position,
            timetable.width - time.pad,
            days.list.len()
          ),
          height: days-dimensions.height + days.pad.above + days.pad.below,
        )

        // Compute the times vertical positions
        let hours-positions = subdivide(
          0cm,
          timetable.height - days.height, 
          time.number + 1
        )

        // Build the week's timetable
        cetz.canvas({
          // outer calendar border
          cetz.draw.rect((0,0), (timetable.width, timetable.height))

          // Display time slices
          for i in range(0, time.number) {
            
            let time = time + (
              y-position : hours-positions.at(time.number - i)
            )

            // Generate time slices on the left of the timetable
            cetz.draw.content(
              (time.x-position, time.y-position), 
              anchor: "east",
              [
                #block(
                  width: time.x-position,
                  inset: 0pt,
                  stroke: if debug {red} else {none}
                )[
                  #align(center)[
                    #{
                      if time.fct != auto {
                        (time.fct)(time.start + i*duration(hours: 1))
                      } else {
                        default-time-fct(time.start + i*duration(hours: 1))
                      }
                    }
                  ]
                ]
       
              ]
            )

            // Draw a straight dotted horizontal line for each time slice
            cetz.draw.line(
              (time.x-position, time.y-position), 
              (timetable.width - time.pad, time.y-position), 
              stroke: (dash: "dotted")
            )
          }

          // Display days names
          for i in range(0, days.list.len()) {
            cetz.draw.content(
              (days.positions.at(i) + time.width / 2 , timetable.height - days.pad.above), 
              anchor: "north",
              box(
                width: time.width,
                stroke: if debug {red} else {none}, 
                inset: (x: 15pt, y: 0pt),
              )[
                #{
                  if days.fct != auto {
                    (days.fct)(monday, days.list, i)
                  } else {
                    default-days-fct(monday, days.list, i)
                  }
                }
              ]
            )
          }

          // Display events
          for event in events {
            add-event(
              event,
              days.positions,
              time.start,
              time.start + duration(hours: time.number),
              hours-positions.at(time.number),
              hours-positions.at(0),
              time.width,
              timetable.height - days.height,
              if event-fct != auto {
                event-fct
              }
              else {
                default-event-fct
              },
            )
          }
        })
      }
    }
  )
}

/// This function generates a weekly calendar from a starting date to a end date. 
/// It displays events, which are parametrized by a dictionary.
///
/// -> content
#let weeklendar(

  /// The starting-date defines the first week  to be displayed in the calendar. 
  ///
  /// The date must be given with the following format (based on the ISO 8601 extended format): \
  /// - "dd-mm-yyyy"          // default time: 00:00:01
  /// - "dd-mm-yyyyThh"       // default time: hh:00:00
  /// - "dd-mm-yyyyThh:mm"    // default time: hh:mm:00
  /// - "dd-mm-yyyyThh:mm:ss" 
  ///
  /// Or directly as a datetime element.
  ///
  /// -> str
  starting-date: datetime.today(),

  /// The ending date defines the last  week to be displayed in the calendar. 
  ///
  /// The accepted date format are the same as for the starting-date.
  ///
  /// -> str
  ending-date: datetime.today() + duration(seconds: 1),

  /// The paper's height (not the same as the timetable's height !). -> length
  height: 21cm,

  /// The paper's width (not the same as the timetable's width !). -> length
  width: 29.70cm,

  /// The paper's margins, which define the timetable's height and width, together with the title's dimensions.
  /// 
  /// The top margin is applied above and below the title, so that the total distance between the top of the timetable
  /// and the top of the page is equal to the title's height + 2 \* margin.top. -> dictionary
  margin: (:),

  /// The days names to be displayed on the timetable. -> array
  days: (
    "Monday", 
    "Tuesday", 
    "Wednesday", 
    "Thursday", 
    "Friday", 
    "Saturday", 
    "Sunday"
  ),

  /// A function to customize the displayed days appearance. It takes the days' name list,
  /// the first week's monday date and the current day's number as arguments. -> auto | function
  days-fct: auto,

  /// The padding below and above the displayed days. -> dictionary
  days-pad : (:),

  /// The first timeline to appear on the timetable. -> datetime
  time-start: datetime(hour: 8, minute: 0, second: 0),

  /// The step between two successives displayed timelines. -> duration
  time-step: duration(hours: 1),

  /// The number of timelines.
  ///
  /// The spacing between consecutives timelines depends on this number. -> int
  time-number: 11,

  /// The padding on the left/right around the timeline's time (added to the time's width) and at the end of the timeline's line. -> length
  time-pad: 10pt,
  //
  /// A custom function for the formatting of the time slices.
  ///
  /// -> auto | function
  time-fct: auto,
  
  /// A custom function for generating weekly titles. It takes the first week's monday as an argument and builds a custom title depending on monday's date.
  ///
  /// -> auto | function
  title-fct: auto,

  /// A custom function for the generic content of an event. It takes an event  as an argument.
  /// It is recommended to build a content that expands vertically (for example by using `#v(1fr)`), 
  /// so that the events are displayed on the entire associated timeline.
  ///
  /// -> auto | function
  event-fct: auto,

  /// A debugging option to show some of the displayed element's boundaries. -> boolean
  debug: false,

  /// Events to be displayed on the calendar, passed as a positional arguments. 
  ///
  /// Each event is described by a dictionary with two mandatory arguments: `start` and `end`, 
  /// which are to be given in the ISO 8601 extended format (see `starting-date` above) or directly
  /// as a datetime element. \
  /// If you want to make a periodic event, then you can use `repeat-until` and `repeat-frequency`.
  /// You can add extra named arguments, that can be accessed by your custom `event-fct`.
  ///
  /// -> array
  ..events,

) = {

  // Check for unknown named arguments
  assert(
    events.named().len() == 0,
    message: "Unrecognized named argument provided.."
  )

  // Resolve starting and ending dates
  let (starting-date, ending-date) = (starting-date, ending-date).map(it => to-datetime(it))

  // Resolve padding
  let days-pad = (
    above: 0.5cm, 
    below: 0.5cm
  ) + days-pad

  // Resolve margins
  let margin = (
    left: 1.3cm,
    right: 1.3cm,
    top: 0.3cm,
    bottom: 1.3cm,
  ) + margin

  // Regroup page arguments
  let page = (
    margin: margin,
    height: height,
    width: width
  )

  // Regroup time arguments
  let time = (
    number: time-number,
    pad: time-pad,
    step: time-step,
    start: time-start,
    fct: time-fct,
  )

  // Regroup days arguments
  let days = (
    list: days,
    pad: days-pad,
    fct: days-fct,
  )

  // Resolve periodic events
  let repeated-events = ()
  for event in events.pos().map(it => to-datetime-event(set-defaults-event(it))) {
    repeated-events = repeated-events + repeat-event(event)
  }

  // Resolve events spanning on multiple days/weeks
  let resolved-events = ()
  for event in repeated-events.map(it => to-datetime-event(it)) {
    resolved-events = resolved-events + resolve-event(
      event, 
      time.start - duration(
        hours: 1
      ), 
      time.start + duration(
        hours: time.number
      )
    )
  }

  // Loop over all weeks from starting-date to ending-date
  for week-number in range(0, int(ending-date.display("[week_number]")) - int(starting-date.display("[week_number]")) + 1) {

    // Select the current week's events
    let current-events = ()
    for event in resolved-events {
      if relative-week-number(event, starting-date) == week-number {
        current-events.push(event)
      }
    }

    // Generate a new page for the week's timetable
    build-week(
      week-number,
      page,
      starting-date,
      days,
      time,
      title-fct,
      debug: debug,
      events: current-events,
      event-fct: event-fct
    )
  }
}          
