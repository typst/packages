// For paper: no flooded fills anywhere.
#import "@preview/sprig:0.1.0": *
#set page(width: 17cm, height: auto, margin: 1cm, fill: white)
#set text(font: "New Computer Modern", size: 10pt)

#mindmap([*Missing data*], theme: "print", leaf-width: 3.6,
  branch(title: [Drop rows])[Simple and fast.],
  branch(title: [Mean])[Affected by outliers.],
  branch(title: [Median])[Robust to outliers.],
  branch(title: [KNN])[Captures relationships.],
  branch(title: [MICE])[Complex, preserves structure.],
)
