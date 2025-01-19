#import "outline.typ": *
#import "applyStyle.typ": *
#import "header-footer.typ": *
#import "front-pages.typ": *
#import "../Tools/shortcuts.typ": *
#import "codeDisplay.typ": *
#import "../Tools/formatting.typ": *


= Documents

/*
Style :
- Numbered
- Colored
- Plain

*/

#let doc(
	lang: "fr",

  title: ("Titre"),
  authors: (),
  style: "",
  titlePage: false,
  outline: false,
  contenu,
) = context {
  set text(lang: lang, font: "New Computer Modern")

  let (firstRealPage, customOutline) = getOutline()

  show: header-footer.with(firstRealPage, titlePage, outline, customOutline, title, authors)

  show: applyStyle.with(style)

  front-pages(title, titlePage, authors, outline, customOutline)

  show: shows-shortcuts
  show: codeDisplay

  // Pre-set

  set table(
    inset: 10pt,
    stroke: 0.5pt,
    align: center + horizon,
    fill: (x, y) => if (x == 0) or (y == 0) { gray.lighten(75%) },
  )

  set grid(column-gutter: 10pt, align: horizon)

  set image(width: 40%)

  show image: it => {
    align(center, it)
  }


  // Contenu
  set text(10pt)
  set par(justify: true)

  [= audhzifoduiygzbcjlxmwmwpadpozieuhgb]

  counter(heading).update(0)

	// Preview quand le document est vide
	if contenu == parbreak() {
		[
			= Titre
			#lorem(20)
			== Sous titre
			#lorem(100)
			#inbox[#lorem(20)]
			#lorem(50)
			== Sous titre
			#lorem(50)
			#inbox2[#lorem(20)]
			#lorem(50)
			=== Sous sous titre
			#lorem(50)
			#para("Remarque")[#lorem(30)]
		]
	}
  contenu
}

