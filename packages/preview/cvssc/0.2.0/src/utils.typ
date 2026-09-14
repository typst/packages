// CVSS Utility Functions

#import "v3/components.typ": *

// Find component by short name
#let find-component(short-name) = {
  for comp in all-components {
    if comp.short == short-name {
      return comp
    }
  }
  none
}

// Find value in component by short name
#let find-value(component, value-short) = {
  for (key, val) in component.values {
    if val.short == value-short {
      return val
    }
  }
  none
}

/// Convert string from camelCase to kebab-case
///
/// #example(`kebab-case("helloWorld")`)
///
/// - string (string): The string to convert
/// -> string
#let kebab-case(string) = {
  if type(string) != str { return ("error": "Input must be a string") }
  string
    .codepoints()
    .enumerate()
    .fold(
      (),
      (it, pair) => {
        let (i, c) = pair
        if c.match(regex("[A-Z]")) != none and i != 0 {
          it.push("-")
        }
        it + (lower(c),)
      },
    )
    .join("")
}

/// Convert dictionary keys from camelCase to kebab-case
///
/// #example(```
/// kebabify-keys((
///   "somethingElse": "else",
///   "anotherThing": "thing",
///   "helloWorld": "world"
/// ))```)
///
/// - input (dictionary): The dictionary to convert
/// -> dictionary
#let kebabify-keys(input) = {
  if type(input) != dictionary { return ("error": "Input must be a dictionary") }
  input
    .pairs()
    .fold(
      (:),
      (it, pair) => {
        let (k, v) = pair
        it + ((kebab-case(k)): v)
      },
    )
}

/// Convert CVSS string to dictionary with version and metrics
///
/// #example(`str2vec("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H")`)
///
/// - s (string): The CVSS string to convert
/// -> dictionary
#let str2vec(s) = {
  if type(s) != str {
    return ("error": "Input must be a string")
  }
  let re = regex("CVSS:([0-9.]+)/(.+)")
  let match = s.match(re)
  if match == none {
    return ("error": "Invalid CVSS string format")
  }
  let version = match.at("captures", default: ("4.0",)).at(0)
  let metrics-str = match.at("captures", default: ("",)).at(1)
  let pairs = metrics-str.split("/")
  let result = pairs.fold(
    (:),
    (c, it) => {
      let pair = it.split(":")
      if pair.len() != 2 { return c }
      let k = pair.at(0)
      let v = pair.at(1)
      c + ((k): v)
    },
  )
  (version: version, metrics: result)
}

/// Convert CVSS dictionary to string
///
/// #example(```
/// vec2str((
///   version: "3.1",
///   metrics: (
///     "AV": "N", "AC": "L",
///     "PR": "N", "UI": "N",
///     "S": "U",  "C": "H",
///     "I": "H", "A": "H"
///   )
/// ))```)
///
/// - vec (dictionary): The CVSS dictionary to convert
/// -> string
#let vec2str(vec) = {
  let version = vec.at("version", default: "4.0")
  let metrics = vec.at("metrics", default: (:))
  let result = "CVSS:" + version + "/"
  result += metrics
    .pairs()
    .map(it => {
      let (k, v) = it
      k + ":" + v
    })
    .join("/")
  result
}

/// Extract version from CVSS string
///
/// #example(`get-version("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H")`)
///
/// - input (string): The CVSS string
/// -> string
#let get-version(input) = {
  if type(input) != str {
    return ("error": "Input must be a string")
  }
  let re = regex("CVSS:([0-9.]+)/(.+)")
  let match = input.match(re)
  if match == none {
    return "4.0"
  }
  let version = match.at("captures", default: ("4.0",)).at(0)
  version
}

// Parse CVSS vector string to metrics dictionary (internal use)
#let parse-vector(vector-string) = {
  // Use str2vec to parse
  let parsed = str2vec(vector-string)
  if parsed.at("error", default: none) != none {
    return (:)
  }

  let metrics-dict = (:)
  let metrics = parsed.at("metrics", default: (:))

  for (metric-name, metric-value) in metrics {
    let component = find-component(metric-name)
    if component == none {
      continue
    }

    let value = find-value(component, metric-value)
    if value != none {
      metrics-dict.insert(metric-name, value)
    }
  }

  metrics-dict
}

// Convert metrics dictionary back to vector string
#let metrics-to-vector(metrics, prefix: "CVSS:3.1/") = {
  let parts = ()
  
  // Base metrics
  for comp in base-components {
    let val = metrics.at(comp.short, default: none)
    if val != none and val.short != "X" {
      parts.push(comp.short + ":" + val.short)
    }
  }
  
  // Temporal metrics
  for comp in temporal-components {
    let val = metrics.at(comp.short, default: none)
    if val != none and val.short != "X" {
      parts.push(comp.short + ":" + val.short)
    }
  }
  
  // Environmental metrics
  for comp in environmental-components {
    let val = metrics.at(comp.short, default: none)
    if val != none and val.short != "X" {
      parts.push(comp.short + ":" + val.short)
    }
  }
  
  prefix + parts.join("/")
}

// Validate that base metrics are defined
#let is-base-defined(metrics) = {
  let required = ("AV", "AC", "PR", "UI", "S", "C", "I", "A")
  for key in required {
    let val = metrics.at(key, default: none)
    if val == none or val.short == "X" {
      return false
    }
  }
  true
}

// Get color for severity level
#let severity-color(severity) = {
  if severity == "NONE" or severity == "none" {
    rgb("#94a3b8")  // Gray
  } else if severity == "LOW" or severity == "low" {
    rgb("#fbbf24")  // Yellow
  } else if severity == "MEDIUM" or severity == "medium" {
    rgb("#fb923c")  // Orange
  } else if severity == "HIGH" or severity == "high" {
    rgb("#f87171")  // Red
  } else {  // CRITICAL
    rgb("#dc2626")  // Dark red
  }
}

// CVSS specification document URLs
#let specifications = (
  "2.0": "https://www.first.org/cvss/v2/guide",
  "3.0": "https://www.first.org/cvss/v3.0/specification-document",
  "3.1": "https://www.first.org/cvss/v3.1/specification-document",
  "4.0": "https://www.first.org/cvss/v4.0/specification-document",
)
