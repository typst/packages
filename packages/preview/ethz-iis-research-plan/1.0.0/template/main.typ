// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>

#import "@preview/ethz-iis-research-plan:1.0.0": *
#import "@preview/ethz-iis-research-plan:1.0.0": pulp-colors
#import "@preview/acrostiche:0.7.0": acr, acrpl, init-acronyms
#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": plot as cplot

// Define acronyms locally — no need to pass them to the template.
#init-acronyms((
  "NoC": ("Network-on-Chip",),
  "3D": ("Three-Dimensional",),
  "2D": ("Two-Dimensional",),
  "D2D": ("Die-to-Die",),
  "SoC": ("System-on-Chip",),
  "HB": ("Hybrid Bonding",),
  "WP": ("Work Package",),
))

#show: research-plan.with(
  title: "3D Network-on-Chip Architectures for Scalable Many-Core Systems",
  author: "Jane Doe",
  email: "jdoe@iis.ee.ethz.ch",
  chair: (name: "Prof. Dr. Carol White", mail: "cwhite@iis.ee.ethz.ch"),
  supervisor: (name: "Prof. Dr. Alice Miller", mail: "amiller@iis.ee.ethz.ch"),
  cosupervisor: (name: "Dr. Bob Smith", mail: "bsmith@iis.ee.ethz.ch"),
  bibliography: bibliography("references.bib", style: "ieee"),
)

= Introduction

The physical limits of #acr("2D") integration — reticle-size constraints and the latency
penalty of traversing large die areas — increasingly bottleneck the scalability of
many-core accelerator arrays. #acr("3D") integration via advanced packaging technologies
such as #acr("HB") offers a path forward by introducing a vertical routing dimension that
fundamentally changes the geometry and bandwidth scaling of on-chip interconnects, as
illustrated in @noc-scaling. This
plan outlines the motivation, open problems, and planned contributions of a doctoral thesis
on #acrpl("NoC") for #acr("3D")-integrated systems.

#let n-max = 512.0
#let cbrt(x) = calc.pow(float(x), 1.0 / 3.0)

#figure(
  cetz.canvas({
    cplot.plot(
      size: (9, 6),
      axis-style: "scientific",
      x-label: [Nodes $N$],
      x-min: 0,
      x-max: n-max,
      y-label: [Avg. hop count],
      y-min: 0,
      y2-label: [Norm. bandwidth],
      y2-min: 0,
      legend: "inner-north-west",
      {
        cplot.add(
          domain: (4, n-max),
          x => 2.0 / 3.0 * calc.sqrt(float(x)),
          label: [Hops 2D ($∝ N^(1\/2)$)],
          style: (stroke: (paint: pulp-colors.blue.base, thickness: 1.5pt)),
        )
        cplot.add(
          domain: (4, n-max),
          x => cbrt(x),
          label: [Hops 3D ($∝ N^(1\/3)$)],
          style: (
            stroke: (
              paint: pulp-colors.blue.light,
              thickness: 1.5pt,
              dash: "dashed",
            ),
          ),
        )
        cplot.add(
          axes: ("x", "y2"),
          domain: (4, n-max),
          x => calc.sqrt(float(x) / 4.0),
          label: [BW 2D ($∝ N^(1\/2)$)],
          style: (stroke: (paint: pulp-colors.orange.base, thickness: 1.5pt)),
        )
        cplot.add(
          axes: ("x", "y2"),
          domain: (4, n-max),
          x => calc.pow(float(x) / 4.0, 2.0 / 3.0),
          label: [BW 3D ($∝ N^(2\/3)$)],
          style: (
            stroke: (
              paint: pulp-colors.orange.light,
              thickness: 1.5pt,
              dash: "dashed",
            ),
          ),
        )
      },
    )
  }),
  caption: [
    Scaling advantages of 3D #acrpl("NoC") over 2D meshes.
    Left axis: average hop count ($N^(1\/3)$ vs. $N^(1\/2)$).
    Right axis: normalized inter-die bandwidth — area-array 3D ($N^(2\/3)$)
    vs. shoreline-limited 2D ($N^(1\/2)$), normalized to $N=4$.
  ],
) <noc-scaling>

= State of the Art

Wide-link #acr("2D") #acrpl("NoC") have demonstrated that "wide and slow" links
outperform "narrow and fast" SerDes links in energy efficiency for die-to-die communication
@fischer2025floonoc. However, horizontal connectivity remains fundamentally bounded by
the linear shoreline of the die. Existing #acr("3D") #acr("NoC") proposals either treat
vertical links as ordinary hops with unchanged router microarchitectures, or focus on
memory-stacking scenarios that differ substantially from the compute-array context.

= Research Gap

No existing #acr("NoC") architecture simultaneously exploits (1) the quadratic bandwidth
scaling offered by area-array vertical interconnects, (2) the near-zero latency of
#acr("HB") vertical hops, and (3) the "wide and slow" signaling philosophy proven effective
in #acr("2D") fabrics. Bridging this gap requires co-designing the router microarchitecture,
the flit format, and the physical link with the constraints of #acr("3D") packaging.

= Completed Work

During the first year, hands-on experience was gained by contributing to the design and
tapeout of a wide-link #acr("2D") #acr("NoC") for large-scale accelerator arrays
@fischer2025floonoc. Building on this foundation, several extensions were implemented,
including support for additional traffic patterns and an improved flow-control mechanism.
These contributions provided a solid baseline and deep familiarity with the design space
that motivates the planned #acr("3D") research direction.

= Project Definition

The thesis is structured into three #acrpl("WP"):

== WP1: 3D Router Microarchitecture

Extend the existing router design with a vertical port that maps wide flits directly onto
#acr("HB") bump arrays without serialization. Characterize the latency, area, and power
of vertical hops and derive design rules for mixed #acr("2D")/#acr("3D") topologies.

== WP2: Topology and Routing Algorithms

Investigate 3D mesh and folded-torus topologies that exploit the reduced hop count of the
vertical dimension. Develop deadlock-free routing algorithms that treat vertical hops as
low-cost shortcuts and evaluate network diameter and worst-case latency at scale.

== WP3: Physical Integration and Full-System Evaluation

Integrate the #acr("3D") #acr("NoC") into a multi-die #acr("SoC") prototype and measure
end-to-end bandwidth, latency, and energy against #acr("2D") baselines. Validate the
quadratic bandwidth-scaling prediction on silicon or a detailed physical model.

= Tentative Timeline

#import "@preview/timeliney:0.4.0"

// Fixed-width box forces left alignment in timeliney's centered cetz content anchor.
// justify: false prevents the template's set par(justify: true) from affecting labels.
#let t(label) = box(width: 5cm, {
  set par(justify: false)
  align(left)[#label]
})


#let mk-style(c) = (stroke: 6pt + c)

// Compute current position on the timeline (unit = 1 quarter, origin = Q1 2026)
#let now = {
  let today = datetime(year: 2027, month: 1, day: 1) // you can also use `datetime.today()`
  let year-offset = today.year() - 2026
  let quarter = calc.floor((today.month() - 1) / 3)
  let month-frac = calc.rem(today.month() - 1, 3) / 3
  float(year-offset * 4 + quarter) + month-frac
}

#figure(
  timeliney.timeline(
    show-grid: true,
    {
      import timeliney: *

      headerline(
        group(([*2026*], 4)),
        group(([*2027*], 4)),
        group(([*2028*], 4)),
        group(([*2029*], 4)),
      )
      headerline(
        group(..range(4).map(n => sub("Q" + str(n + 1)))),
        group(..range(4).map(n => sub("Q" + str(n + 1)))),
        group(..range(4).map(n => sub("Q" + str(n + 1)))),
        group(..range(4).map(n => sub("Q" + str(n + 1)))),
      )

      taskgroup(
        title: t[*Completed Work*],
        style: mk-style(pulp-colors.gray.base),
        {
          task(t[2D NoC tapeout contribution], (0, 2), style: mk-style(
            pulp-colors.gray.light,
          ))
          task(t[Extensions & exploration], (2, 4), style: mk-style(
            pulp-colors.gray.very-light,
          ))
        },
      )

      taskgroup(
        title: t[*WP1: 3D Router*],
        style: mk-style(pulp-colors.blue.base),
        {
          task(t[Vertical port design], (4, 7), style: mk-style(
            pulp-colors.blue.light,
          ))
          task(t[HB link characterization], (6, 9), style: mk-style(
            pulp-colors.blue.very-light,
          ))
        },
      )

      taskgroup(
        title: t[*WP2: Topology & Routing*],
        style: mk-style(pulp-colors.green.base),
        {
          task(t[3D routing algorithms], (8, 11), style: mk-style(
            pulp-colors.green.light,
          ))
          task(t[Scalability analysis], (10, 13), style: mk-style(
            pulp-colors.green.very-light,
          ))
        },
      )

      taskgroup(
        title: t[*WP3: Physical Integration*],
        style: mk-style(pulp-colors.orange.base),
        {
          task(t[Multi-die SoC prototype], (12, 15), style: mk-style(
            pulp-colors.orange.light,
          ))
          task(t[Writing and defense], (14, 16), style: mk-style(
            pulp-colors.orange.very-light,
          ))
        },
      )

      milestone(
        at: now,
        style: (
          stroke: (
            dash: "dashed",
            paint: pulp-colors.gray.base,
            thickness: 1.5pt,
          ),
        ),
        align(center, text(size: 12pt, weight: "bold")[Now]),
      )
    },
  ),
  caption: [Tentative timeline aligned with the work packages.],
)

= Obligations / Teaching Duties

During the course of the doctoral program, the following teaching and service obligations
are planned:

- *Teaching assistant* for the undergraduate course "Digital Design" (2 semesters)
- *Co-supervision* of one master thesis per year
- *Lab maintenance*: shared responsibility for the FPGA lab and associated servers

= Declaration of Originality

I hereby confirm that I am the sole author of the written work enclosed and that I have
compiled it in my own words. Parts excepted are corrections of form and content by the
supervisor. I disclose the use of generative AI tools#footnote[The following generative AI
  tools were used in the preparation of this work: ChatGPT (language editing and
  brainstorming), Grammarly (grammar and syntax checking). All AI-generated content was critically reviewed and
  revised by the author.] in the preparation of this work.
