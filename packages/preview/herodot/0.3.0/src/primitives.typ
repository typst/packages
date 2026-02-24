
// event constructor function that returns a dictionary
// with the values named
#let event(
    title: "y2k",
    year: 2000,
    month: 0,
    day: 0,
  ) = {

  let a = (
    title: title,
    year: year,
    month: month,
    day: day
  )

  return a
}

#let eventspan(
    title: "y2k",
    color: red,
    // fill: red,
    start-point: 2000,
    end-point: 2001,
    timeline-offset: 0.5
  ) = {
    let b = (
      title : title,
      color : color,
      start-point : start-point,
      end-point : end-point,
      timeline-offset : timeline-offset,
    )
    return b
  }
