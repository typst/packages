#import "@preview/classic-thesis-uct:0.1.1": *

#let content = [
This chapter should explain how the research questions will be answered and why the chosen approach is appropriate. The examples below demonstrate common proposal elements that are often expected in reviewable academic documents.

== Research Design

Describe whether the project is theoretical, experimental, qualitative, quantitative, computational, mixed-methods, or another design. State why the design matches the research questions and what evidence it will produce.

== Data or Materials

Explain what data, participants, case studies, instruments, simulations, or source materials will be used. If the project includes a hardware, software, or systems component, an architecture figure is often useful.

#side-caption-figure([Example methodology figure. Replace this with a workflow, architecture, pipeline, sampling design, or study process diagram.])[
  #image("../graphics/esn_architecture.png", width: 100%)
]

== Methods of Analysis

Outline the analytical methods, modelling techniques, experiments, or evaluation procedures that will be applied. If your work uses mathematical modelling, this chapter is a natural place for equations such as:

#numbered-equation($ J(theta) = sum_(i = 1)^n w_i (y_i - hat(y)_i(theta))^2 $)

Here, $J(theta)$ is a generic objective function, $w_i$ are optional weights, $y_i$ are observed values, and $hat(y)_i(theta)$ are model predictions. Replace this example with the notation appropriate to the project.

#side-caption-table(
  [Example summary table for a methodology chapter.],
  (1.2fr, 2.35fr, 1.55fr),
  (
    ("Work Package", "Purpose", "Evidence Output"),
    ([Literature synthesis], [Establishes the current state of knowledge and identifies the gap], [Review chapter or annotated matrix]),
    ([Pilot or feasibility work], [Tests assumptions, access, instrumentation, or analytic workflow], [Pilot report or revised protocol]),
    ([Main analysis], [Produces the primary evidence needed to answer the research questions], [Results, models, or thematic findings]),
    ([Validation or evaluation], [Assesses robustness, generalisability, or practical performance], [Comparative metrics or triangulated findings]),
  ),
)

== Ethics and Risk

Document any ethical approval requirements, operational risks, data governance constraints, or feasibility concerns. If the proposal involves human participants, sensitive data, fieldwork, or hazardous environments, reviewers will usually expect this material to be explicit.

== Expected Contribution

State what the project is expected to contribute to knowledge, practice, or policy. Make the contribution proportionate to the scope of a PhD proposal and tightly coupled to the methods already described.
]
