#import "@preview/pzai-expose:0.1.0": pzai-expose, universities

#show: pzai-expose.with(
  title: [A fancy and very good title],
  author: [Mulmus Autorus],
  email: "mulmus.autorus@uni.edu",
  paper: "a4",
  university: universities.HM,
)

= Introduction
Briefly introduce the reader to the overall topic, describe the problem and scenario you are working on, and --if not obvious-- explain, how this topic matches the topics of the PZAI.

Limit yourself to about 150 words, use references only if absolutely necessary.

= Related Work
Describe the related work and state of the art.
Try to find a balance between covering relevant approaches and detailing those lines of work which are closest to your planned contribution.

Limit yourself to about 300 words, try to avoid references of questionable quality (websites, unverified arxiv preprints, ...) and make sure your references are formatted correctly, e.g.@cooley1965-fft.


= Thesis Objective
Based on the related work, identify the research gap you will be addressing.
Try to formulate research questions that your thesis will answer.
Describe the overall expected outcome of your research.
Helpful formulations could be as below

Consider this an executive summary and limit yourself to 150 words.

The objective of this thesis is ...

To achieve this goal, the following main research questions must be addressed: ....

= Research Outline

Sketch an outline of your research.
What problems will be addressed, how will you solve them?
What are data or infrastructure requirements, and how will you meet them?
How do you measure progress and success in your research?
You can think of this as work packages or milestones that you describe.
Briefly argue why your research will lead to a Dr.-Ing. or Dr. rer. nat.

Limit yourself to about 500 words, use figures, schemes, tables or itemized formatting as needed.

#bibliography("refs.bib")
