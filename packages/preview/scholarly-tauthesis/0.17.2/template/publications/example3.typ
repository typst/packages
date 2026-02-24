
#import "@preview/scholarly-tauthesis:0.17.2" as tauthesis

#show: tauthesis.publicationMainMatter

// Note that every heading level is one higher in this example publication than it is in the main document.
// This is because the publication attachment title pages are implemented as level 1 headings.

== Introduction <example-pub-3-intro>

#lorem(31)

#lorem(40)

== Background <example-pub-3-background>


#lorem(31)

#math.equation(
  block: true,
  alt: "f(x) = 3 x + 5",
  $f(x) = 3 x + 5$
) <example-pub-3-eq-1>

#lorem(40) @example-pub-3-eq-1

== Methods <example-pub-3-methods>

#lorem(25)

=== Method 1 <example-pub-3-method-1>


#lorem(51)

=== Method 2 <example-pub-3-method-2>

#lorem(73)

== Results <example-pub-3-results>

#lorem(46)

#lorem(75)

== Discussion <example-pub-3-discussion>

#lorem(37)

#lorem(66)

== Conclusions <example-pub-3-conclusions>

#lorem(34)

#lorem(80)

// To generate publication attachments, we update the counter style as follows.

#show: tauthesis.publicationAppendix

== Example publication appendix


#lorem(34)

#lorem(80)

#figure(
    image(
        "../images/tau-logo-fin-eng.svg",
        alt: "Tampere University logo.",
        width: 80%,
    ),
    caption: [A test image with a very long caption: #lorem(26)],
    alt: "A test image with a very long caption."
) <example-pub-3-tau-logo>

#lorem(71) @example-pub-3-tau-logo

#math.equation(
  block: true,
  alt: "g(x) = x ^ 2 - 4",
  $g(x) = x ^ 2 - 4$
)

<example-pub-3-appendix-eq>

#lorem(63) @example-pub-3-tau-logo

== Example publication appendix

#lorem(101)

#tauthesis.theorem(
    title: [Pythagorean theorem],
    reflabel: "example-pub-3-theorem",
    alt: "Pythagorean theorem: for sides a, b and c of a right triangle, where c is the hypotenuse, the equation a ^ 2 + b ^ 2 = c ^ 2 holds."
)[
    For sides
    #math.equation(
        alt: "a",
        $a$
    ),
    #math.equation(
        alt: "b",
        $b$
    )
    and
    #math.equation(
        alt: "c",
        $c$
    )
    of a right triangle, where
    #math.equation(
        alt: "c",
        $c$
    )
    is the _hypotenuse_, the following equality holds:
    #math.equation(
        alt: "
            a^2 + b^2 = c^2 .
        ",
        $
            a^2 + b^2 = c^2 thin .
        $
    )
]

#lorem(54)
