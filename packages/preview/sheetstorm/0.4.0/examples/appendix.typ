#import "@preview/sheetstorm:0.4.0": appendix, assignment, task

#show: assignment.with(
  title: "Assignment with Appendix",
  authors: "Appen Dix",
)

#task(points: 42)[
  _Compute the integral $integral_0^1 x^2 d x$._

  $integral_0^1 x^2 d x = 1/3$.

  For a full solution, see @app1.
]

#task[
  For an extended discussion, refer to @app2.
]

#show: appendix

= Detailed solutions

== Task 1 <app1>
An extended solution could look like:
$ integral_0^1 x^2 d x = [1/3 x^3]_0^1 = 1/3 - 0 = 1/3 $.

== Task 2 <app2>
#lorem(40)
