#let cvss-lookup = json("cvss-lookup.json")
#let max-composed = json("max-composed.json")
#let max-severity = json("max-severity.json")
#let expected-metric-order = json("metrics.json")

#let required-base-metrics = (
  "AV",
  "AC",
  "AT",
  "PR",
  "UI",
  "VC",
  "VI",
  "VA",
  "SC",
  "SI",
  "SA",
)

#let default-cvss = (
  "AV": "N",
  "AC": "L",
  "AT": "N",
  "PR": "N",
  "UI": "N",
  "VC": "N",
  "VI": "N",
  "VA": "N",
  "SC": "N",
  "SI": "N",
  "SA": "N",
  "E": "X",
  "CR": "X",
  "IR": "X",
  "AR": "X",
  "MAV": "X",
  "MAC": "X",
  "MAT": "X",
  "MPR": "X",
  "MUI": "X",
  "MVC": "X",
  "MVI": "X",
  "MVA": "X",
  "MSC": "X",
  "MSI": "X",
  "MSA": "X",
  "S": "X",
  "AU": "X",
  "R": "X",
  "V": "X",
  "RE": "X",
  "U": "X",
)

#let severity-levels = (
  "AV": ("N": 0.0, "A": 0.1, "L": 0.2, "P": 0.3),
  "PR": ("N": 0.0, "L": 0.1, "H": 0.2),
  "UI": ("N": 0.0, "P": 0.1, "A": 0.2),
  "AC": ("L": 0.0, "H": 0.1),
  "AT": ("N": 0.0, "P": 0.1),
  "VC": ("H": 0.0, "L": 0.1, "N": 0.2),
  "VI": ("H": 0.0, "L": 0.1, "N": 0.2),
  "VA": ("H": 0.0, "L": 0.1, "N": 0.2),
  "SC": ("H": 0.1, "L": 0.2, "N": 0.3),
  "SI": ("S": 0.0, "H": 0.1, "L": 0.2, "N": 0.3),
  "SA": ("S": 0.0, "H": 0.1, "L": 0.2, "N": 0.3),
  "CR": ("H": 0.0, "M": 0.1, "L": 0.2),
  "IR": ("H": 0.0, "M": 0.1, "L": 0.2),
  "AR": ("H": 0.0, "M": 0.1, "L": 0.2),
)

#let ensure-required-base-metrics(seen, source-name) = {
  for metric in required-base-metrics {
    if not seen.contains(metric) {
      panic("Missing required base metric `" + metric + "` in CVSS " + source-name)
    }
  }
}

#let normalize-metric-key(raw-key) = {
  let key = upper(str(raw-key).trim())
  if key not in expected-metric-order {
    panic("Unknown CVSS metric `" + key + "`")
  }
  key
}

#let normalize-metric-value(metric, raw-value) = {
  let candidate = str(raw-value).trim()
  for allowed in expected-metric-order.at(metric) {
    if upper(allowed) == upper(candidate) {
      return allowed
    }
  }

  panic(
    "Invalid value `" + candidate + "` for metric `" + metric + "`; expected one of "
    + repr(expected-metric-order.at(metric))
  )
}

#let parse-cvss-vector(vector) = {
  let source = str(vector).trim()
  if source.starts-with("#") {
    source = source.slice(1)
  }

  let parts = source.split("/")
  if parts.len() == 0 or upper(parts.at(0)) != "CVSS:4.0" {
    panic("CVSS vector must start with `CVSS:4.0`")
  }

  let normalized = default-cvss + (:)
  let seen = ()

  for part in parts.slice(1) {
    let entry = part.trim()
    if entry == "" {
      continue
    }

    let pieces = entry.split(":")
    if pieces.len() != 2 {
      panic("Invalid CVSS vector segment `" + entry + "`")
    }

    let metric = normalize-metric-key(pieces.at(0))
    if seen.contains(metric) {
      panic("Duplicate metric `" + metric + "` in CVSS vector")
    }

    normalized.at(metric) = normalize-metric-value(metric, pieces.at(1))
    seen.push(metric)
  }

  ensure-required-base-metrics(seen, "vector")
  normalized
}

#let parse-cvss-object(cvss) = {
  let normalized = default-cvss + (:)
  let seen = ()

  for (raw-key, raw-value) in cvss {
    let metric = normalize-metric-key(raw-key)
    normalized.at(metric) = normalize-metric-value(metric, raw-value)
    if not seen.contains(metric) {
      seen.push(metric)
    }
  }

  ensure-required-base-metrics(seen, "dictionary")
  normalized
}

#let normalize-cvss(cvss) = {
  if type(cvss) == str {
    return parse-cvss-vector(cvss)
  }

  if type(cvss) == dictionary {
    return parse-cvss-object(cvss)
  }

  panic("calculate-cvss-score expects a CVSS vector string or dictionary input")
}

#let metric-value(cvss, metric) = {
  let selected = cvss.at(metric)

  if metric == "E" and selected == "X" {
    return "A"
  }

  if (metric == "CR" or metric == "IR" or metric == "AR") and selected == "X" {
    return "H"
  }

  let modified-metric = "M" + metric
  if modified-metric in cvss {
    let modified-selected = cvss.at(modified-metric)
    if modified-selected != "X" {
      return modified-selected
    }
  }

  selected
}

#let subtract-or-none(left, right) = {
  if right == none {
    return none
  }
  left - right
}

#let max-defined(left, right) = {
  if left == none {
    return right
  }
  if right == none {
    return left
  }
  if left > right {
    left
  } else {
    right
  }
}

#let get-eq-maxes(macro-vector-result, eq) = {
  max-composed.at("eq" + str(eq)).at(macro-vector-result.at(eq - 1))
}

#let extract-metric(metric, vector-fragment) = {
  for part in vector-fragment.split("/") {
    if part == "" {
      continue
    }

    let pieces = part.split(":")
    if pieces.len() == 2 and pieces.at(0) == metric {
      return pieces.at(1)
    }
  }

  panic("Metric `" + metric + "` not found in `" + vector-fragment + "`")
}

#let macro-vector(cvss) = {
  let eq1 = none
  if (
    metric-value(cvss, "AV") == "N"
    and metric-value(cvss, "PR") == "N"
    and metric-value(cvss, "UI") == "N"
  ) {
    eq1 = "0"
  } else if (
    (metric-value(cvss, "AV") == "N"
      or metric-value(cvss, "PR") == "N"
      or metric-value(cvss, "UI") == "N")
    and not (
      metric-value(cvss, "AV") == "N"
      and metric-value(cvss, "PR") == "N"
      and metric-value(cvss, "UI") == "N"
    )
    and metric-value(cvss, "AV") != "P"
  ) {
    eq1 = "1"
  } else {
    eq1 = "2"
  }

  let eq2 = if metric-value(cvss, "AC") == "L" and metric-value(cvss, "AT") == "N" {
    "0"
  } else {
    "1"
  }

  let eq3 = none
  if metric-value(cvss, "VC") == "H" and metric-value(cvss, "VI") == "H" {
    eq3 = "0"
  } else if (metric-value(cvss, "VC") == "H"
      or metric-value(cvss, "VI") == "H"
      or metric-value(cvss, "VA") == "H") {
    eq3 = "1"
  } else {
    eq3 = "2"
  }

  let eq4 = none
  if metric-value(cvss, "MSI") == "S" or metric-value(cvss, "MSA") == "S" {
    eq4 = "0"
  } else if (
    metric-value(cvss, "SC") == "H"
    or metric-value(cvss, "SI") == "H"
    or metric-value(cvss, "SA") == "H"
  ) {
    eq4 = "1"
  } else {
    eq4 = "2"
  }

  let eq5 = none
  if metric-value(cvss, "E") == "A" {
    eq5 = "0"
  } else if metric-value(cvss, "E") == "P" {
    eq5 = "1"
  } else {
    eq5 = "2"
  }

  let eq6 = if (
    (metric-value(cvss, "CR") == "H" and metric-value(cvss, "VC") == "H")
    or (metric-value(cvss, "IR") == "H" and metric-value(cvss, "VI") == "H")
    or (metric-value(cvss, "AR") == "H" and metric-value(cvss, "VA") == "H")
  ) {
    "0"
  } else {
    "1"
  }

  eq1 + eq2 + eq3 + eq4 + eq5 + eq6
}

#let score-cvss(cvss, macro-vector-result) = {
  if (
    metric-value(cvss, "VC") == "N"
    and metric-value(cvss, "VI") == "N"
    and metric-value(cvss, "VA") == "N"
    and metric-value(cvss, "SC") == "N"
    and metric-value(cvss, "SI") == "N"
    and metric-value(cvss, "SA") == "N"
  ) {
    return 0.0
  }

  let value = cvss-lookup.at(macro-vector-result, default: none)
  if value == none {
    panic("No CVSS lookup value found for macro vector `" + macro-vector-result + "`")
  }

  let eq1 = macro-vector-result.at(0)
  let eq2 = macro-vector-result.at(1)
  let eq3 = macro-vector-result.at(2)
  let eq4 = macro-vector-result.at(3)
  let eq5 = macro-vector-result.at(4)
  let eq6 = macro-vector-result.at(5)

  let eq1-next-lower-macro = (
    str(int(eq1) + 1) + eq2 + eq3 + eq4 + eq5 + eq6
  )
  let eq2-next-lower-macro = (
    eq1 + str(int(eq2) + 1) + eq3 + eq4 + eq5 + eq6
  )

  let eq3eq6-next-lower-macro = none
  let eq3eq6-next-lower-macro-left = none
  let eq3eq6-next-lower-macro-right = none

  if eq3 == "1" and eq6 == "1" {
    eq3eq6-next-lower-macro = (
      eq1 + eq2 + str(int(eq3) + 1) + eq4 + eq5 + eq6
    )
  } else if eq3 == "0" and eq6 == "1" {
    eq3eq6-next-lower-macro = (
      eq1 + eq2 + str(int(eq3) + 1) + eq4 + eq5 + eq6
    )
  } else if eq3 == "1" and eq6 == "0" {
    eq3eq6-next-lower-macro = (
      eq1 + eq2 + eq3 + eq4 + eq5 + str(int(eq6) + 1)
    )
  } else if eq3 == "0" and eq6 == "0" {
    eq3eq6-next-lower-macro-left = (
      eq1 + eq2 + eq3 + eq4 + eq5 + str(int(eq6) + 1)
    )
    eq3eq6-next-lower-macro-right = (
      eq1 + eq2 + str(int(eq3) + 1) + eq4 + eq5 + eq6
    )
  } else {
    eq3eq6-next-lower-macro = (
      eq1 + eq2 + str(int(eq3) + 1) + eq4 + eq5 + str(int(eq6) + 1)
    )
  }

  let eq4-next-lower-macro = (
    eq1 + eq2 + eq3 + str(int(eq4) + 1) + eq5 + eq6
  )
  let eq5-next-lower-macro = (
    eq1 + eq2 + eq3 + eq4 + str(int(eq5) + 1) + eq6
  )

  let score-eq1-next-lower-macro = (
    cvss-lookup.at(eq1-next-lower-macro, default: none)
  )
  let score-eq2-next-lower-macro = (
    cvss-lookup.at(eq2-next-lower-macro, default: none)
  )
  let score-eq3eq6-next-lower-macro = none
  if eq3 == "0" and eq6 == "0" {
    let left = cvss-lookup.at(eq3eq6-next-lower-macro-left, default: none)
    let right = cvss-lookup.at(eq3eq6-next-lower-macro-right, default: none)
    score-eq3eq6-next-lower-macro = max-defined(left, right)
  } else {
    score-eq3eq6-next-lower-macro = (
      cvss-lookup.at(eq3eq6-next-lower-macro, default: none)
    )
  }
  let score-eq4-next-lower-macro = (
    cvss-lookup.at(eq4-next-lower-macro, default: none)
  )
  let score-eq5-next-lower-macro = (
    cvss-lookup.at(eq5-next-lower-macro, default: none)
  )

  let eq1-maxes = get-eq-maxes(macro-vector-result, 1)
  let eq2-maxes = get-eq-maxes(macro-vector-result, 2)
  let eq3eq6-maxes = get-eq-maxes(macro-vector-result, 3).at(eq6)
  let eq4-maxes = get-eq-maxes(macro-vector-result, 4)
  let eq5-maxes = get-eq-maxes(macro-vector-result, 5)

  let max-vectors = ()
  for eq1-max in eq1-maxes {
    for eq2-max in eq2-maxes {
      for eq3eq6-max in eq3eq6-maxes {
        for eq4-max in eq4-maxes {
          for eq5-max in eq5-maxes {
            max-vectors.push(
              eq1-max + eq2-max + eq3eq6-max + eq4-max + eq5-max
            )
          }
        }
      }
    }
  }

  let severity-distance-av = none
  let severity-distance-pr = none
  let severity-distance-ui = none
  let severity-distance-ac = none
  let severity-distance-at = none
  let severity-distance-vc = none
  let severity-distance-vi = none
  let severity-distance-va = none
  let severity-distance-sc = none
  let severity-distance-si = none
  let severity-distance-sa = none
  let severity-distance-cr = none
  let severity-distance-ir = none
  let severity-distance-ar = none

  let chosen-max-vector = none
  for max-vector in max-vectors {
    severity-distance-av = (
      severity-levels.at("AV").at(metric-value(cvss, "AV"))
      - severity-levels.at("AV").at(extract-metric("AV", max-vector))
    )
    severity-distance-pr = (
      severity-levels.at("PR").at(metric-value(cvss, "PR"))
      - severity-levels.at("PR").at(extract-metric("PR", max-vector))
    )
    severity-distance-ui = (
      severity-levels.at("UI").at(metric-value(cvss, "UI"))
      - severity-levels.at("UI").at(extract-metric("UI", max-vector))
    )

    severity-distance-ac = (
      severity-levels.at("AC").at(metric-value(cvss, "AC"))
      - severity-levels.at("AC").at(extract-metric("AC", max-vector))
    )
    severity-distance-at = (
      severity-levels.at("AT").at(metric-value(cvss, "AT"))
      - severity-levels.at("AT").at(extract-metric("AT", max-vector))
    )

    severity-distance-vc = (
      severity-levels.at("VC").at(metric-value(cvss, "VC"))
      - severity-levels.at("VC").at(extract-metric("VC", max-vector))
    )
    severity-distance-vi = (
      severity-levels.at("VI").at(metric-value(cvss, "VI"))
      - severity-levels.at("VI").at(extract-metric("VI", max-vector))
    )
    severity-distance-va = (
      severity-levels.at("VA").at(metric-value(cvss, "VA"))
      - severity-levels.at("VA").at(extract-metric("VA", max-vector))
    )

    severity-distance-sc = (
      severity-levels.at("SC").at(metric-value(cvss, "SC"))
      - severity-levels.at("SC").at(extract-metric("SC", max-vector))
    )
    severity-distance-si = (
      severity-levels.at("SI").at(metric-value(cvss, "SI"))
      - severity-levels.at("SI").at(extract-metric("SI", max-vector))
    )
    severity-distance-sa = (
      severity-levels.at("SA").at(metric-value(cvss, "SA"))
      - severity-levels.at("SA").at(extract-metric("SA", max-vector))
    )

    severity-distance-cr = (
      severity-levels.at("CR").at(metric-value(cvss, "CR"))
      - severity-levels.at("CR").at(extract-metric("CR", max-vector))
    )
    severity-distance-ir = (
      severity-levels.at("IR").at(metric-value(cvss, "IR"))
      - severity-levels.at("IR").at(extract-metric("IR", max-vector))
    )
    severity-distance-ar = (
      severity-levels.at("AR").at(metric-value(cvss, "AR"))
      - severity-levels.at("AR").at(extract-metric("AR", max-vector))
    )

    if (
      severity-distance-av < 0
      or severity-distance-pr < 0
      or severity-distance-ui < 0
      or severity-distance-ac < 0
      or severity-distance-at < 0
      or severity-distance-vc < 0
      or severity-distance-vi < 0
      or severity-distance-va < 0
      or severity-distance-sc < 0
      or severity-distance-si < 0
      or severity-distance-sa < 0
      or severity-distance-cr < 0
      or severity-distance-ir < 0
      or severity-distance-ar < 0
    ) {
      continue
    }

    chosen-max-vector = max-vector
    break
  }

  if chosen-max-vector == none {
    panic("Unable to find a matching maximum vector for CVSS calculation")
  }

  let current-severity-distance-eq1 = (
    severity-distance-av + severity-distance-pr + severity-distance-ui
  )
  let current-severity-distance-eq2 = (
    severity-distance-ac + severity-distance-at
  )
  let current-severity-distance-eq3eq6 = (
    severity-distance-vc
    + severity-distance-vi
    + severity-distance-va
    + severity-distance-cr
    + severity-distance-ir
    + severity-distance-ar
  )
  let current-severity-distance-eq4 = (
    severity-distance-sc + severity-distance-si + severity-distance-sa
  )
  let current-severity-distance-eq5 = 0

  let step = 0.1
  let available-distance-eq1 = subtract-or-none(value, score-eq1-next-lower-macro)
  let available-distance-eq2 = subtract-or-none(value, score-eq2-next-lower-macro)
  let available-distance-eq3eq6 = (
    subtract-or-none(value, score-eq3eq6-next-lower-macro)
  )
  let available-distance-eq4 = subtract-or-none(value, score-eq4-next-lower-macro)
  let available-distance-eq5 = subtract-or-none(value, score-eq5-next-lower-macro)

  let n-existing-lower = 0
  let normalized-severity-eq1 = 0
  let normalized-severity-eq2 = 0
  let normalized-severity-eq3eq6 = 0
  let normalized-severity-eq4 = 0
  let normalized-severity-eq5 = 0

  let max-severity-eq1 = max-severity.at("eq1").at(eq1) * step
  let max-severity-eq2 = max-severity.at("eq2").at(eq2) * step
  let max-severity-eq3eq6 = max-severity.at("eq3eq6").at(eq3).at(eq6) * step
  let max-severity-eq4 = max-severity.at("eq4").at(eq4) * step

  if available-distance-eq1 != none {
    n-existing-lower += 1
    normalized-severity-eq1 = (
      available-distance-eq1 * (current-severity-distance-eq1 / max-severity-eq1)
    )
  }

  if available-distance-eq2 != none {
    n-existing-lower += 1
    normalized-severity-eq2 = (
      available-distance-eq2 * (current-severity-distance-eq2 / max-severity-eq2)
    )
  }

  if available-distance-eq3eq6 != none {
    n-existing-lower += 1
    normalized-severity-eq3eq6 = (
      available-distance-eq3eq6
      * (current-severity-distance-eq3eq6 / max-severity-eq3eq6)
    )
  }

  if available-distance-eq4 != none {
    n-existing-lower += 1
    normalized-severity-eq4 = (
      available-distance-eq4 * (current-severity-distance-eq4 / max-severity-eq4)
    )
  }

  if available-distance-eq5 != none {
    n-existing-lower += 1
    normalized-severity-eq5 = 0
  }

  let mean-distance = if n-existing-lower == 0 {
    0
  } else {
    (
      normalized-severity-eq1
      + normalized-severity-eq2
      + normalized-severity-eq3eq6
      + normalized-severity-eq4
      + normalized-severity-eq5
    ) / n-existing-lower
  }

  value -= mean-distance
  if value < 0 {
    value = 0.0
  }
  if value > 10 {
    value = 10.0
  }

  calc.round(value * 10) / 10
}

#let calculate-cvss-score(cvss) = {
  let selected = normalize-cvss(cvss)
  let macro-vector-result = macro-vector(selected)
  score-cvss(selected, macro-vector-result)
}

#let get-cvss-score-severity(cvss-score) = {
  if cvss-score >= 9.0 {
    "Critical"
  } else if cvss-score >= 7.0 {
    "High"
  } else if cvss-score >= 4.0 {
    "Medium"
  } else if cvss-score > 0 {
    "Low"
  } else {
    "Informational"
  }
}

#let calculate-cvss-severity(cvss) = {
  get-cvss-score-severity(calculate-cvss-score(cvss))
}