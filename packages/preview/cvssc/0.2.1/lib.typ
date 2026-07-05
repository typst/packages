// CVSS Calculator Library for Typst
// Version 0.2.0
// MIT License
//
// A comprehensive library for calculating Common Vulnerability Scoring System (CVSS) scores
// Supports CVSS v2.0, v3.0, v3.1, and v4.0
//
// Usage:
//   #import "@preview/cvssc:0.2.0": *
//
//   // Calculate from vector string (auto-detect version)
//   #let result = calc("CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H")
//   #result.overall-score  // 9.8
//   #result.severity       // "critical"
//
//   // Display as colored badges
//   #result.badge               // Shows "CRITICAL"
//   #result.badge-with-score    // Shows "CRITICAL 9.8"
//
//   // Display as radar chart
//   #result.graph
//
//   // Or use dictionary format
//   #let result = calc((
//     version: "3.1",
//     metrics: (
//       "AV": "N", "AC": "L", "PR": "N", "UI": "N",
//       "S": "U", "C": "H", "I": "H", "A": "H"
//     )
//   ))

// Re-export all public API from src/main.typ
#import "src/cvssc.typ": *

// Re-export constants for user customization
#import "src/constants.typ": severity-colors, chart-colors, specifications, get-severity-from-score

// Export library version
#let cvss-version = toml("typst.toml").package.version