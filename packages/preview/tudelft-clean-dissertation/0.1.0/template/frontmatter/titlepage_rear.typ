#import  "/template.typ": fix-later-compact

// configure metadata
#let metadata = toml("../metadata.toml")

// page containing information about the committee, keywords and metadata
This dissertation has been approved by the promotors.

Composition of the doctoral committee:

#table(
  columns: (3fr, 4fr),
  stroke: 0pt,
  gutter: 0pt,
  inset: 3pt,
  [Rector Magnificus], [Chairperson],
  [Prof.dr #lorem(2)],  [Delft University of Technology (promotor)],
  [Prof.dr. #lorem(2)],  [Delft University of Technology (promotor)],
)
Independent Members:
#table(
  columns: (3fr, 4fr),
  stroke: 0pt,
  gutter: 0pt,
  inset: 3pt,
  // add committee members in format [title name], [institution <optional role description>]
  [Prof.dr. #lorem(2)], [Delft University of Technology #text(fill:luma(155))[_(reserve member)_]],
)

// consider adding also the logos of your funding agencies or parties involved in the research
// it would be easiest to combine them in an inkscape file
#image("../assets/tudelft_symbols/tudelft.pdf", width: 30%)
Description on funding #lorem(50)

// other relevant metadata in key-value pairs
#table(
  columns: (auto, 1fr),
  stroke: 0pt,
  gutter: 0pt,
  inset: 3pt,
  [*Keywords*], [#metadata.keywords.join(", ")],
  [*Cover*], [#fix-later-compact()[A description of the cover and how it was made.]],
  [*Printed by*], [#fix-later-compact()[Your printing service; optional]],
  // consult with your supervisors or the library what would be an appropriate licence. 
  [*Licence*], [Creative Commons Attribution 4.0 #h(1fr) #box(image("../assets/cc_symbols/CC_logo.svg"), height:0.9em,
baseline: 10%)#h(2pt)#box(image("../assets/cc_symbols/CC_attr.svg"), height:0.9em,
baseline: 10%)#h(2pt)CC BY 4.0],
  [*ISBN/EAN*], [#metadata.ISBN],
  [*Digital Version*], [The digital pdf version of this dissertation, including embedded files, is available in the #link("https://repository.tudelft.nl/")[TU Delft Repository].],
  [*Data & Source*], [#fix-later-compact()[Link to or describe where the relevant data for this dissertation can be found and optionally where one can find the source typst files]]
)

// AI use declaration statement
#text(fill:luma(155))[
  #lorem(50)
]


#pagebreak()