#import "@preview/cvut-thesis:0.1.0": fel-thesis

#show: fel-thesis.with(
  title: "Velmi zajímavá studie",
  subtitle: "Bakalářská práce",
  author: "Jan Novák",
  details: (
    "Vedoucí": "Prof. Jiří Dvořák",
    "Školitel-specialista": "František Vomáčka, Ph.D.",
    "Studijní program": "Enterprise architektury",
  ),
  date: "Květen 2026",
  abstract-cz: [
    #lorem(55)
  ],
  abstract-en: [
    #lorem(40)
  ],
  keywords-cz: ("pes", "a", "kočička"),
  keywords-en: ("dog", "and", "cat"),
  branch: "Obor Softwarové inženýrství a technologie",
  logo: image("assets/cvut-logo.svg"),
)

// Layout/style overwrites possible here...
// Example: #set text(20pt)

// Typst documentation: https://typst.app/docs

// ----------------------- The actual content -------------------------

= První kapitola
#lorem(30)

#figure(
  image("assets/cvut-logo.svg"),
  caption: "Zajímavý obrázek",
)

#quote[We've all got both light and dark inside us. What matters is the part we choose to act on. That's who we really are.] @harry

Tady jsem něco naprogramoval:
```go
package main

func main()  {
	println("Hello world!")
}
```

A tady jsem počítal kořeny kvadratické rovnice:
$ x_{1,2} = (-b plus.minus sqrt(b^2 - 4a c)) / (2a) $


// --------------------------------------------------------------------

#bibliography("references.yaml", style: "assets/iso690-numeric-brackets-cs.csl")
