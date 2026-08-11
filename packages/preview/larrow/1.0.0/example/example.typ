#import "@preview/larrow:1.0.0": *

#set page(width: 16cm, height: 5cm, margin: (left: 1cm))

#let lal = arrow-label.with(dx: -2mm, dy: 1mm)

#lal(<end-left>)*This is an example for label arrows:*
+ This package allows drawing arrows between labels. ~ <start-1>
+ The arrows can be styled in different ways to suit your needs.
+ It's easy to curve the arrow to your liking with the `bend` parameter.
+ Now let's get to the end.
+ This really didn't need to be another point but hey,#al(<end-2>) we just
  needed to fill some space. #arrow-label(<end-1>)

#lal(<start-left>)Everything clear? If not, start from the beginning.
~ <start-2>

#label-arrow(<start-1>, <end-1>, bend: -40, tip: "o", from-tip: "|",
             stroke: 1.5pt + red, both-offset: (1mm, 2mm))
#larw(<start-left>, <end-left>, bend: -25, both-tip: ">")
#label-arrow(<start-2>, <end-2>, from-offset: (0pt, 3pt),
             to-offset: (0pt, -4pt))
