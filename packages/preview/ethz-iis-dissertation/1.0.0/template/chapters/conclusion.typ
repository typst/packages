// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#import "@preview/ethz-iis-dissertation:1.0.0": (
  acr, acrfull, acrpl, chapter-short,
)

// #chapter-short.update("Conclusions")

= Conclusions <chp:conclusion>

This dissertation presented a novel approach to on-chip interconnect design that
addresses the growing performance and energy demands of modern #acrpl("SoC").
We demonstrated that by carefully co-designing the micro-architecture, the verification
methodology, and the physical implementation, it is possible to simultaneously improve
throughput, reduce energy consumption, and simplify correctness proofs.

== Summary of Contributions

The key contributions of this work are as follows.

*Chapter~2 — Background:*
We reviewed the state of the art in #acr("NoC") design and identified the key
limitations of existing approaches that motivate our research.

*Interconnect micro-architecture:*
We proposed a decoupled control/data path architecture that enables near-ideal
pipeline utilization. The design was validated through extensive simulation and
subsequently taped out in a 22 nm process, confirming simulation predictions with
less than 3% deviation.

*Formal verification methodology:*
We developed a composable correctness argument for AXI4-compliant interconnects
that covers all reachable protocol states. Compared to conventional simulation,
our approach reduced the verification effort by 60% while achieving higher coverage.

*Silicon results:*
The fabricated chip achieves 1280 Gb/s/link at 0.09 pJ/B/hop — a 2× throughput
improvement and 40% energy reduction over the best prior work at the same technology
node. The #acr("IPC") of the attached processor cores improved by 18% on average
across our benchmark suite.

== Future Work

#lorem(60)

Several promising directions remain for future investigation:

- *Multi-die integration:* Extending the architecture to support chiplet-based systems
  via die-to-die protocols such as UCIe.

- *Adaptive routing:* Incorporating load-adaptive routing to handle traffic hotspots
  that arise in irregular workloads.

- *Automated topology generation:* Developing tools that automatically select the
  optimal topology and link widths for a given application's communication graph.

- *Formal scalability:* Extending the composable verification framework to cover
  heterogeneous topologies and mixed-protocol endpoints.

We believe that the foundations laid in this dissertation — particularly the open-source
#acr("RTL") and the formal verification methodology — will serve as a productive basis
for these future directions.
