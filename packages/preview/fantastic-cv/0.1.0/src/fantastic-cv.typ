
#let render_space_between_highlight = -0.5em
#let render_space_between_entry = -0.5em
#let render_space_between_sections = -0.5em

#let config(
  font: "New Computer Modern",
  font_size: 10pt,
  page_paper: "a4",
  margin: (
    top: 0.5in,
    bottom: 0.5in,
    left: 0.5in,
    right: 0.5in,
  ),
  accent_color: "#26428b",
  space_between_sections: -0.5em,
  space_between_highlight: -0.5em,
  body
) = {
  let font_size_title = font_size * 1.5
  let font_size_section = font_size * 1.3
  let font_size_entry = font_size * 1.1

  set text(
    font: font,
    size: font_size,
    lang: "en",
    ligatures: false,
  )

  set page(
    margin: margin,
    paper: page_paper,
  )

  set par(justify: true)

  show link: underline

  show heading: set text(fill: rgb(accent_color))

  show link: set text(fill: rgb(accent_color))

  // name heading
  show heading.where(level: 1): it => [#text(font_size_title, weight: "extrabold")[#it]]

  // section heading
  show heading.where(level: 2): it => [#text(font_size_section, weight: "bold")[#it]]

  // entry heading
  show heading.where(level: 3): it => [#text(size: font_size_entry, weight: "semibold")[#it]]

  body
}


#let _format_dates(
  start-date: "",
  end-date: "",
) = {
  start-date + " " + $dash.em$ + " " + end-date
}


#let _entry_heading(
  main: "", // top left
  dates: "", // top right
  description: "", // bottom left
  bottom_right: "", // bottom right
) = {
  [
    === #main #h(1fr) #dates \
    #description #h(1fr) #bottom_right
  ]
}

#let _section(title, body) = {
 [ == #smallcaps(title)]
 v(-0.5em)
 line(length: 100%, stroke: stroke(thickness: 0.4pt))
  v(-0.5em)
  body
  v(render_space_between_sections)
}


#let section_basic_info(
  name: "",
  location: "",
  phone: "",
  email: "",
  url: "",
  profiles: [],
) = {
  set document(
    author: name,
    title: name,
    description: "Resume of " + name,
    keywords: "resume, cv, curriculum vitae",
  )

  align(
    left,
    [= #name #h(1fr) #location],
  )


  pad(
    top: 0.25em,
    [
      #{
        let items = (
          phone,
          link(email)[#email],
          link(url)[#url],
        )
        items.filter(x => x != none).join("  |  ")
        "  |  "
        profiles
          .map(profile => {
            profile.network + ": "
            let url_concat = profile.url + "/" + profile.username
            link(url_concat)[#url_concat]
          })
          .join("  |  ")
      }
    ],
  )
}

#let section_education(_educations) = {
  if _educations.len() == 0 {
    return
  }
  let section_body = {
    _educations
      .map(education => {
        let main = link(education.url)[#education.institution]
        if education.url.len() == 0 {
          main = education.institution
        }
        _entry_heading(
          main: main,
          dates: _format_dates(start-date: education.startDate, end-date: education.endDate),
          description: (
            emph(education.studyType),
            education.area,
            "GPA: " + strong(education.score),
          ).join(" | "),
          bottom_right: education.location,
        )
        [
          - #emph[Selected coursework]: #education.courses.join(", ")
        ]
      })
      .join(v(render_space_between_entry))
  }
  _section("Education", section_body)
}

#let section_work(_works) = {
  if _works.len() == 0 {
    return
  }
  let section_body = {
    _works
      .map(work => {
        let main = link(work.url)[#work.name]
        if work.url.len() == 0 {
          main = work.name
        }
        [
          #_entry_heading(
            main: main,
            dates: _format_dates(start-date: work.startDate, end-date: work.endDate),
            description: (
              emph(work.position),
              work.description,
            ).join(" | "),
            bottom_right: work.location,
          )
          #work.highlights.map(it => [- #it]).join(v(render_space_between_highlight))
        ]
      })
      .join(v(render_space_between_entry))
  }
  _section("Work", section_body)
}

#let section_project(_projects) = {
  if _projects.len() == 0 {
    return
  }
  let section_body = {
    _projects
      .map(project => {
        let main = link(project.url)[#project.name]
        if project.url.len() == 0 {
          main = project.name
        }
        let source_code = link(project.source_code)[Source code]
        if project.source_code.len() == 0 {
          source_code = ""
        }
        [
          #_entry_heading(
            main: main,
            dates: _format_dates(start-date: project.startDate, end-date: project.endDate),
            description: project.roles.map(emph).join(" | "),
            bottom_right: source_code,
          )
          #v(-2em) \
          #project.description
          #project.highlights.map(it => [- #it]).join(v(render_space_between_highlight))
        ]
      })
      .join(v(render_space_between_entry))
  }
  _section("Projects", section_body)
}

#let section_volunteer(_volunteers) = {
  if _volunteers.len() == 0 {
    return
  }
  let section_body = {
    _volunteers
      .map(volunteer => {
        let main = link(volunteer.url)[#volunteer.organization]
        if volunteer.url.len() == 0 {
          main = volunteer.organization
        }
        [
          #_entry_heading(
            main: main,
            dates: _format_dates(start-date: volunteer.startDate, end-date: volunteer.endDate),
            description: emph(volunteer.position),
            bottom_right: volunteer.location,
          )
          #v(-2em) \
          #volunteer.summary
          #volunteer.highlights.map(it => [- #it]).join(v(render_space_between_highlight))
        ]
      })
      .join(v(render_space_between_entry))
  }
  _section("Volunteering", section_body)
}

#let section_award(_awards) = {
  if _awards.len() == 0 {
    return
  }
  let section_body = [
    #(
      _awards
        .map(award => {
          let awarder_str = " - Awarded by " + award.awarder
          if award.awarder.len() == 0 {
            awarder_str = ""
          }
          let prefix = link(award.url)[#award.title]
          if award.url.len() == 0 {
            prefix = award.title
          }
          let summary_str = [#award.summary]
          if award.summary.len() == 0 {
            summary_str = ""
          }
          [- #prefix#awarder_str #h(1fr) #award.date \ #summary_str]
        })
        .join(v(render_space_between_highlight))
    )
  ]
  _section("Awards", section_body)
}

#let section_certificate(_certificates) = {
  if _certificates.len() == 0 {
    return
  }
  let section_body = _certificates
    .map(certificate => {
      let post_fix = h(1fr) + certificate.date
      let issue_str = " - issued by " + certificate.issuer
      if certificate.issuer.len() == 0 {
        issue_str = ""
      }
      let prefix = link(certificate.url)[#certificate.name]
      if certificate.url.len() == 0 {
        prefix = certificate.name
      }
      [- #prefix#issue_str #post_fix]
    })
    .join(v(render_space_between_highlight))
  _section("Certificates", section_body)
}



#let section_publication(_publications) = {
  if _publications.len() == 0 {
    return
  }
  let section_body = [
    #(
      _publications
        .map(publication => {
          let prefix = link(publication.url)[#publication.name]
          if publication.url.len() == 0 {
            prefix = publication.name
          }
          let publisher_str = " - published by " + publication.publisher
          if publication.publisher.len() == 0 {
            publisher_str = ""
          }
          let summary_str = [#publication.summary]
          if publication.summary.len() == 0 {
            summary_str = ""
          }
          [- #prefix#publisher_str #h(1fr) #publication.releaseDate \ #summary_str]
        })
        .join(v(render_space_between_highlight))
    )
  ]
  _section("Publications", section_body)
}

#let _section_custom(title, highlights) = {
  let section_body = {
    highlights
      .map(highlight => {
        let summary_str = highlight.summary + ": "
        let description_str = highlight.description
        if highlight.description.len() == 0 {
          description_str = ""
        }
        [- #text(weight: "bold")[#summary_str]#description_str]
      })
      .join(v(render_space_between_highlight))
  }
  _section(title, section_body)
}

#let sections_custom(_custom_sections) = {
  if _custom_sections.len() == 0 {
    return
  }
  _custom_sections
    .map(custom_section => {
      let title = custom_section.title
      let highlights = custom_section.highlights
      _section_custom(title, highlights)
    })
    .join(v(render_space_between_sections))
}
