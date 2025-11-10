// appendices/appendix.typ
// Single appendix without letter designation
#import "@preview/unofficial-uo-dissertation-2024:1.0.0": appendix

// Create appendix heading - empty string "" for no letter
#appendix("", "Supplemental Figures")

// Set paragraph formatting
#set par(first-line-indent: 0.5in, leading: 2em)

This appendix contains supplemental figures that support the main findings presented in the dissertation.

== 1 Additional Experimental Data

Supplemental figures showing additional experimental results not included in the main chapters.

// Figure A.1
#figure(
  rect(width: 70%, height: 2.5in, fill: gray.lighten(80%))[
    #align(center + horizon)[Supplemental Data Graph]
  ],
  caption: [Complete dataset showing all experimental conditions. Error bars represent standard deviation across three independent trials.],
) <fig:supp-complete-data>

As shown in @fig:supp-complete-data, the complete dataset reveals additional patterns not visible in the summary figures presented in Chapter 3.

// Figure A.2
#figure(
  rect(width: 70%, height: 2.5in, fill: gray.lighten(80%))[
    #align(center + horizon)[Control Group Results]
  ],
  caption: [Control group measurements across all time points. Data collected over 12-week period with weekly measurements.],
) <fig:supp-controls>

== 2 High-Resolution Images

High-resolution versions of key figures from the main text, provided for detailed examination.

// Figure A.3
#figure(
  rect(width: 85%, height: 3in, fill: gray.lighten(80%))[
    #align(center + horizon)[High-Resolution Microscopy Image]
  ],
  caption: [High-resolution microscopy image of sample specimens. Scale bar represents 10 micrometers. Original resolution 4096×4096 pixels.],
) <fig:supp-hires-microscopy>

Figure @fig:supp-hires-microscopy provides greater detail than the compressed version in Chapter 2, allowing for identification of fine structural features.

== 3 Comparative Analysis Figures

Additional comparative analyses and alternative visualizations of the main results.

// Figure A.4
#figure(
  rect(width: 70%, height: 2.5in, fill: gray.lighten(80%))[
    #align(center + horizon)[Alternative Visualization]
  ],
  caption: [Alternative visualization of data from Figure 3.2, using different scaling and color mapping to highlight specific features.],
) <fig:supp-alternative-viz>

== 4 Methodological Details

Detailed diagrams of experimental apparatus and procedural workflows.

// Figure A.5
#figure(
  rect(width: 80%, height: 3in, fill: gray.lighten(80%))[
    #align(center + horizon)[Experimental Apparatus Schematic]
  ],
  caption: [Detailed schematic of experimental apparatus showing all components, connections, and measurement points. Labels indicate (A) input chamber, (B) reaction vessel, (C) measurement probe, (D) output collector.],
) <fig:supp-apparatus>

The complete apparatus diagram (@fig:supp-apparatus) provides technical specifications and dimensions omitted from the simplified diagram in the Methods section.

== 3 Supplemental Video Captions

Video files are available separately via cloud storage or accompanying media.

*Video A.1.* Dynamic visualization of experimental process from initial setup through completion. Duration: 2 minutes 15 seconds. Shows real-time progression of reaction conditions and resulting changes in sample properties.

*Video A.2.* Time-lapse recording of specimen development over 24-hour period. Duration: 45 seconds (actual time compressed 192×). Demonstrates temporal evolution of key morphological features discussed in Chapter 3.

*Video A.3.* Three-dimensional reconstruction and rotation of sample structure. Duration: 1 minute 30 seconds. Provides comprehensive view of spatial relationships not visible in two-dimensional projections.