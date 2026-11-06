// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>
//
// PhD Thesis example — compile with:
//   typst compile main.typ

#import "@preview/ethz-iis-dissertation:1.0.0": dissertation, acr, acrfull, acrpl, typst-guide
#import "acronyms.typ": acronyms

#show: dissertation.with(
  // Identity — replace with your own details
  title: "Title of Your Dissertation",
  author: "Firstname Lastname",
  email: "username@iis.ee.ethz.ch",
  date-of-birth: "dd.mm.yyyy",

  // Examination
  // diss-number: 12345,  // Uncomment once assigned at registration
  supervisor: "Prof. Dr. Supervisor Name",
  co-examiners: ("Prof. Dr. Co-Examiner Name",),
  year: 2026,

  // Render mode
  mode: "official", // Switch to "series" for the Hartung-Gorre publication copy

  // Series mode extras (ignored when mode: "official")
  // volume: 42,
  // isbn: "3-86628-XXX-X",
  // isbn-long: "978-3-86628-XXX-X",
  // published: "2026",

  // Front matter
  acknowledgements: include "chapters/acknowledgements.typ",
  abstracts: (
    include "chapters/abstract_en.typ",
    include "chapters/abstract_de.typ",
  ),
  acronyms: acronyms,

  // Back matter
  bibliography: bibliography("references.bib", style: "ieee"),
  appendices: (
    include "appendices/chip_gallery.typ",
    typst-guide,
  ),
  cv: include "cv.typ",
  show-copyright-notice: true,
)

// Main body — one include per chapter
#include "chapters/introduction.typ"
#include "chapters/background.typ"
#include "chapters/conclusion.typ"
