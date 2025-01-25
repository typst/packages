#import "../main.typ": *

Suppose you have this:
#rect(width: 5cm, height: 2cm, fill: modpattern((100pt, 50pt), circle(stroke: 5pt)))
You can then easily tranlate the circles via the `dx` and `dy` arguments:
#rect(width: 5cm, height: 2cm, fill: modpattern((100pt, 50pt), circle(stroke: 5pt), dx: 5pt, dy: 5pt))

Now, adding a background to:
#rect(width: 5cm, height: 2cm, fill: modpattern((100pt, 50pt), circle(stroke: 5pt, radius: 40pt), dx: 5pt, dy: 5pt))
yield to this:
#rect(width: 5cm, height: 2cm, fill: modpattern((100pt, 50pt), {
  place(box(width: 100%, height: 100%, fill: red))
  place(circle(stroke: 5pt, radius: 40pt))
}, dx: 5pt, dy: 5pt))
The lines are gone. Instead modpattern provides the background argument, so that we can do this:
#rect(width: 5cm, height: 2cm, fill: modpattern((100pt, 50pt), circle(stroke: 5pt, radius: 40pt), dx: 5pt, dy: 5pt, background: red))
You can do crazy stuff now:
#rect(width: 5cm, height: 2cm, fill: modpattern((100pt, 50pt), circle(stroke: 5pt, radius: 40pt), dx: 5pt, dy: 5pt, background: gradient.linear(..color.map.rainbow)))