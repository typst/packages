#let default-document-config(
  title: "Titre",
  description: "Description",
  formation: "Nom de la formation",
  orientation: "Orientation",
  year: "2025 - 2026",
  authors: (
    ("Prenom Nom", "prenom.nom@std.heh.be"),
    ("Xy Z", "xy.z@std.heh.be"),
  ),
  exam-session: "Juin 2026",
  internal-promoter: "NOM PRÉNOM",
  thanks: "Mes plus sincères remerciements à toutes les personnes qui nous ont aidées de près ou de loin à réaliser le projet HEH-Template",
) = {
  return (
    title: title,
    description: description,
    formation: formation,
    orientation: orientation,
    year: year,
    authors: authors,
    exam-session: exam-session,
    internal-promoter: internal-promoter,
    thanks: thanks,
  )
}

#let outlines = (
  headings: (target: heading, title: "Table des matières"),
  tables: (target: figure.where(kind: table), title: "Table des tableaux"),
  images: (target: figure.where(kind: image), title: "Table des images"),
)

#let default-outlines-values = (
  outlines.headings,
  outlines.tables,
  outlines.images,
)

#let default-print-config(
  monochrome: false,
  monochromeimages: true,
  outlines: default-outlines-values,
  show-blank-page: false,
  font: "Roboto",
  lang: "fr",
) = {
  return (
    monochrome: monochrome,
    monochromeimages: monochromeimages,
    outlines: outlines,
    font: font,
    lang: lang,
    show-blank-page: show-blank-page,
  )
}

