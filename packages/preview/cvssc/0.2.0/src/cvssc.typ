// CVSS Calculator Library - Main API
// Version 0.2.0
// MIT License

#import "v2/calculator.typ" as cvss2-calc
#import "v3/v30.typ" as cvss30-calc
#import "v3/v31.typ" as cvss31-calc
#import "v4/calculator.typ" as cvss4-calc
#import "visualization.typ": draw-v2-graph, draw-v3-graph, draw-v4-graph
#import "constants.typ": severity-colors, chart-colors, specifications, get-severity-from-score

// ============================================================================
// STATE MANAGEMENT - Configurable Colors
// ============================================================================

#let cvss-colors = state("cvss-colors", severity-colors + chart-colors)

/// Update CVSS color scheme
///
/// #example(```
/// set-colors((
///   "critical": rgb("#ff0000"),
///   "chart-stroke": rgb("#0000ff")
/// ))
/// ```)
#let set-colors(new-colors) = {
  cvss-colors.update(colors => {
    let updated = colors
    for (key, value) in new-colors {
      updated.insert(key, value)
    }
    updated
  })
}

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/// Convert CVSS string to vector dictionary
///
/// #example(`str2vec("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N")`)
///
/// - s (string): The CVSS string to convert
/// -> dictionary
#let str2vec(s) = {
  if type(s) != str {
    return ("error": "Input must be a string")
  }
  let re = regex("CVSS:([0-9.]+)/(.+)")
  let match = s.match(re)
  if match == none {
    return ("error": "Invalid CVSS string format")
  }
  let version = match.at("captures", default: ("4.0",)).at(0)
  let metrics = match.at("captures", default: ("",)).at(1)
  let pairs = metrics.split("/")
  let result = pairs.fold(
    (:),
    (c, it) => {
      let pair = it.split(":")
      if pair.len() != 2 { return c }
      let k = pair.at(0)
      let v = pair.at(1)
      c + ((k): v)
    },
  )
  (version: version, metrics: result)
}

/// Convert CVSS dictionary to string
///
/// #example(```
/// vec2str((
///   version: "3.0",
///   metrics: (
///     "AV": "N", "AC": "L",
///     "PR": "N", "UI": "N",
///     "S": "U", "C": "N",
///     "I": "N", "A": "N"
///   )
/// ))```)
///
/// - vec (dictionary): The CVSS dictionary to convert
/// -> string
#let vec2str(vec) = {
  let version = vec.at("version", default: "4.0")
  let metrics = vec.at("metrics", default: (:))
  let result = "CVSS:" + version + "/"
  result += metrics
    .pairs()
    .map(it => {
      let (k, v) = it
      k + ":" + v
    })
    .join("/")
  result
}

/// Convert string from camelCase to kebab-case
///
/// #example(`kebab-case("helloWorld")`)
///
/// - string (string): The string to convert
/// -> string
#let kebab-case(string) = {
  if type(string) != str { return ("error": "Input must be a string") }
  string
    .codepoints()
    .enumerate()
    .fold(
      (),
      (it, pair) => {
        let (i, c) = pair
        if c.match(regex("[A-Z]")) != none and i != 0 {
          it.push("-")
        }
        it + (lower(c),)
      },
    )
    .join("")
}

/// Convert dictionary keys from camelCase to kebab-case
///
/// #example(```
/// kebabify-keys((
///   "somethingElse": "else",
///   "anotherThing": "thing",
///   "helloWorld": "world"
/// ))```)
///
/// - input (dictionary): The dictionary to convert
/// -> dictionary
#let kebabify-keys(input) = {
  if type(input) != dictionary { return ("error": "Input must be a dictionary") }
  input
    .pairs()
    .fold(
      (:),
      (it, pair) => {
        let (k, v) = pair
        it + ((kebab-case(k)): v)
      },
    )
}

/// Extract version from CVSS string
///
/// #example(`get-version("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N")`)
///
/// - input (string): The CVSS string
/// -> string
#let get-version(input) = {
  if type(input) != str {
    return ("error": "Input must be a string")
  }
  let re = regex("CVSS:([0-9.]+)/(.+)")
  let match = input.match(re)
  if match == none {
    return "4.0"
  }
  let version = match.at("captures", default: ("4.0",)).at(0)
  version
}

// Note: specifications and get-severity-from-score are now imported from constants.typ

// ============================================================================
// RADAR CHART VISUALIZATION
// ============================================================================

/// Draw a hexagonal radar chart for CVSS scores
#let draw-radar-chart(scores, size: 200pt) = {
  context {
    let colors = cvss-colors.get()

    // Extract score values (0-10 scale)
    let base = scores.at("base-score", default: 0)
    let temporal = scores.at("temporal-score", default: 0)
    let environmental = scores.at("environmental-score", default: 0)

    // Calculate sub-scores for visualization
    // For v3.x these are available, for v2/v4 we approximate
    let exploitability = if scores.at("exploitability-score", default: none) != none {
      scores.at("exploitability-score")
    } else {
      base * 0.4  // Approximate as 40% of base
    }

    let impact = if scores.at("impact-score", default: none) != none {
      scores.at("impact-score")
    } else {
      base * 0.6  // Approximate as 60% of base
    }

    let adj-impact = environmental

    // Normalize all values to 0-10 scale
    let values = (
      base: calc.min(if base == none { 0 } else { base }, 10),
      temporal: calc.min(if temporal == none { 0 } else { temporal }, 10),
      environmental: calc.min(if environmental == none { 0 } else { environmental }, 10),
      exploitability: calc.min(if exploitability == none { 0 } else { exploitability }, 10),
      impact: calc.min(if impact == none { 0 } else { impact }, 10),
      adj-impact: calc.min(if adj-impact == none { 0 } else { adj-impact }, 10),
    )

    // Hexagon vertices (6 points, starting from top)
    let labels = ("Base", "Adj. Impact", "Impact", "Temporal", "Exploitability", "Environmental")
    let data = (values.base, values.adj-impact, values.impact, values.temporal, values.exploitability, values.environmental)

    let center = (size / 2, size / 2)
    let radius = size * 0.35

    // Calculate polygon points
    let angle-step = 360deg / 6
    let start-angle = -90deg  // Start at top

    let get-point(value, index) = {
      let angle = start-angle + angle-step * index
      let r = radius * (value / 10.0)
      let x = center.at(0) + r * calc.cos(angle)
      let y = center.at(1) + r * calc.sin(angle)
      (x, y)
    }

    let get-grid-point(level, index) = {
      let angle = start-angle + angle-step * index
      let r = radius * (level / 10.0)
      let x = center.at(0) + r * calc.cos(angle)
      let y = center.at(1) + r * calc.sin(angle)
      (x, y)
    }

    // Build the chart
    box(
      width: size,
      height: size,
      {
        // Background
        place(
          rect(
            width: 100%,
            height: 100%,
            fill: colors.chart-bg,
            radius: 4pt,
          )
        )

        // Draw grid circles
        for level in (2, 4, 6, 8, 10) {
          let points = range(7).map(i => get-grid-point(level, i))
          place(
            polygon(
              ..points,
              stroke: (paint: colors.chart-grid, thickness: 0.5pt),
              fill: none,
            )
          )
        }

        // Draw axes from center to vertices
        for i in range(6) {
          let endpoint = get-grid-point(10, i)
          place(
            line(
              start: center,
              end: endpoint,
              stroke: (paint: colors.chart-grid, thickness: 0.5pt),
            )
          )
        }

        // Draw data polygon
        let data-points = range(7).map(i => {
          let idx = calc.rem(i, 6)
          get-point(data.at(idx), idx)
        })

        place(
          polygon(
            ..data-points,
            fill: colors.chart-fill,
            stroke: (paint: colors.chart-stroke, thickness: 2pt),
          )
        )

        // Draw labels
        for i in range(6) {
          let angle = start-angle + angle-step * i
          let label-radius = radius * 1.25
          let x = center.at(0) + label-radius * calc.cos(angle)
          let y = center.at(1) + label-radius * calc.sin(angle)

          place(
            dx: x - size * 0.1,
            dy: y - 6pt,
            text(
              size: 8pt,
              fill: colors.chart-text,
              labels.at(i)
            )
          )
        }

        // Draw scale labels
        for level in (0, 2, 4, 6, 8, 10) {
          let pt = get-grid-point(level, 0)
          place(
            dx: center.at(0) + 4pt,
            dy: pt.at(1) - 6pt,
            text(
              size: 7pt,
              fill: colors.chart-text,
              str(level)
            )
          )
        }
      }
    )
  }
}

// ============================================================================
// CVSS OBJECT WITH DISPLAY METHOD
// ============================================================================

/// Create a CVSS result object with graph and badge display capabilities
#let make-cvss-object(scores) = {
  let version = scores.at("version", default: "4.0")
  let metrics = scores.at("metrics", default: (:))

  // Add graph method and badge content to scores dictionary
  scores + (
    // Graph method - version-specific visualization
    graph: {
      context {
        let colors = cvss-colors.get()
        if version == "2.0" {
          draw-v2-graph(scores, metrics, colors: colors)
        } else if version == "3.0" or version == "3.1" {
          draw-v3-graph(scores, metrics, colors: colors)
        } else if version == "4.0" {
          draw-v4-graph(scores, metrics, colors: colors)
        }
      }
    },

    // Badge - severity only (better for inline text)
    badge: context {
      let colors = cvss-colors.get()
      let severity = scores.at("severity", default: "NONE")
      let color = colors.at(lower(severity), default: colors.at("none"))

      box(
        fill: color,
        baseline: 0pt,
        inset: (x: 3pt, y: 0pt),
        outset: (y: 3pt),
        radius: 2.5pt,
        align(center + horizon, {
          set text(size: 9pt, weight: 700, fill: white)
          upper(severity)
        })
      )
    },

    // Badge with score - severity and numeric score
    badge-with-score: context {
      let colors = cvss-colors.get()
      let score-val = scores.at("overall-score", default: 0)
      let severity = scores.at("severity", default: "NONE")
      let color = colors.at(lower(severity), default: colors.at("none"))

      box(
        fill: color,
        baseline: -1pt,
        inset: (x: 3pt, y: 0pt),
        outset: (y: 3pt),
        radius: 2.5pt,
        align(center + horizon, {
          set text(size: 9pt, weight: 700, fill: white)
          upper(severity) + " " + str(score-val)
        })
      )
    }
  )
}

// ============================================================================
// VERSION-SPECIFIC CALCULATORS
// ============================================================================

/// Calculate CVSS v2.0 scores
///
/// #example(`v2("CVSS:2.0/AV:L/AC:L/Au:N/C:C/I:C/A:C")`)
///
/// - vec (string, dictionary): The CVSS string or dictionary to convert
/// -> dictionary
#let v2(vec) = {
  if type(vec) == dictionary {
    vec = vec2str(vec)
  }
  if type(vec) != str {
    return ("error": "Input must be a string or a dictionary")
  }

  let parsed = str2vec(vec)
  if parsed.at("error", default: none) != none {
    return parsed
  }

  let version = parsed.at("version", default: "2.0")
  let metrics-dict = cvss2-calc.parse-vector(vec)

  let result = cvss2-calc.calculate-scores(metrics-dict)

  result.insert("metrics", parsed.metrics)
  result.insert("version", version)
  result.insert("vector", vec)
  result.insert("specification-document", specifications.at(version, default: specifications.at("2.0")))

  if result.at("base-score", default: none) == none {
    result.insert("error", "Invalid or incomplete CVSS vector")
    return result
  }

  make-cvss-object(result)
}

/// Calculate CVSS v3.0 or v3.1 scores
///
/// #example(`v3("CVSS:3.0/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N")`)
/// #example(`v3("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:N/A:N")`)
///
/// - vec (string, dictionary): The CVSS string or dictionary to convert
/// -> dictionary
#let v3(vec) = {
  if type(vec) == dictionary {
    vec = vec2str(vec)
  }
  if type(vec) != str {
    return ("error": "Input must be a string or a dictionary")
  }

  let parsed = str2vec(vec)
  if parsed.at("error", default: none) != none {
    return parsed
  }

  let version = parsed.at("version", default: "3.1")
  let metrics-dict = if version == "3.0" {
    cvss30-calc.parse-vector(vec)
  } else {
    cvss31-calc.parse-vector(vec)
  }

  let result = if version == "3.0" {
    cvss30-calc.calculate-scores(metrics-dict)
  } else {
    cvss31-calc.calculate-scores(metrics-dict)
  }

  result.insert("metrics", parsed.metrics)
  result.insert("version", version)
  result.insert("vector", vec)
  result.insert("specification-document", specifications.at(version, default: specifications.at("3.1")))

  if result.at("base-score", default: none) == none {
    result.insert("error", "Invalid or incomplete CVSS vector")
    return result
  }

  make-cvss-object(result)
}

/// Calculate CVSS v4.0 scores
///
/// #example(`v4("CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:N/SC:N/SI:N/SA:N")`)
///
/// - vec (string, dictionary): The CVSS string or dictionary to convert
/// -> dictionary
#let v4(vec) = {
  if type(vec) == dictionary {
    vec = vec2str(vec)
  }
  if type(vec) != str {
    return ("error": "Input must be a string or a dictionary")
  }

  let parsed = str2vec(vec)
  if parsed.at("error", default: none) != none {
    return parsed
  }

  let version = parsed.at("version", default: "4.0")
  let metrics-dict = cvss4-calc.parse-vector(vec)

  let result = cvss4-calc.calculate-scores(metrics-dict)

  result.insert("metrics", parsed.metrics)
  result.insert("version", version)
  result.insert("vector", vec)
  result.insert("specification-document", specifications.at(version, default: specifications.at("4.0")))

  if result.at("base-score", default: none) == none {
    result.insert("error", "Invalid or incomplete CVSS vector")
    return result
  }

  make-cvss-object(result)
}

/// Calculate CVSS scores (auto-detect version)
///
/// Supports CVSS v2.0, v3.0, v3.1, and v4.0. Automatically determines the version.
///
/// #example(`calc("CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:N/VI:N/VA:N/SC:N/SI:N/SA:N")`)
/// #example(```
/// calc((
///   version: "3.1",
///   metrics: (
///     "AV": "N",
///     "AC": "L",
///     "PR": "N",
///     "UI": "N",
///     "S": "U",
///     "C": "N",
///     "I": "N",
///     "A": "N"
///   )
/// ))```)
///
/// - vec (string, dictionary): The CVSS string or dictionary to convert
/// -> dictionary
#let calc(vec) = {
  if type(vec) == dictionary {
    vec = vec2str(vec)
  }
  if type(vec) != str {
    return ("error": "Input must be a string or a dictionary")
  }

  let version = get-version(vec)

  if version == "2.0" {
    return v2(vec)
  } else if version == "3.0" {
    return v3(vec)
  } else if version == "3.1" {
    return v3(vec)
  } else if version == "4.0" {
    return v4(vec)
  } else {
    return ("error": "Invalid or unsupported CVSS version: " + version)
  }
}


#let guide = json("assets/cvss.json")
