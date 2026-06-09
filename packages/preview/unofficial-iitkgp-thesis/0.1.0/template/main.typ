#import "@preview/unofficial-iitkgp-thesis:0.1.0": iitkgp-thesis

// ============================================
// METADATA & FRONT MATTER
// ============================================
#show: iitkgp-thesis.with(
  // --- Core Details ---
  title: "Your Project Title Goes Here: A Comprehensive Study and Analysis",
  author: "Student Name",
  rollno: "21CHXXXXX",
  supervisor: "Prof. Supervisor Name",
  department: "Chemical Engineering",
  degree: "Dual Degree (B.Tech. + M.Tech.)",

  // --- Overrides ---
  report-type: "M.Tech. Project–II (CH57004)",
  date: "April 26, 2026",
  logo: image("Images/logo.svg", width: 80mm), // Passes the image object directly

  // --- Front Matter ---
  certificate-text: [
    This is to certify that the thesis report entitled *Your Project Title Goes Here: A Comprehensive Study and Analysis*,
    submitted by *Student Name* (Roll Number: _21CHXXXXX_),
    a Dual Degree student of *Chemical Engineering*, Indian Institute of Technology Kharagpur,
    towards partial fulfilment of the requirements for the award of the Dual Degree (B.Tech. + M.Tech.),
    is a record of bona fide work carried out by him under my supervision and guidance during the Spring Semester, 2025–26.
  ],

  declaration-text: [
    (a) The work contained in this report has been done by me under the guidance of my supervisor.

    (b) The work has not been submitted to any other Institute for any degree or diploma.

    (c) I have conformed to the norms and guidelines given in the Ethical Code of Conduct of the Institute.

    (d) Wherever I have used materials (data, theoretical analysis, figures, and text) from other sources, I have given due credit to them by citing them in the text of the thesis and giving their details in the references. Further, I have taken permission from the copyright owners of the sources, wherever necessary.
  ],

  abstract: [
    This is a placeholder for your abstract. The abstract should be a concise summary of your research, covering the background, methodology, key findings, and conclusions.

    #lorem(120)

  ],

  acknowledgment: [
    I would like to express my sincere gratitude to my supervisor, *Prof. Supervisor Name*, for their invaluable guidance, continuous encouragement, and insightful suggestions throughout the course of this project.

    #lorem(50)
  ],

  // --- Toggles & Lists ---
  figures-outline: true,
  tables-outline: true,

  abbreviations: (
    ("IIT", "Indian Institute of Technology"),
    ("KGP", "Kharagpur"),
    ("GUI", "Graphical User Interface"),
    ("API", "Application Programming Interface"),
    ("CFD", "Computational Fluid Dynamics"),
  ),
)


// ============================================
// MAIN CONTENT CHAPTERS
// ============================================

= Introduction

== Background
The introduction chapter sets the stage for your research. Here, you define the context of your problem and why it is important to study. #lorem(80)

== Problem Statement
Clearly define the problem you are trying to solve. #lorem(60)

== Objectives
The primary objectives of this project are:
+ To investigate the fundamental properties of the proposed system.
+ To develop a computational model to simulate the behavior.
+ To validate the model against experimental data.
+ To optimize the parameters for maximum efficiency.


= Literature Review

== Overview of Existing Methods
A thorough literature review discusses what has already been done in your field. #lorem(100)

As shown in previous studies, the relationship can be summarized effectively, but gaps still remain. #lorem(50)

== Research Gap
Identify the gap in the current literature that your project aims to address. #lorem(70)


= Methodology

== Theoretical Framework
Describe the theoretical basis of your work. This section often contains mathematical equations.

The governing equation for the system can be expressed as:

$ f(x) = integral_0^infinity e^(-t) t^(x-1) d t $

Where $f(x)$ represents the gamma function, and $t$ is the integration variable.

== Experimental Setup
Describe your experimental or computational setup. Below is an example of an embedded image from the `Images` folder.

#figure(
  image("Images/work_plan.svg", width: 80%),
  caption: [Schematic representation of the experimental setup and work plan used in this study.],
) <fig-setup>

As seen in @fig-setup, the setup consists of several interconnected modules.


= Results and Discussion

== Performance Analysis
Discuss your findings here. Present your data using tables and graphs. #lorem(60)

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1.2fr),
    inset: 8pt,
    align: center,
    fill: (_, row) => if row == 0 { luma(220) } else { white },
    stroke: 0.5pt,
    table.header([*Sample ID*], [*Parameter A*], [*Parameter B*], [*Efficiency (%)*]),
    [Test-01], [45.2], [9.6], [88.4],
    [Test-02], [48.1], [9.8], [91.2],
    [Test-03], [42.9], [9.5], [86.7],
    [*Average*], [*45.4*], [*9.6*], [*88.7*],
  ),
  caption: [Summary of performance metrics across different test iterations.],
) <tab-results>

The results detailed in @tab-results indicate a strong correlation between Parameter A and overall efficiency.

== Sensitivity Analysis
#lorem(80)

#figure(
  rect(width: 70%, height: 200pt, fill: luma(240), stroke: 1pt + luma(150))[
    #set align(center + horizon)
    #text(fill: luma(100))[Placeholder for Data Plot / Chart]
  ],
  caption: [Effect of varying parameters on the system's output.],
) <fig-plot>


= Conclusion and Future Work

== Conclusion
Summarize the main findings of your thesis. #lorem(100)

== Future Work
Suggest potential avenues for future research based on your findings.
- Expanding the computational model to include multi-physics interactions.
- Conducting long-term durability tests under real-world conditions.
- Developing a user-friendly software tool for automated analysis.


// ============================================
// BIBLIOGRAPHY
// ============================================
#pagebreak(weak: true)
#heading(level: 1, numbering: none)[References]

// Uncomment the line below and ensure you have a citations.bib file to generate references.
// #bibliography("citations.bib", style: "ieee", title: none)
