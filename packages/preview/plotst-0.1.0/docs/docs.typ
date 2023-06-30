#import "template.typ": *
#import "typst-doc.typ": parse-module, show-module
#show link: underline


// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  title: "Typst-plotting",
  subtitle: "Auto generated documentation",
  authors: (
    "Pegacraffft",
    "Gewi"
  ),
  // Insert your abstract after the colon, wrapped in brackets.
  // Example: `abstract: [This is my abstract...]`
  abstract: [
    *Typst-plotting* is a plotting library for #link("https://typst.app/", [Typst]).\
    It supports drawing the following plots/graphs in a variety of styles.
    - Scatter plots
    - Line charts
    - Histograms
    - Bar charts
    - Pie charts
    - Overlaying plots/charts
    More features will be added over time. If you have some feedback, let us know!
  ],
  date: "17.6.2023",
)

// We can apply global styling here to affect the looks
// of the documentation. 
#set text(font: "Fira Sans")
#show heading.where(level: 1): it => {
  align(center, it)
}
#show heading: set text(size: 1.5em)
#show heading.where(level: 3): it => text(size: 1em, style: "italic", block(it.body))


#{
  let options = (allow-breaking: false)
  let modules = (
     "Axes": "/typst-plotting/axis.typ",
     "Plots": "/typst-plotting/plotting.typ",
     "Classification": "/typst-plotting/util/classify.typ",
  )
  set heading(numbering: "1.1.")
  outline(indent: auto, depth: 2)
  align(center)[Docs were created with #link("https://github.com/Mc-Zen/typst-doc")[typst-doc]]
  pagebreak()
  for (name, path) in modules {
    let module = parse-module(path, name:name , )
    show-module(module, first-heading-level: 1, allow-breaking: false)
  }
}