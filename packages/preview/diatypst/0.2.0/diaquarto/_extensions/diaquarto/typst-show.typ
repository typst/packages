// Typst custom formats typically consist of a 'typst-template.typ' (which is
// the source code for a typst template) and a 'typst-show.typ' which calls the
// template's function (forwarding Pandoc metadata values as required)
//
// This is an example 'typst-show.typ' file (based on the default template  
// that ships with Quarto). It calls the typst function named 'article' which 
// is defined in the 'typst-template.typ' file. 
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-template.typ' entirely. You can find
// documentation on creating typst templates here and some examples here:
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates

#import "@preview/diatypst:0.1.0": slides

#show: slides.with(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(author)$
  authors: "$author$",
$endif$
$if(layout)$
  layout: "$layout$",
$endif$
$if(ratio)$
  ratio: float($ratio$),
$endif$
$if(title-color)$
  title-color: rgb("#$title-color$"),
$endif$
$if(counter)$
  counter: [$counter$],
$endif$
$if(footer)$
  footer: [$footer$],
$endif$
)