#let _prefix-csv(path, delimiter: ",") = {
  /// Load a CSV file with pre- or postfixes.
  /// - `path`: Path of the CSV file.
  /// - `delimiter`: Passed to the `csv` function.

  let array = csv(path, delimiter: delimiter)
  let symbols = (:)
  let symbols-short = (:)

  for line in array {
    symbols.insert(lower(line.at(0)), line.at(2))
    symbols-short.insert(line.at(1), line.at(2))
  }
  (symbols, symbols-short)
}

#let _postfix-csv(path, delimiter: ",") = {
  /// Load a CSV file with pre- or postfixes.
  /// - `path`: Path of the CSV file.
  /// - `delimiter`: Passed to the `csv` function.

  let array = csv(path, delimiter: delimiter)
  let dict = (:)

  for line in array {
    dict.insert(lower(line.at(0)), line.at(1))
  }
  dict
}

#let _unit-csv(path, delimiter: ",") = {
  /// Load a CSV file with units.
  /// - `path`: Path of the CSV file.
  /// - `delimiter`: Passed to the `csv` function.

  let array = csv(path, delimiter: delimiter)
  let units = (:)
  let units-short = (:)
  let units-space = (:)
  let units-short-space = (:)

  for line in array {
    units.insert(lower(line.at(0)), line.at(2))
    units-short.insert(line.at(1), line.at(2))
    if line.at(3) == "false" or line.at(3) == "0" {
      units-space.insert(lower(line.at(0)), false)
      units-short-space.insert(line.at(1), false)
    } else {
      units-space.insert(lower(line.at(0)), true)
      units-short-space.insert(line.at(1), true)
    }
  }

  (units, units-short, units-space, units-short-space)
}

#let _postfixes = _postfix-csv("postfixes.csv")

#let _add-money-units(data) = {
  let (units, units-short, units-space, units-short-space) = data

  let array = csv("money.csv", delimiter: ",")
  for line in array {
    units.insert(lower(line.at(0)), line.at(2))
    units-short.insert(line.at(1), line.at(2))
    if line.at(3) == "false" or line.at(3) == "0" {
      units-space.insert(lower(line.at(0)), false)
      units-short-space.insert(line.at(1), false)
    } else {
      units-space.insert(lower(line.at(0)), true)
      units-short-space.insert(line.at(1), true)
    }
  }

  (units, units-short, units-space, units-short-space)
}

#let _lang-db = state(
  "lang-db",
  (
    "en": (
      "units": (_add-money-units(_unit-csv("units-en.csv"))),
      "prefixes": (_prefix-csv("prefixes-en.csv")),
    ),
    "ru": (
      "units": (_add-money-units(_unit-csv("units-ru.csv"))),
      "prefixes": (_prefix-csv("prefixes-ru.csv")),
    ),
  ),
)

#let _get-language() = {
  let lang = text.lang
  let data = _lang-db.get()
  if lang in data {
    lang
  } else {
    "en"
  }
}

// get prefixes
#let _prefixes() = {
  let lang = text.lang
  let data = _lang-db.get()
  if lang in data {
    data.at(lang).prefixes
  } else {
    data.en.prefixes
  }
}

// get units
#let _units() = {
  let lang = text.lang
  let data = _lang-db.get()

  if lang in data {
    data.at(lang).units
  } else {
    data.en.units
  }
}
