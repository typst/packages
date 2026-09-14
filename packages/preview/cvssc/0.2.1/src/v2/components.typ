// CVSS 2.0 Component Definitions
// Based on CVSS v2.0 Specification
// https://www.first.org/cvss/v2/guide

// Base Metrics - Exploitability

// Access Vector (AV)
#let av = (
  name: "Access Vector",
  short: "AV",
  category: "Base",
  subcategory: "Exploitability Metrics",
  description: "This metric reflects how the vulnerability is exploited. The more remote an attacker can be to attack a host, the greater the vulnerability score.",
  values: (
    L: (short: "L", name: "Local", value: 0.395, description: "A vulnerability exploitable with only local access requires the attacker to have either physical access to the vulnerable system or a local (shell) account."),
    A: (short: "A", name: "Adjacent Network", value: 0.646, description: "A vulnerability exploitable with adjacent network access requires the attacker to have access to either the broadcast or collision domain of the vulnerable software."),
    N: (short: "N", name: "Network", value: 1.0, description: "A vulnerability exploitable with network access means the vulnerable software is bound to the network stack and the attacker does not require local network access or local access."),
  )
)

// Access Complexity (AC)
#let ac = (
  name: "Access Complexity",
  short: "AC",
  category: "Base",
  subcategory: "Exploitability Metrics",
  description: "This metric measures the complexity of the attack required to exploit the vulnerability once an attacker has gained access to the target system.",
  values: (
    H: (short: "H", name: "High", value: 0.35, description: "Specialized access conditions exist. For example, an attacker can only exploit the vulnerability under very specialized conditions."),
    M: (short: "M", name: "Medium", value: 0.61, description: "The access conditions are somewhat specialized. For example, the attacker can only exploit the vulnerability under certain conditions."),
    L: (short: "L", name: "Low", value: 0.71, description: "Specialized access conditions or extenuating circumstances do not exist. For example, an attacker can exploit the vulnerability under most conditions."),
  )
)

// Authentication (Au)
#let au = (
  name: "Authentication",
  short: "Au",
  category: "Base",
  subcategory: "Exploitability Metrics",
  description: "This metric measures the number of times an attacker must authenticate to a target in order to exploit a vulnerability.",
  values: (
    M: (short: "M", name: "Multiple", value: 0.45, description: "Exploiting the vulnerability requires that the attacker authenticate two or more times, even if the same credentials are used each time."),
    S: (short: "S", name: "Single", value: 0.56, description: "The vulnerability requires an attacker to be logged into the system (such as at a command line or via a desktop session or web interface)."),
    N: (short: "N", name: "None", value: 0.704, description: "Authentication is not required to exploit the vulnerability."),
  )
)

// Base Metrics - Impact

// Confidentiality Impact (C)
#let c = (
  name: "Confidentiality Impact",
  short: "C",
  category: "Base",
  subcategory: "Impact Metrics",
  description: "This metric measures the impact to the confidentiality of the information resources managed by a software component due to a successfully exploited vulnerability.",
  values: (
    N: (short: "N", name: "None", value: 0.0, description: "There is no impact to the confidentiality of the system."),
    P: (short: "P", name: "Partial", value: 0.275, description: "There is considerable informational disclosure. Access to some system files is possible, but the attacker does not have control over what is obtained, or the scope of the loss is constrained."),
    C: (short: "C", name: "Complete", value: 0.660, description: "There is total information disclosure, resulting in all system files being revealed. The attacker is able to read all of the system's data (memory, files, etc.)"),
  )
)

// Integrity Impact (I)
#let i = (
  name: "Integrity Impact",
  short: "I",
  category: "Base",
  subcategory: "Impact Metrics",
  description: "This metric measures the impact to integrity of a successfully exploited vulnerability.",
  values: (
    N: (short: "N", name: "None", value: 0.0, description: "There is no impact to the integrity of the system."),
    P: (short: "P", name: "Partial", value: 0.275, description: "Modification of some system files or information is possible, but the attacker does not have control over what can be modified, or the scope of what the attacker can affect is limited."),
    C: (short: "C", name: "Complete", value: 0.660, description: "There is a total compromise of system integrity. There is a complete loss of system protection, resulting in the entire system being compromised."),
  )
)

// Availability Impact (A)
#let a = (
  name: "Availability Impact",
  short: "A",
  category: "Base",
  subcategory: "Impact Metrics",
  description: "This metric measures the impact to the availability of the impacted component resulting from a successfully exploited vulnerability.",
  values: (
    N: (short: "N", name: "None", value: 0.0, description: "There is no impact to availability within the impacted component."),
    P: (short: "P", name: "Partial", value: 0.275, description: "There is reduced performance or interruptions in resource availability. An example is a network-based flood attack that permits a limited number of successful connections to an Internet service."),
    C: (short: "C", name: "Complete", value: 0.660, description: "There is a total shutdown of the affected resource. The attacker can render the resource completely unavailable."),
  )
)

// Temporal Metrics

// Exploitability (E)
#let e = (
  name: "Exploitability",
  short: "E",
  category: "Temporal",
  description: "This metric measures the current state of exploit techniques or code availability.",
  values: (
    ND: (short: "ND", name: "Not Defined", value: 1.0, description: "Assigning this value to the metric will not influence the score. It is a signal to the equation to skip this metric."),
    U: (short: "U", name: "Unproven", value: 0.85, description: "No exploit code is available, or an exploit is entirely theoretical."),
    POC: (short: "POC", name: "Proof-of-Concept", value: 0.9, description: "Proof-of-concept exploit code or an attack demonstration that is not practical for most systems is available."),
    F: (short: "F", name: "Functional", value: 0.95, description: "Functional exploit code is available. The code works in most situations where the vulnerability exists."),
    H: (short: "H", name: "High", value: 1.0, description: "Either the vulnerability is exploitable by functional mobile autonomous code, or no exploit is required (manual trigger) and details are widely available."),
  )
)

// Remediation Level (RL)
#let rl = (
  name: "Remediation Level",
  short: "RL",
  category: "Temporal",
  description: "This metric measures the remediation level of a vulnerability.",
  values: (
    ND: (short: "ND", name: "Not Defined", value: 1.0, description: "Assigning this value to the metric will not influence the score. It is a signal to the equation to skip this metric."),
    OF: (short: "OF", name: "Official Fix", value: 0.87, description: "A complete vendor solution is available. Either the vendor has issued an official patch, or an upgrade is available."),
    TF: (short: "TF", name: "Temporary Fix", value: 0.9, description: "There is an official but temporary fix available. This includes instances where the vendor issues a temporary hotfix, tool, or workaround."),
    W: (short: "W", name: "Workaround", value: 0.95, description: "There is an unofficial, non-vendor solution available. In some cases, users of the affected technology will create a patch of their own or provide steps to work around or otherwise mitigate the vulnerability."),
    U: (short: "U", name: "Unavailable", value: 1.0, description: "There is either no solution available or it is impossible to apply."),
  )
)

// Report Confidence (RC)
#let rc = (
  name: "Report Confidence",
  short: "RC",
  category: "Temporal",
  description: "This metric measures the degree of confidence in the existence of the vulnerability and the credibility of the known technical details.",
  values: (
    ND: (short: "ND", name: "Not Defined", value: 1.0, description: "Assigning this value to the metric will not influence the score. It is a signal to the equation to skip this metric."),
    UC: (short: "UC", name: "Unconfirmed", value: 0.9, description: "There is little confidence in the existence of this vulnerability. The report is unconfirmed, or the source is not known."),
    UR: (short: "UR", name: "Uncorroborated", value: 0.95, description: "There is reasonable confidence in the existence of this vulnerability, but the technical details are not known publicly."),
    C: (short: "C", name: "Confirmed", value: 1.0, description: "The existence of this vulnerability is confirmed, but the details are not known publicly. An exploit has been observed, or proof-of-concept exploit code is available."),
  )
)

// Environmental Metrics

// Collateral Damage Potential (CDP)
#let cdp = (
  name: "Collateral Damage Potential",
  short: "CDP",
  category: "Environmental",
  subcategory: "General Modifiers",
  description: "This metric measures the potential for loss of life or physical assets resulting from a vulnerability.",
  values: (
    ND: (short: "ND", name: "Not Defined", value: 0.0, description: "Assigning this value to the metric will not influence the score. It is a signal to the equation to skip this metric."),
    N: (short: "N", name: "None", value: 0.0, description: "There is no potential for loss of life, physical assets, productivity or revenue."),
    L: (short: "L", name: "Low", value: 0.1, description: "A successful exploit of this vulnerability may result in slight physical or property damage. Or, there may be a slight loss of revenue or productivity to the organization."),
    LM: (short: "LM", name: "Low-Medium", value: 0.3, description: "A successful exploit of this vulnerability may result in moderate physical or property damage. Or, there may be a moderate loss of revenue or productivity to the organization."),
    MH: (short: "MH", name: "Medium-High", value: 0.4, description: "A successful exploit of this vulnerability may result in significant physical or property damage or loss. Or, there may be a significant loss of revenue or productivity."),
    H: (short: "H", name: "High", value: 0.5, description: "A successful exploit of this vulnerability may result in catastrophic physical or property damage and loss. Or, there may be a catastrophic loss of revenue or productivity."),
  )
)

// Target Distribution (TD)
#let td = (
  name: "Target Distribution",
  short: "TD",
  category: "Environmental",
  subcategory: "General Modifiers",
  description: "This metric measures the proportion of vulnerable systems that could be affected by an attack.",
  values: (
    ND: (short: "ND", name: "Not Defined", value: 1.0, description: "Assigning this value to the metric will not influence the score. It is a signal to the equation to skip this metric."),
    N: (short: "N", name: "None", value: 0.0, description: "There is no (0%) target distribution."),
    L: (short: "L", name: "Low", value: 0.25, description: "There is a small (< 25%) target distribution."),
    M: (short: "M", name: "Medium", value: 0.75, description: "There is a medium (26-75%) target distribution."),
    H: (short: "H", name: "High", value: 1.0, description: "There is a high (> 75%) target distribution."),
  )
)

// Confidentiality Requirement (CR)
#let cr = (
  name: "Confidentiality Requirement",
  short: "CR",
  category: "Environmental",
  subcategory: "Impact Subscore Modifiers",
  description: "This metric measures the need for confidentiality of the vulnerable component to the user.",
  values: (
    ND: (short: "ND", name: "Not Defined", value: 1.0, description: "Assigning this value to the metric will not influence the score. It is a signal to the equation to skip this metric."),
    L: (short: "L", name: "Low", value: 0.5, description: "Loss of confidentiality is likely to have only a limited adverse effect on the organization or individuals associated with the organization."),
    M: (short: "M", name: "Medium", value: 1.0, description: "Loss of confidentiality is likely to have a serious adverse effect on the organization or individuals associated with the organization."),
    H: (short: "H", name: "High", value: 1.51, description: "Loss of confidentiality is likely to have a catastrophic adverse effect on the organization or individuals associated with the organization."),
  )
)

// Integrity Requirement (IR)
#let ir = (
  name: "Integrity Requirement",
  short: "IR",
  category: "Environmental",
  subcategory: "Impact Subscore Modifiers",
  description: "This metric measures the need for integrity of the vulnerable component to a user.",
  values: (
    ND: (short: "ND", name: "Not Defined", value: 1.0, description: "Assigning this value to the metric will not influence the score. It is a signal to the equation to skip this metric."),
    L: (short: "L", name: "Low", value: 0.5, description: "Loss of integrity is likely to have only a limited adverse effect on the organization or individuals associated with the organization."),
    M: (short: "M", name: "Medium", value: 1.0, description: "Loss of integrity is likely to have a serious adverse effect on the organization or individuals associated with the organization."),
    H: (short: "H", name: "High", value: 1.51, description: "Loss of integrity is likely to have a catastrophic adverse effect on the organization or individuals associated with the organization."),
  )
)

// Availability Requirement (AR)
#let ar = (
  name: "Availability Requirement",
  short: "AR",
  category: "Environmental",
  subcategory: "Impact Subscore Modifiers",
  description: "This metric measures the need for availability of the vulnerable component to a user.",
  values: (
    ND: (short: "ND", name: "Not Defined", value: 1.0, description: "Assigning this value to the metric will not influence the score. It is a signal to the equation to skip this metric."),
    L: (short: "L", name: "Low", value: 0.5, description: "Loss of availability is likely to have only a limited adverse effect on the organization or individuals associated with the organization."),
    M: (short: "M", name: "Medium", value: 1.0, description: "Loss of availability is likely to have a serious adverse effect on the organization or individuals associated with the organization."),
    H: (short: "H", name: "High", value: 1.51, description: "Loss of availability is likely to have a catastrophic adverse effect on the organization or individuals associated with the organization."),
  )
)

// Component registry
#let base-components = (av, ac, au, c, i, a)
#let temporal-components = (e, rl, rc)
#let environmental-components = (cdp, td, cr, ir, ar)
#let all-components = base-components + temporal-components + environmental-components
