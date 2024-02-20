
#let _cvss = plugin("cvss.wasm")

#let get-result(
  got,
  expected,
) = {
  let lower-end = expected - 0.11
  let upper-end = expected + 0.11

  if got >= lower-end and got <= upper-end {
    text(fill: green.darken(30%), weight: 900, "PASS")
  } else {
    text(fill: red, weight: 900, "FAIL")
  }
}
#let test(
  vec,
  expected,
) = {
  let score = float(str(_cvss.score(bytes(vec))))
  let severity = str(_cvss.severity(bytes(vec)))
  // assert(score == expected, message: "expected score " + str(expected) + " but got " + str(score))
  block(
    breakable: false,
    inset: 0.5em,
    stroke: 1pt + black,
    radius: 0.25em,
    width: 100%,
    fill: gray.lighten(50%),
    [
    // === #vec
    // / Score: #score
    // / Expected: #expected
    // / Severity: #severity
    // / Result: #get-result(score, expected)
    #align(center, heading(level: 3, vec))
    #v(-0.5em)
    #table(
      columns: (1fr, 1fr, 1fr, 1fr),
      align: center,
      stroke: none,
      [*Score*], [*Severity*], [*Expected*], [*Result*],
      [#score], severity, [#expected], get-result(score, expected)
    )
  ])
}

== CVSS v2.0 tests

CVSS v2.0 Severity steps
- 0.0 - None
- 0.1 - 3.9 Low
- 4.0 - 6.9 Medium
- 7.0 - 10.0 High

  
// CVSS v2.0 tests
#test("CVSS:2.0/AV:L/AC:L/Au:M/C:N/I:N/A:N", 0)
#test("CVSS:2.0/AV:L/AC:H/Au:M/C:N/I:N/A:P", 0.9)
#test("CVSS:2.0/AV:L/AC:H/Au:M/C:N/I:N/A:C", 3.7)
#test("CVSS:2.0/AV:L/AC:H/Au:M/C:N/I:P/A:P", 2.4)
#test("CVSS:2.0/AV:L/AC:H/Au:M/C:N/I:P/A:C", 4.4)
#test("CVSS:2.0/AV:L/AC:H/Au:M/C:N/I:C/A:C", 5.3)
#test("CVSS:2.0/AV:L/AC:H/Au:M/C:P/I:C/A:C", 5.6)
#test("CVSS:2.0/AV:L/AC:H/Au:N/C:P/I:C/A:C", 5.9)
#test("CVSS:2.0/AV:L/AC:L/Au:N/C:P/I:C/A:C", 6.8)
#test("CVSS:2.0/AV:N/AC:L/Au:N/C:P/I:C/A:C", 9.7)


// CVSS v3.0 tests
CVSS v3.0 Severity steps
- 0.0 - None
- 0.1 - 3.9 Low
- 4.0 - 6.9 Medium
- 7.0 - 8.9 High
- 9.0 - 10.0 Critical

#test("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N", 0)
#test("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:L", 5.3)
#test("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H", 7.5)
#test("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:L/A:L", 6.5)
#test("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H", 8.6)
#test("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H", 9.8)
#test("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:C/C:L/I:L/A:N", 7.2)

// CVSS v3.1 tests
CVSS v3.1 Severity steps
- 0.0 - None
- 0.1 - 3.9 Low
- 4.0 - 6.9 Medium
- 7.0 - 8.9 High
- 9.0 - 10.0 Critical

#test("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N", 0)
#test("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:L", 5.3)
#test("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:H", 7.5)
#test("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:L/A:L", 6.5)
#test("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:L/A:H", 8.6)
#test("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H", 9.8)
#test("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:L/I:L/A:N", 7.2)


// CVSS v4.0 tests
#test(
  "CVSS:4.0/AV:L/AC:H/AT:N/PR:L/UI:A/VC:N/VI:L/VA:L/SC:N/SI:N/SA:N",
  1.0
),
#test(
  "CVSS:4.0/AV:A/AC:H/AT:P/PR:H/UI:A/VC:H/VI:H/VA:L/SC:L/SI:L/SA:L",
  5.3
),
#test(
  "CVSS:4.0/AV:N/AC:H/AT:P/PR:L/UI:P/VC:H/VI:H/VA:L/SC:L/SI:L/SA:L",
  7.5
),
#test(
  "CVSS:4.0/AV:A/AC:H/AT:P/PR:L/UI:P/VC:H/VI:H/VA:L/SC:L/SI:L/SA:L",
  5.3
),
#test(
  "CVSS:4.0/AV:A/AC:L/AT:N/PR:L/UI:P/VC:H/VI:H/VA:L/SC:L/SI:L/SA:L",
  6.9
),
#test(
  "CVSS:4.0/AV:A/AC:L/AT:N/PR:N/UI:P/VC:H/VI:H/VA:L/SC:L/SI:L/SA:L",
  8.6
),
#test(
  "CVSS:4.0/AV:A/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:L/SC:L/SI:L/SA:L",
  8.7
),
#test(
  "CVSS:4.0/AV:L/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:L/SC:L/SI:L/SA:L",
  8.6
),
#test(
  "CVSS:4.0/AV:L/AC:L/AT:N/PR:H/UI:N/VC:H/VI:H/VA:L/SC:L/SI:L/SA:L",
  8.3
),
#test(
  "CVSS:4.0/AV:L/AC:L/AT:N/PR:H/UI:N/VC:H/VI:H/VA:L/SC:H/SI:L/SA:L",
  9.2
),
#test(
  "CVSS:4.0/AV:L/AC:L/AT:N/PR:H/UI:A/VC:N/VI:N/VA:L/SC:H/SI:L/SA:L",
  4.4
),
#test(
  "CVSS:4.0/AV:L/AC:L/AT:P/PR:H/UI:A/VC:N/VI:N/VA:N/SC:H/SI:L/SA:L",
  2.1
),
#test(
  "CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H",
  10.0
),
// currently not working with M+METRIC scores
#test(
  "CVSS:4.0/AV:L/AC:L/AT:P/PR:H/UI:A/VC:N/VI:N/VA:N/SC:H/SI:L/SA:L/MAV:N",
  4.5
),
#test(
  "CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:N/SC:N/SI:N/SA:N/E:A/CR:H/IR:M/AR:L/MSC:L/MSI:H/MSA:L",
  7.8
),
#test(
  "CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:N/SC:N/SI:N/SA:N/E:A/CR:H/IR:M/AR:L/MAC:L/MAT:P/MUI:N/MSC:L/MSI:H/MSA:L",
  7.0
),
#test(
  "CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:L/VA:L/SC:N/SI:H/SA:N/E:A/CR:H/IR:M/AR:L/MAC:L/MAT:P/MUI:N/MSC:L/MSI:H/MSA:L/S:P/AU:N/R:U/V:C/RE:L",
  7.0
),
#test(
  "CVSS:4.0/AV:L/AC:H/AT:N/PR:L/UI:A/VC:N/VI:L/VA:L/SC:N/SI:H/SA:N/E:A/CR:H/IR:M/AR:L/MAC:L/MAT:P/MUI:N/MSC:L/MSI:H/MSA:L/S:P/AU:N/R:U/V:C/RE:L",
  4.8
)


