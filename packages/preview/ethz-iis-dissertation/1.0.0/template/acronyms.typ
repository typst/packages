// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>

// Acronym definitions for the PhD thesis.
// Import this file in main.typ and pass the dict to the template:
//   #import "preamble.typ": acronyms
//   #show: phd-thesis.with(acronyms: acronyms, ...)
//
// Usage in chapters:
//   #acr("SoC")       → short form (first use expands to full form as footnote)
//   #acrpl("SoC")     → plural short form
//   #acrfull("SoC")   → always expands to full form

#let acronyms = (
  // Hardware
  // ────────
  "IC": ("Integrated Circuit",),
  "IIS": ("Integrated Systems Laboratory",),
  "RTL": ("Register-Transfer Level",),
  "ASIC": ("Application-Specific Integrated Circuit",),
  "FPGA": ("Field-Programmable Gate Array",),
  "NoC": ("Network-on-Chip",),
  "ALU": ("Arithmetic Logic Unit",),
  "LLC": ("Last-Level Cache",),

  // Systems
  // ───────
  "SoC": (
    short: "SoC",
    long: "System-on-Chip",
    short-pl: "SoCs",
    long-pl: "Systems-on-Chip",
  ),
  "HDL": (
    short: "HDL",
    long: "Hardware Description Language",
    short-pl: "HDLs",
    long-pl: "Hardware Description Languages",
  ),
  "ISA": (
    short: "ISA",
    long: "Instruction Set Architecture",
    short-pl: "ISAs",
    long-pl: "Instruction Set Architectures",
  ),

  // Verification
  // ────────────
  "EDA": ("Electronic Design Automation",),
  "DUT": ("Design Under Test",),
  "UVM": ("Universal Verification Methodology",),

  // Metrics
  // ───────
  "PPA": ("Power, Performance, and Area",),
  "IPC": ("Instructions Per Cycle",),
)
