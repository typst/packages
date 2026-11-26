#import "@preview/ultraw:0.0.1": highlights, set-uraw, uraw
#import "utils.typ": *

#show: format-doc

#grid(
  columns: (1fr, auto),
  column-gutter: 5mm,
  align: bottom,

  [
    #source(
      width: 100%,
      indent-size: 2,
      ````typ
      // Set the default highlight parameters:
      #set-uraw(highlight: highlights.box(color: red))
      #uraw(
        highlights: (
          (line: (2, 3), fill: aqua.transparentize(70%), stroke: none),
          (line: 4, ..highlights.underline()),
          (start: 5, end: (5, 26), code-style: strong),
        ),
        ```py
        def greeting(name: str):
            if len(name) > 0 and name[0].isupper():
                print("Hello to you, " + name)
            else:
                raise RuntimeError("Not a name.")
        ```,
      )
      ````,
    )
  ],

  [
    #set-uraw(highlight: highlights.box(color: red))

    #uraw(
      highlights: (
        (line: (2, 3), fill: aqua.transparentize(70%), stroke: none),
        (line: 4, ..highlights.underline()),
        (start: 5, end: (5, 26), code-style: strong),
      ),
      ```py
      def greeting(name: str):
          if len(name) > 0 and name[0].isupper():
              print("Hello to you, " + name)
          else:
              raise RuntimeError("Not a name.")
      ```,
    )
  ],
)
