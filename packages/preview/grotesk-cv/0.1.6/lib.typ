#import "@preview/fontawesome:0.4.0": *


#let section-title-style(str, color) = {
  text(
    size: 12pt,
    weight: "bold",
    fill: rgb(color),
    str,
  )
}

#let name-block(
  header-name,
  color,
) = {
  text(
    fill: rgb(color),
    size: 30pt,
    weight: "extrabold",
    header-name,
  )
}

#let title-block(
  title,
  color,
) = {
  text(
    size: 12pt,
    style: "italic",
    fill: rgb(color),
    title,
  )
}

#let info-block-style(
  icon,
  txt,
  color,
  include-icons,
) = {

  text(
    size: 10pt,
    fill: rgb(color),
    weight: "medium",
    if include-icons {
      fa-icon(icon) + h(10pt) + txt
    } else {
      txt
    },
  )
}

#let info-block(
  metadata,
) = {
  let info = metadata.personal.info
  let icons = metadata.personal.icon
  let color = metadata.layout.text.color.medium
  let include-icons = metadata.personal.include_icons
  table(
    columns: (1fr, 1fr),
    stroke: none,
    ..info.pairs().map(((key, val)) => info-block-style(icons.at(key), val, color, include-icons))
  )
}

#let header-table(
  metadata,
) = {
  let lang = metadata.personal.language
  let subtitle = metadata.language.at(lang).at("subtitle")
  table(
    columns: 1fr,
    inset: 0pt,
    stroke: none,
    row-gutter: 4mm,
    [#name-block(metadata.personal.first_name + " " + metadata.personal.last_name, metadata.layout.text.color.dark)],
    [#title-block(
        subtitle,
        metadata.layout.text.color.dark,
      )],
    [#info-block(metadata)],
  )
}

#let cover-header-table(
  metadata,
) = {
  let lang = metadata.personal.language
  let subtitle = metadata.language.at(lang).at("subtitle")
  table(
    columns: 1fr,
    inset: 0pt,
    stroke: none,
    row-gutter: 4mm,
    [#name-block(metadata.personal.first_name + " " + metadata.personal.last_name, metadata.layout.text.color.dark)],
    [#title-block(
        subtitle,
        metadata.layout.text.color.dark,
      )],
  )
}

#let make-header-photo(
  image-name,
  profile-photo,
) = {
  if profile-photo != false {
    box(
      clip: true,
      radius: 50%,
      image("template/img/" + image-name),
    )
  } else {
    box(
      clip: true,
      stroke: 5pt + yellow,
      radius: 50%,
      fill: yellow,
    )
  }
}

#let cv-header(left-comp, right-comp, cols, align) = {
  table(
    columns: cols,
    inset: 0pt,
    stroke: none,
    column-gutter: 10pt,
    align: top,
    {
      left-comp
    },
    {
      right-comp
    }
  )
}

#let make-info-table(
  metadata,
) = {
  let color = metadata.layout.text.color.medium
  let info = metadata.personal.info
  let icons = metadata.personal.icon
  let include-icons = metadata.personal.include_icons
  table(
    columns: 1fr,
    align: right,
    stroke: none,
    ..info.pairs().map(((key, val)) => info-block-style(icons.at(key), val, color, include-icons))
  )
}

#let create-header(
  metadata,
  use-photo: false,
) = {
  cv-header(
    header-table(metadata),
    make-header-photo(metadata.personal.profile_image, use-photo),
    (74%, 20%),
    left,
  )
}

#let create-cover-header(
  metadata,
) = {
  cv-header(
    cover-header-table(metadata),
    make-info-table(metadata),
    (65%, 30%),
    left,
  )
}


#let cv-section(title) = {
  section-title-style(title)
  h(4pt)
}

#let date-style(date) = (
  table.cell(
    align: right,
    text(
      size: 9pt,
      weight: "bold",
      style: "italic",
      date,
    ),
  )
)

#let degree-style(degree) = (
  text(
    size: 10pt,
    weight: "bold",
    degree,
  )
)

#let phonenumber-style(phone) = (
  text(
    size: 9pt,
    style: "italic",
    weight: "medium",
    phone,
  )
)

#let institution-style(institution) = (
  table.cell(
    text(
      size: 9pt,
      style: "italic",
      weight: "medium",
      institution,
    ),
  )
)

#let location-style(location) = (
  table.cell(
    text(
      style: "italic",
      weight: "medium",
      location,
    ),
  )
)

#let email-style(email) = (
  text(
    size: 9pt,
    style: "italic",
    weight: "medium",
    email,
  )
)

#let tag-style(str) = {
  align(
    right,
    text(
      weight: "regular",
      str,
    ),
  )
}

#let tag-list-style(color, tags) = {
  for tag in tags {
    box(
      inset: (x: 0.4em),
      outset: (y: 0.3em),
      fill: rgb(color),
      radius: 3pt,
      tag-style(tag),
    )
    h(5pt)
  }
}

#let profile-entry(str) = {
  text(
    size: text-size,
    weight: "medium",
    str,
  )
}

#let reference-entry(
  name: "Name",
  title: "Title",
  company: "Company",
  telephone: "Telephone",
  email: "Email",
) = {
  table(
    columns: (3fr, 2fr),
    inset: 0pt,
    stroke: none,
    row-gutter: 3mm,
    [#degree-style(name)],
    [#date-style(company)],
    table.cell(colspan: 2)[#phonenumber-style(telephone), #email-style(email)],
  )
  v(2pt)
}

#let education-entry(
  degree: "Degree",
  date: "Date",
  institution: "Institution",
  location: "Location",
  description: "",
  highlights: (),
) = {
  table(
    columns: (3fr, 1fr),
    inset: 0pt,
    stroke: none,
    row-gutter: 3mm,
    [#degree-style(degree)], [#date-style(date)],
    [#institution-style(institution), #location-style(location)],
  )
  v(2pt)
}

#let experience-entry(
  title: "Title",
  date: "Date",
  company: "Company",
  location: "Location",
) = {
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: none,
    row-gutter: 3mm,
    [#degree-style(title)] ,
    [#date-style(date)],
    table.cell(colspan: 2)[#institution-style(company), #location-style(location)],
  )
  v(5pt)
}

#let skill-style(skill) = {
  text(
    weight: "bold",
    skill,
  )
}

#let skill-tag(color, skill) = {
  box(
    inset: (x: 0.3em),
    outset: (y: 0.2em),
    fill: rgb(color),
    radius: 3pt,
    skill-style(skill),
  )
}

#let skill-entry(
  color,
  skills: (),
) = {
  table(
    columns: 1fr,
    inset: 0pt,
    stroke: none,
    row-gutter: 2mm,
    column-gutter: 3mm,
    align: center,
    for sk in skills {
      [#skill-tag(color, sk) #h(4pt)]
    },
  )
}


#let language-entry(
  language: "Language",
  proficiency: "Proficiency",
) = {
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: none,
    row-gutter: 3mm,
    align: left,
    table.cell(
      text(
        weight: "bold",
        language,
      ),
    ),
    table.cell(
      align: right,
      text(
        weight: "medium",
        proficiency,
      ),
    )
  )
}

#let recipient-style(str) = {
  text(
    style: "italic",
    str,
  )
}

#let recipient-entry(
  name: "Name",
  title: "Title",
  company: "Company",
  address: "Address",
  city: "City",
) = {
  table(
    columns: 1fr,
    inset: 0pt,
    stroke: none,
    row-gutter: 3mm,
    align: left,
    recipient-style(name),
    recipient-style(title),
    recipient-style(company),
    recipient-style(address),
  )
}

#let create-panes(left, right, proportion) = {
  grid(
    columns: (proportion, 96% - proportion),
    column-gutter: 20pt,
    stack(
      spacing: 20pt,
      left,
    ),
    stack(
      spacing: 20pt,
      right,
    ),
  )
}


#let cv(
  metadata,
  use-photo: false,
  left-pane: (),
  right-pane: (),
  left-pane-proportion: 71%,
  doc,
) = {
  set text(
    fill: rgb(metadata.layout.text.color.dark),
    font: metadata.layout.text.font,
    size: eval(metadata.layout.text.size),
  )
  set align(left)
  set page(
    fill: rgb(metadata.layout.fill_color),
    paper: metadata.layout.paper_size,
    margin: (
      left: 1.2cm,
      right: 1.2cm,
      top: 1.6cm,
      bottom: 1.2cm,
    ),
  )
  set list(marker: [‣])
  create-header(metadata, use-photo: use-photo)
  create-panes(left-pane, right-pane, left-pane-proportion)
  doc
}

#let cover-letter(
  metadata,
  use-photo: false,
  doc,
) = {
  set text(
    fill: rgb(metadata.layout.text.color.dark),
    font: metadata.layout.text.font,
    size: eval(metadata.layout.text.size),
  )
  set align(left)
  set page(
    fill: rgb(metadata.layout.fill_color),
    paper: metadata.layout.paper_size,
    margin: (
      left: 1.2cm,
      right: 1.2cm,
      top: 1.6cm,
      bottom: 1.2cm,
    ),
  )
  set list(marker: [‣])
  create-cover-header(metadata)
  doc
}
