#let titlepage(metadata, logo, date) = {
  let resources = yaml("../resources.yaml").at(metadata.lang).titlepage

  let type = metadata.layout.Type;
  let study = metadata.layout.Study;
  let data = metadata.data;

  let hdmRed = rgb(229, 20, 51);

  set align(center)
  set text(size: 12pt)
  set par(leading: 1.2em, spacing: 1.5em)

  [
    #set image(height: 10em)
    #logo
  ]

  v(1.5em)
  assert(type == "bachelor" or type == "master", message: "type needs to be set to 'bachelor' or 'master'")
  if type == "bachelor" {
    text("Bachelor Thesis " + study, size: 1.5em)
  } else if type == "master" {
    text("Master Thesis " + study, size: 1.5em)
  }
  v(2em)

  [
    #set text(font: metadata.layout.fonts.heading)
    #par(text(data.title, size: 2.25em, weight: "bold"))
    #par(text(data.subtitle, size: 1.5em, weight: "regular"))
  ]

  v(2em)
  line(length: 110%, stroke: 0.5pt + hdmRed)
  v(2em)

  set text(14pt)
  text(resources.SubmittedBy)
  if data.authors.len() == 1 {
    let author = data.authors.first()
    text(author.Name + "\n", size: 1.5em, fill: hdmRed, weight: "semibold", font: metadata.layout.fonts.heading)
    text(resources.StudentId + " " + str(author.StudentId) + "\n")
  } else {
    for (Name, StudentId) in data.authors {
      text(Name, size: 1.5em, fill: hdmRed, weight: "semibold", font: metadata.layout.fonts.heading)
      text(", " + str(StudentId) + "\n")
    }
  }

  v(1.5em)
  [
    #resources.InstituteAt #metadata.layout.Institute \
    #resources.Date #date.display("[day].[month].[year]") \
    #resources.Degree #metadata.layout.Degree
  ]

  set align(left + bottom)
  set text(14pt)

  let supervisorsData = (
    resources.FirstSupervisor,
    data.supervisors.first.Name,
    resources.SecondSupervisor,
    data.supervisors.second.Name
  )
  if data.supervisors.keys().any(k => k == "external") {
    let s = data.supervisors.external;
    supervisorsData.push(resources.ExternalSupervisor)
    supervisorsData.push(s.Name + " (" + s.Company + ")")
  }

  grid(
    columns: (auto, 1fr),
    column-gutter: 1em,
    row-gutter: -0.2em,
    rows: 1.6em,
    ..supervisorsData
  )

  pagebreak()
}