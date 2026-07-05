/*
  File: example.typ
  Author: neuralpain
  Date Modified: 2025-01-06

  Description: A sample document for users to
  familiarize themselves with Pigmentpedia.
*/

#import "@preview/pigmentpedia:0.3.0": *

#set page(background: rotate(-45deg, text(11em, fill: luma(97%))[EXAMPLE]))
#show heading: it => [#v(5mm) #it #v(2mm)]
#set par(justify: true)

/*
  FINDING PIGMENTS BEFORE WRITING THE DOCUMENT
*/

// Uncomment to view China Traditional Grey-White colors
// #view-pigments(Zhongguo.en.Grey-White)

// Uncomment to search within Crayola for a "burnt" color
// #find-pigment("burnt", scope: Crayola)

/*
  VISUAL ELEMENTS
*/

#let cs-o = 100mm; #let cs-g = 200mm; #let cs-b-l = 100mm; #let cs-b-s = 30mm;
#place(dx: -80mm, dy: 40mm, circle(width: cs-o, height: cs-o, fill: Zhongguo.en.Grey-White.Fish-Maw-White))
#place(dx: 130mm, dy: -100mm, circle(width: cs-g, height: cs-g, fill: Zhongguo.en.Grey-White.White-Tea))
#place(dx: 50mm, dy: 180mm, circle(width: cs-b-l, height: cs-b-l, fill: Zhongguo.en.Grey-White.Snow-White))
#place(dx: 120mm, dy: 260mm, circle(width: cs-b-s, height: cs-b-s, fill: Zhongguo.en.Grey-White.Crystal-White))

/*
  THE DOCUMENT
*/
= #text(Crayola.Standard.Maximum-Red, 2em)[A Journey Through Hope]

== #pigment(Crayola.Standard.Burnt-Orange)[A Healthy Diet Starts With You]

#pigment(Crayola.Standard.Orange, lorem(10)) \ \
#pigment(Crayola.Standard.Orange, lorem(90)) \ \
#pigment(Crayola.Standard.Orange, lorem(40))

== #pigment(Crayola.Standard.Maximum-Blue)[Enough Sleep For A Lifetime]

#pigment(Crayola.Standard.Cerulean-Blue)[
  #lorem(25) \ \
  #lorem(85)
]

== #pigment(Crayola.Standard.Maximum-Green)[No Better Time Than The Present]

#pigment(Crayola.Standard.Asparagus, lorem(35))

#align(bottom)[
  #line(length: 100%, stroke: 0.2pt + grey)
  #emph(
    pigment(Pantone.C.Gray.Cool-Gray-11)[
      This is a sample document showcasing the use of Pigmentpedia in text application. The pigments in Pigmentpedia are not solely for text; they can be used anywhere you need a more diverse range of color in your documentation.

      Это образец документа, демонстрирующий использование Pigmentpedia в текстовом приложении. Пигменты в Pigmentpedia предназначены не только для текста; их можно использовать везде, где вам нужен более разнообразный диапазон цветов в вашей документации.

      这是一个示例文档，展示了在文本应用程序中使用Pigmentpedia。Pigmentpedia中的颜料不仅仅用于文本；它们可以用在文档中需要更多样化颜色的任何地方。
    ],
  )
]

/*
  PREVIEW COLORS YOU MAY WANT TO CHANGE
*/

// Uncomment to find a nice green color
// the spaces ` ` are converted to hyphens `-` for search
// #find-pigment("70 G20Y") // search within all of pigmentpedia
// this space here ^^^ --> becomes "70-G20Y"

// Uncomment to view a nice green color
// #view-pigments(NCS.S-1070-G20Y)
