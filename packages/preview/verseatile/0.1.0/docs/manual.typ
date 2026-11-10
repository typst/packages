#import "@preview/mantys:1.0.2": *
#import "../lib.typ": *

#show: mantys(
  name: "verseatile",
  version: "0.1.0",
  authors: (
    "by Alexander Abt",
  ),
  license: "MIT",
  description: "Easily set poetry.",
  repository: "https://github.com/switchlex/verseatile",
  title: "verseatile",
  abstract: [
    verseatile is a small package for setting poetry with Typst, capable of easily indenting and numbering verses while providing many options for customization. 
  ],
  theme: themes.orly
)

#set text(size: 11pt)

= Setting poems

== Getting Started

To print a poem simply use the @cmd:poem function:

#command("poem", arg("poemtitle"), arg("poembody"), arg("indentpattern"))[
  #argument("poemtitle", types:("content"))[
    The poem's title.
  ]
  #argument("poembody", types:("content"))[
    The poem itself --- The end of a verse must be marked with »#sym.backslash«. The end of a stanza however must not be marked with »#sym.backslash« but with an empty line.
  ]
  #warning-alert[#icons.warning Note that the #arg("poembody") must also start with an empty line for indentation and verse numbers to properly work.]
  #argument("indentpattern", types:("content"))[
    Specification for the indentation of verses --- If no line in the poem is to be specially indented this should be 0. For advanced use of indentpatterns see @using-indentpatterns.
  ]
]

A first example might look like this:

#side-by-side[
```typ
#poem[Hor. carm. I, 26][

Musis amicus tristitiam et metus \
tradam protervis in mare Creticum \
portare ventis, quis sub Arcto \
rex gelidae metuatur orae,

quid Tiridaten terreat, unice \
securus. O quae fontibus integris \
gaudes, apricos necte flores, \
necte meo Lamiae coronam,

][0]
```][
#poem[Hor. carm. I, 26][

Musis amicus tristitiam et metus \
tradam protervis in mare Creticum \
portare ventis, quis sub Arcto \
rex gelidae metuatur orae,

quid Tiridaten terreat, unice \
securus. O quae fontibus integris \
gaudes, apricos necte flores, \
necte meo Lamiae coronam,

][0]
]

=== Styling titles

The styling of poemtitles is configurable via a show rule:

#side-by-side[
  ```typ
  #show <poemtitle>
  ```
][]

The vertical space between the #arg("poemtitle") and the #arg("poembody") is configurable via updating a state variable: 

#variable("v-after-poemtitle", types:("length",), value: 20pt)[
  #side-by-side[
    ```typ
    #v-after-pormtitle.update()
    ```
  ][Default: 20pt]
]

If #arg("poemtitle") is left empty a part of the first verse can be set as an inline poemtitle using the @cmd:inline-poemtitle function:

#command("inline-poemtitle", arg("part-of-verse"))[]

Its styling is also configurable via a show rule:

#side-by-side[
  ```typ
  #show <inline-poemtitle>
  ```
][]

#warning-alert[#icons.warning Note that, if \<poemtitle> is shown to be a heading, inline poemtitles may be shown different but will also appear in the outline (on the same level).]

When using inline poemtitles the first verse will always be printed at the same height that it would have been, if there was a normal (one line) poemtitle.

An example of using an _italicized_ inline poemtitle might look like this:

#side-by-side[
```typ
#show <inline-poemtitle>: set text(
  style: "italic")

#poem[][
  
#inline-poemtitle[Musis amicus]
tristitiam et metus \
tradam protervis in mare Creticum \
portare ventis, quis sub Arcto \
rex gelidae metuatur orae,

quid Tiridaten terreat, unice \
securus. O quae fontibus integris \
gaudes, apricos necte flores, \
necte meo Lamiae coronam,

][0]
```][
#show <inline-poemtitle>: set text(style: "italic")

#poem[][
  
#inline-poemtitle[Musis amicus]
tristitiam et metus \
tradam protervis in mare Creticum \
portare ventis, quis sub Arcto \
rex gelidae metuatur orae,

quid Tiridaten terreat, unice \
securus. O quae fontibus integris \
gaudes, apricos necte flores, \
necte meo Lamiae coronam,

][0]
]

=== Using indentpatterns <using-indentpatterns>

By default all verses are indented in relation to the poemtitle. This base indentation is configureable via updating a state variable: 

#variable("base-indent", types:("length",), value: 1em)[
  #side-by-side[
    ```typ
    #base-indent.update()
    ```
  ][Default: 1em]
]

The #arg("indentpattern") specifies how the verses of the #arg("poembody") for a given poem are to be indented. It consist of a series of numbers demarking the level of indentation and is repeatedly applied. With every level (starting from 0) the verse is incrementally indented by the same space which is configureable via updating a state variable: 

#variable("verse-indent", types:("length",), value: 1em)[
  #side-by-side[
    ```typ
    #verse-indent.update()
    ```
  ][Default: 1em]
]

An example of indenting every third line of the poem to the first and every fourth line to the second level might look like this:

#side-by-side[
```typ
#poem[Hor. carm. I, 26][

Musis amicus tristitiam et metus \
tradam protervis in mare Creticum \
portare ventis, quis sub Arcto \
rex gelidae metuatur orae,

quid Tiridaten terreat, unice \
securus. O quae fontibus integris \
gaudes, apricos necte flores, \
necte meo Lamiae coronam,

][0012]
```][
#poem[Hor. carm. I, 26][
  
Musis amicus tristitiam et metus \
tradam protervis in mare Creticum \
portare ventis, quis sub Arcto \
rex gelidae metuatur orae,

quid Tiridaten terreat, unice \
securus. O quae fontibus integris \
gaudes, apricos necte flores, \
necte meo Lamiae coronam,

][0012]
]

== Numbering Verses

Verse numbers can be displayed by updating a state variable:

#side-by-side[
  ```typ
  #show-verse-numbers.update(true)
  ```
][]

Their styling is configureable via a show rule:

#side-by-side[
  ```typ
  #show <verse-number>
  ```
][]

Displaying only every $n$-th verse number can be achieved via updating a state variable:

#variable("verse-number-modulo", types:("int",), value: 1)[
  #side-by-side[
    ```typ
    #verse-number-modulo.update()
    ```
  ][Default: 1]
]

An example of using 8pt verse numbers and only displaying them for every second verse might look like this:

#side-by-side[
```typ
#show-verse-numbers.update(true)
#verse-number-modulo.update(2)

#show <verse-number>: set text(
  size: 8pt)

#poem[Hor. carm. I, 26][

Musis amicus tristitiam et metus \
tradam protervis in mare Creticum \
portare ventis, quis sub Arcto \
rex gelidae metuatur orae,

quid Tiridaten terreat, unice \
securus. O quae fontibus integris \
gaudes, apricos necte flores, \
necte meo Lamiae coronam,

][0012]
```][
#show-verse-numbers.update(true)
#verse-number-modulo.update(2)
  
#show <verse-number>: set text(
  size: 8pt
)

#poem[Hor. carm. I, 26][

Musis amicus tristitiam et metus \
tradam protervis in mare Creticum \
portare ventis, quis sub Arcto \
rex gelidae metuatur orae,

quid Tiridaten terreat, unice \
securus. O quae fontibus integris \
gaudes, apricos necte flores, \
necte meo Lamiae coronam,

][0012]
]

= Setting cycles

== Printing poems in cycles

Cycles of multiple poems can be printed by using the @cmd:cycle function:

#command("cycle", arg("cycletitle"), arg("cyclebody"))[
  #argument("cycletitle", types:("content"))[
    The cycle's title.
  ]
  #argument("cyclebody", types:("content"))[
    The poems belonging to the cycle --- see @cmd:poem-incycle.
  ]
]

The poems belonging to the cycle are then printed by using the @cmd:poem-incycle function inside the #arg("cyclebody"):

#command("poem-incycle", arg("poemtitle"), arg("poembody"), arg("indentpattern"))[
  #argument("poemtitle", types:("content"))[
    The poem's title.
  ]
  #argument("poembody", types:("content"))[
    The poem itself --- see @cmd:poem.
  ]
  #argument("indentpattern", types:("content"))[
    Specification for the indentation of verses --- see @cmd:poem and @using-indentpatterns.
  ]
]

=== Styling titles

The styling of both the titles of the cycle and the poems it contains is configureable via a show rule:

#side-by-side[
  ```typ
  #show <cycletitle>
  #show <poemtitle-incycle>
  ```
][]

The vertical space following the #arg("cycletitle") will be #text(rgb("#9346ff"), size: 9pt, font: "Liberation Mono")[\#v-after-poemtitle] and the vertical space following the poemtitles in the cycle will be exactly half of that.

An example of a cycle with styled titles might look like this:

#side-by-side[
```typ
#show-verse-numbers.update(true)
#verse-number-modulo.update(2)
  
#show <verse-number>: set text(
  size: 8pt
)

#show <cycletitle>: set text(
  size: 14pt,
  weight: "bold"
)

#show <poemtitle-incycle>: it => text(
  size: 14pt)[
    #smallcaps(all: true, it)]

#cycle[Hor. carm. I][

#poem-incycle[XXVI][

Parcius iunctas quatiunt fenestras \
iactibus crebris iuvenes proterui \
nec tibi somnos adimunt amatque \
ianua limen,

quae prius multum facilis movebat \
cardines. Audis minus et minus iam: \
Me tuo longas perevnte noctes, \
Lydia, dormis?

][0001]
  
#poem-incycle[XXVI][
  
Musis amicus tristitiam et metus \
tradam protervis in mare Creticum \
portare ventis, quis sub Arcto \
rex gelidae metuatur orae,

quid Tiridaten terreat, unice \
securus. O quae fontibus integris \
gaudes, apricos necte flores, \
necte meo Lamiae coronam,

][0012]
```][
#show-verse-numbers.update(true)
#verse-number-modulo.update(2)
  
#show <verse-number>: set text(
  size: 8pt
)

#show <cycletitle>: set text(
  size: 14pt,
  weight: "bold"
)

#show <poemtitle-incycle>: it => text(
  size: 14pt)[
    #smallcaps(all: true, it)]

#cycle[Hor. carm. I, 25 f.][

#poem-incycle[XXVI][

Parcius iunctas quatiunt fenestras \
iactibus crebris iuvenes proterui \
nec tibi somnos adimunt amatque \
ianua limen,

quae prius multum facilis movebat \
cardines. Audis minus et minus iam: \
Me tuo longas perevnte noctes, \
Lydia, dormis?

][0001]
  
#poem-incycle[XXVI][
  
Musis amicus tristitiam et metus \
tradam protervis in mare Creticum \
portare ventis, quis sub Arcto \
rex gelidae metuatur orae,

quid Tiridaten terreat, unice \
securus. O quae fontibus integris \
gaudes, apricos necte flores, \
necte meo Lamiae coronam,

][0012]
]
]
