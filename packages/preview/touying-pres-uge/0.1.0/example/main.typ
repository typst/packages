#import "@preview/touying:0.6.1": *
#import "@preview/pinit:0.2.2": *
#import "@preview/codly:1.3.0": *

#import "@preview/touying-pres-uge:0.1.0": *
#import "@preview/numbly:0.1.0": numbly

#set text(font: "Inria Sans", weight: "regular", size: 20pt)
#show math.equation: set text(font: "Fira Math")

#let pinit-highlight-equation-from(height: 2em, pos: bottom, fill: rgb(0, 180, 255), highlight-pins, point-pin, body) = {
  pinit-highlight(..highlight-pins, dy: -0.6em, fill: rgb(..fill.components().slice(0, -1), 40))
  pinit-point-from(
    fill: fill, pin-dx: 0em, pin-dy: if pos == bottom { 0.8em } else { -0.6em }, body-dx: 0pt, body-dy: if pos == bottom { -1.7em } else { -1.6em }, offset-dx: 0em, offset-dy: if pos == bottom { 0.8em + height } else { -0.6em - height },
    point-pin,
    rect(
      inset: 0.5em,
      stroke: (bottom: 0.12em + fill),
      {
        set text(fill: fill)
        body
      }
    )
  )
}

#show: codly-init.with()

#show: uge-theme.with(
    aspect-ratio: "16-9",
    footer: self => self.info.institution,
    config-info(
	title: [Université Gustave Eiffel Template],
	subtitle: [A touying template #emoji.rocket],
	authors: (
	    (
		name: "Thibaud Toullier",
		affiliations: (1, 2),
		email: "thibaud.toullier@univ-eiffel.fr"
	    ),
	    (
		name: "Romain Noël",
		affiliations: (1, 2),
		email: "romain.noel@univ-eiffel.fr"
	    ),
	    (
		name: "Mathias Malandain",
		affiliations: (1,),
		email: "mathias.malandain@inria.fr"
	    )
	),
	institutions: (
	    "Université Gustave Eiffel, Inria, COSYS-SII, I4S Team, Bouguenais, France",
	    "Université Gustave Eiffel, Inria, COSYS-SII, I4S Team, Rennes, France"
	),
	affiliation_type: "numbers",
	date: datetime.today(),
	logo: image("../assets/logo_univ_gustave_eiffel_blanc_rvb.svg", height: 1em),
	variant: true
    ),
)


#title-slide()


= Outline <touying:unoutlined><touying:hidden>

#text(size: .8em)[
    #uge-outline(
	title: none, 
	depth: 2, 
	indent: 2em
    )
]


= Touying / Typst basics

== Introduction


*Typst* is a new markup-based typesetting system that allows you to create documents, particularly for #alert("science"),
that can be compared to other tools like

- LaTeX
- Word
- Google Docs

#alert(`Touying`) is a `Typst` package for writing #alert("slides")

#quote(attribution: [John Doe])[
    `Touying` is to `Typst` what `Beamer` is to `LaTeX`.
]

== New section & slides

You can write a new section using `=` and a new slide using `==`, a title using `===` etc.:

```Typst
= New section

== New slide

=== Title

Hello world!
```

You can add `tags` to sections or slides to remove them from the outline `touying:outlined` or to hide them `touying:hidden`

```Typst
= Outline <touying:unoutlined><touying:hidden>
```

== Writing in `Typst`

`Typst` is a Markdown-like syntax

#table(
    columns: (1fr, auto, auto, auto),
    inset: 10pt,
    align: horizon,
    table.header(
	[*Description*], [*Function*], [*Code*], [*Rendering*],
    ),
    [Strong emphasis], [strong], [`*strong*`], [*strong*],
    [Emphasis], [emph], [`_emphasis_`], [_emphasis_],
    [Raw text], [raw], [\`print(1)\`], [`print(1)`],
    [Link], [link], [`https://typst.app/`], [https://typst.app/],
    [Label], [label], [`<intro>`], [<intro>],
    [Reference], [ref], [`@intro`], [],
    [Heading], [heading], [`= Heading`], [= Heading],
    [Bullet list], [list], [`- item`], [- item],
    [Numbered list], [enum], [`+ item`], [+ item],
    [Term list], [terms], [`/ Term: description`], [/ Term: description],
    [Math], [Math], [`$x^2$`], [$x^2$],
    [Line break], [linebreak], [`\\`], [\\],
    [Smart quote], [smartquote], [`'single' or "double"`], ['single' or "double"],
    [Symbol shorthand], [Symbols], [`~`, `---`], [~, ---],
    [Code expression], [Scripting], [`#rect(width: auto, [Hello])`], [#rect(width: auto, [Hello])],
    [Character escape], [Below], [`Tweet at us \#ad`], [Tweet at us \#ad],
    [Comment], [-], [`// line`, `/* block */`], []
)<intro>

Check the full documentation #link("https://typst.app/docs/reference/syntax/")[here], particularly for scripting!

== Images

You can insert images using #link("https://typst.app/docs/reference/visualize/image/")[`#image`] and #link("https://typst.app/docs/reference/model/figure/")[`#figure`]


#grid(
    columns: (1fr, 1fr),
    rows: (auto),
    gutter: 3pt,
    ```Typst
#figure(
    image(
	"../assets/logo_univ_gustave_eiffel_rvb.svg", 
	width: 60%
    ),
    caption: [
	Typst directly supports many file formats, like `.svg`!
    ],
)
```,
    figure(
        image("../assets/logo_univ_gustave_eiffel_rvb.svg", width: 80%),
      caption: [
	Typst directly supports many file formats, like `.svg`!
      ],
    ),

)

== Equations

Typst has its own #link("https://typst.app/docs/reference/math/equation/")[equation] format that simplifies writting maths #emoji.sparkles



#grid(
  columns: (1fr, 1fr),
  rows: (auto),
  row-gutter: 20pt,
  column-gutter: 5pt,
```Typst
Bayes' theorem is stated mathematically as the following equation:
$ P(A|B) = P(B|A)P(A)/P(B) $
```,
[
  Bayes' theorem is stated mathematically as the following equation:
  $ P(A|B) = P(B|A)P(A)/P(B) $
],
```Typst
Let the companion form of single-variable system:
$ cases(
    dot(x)(t) = A x(t) + B u(t),
    y(t) = C x(t) + D u(t)
    ) $
```,
[
Let the companion form of single-variable system:

$ cases(
	dot(x)(t) = A x(t) + B u(t),
	y(t) = C x(t) + D u(t)
) $
],

)


== Documentation

  Do not forget to check the documentation, that is easy to read! Some useful links:

  - `Typst` #link("https://typst.app/docs/reference/")[reference],
  - Documentation for #link("https://typst.app/docs/reference/")[`Touying`],
  - Templates to publish your scientifics #link("https://typst.app/universe/search/?category=paper&kind=templates")[papers]
  - ... and even more modules on Typst #link("https://typst.app/universe/")[universe]!
		  
= Touying Uge Theme

== Highlighting text

#alternatives[
    #grid(
        columns: (1fr, 1fr),
        rows: (auto),
        gutter: 1em,
        [You can use the `#alert` function to #alert("highlight content")],
        ```Typst
You can use the `#alert` function to #alert("highlight content")
        ```,
    )

    `uge-theme` also provide a `#result-box` for highlighting some results.

    #grid(
        columns: (1fr, 1fr),
        gutter: 1em,
        result-box[This is some result I want to highlight],
        ```Typst
    #result-box[This is some result I want to highlight]
        ```

    )
][
    `uge-theme` also provide `#info-box`, `#warning-box`, `#danger-box` and `#uge-box` for more customization.

    #grid(
        columns: (1fr, 1fr),
        rows: (auto),
        gutter: 1em,
        info-box[Some content],
        ```Typst
#info-box[Some content]
        ```,
        warning-box[Some content],
        ```Typst
#warning-box[Some content]
        ```,
        danger-box[Some content],
        ```Typst
#danger-box[Some content]
        ```,
        uge-box(
	    title: "My custom box", 
	    color: blue.lighten(30%), 
	    icon: emoji.projector
	)[
	    Some content
	],
        ```Typst
#uge-box(
    title: "My custom box", 
    color: blue.lighten(30%), 
    icon: emoji.projector
)[
    Some content
]
        ```,
    )
]

== Writing Outline <touying:unoutlined><touying:hidden>

The `uge-theme` provides a predefined outline `uge-outline`.

```Typst
#uge-outline(
    title: none, 
    depth: 1, 
    indent: 2em
)
```

#focus-slide[
  Wake up!

`#focus-slide[Wake up!]`
]

== Column view

You can display some content in a full line,

#grid(
    columns: (1fr, 1fr),
    rows: (auto),
    gutter: 3pt,
    [Or display some content],
    [In two columns],
)


```Typst
== Column view
You can display some content in a full line,
#grid(
    columns: (1fr, 1fr),
    rows: (auto),
    gutter: 3pt,
    [Or display some content],
    [In two columns],
)
```

Check the #link("https://typst.app/docs/reference/layout/grid/")[Typst documentation] #emoji.rocket



== A very long Title is automatically resized to fit its box -- #lorem(15)

=== And it is also the case for content, spanned over the next slide!

#v(1em)

#lorem(300)

= Advanced content

== Simple Animation

#grid(
    columns: (1fr, 1fr),
    rows: (auto),
    gutter: 10pt,
```Typst
We can use `#pause` to #pause display something later.

#meanwhile

Meanwhile, #pause we can also use `#meanwhile` to display other content synchronously.
```,
    [We can use `#pause` to #pause display something later.

     #meanwhile

     Meanwhile, #pause we can also use `#meanwhile` to display other content synchronously.],
)

== Speaker notes

By using #link("https://github.com/Cimbali/pympress")[Pympress], you can get speaker notes!

#grid(
    columns: (1fr, 1fr),
    rows: (auto),
    gutter: 10pt,
```Typst
#speaker-note[
    + This is a speaker note.
    + You won't see it unless you use `config-common(show-notes-on-second-screen: right)` in `#show: uge-theme.with(...)`
]
```,
speaker-note[
  + This is a speaker note.
  + You won't see it unless you use `config-common(show-notes-on-second-screen: right)` in `#show: uge-theme.with(...)`
],
)


== Radiative Transfer Equation (RTE)


We can use the #link("https://github.com/OrangeX4/typst-pinit/")[`pinit`] module to easily annotate any content of our document!

The equation of radiative transfer simply says that as a beam of radiation travels, it loses energy to absorption, gains energy by emission processes, and redistributes energy by scattering. The differential form of the equation for radiative transfer is: 

#v(3.5em)

$
    1/(#pin(1)c#pin(2)) partial/(partial t) I_nu + hat(Omega) dot nabla I_nu + (#pin(3)k_(nu,s)#pin(4) + #pin(5)k_(nu, a)#pin(6)) rho I_nu = j_nu #pin(7)rho#pin(8) + #pin(9)1/(4 pi) k_(nu, s) rho integral_Omega #pin(10)I_nu d(Omega)#pin(11)
$

#pinit-highlight-equation-from((1, 2), (1, 2), height: 2.5em, pos: bottom, fill: rgb("#0097d7"))[
    speed of light
]

#pinit-highlight-equation-from((3, 4), (3, 4), height: 2.5em, pos: top, fill: rgb("#8b4a97"))[
    scattering opacity
]

#pinit-highlight-equation-from((5, 6), (5, 6), height: 2.5em, pos: bottom, fill: rgb("#00936e"))[
    absorption opacity
]

#pinit-highlight-equation-from((7, 8), (7, 8), height: 1em, pos: top, fill: rgb("#ef7d00"))[
    mass density
]

#pinit-highlight-equation-from((9, 11), (10), height: 2.5em, pos: bottom, fill: rgb("#0f273b"))[
    #stack(
	dir: ttb,
	text[radiation scattered],
	v(.2em),
	text[from other directions],
    )
]



#v(2.5em)



#show: appendix

= Appendix <touying:unoutlined><touying:unnumbered>

Please pay attention to the current slide number.

#thanks-slide[Thank you!]
