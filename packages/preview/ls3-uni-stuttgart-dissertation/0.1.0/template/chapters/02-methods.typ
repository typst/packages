= Methods

Consider the governing @PDE for flow in porous media.

$ S_s (partial h) / (partial t) = nabla dot (K nabla h) + q $ <eq:flow>

Solving @eq:flow requires boundary conditions.

== A figure and a table

#figure(
  image("../assets/placeholder-figure.pdf", width: 60%),
  caption: [A placeholder figure.],
) <fig:placeholder>

As @fig:placeholder shows, placeholders are rectangular.

#figure(
  table(
    columns: 3,
    table.header([Case], [Mean], [Variance]),
    [A], [0.31], [0.02],
    [B], [0.48], [0.05],
  ),
  caption: [A placeholder table.],
) <tab:cases>

== A listing

#figure(
  ```python
  import numpy as np
  samples = np.random.normal(size=1000)
  print(samples.mean())
  ```,
  caption: [Monte Carlo in three lines.],
) <lst:mc>
