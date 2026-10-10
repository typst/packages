#import "@preview/uwa-thesis:0.1.0": uwa-thesis

#show: uwa-thesis.with(
  unit-code: "GENG5512",
  title: "My Long Thesis Title",
  short-title: "My Thesis",
  authors: (
    (
      name: "John Doe",
      email: "123456789@student.uwa.edu.au",
      department: "School of Engineering, The  University of Western Australia",
    ),
    (
      name: "Professor Jimbo James",
      email: "jimbo.james@uwa.edu.au",
      department: "School of Engieering, The  University of Western Australia",
    ),
  ),
)

= Abstract
Here's my content, already styled by the template. This has major skibbidy
toilet vibes

= Acknowledgements
More text...

#pagebreak()

= Introduction

= Literature Review

= Project Objectives

= Project Process

#figure(
  image("assets/img.jpeg"),
  caption: [This is a picture caption],
)

= Results and Discussion
#figure(
  table(
    columns: 3,
    align: (left, right, left),
    [*Parameter*], [*Value*], [*Unit*],
    [Noise density], [0.8], [mm/s\^2],
    [Bandwidth], [1.30E+01], [],
    [], [3.62E+00], [],
    [Crest factor], [6], [],
    [Pitch angle error], [0.000368889], [rad rms],
    [], [0.021135799], [deg rms],
    [], [0.126814793], [deg pp],
  ),
  caption: "A test table",
)

= Conclusions and Future Work

= References

= Appendicies

