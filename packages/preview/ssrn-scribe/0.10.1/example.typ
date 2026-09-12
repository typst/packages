#import "@preview/ssrn-scribe:0.10.1": paper
#import "extra.typ": *

#show: great-theorems-init

#show: paper.with(
  meta: (
    title: [Queue-aware Scheduling for Shared Research Equipment],
    subtitle: [A simulation study of batching and changeover costs],
    authors: (
      (
        name: "Leila Morgan",
        department: "Department of Operations Research",
        affiliation: "Westbridge Institute of Technology",
        email: "leila.morgan@example.edu",
        note: "Corresponding author. This paper, its authors, institutions, and results are fictional.",
      ),
      (
        name: "Noah Adeyemi",
        department: "Research Infrastructure Unit",
        affiliation: "Westbridge Institute of Technology",
        email: "noah.adeyemi@example.edu",
      ),
    ),
    date: "June 2026",
    abstract: [
      Shared laboratories often schedule instruments in arrival order even when
      switching between sample families requires substantial setup time. We
      compare first-come-first-served scheduling with a queue-aware batching
      rule in a fictional discrete-event simulation. Under moderate demand,
      batching lowers the share of time spent on changeovers while preserving
      predictable waiting times. The example also demonstrates optional theorem
      and table helpers without adding them to the core template.
    ],
    keywords: [shared facilities, scheduling, batching, discrete-event simulation],
    JEL: [C61, C63],
    acknowledgments: [
      This demonstration uses invented data and does not describe a real
      institution or experiment.
    ],
  ),
  theme: (
    font: ("Times New Roman", "Libertinus Serif"),
    heading-font: ("Times New Roman", "Libertinus Serif"),
    body-size: 11pt,
    text: rgb("#111111"),
    heading: rgb("#111111"),
    muted: rgb("#444444"),
    accent: rgb("#111111"),
    rule: rgb("#8a8a8a"),
  ),
  layout: (
    maketitle: true,
    density: "balanced",
    margin: (left: 2.54cm, right: 2.54cm, top: 2.54cm, bottom: 2.54cm),
    author-columns: 2,
    cover-text-width: 90%,
  ),
)

= Introduction

Universities increasingly operate microscopes, spectrometers, and fabrication
tools as shared facilities. A simple arrival-order queue is transparent, but it
can trigger repeated changeovers between sample families. When setup consumes a
large share of instrument time, a small amount of batching may improve access
for the whole user community.

This study compares two scheduling policies in a stylized facility. The first
serves jobs in arrival order. The second may hold a job briefly when another job
from the current sample family is already waiting. The design goal is not to
eliminate waiting, but to reduce avoidable setup while keeping delays bounded.

= Scheduling model

Let $s > 0$ denote the fixed setup time required when consecutive jobs belong to
different sample families. Jobs within a family have identical processing time,
and all jobs are available before the schedule begins.

#theorem(title: "Single-family batching")[
  For a fixed set of available jobs, processing each sample family in one
  contiguous batch weakly reduces total setup time relative to any schedule
  that returns to a previously processed family.
]

#proof[
  Every return to a previously processed family creates at least one additional
  family transition. Merging that family's separated blocks removes a transition
  and does not change the number or duration of jobs. Repeating this operation
  produces one block per family with no greater total setup time.
]

The proposition motivates batching, but it does not by itself protect individual
users from long delays. Our queue-aware policy therefore imposes a maximum hold
time before the oldest waiting job must be served.

= Simulation design

The fictional simulation covers a thirty-day operating period with eight-hour
days. Arrivals follow the same demand trace under each policy. We vary only the
scheduling rule and summarize one hundred replications.

#align(center)[
  #tablex(
    columns: 4,
    align: center + horizon,
    auto-vlines: false,
    hlinex(y: 0),
    [*Policy*], [*Median wait*], [*Setup share*], [*Utilization*],
    hlinex(y: 1),
    [Arrival order], [46 min], [18%], [71%],
    [Queue-aware batch], [51 min], [11%], [77%],
    [Long batch], [73 min], [8%], [79%],
    hlinex(),
  )
]

= Results

The queue-aware rule reduces the simulated setup share by seven percentage
points and increases utilization by six points. Median waiting time rises by
five minutes, while the ninety-fifth percentile remains below the configured
hold-time limit. The long-batch policy saves more setup time but produces a much
larger delay, illustrating why utilization alone is an incomplete objective.

= Discussion

The results are illustrative, not empirical. Real facilities face cancellations,
priority projects, heterogeneous processing times, and maintenance windows. A
practical evaluation should preregister service-level outcomes, report effects
by user group, and test the policy prospectively before deployment.
