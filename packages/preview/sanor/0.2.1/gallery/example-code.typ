#import "@preview/sanor:0.2.1": *

// Set up presentation format.
#set page(paper: "presentation-16-9", fill: luma(20))
#set text(size: 25pt, fill: white)

#slide(s => (
  [
    #import "@preview/zebraw:0.6.3": zebraw
    #let tag = tag.with(s)
    #let zebraw = zebraw.with(
      background-color: luma(30),
      lang: false,
      highlight-color: white.transparentize(90%),
      comment-color: white.transparentize(90%),
      comment-font-args: (font: "Libertinus serif"),
    )
    = Code Example
    Integration with `zebraw`.
    #set align(horizon)

    #show: zebraw

    #tag("snippet")[```typst
    #slide(s => ([
      #let tag = tag.with(s)
      // Your Content Goes Here
    ],s))
    ```]

    #s.push(apply("snippet"))
    #s.push(apply("snippet", it => {
      zebraw(it, highlight-lines: (
        "2": [
          Don't forget this line!
        ],
      ))
    }))

  ],
  s,
))