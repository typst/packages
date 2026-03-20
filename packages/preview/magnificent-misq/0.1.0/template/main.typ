// template/main.typ — Example document for the MISQ Typst template
//
// This file demonstrates all features of the MISQ submission template.
// Replace the title, abstract, keywords, and body text with your own manuscript.
// See misq.typ for configuration options (e.g., paragraph-style).

#import "@preview/magnificent-misq:0.1.0": misq

#show: misq.with(
  title: [Digital Transformation and Organizational Resilience: A Longitudinal Study of Enterprise Information Systems Adoption],
  abstract: [
    Digital transformation has emerged as a critical strategic imperative for organizations seeking to maintain competitive advantage in increasingly turbulent environments. Drawing on dynamic capabilities theory and institutional theory, this study examines how enterprise information systems adoption shapes organizational resilience over time. We conducted a longitudinal field study spanning three years across twelve organizations in the financial services and healthcare sectors. Our findings reveal that resilience outcomes depend not merely on the technical capabilities of adopted systems, but on the degree to which organizations develop complementary routines for sensing environmental changes and reconfiguring digital resources in response. We identify three distinct adoption trajectories and demonstrate that organizations following an adaptive trajectory achieve significantly higher resilience scores than those following compliance-driven or innovation-avoidance trajectories. Theoretical and practical implications for IS researchers and executives are discussed.
  ],
  keywords: ("digital transformation", "organizational resilience", "enterprise systems", "dynamic capabilities", "longitudinal study"),
  paragraph-style: "indent",
)

= Introduction

Information systems researchers have long recognized that technology adoption is not a discrete event but an ongoing organizational process @orlikowski1992duality. As enterprises invest heavily in digital transformation initiatives, questions about how these investments translate into durable organizational capabilities remain inadequately answered. The extant literature has tended to examine adoption outcomes at a single point in time, obscuring the dynamic processes through which organizations develop—or fail to develop—resilience in response to environmental disruption.

This study addresses that gap by examining how the adoption trajectory of enterprise information systems shapes organizational resilience over a three-year period. We argue, following #cite(<creswell2017research>, form: "prose"), that mixed-methods longitudinal designs are particularly well-suited to this kind of process-level inquiry. Our research context—the financial services and healthcare sectors—was chosen because both industries face simultaneous pressures from regulatory change, competitive disruption, and operational complexity @brown2023fault @gupta2018economic.

The remainder of this paper proceeds as follows. Section 2 reviews the theoretical foundations and prior research. Section 3 describes the research methodology. Section 4 presents the findings. Section 5 discusses the theoretical and practical implications, and Section 6 concludes.

= Literature Review

Prior research on digital transformation spans multiple theoretical traditions. This section reviews the two bodies of work most relevant to our study: dynamic capabilities theory and institutional accounts of technology adoption.

== Theoretical Background

Dynamic capabilities theory holds that competitive advantage accrues to firms that can sense environmental shifts, seize emerging opportunities, and reconfigure existing resources @orlikowski1992duality. In an information systems context, digital assets figure prominently in each of these three microfoundations. Sensing capabilities are augmented by analytics and monitoring systems; seizing capabilities are enabled by platform flexibility; and reconfiguring capabilities depend on the modularity and interoperability of existing technology infrastructure.

Institutional theory offers a complementary perspective. Organizations adopt enterprise systems not only to improve operational performance but also to signal legitimacy to external stakeholders. As #cite(<venkatesh2012consumer>, form: "prose") demonstrate in the context of consumer technology, behavioral intentions are shaped by social influence and facilitating conditions as much as by perceived usefulness—a dynamic that operates with similar force in organizational adoption contexts.

=== Key Constructs

We operationalize organizational resilience as the capacity to absorb disruption while maintaining continuous operations and subsequently adapting structural routines in response to new environmental demands. This definition integrates engineering resilience (absorption) and ecological resilience (adaptation) traditions from the broader management literature. Digital transformation capability is defined as the extent to which an organization has developed routines for deploying, extending, and reconfiguring digital resources in pursuit of strategic objectives.

== Prior Research

Earlier IS adoption research established the foundational relationship between system quality and user satisfaction @gupta2018economic. Subsequent work extended these findings to enterprise-level outcomes, demonstrating that system adoption decisions have organization-wide performance consequences that unfold over multi-year periods. Our study builds on this stream by introducing organizational resilience as a key outcome variable and by examining how adoption trajectory—rather than adoption status alone—mediates the relationship between enterprise system investment and resilience outcomes.

= Methodology

This study employed a longitudinal multiple-case design. Data were collected at three points in time (T1, T2, T3) separated by twelve-month intervals across twelve organizations. At each time point, we administered a structured survey instrument, conducted semi-structured interviews with senior IS executives, and extracted archival records from each organization's enterprise system logs.

The sample was selected using theoretical sampling criteria: organizations had to have initiated a major enterprise system adoption project within the six months preceding T1, operate in either financial services or healthcare, and employ more than 500 full-time staff. These criteria yielded a diverse sample spanning community banks, regional insurers, outpatient clinics, and hospital networks. @fig:design illustrates the overall research design, and @tab:stats summarizes the key descriptive statistics for the sample.

#figure(
  rect(width: 4.5in, height: 2.25in, fill: luma(230)),
  caption: [
    Longitudinal research design. Each organization was observed at three time points
    (T1, T2, T3) separated by twelve-month intervals. Quantitative surveys and
    qualitative interviews were conducted at each time point.
  ]
) <fig:design>

#figure(
  table(
    columns: (2.5fr, 1fr, 1fr),
    table.header(
      [Variable], [Mean], [SD],
    ),
    [Digital transformation capability], [3.84], [0.72],
    [Organizational resilience (T3)], [4.12], [0.65],
    [Enterprise system maturity], [3.97], [0.81],
    [Environmental uncertainty], [4.23], [0.58],
  ),
  caption: [Descriptive statistics for key study variables (n = 12 organizations, 847 respondents).]
) <tab:stats>

= Discussion

Our findings extend dynamic capabilities theory by identifying adoption trajectory as an important contingency variable that moderates the relationship between enterprise system investment and resilience outcomes. Organizations that followed an adaptive trajectory—characterized by iterative experimentation and routine reconfiguration—achieved significantly higher resilience at T3 than those following compliance-driven or innovation-avoidance trajectories. This finding resonates with earlier work establishing a link between IS capabilities and organizational agility @orlikowski1992duality.

From a practical standpoint, these results suggest that executives should attend not only to the selection and implementation of enterprise systems but to the organizational routines that govern ongoing system use and adaptation. The adoption journey matters as much as the adoption decision. As #cite(<brown2023fault>, form: "prose") observe, technology-enabled outcomes are shaped by organizational and social factors that are often underestimated in technology investment decisions. Future research should examine whether the trajectory patterns identified here generalize beyond the financial services and healthcare sectors, and whether they persist over longer time horizons than the three years examined in this study.

#pagebreak()

#bibliography("references.bib", title: "References")

#pagebreak()

// NOTE: The appendix heading is set manually rather than using = APPENDIX.
// Using a level-1 heading would produce "5 APPENDIX" due to auto-numbering.
// Authors should use the pattern below to achieve a centered bold heading without a number.
#align(center, text(weight: "bold", size: 12pt)[APPENDIX])

This appendix provides supplementary documentation of the survey instrument administered at each time point. The survey consisted of 42 items organized into six scales corresponding to the key constructs described in Section 2. All items were measured on a seven-point Likert scale anchored at 1 ("Strongly Disagree") and 7 ("Strongly Agree"). Scale reliability estimates (Cronbach's alpha) exceeded 0.80 for all constructs.

Authors requiring multiple appendices should repeat this pattern with distinct headings ("APPENDIX A," "APPENDIX B," etc.) each preceded by a `#pagebreak()` call.
