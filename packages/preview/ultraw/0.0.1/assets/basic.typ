#import "utils.typ": *

#show: format-doc

#grid(
  columns: (1fr, 1fr, 1fr),
  align: bottom + center,

  source(
    width: 100%,
    indent-size: 2,
    ````typ
    #import "@preview/ultraw:0.0.1": *

    #show: uraw

    ```py
    def greeting():
        print("Hello to you!")
    ```
    ````,
  ),

  uraw(
    ```py
    def greeting():
        print("Hello to you!")
    ```,
  ),

  source(
    width: 100%,
    ````typ
    #import "@preview/ultraw:0.0.1": *

    #uraw(
      ```py
      def greeting():
          print("Hello to you!")
      ```,
    )
    ````,
  ),
)
