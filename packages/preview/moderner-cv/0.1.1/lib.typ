#import "@preview/fontawesome:0.5.0": *

#let _cv-line(left, right, ..args) = {
  set block(below: 0pt)
  table(
    columns: (1fr, 5fr),
    stroke: none,
    ..args.named(),
    left,
    right,
  )
}
#let moderncv-blue = rgb("#3973AF")

#let _header(
  title: [],
  subtitle: [],
  socials: (:),
) = {
  let titleStack = stack(
    dir: ttb,
    spacing: 1em,
    text(size: 30pt, title),
    text(size: 20pt, subtitle),
  )

  let social(icon, link_prefix, username) = [
    #fa-icon(icon) #link(link_prefix + username)[#username]
  ]

  let custom-social(icon, dest, body) = [
    #fa-icon(icon) #link(dest, body)
  ]

  let socialsDict = (
    // key: (faIcon, linkPrefix)
    phone: ("phone", "tel:"),
    email: ("envelope", "mailto:"),
    github: ("github", "https://github.com/"),
    linkedin: ("linkedin", "https://linkedin.com/in/"),
    x: ("x-twitter", "https://twitter.com/"),
    bluesky: ("bluesky", "https://bsky.app/profile/"),
  )

  let socialsList = ()
  for entry in socials {
    assert(type(entry) == array, message: "Invalid social entry type.")
    assert(entry.len() == 2, message: "Invalid social entry length.")
    let (key, value) = entry
    if type(value) == str {
      if key not in socialsDict {
        panic("Unknown social key: " + key)
      }
      let (icon, linkPrefix) = socialsDict.at(key)
      socialsList.push(social(icon, linkPrefix, value))
    } else if type(value) == array {
      assert(value.len() == 3, message: "Invalid social entry: " + key)
      let (icon, dest, body) = value
      socialsList.push(custom-social(icon, dest, body))
    } else {
      panic("Invalid social entry: " + entry)
    }
  }

  let socialStack = stack(
    dir: ttb,
    spacing: 0.5em,
    ..socialsList,
  )

  stack(
    dir: ltr,
    titleStack,
    align(
      right + top,
      socialStack,
    ),
  )
}

#let moderner-cv(
  name: [],
  subtitle: [CV],
  social: (:),
  color: moderncv-blue,
  lang: "en",
  font: ("New Computer Modern"),
  show-footer: true,
  body,
) = [
  #set page(
    paper: "a4",
    margin: (
      top: 10mm,
      bottom: 15mm,
      left: 15mm,
      right: 15mm,
    ),
  )
  #set text(
    font: font,
    lang: lang,
  )

  #show heading: it => {
    set text(weight: "regular")
    set text(color)
    set block(above: 0pt)
    _cv-line(
      [],
      [#it.body],
    )
  }
  #show heading.where(level: 1): it => {
    set text(weight: "regular")
    set text(color)
    _cv-line(
      align: horizon,
      [#box(fill: color, width: 28mm, height: 0.25em)],
      [#it.body],
    )
  }

  #_header(title: name, subtitle: subtitle, socials: social)

  #body

  #if show-footer [
    #v(1fr, weak: false)
    #name\
    #datetime.today().display("[month repr:long] [day], [year]")
  ]
]

#let cv-line(left-side, right-side) = {
  _cv-line(
    align(right, left-side),
    par(right-side, justify: true),
  )
}

#let cv-entry(
  date: [],
  title: [],
  employer: [],
  ..description,
) = {
  let elements = (
    strong(title),
    emph(employer),
    ..description.pos(),
  )
  cv-line(
    date,
    elements.join(", "),
  )
}

#let cv-language(name: [], level: [], comment: []) = {
  _cv-line(
    align(right, name),
    stack(dir: ltr, level, align(right, emph(comment))),
  )
}

#let cv-double-item(left-1, right-1, left-2, right-2) = {
  set block(below: 0pt)
  table(
    columns: (1fr, 2fr, 1fr, 2fr),
    stroke: none,
    align(right, left-1), right-1, align(right, left-2), right-2,
  )
}

#let cv-list-item(item) = {
  _cv-line(
    [],
    list(item),
  )
}

#let cv-list-double-item(item1, item2) = {
  set block(below: 0pt)
  table(
    columns: (1fr, 2.5fr, 2.5fr),
    stroke: none,
    [], list(item1), list(item2),
  )
}
