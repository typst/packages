#import "outline.typ": *
#import "apply-style.typ": *
#import "header-footer.typ": *
#import "front-pages.typ": *
#import "../tools/shortcuts.typ": *
#import "code-display.typ": *
#import "../tools/formatting.typ": *


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
  title-page: false,
  outline: false,
  content,
) = context {
  set text(lang: lang, font: "New Computer Modern")

  let (first-real-page, custom-outline) = get-outline(lang)

  show: header-footer.with(first-real-page, authors)

  show: apply-style.with(style)

  front-pages(title, title-page, authors, outline, custom-outline)

  show: shows-shortcuts
  show: code-display

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


  // content
  set text(10pt)
  set par(justify: true)

  [= audhzifoduiygzbcjlxmwmwpadpozieuhgb]

  counter(heading).update(0)

	// Preview when document is empty
	if content == parbreak() {
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
  content
}

