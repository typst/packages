#let _cvss = plugin("cvss.wasm")

#let score(vec) = float(str(_cvss.score(bytes(vec))))

#let NONE = "None"
#let LOW = "Low"
#let MEDIUM = "Medium"
#let HIGH = "High"
#let CRITICAL = "Critical"

// #let test-string = "CVSS:4.0/AV:A/AC:H/AT:P/PR:L/UI:P/VC:L/VI:L/VA:L/SC:L/SI:L/SA:L/E:A/CR:L/IR:L/AR:L/MAV:N/MAC:L/MAT:N/MPR:N/MUI:N/MVC:H/MVI:H/MVA:H/MSC:L/MSI:L/MSA:L/S:N/AU:N/R:A/V:D/RE:L/U:Clear"

#let re = regex("([A-Za-z]{1,3}):([A-Za-z]{1,11})")

#let verify(vec) = {
  if type(vec) != "string" {
    panic("Expected a string")
  } else {
    return vec.starts-with(regex("CVSS:([0-9]+\\.[0-9]+)")) and vec.contains(re)
  }
}

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

#let score(vec) = {
  let result = str(_cvss.score(bytes(vec)))
                .match(regex("([0-9]+\\.[0-9]+)"))
  if type(result) == "dictionary" {
    float(result.captures.at(0))
  } else {
    panic("Failed to parse CVSS score check the input string")
  }
}
#let severity(vec) = {
  let result = str(_cvss.severity(bytes(vec)))
                .match(regex("(None|Low|Medium|High|Critical)"))
  if type(result) == "dictionary" {
    result.captures.at(0)
  } else {
    panic("Failed to parse CVSS severity check the input string")
  }
}

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
