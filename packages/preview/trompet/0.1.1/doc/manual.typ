#import "@preview/tidy:0.4.3"
#import "@preview/trompet:0.1.0" as trompet: *
#import "@preview/lambdabus:0.1.0" as lmd

#show link: content => underline(content, stroke: blue)
#let hbar = line(end: (100%, 0%))
#let lbar = line(start: (5%, 0%), end: (95%, 0%), stroke: luma(50%))
#let typc(content) = raw(content, lang: "typc")
#let typ(content) = raw(content, lang: "typ")
#set page(numbering: "1")
#let cetz-link(dest, body) = link("https://cetz-package.github.io/docs/" + dest, body)

#align(center, [
  #text([= `trompet`], 24pt)

  A #link("https://typst.app", [Typst]) package for making Tromp lambda diagrams, built on top of #link("https://typst.app/universe/package/lambdabus/", [Lambdabus]) and #link("https://typst.app/universe/package/cetz/", [CeTZ])

  #link("https://github.com/CrowdingFaun624/trompet", `github.com/CrowdingFaun624/trompet`)

  #strong[Version 0.1.0]
])

#v(1in)

#columns(2)[
	#outline(
		title: align(center, box(width: 100%)[Guide]),
		indent: 1em,
		target: selector(heading).before(<toc-functions>, inclusive: false),
	)
	#colbreak()
	#outline(
		title: align(center, box(width: 100%)[Reference]),
		indent: 1em,
		target: selector(heading.where(level: 2)).or(heading.where(level: 3)).after(<toc-functions>, inclusive: true),
	)
]

#pagebreak()
== Tromp Diagram
#hbar

There are three ways to call #typc("tromp") to display a Tromp diagram.

#columns(3)[
  ```typ
  #tromp("\\f.\\n.f (f n)")
  ```

  #colbreak()

  ```typ
  #import "@preview/lambdabus:0.1.0" as lmd

  #tromp(lmd.parse(
    "\\f.\\n.f (f n)"
  ))
  ```

  #colbreak()

  ```typ
  #tromp(expression(
    abstraction("f",
      abstraction("n",
        application(
          "f", "f n"
        )
      )
    )
  ))
  ```
]
All of the above produce the following Tromp diagram (the Church numeral $2$):
#align(center, tromp("\\f.\\n.f (f n)"))

== Styling
#hbar

Tromp diagrams can use the #typc("\"pixel\"") mode or the #typc("\"line\"") mode.

#columns(2, align(center + horizon, [
  #text(typc("\"pixel\""), 14pt)

  #tromp("\\f.\\n.f (f n)", mode: "pixel")
  ```typ
  #tromp("\\f.\\n.f (f n)", mode: "pixel")
  ```

  #colbreak()
  #text(typc("\"line\""), 14pt)

  #tromp("\\f.\\n.f (f n)", mode: "line")
  ```typ
  #tromp("\\f.\\n.f (f n)", mode: "line")
  ```
]))

#lbar

Tromp diagrams can adjust the styling of the fill of the pixels or the stroke of the lines using any #link("https://cetz-package.github.io/docs/basics/styling", [CeTZ style]).

#columns(2, align(center + horizon, [
  #tromp("\\f.\\n.f (f n)", style: red)
  ```typ
  #tromp("\\f.\\n.f (f n)", style: red)
  ```

  #colbreak()
  #tromp("\\f.\\n.f (f n)", mode: "line", style: (paint: blue, dash: "dashed"))
  ```typ
  #tromp(
    "\\f.\\n.f (f n)",
    mode: "line",
    style: (paint: blue, dash: "dashed")
  )
  ```
]))

#pagebreak()

Tromp diagrams can label abstractions.

#columns(2, align(center + horizon, [
  #tromp("λf.(λx.x x) (λx.f (x x))", labels: auto)
  ```typ
  #tromp("λf.(λx.x x) (λx.f (x x))", labels: auto)
  ```

  #colbreak()
  #tromp("λf.(λx.x x) (λx.f (x x))", labels: param => text($italic(param)$, red))
  ```typ
  #tromp(
    "λf.(λx.x x) (λx.f (x x))",
    labels: param => {
      text($italic(param)$, red)
    }
  )
  ```
]))

#lbar
The scale of a Tromp diagram can be adjusted using the scale parameter.
#columns(2)[
  #align(horizon, ```typ
    #tromp(
      "λn.λf.n (λf.λn.n (f (λf.λx.n f (f x)))) (λx.f) (λx.x)",
      scale: 0.5,
    )
    ```)
  #colbreak()
  #align(center + horizon, tromp("λn.λf.n (λf.λn.n (f (λf.λx.n f (f x)))) (λx.f) (λx.x)", scale: 0.5))
]

#hbar
== Expression Functions

Lambda expressions can be expressed using the #typc("expression()"), #typc("value()"), #typc("abstraction()"), and $typc("application()")$ functions instead of strings.

#typc("value()"), #typc("abstraction()"), and #typc("application()") all take a #typc("style") parameter which behaves the same way as above.

#lbar

The #typc("expression()") function returns an expression with additional metadata which allows Lambdabus to process it.

#columns(2)[
  `>>> `#typ("#abstraction(\"a\", value(\"a\"))")

  #abstraction("a", value("a")))

  #colbreak()
  `>>> `#typ("#expression(\n\tabstraction(\"a\", value(\"a\"))\n)")

  #expression(abstraction("a", value("a")))
]

#lbar

The #typc("value()") function takes in a single string for the parameter name, referring to a corresponding abstraction with the same parameter.

The #typc("abstraction()") function takes in a string for the parameter name and a lambda expression representing the body of the abstraction. Additionally, it takes a #typc("label") parameter which can be #typc("auto"), #typc("none"), a function from the parameter name to content, or just content.

The #typc("application()") function takes in a lambda expression for the function and a lambda expression for the parameter of the application.

#pagebreak()
== Functions<toc-functions>
#let docs = tidy.parse-module(read("../src/lib.typ"), scope: (
  trompet: trompet,
  lmd: lmd,
  cetz-link: cetz-link,
  typc: typc,
  typ: typ,
))

#tidy.show-module(docs)
