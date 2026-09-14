= Figure Examples

== Basic Image Figures
// Basic figure with image
#figure(
  image("../figures/example-figure.jpg", width: 70%),
  caption: "Basic image figure with caption.",
) <basic-fig>

You can reference figures like this: @basic-fig

== Table Figures
// Table as a figure
#figure(
  table(
    columns: (auto, auto, auto),
    align: center,
    inset: 1em,
    [*Name*], [*Age*], [*Role*],
    [Alice], [28], [Designer],
    [Bob], [34], [Developer],
    [Charlie], [45], [Manager],
  ),
  caption: "A simple table with a caption",
) <table-fig>

See @table-fig for the data values.

== Code Block Figures
// Code block as a figure
#figure(
  block(
    stroke: 1pt + luma(150),
    fill: luma(240),
    inset: 1em,
    ```python
    def hello_world():
        print("Hello, world!")
        return True
    ```,
  ),
  caption: "Code example as a figure.",
) <code-fig>


== Subfigures

// Multiple subfigures in a grid
#figure(
  grid(
    columns: 2,
    gutter: 1em,
    figure(
      image("../figures/example-figure.jpg", width: 100%),
      caption: "First subfigure",
    ),
    figure(
      image("../figures/example-figure.jpg", width: 100%),
      caption: "Second subfigure",
    ),
  ),
  caption: "A figure containing two subfigures.",
) <subfig>