
#import "../preamble.typ": *

= Tests related to cross-referencing

This attachment is here just to make sure that
cross-references work as intended. Towards this end,
@tau-logo-b is here just to make testing within the same
chapter possible.

#figure(
    image(
        "../images/tau-logo-fin-eng.svg",
        width: 80%
    ),
    caption: [Tampere University logo. @tau-logo-image],
) <tau-logo-b>

Also, here is an equation for similar purposes:
$
  matrix(L)
  vector(x)
  approx
  vector(y)
  thin .

$ <test-equation-1>

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
