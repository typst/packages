// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>
//
// Shared utilities for IIS Typst templates

#import "@preview/gentle-clues:1.3.1": code, task

/// Inline placeholder for missing fields — muted italic text e.g. ⟨title⟩
#let fieldpar(content) = text(fill: luma(190), style: "italic", [⟨#content⟩])

/// Helper function to return current Semester
/// e.g. "Spring Semester 26"
#let current-semester() = {
  let current_year = datetime.today().display("[year repr:last_two]")
  let current_season = if datetime.today().month() < 6 { "Spring" } else {
    "Fall"
  }
  current_season + " Semester " + current_year
}

/// Include all pages of a PDF file as full-width images.
/// Use an absolute path (e.g. "/examples/task.pdf") so it resolves from the
/// Typst root regardless of which file calls this function.
/// The page count must be specified manually as Typst does not expose PDF metadata.
#let include-pdf(path, pages: 1) = {
  for i in range(1, pages + 1) {
    image(path, width: 100%, page: i)
  }
}

/// Render a task clue with a title, optional description content, and a
/// syntax-highlighted Typst code snippet. Intended for use in the `else` branch
/// of a `if param != none { param } else { placeholder(...) }` pattern.
#let placeholder(
  title: "",
  description: none,
  snippet: "",
  template: "thesis",
) = {
  task(title: title)[
    #if description != none { description }
    #code[#raw(
      lang: "typc",
      block: true,
      "#show: " + template + ".with(\n  " + snippet + "\n  // ...\n)",
    )]
  ]
}

/// PULP color palette — each entry is a dict with `base`, `light`, and `very-light` variants.
#let pulp-colors = (
  red: (
    base: rgb("#A8322C"),
    light: rgb("#A8322CC8"),
    very-light: rgb("#A8322C96"),
  ),
  blue: (
    base: rgb("#1269B0"),
    light: rgb("#1269B0C8"),
    very-light: rgb("#1269B096"),
  ),
  green: (
    base: rgb("#168638"),
    light: rgb("#168638C8"),
    very-light: rgb("#16863896"),
  ),
  orange: (
    base: rgb("#F29545"),
    light: rgb("#F29545C8"),
    very-light: rgb("#F2954596"),
  ),
  purple: (
    base: rgb("#910569"),
    light: rgb("#910569C8"),
    very-light: rgb("#91056996"),
  ),
  olive: (
    base: rgb("#48592C"),
    light: rgb("#48592CC8"),
    very-light: rgb("#48592C96"),
  ),
  marine: (
    base: rgb("#007996"),
    light: rgb("#007996C8"),
    very-light: rgb("#00799696"),
  ),
  gray: (
    base: rgb("#ABABAB"),
    light: rgb("#ABABABC8"),
    very-light: rgb("#ABABAB96"),
  ),
)

/// ETH header with ETH logo on the left and PULP logo on the right.
#let eth-header = grid(
  columns: (auto, 1fr, auto),
  rows: 80pt,
  align: (left + horizon, horizon, right + horizon),
  image("figures/eth_logo_kurz_pos.svg", height: 80%),
  [],
  image("figures/pulp_logo_inline.svg", height: 3.2em),
)
