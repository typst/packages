# `muw-community-templates`
## Medical University of Vienna

This repository hosts community maintained unofficial templates for the Medical University of Vienna. Currently, it includes a presentation template built on the [`polylux`](https://typst.app/universe/package/polylux/) beamer style engine for Typst.

## Contents

* **`colors.typ`**: Defines the official color scheme according to the university corporate design.
* **`presentation.typ`**: Main presentation template implementing the university branding and layout guidelines.

## Features

* **Colors**. All corporate colors are defined in `colors.typ`.
* **Logos**. White and blue SVG versions of the university logo are included for footer rendering, adapting to background color.
* **Slides**  
  * `slide`: Base slide that calls `polylux.slide`.  
  * `color-slide`: Custom background and font colors.  
  * `black-slide`: Black background with white font (for x-ray, ct, etc.).  
  * `blue-slide`: Dark blue background with white text (titlepage).  
* **Footer**  
  * Left: MedUni Wien logo with adaptive color.  
  * Center: Presentation title and organisational unit.  
  * Right: Page number, optionally formatted as a percentage, and the date if required.  
* **Layout**  
  * Rounded corner boxes via `muw-box`.  
  * Customisable `slides(...)` block with metadata, including `title`, `series`, `orga`, `author`, `klinik`, and `email`.  
  * Optional table of contents and user defined page numbering function.  

## Example Usage

```typst
#import "@preview/muw-community-templates:0.1.1" as muw_presentation
#import muw_presentation: *

#set text(lang: "de")

#polylux.enable-handout-mode(false)

#let muw-logo-white(..args) = muw-box(fill: gray, figure(box([Hello], ..args)))
#let muw-logo-blue(..args) = muw-box(fill: gray, figure(box([Hallo], ..args)))
#let custom-muw-logos = (muw-logo-white, muw-logo-blue)

#show: slides.with(
  title: [Titel mit blauem Hintergrund],
  series: [Titel der Präsentation ODER des Vortragenden],
  klinik: [Universitätsklinik für XY],
  orga: [Organisationseinheit],
  author: [Univ. Prof. Dr. Maximilian Mustermann],
  email: none,  // link("mailto:n12345678@students.meduniwien.ac.at"),
  paper: "presentation-16-9",  // 4-3
  toc: false,
  show-date: true,
  logos: none,  // custom-muw-logos,
  page-numbering: (i, j) => { [ #strong[#i] / #j ] },
)


// Use #slide to create a slide and style it using your favourite Typst functions
#slide[
  #set align(horizon)
  = Very minimalist slides

  #lorem(10)

  #muw-box(
    height: 25mm,
    fill: muw_colors.dunkelblau,
    text(fill: white)[
      ~ Hier ist eine MedUni Wien box ... ~ \
      ~ Hier könnte auch ein bild sein ... ~
    ]
  )

]

// your slides go here
```

> **WARNING**:
>
> As the correct fonts are not freely available, they are not supported in this template.
>
> Locally, Typst uses your installed system fonts or embedded fonts in the CLI, which are Libertinus Serif, New Computer Modern,
> New Computer Modern Math, and DejaVu Sans Mono. In addition, you can use the `--font-path` argument or `TYPST_FONT_PATHS` environment
> variable to add directories that should be scanned for fonts. The priority is: `--font-paths` > system fonts > embedded fonts.
> Run typst fonts to see the fonts that Typst has discovered on your system. Note that you can pass the `--ignore-system-fonts` parameter
> to the CLI to ensure Typst won't search for system fonts.
>
> see: https://typst.app/docs/reference/text/text/
>
>
> - Primärschrift: Danton
> - Systemschrift: Georgia
> - Sekundärschrift: Akkurat Pro
> - Systemschrift: Lucida Sans
>



refs:
- https://www.meduniwien.ac.at/web/studierende/service-center/meduni-wien-vorlagen/
- https://typst.app/
- https://github.com/typst/packages/tree/main/packages/preview/
- https://github.com/typst/packages/blob/main/docs/manifest.md

