// CVSS 2.0 Calculator
// Implementation of CVSS v2.0 scoring formulas
// Based on https://www.first.org/cvss/v2/guide

#import "components.typ": *

// Constants
#let impact-factor = 10.41

// Utility functions
#let round(value, precision) = {
  let scale = calc.pow(10, precision)
  calc.round(value * scale) / scale
}

// f(impact) function
// Returns 0 if impact is 0, otherwise returns 1.176
#let f-impact(impact) = {
  if impact == 0 {
    0
  } else {
    1.176
  }
}

// Calculate Impact Score
// Impact = 10.41 * (1 - (1 - ConfImpact) * (1 - IntegImpact) * (1 - AvailImpact))
#let calculate-impact(c-val, i-val, a-val) = {
  let conf-impact = 1 - c-val
  let integ-impact = 1 - i-val
  let avail-impact = 1 - a-val
  impact-factor * (1 - (conf-impact * integ-impact * avail-impact))
}

// Calculate Exploitability Score
// Exploitability = 20 * AccessComplexity * Authentication * AccessVector
#let calculate-exploitability(av-val, ac-val, au-val) = {
  20 * ac-val * au-val * av-val
}

// Calculate Base Score
// BaseScore = ((0.6 * Impact) + (0.4 * Exploitability) - 1.5) * f(Impact)
#let calculate-base-score(metrics) = {
  let av-val = metrics.at("AV", default: none)
  let ac-val = metrics.at("AC", default: none)
  let au-val = metrics.at("Au", default: none)
  let c-val = metrics.at("C", default: none)
  let i-val = metrics.at("I", default: none)
  let a-val = metrics.at("A", default: none)

  // Check if all base metrics are defined
  if av-val == none or ac-val == none or au-val == none or c-val == none or i-val == none or a-val == none {
    return none
  }

  let impact = calculate-impact(c-val.value, i-val.value, a-val.value)
  let exploitability = calculate-exploitability(av-val.value, ac-val.value, au-val.value)
  let f-score = f-impact(impact)

  let score = ((0.6 * impact) + (0.4 * exploitability) - 1.5) * f-score

  round(score, 1)
}

// Calculate Temporal Score
// TemporalScore = BaseScore * Exploitability * RemediationLevel * ReportConfidence
#let calculate-temporal-score(metrics, base-score) = {
  if base-score == none or base-score == 0 {
    return none
  }

  let e-val = metrics.at("E", default: e.values.ND).value
  let rl-val = metrics.at("RL", default: rl.values.ND).value
  let rc-val = metrics.at("RC", default: rc.values.ND).value

  // Check if any temporal metric is defined (not all are ND/1.0)
  if e-val == 1.0 and rl-val == 1.0 and rc-val == 1.0 {
    return none
  }

  round(base-score * e-val * rl-val * rc-val, 1)
}

// Calculate Adjusted Impact Score (for Environmental)
// AdjustedImpact = min(10, 10.41 * (1 - (1 - ConfImpact * ConfReq) * (1 - IntegImpact * IntegReq) * (1 - AvailImpact * AvailReq)))
#let calculate-adjusted-impact(metrics) = {
  let c-val = metrics.at("C", default: none)
  let i-val = metrics.at("I", default: none)
  let a-val = metrics.at("A", default: none)
  let cr-val = metrics.at("CR", default: cr.values.ND).value
  let ir-val = metrics.at("IR", default: ir.values.ND).value
  let ar-val = metrics.at("AR", default: ar.values.ND).value

  if c-val == none or i-val == none or a-val == none {
    return 0
  }

  calc.min(10,
    impact-factor * (1 -
      (1 - c-val.value * cr-val) *
      (1 - i-val.value * ir-val) *
      (1 - a-val.value * ar-val)))
}

// Calculate Adjusted Base Score (for Environmental)
// AdjustedBase = ((0.6 * AdjustedImpact) + (0.4 * Exploitability) - 1.5) * f(AdjustedImpact)
#let calculate-adjusted-base-score(metrics) = {
  let av-val = metrics.at("AV", default: none)
  let ac-val = metrics.at("AC", default: none)
  let au-val = metrics.at("Au", default: none)

  if av-val == none or ac-val == none or au-val == none {
    return 0
  }

  let adjusted-impact = calculate-adjusted-impact(metrics)
  let exploitability = calculate-exploitability(av-val.value, ac-val.value, au-val.value)
  exploitability = round(exploitability, 1)
  let f-score = f-impact(adjusted-impact)

  ((0.6 * adjusted-impact) + (0.4 * exploitability) - 1.5) * f-score
}

// Calculate Adjusted Temporal Score (for Environmental)
// AdjustedTemporal = AdjustedBase * Exploitability * RemediationLevel * ReportConfidence
#let calculate-adjusted-temporal-score(metrics) = {
  let adjusted-base = calculate-adjusted-base-score(metrics)
  let e-val = metrics.at("E", default: e.values.ND).value
  let rl-val = metrics.at("RL", default: rl.values.ND).value
  let rc-val = metrics.at("RC", default: rc.values.ND).value

  adjusted-base * e-val * rl-val * rc-val
}

// Calculate Environmental Score
// EnvironmentalScore = (AdjustedTemporal + (10 - AdjustedTemporal) * CollateralDamagePotential) * TargetDistribution
#let calculate-environmental-score(metrics, base-score) = {
  if base-score == none or base-score == 0 {
    return none
  }

  // Check if any environmental metric is defined
  let has-env = false
  for key in ("CDP", "TD", "CR", "IR", "AR") {
    let val = metrics.at(key, default: none)
    if val != none {
      // Check if it's not the default "Not Defined" value
      if key == "CDP" and val.short != "ND" {
        has-env = true
        break
      } else if key == "TD" and val.short != "ND" {
        has-env = true
        break
      } else if key == "CR" and val.short != "ND" {
        has-env = true
        break
      } else if key == "IR" and val.short != "ND" {
        has-env = true
        break
      } else if key == "AR" and val.short != "ND" {
        has-env = true
        break
      }
    }
  }

  if not has-env {
    return none
  }

  let adjusted-temporal = calculate-adjusted-temporal-score(metrics)
  let cdp-val = metrics.at("CDP", default: cdp.values.ND).value
  let td-val = metrics.at("TD", default: td.values.ND).value

  round((adjusted-temporal + (10 - adjusted-temporal) * cdp-val) * td-val, 1)
}

// Get severity rating from score
#let get-severity(score) = {
  if score == none or score == 0 {
    "LOW"
  } else if score <= 3.9 {
    "LOW"
  } else if score <= 6.9 {
    "MEDIUM"
  } else if score <= 10.0 {
    "HIGH"
  } else {
    "HIGH"
  }
}

// Main scoring function
#let calculate-scores(metrics) = {
  let base = calculate-base-score(metrics)

  // Calculate subscores for debugging/display
  let impact = none
  let exploitability = none
  if base != none {
    let c-val = metrics.at("C", default: none)
    let i-val = metrics.at("I", default: none)
    let a-val = metrics.at("A", default: none)
    let av-val = metrics.at("AV", default: none)
    let ac-val = metrics.at("AC", default: none)
    let au-val = metrics.at("Au", default: none)

    if c-val != none and i-val != none and a-val != none {
      impact = round(calculate-impact(c-val.value, i-val.value, a-val.value), 1)
    }
    if av-val != none and ac-val != none and au-val != none {
      exploitability = round(calculate-exploitability(av-val.value, ac-val.value, au-val.value), 1)
    }
  }

  let temporal = calculate-temporal-score(metrics, base)
  let environmental = calculate-environmental-score(metrics, base)

  // Calculate modified impact for environmental score (if applicable)
  let modified-impact = none
  if environmental != none {
    modified-impact = round(calculate-adjusted-impact(metrics), 1)
  }

  let overall = if environmental != none {
    environmental
  } else if temporal != none {
    temporal
  } else {
    base
  }

  (
    base-score: base,
    impact-score: impact,
    exploitability-score: exploitability,
    temporal-score: temporal,
    environmental-score: environmental,
    modified-impact-score: modified-impact,
    overall-score: overall,
    severity: get-severity(overall),
    base-severity: get-severity(base),
  )
}

// Parse a CVSS 2.0 vector string
// Format: AV:N/AC:L/Au:N/C:P/I:P/A:P
#let parse-vector(vector-string) = {
  let metrics = (:)

  // Split by '/' to get individual metric pairs
  let parts = vector-string.split("/")

  for part in parts {
    // Split by ':' to get metric name and value
    let pair = part.split(":")
    if pair.len() == 2 {
      let metric-name = pair.at(0).trim()
      let value-short = pair.at(1).trim()

      // Match metric name to component
      let component = none
      if metric-name == "AV" {
        component = av
      } else if metric-name == "AC" {
        component = ac
      } else if metric-name == "Au" {
        component = au
      } else if metric-name == "C" {
        component = c
      } else if metric-name == "I" {
        component = i
      } else if metric-name == "A" {
        component = a
      } else if metric-name == "E" {
        component = e
      } else if metric-name == "RL" {
        component = rl
      } else if metric-name == "RC" {
        component = rc
      } else if metric-name == "CDP" {
        component = cdp
      } else if metric-name == "TD" {
        component = td
      } else if metric-name == "CR" {
        component = cr
      } else if metric-name == "IR" {
        component = ir
      } else if metric-name == "AR" {
        component = ar
      }

      if component != none {
        // Find the matching value in the component
        for (key, val) in component.values {
          if val.short == value-short {
            metrics.insert(metric-name, val)
            break
          }
        }
      }
    }
  }

  metrics
}

// Build a CVSS 2.0 vector string from metrics dictionary
#let build-vector(metrics) = {
  let parts = ()

  // Order: Base (AV, AC, Au, C, I, A), Temporal (E, RL, RC), Environmental (CDP, TD, CR, IR, AR)
  let order = ("AV", "AC", "Au", "C", "I", "A", "E", "RL", "RC", "CDP", "TD", "CR", "IR", "AR")

  for key in order {
    let val = metrics.at(key, default: none)
    if val != none {
      // Skip ND (Not Defined) values for temporal and environmental metrics
      if key in ("E", "RL", "RC", "CDP", "TD", "CR", "IR", "AR") and val.short == "ND" {
        continue
      }
      parts.push(key + ":" + val.short)
    }
  }

  parts.join("/")
}
