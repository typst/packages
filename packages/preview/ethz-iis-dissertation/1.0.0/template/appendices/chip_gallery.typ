// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>
//
// Chip Gallery appendix — one chip-entry call per chip.
// Add chips in reverse chronological order (most recent first).

= Chip Gallery

This appendix lists all fabricated chips the author has contributed to in the form
of technical work or supervision.

// Helper function: renders one chip entry with a side-by-side image + specs layout,
// a separate designers block, and a description paragraph.
#let chip-entry(name, img, designers, specs, description) = {
  // Chip name as a section heading
  [== #name]

  // Top row: image left, spec table right
  grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    // Chip photo
    align(center + horizon, img),
    // Spec table (all fields except designers)
    table(
      columns: (auto, 1fr),
      stroke: none,
      inset: (x: 4pt, y: 3pt),
      ..specs
        .map(s => (
          text(weight: "bold", size: 8pt, s.first()),
          text(size: 8pt, s.last()),
        ))
        .flatten(),
    ),
  )

  // Designers block below the image/spec row
  v(0.4em)
  text(weight: "bold", size: 8pt)[Designers]
  linebreak()
  text(size: 8pt, designers)

  v(0.6em)
  // Description paragraph
  description
  pagebreak(weak: true)
}

// ── Chip A ───────────────────────────────────────────────────────────────────
#chip-entry(
  "Chip A",
  // Replace with the actual chip photo:
  rect(width: 100%, height: 5cm, stroke: 0.5pt, fill: luma(240))[
    #align(center + horizon, text(size: 8pt, fill: luma(120))[Chip photo])
  ],
  // Designers — bold your own name
  [*Firstname Lastname*, Collaborator One, Collaborator Two, Supervisor Name],
  // Specs — array of (label, value) pairs
  (
    ("Application", [High-performance NoC / Research Project]),
    ("Technology", [TSMC Xnm / Custom Package]),
    ("Dimensions", [$X.X "mm" times Y.Y "mm"$]),
    ("Gate count", [$Z$ MGE]),
    ("Voltage", [$V$ V]),
    ("Clock", [$F$ GHz]),
  ),
  // Description
  [
    Replace this paragraph with a description of the chip: its purpose,
    architecture highlights, key collaborators or funding sources, and any
    measurement results or expected outcomes.
  ],
)

// ── Chip B ───────────────────────────────────────────────────────────────────
#chip-entry(
  "Chip B",
  rect(width: 100%, height: 5cm, stroke: 0.5pt, fill: luma(240))[
    #align(center + horizon, text(size: 8pt, fill: luma(120))[Chip photo])
  ],
  [Collaborator One, *Firstname Lastname*, Collaborator Two, Supervisor Name],
  (
    ("Application", [IoT Processor / Research Project]),
    ("Technology", [GF Xnm / QFN Package]),
    ("Dimensions", [$X.X "mm" times Y.Y "mm"$]),
    ("Gate count", [$Z$ MGE]),
    ("Voltage", [$V$ V -- $W$ V]),
    ("Clock", [$F$ MHz]),
  ),
  [
    Replace this paragraph with a description of the chip.
  ],
)
