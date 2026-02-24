#import "../utils/fonts.typ": thesis_font_size, thesis_font

#let graduate-cover(
  info: (:),
  // 其他参数
  stoke-width: 0.5pt,
  row-gutter: 11.5pt
) = {

  context {
    set page(
      margin: (left: 45mm, right: 45mm, top: 50mm, bottom: 50mm),
    )
    // \newgeometry{left=45mm,right=45mm,top=50mm,bottom=50mm,noheadfoot,nomarginpar}
    set grid(
      row-gutter: row-gutter,
      rows: 5pt,
      stroke: (x, y) => (
        bottom: if x == 1 {
          stoke-width
        } else {
          none
        },
      ),
    )
    set align(center)

    block(
      [
        #set text(size: thesis_font_size.llarge)
        #grid(
          columns: (auto),
          align: (center),
          v(1.2cm),
          text(font: thesis_font.times, info.univ-en),
          text(font: thesis_font.minglu, info.univ-zh)
        )
      ],
    )
    v(54pt)

    block(
      // width: 80%,
      [
        #set text(size: thesis_font_size.llarge)
        #grid(
          columns: (auto),
          align: (center),
          text(font: thesis_font.times, info.title-en.first()),
          v(0.05pt),
          text(font: thesis_font.times, info.title-en.last()),
          v(0.1pt),
          text(font: thesis_font.minglu, info.title.first()),
          v(0.1pt),
          text(font: thesis_font.times, info.title.last()),
        )
      ],
    )
    v(36pt)

    block(
      width: 80%,
      [
        #set text(size: thesis_font_size.small)
        #grid(
          columns: (auto),
          align: (center),
          text(font: thesis_font.times, "Submitted to"),
          text(font: thesis_font.times, info.department),
          text(font: thesis_font.minglu, info.department-zh),
          text(font: thesis_font.times, "in Partial Fulfillment of the Requirements"),
          text(font: thesis_font.times, "for the Degree of Doctor of Philosophy"),
          text(font: thesis_font.minglu, "哲學博士學位"),
          if info.isjoint { text(font: thesis_font.times, "awarded by City University of Hong Kong") },
          if info.isjoint { text(font: thesis_font.times, "for successfully completion of the joint programme with") },
          if info.isjoint { text(font: thesis_font.times, info.partnerunvi) },
        )
      ],
    )
    v(3pt)

    block(
      width: 80%,
      [
        #set text(size: thesis_font_size.small)
        #grid(
          columns: (auto),
          align: (center),
          text(font: thesis_font.times, "by"),
        )
      ],
    )

    v(19pt)

    block(
      width: 80%,
      [
        #set text(size: thesis_font_size.small)
        #grid(
          columns: (auto),
          align: (center),
          text(font: thesis_font.times, info.author-en),
          text(font: thesis_font.minglu, info.author),
        )
      ],
    )

    v(19pt)

    block(
      width: 80%,
      [
        #set text(size: thesis_font_size.small)
        #grid(
          columns: (auto),
          align: (center),
          text(font: thesis_font.times, info.submit-date-en),
          text(font: thesis_font.minglu, info.submit-date),
        )
      ],
    )
    v(1.2cm)
  }
}
