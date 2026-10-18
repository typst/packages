#let study-name = (
  IFB: "Informatik Bachelor",
  IGM: "Informatik Master",
  DCB: "Data Science Bachelor",
  ICB: "Scientific Computing Bachelor",
  ITM: "IT-Sicherheit Master",
  ISM: "Stochastic Engineering in Business and Finance",
  IBB: "Wirtschaftsinformaik Bachelor",
  WDB: "Wirtschaftsinformatik - Digitales Management Bachelor",
  WTB: "Wirtschaftsinformatik - Informationstechnologie Bachelor",
  INM: "Wirtschaftsinformatik Master",
  IDB: "Informatik und Design Bachelor",
  DEB: "Digital Engineering Bachelor",
  GSB: "Geodata Science Bachelor",
)

#let study-info = (
  IFB: (
    fk: "07",
    name: "IF",
    degree: "BSc",
  ),
  IGM: (
    fk: "07",
    name: "IF",
    degree: "MSc",
  ),
  DCB: (
    fk: "07",
    name: "Data Science & Scientific Computing",
    degree: "BSc",
  ),
  ICB: (
    fk: "07",
    name: "Scientific Computing",
    degree: "BSc",
  ),
  ITM: (
    fk: "07",
    name: "IT-Sicherheit",
    degree: "MSc",
  ),
  ISM: (
    fk: "07",
    name: "Stochastic Engineering in Business and Finance",
    degree: "MSc",
  ),
  IBB: (
    fk: "07",
    name: "WI",
    degree: "BSc",
  ),
  WDB: (
    fk: "07",
    name: "Wirtschaftsinformatik - Digitales Management",
    degree: "BSc",
  ),
  WTB: (
    fk: "07",
    name: "Wirtschaftsinformatik - Informationstechnologie",
    degree: "BSc",
  ),
  INM: (
    fk: "07",
    name: "WI",
    degree: "MSc",
  ),
  IDB: (
    fk: "21",
    name: "Informatik und Design",
    degree: "BSc",
  ),
  DEB: (
    fk: "21",
    name: "Digital Enginerring",
    degree: "BSc",
  ),
  GSB: (
    fk: "21",
    name: "Geodata Science",
    degree: "BSc",
  ),
)

#let fk = (
  "07": "Fakultät für Informatik und Mathematik",
  "21": "Munich Center for Digital Sciences and AI",
)

#let degree = (
  "BSc": "Bachelor of Science",
  "MSc": "Master of Science",
)

#let study-name-long = (
  "IF": "Informatik",
  "WI": "Wirtschaftsinformatik",
)

#let thesis-type = (
  "B": "Bachelorarbeit",
  "M": "Masterarbeit",
)

#let get-study-info(name) = {
  let key = study-name.keys().at(study-name.values().position(x => x == name))
  if key in study-name {
    let info = study-info.at(key)

    return (
      fk: fk.at(info.fk),
      name: study-name-long.at(info.name, default: info.name),
      degree: degree.at(info.degree),
      thesis-type: thesis-type.at(info.degree.at(0)),
    )
  }
}
