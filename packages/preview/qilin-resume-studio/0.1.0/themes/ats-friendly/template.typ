#import "../module-core.typ": render-contacts

#let resume(
  // Name of the author (you)
  author: "",
  author-position: center,
  // Personal Information
  contacts: (),
  personal-info-position: center,
  // Document values and format
  color-enabled: true,
  text-color: "#000080",
  font: "New Computer Modern",
  paper: "us-letter",
  author-font-size: 20pt,
  font-size: 10pt,
  lang: "en",
  body,
) = {
  // Sets document metadata
  set document(author: author, title: author)

  // Document-wide formatting, including font and margins
  set text(
    font: font,
    size: font-size,
    lang: lang,
    ligatures: false,
  )
  set page(
    margin: 0.5in,
    paper: paper,
  )

  // Accent Color Styling
  show heading: set text(fill: if color-enabled { rgb(text-color) } else { black })
  show link: set text(fill: if color-enabled { rgb(text-color) } else { blue })

  // Link styles
  show link: underline

  // Name will be aligned to center, bold and big
  show heading.where(level: 1): it => [
    #set align(author-position)
    #set text(
      weight: "bold",
      size: author-font-size,
    )
    #pad(it.body)
  ]

  // Level 1 Heading
  [= #(author)]

  // Personal Information
  pad(
    top: 0.25em,
    align(personal-info-position)[
      #render-contacts(contacts, delimiter: [  |  ])
    ],
  )

  show heading.where(level: 2): it => [
    #pad(top: 0pt, bottom: -10pt, [#smallcaps(it.body)])
    #line(length: 100%, stroke: 1pt)
  ]

  // Main body.
  set par(justify: true)

  body
}

// Components layout template
#let one-by-one-layout(
  left: "",
  right: "",
) = {
  [
    #left #h(1fr) #right
  ]
}

#let two-by-two-layout(
  top-left: "",
  top-right: "",
  bottom-left: "",
  bottom-right: "",
) = {
  [
    #top-left #h(1fr) #top-right \
    #bottom-left #h(1fr) #bottom-right
  ]
}

// Dates that can be use for components
#let dates-util(
  start-date: "",
  end-date: "",
) = {
  if end-date == "" {
    start-date
  } else {
    start-date + " " + $dash.em$ + " " + end-date
  }
}

// Work Component
#let work(
  company: "",
  role: "",
  dates: "",
  tech-used: "",
  location: "",
) = {
  if tech-used == "" {
    two-by-two-layout(
      top-left: strong(company),
      top-right: dates,
      bottom-left: role,
      bottom-right: emph(location),
    )
  } else {
    two-by-two-layout(
      top-left: strong(company) + " " + "|" + " " + strong(role),
      top-right: dates,
      bottom-left: tech-used,
      bottom-right: emph(location),
    )
  }
}

// Project Component
#let project(
  name: "",
  dates: "",
  tech-used: "",
  url: "",
) = {
  if tech-used == "" {
    one-by-one-layout(
      left: [*#name* #if url != "" and dates != "" [(#link("https://" + url)[#url])]],
      right: dates,
    )
  } else {
    two-by-two-layout(
      top-left: strong(name),
      top-right: dates,
      bottom-left: tech-used,
      bottom-right: [(#link("https://" + url)[#url])],
    )
  }
}

// Education Component
#let edu(
  institution: "",
  location: "",
  degree: "",
  dates: "",
) = {
  two-by-two-layout(
    top-left: strong(institution),
    top-right: location,
    bottom-left: degree,
    bottom-right: dates,
  )
}

// ─────────────────────────────────────────────────────────────────────────────

#let _safe(v, fallback: "") = {
  if v == none { fallback } else { v }
}

#let _find-contact(contacts, key) = {
  for c in contacts {
    if _safe(c.at("type", default: "")) == key {
      return c
    }
  }
  none
}

#let _contact-val(contacts, key) = {
  let c = _find-contact(contacts, key)
  if c == none {
    ""
  } else {
    _safe(c.at("value", default: c.at("label", default: c.at("url", default: ""))))
  }
}

#let _date(start, end) = {
  dates-util(start-date: _safe(start), end-date: _safe(end))
}

#let _default-settings = (
  color-enabled: false,
  text-color: "#000080",
  font: "New Computer Modern",
  paper: "us-letter",
  author-font-size: 20pt,
  font-size: 10pt,
  lang: "en",
)

#let _length-or(value, fallback) = {
  if type(value) == length {
    value
  } else {
    fallback
  }
}

#let _normalize-native(data) = {
  let settings = data.at("settings", default: (:))
  let personal = data.at("personal", default: (:))
  let technical-skills = data.at("technical-skills", default: ())
  let experience = data.at("experience", default: ())
  let projects = data.at("projects", default: ())
  let internship = data.at("internship", default: ())
  let education = data.at("education", default: ())

  let merged-settings = _default-settings
  for (k, v) in settings {
    merged-settings.insert(k, v)
  }

  // 如果 personal 中没有 contacts 数组，从个别字段构建
  if "contacts" not in personal {
    let contacts = ()
    let phone = personal.at("phone", default: "")
    let location = personal.at("location", default: "")
    let email = personal.at("email", default: "")
    let github = personal.at("github", default: "")
    let linkedin = personal.at("linkedin", default: "")
    let portfolio = personal.at("portfolio", default: "")
    if phone != "" { contacts.push((type: "phone", label: "Phone", value: phone)) }
    if location != "" { contacts.push((type: "address", label: "Location", value: location)) }
    if email != "" { contacts.push((type: "email", label: "Email", value: email, url: "mailto:" + email)) }
    if github != "" { contacts.push((type: "github", label: "GitHub", value: github, url: "https://" + github)) }
    if linkedin != "" {
      contacts.push((type: "linkedin", label: "LinkedIn", value: linkedin, url: "https://" + linkedin))
    }
    if portfolio != "" {
      contacts.push((type: "website", label: "Portfolio", value: portfolio, url: "https://" + portfolio))
    }
    personal.insert("contacts", contacts)
  }

  (
    settings: merged-settings,
    personal: personal,
    technical-skills: technical-skills,
    experience: experience,
    projects: projects,
    internship: internship,
    education: education,
  )
}

#let _from-unified(data) = {
  let resume-info = data.at("resume-info", default: (:))
  let contacts = resume-info.at("contacts", default: ())

  let raw-skills = data.at("skills", default: ())
  let technical-skills = if type(raw-skills) == dictionary { raw-skills.at("items", default: ()) } else { raw-skills }

  let experience = ()
  let raw-exp = data.at("experience", default: ())
  let exp-items = if type(raw-exp) == dictionary { raw-exp.at("items", default: ()) } else { raw-exp }
  for e in exp-items {
    let highlights = if "details" in e {
      e.at("details", default: ())
    } else if "description" in e {
      (_safe(e.at("description", default: "")),)
    } else {
      ()
    }

    experience.push((
      company: _safe(e.at("company", default: "")),
      role: _safe(e.at("position", default: "")),
      start-date: _safe(e.at("start", default: "")),
      end-date: _safe(e.at("end", default: "")),
      location: _safe(e.at("location", default: _safe(resume-info.at("location", default: ""))), fallback: ""),
      tech-used: _safe(e.at("tech-used", default: "")),
      highlights: highlights,
    ))
  }

  let projects = ()
  let raw-proj = data.at("projects", default: ())
  let proj-items = if type(raw-proj) == dictionary { raw-proj.at("items", default: ()) } else { raw-proj }
  for p in proj-items {
    let highlights = if "details" in p {
      p.at("details", default: ())
    } else if "description" in p {
      (_safe(p.at("description", default: "")),)
    } else {
      ()
    }

    projects.push((
      name: _safe(p.at("name", default: "")),
      start-date: _safe(p.at("start", default: "")),
      end-date: _safe(p.at("end", default: "")),
      tech-used: _safe(p.at("tech-used", default: _safe(p.at("role", default: ""))), fallback: ""),
      url: _safe(p.at("url", default: _safe(p.at("link", default: ""))), fallback: ""),
      highlights: highlights,
    ))
  }

  let internship = ()
  let raw-intern = data.at("internship", default: ())
  let intern-items = if type(raw-intern) == dictionary { raw-intern.at("items", default: ()) } else { raw-intern }
  for p in intern-items {
    let highlights = if "details" in p {
      p.at("details", default: ())
    } else if "description" in p {
      (_safe(p.at("description", default: "")),)
    } else {
      ()
    }

    internship.push((
      name: _safe(p.at("name", default: "")),
      start-date: _safe(p.at("start", default: "")),
      end-date: _safe(p.at("end", default: "")),
      tech-used: _safe(p.at("tech-used", default: _safe(p.at("role", default: ""))), fallback: ""),
      url: _safe(p.at("url", default: _safe(p.at("github", default: ""))), fallback: ""),
      highlights: highlights,
    ))
  }

  let education = ()
  let raw-edu = data.at("education", default: ())
  let edu-items = if type(raw-edu) == dictionary { raw-edu.at("items", default: ()) } else { raw-edu }
  for edu in edu-items {
    education.push((
      institution: _safe(edu.at("institution", default: _safe(edu.at("school", default: ""))), fallback: ""),
      location: _safe(edu.at("location", default: "")),
      degree: _safe(edu.at("degree", default: ""))
        + if "major" in edu and _safe(edu.at("major", default: "")) != "" {
          " in " + _safe(edu.at("major", default: ""))
        } else {
          ""
        },
      start-date: _safe(edu.at("start", default: _safe(edu.at("start-date", default: ""))), fallback: ""),
      end-date: _safe(edu.at("end", default: _safe(edu.at("end-date", default: ""))), fallback: ""),
    ))
  }

  _normalize-native((
    personal: (
      name: _safe(resume-info.at("name", default: "")),
      contacts: contacts,
    ),
    technical-skills: technical-skills,
    experience: experience,
    projects: projects,
    internship: internship,
    education: education,
  ))
}

#let _render-bullets(items) = {
  for item in items {
    if type(item) == dictionary {
      // 支持 name/level/description 格式（技能）
      let name = item.at("name", default: "")
      if name != "" {
        let level = item.at("level", default: "")
        let description = item.at("description", default: "")
        let parts = (name,)
        if level != "" { parts.push(level) }
        if description != "" { parts.push(description) }
        [- #parts.join("：")]
      } else {
        let title = item.at("title", default: item.at("category", default: ""))
        let value = item.at("value", default: item.at("items", default: ""))
        if title != "" {
          [- *#title*: #(if type(value) == array { value.join(", ") } else { value })]
        } else {
          [- #(if type(value) == array { value.join(", ") } else { value })]
        }
      }
    } else if _safe(item) != "" {
      [- #item]
    }
  }
}

#let blueprint(
  data: (:),
  body,
) = {
  let normalized = if "resume-info" in data {
    _from-unified(data)
  } else {
    _normalize-native(data)
  }

  let settings = normalized.settings
  let personal = normalized.personal
  let technical-skills = normalized.at("technical-skills", default: ())
  let experience = normalized.experience
  let projects = normalized.projects
  let internship = normalized.at("internship", default: ())
  let education = normalized.education

  show: resume.with(
    author: _safe(personal.at("name", default: "")),
    author-position: center,
    contacts: personal.at("contacts", default: ()),
    personal-info-position: center,
    color-enabled: settings.at("color-enabled", default: false),
    text-color: settings.at("text-color", default: "#000080"),
    font: settings.at("font", default: "New Computer Modern"),
    paper: settings.at("paper", default: "us-letter"),
    author-font-size: _length-or(settings.at("author-font-size", default: 20pt), 20pt),
    font-size: _length-or(settings.at("font-size", default: 10pt), 10pt),
    lang: settings.at("lang", default: "en"),
  )

  if technical-skills.len() > 0 {
    [== Technical Skills]
    _render-bullets(technical-skills)
  }

  if experience.len() > 0 {
    [== Experience]
    for e in experience {
      work(
        company: _safe(e.at("company", default: "")),
        role: _safe(e.at("role", default: "")),
        dates: _date(e.at("start-date", default: ""), e.at("end-date", default: "")),
        tech-used: _safe(e.at("tech-used", default: "")),
        location: _safe(e.at("location", default: "")),
      )
      _render-bullets(e.at("highlights", default: ()))
    }
  }

  // Projects & Internship (use same rendering logic)
  for (section-data, section-title) in ((projects, "Projects"), (internship, "Internship")) {
    if section-data.len() > 0 {
      [== #section-title]
      for p in section-data {
        project(
          name: _safe(p.at("name", default: "")),
          dates: _date(p.at("start-date", default: ""), p.at("end-date", default: "")),
          tech-used: _safe(p.at("tech-used", default: "")),
          url: _safe(p.at("url", default: "")),
        )
        _render-bullets(p.at("highlights", default: ()))
      }
    }
  }

  if education.len() > 0 {
    [== Education]
    for ed in education {
      edu(
        institution: _safe(ed.at("institution", default: "")),
        location: _safe(ed.at("location", default: "")),
        degree: _safe(ed.at("degree", default: "")),
        dates: _date(ed.at("start-date", default: ""), ed.at("end-date", default: "")),
      )
    }
  }

  // ─────────────────────────────────────────────────────────
  //  resume-info 扩展字段
  // ─────────────────────────────────────────────────────────

  if "resume-info" in data {
    let resume-info = data.at("resume-info", default: (:))

    // 额外基本信息
    let extra-items = ()
    for (key, label) in (("gender", "Gender"), ("species", "Species"), ("birthday", "Birthday"), ("city", "City")) {
      let val = resume-info.at(key, default: "")
      if val != "" { extra-items.push(label + ": " + str(val)) }
    }
    if extra-items.len() > 0 {
      [== Personal Information]
      [#extra-items.join("  |  ")]
    }

    let motto = resume-info.at("motto", default: "")
    if motto != "" {
      [_"#motto"_]
      v(0.3em)
    }

    let summary = resume-info.at("summary", default: "")
    if summary != "" {
      [== Summary]
      [#summary]
    }

    let self-evaluation = resume-info.at("self-evaluation", default: "")
    if self-evaluation != "" {
      [== Self Evaluation]
      [#self-evaluation]
    }

    let interests = resume-info.at("interests", default: ())
    if interests.len() > 0 {
      [== Interests]
      [#interests.join(", ")]
    }
  }

  // ─────────────────────────────────────────────────────────
  //  荣誉奖项
  // ─────────────────────────────────────────────────────────

  let raw-awards = data.at("awards", default: ())
  let awards = if type(raw-awards) == dictionary { raw-awards.at("items", default: ()) } else { raw-awards }
  if awards.len() > 0 {
    [== Awards]
    for award in awards {
      if type(award) == dictionary {
        [
          - *#award.at("title", default: "")* #if award.at("date", default: "") != "" { [  (#award.at("date", default: ""))] }
        ]
      } else {
        [- #str(award)]
      }
    }
  }

  // ─────────────────────────────────────────────────────────
  //  资质证书
  // ─────────────────────────────────────────────────────────

  let raw-certs = data.at("certificates", default: ())
  let certificates = if type(raw-certs) == dictionary { raw-certs.at("items", default: ()) } else { raw-certs }
  if certificates.len() > 0 {
    [== Certificates]
    for cert in certificates {
      if type(cert) == dictionary {
        [
          - *#cert.at("name", default: "")* #if cert.at("date", default: "") != "" { [(#cert.at("date", default: ""))] } #if cert.at("org", default: "") != "" { [ — #cert.at("org", default: "")] }
        ]
      } else {
        [- #str(cert)]
      }
    }
  }

  body
}
