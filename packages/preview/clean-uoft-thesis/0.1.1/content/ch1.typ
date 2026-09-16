// Re-import the package anywhere you wish to use multicaption()
#import "@preview/clean-uoft-thesis:0.1.1": *

= First Chapter

== Subtopic

=== Subsubtopic

==== Subsubsubtopic

#figure(
  rect(),
  caption: multicaption[Brief title shown in List of Figures.][
      Additional caption elaboration that is displayed under the figure after the brief title, but is not displayed in the List of Figures.
  ],
)

#figure(
  rect(),
  caption: [Figure with a regular caption.]
)
