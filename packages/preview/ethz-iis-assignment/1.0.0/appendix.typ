// Copyright 2026 ETH Zurich.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Author: Tim Fischer <fischeti@iis.ee.ethz.ch>
//
// Boilerplate appendix sections appended to every IIS assignment.

#let appendix(projecttype) = [
  == Meetings

  Weekly meetings will be held between the student and the assistants.
  The exact time and location of these meetings will be determined within the first week of the project in order to fit the student's and the assistants' schedule.
  These meetings will be used to evaluate the status and progress of the project.
  Beside these regular meetings, additional meetings can be organized to address urgent issues as well.

  == Weekly Reports

  #if projecttype == "master" [
    The student is required to a write a weekly report at the end of each week and to send it to his advisors by email.
  ] else [
    The student is advised, but not required, to a write a weekly report at the end of each week and to send it to his advisors.
  ]
  The idea of the weekly report is to briefly summarize the work, progress and any findings made during the week, to plan the actions for the next week, and to discuss open questions and points.
  The weekly report is also an important means for the student to get a goal-oriented attitude to work.

  == Coding Guidelines

  === HDL Code Style
  Adapting a consistent code style is one of the most important steps in order to make your code easy to understand.
  If signals, processes, and modules are always named consistently, any inconsistency can be detected more easily.
  Moreover, if a design group shares the same naming and formatting conventions, all members immediately _feel at home_ with each other's code. At IIS, we use lowRISC's style guide for SystemVerilog HDL: #link("https://github.com/lowRISC/style-guides/")[https://github.com/lowRISC/style-guides/].

  === Software Code Style
  We generally suggest that you use style guides or code formatters provided by the language's developers or community. For example, we recommend LLVM's or Google's code styles with `clang-format` for C/C++, PEP-8 and `pylint` for Python, and the official style guide with `rustfmt` for Rust.

  === Version Control
  Even in the context of a student project, keeping a precise history of changes is _essential_ to a maintainable code base. You may also need to collaborate with others, adopt their changes to existing code, or work on different versions of your code concurrently. For all of these purposes, we heavily use _Git_ as a version control system at IIS. If you have no previous experience with Git, we _strongly_ advise you to familiarize yourself with the basic Git workflow before you start your project.

  == Report

  Documentation is an important and often overlooked aspect of engineering.
  A final report has to be completed within this project.

  The common language of engineering is de facto English.
  Therefore, the final report of the work is preferred to be written in English.

  Any form of word processing software is allowed for writing the reports, nevertheless the use of LaTeX with Inkscape
  or any other vector drawing software (for block diagrams) is strongly encouraged by the IIS staff.

  If you write the report in LaTeX, we offer an instructive, ready-to-use template, which can be forked from the Git repository at #link("https://iis-git.ee.ethz.ch/akurth/iisreport")[https://iis-git.ee.ethz.ch/akurth/iisreport].

  === Final Report
  The final report has to be presented at the end of the project and a digital copy needs to be handed in and remain property of the IIS.
  Note that this assignment is part of your report and has to be attached to your final report.

  == Presentation

  There will be a presentation (#if projecttype == "master" [20] else [15] min presentation and 5 min Q&A) at the end of this project in order to present your results to a wider audience.
  The exact date will be determined towards the end of the work.

  = Deliverables

  In order to complete the project successfully, the following deliverables have to be submitted at the end of the work:

  - Final report incl. presentation slides
  - Source code and documentation for all developed software and hardware
  - Test suites (software) and test benches (hardware)
  - Synthesis and implementation scripts, results, and reports
]
