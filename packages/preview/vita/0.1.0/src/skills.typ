#let skillslist = state("skillslist", ())

#let skill(
  name, notes,
) = {
  let title = [
    #heading(level: 2, name)
    #notes
  ]

  skillslist.update(current => current + (title,))
}
#let skills(header: "Technical Skills") = {
  locate(
    loc => {
      let skillslist = skillslist.final(loc)
      if skillslist.len() > 0 {
        heading(level: 1, header)
        line(length: 97%)
        skillslist.join()
      }
    }
  )

}