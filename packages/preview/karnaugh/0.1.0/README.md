# Karnaugh

Draw simple Karnaugh maps. Use with:

```typ
#import "@preview/karnaugh:0.1.0": karnaugh

#karnaugh(("C", "AB"),
  implicants: (
    (0, 1, 1, 2),
    (1, 2, 2, 1),
  ),
  (
    (0, 1, 0, 0),
    (0, 1, 1, 1),
  )
)
```

Samples are available in `sample.pdf`.
