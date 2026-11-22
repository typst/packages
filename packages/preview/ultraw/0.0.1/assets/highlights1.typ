#import "../export/main.typ": *
#import "utils.typ": *

#show: format-doc

#grid(
  columns: (1fr, auto),
  column-gutter: 5mm,
  align: bottom,

  [
    #highlights.remove((ldel: "*:", rdel: ":*"), (ldel: "*!", rdel: "!*"))
    #source(
      width: 100%,
      indent-size: 2,
      ````typ
      The guard conditions are highlighted in yellow \
      and the raised error is highlighted in red.

      ```py
      def greeting(name: str):
          if *:len(name) > 0:* and *:name[0].isupper():*:
              print("Hello to you, " + name)
          else:
              raise *!RuntimeError!*("Not a name.")
      ```
      ````,
    )
    #highlights.add(highlights.base, highlights.alert())
  ],

  [
    #show: uraw

    The guard conditions are highlighted in yellow \
    and the raised error is highlighted in red.

    ```py
    def greeting(name: str):
        if *:len(name) > 0:* and *:name[0].isupper():*:
            print("Hello to you, " + name)
        else:
            raise *!RuntimeError!*("Not a name.")
    ```
  ],
)
