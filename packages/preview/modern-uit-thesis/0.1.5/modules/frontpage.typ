#let frontpage(
  title: [],
  subtitle: "",
  author: "",
  degree: "",
  faculty: "",
  department: "",
  major: "",
  date: none,
) = {
  set document(title: title, author: author)
  page(
    paper: "a4",
    margin: (left: 3mm, right: 3mm, top: 12mm, bottom: 27mm),
    header: none,
    footer: none,
    numbering: none,
    number-align: center,
    [
      #set text(font: ("Open Sans", "Noto Sans"))
      #place(top + left, image("../assets/logo.svg", width: 100%, height: 100%))
      // NOTE: We use negative alignment from the bottom here to align with the cover page svg
      // (rather than the top) in the event of the title breaking to a new line
      #place(
        bottom + left,
        dy: -192mm,
        dx: 27mm,
        box(
          width: 80%,
          stack(
            spacing: 1.5em,
            stack(
              spacing: .5em,
              text(12pt, weight: "light", faculty),
              text(12pt, weight: "light", department),
            ),
            text(14pt, weight: "semibold", title),
            if (subtitle != "") {
              text(12pt, weight: "light", subtitle)
            },
            stack(
              spacing: .75em,
              text(10pt, weight: "light", author),
              text(
                10pt,
                weight: "light",
                degree
                  + " thesis in "
                  + major
                  + "  — "
                  + date.display("[month repr:long] [year]"),
              ),
            ),
          ),
        ),
      )

      #place(
        bottom + center,
        dy: 27mm,
        image("../assets/frontpage_full.svg", width: 216mm, height: 303mm),
      )
    ],
  )
}
