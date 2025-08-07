#import "@preview/cetz:0.3.2": *
#import "@preview/cetz-plot:0.1.1": *
#import draw: *
#import plot: *


#let add-arrow(point,dir)={
  let len=calc.sqrt(dir.at(0)*dir.at(0)+dir.at(1)*dir.at(1))
  let vec=(dir.at(0)/len,dir.at(1)/len)
  let rot=0.3
  let direction=(calc.cos(rot)*vec.at(0)-calc.sin(rot)*vec.at(1),calc.sin(rot)*vec.at(0)+calc.cos(rot)*vec.at(1))
  let direction1=(calc.cos(-rot)*vec.at(0)-calc.sin(-rot)*vec.at(1),calc.sin(-rot)*vec.at(0)+calc.cos(-rot)*vec.at(1))
  add((
  (point.at(0)-direction1.at(0),point.at(1)-direction1.at(1)),
  point,
  (point.at(0)-direction.at(0),point.at(1)-direction.at(1)),
  (point.at(0)-direction1.at(0),point.at(1)-direction1.at(1))
))
}

#let add-vector(origin, vector)={
  add((origin,(origin.at(0)+vector.at(0),origin.at(1)+vector.at(1))))
  add-arrow((origin.at(0)+vector.at(0),origin.at(1)+vector.at(1)),vector)
}


#let simpleplot(xsize: 5,
                ysize: 5,
                alignment: center + horizon,
                axis-style: "school-book",
                bodyc: none,
                bodyp
                ) = {
  
 



  align(
    alignment,
    canvas({
        plot(axis-style: axis-style,
          size: (xsize, ysize),
          bodyp
        )
        bodyc
      }
    )
  )
}



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

