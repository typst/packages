/*
  File: pigment-playground.typ
  Author: neuralpain
  Date Modified: 2025-01-13

  Description: A sample document to test pigments.
*/

#import "private.typ": pgmt-icon, pgmt-logo, pgmt-icon-svg, pgmt-logo-svg
#import "pigments.typ": pigment
#import "text-contrast.typ": get-contrast-color

/// Test out pigments with a sample document.
///
/// - bg (color): Background color of the page.
/// - default-text-color (color): Apply one color to all text.
/// - title (color): Color of the title text.
/// - section-1 (color): Color of the first section of text.
/// - section-1-heading (color): Color of the header of the first section of text.
/// - section-1-text (color): Color of the text in the first section.
/// - section-2 (color): Color of the second section of text.
/// - section-2-heading (color): Color of the header of the second section of text.
/// - section-2-text (color): Color of the text in the second section.
/// - section-3 (color): Color of the third section of text.
/// - section-3-heading (color): Color of the header of the third section of text.
/// - section-3-text (color): Color of the text in the third section.
/// - footer-text (color): Color of the footer text.
/// -> content
#let pigment-playground(
  bg: auto,
  default-text-color: none,
  title: none,
  section-1: none,
  section-1-heading: none,
  section-1-text: none,
  section-2: none,
  section-2-heading: none,
  section-2-text: none,
  section-3: none,
  section-3-heading: none,
  section-3-text: none,
  footer-text: none,
) = [
  #if bg == auto and default-text-color != none {
    bg = get-contrast-color(default-text-color)
  } else if bg == auto {
    bg = white
  }

  #if section-1 != none {
    section-1-heading = section-1
    section-1-text = section-1
  }

  #if section-2 != none {
    section-2-heading = section-2
    section-2-text = section-2
  }

  #if section-3 != none {
    section-3-heading = section-3
    section-3-text = section-3
  }

  #if default-text-color != none {
    if title == none { title = default-text-color }
    if section-1-heading == none { section-1-heading = default-text-color }
    if section-1-text == none { section-1-text = default-text-color }
    if section-2-heading == none { section-2-heading = default-text-color }
    if section-2-text == none { section-2-text = default-text-color }
    if section-3-heading == none { section-3-heading = default-text-color }
    if section-3-text == none { section-3-text = default-text-color }
    if footer-text == none { footer-text = default-text-color }
  }

  #if title == none { title = get-contrast-color(bg) }
  #if section-1-heading == none { section-1-heading = get-contrast-color(bg) }
  #if section-1-text == none { section-1-text = get-contrast-color(bg) }
  #if section-2-heading == none { section-2-heading = get-contrast-color(bg) }
  #if section-2-text == none { section-2-text = get-contrast-color(bg) }
  #if section-3-heading == none { section-3-heading = get-contrast-color(bg) }
  #if section-3-text == none { section-3-text = get-contrast-color(bg) }
  #if footer-text == none { footer-text = get-contrast-color(bg) }

  #set page(
    fill: bg,
    header: place(right, dx: 15mm, dy: 10mm)[
      #let svg-h = 10mm
      #if bg == white {
        image(pgmt-icon-svg, height: svg-h)
      } else {
        image.decode(pgmt-icon(get-contrast-color(bg)), height: svg-h)
      }
    ],
  )

  #show heading: it => [#v(5mm) #it #v(2mm)]
  #set par(justify: true)

  = #text(title, 2em)[A Journey Through Hope]

  == #pigment(section-1-heading)[A Healthy Diet Starts With You]

  #pigment(section-1-text)[
    #lorem(10) \ \
    #lorem(90) \ \
    #lorem(40)
  ]

  == #pigment(section-2-heading)[Enough Sleep For A Lifetime]

  #pigment(section-2-text)[
    #lorem(25) \ \
    #lorem(85)
  ]

  == #pigment(section-3-heading)[No Better Time Than The Present]

  #pigment(section-3-text, lorem(35))

  #align(bottom)[
    #line(length: 100%, stroke: 0.2pt + get-contrast-color(bg))
    #emph(
      pigment(footer-text)[
        This is a sample document showcasing the use of Pigmentpedia in text application. The pigments in Pigmentpedia are not solely for text; they can be used anywhere you need a more diverse range of color in your documentation.

        Это образец документа, демонстрирующий использование Pigmentpedia в текстовом приложении. Пигменты в Pigmentpedia предназначены не только для текста; их можно использовать везде, где вам нужен более разнообразный диапазон цветов в вашей документации.

        这是一个示例文档，展示了在文本应用程序中使用Pigmentpedia。Pigmentpedia中的颜料不仅仅用于文本；它们可以用在文档中需要更多样化颜色的任何地方。
      ],
    )
  ]
]
