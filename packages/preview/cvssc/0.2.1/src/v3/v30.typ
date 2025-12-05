// CVSS 3.0 Calculator
// Implementation of CVSS v3.0 scoring formulas
//
// IMPORTANT: CVSS 3.0 and 3.1 differ ONLY in the Modified Impact Score calculation
// for Environmental scoring. The formula change affects the exponent applied to MISS.

#import "components.typ": *

// Constants (identical to 3.1)
#let scope-changed-factor = 7.52
#let scope-unchanged-factor = 6.42
#let exploitability-coef = 8.22
#let scope-coef = 1.08

// Utility functions
#let round-up(value) = {
  let input = calc.round(value * 100000)
  if calc.rem(input, 10000) == 0 {
    input / 100000.0
  } else {
    (calc.floor(input / 10000) + 1) / 10.0
  }
}

#let round(value, precision) = {
  let scale = calc.pow(10, precision)
  calc.round(value * scale) / scale
}

// Helper function to find component by short name
#let find-component(short-name) = {
  for comp in all-components {
    if comp.short == short-name {
      return comp
    }
  }
  none
}

// Helper function to find value in component by short name
#let find-value(component, value-short) = {
  for (key, val) in component.values {
    if val.short == value-short {
      return val
    }
  }
  none
}

// Parse CVSS vector string to metrics dictionary
#let parse-vector(vector-string) = {
  // Normalize vector string
  let normalized = vector-string
    .replace("CVSS:3.1/", "")
    .replace("CVSS:3.0/", "")
    .replace("CVSS:", "")
    .trim()

  // Split into parts
  let parts = normalized.split("/")
  let metrics = (:)

  for part in parts {
    if part == "" {
      continue
    }

    let components = part.split(":")
    if components.len() != 2 {
      continue
    }

    let metric-name = components.at(0)
    let metric-value = components.at(1)

    let component = find-component(metric-name)
    if component == none {
      continue
    }

    let value = find-value(component, metric-value)
    if value != none {
      metrics.insert(metric-name, value)
    }
  }

  metrics
}

// Calculate ISS (Impact Sub-Score) - identical to 3.1
#let calculate-iss(conf, integ, avail) = {
  1 - ((1 - conf) * (1 - integ) * (1 - avail))
}

// Calculate Impact Score - identical to 3.1
#let calculate-impact(iss, scope-changed) = {
  if scope-changed {
    scope-changed-factor * (iss - 0.029) - 3.25 * calc.pow(iss - 0.02, 15)
  } else {
    scope-unchanged-factor * iss
  }
}

// Calculate Exploitability Score - identical to 3.1
#let calculate-exploitability(av-val, ac-val, pr-val, ui-val, scope-changed) = {
  let pr-value = if scope-changed {
    pr-val.changed
  } else {
    pr-val.value
  }

  exploitability-coef * av-val * ac-val * pr-value * ui-val
}

// Calculate Base Score - identical to 3.1
#let calculate-base-score(metrics) = {
  let av-val = metrics.at("AV", default: av.values.X).value
  let ac-val = metrics.at("AC", default: ac.values.X).value
  let pr-val = metrics.at("PR", default: pr.values.X)
  let ui-val = metrics.at("UI", default: ui.values.X).value
  let s-val = metrics.at("S", default: s.values.X).value
  let c-val = metrics.at("C", default: c.values.X).value
  let i-val = metrics.at("I", default: i.values.X).value
  let a-val = metrics.at("A", default: a.values.X).value

  // Check if base metrics are defined
  if av-val == 1.0 or ac-val == 1.0 {
    return none
  }

  let iss = calculate-iss(c-val, i-val, a-val)
  let impact = calculate-impact(iss, s-val)

  if impact <= 0 {
    return 0.0
  }

  let exploitability = calculate-exploitability(av-val, ac-val, pr-val, ui-val, s-val)

  let score = if s-val {
    calc.min(scope-coef * (impact + exploitability), 10)
  } else {
    calc.min(impact + exploitability, 10)
  }

  round-up(score)
}

// Calculate Temporal Score - identical to 3.1
#let calculate-temporal-score(metrics, base-score) = {
  if base-score == none or base-score == 0 {
    return none
  }

  let e-val = metrics.at("E", default: e.values.X).value
  let rl-val = metrics.at("RL", default: rl.values.X).value
  let rc-val = metrics.at("RC", default: rc.values.X).value

  // Check if any temporal metric is defined
  if e-val == 1.0 and rl-val == 1.0 and rc-val == 1.0 {
    return none
  }

  round-up(base-score * e-val * rl-val * rc-val)
}

// Calculate Modified ISS - identical to 3.1
#let calculate-miss(metrics) = {
  let mc-val = metrics.at("MC", default: none)
  let mi-val = metrics.at("MI", default: none)
  let ma-val = metrics.at("MA", default: none)

  let c-val = metrics.at("C", default: c.values.X).value
  let i-val = metrics.at("I", default: i.values.X).value
  let a-val = metrics.at("A", default: a.values.X).value

  let cr-val = metrics.at("CR", default: cr.values.X).value
  let ir-val = metrics.at("IR", default: ir.values.X).value
  let ar-val = metrics.at("AR", default: ar.values.X).value

  let mci = if mc-val != none and mc-val.short != "X" { mc-val.value } else { c-val }
  let mii = if mi-val != none and mi-val.short != "X" { mi-val.value } else { i-val }
  let mai = if ma-val != none and ma-val.short != "X" { ma-val.value } else { a-val }

  calc.min(
    1 - ((1 - cr-val * mci) * (1 - ir-val * mii) * (1 - ar-val * mai)),
    0.915
  )
}

// Calculate Modified Impact Score for Environmental scoring
// THIS IS THE KEY DIFFERENCE BETWEEN CVSS 3.0 AND 3.1
#let calculate-modified-impact(miss, scope-changed) = {
  if scope-changed {
    // CVSS 3.0 formula: uses (miss - 0.02)^15
    scope-changed-factor * (miss - 0.029) - 3.25 * calc.pow(miss - 0.02, 15)
  } else {
    // CVSS 3.0 formula: uses (miss - 0.02)^15
    scope-unchanged-factor * miss
  }
}

// Calculate Environmental Score
// DIFFERENT FROM 3.1: Uses CVSS 3.0 Modified Impact formula
#let calculate-environmental-score(metrics, base-score) = {
  if base-score == none or base-score == 0 {
    return none
  }

  // Check if any environmental metric is defined
  let has-env = false
  for key in ("CR", "IR", "AR", "MAV", "MAC", "MPR", "MUI", "MS", "MC", "MI", "MA") {
    let val = metrics.at(key, default: none)
    if val != none and val.short != "X" {
      has-env = true
      break
    }
  }

  if not has-env {
    return none
  }

  // Get modified metrics
  let mav-val = metrics.at("MAV", default: metrics.at("AV", default: av.values.X)).value
  let mac-val = metrics.at("MAC", default: metrics.at("AC", default: ac.values.X)).value
  let mpr-val = metrics.at("MPR", default: metrics.at("PR", default: pr.values.X))
  let mui-val = metrics.at("MUI", default: metrics.at("UI", default: ui.values.X)).value
  let ms-val = metrics.at("MS", default: metrics.at("S", default: s.values.X)).value

  let miss = calculate-miss(metrics)
  // Use CVSS 3.0 formula for modified impact
  let mod-impact = calculate-modified-impact(miss, ms-val)

  if mod-impact <= 0 {
    return 0.0
  }

  let mod-exploitability = calculate-exploitability(mav-val, mac-val, mpr-val, mui-val, ms-val)

  let e-val = metrics.at("E", default: e.values.X).value
  let rl-val = metrics.at("RL", default: rl.values.X).value
  let rc-val = metrics.at("RC", default: rc.values.X).value

  let mod-score = if ms-val {
    calc.min(scope-coef * (mod-impact + mod-exploitability), 10)
  } else {
    calc.min(mod-impact + mod-exploitability, 10)
  }

  round-up(round-up(mod-score) * e-val * rl-val * rc-val)
}

// Get severity rating from score - identical to 3.1
#let get-severity(score) = {
  if score == none or score == 0 {
    "NONE"
  } else if score <= 3.9 {
    "LOW"
  } else if score <= 6.9 {
    "MEDIUM"
  } else if score <= 8.9 {
    "HIGH"
  } else {
    "CRITICAL"
  }
}

// Main scoring function (returns kebab-case keys)
#let calculate-scores(metrics) = {
  let base = calculate-base-score(metrics)
  let temporal = calculate-temporal-score(metrics, base)
  let environmental = calculate-environmental-score(metrics, base)

  let overall = if environmental != none {
    environmental
  } else if temporal != none {
    temporal
  } else {
    base
  }

  (
    base-score: base,
    temporal-score: temporal,
    environmental-score: environmental,
    overall-score: overall,
    severity: get-severity(overall),
    base-severity: get-severity(base),
  )
}
