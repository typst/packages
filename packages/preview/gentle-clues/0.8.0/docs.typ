// #import "@local/gentle-clues:0.7.0": *
#import "lib/lib.typ": *
// #import "@local/svg-emoji:0.1.0": *

#set page(margin: 2cm);

// #show: setup-emoji

#show: gentle-clues.with(
  headless: false,
  breakable: false,
  // header-inset: 0.4em,
  // content-inset: 1.3em,
  // border-radius: 12pt,
  // border-width: 1pt,
  // stroke-width: 5pt,
)

#set text(font: "Rubik", weight: 300, lang: "en")

= Gentle clues for typst

Add some beautiful, predefined admonitions or define your own.

#clue(title: "Getting Started")[
  A minimal starting example
  ```typ
  #import "@preview/gentle-clues:0.8.0": *

  #tip[Check out this cool package]
  ```
  #tip[Check out this cool package]
]

#clue(title: "Usage")[
  + Import the package like this:
    ```typ
    #import "@preview/gentle-clues:0.8.0": *
    ```

  + Change the default settings for a clue.
    ```typ
    #show: gentle-clues.with(
      headless: false,  // never show any headers
      breakable: false, // default breaking behavior
      header-inset: 0.5em, // default header-inset
      content-inset: 1em, // default content-inset
      stroke-width: 2pt, // default left stroke-width
      border-radius: 2pt, // default border-radius
      border-width: 0.5pt,  // default boarder-width 
    )
    ```
  + 
    #grid(columns: 2, gutter: 1em)[
      Use a predefined clue without any options
      ```typ
      #info[You will find a list with all predefined clues at the last page.]
      ```
      #align(end)[_Turns into this_ #sym.arrow]
      
    ][
      #set align(bottom)
      #info[You will find a list with all predefined clues at the last page.]
    ]
  + #grid(columns: 2, gutter: 1em)[
      Or add some options like a custom title
      ```typ
      #example(title: "Custom title")[ Content ...]
      ```
      #align(end)[_Turns into this_ #sym.arrow]
    ][
      #set align(bottom)
      #example(title: "Custom title")[ Content ...]
    ]

  + *I18n:*
    - The current language which is set by `#set text(lang: "de")` changes the default header title. 
    - Currently supported are `en`, `de`, `fr` and `es`. This package uses linguify for language settings. Feel free to contribute more languages.
  
]




#clue(title: "All Options for a clue")[ 
  All default settings can also be applied to a single clue through passing it as an named argument. Here is a list of accepted arguments:
  ```typ
  title: auto, // [string] or [none] (none will print headless)
  icon: emoji.magnify.l, // [file] or [symbol]
  accent-color: navy, // left accent color [color] or [gradient]
  width: auto, // total width [length]
  radius: auto, // radius of the right border [length]
  border-width: auto, // width of the right and down border [length]
  content-inset: auto, // [length]
  header-inset: auto, // [length]
  breakable: auto, // if clue can break onto next page [bool]
  ```
]

#box(
  height: 4.5cm, 
  stroke: gray.lighten(40%),
  radius: 2pt,
  inset: 2mm, 
  columns(2)[
    #example(title: "Breaking news", breakable: true)[
      Clues can now break onto the next page with option: `breakable: true`

      #lorem(30)
    ]
    This is a two columns layout.
])


#clue(title: "Define your own clue")[
  ```typst
  // Define a clue called ghost
  #let ghost(title: "Buuuuuuh", icon: emoji.ghost , ..args) = clue(
    accent-color: purple, // Define a base color
    title: title,   // Define the default title
    icon: icon,     // Define the default icon
    ..args          // Pass along all other arguments
  )
  // Use it
  #ghost[Huuuuuuh.]
  ```
  The result looks like this.
  #let ghost(
    title: "Buuuuuuh.", 
    accent-color: purple,
    icon: emoji.ghost , 
    ..args
  ) = clue(title: title, icon: icon, ..args)
  #ghost[Huuuuuuh.]
  #set text(9pt)
  #tip[Use the `svg-emoji` package until emoji support is fully supported in typst ]
]



#pagebreak()
== List of all predefined clues <predefined>

#columns(2)[
`#abstract`
#abstract[Make it short. This is all you need.]

`#question`
#question[How do amonishments work?]

`#info`
#info[It's as easy as 
```typst 
  #info[Whatever you want to say]
  ```
]

`#example`,
#example[Testing ...]

`#task`
#task[
  #box(width: 0.8em, height: 0.8em, stroke: 0.5pt + black, radius: 2pt) Check out this wonderful typst package!
]

`#error`
#error[Something did not work here.]

`#warning`
#warning[Still a work in progress.]

`#success`
#success[All tests passed. It's worth a try.]

`#tip`
#tip[Try it yourself]

`#conclusion`
#conclusion[This package makes it easy to add some beatufillness to your documents]

`#memo`
#memo[Leave a #emoji.star on github.]

`#quote`
#quote(attribution: "The maintainer")[Keep it simple. Admonish your life.]

=== Headless Variant

just add `title: none` to any example

#info(title:none)[Just a short information.]

] // columns end

