// ============================================================================
// CVSS Calculator Validation Test Suite - Compact Edition
// Version 0.2.0
// Test vectors sourced from FIRST.org official examples
// ============================================================================
#import "cvssc.typ": *

#set page(margin: (top: 0.6in, bottom: 0.6in, left: 0.5in, right: 0.5in), numbering: "1")
#set text(font: "Inter", size: 8.5pt)

// ============================================================================
// TEST DATA - LOADED FROM VALIDATED JSON
// ============================================================================
#let tests = json("./assets/tests.json")

// ============================================================================
// COVER PAGE - ULTRA COMPACT
// ============================================================================
#align(center)[
  #v(1em)
  #text(size: 20pt, weight: "bold")[CVSS Calculator Validation Suite]
  #v(0.3em)
  #text(size: 10pt, fill: gray)[Comprehensive Testing Report · Version 0.2.0]
  #v(1em)
]

// Calculate stats
#let total-tests = 0
#let passed-tests = 0
#let failed-tests = 0
#let version-stats = (:)

#for (version-name, version-tests) in tests {
  total-tests = total-tests + version-tests.len()
  let v-passed = 0
  let v-failed = 0

  for test in version-tests {
    let result = calc(test.vector)
    if result.base-score == test.expected {
      passed-tests = passed-tests + 1
      v-passed = v-passed + 1
    } else {
      failed-tests = failed-tests + 1
      v-failed = v-failed + 1
    }
  }

  version-stats.insert(version-name, (passed: v-passed, failed: v-failed, total: version-tests.len()))
}

#let pass-rate = int((passed-tests / total-tests) * 1000 + 0.5) / 10.0

// Summary table
#block(
  fill: rgb("#f5f5f5"),
  stroke: rgb("#ddd") + 1pt,
  inset: 1.2em,
  radius: 6pt,
  width: 100%,
)[
  #set text(size: 9pt)
  #grid(
    columns: (1fr, 1fr, 1fr, 1fr),
    gutter: 1.5em,
    align: center,
    [
      #text(size: 28pt, weight: "bold")[#total-tests]
      #v(0.2em)
      #text(size: 9pt, fill: gray)[Total Tests]
    ],
    [
      #text(size: 28pt, weight: "bold", fill: rgb("#2e7d32"))[#passed-tests]
      #v(0.2em)
      #text(size: 9pt, fill: gray)[Passed]
    ],
    [
      #text(size: 28pt, weight: "bold", fill: rgb("#c62828"))[#failed-tests]
      #v(0.2em)
      #text(size: 9pt, fill: gray)[Failed]
    ],
    [
      #text(size: 28pt, weight: "bold", fill: rgb("#1565c0"))[#pass-rate%]
      #v(0.2em)
      #text(size: 9pt, fill: gray)[Pass Rate]
    ],
  )
]

#v(1em)

// Version breakdown
#grid(
  columns: (1fr, 1fr),
  gutter: 0.8em,
  row-gutter: 0.8em,
  ..for (ver, stats) in version-stats {
    let v-rate = int((stats.passed / stats.total) * 1000 + 0.5) / 10.0
    (
      block(
        fill: white,
        stroke: rgb("#ddd") + 1pt,
        inset: 0.9em,
        radius: 4pt,
      )[
        #set text(size: 8.5pt)
        #grid(
          columns: (auto, 1fr),
          gutter: 1em,
          [#text(size: 14pt, weight: "bold")[CVSS #ver]],
          [
            #align(right)[
              #text(fill: rgb("#2e7d32"), weight: "bold")[#stats.passed]/#text(fill: rgb("#c62828"), weight: "bold")[#stats.failed]
              #v(0.1em)
              #text(size: 14pt, weight: "bold")[#v-rate%]
            ]
          ]
        )
      ],
    )
  }
)

#pagebreak()

// ============================================================================
// TEST RESULTS - COMPACT TABLE FORMAT
// ============================================================================
#for (version-name, version-tests) in tests {
  set page(header: [
    #set text(size: 8pt, fill: gray)
    CVSS #version-name Validation
    #h(1fr)
    Page #context counter(page).display("1")
  ])

  let stats = version-stats.at(version-name)
  let v-rate = int((stats.passed / stats.total) * 1000 + 0.5) / 10.0

  // Section header
  block(
    fill: rgb("#37474f"),
    inset: 0.8em,
    width: 100%,
  )[
    #set text(fill: white, size: 14pt, weight: "bold")
    #grid(
      columns: (1fr, auto),
      [CVSS #version-name Tests (#stats.total tests)],
      [
        #set text(size: 11pt)
        #text(fill: rgb("#66bb6a"))[#stats.passed Pass] / #text(fill: rgb("#ef5350"))[#stats.failed Fail] · #v-rate%
      ]
    )
  ]

  v(0.5em)

  // Compact test table
  table(
    columns: (auto, 3.5fr, auto, auto, auto),
    stroke: (x, y) => if y == 0 { (bottom: 1pt + gray) } else { (bottom: 0.5pt + rgb("#eee")) },
    inset: (x: 0.5em, y: 0.4em),
    align: (left, left, center, center, center),

    // Header
    table.cell(fill: rgb("#f5f5f5"), text(weight: "bold", size: 7.5pt)[\#]),
    table.cell(fill: rgb("#f5f5f5"), text(weight: "bold", size: 7.5pt)[Vector / CVE]),
    table.cell(fill: rgb("#f5f5f5"), text(weight: "bold", size: 7.5pt)[Expected]),
    table.cell(fill: rgb("#f5f5f5"), text(weight: "bold", size: 7.5pt)[Actual]),
    table.cell(fill: rgb("#f5f5f5"), text(weight: "bold", size: 7.5pt)[Status]),

    // Test rows
    ..for (i, test) in version-tests.enumerate() {
      let result = calc(test.vector)
      let passed = result.base-score == test.expected
      let row-fill = if i.bit-and(1) == 0 { white } else { rgb("#fafafa") }

      (
        table.cell(fill: row-fill, text(size: 7.5pt, fill: gray)[#(i + 1)]),
        table.cell(fill: row-fill, {
          set text(size: 7pt, font: "Lilex Nerd Font")
          result.vector
          linebreak()
          set text(size: 6.5pt, fill: gray, font: "Inter")
          [Test #(i + 1)]
        }),
        table.cell(fill: row-fill, text(size: 9pt, weight: "bold")[#test.expected]),
        table.cell(fill: row-fill, {
          let color = if result.base-score == none { gray }
                      else if result.base-score < 4.0 { rgb("#fbc02d") }
                      else if result.base-score < 7.0 { rgb("#f57c00") }
                      else if result.base-score < 9.0 { rgb("#d32f2f") }
                      else { rgb("#7b1fa2") }
          text(size: 9pt, weight: "bold", fill: color)[
            #if result.base-score != none [#result.base-score] else [N/A]
          ]
        }),
        table.cell(fill: row-fill, {
          if passed {
            text(fill: rgb("#2e7d32"), weight: "bold", size: 8pt)[✓]
          } else {
            text(fill: rgb("#c62828"), weight: "bold", size: 8pt)[✗]
          }
        }),
      )
    }
  )

  pagebreak()
}

// ============================================================================
// FINAL SUMMARY
// ============================================================================
#set page(header: none)

#align(center)[
  #v(2em)
  #text(size: 18pt, weight: "bold")[Test Execution Complete]
  #v(1em)
]

#block(
  fill: if pass-rate >= 80 { rgb("#2e7d32").lighten(85%) }
        else if pass-rate >= 60 { rgb("#f57c00").lighten(85%) }
        else { rgb("#c62828").lighten(85%) },
  stroke: if pass-rate >= 80 { rgb("#2e7d32") + 2pt }
          else if pass-rate >= 60 { rgb("#f57c00") + 2pt }
          else { rgb("#c62828") + 2pt },
  inset: 1.5em,
  radius: 6pt,
  width: 100%,
)[
  #set align(center)
  #text(size: 14pt, weight: "bold")[Overall Result]
  #v(0.8em)
  #text(size: 36pt, weight: "bold")[
    #if pass-rate >= 80 [✓] else if pass-rate >= 60 [~] else [✗]
  ]
  #v(0.5em)
  #text(size: 18pt, weight: "bold")[#pass-rate% Pass Rate]
  #v(0.8em)
  #text(size: 9pt, fill: gray)[
    #passed-tests passed · #failed-tests failed · #total-tests total tests
  ]
]

#v(1em)

#text(size: 11pt, weight: "bold")[Recommendations:]
#v(0.3em)

#if pass-rate >= 95 [
  #box(fill: rgb("#2e7d32").lighten(90%), inset: 0.8em, radius: 4pt, width: 100%)[
    ✓ *Excellent:* Calculator implementations are highly accurate and production-ready.
  ]
] else if pass-rate >= 80 [
  #box(fill: rgb("#f57c00").lighten(90%), inset: 0.8em, radius: 4pt, width: 100%)[
    ~ *Good:* Most tests passing. Review failed tests for edge cases and modified metrics.
  ]
] else [
  #box(fill: rgb("#c62828").lighten(90%), inset: 0.8em, radius: 4pt, width: 100%)[
    ✗ *Needs Work:* Significant issues detected. Focus areas:
    - CVSS v4.0 severity distance calculations
    - Modified/Environmental metric handling
    - Edge case scenarios
  ]
]

#v(1em)
#align(center)[
  #text(size: 7.5pt, fill: gray)[
    Test vectors sourced from FIRST.org official examples and reference implementations
  ]
]
