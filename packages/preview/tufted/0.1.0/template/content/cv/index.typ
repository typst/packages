#import "../index.typ": template, tufted
#show: template
#import "@preview/citegeist:0.2.0": load-bibliography

= Edward R. Tufte

#tufted.margin-note[
  Statistician, Artist, and Professor Emeritus \
  Website: #link("https://www.edwardtufte.com")[edwardtufte.com] \
  Email: #link("mailto:noreply@edwardtufte.com")[`noreply@edwardtufte.com`]
]

Research in statistical evidence and analytical design for information visualization, integrating principles from statistics, graphic design, and cognitive science for the effective presentation of quantitative data.


== Experience
- *1983--Present*: Founder & Publisher, Graphics Press. Independent publishing house specializing in information design and data visualization.
- *1977--1999*: Professor Emeritus, Yale University. Departments of Political Science, Statistics, and Computer Science.
- *1967--1977*: Instructor, Princeton University. Woodrow Wilson School of Public and International Affairs.

== Artworks

#tufted.margin-note[
  #image("escaping-flatland.webp")
]

#tufted.margin-note[
  A homage to Edward R. Tufte's large stainless steel sculpture titled _Escaping Flatland_
]

Founder of Hogpen Hill Farms, a 234-acre sculpture park in Woodbury, Connecticut. Creator of large-scale works including _Larkin’s Twig_ and the _Escaping Flatland_ series, exhibited at the Aldrich Contemporary Art Museum.

== Research Contributions
Development of sparklines, a method for embedding high-resolution data graphics within text, and formulation of the data-ink ratio as a quantitative measure of graphical efficiency.

== Books
#{
  let bib = load-bibliography(read("books.bib"))
  for item in bib.values().rev() [
    #let data = item.fields
    - #strong(data.year): #emph(data.title)
  ]
}

== Papers
#{
  let bib = load-bibliography(read("papers.bib"))
  for item in bib.values().rev() [
    #let data = item.fields
    - #data.author, "#data.title," #emph(data.journal), #data.year. DOI: #link(data.url)[#data.doi]
  ]
}


== Education
- PhD in Political Science: Yale University (1968).
- MS in Statistics: Stanford University.
- BS in Statistics: Stanford University.
