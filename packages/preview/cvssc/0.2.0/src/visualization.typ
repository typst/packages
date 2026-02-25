// CVSS Visualization Functions
// Specialized graphs for each CVSS version using native Typst

#import "constants.typ": severity-colors, chart-colors

// Default color scheme (will be overridden by state in main.typ)
#let default-colors = severity-colors + chart-colors

// Helper function to convert polar to Cartesian coordinates
#let polar-to-xy(center-x, center-y, angle-deg, radius) = {
  let angle-rad = angle-deg * calc.pi / 180
  let x = center-x + radius * calc.cos(angle-rad)
  let y = center-y + radius * calc.sin(angle-rad)
  (x, y)
}

// ============================================================================
// CVSS 2.0 RADAR CHART (Hexagon - 6 base metrics)
// ============================================================================

/// Draw CVSS 2.0 radar chart (6 base metrics)
#let draw-v2-graph(scores, metrics, size: 240pt, colors: default-colors) = {
  // Convert CVSS 2.0 metrics to 0-10 scale
  let convert-v2-metric(val, metric-type) = {
    if metric-type == "AV" {
      if val == "L" { 3.0 }
      else if val == "A" { 6.0 }
      else if val == "N" { 10.0 }
      else { 0.0 }
    } else if metric-type == "AC" {
      if val == "H" { 3.5 }
      else if val == "M" { 6.0 }
      else if val == "L" { 7.7 }
      else { 0.0 }
    } else if metric-type == "Au" {
      if val == "M" { 4.5 }
      else if val == "S" { 5.6 }
      else if val == "N" { 7.0 }
      else { 0.0 }
    } else if metric-type in ("C", "I", "A") {
      if val == "N" { 0.0 }
      else if val == "P" { 2.75 }
      else if val == "C" { 6.6 }
      else { 0.0 }
    } else { 5.0 }
  }

  // Get metric values (6 base metrics)
  let labels = ("AV", "AC", "Au", "C", "I", "A")
  let data = labels.map(label => convert-v2-metric(metrics.at(label, default: "N"), label))
  let n-points = labels.len()

  // Get severity-based colors
  let severity = lower(scores.at("severity", default: "none"))
  let severity-color = colors.at(severity)
  let data-fill = severity-color.transparentize(75%)
  let data-stroke = severity-color

  let center-x = size / 2
  let center-y = size / 2
  let radius = size * 0.32
  let angle-step = 360 / n-points
  let start-angle = -90

  box(width: size, height: size, {
    // Draw grid hexagons (dotted)
    for level in (2.5, 5, 7.5, 10) {
      let pts = ()
      for i in range(n-points + 1) {
        let angle = start-angle + angle-step * calc.rem(i, n-points)
        pts.push(polar-to-xy(center-x, center-y, angle, radius * level / 10))
      }
      place(polygon(..pts, stroke: (paint: colors.at("chart-grid"), thickness: 1pt, dash: "dotted"), fill: none))
    }

    // Draw axes
    for i in range(n-points) {
      let angle = start-angle + angle-step * i
      let endpoint = polar-to-xy(center-x, center-y, angle, radius)
      place(line(start: (center-x, center-y), end: endpoint, stroke: (paint: colors.at("chart-grid"), thickness: 1pt)))
    }

    // Draw data polygon
    let data-pts = ()
    for i in range(n-points + 1) {
      let idx = calc.rem(i, n-points)
      let angle = start-angle + angle-step * idx
      data-pts.push(polar-to-xy(center-x, center-y, angle, radius * data.at(idx) / 10))
    }
    place(polygon(..data-pts, fill: data-fill, stroke: (paint: data-stroke, thickness: 0pt)))

    // Draw metric labels
    for i in range(n-points) {
      let angle = start-angle + angle-step * i
      let label-pos = polar-to-xy(center-x, center-y, angle, radius * 1.2)
      let metric-label = labels.at(i) + ":" + metrics.at(labels.at(i), default: "-")

      place(
        dx: label-pos.at(0),
        dy: label-pos.at(1),
        box(
          width: 0pt,
          height: 0pt,
          align(center + horizon,
            text(size: 8pt, weight: "bold", fill: colors.at("chart-text"), metric-label)
          )
        )
      )
    }
  })
}

// ============================================================================
// CVSS 3.x RADAR CHART (Octagon - 8 base metrics)
// ============================================================================

/// Draw CVSS 3.x radar chart (8 base metrics)
#let draw-v3-graph(scores, metrics, size: 240pt, colors: default-colors) = {
  // Convert CVSS 3.x metrics to 0-10 scale
  let convert-v3-metric(val, metric-type) = {
    if metric-type == "AV" {
      if val == "P" { 2.0 }
      else if val == "L" { 5.5 }
      else if val == "A" { 6.2 }
      else if val == "N" { 8.5 }
      else { 0.0 }
    } else if metric-type == "AC" {
      if val == "H" { 4.4 }
      else if val == "L" { 7.7 }
      else { 0.0 }
    } else if metric-type == "PR" {
      if val == "H" { 2.7 }
      else if val == "L" { 6.2 }
      else if val == "N" { 8.5 }
      else { 0.0 }
    } else if metric-type == "UI" {
      if val == "R" { 6.2 }
      else if val == "N" { 8.5 }
      else { 0.0 }
    } else if metric-type == "S" {
      if val == "U" { 5.0 }
      else if val == "C" { 10.0 }
      else { 0.0 }
    } else if metric-type in ("C", "I", "A") {
      if val == "N" { 0.0 }
      else if val == "L" { 2.2 }
      else if val == "H" { 5.6 }
      else { 0.0 }
    } else { 5.0 }
  }

  // Get metric values (8 base metrics)
  let labels = ("AV", "AC", "PR", "UI", "S", "C", "I", "A")
  let data = labels.map(label => convert-v3-metric(metrics.at(label, default: "N"), label))
  let n-points = labels.len()

  // Get severity-based colors
  let severity = lower(scores.at("severity", default: "none"))
  let severity-color = colors.at(severity)
  let data-fill = severity-color.transparentize(75%)
  let data-stroke = severity-color

  let center-x = size / 2
  let center-y = size / 2
  let radius = size * 0.32
  let angle-step = 360 / n-points
  let start-angle = -90

  box(width: size, height: size, {
    // Draw grid octagons (dotted)
    for level in (2.5, 5, 7.5, 10) {
      let pts = ()
      for i in range(n-points + 1) {
        let angle = start-angle + angle-step * calc.rem(i, n-points)
        pts.push(polar-to-xy(center-x, center-y, angle, radius * level / 10))
      }
      place(polygon(..pts, stroke: (paint: colors.at("chart-grid"), thickness: 1pt, dash: "dotted"), fill: none))
    }

    // Draw axes
    for i in range(n-points) {
      let angle = start-angle + angle-step * i
      let endpoint = polar-to-xy(center-x, center-y, angle, radius)
      place(line(start: (center-x, center-y), end: endpoint, stroke: (paint: colors.at("chart-grid"), thickness: 1pt)))
    }

    // Draw data polygon
    let data-pts = ()
    for i in range(n-points + 1) {
      let idx = calc.rem(i, n-points)
      let angle = start-angle + angle-step * idx
      data-pts.push(polar-to-xy(center-x, center-y, angle, radius * data.at(idx) / 10))
    }
    place(polygon(..data-pts, fill: data-fill, stroke: (paint: data-stroke, thickness: 0pt)))

    // Draw metric labels
    for i in range(n-points) {
      let angle = start-angle + angle-step * i
      let label-pos = polar-to-xy(center-x, center-y, angle, radius * 1.2)
      let metric-label = labels.at(i) + ":" + metrics.at(labels.at(i), default: "-")

      place(
        dx: label-pos.at(0),
        dy: label-pos.at(1),
        box(
          width: 0pt,
          height: 0pt,
          align(center + horizon,
            text(size: 8pt, weight: "bold", fill: colors.at("chart-text"), metric-label)
          )
        )
      )
    }
  })
}

// ============================================================================
// CVSS 4.0 RADAR CHART (11-sided polygon - 11 base metrics)
// ============================================================================

/// Draw CVSS 4.0 radar chart (11 base metrics)
#let draw-v4-graph(scores, metrics, size: 260pt, colors: default-colors) = {
  // Convert CVSS 4.0 metrics to 0-10 scale
  let convert-v4-metric(val, metric-type) = {
    if metric-type == "AV" {
      if val == "P" { 2.0 }
      else if val == "L" { 5.5 }
      else if val == "A" { 6.2 }
      else if val == "N" { 8.5 }
      else { 0.0 }
    } else if metric-type == "AC" {
      if val == "H" { 4.4 }
      else if val == "L" { 7.7 }
      else { 0.0 }
    } else if metric-type == "AT" {
      if val == "P" { 3.0 }
      else if val == "N" { 8.0 }
      else { 0.0 }
    } else if metric-type == "PR" {
      if val == "H" { 2.7 }
      else if val == "L" { 6.2 }
      else if val == "N" { 8.5 }
      else { 0.0 }
    } else if metric-type == "UI" {
      if val == "A" { 3.0 }
      else if val == "P" { 6.2 }
      else if val == "N" { 8.5 }
      else { 0.0 }
    } else if metric-type in ("VC", "VI", "VA", "SC", "SI", "SA") {
      if val == "N" { 0.0 }
      else if val == "L" { 3.5 }
      else if val == "H" { 7.0 }
      else if val == "S" { 10.0 }
      else { 0.0 }
    } else { 5.0 }
  }

  // Get metric values (11 base metrics)
  let labels = ("AV", "AC", "AT", "PR", "UI", "VC", "VI", "VA", "SC", "SI", "SA")
  let data = labels.map(label => convert-v4-metric(metrics.at(label, default: "N"), label))
  let n-points = labels.len()

  // Get severity-based colors
  let severity = lower(scores.at("severity", default: "none"))
  let severity-color = colors.at(severity)
  let data-fill = severity-color.transparentize(75%)
  let data-stroke = severity-color

  let center-x = size / 2
  let center-y = size / 2
  let radius = size * 0.30
  let angle-step = 360 / n-points
  let start-angle = -90

  box(width: size, height: size, {
    // Draw grid circles (dotted)
    for level in (2.5, 5, 7.5, 10) {
      let pts = ()
      for i in range(n-points + 1) {
        let angle = start-angle + angle-step * calc.rem(i, n-points)
        pts.push(polar-to-xy(center-x, center-y, angle, radius * level / 10))
      }
      place(polygon(..pts, stroke: (paint: colors.at("chart-grid"), thickness: 1pt, dash: "dotted"), fill: none))
    }

    // Draw axes
    for i in range(n-points) {
      let angle = start-angle + angle-step * i
      let endpoint = polar-to-xy(center-x, center-y, angle, radius)
      place(line(start: (center-x, center-y), end: endpoint, stroke: (paint: colors.at("chart-grid"), thickness: 1pt)))
    }

    // Draw data polygon
    let data-pts = ()
    for i in range(n-points + 1) {
      let idx = calc.rem(i, n-points)
      let angle = start-angle + angle-step * idx
      data-pts.push(polar-to-xy(center-x, center-y, angle, radius * data.at(idx) / 10))
    }
    place(polygon(..data-pts, fill: data-fill, stroke: (paint: data-stroke, thickness: 0pt)))

    // Draw metric labels
    for i in range(n-points) {
      let angle = start-angle + angle-step * i
      let label-pos = polar-to-xy(center-x, center-y, angle, radius * 1.25)
      let metric-label = labels.at(i) + ":" + metrics.at(labels.at(i), default: "-")

      place(
        dx: label-pos.at(0),
        dy: label-pos.at(1),
        box(
          width: 0pt,
          height: 0pt,
          align(center + horizon,
            text(size: 7.5pt, weight: "bold", fill: colors.at("chart-text"), metric-label)
          )
        )
      )
    }
  })
}
