#let frontpage(
  title: [],
  subtitle: "",
  author: "",
  degree: "",
  faculty: "",
  department: "",
  major: "",
  submission-date: none,
) = {
  set document(title: title, author: author)
  set page(
    paper: "a4",
    margin: (left: 3mm, right: 3mm, top: 12mm, bottom: 27mm),
    header: none,
    footer: none,
    numbering: none,
    number-align: center,
  )

  let body-font = ("Open Sans", "Noto Sans")

  set text(font: body-font, size: 12pt, lang: "en")

  set par(leading: 1em)

  // --- Title Page ---
  place(top + left, image("../assets/logo.svg", width: 100%, height: 100%))

  // Faculty
  place(
    top + left,
    dy: 30mm,
    dx: 27mm,
    text(12pt, weight: "light", faculty),
  )

  // Department
  place(
    top + left,
    dy: 35mm,
    dx: 27mm,
    text(12pt, weight: "light", department),
  )

  // Title
  place(
    top + left,
    dy: 43mm,
    dx: 27mm,
    text(14pt, weight: "semibold", title),
  )

  // Subtitle (optional)
  if (subtitle != "") {
    place(
      top + left,
      dy: 53mm,
      dx: 27mm,
      text(12pt, weight: "light", subtitle),
    )
  }

  // Author
  place(
    top + left,
    dy: 56mm,
    dx: 27mm,
    text(10pt, weight: "light", author),
  )

  // Description, Degree and Program
  place(
    top + left,
    dy: 62mm,
    dx: 27mm,
    text(
      10pt,
      weight: "light",
      degree + " thesis in " + major + "  — " + submission-date.display("[month repr:long] [year]"),
    ),
  )

  // Image
  place(
    bottom + center,
    dy: 27mm,
    image("../assets/frontpage_full.svg", width: 216mm, height: 303mm),
  )
}
