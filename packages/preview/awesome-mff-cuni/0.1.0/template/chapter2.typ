#import "@preview/awesome-mff-cuni:0.1.0": *

= Chapter 2

Here is a table. You can see that now there is a list of all tables at the end of the document, however the list of images does not show up since there are no images in the document. As soon as you would add one, it will show up too.

#figure(
  table(
    columns: 4,
    [t], [1], [2], [3],
    [y], [0.3s], [0.4s], [0.8s],
  ),
  caption: [Timing results],
)

