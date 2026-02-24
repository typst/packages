// Functions

#let callout(body, title: "Callout", fill: blue, title-color: white, body-color: black, icon: none) = {
  block(fill: fill,
	   width: 100%,
	   inset: 8pt)[
	   #text(title-color,size:1.4em)[#icon #title]
     \
	  #text(body-color)[
		  #body
		  ]
	]
}

// Presets

#let note = callout.with(title: "Note",
			fill: rgb(21, 30, 44),
			icon: "✎",
			title-color: rgb(21, 122, 255),
			body-color: white)

#let info = callout.with(title: "Info",
		   fill: rgb(21, 30, 44),
								   icon: "🛈",
								   title-color: rgb(21, 122, 255),
								   body-color: rgb(8, 109, 221))

#let warning = callout.with(title: "Warning",
		   fill: rgb(42, 33, 24),
									  icon: "⚠",
									  title-color: rgb(233, 151, 63),
									  body-color: white)

#let success = callout.with(title: "Success",
		   fill: rgb(25, 39, 29),
									  title-color: rgb(68, 207, 110),
									  icon: "✓",
									  body-color: white)

#let check = success.with(title: "Check")

#let question = callout.with(title: "Question",
		   fill: rgb(41, 41, 29),
									  title-color: rgb(224, 222, 113),
									  icon: "?",
									  body-color: white)

#let fail = callout.with(title: "Failed",
		   fill: rgb(44, 25, 26),
									  title-color: rgb(175, 52, 56),
									  icon: "𐄂",
									  body-color: white)

#let example = callout.with(title: "Example",
		   fill: rgb(25, 79, 29),
									  title-color: rgb(68, 217, 110),
									  icon: "🕮",
									  body-color: white)

#let examples = example.with(title: "Examples")

#let quote = callout.with(title: "Quote",
		   fill: rgb(34, 34, 34),
									  title-color: rgb(158, 158, 158),
									  icon: "❞",
									  body-color: white)
