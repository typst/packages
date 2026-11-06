// This is the common way Resumania handles timeframes throughout resumes.
//
// Here is a usage example:
// ```typst
// #show-timeframe(
//   (
//     start: datetime(year: 2042, month: 01, day: 01),
//     end: datetime(year: 2088, month: 08, day: 08),
//   ),
//   format: "[year]-[month]-[day]",
// )
// ```
// -----------------------------------------------------------------------------

// The default format to use when displaying `datetime` objects in the resume.
// This can be altered if the whole resume's date format style is desired to be
// different than the one provided here, but for one-shot differences most
// functions should allow a dedicated argument for changing the way `datetime`s
// are displayed for that one instance.
#let default-datetime-format = state(
  "resumania:timeframe:default-datetime-format",
  "[month repr:short] [year]",
)

// Return content of the provided datetime.
//
// = Parameters
// - `datetime`: `datetime`
//     The object to format.
#let show-datetime(datetime) = {
  return context datetime.display(default-datetime-format.get())
}


// Convert a timeframe that has start and end fields into content.
//
// The timeframe will be formatted with an en-dash between the start and end. If
// either of them is `none`, the en-dash will still be inserted, and if both are
// `none` then `none` will be returned (note this is different from empty
// content).
//
// = Parameters
// - `start`: `str` | `content` | `datetime` | `none`
//     The start of the timeframe.
// - `end`: `str` | `content` | `datetime` | `none`
//     The end of the timeframe.
#let show-timeframe-with-endpoints(start, end) = {
  let result = none

  // Format `datetime` fields ahead of time so they can be treated like other
  // content down the line.
  if type(start) == datetime {
    start = show-datetime(start)
  }
  if type(end) == datetime {
    end = show-datetime(end)
  }

  result += start
  if start != none or end != none {
    result += [--]
  }
  result += end

  return result
}


// Convert a timeframe between two dates into content.
//
// = Parameters
// - `timeframe`: `datetime` | `dictionary` | `array` | `any`
//     The timeframe to convert into content. See notes below for more how the
//     parameter can be formatted and how it's handled.
//
// = Notes
// - The two forms a timeframe can take:
//     1. A non-container type, which may be a `datetime` or any other type that
//        isn't a container (e.g. an array or dictionary). If the timeframe is a
//        `datetime`, it will be converted using the `display` method and the
//        provided format (or the default format). Any other type will be simply
//        returned as `[#timeframe]`, with the exception that `none` will be
//        returned as `none`.
//     2. A container type, which is either a dictionary with `"start"` and
//        `"end"` keys, or an array of two elements where the order of elements
//        is `(<start>, <end>)`. The elements must be any valid non-container
//        type for the `timeframe` parameter as described above, where each
//        element will be handled as described, with the addition that an
//        en-dash will be inserted in the middle. The en-dash will always be
//        inserted *unless* both endpoints are `none`, in which case just `none`
//        is returned.
#let show-timeframe(timeframe) = {
  let result = none

  if type(timeframe) in (dictionary, array) {
    let (start, end) = timeframe
    result += show-timeframe-with-endpoints(start, end)
  } else if type(timeframe) == datetime {
    result += show-datetime(timeframe)
  } else {
    result += [#timeframe]
  }

  return result
}
