#import "/lib/colors.typ": color
#import "/lib/utils/make-hero.typ": make-hero

// Theme
#let ucpc(
  content,
  title: none,
  date: none,
  authors: (),
  paper: "presentation-16-9",
  hero: none,
  margin: (
    top: 2em, 
    bottom: 3em,
    left: 2.5em,
    right: 2.5em
  ),
  pallete: (
    primary: color.bluegray.at(2),
    secondary: white,
  )
) = {
  // Setup (Before Hero)
  set document(
    title: title,
    author: authors
  )
  set text(
    font: ("Gothic A1", "Pretendard", "Noto Sans CJK KR", "Noto Sans KR", "Noto Sans")
  )
  set page(
    margin: 0%,
    paper: paper
  )

  // Hero Page
  if hero != none [
    #hero
  ] else [
    #make-hero(
      title: title,
      authors: authors,
    )
  ]

  // Setup (After Hero)
  set page(
    margin: (
      top: margin.top,
      bottom: margin.bottom,
      left: margin.left,
      right: margin.right,
    ),
    footer: text(size: 10pt)[
      #columns(2)[
        #align(left)[#title]
        #colbreak()
        #align(right)[#counter(page).display("1")]
      ]
    ]
  )

  content
}
