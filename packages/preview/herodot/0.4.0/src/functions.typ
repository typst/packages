
#import "primitives.typ"

#let eventlocation(
  start-year: 1,
  end-year: 3,
  
  event: (title: "y2k", year: 20, month: 2, day: 30)
  ) = {
    let yearfrac = event.year

    // if month is set add its fraction of
    // a year to the total yearfrac value
    if event.month != 0 or event.month != none {
      if event.month <= 12 and event.month > 0 {
      yearfrac += event.month / 12
    }
   }

    // if the day is set add its fraction of
    // a month to a year to the total yearfrac value
    if event.day != 0 or event.day != none {
      if event.day < 31 and event.day > 0 {
         yearfrac += (event.day / 31 ) / 12
      }
    }


    let loc
    if start-year > 0 {
      loc = (yearfrac - start-year)/ (end-year - start-year)
    }

    if start-year ==  0 {
      loc = yearfrac / end-year 
    }

    if start-year < 0 {
      loc = (( yearfrac + -(start-year) )/ (end-year + -(start-year)))
    }
    
    return loc 
}


#let eventspanlocation(
  start-year: 1,
  end-year: 3,
  eventyear: 2,
) = {
  if start-year > 0 {

    // if the start year is positive
    // it is subtracted so that it
    // is offset back to the origin
    // point (0,0) used by the graphing
    // system
    let x-pos = ((eventyear - start-year ) / (end-year - start-year ))
    return x-pos
  }

  if start-year == 0 {
    if end-year >= eventyear {
      // set the location as an
      // absolute x value from origin (0,0)
      // by calculating the percentage
      // the eventyear is from end

      let x-pos = (eventyear / end-year)   
      return x-pos
    }
  }
  if start-year < 0 {

    // off sets the event types by start year
    // as positive,
    // so that the graphing mechanism can
    // use the orgin point (0,0) in the canvas
    // Said differently, so that the startyear
    // represents the origin point for the
    // rest of the timeline.
    let x-pos = (( eventyear + -(start-year) )/ (end-year + -(start-year)))
    return x-pos
  }
}


#let month-conversion(
  nummerical: 1,
  locale: (
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ) 
) = {
    if nummerical - 1 != -1 {
      return locale.at(nummerical - 1)
    }
}
