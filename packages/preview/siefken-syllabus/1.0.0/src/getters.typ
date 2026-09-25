#import "types.typ": *
#import "constants.typ": *
#import "settings.typ": *
#import "utils.typ": *

/// Get a value that is stored in the syllabus settings.
#let get_setting(name, map: none) = e.get(get => {
  let opts = get(settings)
  let val = opts.at(name, default: NOT_FOUND_SENTINEL)
  if val == NOT_FOUND_SENTINEL {
    return text(fill: red, [
      (WARNING: Setting  "#text(fill: gray, [#name])" not found. Existing settings are:
      #(opts.keys().map(k => ["#text(fill: gray, raw(k))"])).join(", "))
    ])
  }
  if type(map) == function {
    map(val)
  } else {
    val
  }
})

/// Get a formatted version of the date of an event. The events are defined in the `settings`
/// object.
///
/// -> str | content
#let get_event_time(
  /// The name of the event. This will correspond to the string you set as the `key` in the `settings.events` or `settings.holidays`.
  /// -> str
  event_name,
) = {
  // We search for events as keys in the settings,
  // then in `settings.events`, then in `settings.holidays`.
  e.get(get => {
    let opts = get(settings)
    let event = opts.at(event_name, default: NOT_FOUND_SENTINEL)
    if event != NOT_FOUND_SENTINEL and event != none {
      return format_date(event)
    }
    // Not found in the settings, so we look in the events and holidays
    let all_events = opts.events + opts.holidays
    // get a list of all searchable events. This includes the events as keys of `opts`
    let all_event_names = (
      opts.pairs().filter(((k, v)) => type(v) == datetime).map(((k, v)) => k)
        + all_events.filter(e => e.key != none).map(e => e.key)
    )

    let event = all_events.find(e => e.key == event_name)
    if event == none {
      return text(
        fill: red,
        [
          WARNING: Event "#text(fill: gray, event_name)" not found. Valid event names are given as `key`s
          in the `settings` object. Currently specified events are: #(
            all_event_names.map(e => ["#text(fill: gray, raw(e))"]).join(", ")
          )
        ],
      )
    }


    format_event_date(event)
  })
}
