// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>

// List of acronyms used in the thesis.
// Pass this to the thesis template via: #show: thesis.with(acronyms: acronyms)
// Usage in text: #acr("IIS"), #acrpl("FPGA"), #acrfull("ASIC")
//
// Simple form — acrostiche auto-pluralises by appending "s":
//   "IC": ("Integrated Circuit",),
//
// Advanced form — explicit singular/plural for both short and long:
//   "SoC": (
//     short: "SoC", long: "System-on-Chip",
//     short-pl: "SoCs", long-pl: "Systems-on-Chip",
//   ),

#let acronyms = (
  // Simple acronyms (acrostiche appends "s" for the plural form)
  "IC": ("Integrated Circuit",),
  "IIS": ("Integrated Systems Laboratory",),
  "RTL": ("Register-Transfer Level",),
  "ASIC": ("Application-Specific Integrated Circuit",),
  "FPGA": ("Field-Programmable Gate Array",),

  // Advanced acronyms with explicit plural forms
  "HDL": (
    short: "HDL",
    long: "Hardware Description Language",
    short-pl: "HDLs",
    long-pl: "Hardware Description Languages",
  ),
  "SoC": (
    short: "SoC",
    long: "System-on-Chip",
    short-pl: "SoCs",
    long-pl: "Systems-on-Chip",
  ),
)
