
#pdf.attach(
  "B.typ",
  relationship: "source",
  mime-type: "text/vnd.typst",
  description: "The Typst source code for the cross-referencing test attachment B of this thesis.",
)

#import "../preamble.typ": *

= Tests related to cross-referencing

This attachment is here just to make sure that
cross-references work as intended. Towards this end,
@tau-logo-b is here just to make testing within the same
chapter possible.

#figure(
    image(
        "../images/tau-logo-fin-eng.svg",
        alt: "Tampere University logo.",
        width: 80%,
    ),
    caption: [A test image with a very long caption: #lorem(26)],
    alt: "A test image with a very long caption."
) <tau-logo-b>

Also, here is an equation for similar purposes:
#math.equation(
  block: true,
  alt: "A matrix-vector product Lx approx y.",
  $
    matrix(L)
    vector(x)
    approx
    vector(y)
    thin .
  $
)

<test-equation-1>

#import "@preview/scholarly-tauthesis:0.17.2" as tauthesis

Also, why not add a theorem to the mix.

#tauthesis.theorem(
    title: [Pythagorean theorem],
    reflabel: "test-theorem",
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

== Figure tests

@tau-logo-b[] with an empty supplement as the first inline
element of this paragraph, to make sure that there is no
funny whitespace introduced before figure references.

Here is a reference to a figure in a previous chapter:
@tau-logo. Notice the period after the reference, meaning
the spacing around the reference works as intended.

Here is a reference to the same figure but with an
alternative supplement: @tau-logo[Kuvassa].

Table reference: @tab-evaporation-conditions.

Table reference with an alternative supplement:
@tab-evaporation-conditions[Taulukossa].

Table reference with an empty supplement:
@tab-evaporation-conditions[].

== Section tests

A chapter reference: @introduction.

A chapter reference with an alternative supplement:
@introduction[Luvussa].

@introduction as the first element of this paragraph to
test that there is no unnecessary whitespace before heading
references.

== Equation tests

Here is an equation reference: @test-equation-1.

Reference equation in previous chapter:
@fundamental-theorem-of-calculus.

Check that supplements are ignored in the case of equation
references: @test-equation-1[aaa].

@test-equation-1 as the first element of this paragraph.
Again, no predecing whitespace should be generated.

== Citation tests

A citation test: @Bezanson2017Julia.

A citation test with page numbers: @Bezanson2017Julia[s. 1--2]

@Bezanson2017Julia: no preceding whitespace at the start of
a paragraph.

== Theorem tests

Referencing a theorem in this section: @test-theorem.

Referencing a theorem box in another section: @pythagorean-theorem

Referencing a theorem box in another section in Finnish: @pythagoraan-lause

#import "../metadata.typ" as meta

#if tauthesis.thesisTypeToIntFn(meta.thesisType) >= tauthesis.licentiateThesisTypeInt and meta.compilationThesis and meta.attachPublications [
    Referencing a theorem in the attached @tauthesis-publication-anchor-1[Publication]: @example-pub-1-theorem

    Referencing a theorem in the attached @tauthesis-publication-anchor-2[Publication]: @example-pub-2-theorem

    Referencing a theorem in the attached @tauthesis-publication-anchor-3[Publication]: @example-pub-3-theorem
]
