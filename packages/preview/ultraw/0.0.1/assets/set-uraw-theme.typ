#import "../export/main.typ": *
#import "utils.typ": *

#show: format-doc

#grid(
  columns: (1fr, auto),
  column-gutter: 5mm,
  align: bottom,

  source(
    width: 100%,
    indent-size: 2,
    ````typ
    #set-uraw(..themes.dark)

    ```py
    def greeting():
        print("Hello to you!")
    ```
    ````,
  ),

  [
    #show: uraw
    #set-uraw(..themes.dark)

    ```py
    def greeting():
        print("Hello to you!")
    ```
  ],
)
