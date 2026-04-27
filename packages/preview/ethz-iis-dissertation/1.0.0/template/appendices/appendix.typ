// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>

= AXI4 Protocol Reference

== Channel Signals

@tab:axi4-signals lists the signals on the AXI4 write-address channel. The remaining
channels follow an analogous structure.

#figure(
  table(
    columns: (auto, auto, 1fr),
    align: (left, center, left),
    stroke: none,
    table.hline(stroke: 1.5pt),
    table.header([*Signal*], [*Width*], [*Description*]),
    table.hline(stroke: 0.75pt),
    [`AWID`], [varies], [Write address ID],
    [`AWADDR`], [32/64 b], [Write address],
    [`AWLEN`], [8 b], [Burst length (number of transfers minus one)],
    [`AWSIZE`], [3 b], [Transfer size (bytes per beat, log2)],
    [`AWBURST`], [2 b], [Burst type: FIXED, INCR, WRAP],
    [`AWVALID`], [1 b], [Handshake: master asserts when address is valid],
    [`AWREADY`],
    [1 b],
    [Handshake: slave asserts when it can accept the address],
    table.hline(stroke: 1.5pt),
  ),
  caption: [AXI4 write-address channel (AW) signals.],
) <tab:axi4-signals>

== Handshake Protocol

Data is transferred on a channel whenever both `VALID` and `READY` are asserted in
the same clock cycle. The master must not wait for `READY` before asserting `VALID`,
and the slave must not wait for `VALID` before asserting `READY`. This rule prevents
deadlock in systems where `READY` depends combinationally on `VALID`.
