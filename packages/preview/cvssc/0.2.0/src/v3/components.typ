// CVSS 3.1 Component Definitions
// Based on CVSS v3.1 Specification
// https://www.first.org/cvss/v3.1/specification-document

// Attack Vector (AV)
#let av = (
  name: "Attack Vector",
  short: "AV",
  values: (
    X: (short: "X", name: "Not Defined", value: 1.0),
    N: (short: "N", name: "Network", value: 0.85),
    A: (short: "A", name: "Adjacent Network", value: 0.62),
    L: (short: "L", name: "Local", value: 0.55),
    P: (short: "P", name: "Physical", value: 0.2),
  )
)

// Attack Complexity (AC)
#let ac = (
  name: "Attack Complexity",
  short: "AC",
  values: (
    X: (short: "X", name: "Not Defined", value: 1.0),
    L: (short: "L", name: "Low", value: 0.77),
    H: (short: "H", name: "High", value: 0.44),
  )
)

// Privileges Required (PR)
#let pr = (
  name: "Privileges Required",
  short: "PR",
  values: (
    X: (short: "X", name: "Not Defined", value: 1.0, changed: 1.0),
    N: (short: "N", name: "None", value: 0.85, changed: 0.85),
    L: (short: "L", name: "Low", value: 0.62, changed: 0.68),
    H: (short: "H", name: "High", value: 0.27, changed: 0.5),
  )
)

// User Interaction (UI)
#let ui = (
  name: "User Interaction",
  short: "UI",
  values: (
    X: (short: "X", name: "Not Defined", value: 1.0),
    N: (short: "N", name: "None", value: 0.85),
    R: (short: "R", name: "Required", value: 0.62),
  )
)

// Scope (S)
#let s = (
  name: "Scope",
  short: "S",
  values: (
    X: (short: "X", name: "Not Defined", value: false),
    U: (short: "U", name: "Unchanged", value: false),
    C: (short: "C", name: "Changed", value: true),
  )
)

// Confidentiality Impact (C)
#let c = (
  name: "Confidentiality Impact",
  short: "C",
  values: (
    X: (short: "X", name: "Not Defined", value: 0.0),
    N: (short: "N", name: "None", value: 0.0),
    L: (short: "L", name: "Low", value: 0.22),
    H: (short: "H", name: "High", value: 0.56),
  )
)

// Integrity Impact (I)
#let i = (
  name: "Integrity Impact",
  short: "I",
  values: (
    X: (short: "X", name: "Not Defined", value: 0.0),
    N: (short: "N", name: "None", value: 0.0),
    L: (short: "L", name: "Low", value: 0.22),
    H: (short: "H", name: "High", value: 0.56),
  )
)

// Availability Impact (A)
#let a = (
  name: "Availability Impact",
  short: "A",
  values: (
    X: (short: "X", name: "Not Defined", value: 0.0),
    N: (short: "N", name: "None", value: 0.0),
    L: (short: "L", name: "Low", value: 0.22),
    H: (short: "H", name: "High", value: 0.56),
  )
)

// Exploit Code Maturity (E)
#let e = (
  name: "Exploit Code Maturity",
  short: "E",
  values: (
    X: (short: "X", name: "Not Defined", value: 1.0),
    U: (short: "U", name: "Unproven", value: 0.91),
    P: (short: "P", name: "Proof-of-Concept", value: 0.94),
    F: (short: "F", name: "Functional", value: 0.97),
    H: (short: "H", name: "High", value: 1.0),
  )
)

// Remediation Level (RL)
#let rl = (
  name: "Remediation Level",
  short: "RL",
  values: (
    X: (short: "X", name: "Not Defined", value: 1.0),
    O: (short: "O", name: "Official Fix", value: 0.95),
    T: (short: "T", name: "Temporary Fix", value: 0.96),
    W: (short: "W", name: "Workaround", value: 0.97),
    U: (short: "U", name: "Unavailable", value: 1.0),
  )
)

// Report Confidence (RC)
#let rc = (
  name: "Report Confidence",
  short: "RC",
  values: (
    X: (short: "X", name: "Not Defined", value: 1.0),
    U: (short: "U", name: "Unknown", value: 0.92),
    R: (short: "R", name: "Reasonable", value: 0.96),
    C: (short: "C", name: "Confirmed", value: 1.0),
  )
)

// CIA Requirements
#let cr = (
  name: "Confidentiality Requirement",
  short: "CR",
  values: (
    X: (short: "X", name: "Not Defined", value: 1.0),
    L: (short: "L", name: "Low", value: 0.5),
    M: (short: "M", name: "Medium", value: 1.0),
    H: (short: "H", name: "High", value: 1.5),
  )
)

#let ir = (
  name: "Integrity Requirement",
  short: "IR",
  values: (
    X: (short: "X", name: "Not Defined", value: 1.0),
    L: (short: "L", name: "Low", value: 0.5),
    M: (short: "M", name: "Medium", value: 1.0),
    H: (short: "H", name: "High", value: 1.5),
  )
)

#let ar = (
  name: "Availability Requirement",
  short: "AR",
  values: (
    X: (short: "X", name: "Not Defined", value: 1.0),
    L: (short: "L", name: "Low", value: 0.5),
    M: (short: "M", name: "Medium", value: 1.0),
    H: (short: "H", name: "High", value: 1.5),
  )
)

// Modified Base Metrics (same values as base)
#let mav = av
#let mac = ac
#let mpr = pr
#let mui = ui
#let ms = s
#let mc = c
#let mi = i
#let ma = a

// Component registry
#let base-components = (av, ac, pr, ui, s, c, i, a)
#let temporal-components = (e, rl, rc)
#let environmental-components = (cr, ir, ar, mav, mac, mpr, mui, ms, mc, mi, ma)
#let all-components = base-components + temporal-components + environmental-components
