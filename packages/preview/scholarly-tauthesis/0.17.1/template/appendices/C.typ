
#import "../preamble.typ": *

= Test appendix with mathematics in its heading: #math.equation(
  alt: "force = mass acceleration",
  $force = mass acceleration$
)

This test appendix is here to test how the text sizes in
the lists of figures and such behave.

#figure(
    image(
        "../images/tau-logo-fin-eng.svg",
        alt: "A test image with mathematics in its caption.",
        width: 80%
    ),
    caption: [
      A test figure with mathematics in the caption:
      #math.equation(
        alt: "integral_x f(x) dif x .",
        $integral_{x} f(x) dif x thin .$
      )],
) <test-fig-math-in-caption>

The text sizes should be sensible, and mathematics should
also scale to the surrounding text size.

== A level 2 heading with mathematics: #math.equation(
  alt: "integral_x f(x) dif x",
  $integral_{x} f(x) dif x$
)

#lorem(30)

=== A level 3 heading with mathematics: #math.equation(
  alt: "integral_x f(x) dif x",
  $integral_{x} f(x) dif x$
)

#lorem(30)

== Another level 2 heading with mathematics: #math.equation(
  alt: "nabla dot vector(J) = 0",
  $nabla dot vector(J) = 0$
)

#lorem(30)

=== Another level 3 heading with mathematics: #box(
  math.equation(
    alt: "nabla dot vector(J) = 0",
    $nabla dot vector(J) = 0$
  )
)

#lorem(30)
