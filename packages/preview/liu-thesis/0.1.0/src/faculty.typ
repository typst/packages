// Faculty data for graduate theses.

#let faculty-data = (
  lith: (
    faculty-name: "Institute of Technology",
    degree-prefix: "teknologie",
    series: "Linköping Studies in Science and Technology",
    issn: (
      lic: "0280-7971",
      phd: "0345-7524",
    ),
  ),
  filfak: (
    faculty-name: "Philosophical faculty",
    degree-prefix: "filosofie",
    series: "Linköping Studies in Arts and Sciences",
    issn: (
      lic: "1401-4637",
      phd: "0282-9800",
    ),
  ),
)

// Returns a dict with: series, degree-word, issn, faculty-name, degree-prefix.
// Handles the FilFak+lic special case where series becomes
// "Filosofiska fakulteten – FiF avhandling {number}".
#let get-faculty-data(faculty, level, thesis-number) = {
  let data = faculty-data.at(faculty)

  let series = if faculty == "filfak" and level == "lic" {
    "Filosofiska fakulteten – FiF avhandling " + thesis-number
  } else {
    data.series
  }

  let degree-word = if level == "phd" { "Dissertations," } else { "Licentiate Thesis" }

  (
    series: series,
    degree-word: degree-word,
    issn: data.issn.at(level),
    faculty-name: data.faculty-name,
    degree-prefix: data.degree-prefix,
  )
}

// Swedish degree type: "{prefix} {doktorsexamen|licentiatexamen}"
#let get-degree-type-swedish(degree-prefix, level) = {
  let suffix = if level == "phd" { "doktorsexamen" } else { "licentiatexamen" }
  degree-prefix + " " + suffix
}

// English degree type: "Doctor of {suffix}" or "Licentiate degree in {suffix}"
#let get-degree-type-english(level, degree-suffix) = {
  if level == "phd" {
    "Doctor of " + degree-suffix
  } else {
    "Licentiate degree in " + degree-suffix
  }
}
