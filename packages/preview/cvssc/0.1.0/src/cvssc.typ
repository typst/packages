#let cvssc = plugin("cvssc.wasm")

/// The First Organization url.
///
/// #example(`#cvssc.first`, mode: "markup")
#let first = "https://www.first.org/"
/// The First CVSS specification document urls. (2.0, 3.0, 3.1, 4.0)
///
/// #example(`#cvssc.specifications`, mode: "markup")
/// #example(`#cvssc.specifications.at("3.0")`, mode: "markup")
/// #example(```
/// #link(
///   cvssc.specifications.at("3.1"),
///   "CVSSv3.1 Specification"
/// )
/// ```, mode: "markup")
#let specifications = (
  "2.0": "https://www.first.org/cvss/v2/guide",
  "3.0": "https://www.first.org/cvss/v3.0/specification-document",
  "3.1": "https://www.first.org/cvss/v3.1/specification-document",
  "4.0": "https://www.first.org/cvss/v4.0/specification-document"
)
/// The version of this package.
///
/// #example(`#cvssc.version`, mode: "markup")
#let version = "0.1.0"

/// This function converts a CVSS string into a dictionary. The input must be a string in the format: `CVSS:([0-9.]+)/(.+)`
///
/// #example(`cvssc.str2vec("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N")`)
///
/// - s (string): The CVSS string to convert.
/// -> dictionary
#let str2vec(s) = {
  if type(s) != "string" {
    return ("error": "Input must be a string")
  }
  let re = regex("CVSS:([0-9.]+)/(.+)")
  let match = s.match(re)
  let version = match.at("captures", default: ("4.0",)).at(0)
  let metrics = match.at("captures", default: ("",)).at(1)
  let pairs = metrics.split("/")
  let result = pairs.fold((:), (c, it) => {
    let pair = it.split(":")
    let k = pair.at(0)
    let v = pair.at(1)
    c + ((k): v)
  })
  (version: version, metrics: result)
}


/// This function converts a CVSS dictionary into a string. The input must be a dictionary in the format: `(version: "version", metrics: (...))`
///
/// #example(```
/// cvssc.vec2str((
///   version: "3.0",
///   metrics: (
///     "AV": "N", "AC": "L",
///     "PR": "N", "UI": "N",
///     "S": "U",  "C": "N",
///     "I": "N", "A": "N"
///   )
/// ))```)
///
/// - vec (dictionary): The CVSS dictionary to convert.
/// -> string
#let vec2str(vec) = {
  let version = vec.at("version", default: "4.0")
  let metrics = vec.at("metrics", default: (:))
  let result = "CVSS:" + version + "/"
  result += metrics.pairs().map(it => {
    let (k, v) = it
    k + ":" + v
  }).join("/")
  result
}

/// This function converts a string from camelCase to kebab-case. The input must be a string.
///
/// #example(`cvssc.kebab-case("helloWorld")`)
///
/// - string (string): The string to convert.
/// -> string
#let kebab-case(string) = {
  import "@preview/t4t:0.3.2": assert
  if type(string) != "string" { return ("error": "Input must be a string") }
  string.codepoints().enumerate().fold((), (it, pair) => {
    let (i, c) = pair
    if c.match(regex("[A-Z]")) != none and i != 0 {
      it.push("-")
    }
    it + (lower(c),)
  }).join("")
}

/// This function converts the keys of a dictionary from camelCase to kebab-case. The input must be a dictionary.
///
/// #example(```
/// cvssc.kebabify-keys((
///   "somethingElse": "else",
///   "anotherThing": "thing",
///   "helloWorld": "world"
/// ))```)
///
/// - input (dictionary): The dictionary to convert.
/// -> dictionary
#let kebabify-keys(input) = {
  if type(input) != "dictionary" { return ("error": "Input must be a dictionary") }
  input.pairs().fold((:), (it, pair) => {
    let (k, v) = pair
    it + ((kebab-case(k)): v)
  })
}

/// This function extracts the version from a CVSS string. The input must be a string in the format: `CVSS:([0-9.]+)/(.+)`
///
/// #example(`cvssc.get-version("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N")`)
///
/// - input (string): The CVSS string.
/// -> string
#let get-version(input) = {
  if type(input) != "string" {
    return ("error": "Input must be a string")
  }
  let re = regex("CVSS:([0-9.]+)/(.+)")
  let match = input.match(re)
  let version = match.at("captures", default: ("4.0",)).at(0)
  version
}

/// This function calculates transforms a CVSS string or dictionary into a dictionary with various metrics, including the base score and severity. The input must be a valid CVSS string or dictionary. the format for the dictionary is (version: "2.0", metrics: (...))
///
/// #example(`cvssc.v2("CVSS:2.0/AV:L/AC:L/Au:N/C:C/I:C/A:C")`)
///
/// - vec (string): The CVSS string or dictionary to convert.
/// -> dictionary
#let v2(vec) = {
  if type(vec) == "dictionary" {
    vec = vec2str(vec)
  }
  if type(vec) != "string" {
    return ("error": "Input must be a string or a dictionary")
  }
  let result = cbor.decode(cvssc.v2(bytes(vec)))
  let metrics = str2vec(vec)

  result.insert("metrics", metrics.metrics)

  result = kebabify-keys(result)

  if result.at("error", default: none) != none {
    return result
  }
  if result.at("base-score", default: none) != none {
    result.insert("base-score", calc.round(result.at("base-score"), digits: 2))
    if result.at("base-score") < 4.0 {
      result.insert("base-severity", "LOW")
    } else if result.at("base-score") < 7.0 {
      result.insert("base-severity", "MEDIUM")
    } else {
      result.insert("base-severity", "HIGH")
    }
  }

  result.insert("specification-document", specifications.at(result.version, default: first))
  result
}

/// This function calculates transforms a CVSS string or dictionary into a dictionary with various metrics, including the base score and severity. The input must be a valid CVSS string or dictionary. the format for the dictionary is (version: "2.0", metrics: (...))
///
/// #example(`cvssc.v3("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N")`)
/// #example(`cvssc.v3("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N")`)
///
/// - vec (string): The CVSS string or dictionary to convert.
/// -> dictionary
#let v3(vec) = {
  if type(vec) == "dictionary" {
    vec = vec2str(vec)
  }
  if type(vec) != "string" {
    return ("error": "Input must be a string or a dictionary")
  }
  let result = cbor.decode(cvssc.v3(bytes(vec)))
  let metrics = str2vec(vec)

  result.insert("metrics", metrics.metrics)

  result = kebabify-keys(result)

  if result.at("error", default: none) != none {
    return result
  }
  if result.at("base-score", default: none) != none {
    result.insert("base-score", calc.round(result.at("base-score"), digits: 2))
  }

 result.insert("specification-document", specifications.at(result.version, default: first))
  result
}

/// This function calculates transforms a CVSS string or dictionary into a dictionary with various metrics, including the base score and severity. The input must be a valid CVSS string or dictionary. the format for the dictionary is (version: "2.0", metrics: (...))
///
/// #example(`cvssc.v4("CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:N/SC:N/SI:N/SA:N")`)
///
/// - vec (string): The CVSS string or dictionary to convert.
/// -> dictionary
#let v4(vec) = {
  if type(vec) == "dictionary" {
    vec = vec2str(vec)
  }
  if type(vec) != "string" {
    return ("error": "Input must be a string or a dictionary")
  }
  let result = cbor.decode(cvssc.v4(bytes(vec)))
  let metrics = str2vec(vec)

  result.insert("metrics", metrics.metrics)

  result = kebabify-keys(result)

  if result.at("error", default: none) != none {
    return result
  }
  if result.at("base-score", default: none) != none {
    result.insert("base-score", calc.round(result.at("base-score"), digits: 2))
  }

  result.insert("specification-document", specifications.at(result.version, default: first))
  result
}

/// This function calculates transforms a CVSS string or dictionary into a dictionary with various metrics, including the base score and severity. The input must be a valid CVSS string or dictionary. this function is a wrapper for the v2, v3, and v4 functions. and will automatically determine the version of the input.
///
/// #example(`cvssc.calc("CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:N/SC:N/SI:N/SA:N")`)
/// #example(```
/// cvssc.calc((
///   version: "3.1",
///   metrics: (
///     "AV": "N",
///     "AC": "L",
///     "PR": "N",
///     "UI": "N",
///     "S": "U",
///     "C": "N",
///     "I": "N",
///     "A": "N"
///   )
/// ))```)
///
/// - vec (string): The CVSS string or dictionary to convert.
/// -> dictionary
#let calc(vec) = {
  if type(vec) == "dictionary" { vec = vec2str(vec) }
  if type(vec) != "string" { return ("error": "Input must be a string or a dictionary") }
  if get-version(vec) == "2.0" { return v2(vec) }
  else if get-version(vec) == "3.0" { return v3(vec) }
  else if get-version(vec) == "3.1" { return v3(vec) }
  else if get-version(vec) == "4.0" { return v4(vec) }
  else { return ("error": "Invalid version") }
}

