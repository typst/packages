// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>

#import "@preview/ethz-iis-assignment:1.0.0": *

#show: assignment.with(
  projecttype: "master",
  bibliography: bibliography("references.bib", style: "ieee", full: true),
  student: "Student Name",
  title: "Master Thesis Title",
  advisors: (
    (
      name: "First supervisor",
      office: "OAT UXX",
      mail: "first.supervisor@iis.ee.ethz.ch",
    ),
    (
      name: "Second Supervisor",
      office: "OAT UYY",
      mail: "second.supervisor@iis.ee.ethz.ch",
    ),
  ),
  professors: (
    (name: "Prof Dr. P. Professor", mail: "professor@iis.ee.ethz.ch"),
  ),
)

= Introduction

This section serves to set up the context of the work, but does not include the task.

= Project Description

The core goal of the project is to ... (1 paragraph)

= Milestones

The following are the milestones that we expect to achieve throughout the project:

- Milestone 1
- Milestone 2
- Milestone 3
  + Step 1
  + Step 2
  + Step 3

== Stretch Goals

Should the above milestones be reached earlier than expected and you are motivated to do further work, we propose the following stretch goals to aim for:

- SG 1
- SG 2
- SG 3

= Project Realization

== Time Schedule

The time schedule presented in @fig:time_plan is merely a proposition; it is primarily intended as a reference and an estimation of the time required for each required step.

#import "@preview/timeliney:0.4.0"

// Define styles for tasks, groups, and milestones that are used multiple times.
#let task-style = (stroke: 6pt + gray)
#let group-style = (stroke: 6pt + black)
#let milestone-style = (stroke: (dash: "dashed"))
#let ms(at, label) = timeliney.milestone(at: at, style: milestone-style, align(
  center,
  [*#label*],
))

#figure(
  timeliney.timeline(
    show-grid: true,
    {
      import timeliney: *

      headerline(group(..range(14).map(n => strong("W" + str(n + 1)))))

      taskgroup(title: [*Familiarization*], style: group-style, {
        task("Read the paper", (0, 1), style: task-style)
        task("Clone the repository", (1, 2), style: task-style)
      })

      taskgroup(title: [*Development*], style: group-style, {
        task("Implement feature", (2, 4), style: task-style)
        task("Verification", (4, 7), style: task-style)
        task("Backend trials", (7, 11), style: task-style)
        task("Measurements", (10, 13), style: task-style)
      })

      taskgroup(title: [*Finishing*], style: group-style, {
        task("Write report", (12, 13), style: task-style)
        task("Prepare presentation", (13, 14), style: task-style)
      })

      ms(2, "Milestone 1")
      ms(7, "Milestone 2")
      ms(12, "Milestone 3")
    },
  ),
  caption: [Proposed time schedule and investment],
)<fig:time_plan>
