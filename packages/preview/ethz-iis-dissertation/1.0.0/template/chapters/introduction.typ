// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#import "@preview/ethz-iis-dissertation:1.0.0": (
  acr, acrfull, acrpl, chapter-short,
)

// Optional: override the running header with a shorter title.
// Useful when the full chapter title is too long to fit on one line.
// #chapter-short.update("Intro")

= Introduction <chp:intro>

The exponential growth in data-intensive applications — from machine learning inference
to large-scale scientific computing — places unprecedented demands on the hardware
architectures that support them. At the same time, the end of classical Dennard scaling
has made energy efficiency a first-class design constraint alongside raw performance
@hennessy2019new. The resulting tension between performance, energy, and area (#acr("PPA"))
motivates the search for fundamentally new approaches to hardware design.

This thesis investigates the design and implementation of scalable interconnect
architectures for #acrpl("SoC"). Interconnects — the networks that carry data between
processing elements, memories, and peripherals — are increasingly the primary bottleneck
in modern systems: they account for a substantial fraction of the total chip area and
power budget, yet their design has received comparatively little attention relative to
compute elements @benini2002networks.

== Motivation

#lorem(80)

The Integrated Systems Laboratory (#acr("IIS")) at ETH Zurich has a long history of
producing open-source hardware that bridges the gap between academic research and
industrial practice @fischer2025floonoc. This thesis continues that tradition by
contributing a fully open-source, silicon-validated interconnect architecture.

== Problem Statement

#lorem(60)

Formally, we seek an interconnect architecture $cal(N)$ that satisfies:
$
  "throughput"(cal(N)) >= T_"min", quad "power"(cal(N)) <= P_"max"
$
subject to an area budget $A_"max"$ and full protocol compliance with the AXI4 standard.

== Contributions

The main contributions of this dissertation are:

+ *NoC micro-architecture:* A novel decoupled control/data path design that achieves
  near-ideal pipeline utilization with minimal area overhead.

+ *Formal verification methodology:* A composable correctness argument that covers all
  protocol states without exhaustive simulation.

+ *Silicon validation:* A 22 nm #acr("ASIC") implementation demonstrating 2.1×
  throughput improvement and 35% power reduction over prior work.

+ *Open-source release:* All #acr("RTL"), scripts, and testbenches are released
  under a permissive open-source license.

== Thesis Outline

The remainder of this thesis is organized as follows.
@chp:background introduces the necessary background on #acrpl("NoC") and #acrpl("SoC").
@chp:conclusion summarizes the contributions and outlines directions for future work.

#figure(
  table(
    columns: (1fr, 2fr),
    align: (left, left),
    stroke: none,
    table.hline(stroke: 1.5pt),
    table.header([*Chapter*], [*Content*]),
    table.hline(stroke: 0.75pt),
    [@chp:background], [Background on interconnects and related work],
    [@chp:conclusion], [Conclusions and future work],
    table.hline(stroke: 1.5pt),
  ),
  caption: [Overview of the thesis structure.],
) <tab:outline>
