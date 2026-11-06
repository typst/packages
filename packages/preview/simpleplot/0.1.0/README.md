a simple package to quickly add simple graphs into your document.

# instructions: 
- connect multiple points with a line:
  - add((dots)) example: add(((1,5),(4,6)))
- scale the graph:
  - xsize: horizontal size
  - ysize: vertical size
- position the graph:
  - vertikal: top, bottom, horizon
  - horizontal: left, right, center
- specify axis style:
  - axis-style: [scientific, scientific-auto, school-book]
- full example:
```
#simpleplot(
  xsize: 5,
  ysize: 5,
  alignment: center+horizon,
  axis-style: "school-book",
  {
    add(((0, 0), (4, 6)))
    add(((-5, -3), (4, 6),(5,4)))
  }
)
```
- will look like this:
<img src="graph_bright.png#gh-light-mode-only">
<img src="graph_dark.png#gh-dark-mode-only">

- to display this text, add the ``help()`` function to your document.
- this is using cetz and cetz-plot. so if you are familiar, you can add more to the body of the function.
