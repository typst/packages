#let degreeslist = state("degreeslist", ())

#let duration(start, stop) = {
  text(rgb(130,130,130))[
    #start #if (start != none and stop != none) { " — " } #stop
  ]
}

#let degree(
  title, field,
  school: none,
  start: none,
  stop: none,
  notes
) = {
  
  let content = [
    #grid(
      columns: (70%, 28%, 1fr),
      heading(level: 2, (title, field).join(" ")),
      align(right)[
        #duration(start, stop)
      ]
    )
    #if school != none {
      set text(rgb(100,100,100))
      v(-0.75em)
      heading(level: 3, school)
    }
    #notes
  ]

  degreeslist.update(current => current + (content,))
}

#let degrees(header: "Education", size: 11pt) = {
  locate(
    loc => {
      let content = degreeslist.final(loc)
      if content.len() > 0 {
        heading(level: 1, header)
        line(length: 97%)
        content.join()
      }
    }
  )
}

