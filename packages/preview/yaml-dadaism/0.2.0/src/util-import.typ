#import "util-event.typ": *
#import "util-misc.typ": *

// test if this is a duration or not
// to decide if colour assigned
#let test-duration(type, start, end) = {
  let bool = type == "duration"
  bool or start != end
}

// standardise events
// add y value
// and colour if duration
#let import-events(el) = {

  let raw-events = el.pairs().filter(it => not test-duration(it.at(1).type, it.at(1).dtstart, it.at(1).dtend)).sorted(key: it => (it.at(1).dtstart,))
  
  let raw-durations = el.pairs().filter(it => test-duration(it.at(1).type, it.at(1).dtstart, it.at(1).dtend)).sorted(key: it => (it.at(1).dtstart,))
  
  // durations get coloured incrementally from palette
  let durations = raw-durations.enumerate().map(it => codify-event(it.at(1), it.at(0), palette-paired))

  // events don't get coloured
  let events = raw-events.enumerate().map(it => codify-event(it.at(1), 0, (black,)))

  // combined events and durations into one list, durations first
  let combined = (..durations, ..events)
  
  combined
  
}

// duplicate at month boundaries if any
// and split by month
#let split-by-month(x) = { 
  
  let all = x.map(it => split-event(it)).flatten()

   // split by month
   let combined-by-month = range(1,13).map(month => all.filter(it => {it.dtstart.month() == month}))

   combined-by-month

}

