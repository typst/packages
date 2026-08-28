
// DATA STATES
#let resume-name = state("resume-name")
#let resume-summary = state("resume-summary")
#let resume-contact = state("resume-contact", ())
#let resume-skills = state("resume-skills", ())
#let resume-experiences = state("resume-experiences",  ())
#let resume-projects = state("resume-projects", ())
#let resume-education = state("resume-education", ())
#let resume-certifications = state("resume-certifications", ())

// CONFIG STATES
#let resume-inline-separator = state("inline-separator", [])
#let resume-contacts-separator = state("contacts-separator", [])

// TEMPLATE CONFIG
#let resume(
  contact-info-position: left,
  link-color: navy,
  accent-color: navy,
  font: "libertinus serif", 
  font-size: 11pt,
  line-spacing: 0.65em,
  page-margin: 0.5in,
  list-marker: [--],
  contacts-separator: [\/],
  inline-separator: [\/],
  justify: true,
  doc
) = {
  set page(margin: page-margin)
  set par(justify: justify)
  set par(leading: line-spacing)
  set text(size: font-size, font: font)
  set list(marker: list-marker)
  
  show link: set text(link-color)
  show title: set text(accent-color)
  show heading: set text(accent-color)
  show heading: set text(weight: "regular")
  show heading: it => {
    pad(top: 0pt, bottom: -10pt, [#smallcaps[#it.body]])
    line(length: 100%, stroke: 0.5pt)
  }
  show <contact-info>: set align(contact-info-position)
  show <contact-info>: set text(accent-color)

  context resume-inline-separator.update(_ => inline-separator)
  context resume-contacts-separator.update(_ => contacts-separator)
  doc
}


// HELPER FUNCTIONS
#let is-url(item) = {
  type(item) == str and (
    item.starts-with("https://") or
    item.starts-with("http://")
  )
}

#let url-domain(url) = {
  let url = if url.starts-with("https://") {
    url.slice(8)
  } else if url.starts-with("http://") {
    url.slice(7)
  } else {
    url
  }

  let domain = url.split("/").at(0)

  if domain.starts-with("www.") {
    domain.slice(4)
  } else {
    domain
  }
}

#let to-string(it) = {
  if type(it) == str {
    it
  } else if type(it) != content {
    str(it)
  } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(to-string).join()
  } else if it.has("body") {
    to-string(it.body)
  } else if it == [ ] {
    " "
  }
}

#let link-formatter(url, content) = {
  link(to-string(url))[#content]
}


#let contact-formatters = (
  email: (item, type) =>
    link-formatter(
      "mailto:" + item,
      item,
    ),
  phone: (item, type) =>
    link-formatter(
      "tel:" + item,
      item,
    ),
  linkedin: (item, type) =>
    link-formatter(
      "https://linkedin.com/in/" + item,
      [linkedin/#item],
    ),
  github: (item, type) =>
    link-formatter(
      "https://github.com/" + item,
      [github/#item],
    ),
  default: (item, type) => {
    if is-url(item) {
      link-formatter(
        item,
        [#type/#url-domain(item)],
      )
    } else {
      item
    }
  },
)

#let format-item(item, type) = {
  contact-formatters
    .at(type, default: contact-formatters.default)(item, type)
}

#let upsert(items, key, value) = {
  let result = items.filter(entry => entry.at(0) != key)
  result.push((key, value))
  result
}

#let inline-separator = {context resume-inline-separator.get()}

#let resume-section(title, body) = {
  block[
    == #title
    #body
  ]
}

// DATA SETTER FUNCTIONS
#let contact-info(
  name: [],
  phone: none,
  email: none,
  address: none,
  linkedin: none,
  github: none,
  ..args
) = {
  resume-name.update(_ => upper(name))
  let contact-items = ()
  if phone != none [#contact-items.push(("phone", phone))]
  if email != none [#contact-items.push(("email", email))]
  if address != none [#contact-items.push(("address", address))]
  if linkedin != none [#contact-items.push(("linkedin", linkedin))]
  if github != none [#contact-items.push(("github", github))]
  for arg in args.named() [#contact-items.push(arg)]
  for (type, item) in contact-items [
    #context resume-contact.update(items =>
      upsert(items, type, item)
    )
  ]
}

#let summary(content) = {
  resume-summary.update(_ => content)
}

#let skillset(category:"", skills:"") = {
  resume-skills.update(entries => {
    entries + (
      (
        category: category,
        skills: skills,
      ),
    )
  })
}

#let experience(
  title: [],
  company: none,
  location: none,
  start-date: none,
  end-date: none,
  new-page: false,
  ..accomplishments
) = {
  resume-experiences.update(entries => {
    entries + (
      (
        title: title,
        company: company,
        location: location,
        start-date: start-date,
        end-date: end-date,
        new-page: new-page,
        accomplishments: accomplishments.pos(),
      ),
    )
  })
}

#let project(
  name: [],
  start-date: none,
  end-date: none,
  info: none,
  new-page: false,
  ..accomplishments,
) = {
  resume-projects.update(entries => {
    entries + (
      (
        name: name,
        start-date: start-date,
        end-date: end-date,
        info: info,
        new-page: new-page,
        accomplishments: accomplishments.pos(),
      ),
    )
  })
}

#let education(
  degree: [],
  school: none,
  location: none,
  start-date: none,
  end-date: none,
  gpa: none,
  coursework: none,
  new-page: false,
) = {
  resume-education.update(entries => {
    entries + (
      (
        degree: degree,
        school: school,
        location: location,
        start-date: start-date,
        end-date: end-date,
        gpa: gpa,
        coursework: coursework,
        new-page: new-page,
      ),
    )
  })
}

#let certification(
  name:[],
  issuer:none,
  date:none,
  new-page: false,
  ..highlights
) = {
  resume-certifications.update(entries => {
    entries + (
      (
        name: name,
        issuer: issuer,
        date: date,
        new-page: new-page,
        highlights: highlights.pos()
      ),
    )
  })
}

// PRINT FUNCTIONS
#let print-contact = [
  #title[#context resume-name.get()]<contact-info>
  #context {
    resume-contact.get()
      .map(entry => format-item(entry.at(1), entry.at(0)))
      .join([#resume-contacts-separator.get()])
  } <contact-info>
]

#let print-summary = {
  resume-section("Summary", context {resume-summary.get()})
}

#let print-skills = {
  resume-section("Skills",
  context {
    table(
      columns: (auto, 1fr),
      column-gutter: 1em,
      row-gutter: par.leading,
      stroke: none,
      inset: (0pt),
      ..resume-skills.get()
      .map(entry => (
        [#strong[#entry.category]],
        [#entry.skills],
      ))
      .flatten(),
    )
  })
}

#let print-experience = {
  resume-section("Experiences",
  context{
    for entry in resume-experiences.get() [
      #if entry.new-page [#colbreak()]
      #strong[#entry.title]#if entry.company != none [#inline-separator#entry.company]#if entry.location != none [#inline-separator#entry.location]
      #h(1fr)
      *#entry.start-date 
      #if entry.start-date != none and entry.end-date != none [ -- ] 
      #entry.end-date*
      #for accomplishment in entry.accomplishments [
        - #accomplishment
      ]
    ]
  })
}

#let print-projects = {
  resume-section("Projects",
  context{
    for entry in resume-projects.get() [
      #if entry.new-page [#colbreak()]
      #strong[#entry.name]#if entry.info != none [#inline-separator#entry.info]
      #h(1fr)
      *#entry.start-date 
      #if entry.start-date != none and entry.end-date != none [ -- ]
      #entry.end-date*
      #for accomplishment in entry.accomplishments [
       - #accomplishment
     ]
    ]
  })
}

#let print-education = {
  resume-section("Education",
  context{
    let entries = resume-education.get()
    for (i, entry) in entries.enumerate() [
      #if entry.new-page [#colbreak()]
      #strong[#entry.degree]#if entry.school != none [#inline-separator#entry.school]#if entry.location != none [#inline-separator#entry.location]
      #h(1fr)
      *#entry.start-date 
      #if entry.start-date != none and entry.end-date != none [ -- ] 
      #entry.end-date* \
      #if entry.gpa != none [
        _*GPA* — #entry.gpa _
      ]#if entry.gpa != none and entry.coursework != none [#inline-separator]#if entry.coursework != none [_*Coursework* — #entry.coursework _]
      #if i < entries.len() - 1 [
        #v(1pt)
      ]
    ]
  })
}

#let print-certifications = {
  resume-section("Certifications",
  context{
    let entries = resume-certifications.get()
    for (i, entry) in entries.enumerate() [
      #if entry.new-page [#colbreak()]
      #strong[#entry.name]#if (entry.issuer != none) [#inline-separator#entry.issuer]#if entry.date != none [#h(1fr)*#entry.date*]
      #for highlight in entry.highlights [
        - #highlight
      ]
    ]
  })
}