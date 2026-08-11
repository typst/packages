// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#import "@preview/ethz-iis-dissertation:1.0.0": (
  acr, acrfull, acrpl, chapter-short,
)

// #chapter-short.update("Background")

= Background <chp:background>

This chapter reviews the background knowledge required to understand the contributions
of this thesis. We cover the fundamentals of #acrpl("SoC") interconnect design
(@sec:noc-basics), standard communication protocols (@sec:protocols), and prior
work that motivates our approach (@sec:related).

== Network-on-Chip Fundamentals <sec:noc-basics>

A #acr("NoC") is a packet-switched communication fabric that connects multiple
intellectual property (IP) blocks on a single die @benini2002networks. Unlike
traditional bus-based interconnects, #acrpl("NoC") scale to large numbers of endpoints
while providing predictable worst-case latency and high aggregate bandwidth.

=== Topology

#lorem(60)

The choice of topology determines the fundamental trade-offs between bisection
bandwidth, hop count, and router area. Common topologies include:

- *Mesh:* Regular 2D grid; simple to implement and route; used in most commercial
  many-core processors.
- *Torus:* Mesh with wrap-around links; reduces diameter at the cost of longer wires.
- *Butterfly / fat-tree:* Hierarchical structures that minimize hop count at the
  cost of non-uniform link widths.

=== Routing

#lorem(40)

The routing algorithm determines which path a packet follows from source to
destination. Dimension-ordered routing (XY routing) is the de facto standard for
mesh topologies due to its deadlock-free, deterministic nature.

=== Flow Control

Flow control governs how buffer space is allocated along a packet's path. Credit-based
flow control — where a receiver grants credits to its upstream neighbor — is widely
used because it provides tight, cycle-accurate backpressure with low overhead.

== Communication Protocols <sec:protocols>

Modern #acrpl("SoC") rely on standardized bus protocols to ensure interoperability
between IP blocks from different vendors. The AXI4 protocol from the ARM AMBA
specification is the dominant standard in the industry today.

=== AXI4 Overview

#lorem(80)

AXI4 separates each transaction into five independent channels: address write (AW),
data write (W), write response (B), address read (AR), and data read (R). This
separation allows requests and responses to be pipelined independently, enabling
high-throughput operation even under heavy load.

=== AXI4 Stream

For bulk data transfers, AXI4-Stream provides a simplified unidirectional interface
without address channels. It is widely used for DMA engines and streaming accelerators.

== Related Work <sec:related>

#lorem(100)

@fischer2025floonoc presents the FlooNoC interconnect, which achieves 645 Gb/s/link
with 0.15 pJ/B/hop in a 22 nm technology. This work builds directly on FlooNoC
and extends its micro-architecture to support multi-stream parallel transfers.

#figure(
  table(
    columns: (auto, 1fr, 1fr, 1fr),
    align: (left, center, center, center),
    stroke: none,
    table.hline(stroke: 1.5pt),
    table.header(
      [*Work*], [*BW (Gb/s/link)*], [*Energy (pJ/B)*], [*Technology*]
    ),
    table.hline(stroke: 0.75pt),
    [Prior A], [128], [0.48], [28 nm],
    [Prior B], [256], [0.31], [22 nm],
    [FlooNoC @fischer2025floonoc], [645], [0.15], [22 nm],
    [*This work*], [*1280*], [*0.09*], [*22 nm*],
    table.hline(stroke: 1.5pt),
  ),
  caption: [Comparison of on-chip interconnect designs.],
) <tab:comparison>

As shown in @tab:comparison, our design achieves the best energy efficiency while
doubling the peak bandwidth of FlooNoC.
