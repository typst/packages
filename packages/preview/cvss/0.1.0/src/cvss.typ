#let _cvss = plugin("cvss.wasm")

/// Pseudo-constant representing the None severity.
///
///string: "None"
#let NONE = "None"
/// Pseudo-constant representing the Low severity.
///
/// string: "Low"
#let LOW = "Low"
/// Pseudo-constant representing the Medium severity.
///
/// string: "Medium"
#let MEDIUM = "Medium"
/// Pseudo-constant representing the High severity.
///
/// string: "High"
#let HIGH = "High"
/// Pseudo-constant representing the Critical severity.
///
/// string: "Critical"
#let CRITICAL = "Critical"

/// This array contains strings of the the accepted CVSS versions.
///
/// -> array: the accepted CVSS versions. ("4.0", "3.1", "3.0", "2.0")
#let VERSIONS = (
  "4.0",
  "3.1",
  "3.0",
  "2.0"
)

/// Regex pattern for the parsing the CVSS vector string.
///
/// *does not handle invalid metrics or invalid values*
/// E.g. "CVSS:3.1/ZZ:QQ/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H"
/// -> regex: the regex pattern.
#let re = regex("([A-Za-z]{1,3}):([A-Za-z]{1,11})")

/// This function verifies if the input string is a valid CVSS vector string.
///
/// Example:
/// ```typ
/// cvss.verify("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H")
/// ```
/// Output:
/// ```typ
/// true // or false
/// ```
///
/// - vec (string): the CVSS vector string.
/// -> bool: true if the input string is a valid CVSS vector string, false otherwise.
#let verify(vec) = {
  if type(vec) != "string" {
    panic("Expected a string")
  } else {
    return vec.starts-with(regex("CVSS:([0-9]+\\.[0-9]+)")) and vec.contains(re)
  }
}

/// This function calculates breaks down the CVSS vector string into a dictionary.
///
/// Example:
/// ```typ
/// cvss.metrics("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H")
/// ```
/// Output:
/// ```typ
/// (
///   "version": "3.1",
///   "AV": "N",
///   "AC": "L",
///   "PR": "N",
///   "UI": "N",
///   "S": "U",
///   "C": "N",
///   "I": "N",
///   "A": "H"
/// )
/// ```
///
/// - s (string): the CVSS vector string.
/// -> dictionary: the CVSS vector string as a dictionary.
#let metrics(s) = {
  let result = s.matches(re).fold((:), (acc, it) => {
    let (k, v) = it.captures
    acc + ((k): v)
  })
  if result.pairs().len() < 1 {
    panic("Failed to parse CVSS metrics check the input string")
  } else {
    // get version
    let version = s.match(regex("CVSS:([0-9]+\\.[0-9]+)"))
    if type(version) == "dictionary" {
      result = result + (("version"): version.captures.at(0))
    }
    result
  }
}

/// This function changes the CVSS vector dictionary into a string.
///
/// Example:
/// ```typ
/// cvss.dict2str((
///   "version": "3.1",
///   "AV": "N",
///   "AC": "L",
///   "PR": "N",
///   "UI": "N",
///   "S": "U",
///   "C": "N",
///   "I": "N",
///   "A": "H"
/// ))
/// ```
/// Output:
/// ```typ
/// "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H"
/// ```
///
/// - d (dictionary): the CVSS vector dictionary.
/// -> string: the CVSS vector dictionary as a string.
#let dict2str(d) = {
  if type(d) != "dictionary" {
    panic("Expected a dictionary")
  } else {
    if d.at("version", default: "4.0") not in VERSIONS  {
      panic("Invalid CVSS version")
    }
    "CVSS:" + d.at("version") + "/" + d.pairs().map(it => {
     if it.at(0) == "version" {
       return ""
     }
     str(it.at(0)) + ":" + str(it.at(1))
    }).join("/")

    // let pairs = d.pairs()
    // let pairs_str = pairs.map((k, v) => {
    //   k + ":" + v
    // })
    // "CVSS:" + version + "/" + pairs_str.join("/")
  }
}

/// This function changes the CVSS vector string into a dictionary.
///
/// Example:
/// ```typ
/// cvss.str2dict("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H")
/// ```
/// Output:
/// ```typ
/// (
///   "version": "3.1",
///   "AV": "N",
///   "AC": "L",
///   "PR": "N",
///   "UI": "N",
///   "S": "U",
///   "C": "N",
///   "I": "N",
///   "A": "H"
/// )
/// ```
///
/// - s (string): the CVSS vector string.
/// -> dictionary: the CVSS vector string as a dictionary.
#let str2dict(s) = {
  if type(s) != "string" {
    panic("Expected a string")
  } else {
    let result = s.matches(re).fold((:), (acc, it) => {
      let (k, v) = it.captures
      acc + ((k): v)
    })
    if result.pairs().len() < 1 {
      panic("Failed to parse CVSS metrics check the input string")
    } else {
      // get version
      let version = s.match(regex("CVSS:([0-9]+\\.[0-9]+)"))
      if type(version) == "dictionary" {
        result = result + (("version"): version.captures.at(0))
      }
      result
    }
  }
}

/// This function calculates the CVSS severity based on the CVSS vector string or dictionary.
///
/// Example:
/// ```typ
/// cvss.score("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H")
/// ```
/// Output:
/// ```typ
/// 7.5
/// ```
///
/// - vec (string|dictionary): the CVSS vector string.
/// -> float: the CVSS score.
#let score(vec) = {
  if type(vec) == "dictionary" {
    vec = dict2str(vec)
  }
  let result = str(_cvss.score(bytes(vec)))
                .match(regex("([0-9]+\\.[0-9]+)"))
  if type(result) == "dictionary" {
    float(result.captures.at(0))
  } else {
    panic("Failed to parse CVSS score check the input string")
  }
}

/// This function calculates the CVSS severity based on the CVSS vector string or dictionary.
///
/// Example:
/// ```typ
/// cvss.severity("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H")
/// ```
/// Output:
/// ```typ
/// "High"
/// ```
/// - vec (string|dictionary): the CVSS vector string.
/// - string: the CVSS severity.

#let severity(vec) = {
  if type(vec) == "dictionary" {
    vec = dict2str(vec)
  }
  let result = str(_cvss.severity(bytes(vec)))
                .match(regex("(None|Low|Medium|High|Critical)"))
  if type(result) == "dictionary" {
    result.captures.at(0)
  } else {
    panic("Failed to parse CVSS severity check the input string")
  }
}

/// This function calculates the CVSS severity, score and metrics based on the CVSS vector string or dictionary.
///
/// Example:
/// ```typ
/// cvss.parse("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H")
/// ```
/// Output:
/// ```typ
/// (
///   metrics: (
///     "version": "3.1",
///     "AV": "N",
///     "AC": "L",
///     "PR": "N",
///     "UI": "N",
///     "S": "U",
///     "C": "N",
///     "I": "N",
///     "A": "H"
///   ),
///   score: 7.5,
///   severity: "High"
/// )
/// ```
/// - vec (string|dictionary): the CVSS vector string.
/// - dictionary: the CVSS severity, score and metrics.
#let parse(vec) = {
  let m = metrics(vec)
  let s = score(vec)
  let sev = severity(vec)
  (
    metrics: m,
    score: s,
    severity: sev
  )
}
