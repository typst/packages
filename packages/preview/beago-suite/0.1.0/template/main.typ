#import "@preview/beago-suite:0.1.0": *

#show: beago-article.with(
    title: [The Architecture of Distributed Logistics Systems],
    subtitle: [A Case Study of the Beago Logistics System],
    author: [Aaron P. Murniadi],
    title-align: left,
    heading-numbering: "1.1.",
    paper: "a4",
    first-line-indent: (amount: 2em, all: false),
    font-size: 12pt,
    line-spacing: 1em,
    abstract: [
        Modern logistics networks require automated routing configuration at scale.
        This case study describes the Beago logistics system, its hierarchical zone
        decomposition, and the composable routing schemas that reduce solver time
        while preserving delivery accuracy.
    ],
)

= Introduction

#lorem(80)

= Background

$ (-1.32865 plus.minus 0.50273) times 10^(-6) $

== Motivation

Modern logistics networks operate at a scale that makes manual routing
infeasible. The combinatorial complexity of assigning parcels to zones, hubs,
and drivers grows exponentially with fleet size. Automated routing configuration
systems address this by encoding business rules — coverage zones, capacity
constraints, and service-level agreements — into structured, machine-readable
formats.#footnote[This is a test footnote]

#lorem(80)

== Related Work

Prior work in vehicle routing (VRP) and its variants established the theoretical
foundations now used in production systems. Recent industry efforts have shifted
toward hybrid approaches that combine constraint solvers with learned
heuristics, enabling real-time re-routing in response to traffic or failed
delivery attempts.

#lorem(60)

= Methodology

== System Design

#lorem(100)

== Routing Configuration

Routing nodes are the atomic unit of the configuration layer. Each node encodes
a mapping from a geographic zone identifier to a set of operational parameters:
hub assignment, delivery window, vehicle class, and fallback rules. Nodes are
composed into directed graphs, enabling cascading resolution when primary
assignments are unavailable.

#lorem(50)

== Evaluation

#lorem(90)

= Results

#lorem(110)

== Discussion

The results confirm that hierarchical zone decomposition significantly reduces
solver time without sacrificing delivery accuracy. Notably, configurations that
expose fallback chains — rather than hard-failing on unresolvable zones —
improved overall fulfillment rate by reducing manual intervention in edge cases.

#lorem(40)

= Conclusion

#lorem(70)

Taken together, these findings suggest that investing in expressive, composable
routing configuration schemas is a more tractable path to scalable logistics
than pursuing purely algorithmic improvements in isolation. Future work will
explore dynamic reconfiguration triggered by real-time demand signals.
