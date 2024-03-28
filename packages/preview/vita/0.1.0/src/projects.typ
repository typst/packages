#let projectslist = state("projectslist", ())

#let project(
  name, 
  url: none,
  description: none,
) = {
  let banner = if url == none {
    name
  } else {
    link(url, name)
  }

  let title = [
    #heading(level: 2, banner)
    #text(style: "italic", description)
  ]

  projectslist.update(current => current + (title,))
}

#let projects(header: "Personal Projects", color: white, size: 9pt) = {
  locate(
    loc => {
      let projectslist = projectslist.final(loc)
      if projectslist.len() > 0 {
        heading(level:1, text(color, header))
        set text(color, size: size)
        projectslist.join()
      }
    }
  )
}