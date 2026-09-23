# figures/

Put your thesis figures (plots, diagrams, screenshots) here and reference them
from a chapter with a relative path:

```typ
#figure(
  image("../figures/your-figure.png", width: 100%),
  caption: [Your caption.],
) <fig:your-figure>
```

Typst reads PNG, JPEG, GIF, and SVG. `placeholder.svg` ships with the template so
the example compiles out of the box — delete it once you add your own figures.
