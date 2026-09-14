// CVSS 4.0 Component Definitions
// Based on CVSS v4.0 Specification
// https://www.first.org/cvss/v4.0/specification-document

// ============================================================================
// BASE METRICS - Exploitability
// ============================================================================

// Attack Vector (AV)
#let av = (
  name: "Attack Vector",
  short: "AV",
  values: (
    X: (short: "X", name: "Not Defined"),
    N: (short: "N", name: "Network"),
    A: (short: "A", name: "Adjacent Network"),
    L: (short: "L", name: "Local"),
    P: (short: "P", name: "Physical"),
  )
)

// Attack Complexity (AC)
#let ac = (
  name: "Attack Complexity",
  short: "AC",
  values: (
    X: (short: "X", name: "Not Defined"),
    L: (short: "L", name: "Low"),
    H: (short: "H", name: "High"),
  )
)

// Attack Requirements (AT) - NEW in CVSS 4.0
#let at = (
  name: "Attack Requirements",
  short: "AT",
  values: (
    X: (short: "X", name: "Not Defined"),
    N: (short: "N", name: "None"),
    P: (short: "P", name: "Present"),
  )
)

// Privileges Required (PR)
#let pr = (
  name: "Privileges Required",
  short: "PR",
  values: (
    X: (short: "X", name: "Not Defined"),
    N: (short: "N", name: "None"),
    L: (short: "L", name: "Low"),
    H: (short: "H", name: "High"),
  )
)

// User Interaction (UI)
#let ui = (
  name: "User Interaction",
  short: "UI",
  values: (
    X: (short: "X", name: "Not Defined"),
    N: (short: "N", name: "None"),
    P: (short: "P", name: "Passive"),
    A: (short: "A", name: "Active"),
  )
)

// ============================================================================
// BASE METRICS - Vulnerable System Impact
// ============================================================================

// Vulnerable System Confidentiality (VC)
#let vc = (
  name: "Vulnerable System Confidentiality",
  short: "VC",
  values: (
    X: (short: "X", name: "Not Defined"),
    H: (short: "H", name: "High"),
    L: (short: "L", name: "Low"),
    N: (short: "N", name: "None"),
  )
)

// Vulnerable System Integrity (VI)
#let vi = (
  name: "Vulnerable System Integrity",
  short: "VI",
  values: (
    X: (short: "X", name: "Not Defined"),
    H: (short: "H", name: "High"),
    L: (short: "L", name: "Low"),
    N: (short: "N", name: "None"),
  )
)

// Vulnerable System Availability (VA)
#let va = (
  name: "Vulnerable System Availability",
  short: "VA",
  values: (
    X: (short: "X", name: "Not Defined"),
    H: (short: "H", name: "High"),
    L: (short: "L", name: "Low"),
    N: (short: "N", name: "None"),
  )
)

// ============================================================================
// BASE METRICS - Subsequent System Impact (NEW in CVSS 4.0)
// ============================================================================

// Subsequent System Confidentiality (SC)
#let sc = (
  name: "Subsequent System Confidentiality",
  short: "SC",
  values: (
    X: (short: "X", name: "Not Defined"),
    H: (short: "H", name: "High"),
    L: (short: "L", name: "Low"),
    N: (short: "N", name: "None"),
  )
)

// Subsequent System Integrity (SI)
#let si = (
  name: "Subsequent System Integrity",
  short: "SI",
  values: (
    X: (short: "X", name: "Not Defined"),
    S: (short: "S", name: "Safety"),
    H: (short: "H", name: "High"),
    L: (short: "L", name: "Low"),
    N: (short: "N", name: "None"),
  )
)

// Subsequent System Availability (SA)
#let sa = (
  name: "Subsequent System Availability",
  short: "SA",
  values: (
    X: (short: "X", name: "Not Defined"),
    S: (short: "S", name: "Safety"),
    H: (short: "H", name: "High"),
    L: (short: "L", name: "Low"),
    N: (short: "N", name: "None"),
  )
)

// ============================================================================
// THREAT METRICS
// ============================================================================

// Exploit Maturity (E)
#let e = (
  name: "Exploit Maturity",
  short: "E",
  values: (
    X: (short: "X", name: "Not Defined"),
    A: (short: "A", name: "Attacked"),
    P: (short: "P", name: "POC"),
    U: (short: "U", name: "Unreported"),
  )
)

// ============================================================================
// ENVIRONMENTAL METRICS - Security Requirements
// ============================================================================

// Confidentiality Requirement (CR)
#let cr = (
  name: "Confidentiality Requirement",
  short: "CR",
  values: (
    X: (short: "X", name: "Not Defined"),
    H: (short: "H", name: "High"),
    M: (short: "M", name: "Medium"),
    L: (short: "L", name: "Low"),
  )
)

// Integrity Requirement (IR)
#let ir = (
  name: "Integrity Requirement",
  short: "IR",
  values: (
    X: (short: "X", name: "Not Defined"),
    H: (short: "H", name: "High"),
    M: (short: "M", name: "Medium"),
    L: (short: "L", name: "Low"),
  )
)

// Availability Requirement (AR)
#let ar = (
  name: "Availability Requirement",
  short: "AR",
  values: (
    X: (short: "X", name: "Not Defined"),
    H: (short: "H", name: "High"),
    M: (short: "M", name: "Medium"),
    L: (short: "L", name: "Low"),
  )
)

// ============================================================================
// ENVIRONMENTAL METRICS - Modified Base Metrics
// ============================================================================

// Modified Attack Vector (MAV)
#let mav = (
  name: "Modified Attack Vector",
  short: "MAV",
  values: (
    X: (short: "X", name: "Not Defined"),
    N: (short: "N", name: "Network"),
    A: (short: "A", name: "Adjacent Network"),
    L: (short: "L", name: "Local"),
    P: (short: "P", name: "Physical"),
  )
)

// Modified Attack Complexity (MAC)
#let mac = (
  name: "Modified Attack Complexity",
  short: "MAC",
  values: (
    X: (short: "X", name: "Not Defined"),
    L: (short: "L", name: "Low"),
    H: (short: "H", name: "High"),
  )
)

// Modified Attack Requirements (MAT)
#let mat = (
  name: "Modified Attack Requirements",
  short: "MAT",
  values: (
    X: (short: "X", name: "Not Defined"),
    N: (short: "N", name: "None"),
    P: (short: "P", name: "Present"),
  )
)

// Modified Privileges Required (MPR)
#let mpr = (
  name: "Modified Privileges Required",
  short: "MPR",
  values: (
    X: (short: "X", name: "Not Defined"),
    N: (short: "N", name: "None"),
    L: (short: "L", name: "Low"),
    H: (short: "H", name: "High"),
  )
)

// Modified User Interaction (MUI)
#let mui = (
  name: "Modified User Interaction",
  short: "MUI",
  values: (
    X: (short: "X", name: "Not Defined"),
    N: (short: "N", name: "None"),
    P: (short: "P", name: "Passive"),
    A: (short: "A", name: "Active"),
  )
)

// Modified Vulnerable System Confidentiality (MVC)
#let mvc = (
  name: "Modified Vulnerable System Confidentiality",
  short: "MVC",
  values: (
    X: (short: "X", name: "Not Defined"),
    H: (short: "H", name: "High"),
    L: (short: "L", name: "Low"),
    N: (short: "N", name: "None"),
  )
)

// Modified Vulnerable System Integrity (MVI)
#let mvi = (
  name: "Modified Vulnerable System Integrity",
  short: "MVI",
  values: (
    X: (short: "X", name: "Not Defined"),
    H: (short: "H", name: "High"),
    L: (short: "L", name: "Low"),
    N: (short: "N", name: "None"),
  )
)

// Modified Vulnerable System Availability (MVA)
#let mva = (
  name: "Modified Vulnerable System Availability",
  short: "MVA",
  values: (
    X: (short: "X", name: "Not Defined"),
    H: (short: "H", name: "High"),
    L: (short: "L", name: "Low"),
    N: (short: "N", name: "None"),
  )
)

// Modified Subsequent System Confidentiality (MSC)
#let msc = (
  name: "Modified Subsequent System Confidentiality",
  short: "MSC",
  values: (
    X: (short: "X", name: "Not Defined"),
    H: (short: "H", name: "High"),
    L: (short: "L", name: "Low"),
    N: (short: "N", name: "Negligible"),
  )
)

// Modified Subsequent System Integrity (MSI)
#let msi = (
  name: "Modified Subsequent System Integrity",
  short: "MSI",
  values: (
    X: (short: "X", name: "Not Defined"),
    S: (short: "S", name: "Safety"),
    H: (short: "H", name: "High"),
    L: (short: "L", name: "Low"),
    N: (short: "N", name: "Negligible"),
  )
)

// Modified Subsequent System Availability (MSA)
#let msa = (
  name: "Modified Subsequent System Availability",
  short: "MSA",
  values: (
    X: (short: "X", name: "Not Defined"),
    S: (short: "S", name: "Safety"),
    H: (short: "H", name: "High"),
    L: (short: "L", name: "Low"),
    N: (short: "N", name: "Negligible"),
  )
)

// ============================================================================
// SUPPLEMENTAL METRICS (NEW in CVSS 4.0)
// ============================================================================

// Safety (S)
#let s = (
  name: "Safety",
  short: "S",
  values: (
    X: (short: "X", name: "Not Defined"),
    N: (short: "N", name: "Negligible"),
    P: (short: "P", name: "Present"),
  )
)

// Automatable (AU)
#let au = (
  name: "Automatable",
  short: "AU",
  values: (
    X: (short: "X", name: "Not Defined"),
    N: (short: "N", name: "No"),
    Y: (short: "Y", name: "Yes"),
  )
)

// Recovery (R)
#let r = (
  name: "Recovery",
  short: "R",
  values: (
    X: (short: "X", name: "Not Defined"),
    A: (short: "A", name: "Automatic"),
    U: (short: "U", name: "User"),
    I: (short: "I", name: "Irrecoverable"),
  )
)

// Value Density (V)
#let v = (
  name: "Value Density",
  short: "V",
  values: (
    X: (short: "X", name: "Not Defined"),
    D: (short: "D", name: "Diffuse"),
    C: (short: "C", name: "Concentrated"),
  )
)

// Vulnerability Response Effort (RE)
#let re = (
  name: "Vulnerability Response Effort",
  short: "RE",
  values: (
    X: (short: "X", name: "Not Defined"),
    L: (short: "L", name: "Low"),
    M: (short: "M", name: "Moderate"),
    H: (short: "H", name: "High"),
  )
)

// Provider Urgency (U)
#let u = (
  name: "Provider Urgency",
  short: "U",
  values: (
    X: (short: "X", name: "Not Defined"),
    Clear: (short: "Clear", name: "Clear"),
    Green: (short: "Green", name: "Green"),
    Amber: (short: "Amber", name: "Amber"),
    Red: (short: "Red", name: "Red"),
  )
)

// ============================================================================
// Component registries
// ============================================================================

#let base-components = (av, ac, at, pr, ui, vc, vi, va, sc, si, sa)
#let threat-components = (e,)
#let environmental-security-requirement-components = (cr, ir, ar)
#let environmental-modified-base-components = (mav, mac, mat, mpr, mui, mvc, mvi, mva, msc, msi, msa)
#let supplemental-components = (s, au, r, v, re, u)
#let all-components = base-components + threat-components + environmental-security-requirement-components + environmental-modified-base-components + supplemental-components
