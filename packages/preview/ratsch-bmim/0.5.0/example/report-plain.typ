#import "./preamble.typ": *

#show: bmim.report(
  title: (
    "This is a Report",
    "",
  ),
  lang: "en",
  course: none,
  authors: ("John Doe", "Jane Doe", "Max Mustermann"),
  date: datetime.today(),
  show-solution: none,
  titleblock: none,
  task-show-points: false,
)

#align(center)[
  #text(size: 40pt, weight: "bold")[A Plain Report]
]

#lorem(10)

Lists:
- Element 1
- Element 1
- Element 1
- Element 1
and some text around.

Group axioms:
+ Associativity
+ Existence of identity element
+ Existence of inverse element

Another important list:
+ Newton's laws of motion are three physical laws that relate the motion of an
  object to the forces acting on it.
  + A body remains at rest, or in motion at a constant speed in a straight
    line, unless it is acted upon by a force.
  + The net force on a body is equal to the body's acceleration multiplied by
    its mass
  + If two bodies exert forces on each other, these
    forces have the same magnitude but opposite directions
+ Another important force is hooks law: $ arrow(F) = -k
  arrow(Delta x) $


#lorem(200) 

