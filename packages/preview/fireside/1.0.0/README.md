# fireside

A Typst theme for a nice and simple looking letter that's not completely black and white. Inspired by a Canva theme.

Features:
  * A neutral-warm beige background that feels cosier and softer to the eyes than pure white, while still looking kinda white-ish
  * Short content is vertically padded to look a bit more centered
  * Long content overflows gracefully on as many pages as necessary

# Demo

| Basic example                                            | Short text (vertically centered)                       | Multi-page overflowing text                          |
|----------------------------------------------------------|--------------------------------------------------------|------------------------------------------------------|
| [`.rendered/demo_medium.pdf`](.rendered/demo_medium.pdf) | [`.rendered/demo_short.pdf`](.rendered/demo_short.pdf) | [`.rendered/demo_long.pdf`](.rendered/demo_long.pdf) |

# Usage

  * If using Typst locally, install the [HK Grotesk](https://fonts.google.com/specimen/Hanken+Grotesk) font
      * _Note: it is already installed on the https://typst.app/ IDE_
  * Insert the setup `show` statement
    ```typst
    #import "@preview/fireside:1.0.0": *

    #show: project.with(
      title: [Anakin \ Skywalker],
      from-details: [
        Appt. x, \
        Mos Espa, \
        Tatooine \
        anakin\@example.com \ +999 xxxx xxx
      ],
      to-details: [
        Sheev Palpatine \
        500 Republica, \
        Ambassadorial Sector, Senate District, \
        Galactic City, \ Coruscant
      ],
    )

    Dear Emperor, ...
    ```
  * If your text overflows on multiple pages, you might want to add [page numbering](https://typst.app/docs/reference/layout/page/#parameters-numbering), as shown in [`.demo/demo_long.typ`](.demo/demo_long.typ) (line 3)

# Parameters

```typst
  background: rgb("f4f1eb"), # Override the background color
  title: "",                 # Set the top-left title. It looks best on two lines
  from-details: none,        # Letter sender (you) details
  to-details: none,          # Letter receiver details
  margin: 2.1cm,             # Page margin
  vertical-center-level: 2,  # When the content is small, it is vertically centered a bit, but still kept closer to the top. This controls how much. Setting to none will disable centering.
  body
```

# License

  * `lib.typ` is licensed as MIT (https://opensource.org/license/mit)
  * The demo/template files are licensed as CC0 (https://creativecommons.org/publicdomain/zero/1.0/legalcode)
  * Any document fully or partially generated using this template may be licensed however you wish
