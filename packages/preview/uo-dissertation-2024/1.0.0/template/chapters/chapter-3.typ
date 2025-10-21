// chapters/chapter-3.typ
#import "../config.typ": uo-figure, uo-table

// Set paragraph formatting for body text
#set par(first-line-indent: 0.5in, leading: 2em)

// Create chapter heading
= Title of Your Published/Submitted Paper

// IMPORTANT: Add co-author acknowledgment if this is published/co-authored work
// This chapter has been published in [Journal Name, Volume, Year] with co-authors [Names].
// [Co-author 1] contributed to data collection, [Co-author 2] assisted with analysis.
// I conducted the primary research and wrote the manuscript.

// ===== CHAPTER CONTENT =====

== Abstract

Brief summary of the chapter's research question, methods, key findings, and implications.

== Importance

Explanation of why this research matters to the field and broader scientific community.

== Introduction

Background information specific to this study, leading to the research hypothesis or objectives.

== Results

Presentation of findings from the data analysis, organized by research question or experiment.

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    [Variable], [Measurement], [Scale],
    [Temperature], [Celsius], [Continuous],
    [Pressure], [Pascal], [Continuous],
  ),
  caption: [Experimental variables and measurement scales],
) <tab:variables>

The variables listed in @tab:variables were measured using standardized instruments. Temperature was recorded using a digital thermometer with ±0.1°C accuracy, while pressure measurements utilized a calibrated pressure transducer with ±0.5% accuracy across the operational range.


=== Subsection for Major Finding 1

Description of the first major finding with reference to figures and tables.

=== Subsection for Major Finding 2  

Description of the second major finding with supporting data.

=== Subsection for Major Finding 3

Additional findings that support or extend the main results.

== Discussion

Interpretation of results in context of existing literature and theoretical implications.

=== Implications for Theory

How these findings advance theoretical understanding in the field.

=== Practical Applications

Real-world applications and relevance of the findings.

=== Limitations and Future Directions

Acknowledgment of study limitations and suggestions for future research.

== Materials and Methods

Detailed description of experimental procedures, data collection, and analytical methods.

=== Study Design

Overview of the research design and rationale for methodological choices.

=== Participants/Samples

Description of study population, sampling methods, and inclusion criteria.

=== Data Collection

Procedures for gathering data, including instruments and protocols used.

=== Statistical Analysis

Description of statistical methods and software used for data analysis.

== Acknowledgments

Recognition of funding sources, institutional support, and individuals who contributed.

== Bridge to Chapter IV

Transition paragraph explaining how this chapter's findings lead to the next chapter's research questions.