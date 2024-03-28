#let experiencelist = state("experiencelist", ())

#let experience(
  organization,
  role: none,
  start: none,
  stop: none,

  notes
) = {
  let content = [
    #grid(
      columns: (65%, 33%, 1fr),
      heading(level: 2, organization),
      align(right)[
        #set text(rgb(130,130,130))
        #start #if stop != none { " — " + stop}
      ]
    )
    #if role != none {
      set text(rgb(100,100,100))
      if type(role) == "string" {
        v(-0.75em)
        heading(level: 3, text(style: "italic", role))
      } else {
        v(-0.75em)
        heading(level: 3, text(style: "italic", role.join(", ")))
      }
    }
    #notes
  ]

  experiencelist.update(current => current + (content,))
}
#let experiences(header: "Professional Experience", color: black, size: 9pt) = {
  locate(
    loc => {
      let experiencelist = experiencelist.final(loc)
      if experiencelist.len() > 0 {
        heading(level: 1, text(header))
        line(length: 97%)
        set text(color, size: size)
        experiencelist.join()
      }
    }
  )
}