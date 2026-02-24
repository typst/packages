#import "@preview/cetz:0.3.2": *
#import "@preview/cetz-plot:0.1.1": *
#import draw: *
#import plot: *


#let simpleplot(xsize: 5,
                ysize: 5,
                alignment: center + horizon,
                axis-style: "school-book",
                body
                ) = align(
  alignment,
  canvas(
    plot(axis-style: axis-style,
      size: (xsize, ysize),
      body
    )
  )
)



#let help(lan: "en") = if lan == "de" {
  "
  Mehrere Punkte mit einer Linie verbinden:
  add((Punkte)) z.B. add(((1,5),(4,6)))

  Position:
  vertikal: top, bottom, horizon
  horizontal: left, right, center

  Grösse ändern:
  xsize: horizontale Grösse
  ysize: vertikale Grösse

  Axen Style spezifizieren:
  axis-style: [scientific, scientific-auto, school-book]

  Volles Beispiel:
  #simpleplot(
    xsize: 5,
    ysize: 5,
    alignment: center+horizon,
    axis-style: \"school-book\",
    {
      add(((0, 0), (4, 6)))
      add(((-5, -3), (4, 6),(5,4)))
    }
  )
  
  Wird so aussehen:"
} else if lan == "en" {
  "
  connect multiple points with a line:
  add((dots)) example: add(((1,5),(4,6)))

  position the graph:
  vertikal: top, bottom, horizon
  horizontal: left, right, center

  scale the graph:
  xsize: horizontal size
  ysize: vertical size

  specify axis style:
  axis-style: [scientific, scientific-auto, school-book]

  full example:
  #simpleplot(
    xsize: 5,
    ysize: 5,
    alignment: center+horizon,
    axis-style: \"school-book\",
    {
      add(((0, 0), (4, 6)))
      add(((-5, -3), (4, 6),(5,4)))
    }
  )

  will look like this:"
}+simpleplot(
  xsize: 5,
  ysize: 5,
  alignment: top+left,
  axis-style: "school-book",
  {
    add(((0, 0), (4, 6)))
    add(((-5, -3), (4, 6),(5,4)))
  }
)

