#import "@preview/cvssc:0.2.0": *

// ============================================================================
// CVSS Calculator Library - Comprehensive Test Suite
// Version 0.2.0
// ============================================================================

#set page(margin: 1in, numbering: "1")
#set text(font: "Noto Sans", size: 10pt)
#set heading(numbering: "1.")

#align(center)[
  #text(size: 18pt, weight: "bold")[CVSS Calculator Library Tests]
  #v(0.5em)
  #text(size: 12pt, fill: rgb("#64748b"))[Version 0.2.0]
  #v(1em)
]

= Test 1: CVSS 2.0 Calculations

== High Severity Example
#let v2_high = calc("CVSS:2.0/AV:L/AC:L/Au:N/C:C/I:C/A:C")

*Badge:* #v2_high.badge

*Vector:* #v2_high.vector

*Scores:*
- Base Score: #v2_high.base-score
- Severity: #v2_high.severity

*Visualization:*

#v2_high.graph

#pagebreak()

== Medium Severity Example
#let v2_medium = calc("CVSS:2.0/AV:N/AC:M/Au:N/C:P/I:P/A:N")

*Badge:* #v2_medium.badge-with-score

*Scores:*
- Base Score: #v2_medium.base-score
- Severity: #v2_medium.severity

*Visualization:*

#v2_medium.graph

#pagebreak()

= Test 2: CVSS 3.0 Calculations

== Critical Severity Example
#let v30_critical = calc("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H")

*Badge:* #v30_critical.badge-with-score

*Vector:* #v30_critical.vector

*Scores:*
- Base Score: #v30_critical.base-score
- Severity: #v30_critical.severity

*Visualization:*

#v30_critical.graph

#pagebreak()

= Test 3: CVSS 3.1 Calculations

== Critical Severity Example (Classic Remote Code Execution)
#let v31_critical = calc("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H")

*Badge:* #v31_critical.badge-with-score

*Vector:* #v31_critical.vector

*Scores:*
- Base Score: #v31_critical.base-score
- Severity: #v31_critical.severity
- Exploitability: #v31_critical.at("exploitability-score", default: "N/A")
- Impact: #v31_critical.at("impact-score", default: "N/A")

*Visualization:*

#v31_critical.graph

#pagebreak()

== High Severity Example
#let v31_high = calc("CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:N")

*Badge:* #v31_high.badge-with-score

*Scores:*
- Base Score: #v31_high.base-score
- Severity: #v31_high.severity

*Visualization:*

#v31_high.graph

#pagebreak()

== Medium Severity Example
#let v31_medium = calc("CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:L/I:L/A:N")

*Badge:* #v31_medium.badge-with-score

*Scores:*
- Base Score: #v31_medium.base-score
- Severity: #v31_medium.severity

*Visualization:*

#v31_medium.graph

#pagebreak()

== Low Severity Example
#let v31_low = calc("CVSS:3.1/AV:L/AC:H/PR:H/UI:R/S:U/C:L/I:N/A:N")

*Badge:* #v31_low.badge-with-score

*Scores:*
- Base Score: #v31_low.base-score
- Severity: #v31_low.severity

*Visualization:*

#v31_low.graph

#pagebreak()

= Test 4: CVSS 4.0 Calculations

== Critical Severity Example
#let v4_critical = calc("CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H")

*Badge:* #v4_critical.badge-with-score

*Vector:* #v4_critical.vector

*Scores:*
- Base Score: #v4_critical.base-score
- Severity: #v4_critical.severity

*Visualization:*

#v4_critical.graph

#pagebreak()

== High Severity Example
#let v4_high = calc("CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N")

*Badge:* #v4_high.badge-with-score

*Scores:*
- Base Score: #v4_high.base-score
- Severity: #v4_high.severity

*Visualization:*

#v4_high.graph

#pagebreak()

= Test 5: Dictionary Input Format

#let dict_input = calc((
  version: "3.1",
  metrics: (
    "AV": "N",
    "AC": "L",
    "PR": "N",
    "UI": "N",
    "S": "U",
    "C": "H",
    "I": "H",
    "A": "H"
  )
))

*Badge:* #dict_input.badge-with-score

*Vector:* #dict_input.vector

*Scores:*
- Base Score: #dict_input.base-score
- Severity: #dict_input.severity

*Visualization:*

#dict_input.graph

#pagebreak()

= Test 6: Utility Functions

== str2vec Function
#let parsed = str2vec("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H")

*Input:* `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`

*Parsed Result:*
- Version: #parsed.version
- Metrics: #repr(parsed.metrics)

== vec2str Function
#let vec = (
  version: "3.1",
  metrics: (
    "AV": "N", "AC": "L",
    "PR": "N", "UI": "N",
    "S": "U", "C": "H",
    "I": "H", "A": "H"
  )
)

*Input Dictionary:* #repr(vec)

*String Output:* #vec2str(vec)

== kebab-case Function
- `helloWorld` → #kebab-case("helloWorld")
- `testCaseExample` → #kebab-case("testCaseExample")
- `CVSSVector` → #kebab-case("CVSSVector")

== get-version Function
- `get-version("CVSS:2.0/...")` → #get-version("CVSS:2.0/AV:L/AC:L/Au:N/C:C/I:C/A:C")
- `get-version("CVSS:3.0/...")` → #get-version("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N")
- `get-version("CVSS:3.1/...")` → #get-version("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H")
- `get-version("CVSS:4.0/...")` → #get-version("CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H")

#pagebreak()

= Test 7: All Severity Levels Side-by-Side

== Low (Score: 3.3)
#let low_score = calc("CVSS:3.1/AV:P/AC:H/PR:H/UI:R/S:U/C:L/I:L/A:N")
*Badge:* #low_score.badge-with-score | *Score:* #low_score.base-score

== Medium (Score: 6.5)
#let medium_score = calc("CVSS:3.1/AV:N/AC:L/PR:L/UI:R/S:U/C:H/I:L/A:N")
*Badge:* #medium_score.badge-with-score | *Score:* #medium_score.base-score

== High (Score: 8.1)
#let high_score = calc("CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H")
*Badge:* #high_score.badge-with-score | *Score:* #high_score.base-score

== Critical (Score: 9.8)
#let critical_score = calc("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H")
*Badge:* #critical_score.badge-with-score | *Score:* #critical_score.base-score

#pagebreak()

= Test Summary

All tests demonstrate:
1. ✓ CVSS 2.0 calculations with hexagon graph (6 base metrics)
2. ✓ CVSS 3.0 calculations with octagon graph (8 base metrics)
3. ✓ CVSS 3.1 calculations with octagon graph (8 base metrics)
4. ✓ CVSS 4.0 calculations with 11-sided graph (11 base metrics)
5. ✓ Badge as content (not a function)
6. ✓ Graph method (renamed from display)
7. ✓ Dictionary input format
8. ✓ Utility functions (str2vec, vec2str, kebab-case, get-version)
9. ✓ All severity levels (Low, Medium, High, Critical)
10. ✓ Shape changes based on number of base metrics
11. ✓ Severity-based colors for data polygons
12. ✓ Darker grid for better readability
13. ✓ Clean, polished graphs with no background
14. ✓ Metric labels combined with values (e.g., AV:N)

*Library Version:* #cvss-version
