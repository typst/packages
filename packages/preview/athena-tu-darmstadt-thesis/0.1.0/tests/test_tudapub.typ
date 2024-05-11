// imports
#import "@preview/cetz:0.1.2": canvas, plot
#import "@preview/glossarium:0.2.5": make-glossary, print-glossary, gls, glspl 
#import "@preview/mitex:0.2.3": *
#import "@preview/drafting:0.1.2": *
#show: make-glossary


#import "../templates/tudapub/tudapub.typ": tudapub
#import "../templates/tudapub/tudacolors.typ": tuda_colors
#import "../templates/tudapub/common/props.typ": *


// setup
// #set page(width: 20cm, height:auto)
// #set heading(numbering: "1.")
// #set par(justify: true)


#show: tudapub.with(
  title: [
    TUDaThesis - Title With a second line
  ],
  author: "Albert Author",
  accentcolor: "9c",
  language: "eng",


  abstract: [The abstract...],

  margin: tud_page_margin_big,

  bib: bibliography("./latex_ref/DEMO-TUDaBibliography.bib", full: true)//, style: "spie")
)


//#rule-grid(width: 10cm, height: 10cm, spacing: 5mm)

// test content
= Über diese Datei

This is some example text that is not very long, but needs to fill some space. @TUDaGuideline


This starts a new paragraph. Test words. Test words. Test words. Test words. Test words. Test words. Test words. Test words. Test words. Test words. Test words. Test words. Test words. Test words. Test words. Test words. Test words. Test words. Test words.

== Subheading
Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.   

Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.   

Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.   

Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat.   

Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis.   

At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, At accusam aliquyam diam diam dolore dolores duo eirmod eos erat, et nonumy sed tempor et et invidunt justo labore Stet clita ea et gubergren, kasd magna no rebum. sanctus sea sed takimata ut vero voluptua. est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur

== Subheading
Some text
=== Subsubheading
Text with some math $x <= 10$
$
x <= 10
$
More text after eq.

#pagebreak()

== Subheading first on page
Text

== Subheading
Text

=== Subsubheading
Texts
==== SubSubsubheading

#pagebreak()
=== Subsubheading first on page

== Subheading
=== Subsubheading
==== SubSubsubheading
Text

#pagebreak()
#set text(hyphenate: false)
#set text(alternates: true)
Test Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim aeque doleamus animo, cum corpore dolemus

New paragraph...
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim aeque doleamus animo, cum corpore dolemus
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim aeque doleamus animo, cum corpore dolemus
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim aeque doleamus animo, cum corpore dolemus
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim aeque doleamus animo, cum corpore dolemus
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim aeque doleamus animo, cum corpore dolemus


#set text(hyphenate: true)
#lorem(135)



= Test Different Elements
Test some footnotes  #footnote[This is a footnote].
Another footnote #footnote[This is another footnote which has a very long text. This footnote expands over multiple lines causing the footnote region to expand vertically.].
//Bla #footnote[Abc \ D \ E \ F \ G \ D]

=== Figures
Here is @fig_test. Here is more text.
#figure(
  image(height: 60pt, "img/opensource_logo.png"),
  placement: none,
  caption: [This is the figure title.]
) <fig_test>
Even more text that may or may not be before the figure.
Some text after the figure. And another sentence containing no meaning.


#pagebreak()

==== Figures with Tables
Here is @fig_test_table. Here is more text.
#figure(
  table(
    columns: 2,
    [A], [B],
    [1], [2]
  ),
  caption: [This is the figure title.]
) <fig_test_table>
Even more text that may or may not be before the figure.
Some text after the figure. And another sentence containing no meaning.
#figure(
  table(
    columns: 2,
    [AA], [BB],
    [1], [2]
  ),
  caption: [This is the figure title.]
) 


#pagebreak()
=== Test some lists
This is a list:
 + an item
 + another item

=== Subsubheading


#lorem(584)
#pagebreak()
== Spezielle Optionen für Abschlussarbeiten


#pagebreak(weak: true)
Es besteht zusätzlich die Möglichkeit ein anderssprachiges Affidavit als Ergänzung mit
abzudrucken. Um die Struktur und die ggf. notwendige Sprachumschaltung zu erledigen,
existiert hierfür ab Version 2.03 eine Umgebung:


== Lets do some math
Bla _blub_ *bold*.
Math: $x + y (a+b)/2$.


$
"Align:"& \
        & x+y^2    && != 27 sum_(n=0)^N e^(i dot pi dot n) \
        & "s.t. "  && b c
        \
        \
        & mat(
            1,3 ;
            3, 4
          )^T
          && = 
          alpha 
          mat(
            x ,y ;
            x_2, y_2
          )^T
          \
          \
          & underbrace( cal(B) >= B , "This is fancy!")
$
$ 
x &= y^2 + 12  & "(This does A)"
$
$ 
y &= z  & "(This does B)"
$ <eq.last>
In @eq.last we can see cool stuff.

=== Math in Latex Notation
#table(
  columns: 2,
```latex
mitex(`
\begin{pmatrix}
  \dot{r}_x + \omega r_x - \omega p_x \\ 
  \dot{r}_x - \omega r_x + \omega p_x
\end{pmatrix}
=
\begin{pmatrix}
  +\omega \xi_x - \omega p_x \\ 
  -\omega s_x + \omega p_x
\end{pmatrix}
`)
```,
mitex(`
    \begin{pmatrix}
        \dot{r}_x + \omega r_x - \omega p_x \\ 
        \dot{r}_x - \omega r_x + \omega p_x
    \end{pmatrix}
    =
    \begin{pmatrix}
        +\omega \xi_x - \omega p_x \\ 
        -\omega s_x + \omega p_x
    \end{pmatrix}
`)
)

More latex math:
#mitex(`
  \newcommand{\f}[2]{#1f(#2)}
  \f\relax{x} = \int_{-\infty}^\infty
    \f\hat\xi\,e^{2 \pi i \xi x}
    \,d\xi
`)

We can also import basic latex (just a few commands are suppored) via `mitex`:
#mitext(`
  \subsubsection{This is Generated from Latex}

  A \textbf{strong} text, a \emph{emph} text and inline equation $x + y$.
  
  Also block \eqref{eq:pythagoras}.

  \begin{equation}
    a^2 + b^2 = c^2 \label{eq:pythagoras}
  \end{equation}
`)




== Another Section
Some graphics: \
#box(stroke: black, inset: 5mm)[
  test in box
  #circle(width: 2.2cm, inset: 2mm)[
    And in the circle
  ]
]

Some more text here. #lorem(20)
In @fig.myfig we can see stuff.
==== Deep section
#figure(
  [
    #rect(inset: 20.9pt)[Dummy Test]
  ],
  caption: [
    This is a figure
  ]
)<fig.myfig>


Next is @fig:test_f. When using `figure_numbering_per_chapter: true` figures need to referenced with `@fig:<labelname>`
#figure(
  [
    #rect(inset: 20.9pt)[Dummy Test]
  ],
  caption: [
    This is a figure
  ]
)<test_f>


#lorem(100)
===== Level 5 Heading
#lorem(50)

===== Level 5 Heading
#lorem(50)

A term list:
/ A: This is a term. #lorem(20)
/ B: This is a term. #lorem(20)
/ C: This is a term. #lorem(20)


= Next Chapter with Figures

#figure(
  [
    #rect(inset: 20.9pt)[Dummy Test]
  ],
  caption: [
    This is a figure
  ]
)

First eq:
$
x
$

Second eq:
$
y
$

Third eq:
$
y
$