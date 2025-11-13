// CVSS 4.0 Calculator
// Implementation of CVSS v4.0 scoring using macro vectors and equivalence classes
// Based on CVSS v4.0 Specification
// https://www.first.org/cvss/v4.0/specification-document

#import "components.typ": *

// ============================================================================
// MACRO VECTOR LOOKUP TABLE
// Maps 6-digit macro vector strings to base scores
// ============================================================================

#let macro-vector-lookup = (
  "000000": 10.0, "000001": 9.9, "000010": 9.8, "000011": 9.5, "000020": 9.5, "000021": 9.2,
  "000100": 10.0, "000101": 9.6, "000110": 9.3, "000111": 8.7, "000120": 9.1, "000121": 8.1,
  "000200": 9.3, "000201": 9.0, "000210": 8.9, "000211": 8.0, "000220": 8.1, "000221": 6.8,
  "001000": 9.8, "001001": 9.5, "001010": 9.5, "001011": 9.2, "001020": 9.0, "001021": 8.4,
  "001100": 9.3, "001101": 9.2, "001110": 8.9, "001111": 8.1, "001120": 8.1, "001121": 6.5,
  "001200": 8.8, "001201": 8.0, "001210": 7.8, "001211": 7.0, "001220": 6.9, "001221": 4.8,
  "002001": 9.2, "002011": 8.2, "002021": 7.2, "002101": 7.9, "002111": 6.9, "002121": 5.0,
  "002201": 6.9, "002211": 5.5, "002221": 2.7,
  "010000": 9.9, "010001": 9.7, "010010": 9.5, "010011": 9.2, "010020": 9.2, "010021": 8.5,
  "010100": 9.5, "010101": 9.1, "010110": 9.0, "010111": 8.3, "010120": 8.4, "010121": 7.1,
  "010200": 9.2, "010201": 8.1, "010210": 8.2, "010211": 7.1, "010220": 7.2, "010221": 5.3,
  "011000": 9.5, "011001": 9.3, "011010": 9.2, "011011": 8.5, "011020": 8.5, "011021": 7.3,
  "011100": 9.2, "011101": 8.2, "011110": 8.0, "011111": 7.2, "011120": 7.0, "011121": 5.9,
  "011200": 8.4, "011201": 7.0, "011210": 7.1, "011211": 5.2, "011220": 5.0, "011221": 3.0,
  "012001": 8.6, "012011": 7.5, "012021": 5.2, "012101": 7.1, "012111": 5.2, "012121": 2.9,
  "012201": 6.3, "012211": 2.9, "012221": 1.7,
  "100000": 9.8, "100001": 9.5, "100010": 9.4, "100011": 8.7, "100020": 9.1, "100021": 8.1,
  "100100": 9.4, "100101": 8.9, "100110": 8.6, "100111": 7.4, "100120": 7.7, "100121": 6.4,
  "100200": 8.7, "100201": 7.5, "100210": 7.4, "100211": 6.3, "100220": 6.3, "100221": 4.9,
  "101000": 9.4, "101001": 8.9, "101010": 8.8, "101011": 7.7, "101020": 7.6, "101021": 6.7,
  "101100": 8.6, "101101": 7.6, "101110": 7.4, "101111": 5.8, "101120": 5.9, "101121": 5.0,
  "101200": 7.2, "101201": 5.7, "101210": 5.7, "101211": 5.2, "101220": 5.2, "101221": 2.5,
  "102001": 8.3, "102011": 7.0, "102021": 5.4, "102101": 6.5, "102111": 5.8, "102121": 2.6,
  "102201": 5.3, "102211": 2.1, "102221": 1.3,
  "110000": 9.5, "110001": 9.0, "110010": 8.8, "110011": 7.6, "110020": 7.6, "110021": 7.0,
  "110100": 9.0, "110101": 7.7, "110110": 7.5, "110111": 6.2, "110120": 6.1, "110121": 5.3,
  "110200": 7.7, "110201": 6.6, "110210": 6.8, "110211": 5.9, "110220": 5.2, "110221": 3.0,
  "111000": 8.9, "111001": 7.8, "111010": 7.6, "111011": 6.7, "111020": 6.2, "111021": 5.8,
  "111100": 7.4, "111101": 5.9, "111110": 5.7, "111111": 5.7, "111120": 4.7, "111121": 2.3,
  "111200": 6.1, "111201": 5.2, "111210": 5.7, "111211": 2.9, "111220": 2.4, "111221": 1.6,
  "112001": 7.1, "112011": 5.9, "112021": 3.0, "112101": 5.8, "112111": 2.6, "112121": 1.5,
  "112201": 2.3, "112211": 1.3, "112221": 0.6,
  "200000": 9.3, "200001": 8.7, "200010": 8.6, "200011": 7.2, "200020": 7.5, "200021": 5.8,
  "200100": 8.6, "200101": 7.4, "200110": 7.4, "200111": 6.1, "200120": 5.6, "200121": 3.4,
  "200200": 7.0, "200201": 5.4, "200210": 5.2, "200211": 4.0, "200220": 4.0, "200221": 2.2,
  "201000": 8.5, "201001": 7.5, "201010": 7.4, "201011": 5.5, "201020": 6.2, "201021": 5.1,
  "201100": 7.2, "201101": 5.7, "201110": 5.5, "201111": 4.1, "201120": 4.6, "201121": 1.9,
  "201200": 5.3, "201201": 3.6, "201210": 3.4, "201211": 1.9, "201220": 1.9, "201221": 0.8,
  "202001": 6.4, "202011": 5.1, "202021": 2.0, "202101": 4.7, "202111": 2.1, "202121": 1.1,
  "202201": 2.4, "202211": 0.9, "202221": 0.4,
  "210000": 8.8, "210001": 7.5, "210010": 7.3, "210011": 5.3, "210020": 6.0, "210021": 5.0,
  "210100": 7.3, "210101": 5.5, "210110": 5.9, "210111": 4.0, "210120": 4.1, "210121": 2.0,
  "210200": 5.4, "210201": 4.3, "210210": 4.5, "210211": 2.2, "210220": 2.0, "210221": 1.1,
  "211000": 7.5, "211001": 5.5, "211010": 5.8, "211011": 4.5, "211020": 4.0, "211021": 2.1,
  "211100": 6.1, "211101": 5.1, "211110": 4.8, "211111": 1.8, "211120": 2.0, "211121": 0.9,
  "211200": 4.6, "211201": 1.8, "211210": 1.7, "211211": 0.7, "211220": 0.8, "211221": 0.2,
  "212001": 5.3, "212011": 2.4, "212021": 1.4, "212101": 2.4, "212111": 1.2, "212121": 0.5,
  "212201": 1.0, "212211": 0.3, "212221": 0.1,
)

// ============================================================================
// EQUIVALENCE CLASS (EQ) DEFINITIONS
// The macro vector consists of 6 equivalence classes (EQ1-EQ6)
// ============================================================================

// Get comparison metric value (handles X values and modified metrics)
#let get-comparison-metric(metrics, key) = {
  // E:X is treated as E:A
  if key == "E" {
    let val = metrics.at(key, default: "X")
    return if val == "X" { "A" } else { val }
  }

  // CR:X, IR:X, AR:X are treated as H
  if key in ("CR", "IR", "AR") {
    let val = metrics.at(key, default: "X")
    return if val == "X" { "H" } else { val }
  }

  // MSI and MSA special handling for Safety
  if key == "MSI" {
    let mval = metrics.at("MSI", default: "X")
    if mval == "X" and metrics.at("SI", default: "N") == "S" {
      return "H"
    }
    if mval != "X" { return mval }
  }

  if key == "MSA" {
    let mval = metrics.at("MSA", default: "X")
    if mval == "X" and metrics.at("SA", default: "N") == "S" {
      return "H"
    }
    if mval != "X" { return mval }
  }

  // For other modified metrics, use modified value if not X, otherwise base value
  if key.starts-with("M") {
    let mval = metrics.at(key, default: "X")
    if mval != "X" { return mval }
    let base-key = key.slice(1)
    return metrics.at(base-key, default: "X")
  }

  metrics.at(key, default: "X")
}

// EQ1: AV:N and PR:N and UI:N
#let calculate-eq1(metrics) = {
  let av = get-comparison-metric(metrics, "AV")
  let pr = get-comparison-metric(metrics, "PR")
  let ui = get-comparison-metric(metrics, "UI")

  if av == "N" and pr == "N" and ui == "N" {
    "0"
  } else if av == "P" or (av != "N" and pr != "N" and ui != "N") {
    "2"
  } else {
    "1"
  }
}

// EQ2: AC:L and AT:N
#let calculate-eq2(metrics) = {
  let ac = get-comparison-metric(metrics, "AC")
  let at = get-comparison-metric(metrics, "AT")

  if ac == "L" and at == "N" {
    "0"
  } else {
    "1"
  }
}

// EQ3: VC:H and VI:H
#let calculate-eq3(metrics) = {
  let vc = get-comparison-metric(metrics, "VC")
  let vi = get-comparison-metric(metrics, "VI")
  let va = get-comparison-metric(metrics, "VA")

  if vc == "H" and vi == "H" {
    "0"
  } else if vc == "H" or vi == "H" or va == "H" {
    "1"
  } else {
    "2"
  }
}

// EQ4: MSI:S or MSA:S
#let calculate-eq4(metrics) = {
  let msi = get-comparison-metric(metrics, "MSI")
  let msa = get-comparison-metric(metrics, "MSA")
  let sc = get-comparison-metric(metrics, "SC")
  let si = get-comparison-metric(metrics, "SI")
  let sa = get-comparison-metric(metrics, "SA")

  if msi == "S" or msa == "S" {
    "0"
  } else if sc == "H" or si == "H" or sa == "H" {
    "1"
  } else {
    "2"
  }
}

// EQ5: E
#let calculate-eq5(metrics) = {
  let e = get-comparison-metric(metrics, "E")

  if e == "A" {
    "0"
  } else if e == "P" {
    "1"
  } else {
    "2"
  }
}

// EQ6: (CR:H and VC:H) or (IR:H and VI:H) or (AR:H and VA:H)
#let calculate-eq6(metrics) = {
  let cr = get-comparison-metric(metrics, "CR")
  let ir = get-comparison-metric(metrics, "IR")
  let ar = get-comparison-metric(metrics, "AR")
  let vc = get-comparison-metric(metrics, "VC")
  let vi = get-comparison-metric(metrics, "VI")
  let va = get-comparison-metric(metrics, "VA")

  if (cr == "H" and vc == "H") or (ir == "H" and vi == "H") or (ar == "H" and va == "H") {
    "0"
  } else {
    "1"
  }
}

// Calculate macro vector string (6 digits)
#let calculate-macro-vector(metrics) = {
  let eq1 = calculate-eq1(metrics)
  let eq2 = calculate-eq2(metrics)
  let eq3 = calculate-eq3(metrics)
  let eq4 = calculate-eq4(metrics)
  let eq5 = calculate-eq5(metrics)
  let eq6 = calculate-eq6(metrics)

  eq1 + eq2 + eq3 + eq4 + eq5 + eq6
}

// ============================================================================
// SEVERITY DISTANCE CALCULATIONS
// ============================================================================

// Severity level ordering for different metric groups
#let severity-order = (
  AV: ("P", "L", "A", "N"),
  AC: ("H", "L"),
  AT: ("P", "N"),
  PR: ("H", "L", "N"),
  UI: ("A", "P", "N"),
  VC: ("N", "L", "H"),
  VI: ("N", "L", "H"),
  VA: ("N", "L", "H"),
  SC: ("N", "L", "H"),
  SI: ("N", "L", "H", "S"),
  SA: ("N", "L", "H", "S"),
  CR: ("L", "M", "H"),
  IR: ("L", "M", "H"),
  AR: ("L", "M", "H"),
)

// Get severity distance between two values for a metric
#let severity-distance(metric, val1, val2) = {
  let order = severity-order.at(metric, default: ())
  if order == () { return 0 }

  let idx1 = order.position(v => v == val1)
  let idx2 = order.position(v => v == val2)

  if idx1 == none or idx2 == none { return 0 }

  idx1 - idx2
}

// ============================================================================
// MACRO VECTOR DEPTH FOR EACH EQ
// ============================================================================

#let eq-depths = (
  "1": (
    "0": 1,
    "1": 4,
    "2": 5,
  ),
  "2": (
    "0": 1,
    "1": 2,
  ),
  "3": (
    "0": 7,
    "1": 6,
    "2": 8,
  ),
  "4": (
    "0": 6,
    "1": 5,
    "2": 4,
  ),
  "5": (
    "0": 1,
    "1": 1,
    "2": 1,
  ),
  "6": (
    "0": 7,
    "1": 6,
  ),
)

// Get depth for specific EQ level
#let get-eq-depth(eq-num, level) = {
  eq-depths.at(str(eq-num), default: (:)).at(level, default: 0)
}

// ============================================================================
// HIGHEST SEVERITY VECTORS FOR EACH EQ
// Based on official CVSS v4.0 spec
// ============================================================================

#let max-composed = (
  eq1: (
    "0": ("AV:N/PR:N/UI:N/",),
    "1": ("AV:A/PR:N/UI:N/", "AV:N/PR:L/UI:N/", "AV:N/PR:N/UI:P/"),
    "2": ("AV:P/PR:N/UI:N/", "AV:A/PR:L/UI:P/"),
  ),
  eq2: (
    "0": ("AC:L/AT:N/",),
    "1": ("AC:H/AT:N/", "AC:L/AT:P/"),
  ),
  eq3eq6: (
    "00": ("VC:H/VI:H/VA:H/CR:H/IR:H/AR:H/",),
    "01": ("VC:H/VI:H/VA:L/CR:M/IR:M/AR:H/", "VC:H/VI:H/VA:H/CR:M/IR:M/AR:M/"),
    "10": ("VC:L/VI:H/VA:H/CR:H/IR:H/AR:H/", "VC:H/VI:L/VA:H/CR:H/IR:H/AR:H/"),
    "11": ("VC:L/VI:H/VA:L/CR:H/IR:M/AR:H/", "VC:L/VI:H/VA:H/CR:H/IR:M/AR:M/",
           "VC:H/VI:L/VA:H/CR:M/IR:H/AR:M/", "VC:H/VI:L/VA:L/CR:M/IR:H/AR:H/",
           "VC:L/VI:L/VA:H/CR:H/IR:H/AR:M/"),
    "21": ("VC:L/VI:L/VA:L/CR:H/IR:H/AR:H/",),
  ),
  eq4: (
    "0": ("SC:H/SI:S/SA:S/",),
    "1": ("SC:H/SI:H/SA:H/",),
    "2": ("SC:L/SI:L/SA:L/",),
  ),
  eq5: (
    "0": ("E:A/",),
    "1": ("E:P/",),
    "2": ("E:U/",),
  ),
)

#let max-severity = (
  eq1: (
    "0": 1,
    "1": 4,
    "2": 5,
  ),
  eq2: (
    "0": 1,
    "1": 2,
  ),
  eq3eq6: (
    "00": 7,
    "01": 6,
    "10": 8,
    "11": 8,
    "21": 10,
  ),
  eq4: (
    "0": 6,
    "1": 5,
    "2": 4,
  ),
  eq5: (
    "0": 1,
    "1": 1,
    "2": 1,
  ),
)

// Metric level scores (lower is more severe)
#let metric-levels = (
  AV: (N: 0.0, A: 0.1, L: 0.2, P: 0.3),
  PR: (N: 0.0, L: 0.1, H: 0.2),
  UI: (N: 0.0, P: 0.1, A: 0.2),
  AC: (L: 0.0, H: 0.1),
  AT: (N: 0.0, P: 0.1),
  VC: (H: 0.0, L: 0.1, N: 0.2),
  VI: (H: 0.0, L: 0.1, N: 0.2),
  VA: (H: 0.0, L: 0.1, N: 0.2),
  SC: (H: 0.1, L: 0.2, N: 0.3),
  SI: (S: 0.0, H: 0.1, L: 0.2, N: 0.3),
  SA: (S: 0.0, H: 0.1, L: 0.2, N: 0.3),
  CR: (H: 0.0, M: 0.1, L: 0.2),
  IR: (H: 0.0, M: 0.1, L: 0.2),
  AR: (H: 0.0, M: 0.1, L: 0.2),
)

// ============================================================================
// SCORE CALCULATION
// ============================================================================

// Parse a max vector string into metrics
#let parse-max-vector(vec-str) = {
  let parts = vec-str.split("/").filter(p => p.len() > 0)
  let result = (:)
  for part in parts {
    let kv = part.split(":")
    if kv.len() == 2 {
      result.insert(kv.at(0), kv.at(1))
    }
  }
  result
}

// Get metric level score
#let get-metric-level(metric, value) = {
  if value == none or value == "X" {
    return none
  }
  let levels = metric-levels.at(metric, default: none)
  if levels == none {
    return none
  }
  levels.at(value, default: none)
}

// Calculate severity distance between current vector and a max vector
#let calc-severity-distance(current-metrics, max-vec-str, metric-keys) = {
  let max-vec = parse-max-vector(max-vec-str)
  let total = 0.0

  for key in metric-keys {
    let current-val = get-comparison-metric(current-metrics, key)
    let max-val = max-vec.at(key, default: "X")

    let current-level = get-metric-level(key, current-val)
    let max-level = get-metric-level(key, max-val)

    if current-level != none and max-level != none {
      total = total + (current-level - max-level)
    }
  }

  total
}

// Find the maximum severity vector for current metrics within an EQ
#let find-max-vector(current-metrics, eq-key, eq-level) = {
  let max-vecs = max-composed.at(eq-key, default: (:)).at(eq-level, default: ())

  if max-vecs.len() == 0 {
    return none
  }

  // Determine which metrics to check based on EQ
  let metric-keys = if eq-key == "eq1" {
    ("AV", "PR", "UI")
  } else if eq-key == "eq2" {
    ("AC", "AT")
  } else if eq-key == "eq3eq6" {
    ("VC", "VI", "VA", "CR", "IR", "AR")
  } else if eq-key == "eq4" {
    ("SC", "SI", "SA")
  } else if eq-key == "eq5" {
    ("E",)
  } else {
    ()
  }

  // Try each max vector and return the first valid one
  // (where current metrics are not more severe than max)
  for max-vec in max-vecs {
    let distance = calc-severity-distance(current-metrics, max-vec, metric-keys)
    if distance >= 0 {
      return (vec: max-vec, distance: distance)
    }
  }

  // If no valid vector found, use first one
  if max-vecs.len() > 0 {
    let max-vec = max-vecs.at(0)
    return (
      vec: max-vec,
      distance: calc-severity-distance(current-metrics, max-vec, metric-keys)
    )
  }

  none
}

// Calculate the next lower macro vector for a specific EQ
#let derive-next-lower(macro-vec, eq-index) = {
  let digits = macro-vec.clusters()

  if eq-index < 1 or eq-index > 6 { return none }

  // Special handling for EQ3 (combined with EQ6)
  if eq-index == 3 {
    let eq3-val = int(digits.at(2))
    let eq6-val = int(digits.at(5))

    // Based on RedHat's logic for EQ3+EQ6
    if eq3-val == 1 and eq6-val == 1 {
      // Increment EQ3
      if eq3-val + 1 > 2 { return none }
      let result = ""
      for i in range(6) {
        if i == 2 { result = result + str(eq3-val + 1) }
        else { result = result + digits.at(i) }
      }
      return result
    } else if eq3-val == 0 and eq6-val == 1 {
      // Increment EQ3
      let result = ""
      for i in range(6) {
        if i == 2 { result = result + str(eq3-val + 1) }
        else { result = result + digits.at(i) }
      }
      return result
    } else if eq3-val == 1 and eq6-val == 0 {
      // Increment EQ6
      if eq6-val + 1 > 1 { return none }
      let result = ""
      for i in range(6) {
        if i == 5 { result = result + str(eq6-val + 1) }
        else { result = result + digits.at(i) }
      }
      return result
    } else if eq3-val == 0 and eq6-val == 0 {
      // Take max of two options (handled in caller)
      // For now, increment EQ6 (caller will handle both)
      let result = ""
      for i in range(6) {
        if i == 5 { result = result + "1" }
        else { result = result + digits.at(i) }
      }
      return result
    } else {
      // eq3=2, eq6=1: increment both
      if eq3-val + 1 > 2 or eq6-val + 1 > 1 { return none }
      let result = ""
      for i in range(6) {
        if i == 2 { result = result + str(eq3-val + 1) }
        else if i == 5 { result = result + str(eq6-val + 1) }
        else { result = result + digits.at(i) }
      }
      return result
    }
  }

  let current = digits.at(eq-index - 1)
  let next-val = int(current) + 1

  // Check if next level exists
  if eq-index == 1 and next-val > 2 { return none }
  if eq-index == 2 and next-val > 1 { return none }
  if eq-index == 4 and next-val > 2 { return none }
  if eq-index == 5 and next-val > 2 { return none }
  if eq-index == 6 and next-val > 1 { return none }

  let next = str(next-val)

  // Build new macro vector with updated digit
  let result = ""
  for i in range(6) {
    if i == eq-index - 1 {
      result = result + next
    } else {
      result = result + digits.at(i)
    }
  }

  result
}

// Get score for next lower macro vector
#let get-next-lower-score(macro-vec, eq-index) = {
  let next = derive-next-lower(macro-vec, eq-index)
  if next == none {
    return none
  }
  macro-vector-lookup.at(next, default: none)
}

// Round score to one decimal place with CVSS rounding
#let round-cvss4(value) = {
  let epsilon = calc.pow(10, -6)
  calc.round((value + epsilon) * 10) / 10
}

// Main score calculation function
#let calculate-base-score(metrics) = {
  // Check if base metrics are defined
  let av = metrics.at("AV", default: "X")
  let ac = metrics.at("AC", default: "X")
  let at = metrics.at("AT", default: "X")
  let pr = metrics.at("PR", default: "X")
  let ui = metrics.at("UI", default: "X")

  if av == "X" or ac == "X" or at == "X" or pr == "X" or ui == "X" {
    return none
  }

  // Check for no impact
  let vc = metrics.at("VC", default: "N")
  let vi = metrics.at("VI", default: "N")
  let va = metrics.at("VA", default: "N")
  let sc = metrics.at("SC", default: "N")
  let si = metrics.at("SI", default: "N")
  let sa = metrics.at("SA", default: "N")

  if vc == "N" and vi == "N" and va == "N" and sc == "N" and si == "N" and sa == "N" {
    return 0.0
  }

  // Calculate macro vector
  let macro-vec = calculate-macro-vector(metrics)

  // Look up base score from table
  let base-score = macro-vector-lookup.at(macro-vec, default: none)

  if base-score == none {
    return none
  }

  // Calculate severity distance adjustments for each EQ
  let eq1-level = macro-vec.at(0)
  let eq2-level = macro-vec.at(1)
  let eq3-level = macro-vec.at(2)
  let eq4-level = macro-vec.at(3)
  let eq5-level = macro-vec.at(4)
  let eq6-level = macro-vec.at(5)

  // Scale factor for max severity (as per CVSS v4.0 spec)
  let step = 0.1

  // Generate all possible max vector combinations (RedHat approach)
  let eq1-maxes = max-composed.eq1.at(eq1-level, default: ())
  let eq2-maxes = max-composed.eq2.at(eq2-level, default: ())
  let eq36-key = eq3-level + eq6-level
  let eq3eq6-maxes = max-composed.eq3eq6.at(eq36-key, default: ())
  let eq4-maxes = max-composed.eq4.at(eq4-level, default: ())
  let eq5-maxes = max-composed.eq5.at(eq5-level, default: ())

  // Find ONE max vector where all severity distances are >= 0
  let combined-max-vec = none
  for eq1-max in eq1-maxes {
    for eq2-max in eq2-maxes {
      for eq3eq6-max in eq3eq6-maxes {
        for eq4-max in eq4-maxes {
          for eq5-max in eq5-maxes {
            let test-vec = eq1-max + eq2-max + eq3eq6-max + eq4-max + eq5-max

            // Calculate all severity distances for this combined vector
            let all-metrics-keys = ("AV", "PR", "UI", "AC", "AT", "VC", "VI", "VA", "SC", "SI", "SA", "CR", "IR", "AR")
            let all-valid = true
            for key in all-metrics-keys {
              let current-val = get-comparison-metric(metrics, key)
              let max-metrics = parse-max-vector(test-vec)
              let max-val = max-metrics.at(key, default: "X")

              let current-level = get-metric-level(key, current-val)
              let max-level = get-metric-level(key, max-val)

              if current-level != none and max-level != none {
                if current-level - max-level < 0 {
                  all-valid = false
                  break
                }
              }
            }

            if all-valid {
              combined-max-vec = test-vec
              break
            }
          }
          if combined-max-vec != none { break }
        }
        if combined-max-vec != none { break }
      }
      if combined-max-vec != none { break }
    }
    if combined-max-vec != none { break }
  }

  // Use the single combined max vector to calculate all severity distances
  let normalized-severities = ()
  let n-existing-lower = 0

  if combined-max-vec != none {
    // EQ1: AV, PR, UI
    let next-score = get-next-lower-score(macro-vec, 1)
    if next-score != none and next-score <= base-score {
      let distance = calc-severity-distance(metrics, combined-max-vec, ("AV", "PR", "UI"))
      let max-sev = max-severity.eq1.at(eq1-level, default: 1) * step
      let available = base-score - next-score
      let normalized = (distance / max-sev) * available
      normalized-severities.push(normalized)
      n-existing-lower += 1
    }

    // EQ2: AC, AT
    next-score = get-next-lower-score(macro-vec, 2)
    if next-score != none and next-score <= base-score {
      let distance = calc-severity-distance(metrics, combined-max-vec, ("AC", "AT"))
      let max-sev = max-severity.eq2.at(eq2-level, default: 1) * step
      let available = base-score - next-score
      let normalized = (distance / max-sev) * available
      normalized-severities.push(normalized)
      n-existing-lower += 1
    }

    // EQ3+EQ6: VC, VI, VA, CR, IR, AR
    next-score = get-next-lower-score(macro-vec, 3)
    if next-score != none and next-score <= base-score {
      let distance = calc-severity-distance(metrics, combined-max-vec, ("VC", "VI", "VA", "CR", "IR", "AR"))
      let max-sev = max-severity.eq3eq6.at(eq36-key, default: 1) * step
      let available = base-score - next-score
      let normalized = (distance / max-sev) * available
      normalized-severities.push(normalized)
      n-existing-lower += 1
    }

    // EQ4: SC, SI, SA
    next-score = get-next-lower-score(macro-vec, 4)
    if next-score != none and next-score <= base-score {
      let distance = calc-severity-distance(metrics, combined-max-vec, ("SC", "SI", "SA"))
      let max-sev = max-severity.eq4.at(eq4-level, default: 1) * step
      let available = base-score - next-score
      let normalized = (distance / max-sev) * available
      normalized-severities.push(normalized)
      n-existing-lower += 1
    }

    // EQ5: E (always 0 for base score, but still counts in mean)
    next-score = get-next-lower-score(macro-vec, 5)
    if next-score != none and next-score <= base-score {
      normalized-severities.push(0.0)
      n-existing-lower += 1
    }
  }

  // Calculate mean adjustment
  let mean-adjustment = if n-existing-lower > 0 and normalized-severities.len() > 0 {
    normalized-severities.sum() / n-existing-lower
  } else {
    0.0
  }

  let final-score = base-score - mean-adjustment

  // Clamp to valid range and round
  if final-score < 0 {
    0.0
  } else if final-score > 10 {
    10.0
  } else {
    round-cvss4(final-score)
  }
}

// Get severity rating from score
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

// Calculate threat score (with Exploit Maturity)
#let calculate-threat-score(metrics, base-score) = {
  if base-score == none or base-score == 0 {
    return none
  }

  let e = metrics.at("E", default: "X")
  if e == "X" {
    return none
  }

  // Threat metrics affect the macro vector through EQ5
  // Recalculate with only base + threat metrics
  calculate-base-score(metrics)
}

// Calculate environmental score
#let calculate-environmental-score(metrics, base-score) = {
  if base-score == none or base-score == 0 {
    return none
  }

  // Check if any environmental metrics are defined
  let has-env = false
  for key in ("CR", "IR", "AR", "MAV", "MAC", "MAT", "MPR", "MUI", "MVC", "MVI", "MVA", "MSC", "MSI", "MSA") {
    if metrics.at(key, default: "X") != "X" {
      has-env = true
      break
    }
  }

  if not has-env {
    return none
  }

  // Environmental metrics affect macro vector calculation
  // Recalculate with modified metrics
  calculate-base-score(metrics)
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

// Parse CVSS 4.0 vector string to metrics dictionary
#let parse-vector(vector-string) = {
  // Normalize vector string
  let normalized = vector-string
    .replace("CVSS:4.0/", "")
    .replace("CVSS:", "")
    .replace("(", "")
    .replace(")", "")
    .replace(" ", "")
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

    // For CVSS 4.0, store the short string value directly
    // The calculate functions will look up values as needed
    metrics.insert(metric-name, metric-value)
  }

  metrics
}

// Main scoring function
#let calculate-scores(metrics) = {
  let base = calculate-base-score(metrics)
  let threat = calculate-threat-score(metrics, base)
  let environmental = calculate-environmental-score(metrics, base)

  let overall = if environmental != none {
    environmental
  } else if threat != none {
    threat
  } else {
    base
  }

  (
    base-score: base,
    threat-score: threat,
    environmental-score: environmental,
    overall-score: overall,
    severity: get-severity(overall),
    base-severity: get-severity(base),
    macro-vector: if base != none { calculate-macro-vector(metrics) } else { none },
  )
}
