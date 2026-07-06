#import "@preview/mantys:1.0.2": *
#import "@local/verseatile:0.2.0": *

#show: mantys(
  name: "verseatile",
  version: "0.2.0",
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
  theme: themes.default
)

#set text(size: 11pt)

#let preset-card = {
  show-verse-numbers.update(true)
  always-align-poemtitle.update(false)
  move(dx: 15pt)[
  #grid(columns: 2, column-gutter: 30pt,
  {cycle[Cycletitle][Cyclesubtitle][

  #poem-incycle[Poemtitle-incycle][Poemsubtitle-incycle][

    numbered-verse

    #interjection[Interjection]

    numbered-verse

  ][0]]},
  {poem[Poemtitle][

    #dedication[Dedication]

    numbered-verse

  ][0]
  poem[][

    #inline-poemtitle[inline-poemtitle] rest-of-verse
  
  ][0]})]}

= Setting poems <setting-poems>

== Getting Started <getting-started>

To print a poem simply use the @cmd:poem function:

#command("poem", arg("poemtitle"), arg("poembody"), arg("indentpattern"))[
  #argument("poemtitle", types:("content"))[
    The poem's title.
  ]
  #argument("poembody", types:("content"))[
    The poem itself --- The end of a verse must be marked with »#sym.backslash«. The end of a stanza however must not be marked with »#sym.backslash« but with an empty line.
  ]
  #warning-alert[#icons.warning Note that (as of v.0.2.0) the #arg("poembody") must also start with an empty line for indentation and verse numbers to properly work.]
  #argument("indentpattern", types:("content"))[
    Specification for the indentation of verses --- If no line in the poem is to be specially indented this should be 0. For advanced use of indentpatterns see @indentpatterns.
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
necte meo Lamiae coronam, ...

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
necte meo Lamiae coronam, ...

][0]
]

#pagebreak()

== Inline poemtitles <inline-poemtitles>

If #arg("poemtitle") is left empty, a part of the first verse can be set as an inline poemtitle using the @cmd:inline-poemtitle function:

#command("inline-poemtitle", arg("part-of-verse"))[]

Inline poemtitles can also be useful for advanced styling (see @advanced-styling). When using them the first verse will by default be printed at the same height that it would have been, if there was a normal (one line) #arg("poemtitle"). This can however be changed.

#variable("always-align-poemtitle", types:("bool",), value: true)[
  This can be configured by using:
  #side-by-side[
    ```typ
    #always-align-poemtitle.update()
    ```
  ][#align(right)[Default: `true`]]
]

An example of using an inline poemtitle without alignment might look like this:

#side-by-side[
```typ
#always-align-poemtitle.update(false)

#poem[][

#inline-poemtitle[Musis amicus]
  tristitiam et metus \
tradam protervis in mare Creticum \
portare ventis, quis sub Arcto \
rex gelidae metuatur orae,

quid Tiridaten terreat, unice \
securus. O quae fontibus integris \
gaudes, apricos necte flores, \
necte meo Lamiae coronam, ...

][0]
```][
#always-align-poemtitle.update(false)
  
#poem[][

#inline-poemtitle[Musis amicus]
  tristitiam et metus \
tradam protervis in mare Creticum \
portare ventis, quis sub Arcto \
rex gelidae metuatur orae,

quid Tiridaten terreat, unice \
securus. O quae fontibus integris \
gaudes, apricos necte flores, \
necte meo Lamiae coronam, ...

][0]
]

#pagebreak()

== Indentation <indentation>

By default all verses are indented in relation to the poemtitle.

#variable("base-indent", types:("length",), value: 1em)[
  This can be configured by using:
  #side-by-side[
    ```typ
    #base-indent.update()
    ```
  ][#align(right)[Default: `1em`]]
]

=== stanza-indent

Special indentation for the first verse in each stanza can also be added.

#variable("stanza-indent", types:("length",), value: 0em)[
  This can be configured by using:
  #side-by-side[
    ```typ
    #stanza-indent.update()
    ```
  ][#align(right)[Default: `0em`]]
]

=== indentpatterns <indentpatterns>

An #arg("indentpattern") specifies how the verses of the #arg("poembody") for a given poem are to be indented. It consist of a series of numbers demarking the level of indentation and is repeatedly applied. With every level (starting from $0$) the verse is incrementally indented by the same space.

#variable("verse-indent", types:("length",), value: 1em)[
  This can be configured by using:
  #side-by-side[
    ```typ
    #verse-indent.update()
    ```
  ][#align(right)[Default: `1em`]]
]

An example of indenting every third line of the poem to the first and every fourth line to the second level by using an #arg("indentpattern") might look like this:

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
necte meo Lamiae coronam, ...

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
necte meo Lamiae coronam, ...

][0012]
]

#pagebreak()

== Numbering verses <numbering-verses>

Verse numbers can be displayed by using:

#side-by-side[
  ```typ
  #show-verse-numbers.update(true)
  ```
][#align(right)[Default: `false`]]

They are placed at a configurable distance from the leftmost border of the #arg("poembody").

#variable("verse-number-distance", types:("length",), value: 5pt)[
  This can be configured by using:
  #side-by-side[
    ```typ
    #verse-number-distance.update()
    ```
  ][#align(right)[Default: `5pt`]]
]

By default verse numbers start at $1$. This can however be changed.

#variable("verse-number-start", types:("int",), value: 1)[
  This can be configured by using:
  #side-by-side[
    ```typ
    #verse-number-start.update()
    ```
  ][#align(right)[Default: `1`]]
]

They can be configured so that only every $n$-th verse number will be displayed.

#variable("verse-number-modulo", types:("int",), value: 1)[
  This can be configured by using:
  #side-by-side[
    ```typ
    #verse-number-modulo.update()
    ```
  ][#align(right)[Default: `1`]]
]

An example of displaying verse numbers for every second verse might look like this:

#side-by-side[
```typ
#show-verse-numbers.update(true)
#verse-number-modulo.update(2)

#poem[Hor. carm. I, 26][

Musis amicus tristitiam et metus \
tradam protervis in mare Creticum \
portare ventis, quis sub Arcto \
rex gelidae metuatur orae,

quid Tiridaten terreat, unice \
securus. O quae fontibus integris \
gaudes, apricos necte flores, \
necte meo Lamiae coronam, ...

][0012]
```][
#show-verse-numbers.update(true)
#verse-number-modulo.update(2)

#poem[Hor. carm. I, 26][

Musis amicus tristitiam et metus \
tradam protervis in mare Creticum \
portare ventis, quis sub Arcto \
rex gelidae metuatur orae,

quid Tiridaten terreat, unice \
securus. O quae fontibus integris \
gaudes, apricos necte flores, \
necte meo Lamiae coronam, ...

][0012]
]

#pagebreak()

== Using interjections <using-interjections>

=== interjections <interjections>

Interjections can be placed at any point in the #arg("poembody"). They are not counted as verses, will be rendered with normal spacing and can be useful for advanced styling (see @advanced-styling).

#warning-alert[#icons.warning Note that (as of v.0.2.0) a line interjections must not be followed with »\\«.]

An example of interjected strophe- and antistrophe markings might look like this:

#side-by-side[
```typ
#show-verse-numbers.update(true)
#verse-number-start.update(176)
#verse-number-modulo.update(2)

#poem-incycle[Aischyl. Ag. 176--191][

#interjection[στρ. γ.]
  
τὸν φρονεῖν βροτοὺς ὁδώ- \
σαντα, τὸν πάθει μάθος \
θέντα κυρίως ἔχειν. \
στάζει δʼ ἔν θʼ ὕπνῳ πρὸ καρδίας \
μνησιπήμων πόνος· καὶ παρʼ ἄ- \
κοντας ἦλθε σωφρονεῖν. \
δαιμόνων δέ που χάρις βίαιος \
σέλμα σεμνὸν ἡμένων.

#interjection[ἀντ. γ.]

καὶ τόθʼ ἡγεμὼν ὁ πρέ- \
σβυς νεῶν Ἀχαιικῶν, \
μάντιν οὔτινα ψέγων, \
ἐμπαίοις τύχαισι συμπνέων, \
εὖτʼ ἀπλοίᾳ κεναγγεῖ βαρύ- \
νοντʼ Ἀχαιικὸς λεώς, \
Χαλκίδος πέραν ἔχων παλιρρόχ- \
θοις ἐν Αὐλίδος τόποις·

][0]
```][
#show-verse-numbers.update(true)
#verse-number-start.update(176)
#verse-number-modulo.update(2)

#move(dx:15pt)[

#poem-incycle[Aischyl. Ag. 176--191][

#interjection[στρ. γ.]
  
τὸν φρονεῖν βροτοὺς ὁδώ- \
σαντα, τὸν πάθει μάθος \
θέντα κυρίως ἔχειν. \
στάζει δʼ ἔν θʼ ὕπνῳ πρὸ καρδίας \
μνησιπήμων πόνος· καὶ παρʼ ἄ- \
κοντας ἦλθε σωφρονεῖν. \
δαιμόνων δέ που χάρις βίαιος \
σέλμα σεμνὸν ἡμένων.

#interjection[ἀντ. γ.]

καὶ τόθʼ ἡγεμὼν ὁ πρέ- \
σβυς νεῶν Ἀχαιικῶν, \
μάντιν οὔτινα ψέγων, \
ἐμπαίοις τύχαισι συμπνέων, \
εὖτʼ ἀπλοίᾳ κεναγγεῖ βαρύ- \
νοντʼ Ἀχαιικὸς λεώς, \
Χαλκίδος πέραν ἔχων παλιρρόχ- \
θοις ἐν Αὐλίδος τόποις·

][0]]
]

=== dedications <dedications>

Dedications work very similar to interjections. They can placed at the beginning of the #arg("poembody"), will be rendered with apropriate spacing (see @spacing) and can be useful for advanced styling (see @advanced-styling).

#command("dedication", arg("part-of-verse"))[]

An dedicated example poem might look like this:

#side-by-side[
```typ
#poem[Cat. carm. 1][

#dedication[ad Cornelium]

Cui dono lepidum novum libellum \
arido modo pumice expolitum? \
Corneli, tibi; namque tu solebas \
meas esse aliquid putare nugas, \
iam tum cum ausus es unus Italorum \
omne aevum tribus explicare chartis, \
doctis, Iuppiter, et laboriosis! \
quare habe tibi quidquid hoc libelli \
qualecumque, quod, o patrona virgo, \
plus uno maneat perenne saeclo.

][0]
```][
#show-verse-numbers.update(false)

#poem[Cat. carm. 1][

#dedication[ad Cornelium]

Cui dono lepidum novum libellum \
arido modo pumice expolitum? \
Corneli, tibi; namque tu solebas \
meas esse aliquid putare nugas, \
iam tum cum ausus es unus Italorum \
omne aevum tribus explicare chartis, \
doctis, Iuppiter, et laboriosis! \
quare habe tibi quidquid hoc libelli \
qualecumque, quod, o patrona virgo, \
plus uno maneat perenne saeclo.

][0]
]

#pagebreak()

== Splitting verses <splitting-verses>

#error-alert[#icons.warning Note that (as of v.0.2.0) verse numbers for split verses will only be counted and displayed correctly if they are used within the same stanza!]

Single verses can be split over multiple lines by using the @cmd:splitverse and @cmd:versesplit functions. To split a verse into two parts the first part must be wrapped by the former:

#command("splitverse", arg("part-of-verse"))[]

#warning-alert[#icons.warning Note that (as of v.0.2.0) a line using the @cmd:splitverse function must be followed with »\\«.]

The second part in the following line must then be preceeded by a call of the latter:

#command("versesplit")[]

To split a verse into multiple parts, wrap every part before the last in the @cmd:splitverse function and preceed only the last by a call of @cmd:versesplit.

An example of splitting a verse into three parts might look like this:

#example[
```typ
#show-verse-numbers.update(true)

#poem[Cat. carm. 85][

#splitverse[Odi et amo.] \
#splitverse[quare id faciam,] \
#versesplit fortasse requiris. \
nescio, sed fieri sentio et excrucior.

][01]
```][
#show-verse-numbers.update(true)
#verse-number-modulo.update(1)
#verse-number-start.update(1)

#move(dx: 15pt)[

#poem[Cat. carm. 85][

#splitverse[Odi et amo.] \
#splitverse[quare id faciam,] \
#versesplit fortasse requiris. \
nescio, sed fieri sentio et excrucior.

][01]]
]

= Setting cycles <setting-cycles>

Cycles of multiple poems can be printed by using the @cmd:cycle function:

#command("cycle", arg("cycletitle"), arg("..cyclesubtitle"), arg("cyclebody"))[
  #argument("cycletitle", types:("content"))[
    The cycle's title.
  ]
  #argument("..cyclesubtitle", types:("content"))[
    The cycle's subtitle --- Cycles _can_ be given subtitles for advanced sytling (see @advanced-styling); this does not need be specified. By default it is rendered directly behind the #arg("cycletitle").
  ]
  #argument("cyclebody", types:("content"))[
    The poems belonging to the cycle --- see @cmd:poem-incycle.
  ]
]

The poems belonging to the cycle are then printed by using the @cmd:poem-incycle function inside the #arg("cyclebody"):

#command("poem-incycle", arg("poemtitle"), arg("..poemsubtitle"), arg("poembody"), arg("indentpattern"))[
  #argument("poemtitle", types:("content"))[
    The poem's title.
  ]
  #argument("..poemsubtitle", types:("content"))[
    The poem's subtitle --- Poems in cycles _can_ be given subtitles for advanced sytling (see @advanced-styling); this does not need be specified. By default it is rendered directly behind the #arg("poemtitle").
  ]
  #argument("poembody", types:("content"))[
    The poem itself --- see @cmd:poem.
  ]
  #argument("indentpattern", types:("content"))[
    Specification for the indentation of verses --- see @cmd:poem and @indentpatterns.
  ]
]

An example of a cycle might look like this:

#example[
```typ
#cycle[Martialis epigrammata][(XIV, 45 ff.)][

#poem-incycle[XLV.][Pila paganica][

Haec quae difficili turget paganica pluma, \
Folle minus laxast et minus arta pila.

][01]
  
#poem-incycle[XLVI.][Pila trigonalis][
  
Si me nobilibus scis expulsare sinistris, \
Sum tua. Tu nescis? rustice, redde pilam.

][01]

#poem-incycle[XLVII.][Follis][
  
Ite procul, iuvenes: mitis mihi convenit aetas: \
Folle decet pueros ludere, folle senes.

][01]
```][
#show-verse-numbers.update(false)

#cycle[Martialis epigrammata][(XIV, 45 ff.)][

#poem-incycle[XLV.][Pila paganica][

Haec quae difficili turget paganica pluma, \
Folle minus laxast et minus arta pila.

][01]
  
#poem-incycle[XLVI.][Pila trigonalis][
  
Si me nobilibus scis expulsare sinistris, \
Sum tua. Tu nescis? rustice, redde pilam.

][01]

#poem-incycle[XLVII.][Follis][
  
Ite procul, iuvenes: mitis mihi convenit aetas: \
Folle decet pueros ludere, folle senes.

][01]]
]

= Styling options <sytling-options>

== Using presets <using-presets>

Presets are preconfigured style sets that can be used for simple and effective styling. A preset can be applied by using:

#side-by-side[
  ```typ
  #show: preset-〈name〉
  ```
][]

As of v.0.2.0 the following presets are included with the package:

=== classic

#example[
```typ
#show: preset-classic
```][
#show: preset-classic
#preset-card
]

==== classic-headings
  
#example[
  ```typst
  #show: preset-classic-headings
  ```][
    Based on the `classic` preset with titles of poems and cycles being rendered as second- and poemtitles in cycles being rendered as third-level headings.
  ]

== Advanced sytling <advanced-styling>

=== Spacing <spacing>

Most spacing is controlled by setting the vertical space between the #arg("poemtitle") and the #arg("poembody") which is predefined to scale with the document's text size. 

#variable("v-after-poemtitle", types:("length",), value: 20em)[
  #side-by-side[
    ```typ
    #v-after-pormtitle.update()
    ```
  ][#align(right)[Default: `20em` at `11pt`]]
]

The vertical space following the #arg("cycletitle") will also equal #var("v-after-poemtitle") while vertical space following the poemtitles in the cycle will be exactly $frac(1, 2, style: "skewed")$ of that.

If @cmd:dedication is called at the beginning of the #arg("poembody") it will be placed exactly $frac(1, 2, style: "skewed")$ (when used with @cmd:poem) or exactly $frac(1, 4, style: "skewed")$ (when used with @cmd:poem-incycle) of #var("v-after-poemtitle") away from the #arg("poemtitle"). The vertical space between the dedication and the first verse will be twice that distance.

=== Visuals <visuals>

The styling of almost all relevant elements can also be completely customized by using show-rules. This is possible with

#side-by-side[
  ```typst
  #show <poemtitle>
  ```
][#align(right)[
  see @getting-started]
]

#side-by-side[
  ```typst
  #show <inline-poemtitle>
  ```
][#align(right)[
  see @inline-poemtitles]
]

#warning-alert[#icons.warning Note that (as of v.0.2.0), if \<poemtitle> is shown to be a heading, inline poemtitles may be shown different but will also appear in the outline (on the same level).]

#side-by-side[
  ```typst
  #show <verse-number>
  ```
][#align(right)[
  see @numbering-verses]
]

#side-by-side[
  ```typst
  #show <interjection>
  ```
][#align(right)[
  see @interjections]
]

#side-by-side[
  ```typst
  #show <dedication>
  ```
][#align(right)[
  see @dedications]
]

#side-by-side[
  ```typst
  #show <cycletitle>
  ```
][#align(right)[
  see @setting-cycles]
]

#side-by-side[
  ```typst
  #show <cyclesubtitle>
  ```
][#align(right)[
  see @setting-cycles]
]

#side-by-side[
  ```typst
  #show <poemtitle-incycle>
  ```
][#align(right)[
  see @setting-cycles]
]

#side-by-side[
  ```typst
  #show <poemsubtitle-incycle>
  ```
][#align(right)[
  see @setting-cycles]
]

= Changelog

#text(size: 14pt, weight: "bold")[v.0.2.0]

- New features:
  - Added presets.
  - Added interjections and dedications.
  - Added functionality to split verses via `#splitverse[]` and `#versesplit`.
  - Added subtitles for cycles and poems in cycles.
  - Made the indentation of the first verse of a stanza configurable via `#stanza-indent.update()`.
  - Made the starting verse number configurable via `#verse-numbers-start.update()`.
- Presets:
  - Added presets (`classic`, `classic-headings`).
- Fixes:
  - Reworked inline poemtitles to prevent false headings being displayed in the outline in certain constellations.
- Documentation:
  - Updated the manual.
  - Updated the readme.

#text(size: 14pt, weight: "bold")[v.0.1.1]

- New features:
  - Made the distance between verse numbers and the poem configurable via `#verse-number-distance.update()`.
- Fixes:
  - Reworked verse numbers to prevent them causing issues with indentation in certain constellations.
- Documentation:
  - Updated the manual.

#text(size: 14pt, weight: "bold")[v.0.1.0]

Initial release.
