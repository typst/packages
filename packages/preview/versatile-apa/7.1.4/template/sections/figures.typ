#import "@preview/versatile-apa:7.1.4": apa-figure

= Sample figures
// Sample figures taken from https://apastyle.apa.org/style-grammar-guidelines/tables-figures/sample-figures
== Sample bar graph
Referencing @fig:sample-bar-graph.

#apa-figure(
  caption: [Framing Scores for Different Reward Sizes],
  image("../assets/images/sample-bar-graph.png"),
  note: [
    Framing scores of adolescents and young adults are shown for low and high risks and for small, medium, and large rewards (error bars show standard errors).
  ],
  label: "fig:sample-bar-graph",
)

#pagebreak()
== Sample line graph
Referencing @fig:sample-line-graph.

#apa-figure(
  caption: [Mean Regression Slopes in Experiment 1],
  image("../assets/images/sample.line-graph.png"),
  note: [
    Mean regression slopes in Experiment 1 are shown for the stereo motion, biocularly viewed monocular motion, combined, and monocularly viewed monocular motion conditions, plotted by rotation amount. Error bars represent standard errors. From “Large Continuous Perspective Change With Noncoplanar Points Enables Accurate Slant Perception,” by X. M. Wang, M. Lind, and G. P. Bingham, 2018, Journal of Experimental Psychology: Human Perception and Performance, 44(10), p. 1513 (https://doi.org/10.1037/xhp0000553). Copyright 2018 by the American Psychological Association.
  ],
  label: "fig:sample-line-graph",
)

== Sample CONSORT flowchart
Referencing @fig:sample-consort-flowchart.

#apa-figure(
  caption: [CONSORT Flowchart of Participants],
  image("../assets/images/sample-consort-flowchart.png"),
  label: "fig:sample-consort-flowchart",
)

== Sample path model
Referencing @fig:sample-path-model.

#apa-figure(
  caption: [Path Analysis Model of Associations Between ASMC and Body-Related Constructs],
  image("../assets/images/sample-path-model.png"),
  note: [
    The path analysis shows associations between ASMC and endogenous body-related variables (body esteem, body comparison, and body surveillance), controlling for time spent on social media. Coefficients presented are standardized linear regression coefficients.],
  probability-note: [#super[\*\*\*]$p < .001$.],
  label: "fig:sample-path-model",
)

== Sample qualitative research figure
Referencing @fig:sample-qualitative-research-figure.

#apa-figure(
  caption: [Organizational Framework for Racial Microaggressions in the Workplace],
  image("../assets/images/sample-qualitative-research-figure.png"),
  label: "fig:sample-qualitative-research-figure",
)

== Sample mixed methods research figure
Referencing @fig:sample-mixed-methods-research-figure.

#apa-figure(
  caption: [A Multistage Paradigm for Integrative Mixed Methods Research],
  image("../assets/images/sample-mixed-methods-research-figure.png"),
  label: "fig:sample-mixed-methods-research-figure",
)

== Sample illustration of experimental stimuli
Referencing @fig:sample-stimuli.

#apa-figure(
  caption: [Examples of Stimuli Used in Experiment 1],
  image(
    "../assets/images/sample-illustration-experimental-stimuli.png",
    alt: "Two computer-generated cartoon bees, one with two legs, a striped body, single wings, and antennae, and the other with six legs, a spotted body, double wings, and no antennae.",
  ),
  note: [
    Stimuli were computer-generated cartoon bees that varied on four binary dimensions, for a total of 16 unique stimuli. They had two or six legs, a striped or spotted body, single or double wings, and antennae or no antennae. The two stimuli shown here demonstrate the use of opposite values on all four binary dimensions.
  ],
  label: "fig:sample-stimuli",
)

== Sample map
Referencing @fig:sample-map

#apa-figure(
  caption: [Poverty Rate in the United States, 2017],
  image(
    "../assets/images/sample-map.png",
    alt: "Map of the United States, with color gradients indicating percentage of people living in poverty.",
  ),
  note: [
    The map does not include data for Puerto Rico. Adapted from 2017 Poverty Rate in the United States, by U.S. Census Bureau, 2017 (https://www.census.gov/library/visualizations/2018/comm/acs-poverty-map.html). In the public domain.
  ],
  label: "fig:sample-map",
)
