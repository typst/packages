#import "@preview/ultraw:0.0.1": style, uraw
#import "utils.typ": *

#show: format-doc

#source(
  indent-size: 2,
  width: 100%,
  ````typ
  #import "@preview/octique:0.1.1": *
  #uraw(
    markers: ((4, octique("smiley", color: olive)), ((6, 7), [?]), (16, style.badge-marker(color: red))),
    comments: (
      (3, [Correct way to be polite:]),
      (after: 6, content: [That's a strange thing to print in a program...], indent: true, fill: purple.lighten(80%), marker: [!], marker-placement: "markers"),
    ),
    jumps: (from: 7, to: 15, marker: $dots.v$, comment: [More code about the conversation.], separate: gray),
    ```py
    def greeting(name: str, polite: bool):
        if len(name) > 0 and name[0].isupper():
            if polite:
                print("Hello to you, " + name)
            else:
                print("Intense staring <•>_<•>")
            sn = input("What is your surname?")
        else:
            raise RuntimeError("Not a name.")
    ```,
  )
  ````,
)

#place(bottom + right)[
  #import "@preview/octique:0.1.1": *
  #uraw(
    frame-fill: white,
    frame-stroke: black,
    markers: (
      (4, octique("smiley", color: olive)),
      ((6, 7), [?]),
      (16, style.badge-marker(color: red)),
    ),
    comments: (
      (3, [Correct way to be polite:]),
      (
        after: 6,
        content: [That's a strange thing to print in a program...],
        indent: true,
        fill: purple.lighten(80%),
        marker: [!],
        marker-placement: "markers",
      ),
    ),
    jumps: (
      from: 7,
      to: 15,
      marker: $dots.v$,
      comment: [More code about the conversation.],
      separate: gray,
    ),
    ```py
    def greeting(name: str, polite: bool):
        if len(name) > 0 and name[0].isupper():
            if polite:
                print("Hello to you, " + name)
            else:
                print("Intense staring <•>_<•>")
            sn = input("What is your surname?")
        else:
            raise RuntimeError("Not a name.")
    ```,
  )
]
