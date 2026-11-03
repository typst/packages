// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>

#import "@preview/ethz-iis-thesis:1.0.0": *
#import "acronyms.typ": acronyms
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/finite:0.5.1": automaton

#show: thesis.with(
  title: "Title of the Thesis",
  author: "Student Name",
  email: "student@iis.ee.ethz.ch",
  reporttype: "Master Thesis",
  advisors: (
    (name: "First Supervisor", mail: "first.supervisor@iis.ee.ethz.ch"),
    (name: "Second Supervisor", mail: "second.supervisor@iis.ee.ethz.ch"),
  ),
  professors: (
    (name: "Prof. Dr. P. Professor", mail: "professor@iis.ee.ethz.ch"),
  ),
  acknowledgements: lorem(50),
  abstract: lorem(50),
  logo: automaton(
    (q0: (q1: ""), q1: (q2: ""), q2: (q3: ""), q3: none),
    labels: (q0: "L", q1: "O", q2: "G", q3: "O"),
  ),
  acronyms: acronyms,
  bibliography: bibliography("references.bib", style: "ieee", full: true),
)

= Introduction

Modern integrated systems face increasing demands for performance, energy efficiency, and
reliability. This thesis addresses these challenges by proposing a novel architecture that
leverages recent advances in hardware design.

== Motivation

The growing complexity of #acrpl("IC") requires new design methodologies that can
handle billions of transistors while maintaining correctness and meeting strict timing
constraints.

== Contributions

The main contributions of this thesis are:
- A novel hardware architecture for efficient data processing
- A verification methodology that scales to large designs
- A comprehensive evaluation on real silicon

== Outline

The remainder of this thesis is organized as follows. @chp:background reviews relevant
background material. @chp:related discusses related work. @chp:theory presents the theoretical
foundations. @chp:architecture describes the proposed architecture. @chp:implementation details
the implementation. @chp:results presents the evaluation results. @chp:conclusion concludes
the thesis.

= Background <chp:background>

This chapter introduces the background knowledge required to understand this thesis.

== Integrated Circuits

An #acr("IC") is a set of electronic circuits on a small flat piece of semiconductor
material. Modern #acrpl("IC") contain billions of transistors and operate at clock
frequencies exceeding several gigahertz. #acrpl("SoC") integrate a complete system —
processor, memory, and peripherals — onto a single die, and are the focus of research
at the #acr("IIS").

== Hardware Description Languages

#acrpl("HDL") are used to describe the structure and behavior of electronic circuits.
The most commonly used #acrpl("HDL") are VHDL and SystemVerilog. Designs are typically
written at the #acr("RTL") abstraction and then synthesized to gates for an
#acr("ASIC") or mapped to an #acr("FPGA").

= Related Work <chp:related>

This chapter reviews existing work in the field and positions our contributions relative
to the state of the art.

Several groups have proposed similar architectures. However, none of these
approaches achieve the combination of performance and energy efficiency presented in
this work.

= Theory <chp:theory>

This chapter presents the theoretical foundations underlying our approach.

== Problem Formulation

Let $G = (V, E)$ be a directed graph representing the dataflow of a computation, where
$V$ is the set of operations and $E$ is the set of data dependencies between them.

== Algorithmic Approach

Our approach builds on the following key insight: by exploiting the structure of $G$,
we can schedule operations more efficiently than existing methods.

= Architecture <chp:architecture>

This chapter describes the proposed hardware architecture in detail.

== Overview

@fig:architecture shows the high-level block diagram of the proposed architecture.
The design consists of three main components: a frontend, a backend, and a memory subsystem.

#figure(
  canvas({
    import draw: *
    let blk(pos, name, label, color) = {
      rect(pos, (rel: (2.8, 1)), name: name, radius: 0.1, fill: color)
      content(name, label)
    }
    blk((0, 0), "fe", [Frontend], rgb("#a8d8ea"))
    blk((3.8, 0), "be", [Backend], rgb("#a8e6cf"))
    blk((7.6, 0), "mem", [Memory], rgb("#ffd3b6"))
    line("fe.east", "be.west", mark: (end: ">"))
    line("be.east", "mem.west", mark: (end: ">"))
  }),
  caption: [High-level architecture of the proposed design.],
) <fig:architecture>

== Frontend

The frontend is responsible for fetching and decoding instructions. It implements a
speculative execution pipeline with branch prediction.

== Backend

The backend executes decoded instructions out of order, exploiting instruction-level
parallelism.

= Implementation <chp:implementation>

This chapter describes the #acr("RTL") implementation and the physical design flow.

== RTL Design

The design is implemented in SystemVerilog following the lowRISC coding style guide.
The top-level module instantiates the frontend, backend, and memory subsystem.

== Synthesis Results

@tab:synthesis summarizes the synthesis results for the proposed design on a 22 nm
technology node.

#figure(
  table(
    columns: (1fr, 2fr, 2fr),
    align: (left, right, right),
    stroke: none,
    table.hline(stroke: 1.5pt),
    table.header([Module], [Area kGE], [Freq. MHz]),
    table.hline(stroke: 0.75pt),
    [Frontend], [42.3], [900],
    [Backend], [128.7], [700],
    [Memory], [35.1], [800],
    table.hline(stroke: 0.75pt),
    [*Total*], [*206.1*], [*700*],
    table.hline(stroke: 1.5pt),
  ),
  caption: [Post-synthesis results on 22 nm technology.],
) <tab:synthesis>

= Results <chp:results>

This chapter presents the experimental evaluation of the proposed design.

== Experimental Setup

We evaluate the design using a suite of standard benchmarks. All measurements are
performed on post-layout netlist simulations.

== Performance

Our design achieves an average speedup of 1.8× over the baseline architecture while
consuming 30% less energy.

= Conclusion <chp:conclusion>

This thesis presented a novel integrated systems architecture that achieves significant
improvements in performance and energy efficiency. The key insight was to exploit
dataflow structure to improve scheduling.

== Future Work

Future work will explore extending the architecture to support multi-core configurations
and investigate further optimizations at the physical design level.
