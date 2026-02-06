#import "bib-util.typ": fd, is-integer

#let month-names = (
    "january": 1,
    "february": 2,
    "march": 3,
    "april": 4,
    "may": 5,
    "june": 6,
    "july": 7,
    "august": 8,
    "september": 9,
    "october": 10,
    "november": 11,
    "december": 12,
    "jan": 1,
    "feb": 2,
    "mar": 3,
    "apr": 4,
    "jun": 6,
    "jul": 7,
    "aug": 8,
    "sep": 9,
    "oct": 10,
    "nov": 11,
    "dec": 12
  )

// Returns an empty dictionary if the date field is unparseable.
// (Returning "none" would cause trouble in printfield, which returns none
// if the field value is none.)
#let parse-date(reference, date-field, fallback-year-field: none, fallback-month-field: none) = {
  let options = (:) // these are print-reference options, and we are outside of print-reference
  let date-str = fd(reference, date-field, options)
  
  // I would like to return dates as Typst datetime objects, but they require
  // valid dates in which year, month, day are all specified; and Biblatex doesn't require this.

  // TODO: permit date ranges
  // TODO: permit approximate dates
  // TODO: permit negative years

  if date-str != none {
    date-str = date-str.trim()

    if date-str.contains("-") {
      // parse as ISO8601-2 Extended Format, see Biblatex manual, §2.3.8
      let parts = date-str.split("-")

      if parts.len() >= 3 {
        // Format: year-month-date
        if is-integer(parts.at(0)) and is-integer(parts.at(1)) and is-integer(parts.at(2)) {
          ("year": int(parts.at(0)), "month": int(parts.at(1)), "day": int(parts.at(2)))
        } else {
          // unparseable date
          (:)
        }
      } else if parts.len() == 2 {
        // Format: year-month
         if is-integer(parts.at(0)) and is-integer(parts.at(1)) {          
          ("year": int(parts.at(0)), "month": int(parts.at(1)))
         } else {
          (:)
         }
      }
    } else if is-integer(date-str) {
      // Format: year
      ("year": int(date-str))
    } else {
      // unparsable date -> print as "n.d."
      (:)
    }
  } else if fallback-year-field != none {
    // no date field, fall back to year field
    let year-str = fd(reference, fallback-year-field, options)
    if year-str != none and is-integer(year-str) {
      let date-dict = ("year": int(year-str.trim()))

      if fallback-month-field != none {
        let month-str = fd(reference, fallback-month-field, options)
        if month-str != none {
          month-str = month-str.trim()

          if is-integer(month-str) {
            // integer months: insert directly
            date-dict.insert("month", int(month-str.trim()))
          } else {
            // months that are defined in the month-names dict: resolve to int
            // all other months: retain verbatim (thus "month" field can be type str)
            let lower-month-str = lower(month-str)
            let month-num = month-names.at(lower-month-str, default: month-str)
            date-dict.insert("month", month-num)
          }
        }
      }

      date-dict
    } else {
      // unparseable year -> print as "n.d."
      (:)
    }
  } else {
    // no date or year field specified -> print as "n.d."
    (:)
  }
}

// Checks whether the year is defined in this reference dict.
#let is-year-defined(reference) = {
  reference.fields.parsed-date != none and "year" in reference.fields.parsed-date
}