#import "@preview/craken-slides:0.1.0": *

#show: craken-slides.with(
  title: [Your talk title],
  subtitle: [One sentence that tells people why they should stay.],
  author: "Your Name",
  date: [Month year],
  event: [Where you're giving it],
  // short-title: [Shorter title for the footer],
  // logo: image("logo.png"),
  theme: sys.inputs.at("theme", default: "paper"),
)

#title-slide()
#outline-slide()

#section-slide([First part], lede: [What this part is about, in one line.])

#slide(title: [A first slide])[
  Start with a tiny concrete case, then the general rule.
]

#closing-slide[Questions are very welcome.]
