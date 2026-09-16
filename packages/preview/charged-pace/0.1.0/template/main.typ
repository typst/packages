#import "@preview/charged-pace:0.1.0": manuscript

// Aliases: thesis, dissertation
#show: manuscript.with(
  title: [A Typst Template for a PhDCS Dissertation or MSCS Thesis],
  author: [Forename Surname],
  date: (month: "May", year: 2026),
  degree: "Master's",
  bibliography-decl: bibliography("refs.yaml"),
  abstract: [An abstract should be typed single-spaced and contain no more than 350 words. \ \
    This template was created based on _CSIS DPS Guide for Formatting the Dissertation._ \ \
    If your abstract spans two pages, be sure that the "Table of Contents" is numbered with the correct roman numeral.],
)

= Introduction <sec:introduction>
#lorem(120)

== Problem Statement <sec:prob_state>
#lorem(300)

== Thesis Structure <sec:thesis_struct>
#lorem(200)

= Method <sec:method>
#lorem(45)
$ a + b = gamma $ <eq:gamma>
#lorem(80)

#figure(
  placement: none,
  circle(radius: 15pt),
  caption: [A circle representing the Sun.],
) <fig:sun>

In @fig:sun you can see a common representation of the Sun, which is a star that is located at the center of the solar system.

#lorem(120)

#figure(
  caption: [The Planets of the Solar System and Their Average Distance from the Sun],
  placement: top,
  table(
    // Table styling is not mandated by the IEEE. Feel free to adjust these
    // settings and potentially move them into a set rule.
    columns: (6em, auto),
    align: (left, right),
    inset: (x: 8pt, y: 4pt),
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },

    table.header[Planet][Distance (million km)],
    [Mercury], [57.9],
    [Venus], [108.2],
    [Earth], [149.6],
    [Mars], [227.9],
    [Jupiter], [778.6],
    [Saturn], [1,433.5],
    [Uranus], [2,872.5],
    [Neptune], [4,495.1],
  ),
) <tab:planets>

In @tab:planets, you see the planets of the solar system and their average distance from the Sun.
The distances were calculated with @eq:gamma that we presented in @sec:method.

#lorem(240)

#lorem(240)
