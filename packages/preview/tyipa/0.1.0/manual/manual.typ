#let typst-toml = toml("../typst.toml")
#import "../src/lib.typ" as ipa

#let ipa-as-dict = dictionary(ipa)
#let diac-as-dict = dictionary(ipa.diac)
#let sym-as-dict = dictionary(ipa.sym)

#let doc = (
  title: [TyIPA Manual],
  package-name: typst-toml.package.name,
  package-version: typst-toml.package.version,
  author: typst-toml.package.authors.join(", "),
  license: typst-toml.package.license,
  description: typst-toml.package.description,
  keywords: typst-toml.package.keywords,
  categories: typst-toml.package.categories,
  disciplines: typst-toml.package.disciplines,
  date: datetime.today(),
)

// Styling attributes
#let fonts = (
  headings: "Fira Sans",
  text: "Gentium",
  code: "Fira Mono",
)

#let colors = (
  title: rgb("#361c0d"),
  links: rgb("#52a"),
  headings: black,
  footer: gray,
  package-name: rgb("#563c2d"),
)

#let pkg = text(font: fonts.code, weight: 500, size: 0.9em, fill: rgb("#563c2d"),"TyIPA")

#let example(input, ..output) = {
  if output.pos().len() > 0 {
    rect(
      input + place(
        top + right,
        dy: -0.2cm,
        text(font: fonts.code, size: 0.5em, fill: gray, "code")
      ),
      radius: (top-left: 0.25cm, top-right: 0.25cm),
      fill: rgb("#f2f2f2"),
      stroke: rgb("#ccc"),
      inset: (left: 0.25cm, right: 0.25cm, top: 0.35cm, bottom: 0.35cm),
      width: 100%
    )
    v(0cm, weak: true)
    rect(
      output.pos().at(0) + place(
        top + right,
        dy: -0.2cm,
        text(font: fonts.code, size: 0.5em, fill: gray, "preview")
      ),
      radius: (bottom-left: 0.25cm, bottom-right: 0.25cm),
      fill: none,
      stroke: rgb("#ccc"),
      inset: (left: 0.25cm, right: 0.25cm, top: 0.35cm, bottom: 0.35cm),
      width: 100%
    )
    
  } else {
    rect(
      input + place(
        top + right,
        dy: -0.2cm,
        text(font: fonts.code, size: 0.5em, fill: gray, "code")
      ),
      radius: 0.1cm,
      fill: rgb("#f2f2f2"),
      stroke: rgb("#ccc"),
      inset: (left: 0.25cm, right: 0.25cm, top: 0.35cm, bottom: 0.35cm),
      width: 100%
    )
  }
}

#let logo() = [
  /*
  #set text(fill: rgb("#f8f8f8"))
  #set align(center + top)
  #box(width: 3.25cm, height: 2cm)[
    #set text(size: 0.75cm)
    #place(
      top + left,
      dy: 0.5cm,
      rotate(text(size: 1.5cm, emoji.knot), 115deg)
    )
    #place(
      top + left,
      dx: 1.4cm,
      dy: 0.25cm,
      ipa.text("a I")
    )
    #place(
      top + left,
      dx: 1.6cm,
      dy: 0.7cm,
      ipa.text("aspirated(p) i length-mark")
    )
    #place(
      top + left,
      dx: 1.85cm,
      dy: 1.15cm,
      ipa.text("e I")
    )
  ]
  */
  #image("logo.svg", height: 2cm)
  #place(
    top + left,
    box(fill: rgb(255, 255, 255, 248), height: 2cm, width: 3.25cm)
  )
]

#let inline-code(input) = {
  highlight(
    fill: rgb("#f2f2f2"),
    extent: 0.05em,
    input
  )
}

#let int-to-hex(dec) = {
  let sign = ""
  if dec < 0 {
    sign = "-"
    dec = calc.abs(dec)
  }
  let digits = ()
  while dec > 0 {
    let d = calc.rem(dec, 0x10)
    dec = int(dec / 0x10)
    digits.push("0123456789ABCDEF".at(d))
  }
  sign + digits.rev().join("")
}

// Set document metadata
#set document(
  title: doc.title,
  author: doc.author,
  description: doc.description,
  keywords: doc.keywords,
  date: doc.date,
)

// Configure general page layout
#set page(
  paper: "a4",
  numbering: "1",
  footer: context [
    #set text(size: 0.6em, fill: gray)
    #doc.package-name #doc.package-version
    #h(1fr)
    #doc.date.display()
    #h(1fr)
    #counter(page).display()
  ],
  margin: (left: 2cm, right: 2cm, top: 2.5cm, bottom: 2cm),
)

// Configure basic styling
#set text(font: fonts.text, size: 11pt)
#set par(justify: true)
#set heading(numbering: "1.1")
#show heading: it => [
  #set text(font: fonts.headings, fill: colors.headings)
  #block[
    #if counter(heading).get().at(0) > 0 {
      place(
        dx: -1cm,
        box(
          width: 0.8cm,
          align(top + right, counter(heading).display())
        )
      )
    }
    #it.body
  ]
]
#show heading.where(level: 1): it => {
  // pagebreak(weak: true)
  //colbreak(weak: true)
  v(5em, weak: true)
  it
}
#show raw: set text(font: fonts.code)
#set highlight(
    fill: yellow,
    top-edge: "ascender",
    bottom-edge: "descender",
    extent: 0.15em,
    radius: 0.1em,
)
#show link: it => text(fill: colors.links)[#it#text(super("⮥"), fill: colors.links.transparentize(75%))]

// Set title page
#page()[
  #text(font: fonts.headings, size: 2em, weight: 700, fill: colors.title)[
    #doc.title
  ]
  #text(fill: gray, size: 0.9em)[
    #doc.package-name #doc.package-version
  ]

  _ #doc.description _

  #v(2cm, weak: true)

  #align(right, scale(200%, logo()))

  #v(2cm, weak: true)

  #outline()
]

#set page(columns: 2)
#set columns(gutter: 1.2cm)

= Introduction


#pkg is a module for working with the International Phonetic Alphabet (the IPA)
in Typst, in a _typsty_ style. It provides access to a library of IPA symbols via an interface
highly similar to Typst's `std.sym` interface, combined with accenting
functions covering the large variety of accents needed for IPA transcriptions.
Lastly, to facilitate the ease of coding transcriptions in a Typst document,
#pkg provides a conversion function that provides direct access to IPA symbols
and accents, similar to how `std.sym` etc. can be accessed directly in math
mode.

#pkg relies fully on Unicode and on fonts implementing the IPA-specific parts
of UTF-8 in a compliant way. Unlike for example `TIPA` for `LaTeX`, #pkg does
not attempt to draw, modify or encode its own IPA characters to plug any gaps 
or fix problems with fonts.

= Quick guide

== Importing #pkg

To start using #pkg, import it in your Typst project:

#example[
```typst
#import "@preview/tyipa:0.1.0" as ipa

The IPA symbol for a voiceless velar nasal is
#highlight(
  ipa.diac.voiceless-above(
    ipa.sym.n.engma
  )
).
```
][
  The IPA symbol for a voiceless velar nasal is
  #highlight(
    ipa.diac.voiceless-above(
      ipa.sym.n.engma
    )
  ).
]

Note: You should always import #pkg at the module level as shown above
(rather than e.g. ```typst #import "@preview/tyipa:0.1.0":*```) because this
avoids name collisions that would mean that #pkg shadows items from the
standard library. *This manual assumes that you've imported the whole module and
aliased it to _`ipa`_ as illustrated above.*

#pkg provides three principal facilities:

- *`ipa.sym`*: A module providing comprehensive and systematic access to the
  symbols of the IPA.
- *`ipa.diac`*: A module providing a comprehensive set of functions to attach
  the various combining diacritics of the IPA to one or more symbols.
- *`ipa.text`*: A function that allows convenient access to the IPA symbols and
  diacritic functions from within text strings.

== Inserting IPA symbols

To insert single IPA symbols, use the *#inline-code[```typ #ipa.sym```]*-submodule provided by #pkg. The 
symbols are named systematically in a way that should be familiar to most
phoneticians, though note particularly the choise to use `raised` as a
descriptor for superscript items (e.g.
#inline-code[```typc ipa.sym.y.turned.raised```] corresponds to
the symbol commonly known as "Superscript turned lower-case y", viz.
#highlight(ipa.sym.y.turned.raised)).

Generally the order is the inverse of how you would name a symbol (i.e. each
successive name component narrows down the selection and/or indicates a layer
of modification).

#[
  #set par(justify: false)
  #set text(size: 0.95em)
  _Examples:_
  - #inline-code[```typm #ipa.sym.r```]: ~ #highlight(ipa.sym.r) -- Lower-case r.
  - #inline-code[```typm #ipa.sym.r.turned```]: ~ #highlight(ipa.sym.r.turned) -- Turned lower-case r.
  - #inline-code[```typm #ipa.sym.r.turned.tail.right```]: ~ #highlight(ipa.sym.r.turned.tail.right) --
    Right-tail turned lower-case r.
]

For a comprehensive list of symbols provided by #pkg, see @sym-guide.

== Adding diacritics to symbols

For combining diacritics (aka _accents_), #pkg provides the *#inline-code[```typ #ipa.diac```]*-submodule. The submodule contains numerous functions which take a symbol or string as an argument and add augment its input with the diacritic. The diacritic functions are named after the modification they signify according to the IPA, e.g. the acute accent #highlight(ipa.diac.high(ipa.sym.placeholder)) is encoded by #inline-code(```typc ipa.diac.high()```) because it signifies a high level tone.

Some diacritics (e.g. the ring-diacritic for voicelessness) can be placed either above or below the symbol they modify. In this case, there are two diacritic functions named #inline-code(```typc ...-above()```) and #inline-code(```typc ...-below()```) respectively, and there is an alias without the `-above`/`-below` which maps to whatever is the default. For example,
#inline-code(```typc ipa.diac.voiceless-above("x")```) yields #highlight(ipa.diac.voiceless-above("x")), #inline-code(```typc ipa.diac.voiceless-below("x")```) yields #highlight(ipa.diac.voiceless-below("x")), and #inline-code(```typc ipa.diac.voiceless("x")```) yields #highlight(ipa.diac.voiceless("x")) -- the same as the `-below`-variant, because that is the "default" for the voiceless diacritic.

#[
  #set par(justify: false)
  #set text(size: 0.95em)
  _Examples:_
  - #inline-code[```typm #ipa.diac.high(ipa.sym.epsilon)```]: ~ #highlight(ipa.diac.high(ipa.sym.epsilon)) -- Lower-case epsilon with acute accent/high level tone.
  - #inline-code[```typm #ipa.diac.extra-high(ipa.sym.epsilon)```]: ~ #highlight(ipa.diac.extra-high(ipa.sym.epsilon)) -- Lower-case epsilon with double-acute accent/extra high level tone.
  - #inline-code[```typm #ipa.diac.voiceless(ipa.sym.n)```]: ~ #highlight(ipa.diac.voiceless(ipa.sym.n)) -- Lower-case n with ring below/voiceless diacritic.
  - #inline-code[```typm #ipa.diac.voiceless-above(ipa.sym.engma)```]: ~ #highlight(ipa.diac.voiceless-above(ipa.sym.engma)) -- Lower-case engma with ring above/voiceless diacritic above.
]

You can also provide a longer string to the diacritic functions, in which case each character of the string will be combined with the diacritic, e.g. #inline-code[```typc ipa.diac.syllabic("hello")```] #sym.arrow.double #highlight(ipa.diac.syllabic("hello")).

A notable exception to the above general pattern is the diacritic function #inline-code[```typc ipa.diac.tied()```], which always expects a string of length exactly 2, since the tie-bar is meant to show that two symbols represent a single segment (e.g. an affricate or a double articulation).

#[
  #set par(justify: false)
  #set text(size: 0.9em)
  _Examples:_
  - #inline-code[```typm #ipa.diac.tied(ipa.sym.t + ipa.sym.esh)```]: ~ #highlight(ipa.diac.tied(ipa.sym.t + ipa.sym.esh)) -- Tied symbols lower-case t and lower-case esh.
  - #inline-code[```typm #ipa.diac.tied("gb")```]: ~ #highlight(ipa.diac.tied("gb")) -- Tied symbols lower-case g and lower-case b.
  - #inline-code[```typm #ipa.diac.tied-below("ts")```]: ~ #highlight(ipa.diac.tied-below("ts")) -- Tied symbols lower-case t and lower-case s.
]

Diacritics can, in principle, be further combined and "stacked", though it is worth paying attention to how well your chosen font handles such combinations of diacritics, as not all of them manage this equally well.

#example[
  ```typ
  Though improbable,
  #highlight(
    ipa.diac.aspirated(
      ipa.diac.falling-rising(
        ipa.diac.voiceless(
          ipa.diac.retracted(
            ipa.sym.o.open
          )
        )
      )
    )
  )
  represents a falling-rising voiceless aspirated retracted open-mid rounded back vowel.
  ```
][
  Though improbable,
  #highlight(
    ipa.diac.aspirated(
      ipa.diac.falling-rising(
        ipa.diac.voiceless(
          ipa.diac.retracted(
            ipa.sym.o.open
          )
        )
      )
    )
  )
  represents a falling-rising voiceless aspirated retracted open-mid rounded back vowel.
]

A comprehensive list of the diacritic functions provided by #pkg, see @diac-guide.

== Direct IPA input via `ipa.text()`

Most often, several IPA symbols and/or diacritics are needed at a time, e.g. to
transcribe a word or a short passage. It would be somewhat cumbersome to have to
enter this as an extensive series of fully-qualified
#inline-code[```typc ipa.sym.{...}```] and #inline-code[```typc ipa.diac.{...}```]
calls. So, similar to how Typst provides direct unqualified calls to the builtin
#inline-code[```typc sym.{...}```] symbols inside math mode, #pkg provides the
*#inline-code[```typc ipa.text(...)```]*
function which allows unqualified direct access to the IPA symbols and
diacritics.

Say we want to transcribe the French word _bonjour_ 'good day'. With fully
qualified symbol and diacritic calls we could do this as follows:

#example[
  #set text(size: 0.9em)
  ```typm
  \[#ipa.sym.b#ipa.diac.nasalized(
    ipa.sym.o.open
  )#ipa.sym.syllable-break#ipa.sym.ezh#ipa.sym.u#ipa.diac.extra-short(
    ipa.sym.schwa
  )#ipa.sym.R.inverted\]
  ```
][
  \[#ipa.sym.b#ipa.diac.nasalized(
    ipa.sym.o.open
  )#ipa.sym.syllable-break#ipa.sym.ezh#ipa.sym.u#ipa.diac.extra-short(
    ipa.sym.schwa
  )#ipa.sym.R.inverted\]
]
 The above is horrendously verbose, isn't it? So let's try the same with
 ```typ #ipa.text(...)``` instead.
#example[
  #set text(size: 0.9em)
  ```typm
  #ipa.text(
    "b nasalized(o.open) syllable-break "
    + "ezh u extra-short(schwa) R.inverted",
    delim: "["
  )
  ```
][
  #ipa.text(
    "b nasalized(o.open) syllable-break "
    + "ezh u extra-short(schwa) R.inverted",
    delim: "["
  )
]

That's a whole lot simpler. Also note how #inline-code[```typc ipa.text(...)```]
takes an optional argument #inline-code[```typc delim```] of type
#inline-code[```typc str```] which automatically adds the desired brackets around
the transcription.

There are several options for #inline-code[```typc delim```]:
#block(inset: (left: 1em))[
  #set text(size: 0.9em)
  #set table.cell(inset: 0.3em)
  #table(
    columns: (0.5fr, 1fr),
    stroke: 0.1mm,
    table.header(
      [*#inline-code[```typc delim: ...```]*], [*Example output*]
    ),
    [```typc "/"```],  [#ipa.text("h epsilon stress-mark l schwa upsilon", delim: "/")],
    [```typc "//"```], [#ipa.text("h epsilon stress-mark l schwa upsilon", delim: "//")],
    [```typc "["```],  [#ipa.text("h epsilon stress-mark l schwa upsilon", delim: "[")],
    [```typc "[["```], [#ipa.text("h epsilon stress-mark l schwa upsilon", delim: "[[")],
    [```typc "("```],  [#ipa.text("h epsilon stress-mark l schwa upsilon", delim: "(")],
    [```typc "(("```], [#ipa.text("h epsilon stress-mark l schwa upsilon", delim: "((")],
    [```typc "<"```],  [#ipa.text("h epsilon stress-mark l schwa upsilon", delim: "<")],
    [```typc "<<"```], [#ipa.text("h epsilon stress-mark l schwa upsilon", delim: "<<")],
  )
]

For a longer example of a transcribed passage of _The Sun and the North Wind_
using the #inline-code(```typc ipa.text(...)```) function, see @extended-text-example.

== Using `ipa.text()` with a `content`-block #text(fill: red.darken(25%))[(Experimental!)]

As an experimental feature, you can also use #inline-code(```typc ipa.text(...)```)
with an argument of type #inline-code[```typc content```]. For example:

#example[
  ```typ
  #ipa.text(delim: "[")[
    stress-mark s e I f . t i
    ~ stress-mark.secondary I z
    ~ I m stress-mark aspirated(p)
    long(o.open) . t syllabic(n)
    no-release(t)
  ]
  ```
][
  #ipa.text(delim: "[")[
    stress-mark s e I f . t i
    ~ stress-mark.secondary I z
    ~ I m stress-mark aspirated(p)
    long(o.open) . t syllabic(n)
    no-release(t)
  ]
]

This might often be more convenient to type than using a string, however there
are some potential pitfalls and caveats:
- Whereas you can just type a double space (#inline-code(```typc "  "```)) to
  get a space in the output if passing a string as input, you have to hard code
  spaces with #inline-code(```typm ~```) in content mode, because Typst will
  already squash whitespace characters together, so they cannot be preserved.
- If you write several paragraphs, each of them will essentially be treated as a
  separate call to #inline-code(```typc ipa.text()```), which means that if you
  assign a delimiter, each paragraph will show the selected brackets.
- The transliteration mechanism will target _anything_ that is text within the
  passed content, so e.g. the bullets of a list might receive unintentional
  bracketing.
- You'll have to escape characters that you'd normally have to escape in content
  text, e.g. you have to write #inline-code(```typc \/```) to get the forward
  slash #highlight[\/] iff it is the first character on a line, whereas in a
  string #inline-code(```typc "/"```) would always be fine.

However, while passing content has its limitations and pitfalls, it also has
the advantage of allowing further formatting directly within a transcription,
for example imagine we wanted to highlight "_suffers_" and "_treigloffobia_" in
a partial transcription of
#ipa.sym.bracket.angle.left\He said that she _suffers_ from *treigloffobia*#ipa.sym.bracket.angle.right\.\
With a content-block, we can easily do this:

#example[

```typ
He said that
#ipa.text[```
```
  \/esh i length-mark ~
  _s wedge . f schwa z_ ~
  f r.turned wedge m ~
 *t r e I . g l o.open .
  f long(o) . b i  . j a*\/
```
```
].
```
][
  He said that
  #ipa.text[
    \/esh i length-mark ~
    _s wedge . f schwa z_ ~
    f r.turned wedge m ~
    *t r e I . g l o.open .
    f long(o) . b i  . j a*\/
  ].
]


== Choosing a font

#lorem(30)

Here are a couple of fonts you might consider trying out:

- #link("https://software.sil.org/doulos/")[Doulos SIL]
- #link("https://software.sil.org/charis/")[Charis]
- #link("https://software.sil.org/gentium/")[Gentium]
- #link("https://software.sil.org/andika/")[Andika]
- #link("https://notofonts.github.io/")[Noto] (both Serif and Sans variants)
- #link("https://brill.com/page/510269")[Brill] (free for non-commercial use only)

There's also a brief but rather handy comparison of a number of font's IPA
capabilities on Christopher Bergmann's blog at #link("https://www.isoglosse.de/2016/06/fonts-for-phonetic-transcriptions/")[isoglosse.de].

The font used in this manual is #emph(fonts.text).

= List of available IPA symbols <sym-guide>

#let display-sym(symbol, desc, name, escape: auto, note: "") = block(
  width: 100%,
  breakable: false,
  above: auto,
  below: 0.25cm,
)[
  #grid(columns: (1cm, 1fr), gutter: 0.25cm)[
    #rect(
      width: 1cm,
      height: 1cm,
      stroke: rgb("#222") + 0.25mm,
      radius: 0.2em,
    )[
      #set align(center  + horizon)
      #set text(size: 1.5em)
      #place(
        top + left,
        dx: -0.1cm,
        dy: 0.035cm,
        line(length: 0.9cm, stroke: (paint: rgb("#bbb"), thickness: 0.25mm, dash: "dotted"))
      )
      #place(
        top + left,
        dx: -0.1cm,
        dy: 0.15cm,
        line(length: 0.9cm, stroke: (paint: rgb("#aaa"), thickness: 0.25mm, dash: "densely-dashed"))
      )
      #place(
        top + left,
        dx: -0.1cm,
        dy: 0.5cm,
        line(length: 0.9cm, stroke: (paint: rgb("#aaa"), thickness: 0.25mm, dash: "densely-dashed"))
      )
      #place(
        top + left,
        dx: -0.1cm,
        dy: 0.64cm,
        line(length: 0.9cm, stroke: (paint: rgb("#bbb"), thickness: 0.25mm, dash: "dotted"))
      )
      #symbol
    ]
  ][
    #set par(justify: false, leading: 0.5em)
    #set align(left + top)
    #set text(size: 0.75em)
    *#desc*
    #v(0.5em, weak: true)
    #stack(dir: ltr, spacing: 0.2em)[
      #text(size: 0.65em)[Name:] 
    ][
      #raw(name)
    ]
    #v(0.5em, weak: true)
    // #stack(dir: ltr, spacing: 0.2em)[
    //   #text(size: 0.65em)[Shorthand:] 
    // ][
    //   #raw("+X_")
    // ]
    #v(0.5em, weak: true)
    #set text(fill: black.lighten(35%))
    #stack(dir: ltr, spacing: 0.2em)[
      #text(size: 0.65em)[Escape:]
    ][
      #if escape == auto {
        raw("\u{" + lower(int-to-hex(str(symbol).to-unicode())) + "}")
      } else {
        raw(escape)
      }
    ]
    #if note != "" {
      v(0.5em, weak: true)
      stack(dir: ltr, spacing: 0.2em)[
        #text(size: 0.65em)[Note:]
      ][
        #note
      ]
    }
  ]
]

#let display-symas(symbol, canonical, aliases) = block(
  width: 100%,
  breakable: false,
  above: auto,
  below: 0.25cm,
)[
  #grid(columns: (0.8cm, 1fr), gutter: 0.25cm)[
    #rect(
      width: 0.8cm,
      height: 0.8cm,
      stroke: none,
    )[
      #set align(center + horizon)
      #set text(size: 1.5em, fill: rgb("#333"))
      #symbol
      #place(
        top + right,
        dx: 0.15cm,
        dy: -0.15cm,
        line(angle: 90deg, length: 0.8cm, stroke: rgb("#333"))
      )
    ]
  ][
    #grid(columns: 2, gutter: 0.2em)[
      #set align(left + top)
      #text(size: 0.5em)[_Canon:_] 
    ][
      #raw(canonical)
    ]
    #v(0.5em, weak: true)
    #set text(size: 0.9em, fill: rgb("#333"))
    #text(size: 0.5em)[_Aliases:_]
    #v(0.25em, weak: true)
    #set list(indent: 0.75em, spacing: 0.35em, marker: [--])
    #for alias in aliases [
      - #raw(alias)
    ]
  ]
]

The following is a comprehensive list of the IPA symbols (and a few extra
symbols, namely brackets) made available by #pkg.

Each symbol shows to the left the symbol itself, here in the font "#fonts.text",
with the dashed lines showing the baseline and cap-height, and the dotted lines
showing the descender- and ascender-heights of the font.

Next to each symbol is shown:
- The symbol's descriptive name in boldface (what a phonetician might call the symbol, which is not
  usually what the Unicode standard calls it).
- The symbols canonical name in #pkg, which can be either used as the
  fully-qualified #inline-code[```typ #ipa.sym.{NAME}```] anywhere or as just
  #inline-code[```typ {NAME}```]
  inside a #inline-code[```typ #ipa.text("...")```] expression. For example,
  if the name is
  given as `schwa`, you can use #inline-code[```typ #ipa.sym.schwa```] or
  #inline-code[```typ #ipa.text("schwa")```] to encode #highlight(ipa.sym.schwa).
- The symbol's escape code, which is the symbol's Unicode codepoint surrounded
  by #inline-code[```typ \u{...}```].
- A note on the symbol's use (if any). For example, whether the symbol is
  obsolete, deprecated, has a non-standard use, or an alternative name. Note
  that this does not give aliases, for which see @sym-aliases.

== Lower-case Latin-based

#display-sym(ipa.sym.a, "Lower-case a", "a")
#display-sym(ipa.sym.a.raised, "Raised lower-case a", "a.raised")
#display-sym(ipa.sym.a.turned, "Turned lower-case a", "a.turned")
#display-sym(ipa.sym.a.turned.raised, "Superscript turned lower-case a", "a.turned.raised")

#display-sym(ipa.sym.b, "Lower-case b", "b")
#display-sym(ipa.sym.b.hook-top, "Hook-top lower-case b", "b.hook-top")
#display-sym(ipa.sym.b.raised, "Superscript lower-case b", "b.hook-top")

#display-sym(ipa.sym.c, "Lower-case c", "c")
#display-sym(ipa.sym.c.cedilla, "Lower-case c-cedilla", "c.cedilla")
#display-sym(ipa.sym.c.hook-top, "Hook-top lower-case c", "c.hook-top")
#display-sym(ipa.sym.c.raised, "Superscript lower-case c", "c.raised")
#display-sym(ipa.sym.c.streched, "Stretched lower-case c", "b.hook-top", note: "Obsolete")
#display-sym(ipa.sym.c.tail.curly, "Curly-tail lower-case c", "c.tail.curly")
#display-sym(ipa.sym.c.tail.curly.raised, "Superscript curly-tail lower-case c", "c.tail.curly.raised")

#display-sym(ipa.sym.d, "Lower-case d", "d")
#display-sym(ipa.sym.d.raised, "Superscript lower-case d", "d.raised")
#display-sym(ipa.sym.d.tail.right, "Right-tail lower-case d", "d.tail.right")

#display-sym(ipa.sym.e, "Lower-case e", "e")
#display-sym(ipa.sym.e.raised, "Superscript lower-case e", "e.raised")
#display-sym(ipa.sym.e.reversed, "Reversed lower-case e", "e.reversed")
#display-sym(ipa.sym.schwa, "Schwa", "schwa", note: [aka _turned lower-case e_])
#display-sym(ipa.sym.schwa.hook, "Schwa with hook", "schwa.hook")
#display-sym(ipa.sym.schwa.raised, "Superscript schwa", "schwa.raised")

#display-sym(ipa.sym.f, "Lower-case f", "f")
#display-sym(ipa.sym.f.raised, "Superscript lower-case f", "f.raised")

#display-sym(ipa.sym.g, "Lower-case g", "g", note: [Always single-storey g])
#display-sym(ipa.sym.g.hook-top, "Hook-top lower-case g", "g.hook-top", note: [Always single-storey g])
#display-sym(ipa.sym.g.raised, "Raised lower-case g", "g.raised", note: [Always single-storey g])

#display-sym(ipa.sym.h, "Lower-case h", "h")
#display-sym(ipa.sym.h.barred, "Barred lower-case h", "h.barred")
#display-sym(ipa.sym.h.barred.raised, "Superscript barred lower-case h", "h.barred.raised")
#display-sym(ipa.sym.h.engma, "Hengma", "sym.h.engma")
#display-sym(ipa.sym.h.engma.hook-top, "Hook-top hengma", "sym.h.engma.hook-top")
#display-sym(ipa.sym.h.engma.hook-top.raised, "Superscript hook-top hengma", "h.engma.hook-top.raised")
#display-sym(ipa.sym.h.hook-top, "Hook-top lower-case h", "sym.h.hook-top")
#display-sym(ipa.sym.h.hook-top.raised, "Superscript hook-top lower-case h", "h.hook-top.raised")
#display-sym(ipa.sym.h.raised, "Superscript lower-case h", "h.raised")
#display-sym(ipa.sym.h.turned, "Turned lower-case h", "h.turned")
#display-sym(ipa.sym.h.turned.fish-hook, "Fish-hook turned lower-case h", "h.turned.fish-hook")
#display-sym(ipa.sym.h.turned.fish-hook.tail.right, "Right-tail fish-hook turned lower-case h", "h.turned.fish-hook.tail.right")
#display-sym(ipa.sym.h.turned.raised, "Superscript turned lower-case h", "h.turned.raised")


#display-sym(ipa.sym.i, "Lower-case i", "i")
#display-sym(ipa.sym.i.barred, "Barred lower-case i", "i.barred")
#display-sym(ipa.sym.i.barred.raised, "Superscript barred lower-case i", "i.barred.raised")
#display-sym(ipa.sym.i.raised, "Superscript lower-case i", "i.raised")

#display-sym(ipa.sym.j, "Lower-case j", "j")
#display-sym(ipa.sym.j.dotless.barred, "Barred dotless lower-case j", "j.dotless.barred")
#display-sym(ipa.sym.j.dotless.barred.hook-top, "Hook-top barred dotless lower-case j", "j.dotless.barred.hook-top")
#display-sym(ipa.sym.j.dotless.barred.hook-top.raised, "Superscript hook-top barred dotless lower-case j", "j.dotless.barred.hook-top.raised")
#display-sym(ipa.sym.j.raised, "Superscript lower-case j", "j")
#display-sym(ipa.sym.j.tail.curly, "Curly-tail lower-case j", "j.tail.curly")
#display-sym(ipa.sym.j.tail.curly.raised, "Superscript curly-tail lower-case j", "j.tail.curly.raised")

#display-sym(ipa.sym.k, "Lower-case k", "k")
#display-sym(ipa.sym.k.hook-top, "Hook-top lower-case k", "k.hook-top", note: [Obsolete])
#display-sym(ipa.sym.k.raised, "Superscript lower-case k", "k")
#display-sym(ipa.sym.k.turned, "Superscript turned lower-case k", "k", note: [Obsolete])

#display-sym(ipa.sym.l, "Lower-case l", "l")
#display-sym(ipa.sym.l.belted, "Belted lower-case l", "l.belted")
#display-sym(ipa.sym.l.belted.raised, "Superscript belted lower-case l", "l.belted.raised")
#display-sym(ipa.sym.l.raised, "Superscript lower-case l", "l.raised")
#display-sym(ipa.sym.l.tail.right, "Right-tail lower-case l", "l.tail.right")
#display-sym(ipa.sym.l.tail.right.raised, "Superscript right-tail lower-case l", "l.tail.right.raised")
#display-sym(ipa.sym.l.tilde, "Lower-case l with tilde", "l.tilde")
#display-sym(ipa.sym.l.tilde.raised, [Superscript lower-case l with tilde#footnote[Apparently some fonts (e.g. _Times New Roman_) have misimplemented _superscript lower-case l with tilde_ as showing a double-tilde; the Unicode codepoint is correct.]], "l.tilde.raised")


#display-sym(ipa.sym.m, "Lower-case m", "m")
#display-sym(ipa.sym.m.engma, "Mengma", "m.engma")
#display-sym(ipa.sym.m.engma.raised, "Superscript mengma", "m.engma.raised")
#display-sym(ipa.sym.m.raised, "Superscript lower-case m", "m.raised")
#display-sym(ipa.sym.m.turned, "Turned lower-case m", "m.turned")
#display-sym(ipa.sym.m.turned.raised, "Superscript turned lower-case m", "m.turned.raised")
#display-sym(ipa.sym.m.turned.right-leg, "Right-leg turned lower-case m", "m.turned.right-leg")
#display-sym(ipa.sym.m.turned.right-leg.raised, "Superscript right-leg turned lower-case m", "m.turned.right-leg.raised")

#display-sym(ipa.sym.n, "Lower-case n", "n")
#display-sym(ipa.sym.n.engma, "Engma", "n.engma")
#display-sym(ipa.sym.n.engma.raised, "Superscript engma", "n.engma.raised")
#display-sym(ipa.sym.n.tail.right, "Right-tail lower-case n", "n.tail.right")
#display-sym(ipa.sym.n.tail.right.raised, "Superscript right-tail lower-case n", "n.tail.right.raised")
#display-sym(ipa.sym.n.tail.left, "Left-tail lower-case n", "n.tail.left")
#display-sym(ipa.sym.n.tail.left.raised, "Superscript left-tail lower-case n", "n.tail.left.raised")

#display-sym(ipa.sym.o, "Lower-case o", "o")
#display-sym(ipa.sym.o.barred, "Barred lower-case o", "o.barred")
#display-sym(ipa.sym.o.barred.raised, "Superscript barred lower-case o", "o.barred.raised")
#display-sym(ipa.sym.o.open, "Open lower-case o", "o.open")
#display-sym(ipa.sym.o.open.raised, "Superscript open lower-case o", "o.open.raised")
#display-sym(ipa.sym.o.raised, "Superscript lower-case o", "o.raised")
#display-sym(ipa.sym.o.slashed, "Slashed lower-case o", "o.slashed")
#display-sym(ipa.sym.o.slashed.raised, "Superscript slashed lower-case o", "o.slashed.raised")

#display-sym(ipa.sym.p, "Lower-case p", "p")
#display-sym(ipa.sym.p.hook-top, "Hook-top lower-case p", "p.hook-top", note: [Obsolete])
#display-sym(ipa.sym.p.raised, "Superscript lower-case p", "p.raised")

#display-sym(ipa.sym.q, "Lower-case q", "q")
#display-sym(ipa.sym.q.hook-top, "Hook-top lower-case q", "q.hook-top", note: [Obsolete])
#display-sym(ipa.sym.q.hook-top.raised, "Superscript hook-top lower-case q", "q.hook-top.raised", note: [Obsolete])
#display-sym(ipa.sym.q.raised, "Superscript lower-case q", "q.raised")

#display-sym(ipa.sym.r, "Lower-case r", "r")
#display-sym(ipa.sym.r.fish-hook, "Fish-hook r", "r.fish-hook")
#display-sym(ipa.sym.r.fish-hook.reversed, "Reversed fish-hook r", "r.fish-hook.reversed", note: [Non-standard, sinology use])
#display-sym(ipa.sym.r.long-leg, "Long-leg lower-case r", "r.long-leg", note: [Obsolete])
#display-sym(ipa.sym.r.long-leg.turned, "Turned long-leg lower-case r", "r.long-leg.turned")
#display-sym(ipa.sym.r.raised, "Superscript lower-case r", "r.raised")
#display-sym(ipa.sym.r.tail.right, "Right-tail lower-case r", "r.tail.right")
#display-sym(ipa.sym.r.tail.right.raised, "Superscript right-tail lower-case r", "r.tail.right.raised")
#display-sym(ipa.sym.r.turned, "Turned lower-case r", "r.turned")
#display-sym(ipa.sym.r.turned.raised, "Superscript turned lower-case r", "r.turned.raised")
#display-sym(ipa.sym.r.turned.tail.right, "Right-tail turned lower-case r", "r.turned.tail.right")
#display-sym(ipa.sym.r.turned.tail.right.raised, "Superscript right-tail turned lower-case r", "r.turned.tail.right.raised")

#display-sym(ipa.sym.s, "Lower-case s", "s")
#display-sym(ipa.sym.s.raised, "Superscript lower-case s", "s.raised")
#display-sym(ipa.sym.s.tail.right, "Right-tail lower-case s", "s.tail.right")
#display-sym(ipa.sym.s.tail.right.raised, "Superscript right-tail lower-case s", "s.tail.right")

#display-sym(ipa.sym.t, "Lower-case t", "t")
#display-sym(ipa.sym.t.hook-top, "Hook-top lower-case t", "t.hook-top", note: [Obsolete])
#display-sym(ipa.sym.t.raised, "Superscript lower-case t", "t.raised")
#display-sym(ipa.sym.t.tail.right, "Right-tail lower-case t", "t.tail.right")
#display-sym(ipa.sym.t.tail.right.raised, "Superscript right-tail lower-case t", "t.tail.right.raised")
#display-sym(ipa.sym.t.turned, "Turned lower-case t", "t.turned", note: [Obsolete])

#display-sym(ipa.sym.u, "Lower-case u", "u")
#display-sym(ipa.sym.u.barred, "Barred lower-case u", "u.barred")
#display-sym(ipa.sym.u.barred.raised, "Superscript barred lower-case u", "u.barred.raised")
#display-sym(ipa.sym.u.raised, "Superscript lower-case u", "u.raised")

#display-sym(ipa.sym.v, "Lower-case v", "v")
#display-sym(ipa.sym.v.cursive, "Cursive lower-case v", "v.cursive")
#display-sym(ipa.sym.v.cursive.raised, "Superscript cursive lower-case v", "v.raised")
#display-sym(ipa.sym.v.hook-top, "Hook-top lower-case v", "v.hook-top")
#display-sym(ipa.sym.v.hook-top.raised, "Superscript hook-top lower-case v", "v.hook-top.raised")
#display-sym(ipa.sym.v.raised, "Superscript lower-case v", "v.raised")
#display-sym(ipa.sym.v.turned, "Turned lower-case v", "v.turned")
#display-sym(ipa.sym.v.turned.raised, "Superscript turned lower-case v", "v.turned.raised")

#display-sym(ipa.sym.w, "Lower-case w", "w")
#display-sym(ipa.sym.w.raised, "Superscript lower-case w", "w.raised")
#display-sym(ipa.sym.w.turned, "Turned lower-case w", "w.turned")
#display-sym(ipa.sym.w.turned.raised, "Superscript turned lower-case w", "w.turned.raised")

#display-sym(ipa.sym.x, "Lower-case x", "x")
#display-sym(ipa.sym.x.raised, "Superscript lower-case x", "x.raised")

#display-sym(ipa.sym.y, "Lower-case y", "y")
#display-sym(ipa.sym.y.raised, "Superscript lower-case y", "y.raised")
#display-sym(ipa.sym.y.turned, "Turned lower-case y", "y.turned")
#display-sym(ipa.sym.y.turned.raised, "Superscript turned lower-case y", "y.turned.raised")

#display-sym(ipa.sym.z, "Lower-case z", "z")
#display-sym(ipa.sym.z.raised, "Superscript lower-case z", "z.raised")
#display-sym(ipa.sym.z.tail.right, "Right-tail lower-case z", "z.tail.right")
#display-sym(ipa.sym.z.tail.right.raised, "Superscript right-tail lower-case z", "z.tail.right.raised")
#display-sym(ipa.sym.z.tail.curly, "Curly-tail lower-case z", "z.tail.curly")
#display-sym(ipa.sym.z.tail.curly.raised, "Superscript curly-tail lower-case z", "z.tail.curly.raised")

== Small-capital Latin-based

#display-sym(ipa.sym.B, "Small-capital B", "B")
#display-sym(ipa.sym.B.raised, "Superscript small-capital B", "B.raised")

#display-sym(ipa.sym.G, "Small-capital G", "G")
#display-sym(ipa.sym.G.hook-top, "Hook-top small-capital G", "G.hook-top")
#display-sym(ipa.sym.G.hook-top.raised, "Superscript hook-top small-capital G", "G.hook-top.raised")
#display-sym(ipa.sym.G.raised, "Superscript small-capital G", "G.raised")

#display-sym(ipa.sym.H, "Small-capital H", "H")
#display-sym(ipa.sym.H.raised, "Superscript small-capital H", "H.raised")

#display-sym(ipa.sym.I, "Small-capital I", "I")
#display-sym(ipa.sym.I.raised, "Superscript small-capital I", "I.raised")

#display-sym(ipa.sym.Y, "Small-capital Y", "Y")
#display-sym(ipa.sym.Y.raised, "Superscript small-capital Y", "Y.raised")

#display-sym(ipa.sym.L, "Small-capital L", "L")
#display-sym(ipa.sym.L.raised, "Superscript small-capital L", "L.raised")

#display-sym(ipa.sym.N, "Small-capital N", "N")
#display-sym(ipa.sym.N.raised, "Superscript small-capital N", "N.raised")

#display-sym(ipa.sym.R, "Small-capital R", "R")
#display-sym(ipa.sym.R.inverted, "Inverted small-capital R", "R.inverted")
#display-sym(ipa.sym.R.inverted.raised, "Superscript inverted small-capital R", "R.inverted.raised")
#display-sym(ipa.sym.R.raised, "Superscript small-capital R", "R.raised")

== Greek-based

#display-sym(ipa.sym.alpha, "Lower-case alpha", "alpha")
#display-sym(ipa.sym.alpha.raised, "Superscript lower-case alpha", "alpha.raised")
#display-sym(ipa.sym.alpha.turned, "Turned lower-case alpha", "alpha.turned")
#display-sym(ipa.sym.alpha.turned.raised, "Superscript turned lower-case alpha", "alpha.turned.raised")

#display-sym(ipa.sym.beta, "Lower-case beta", "beta")
#display-sym(ipa.sym.beta.raised, "Superscript lower-case beta", "beta.raised")

#display-sym(ipa.sym.gamma, "Lower-case gamma", "gamma")
#display-sym(ipa.sym.gamma.raised, "Superscript lower-case gamma", "gamma.raised")

#display-sym(ipa.sym.epsilon, "Lowe-case epislon", "epsilon")
#display-sym(ipa.sym.epsilon.raised, "Superscript lower-case epsilon", "epsilon.raised")
#display-sym(ipa.sym.epsilon.reversed, "Reversed lower-case epsilon", "epsilon.reversed")
#display-sym(ipa.sym.epsilon.reversed.closed, "Closed reversed lower-case epsilon", "epsilon.reversed.closed")
#display-sym(ipa.sym.epsilon.reversed.closed.raised, "Superscript reversed lower-case epsilon", "epsilon.reversed.closed.raised")
#display-sym(ipa.sym.epsilon.reversed.hook, "Reversed lower-case epsilon with hook", "epsilon.reversed.hook")
#display-sym(ipa.sym.epsilon.reversed.raised, "Superscript reversed lower-case epsilon", "epsilon.reversed.raised")

#display-sym(ipa.sym.theta, "Lower-case theta", "theta")
#display-sym(ipa.sym.theta.raised, "Superscript lower-case theta", "theta.raised")

#display-sym(ipa.sym.iota, "Lower-case iota", "iota", note: [Obsolete])

#display-sym(ipa.sym.upsilon, "Lower-case upsilon", "upsilon")
#display-sym(ipa.sym.upsilon.raised, "Superscript lower-case upsilon", "upsilon.raised")

#display-sym(ipa.sym.phi, "Lower-case phi", "phi")
#display-sym(ipa.sym.phi.raised, "Superscript lower-case phi", "phi.raised")

#display-sym(ipa.sym.chi, "Lower-case chi", "chi")
#display-sym(ipa.sym.chi.raised, "Superscript lower-case chi", "chi.raised")

#display-sym(ipa.sym.omega.closed, "Closed lower-case omega", "omega.closed")
#display-sym(ipa.sym.omega.closed.raised, "Superscript lower-case omega", "omega.closed.raised")

== Ligatures, digraphs and others

#display-sym(ipa.sym.ae, "Lower-case a-e ligature", "ae")
#display-sym(ipa.sym.ae.raised, "Superscript lower-case a-e ligature", "ae.raised")

#display-sym(ipa.sym.bulls-eye, "Bull's eye", "bulls-eye")
#display-sym(ipa.sym.bulls-eye.raised, "Superscript bull's eye", "bulls-eye.raised")

#display-sym(ipa.sym.esh, "Lower-case esh", "esh")
#display-sym(ipa.sym.esh.raised, "Superscript lower-case esh", "esh.raised")
#display-sym(ipa.sym.esh.reversed, "Reversed lower-case esh", "esh.reversed")
#display-sym(ipa.sym.esh.tail.curly, "Curly-tail lower-case esh", "esh.tail.curly", note: [Obsolete])

#display-sym(ipa.sym.eth, "Lower-case eth", "eth")
#display-sym(ipa.sym.eth.raised, "Superscript lower-case eth", "eth.raised")

#display-sym(ipa.sym.ezh, "Lower-case ezh", "esh")
#display-sym(ipa.sym.ezh.raised, "Superscript lower-case ezh", "ezh.raised")
#display-sym(ipa.sym.ezh.tail.curly, "Curly-tail lower-case ezh", "ezh.raised.tail.curly", note: [Obsolete])

#display-sym(ipa.sym.exclamation-mark, "Exclamation mark", "exclamation-mark")
#display-sym(ipa.sym.exclamation-mark.raised, "Superscript exclamation-mark", "exclamation-mark.raised")

#display-sym(ipa.sym.glottal-stop, "Glottal stop", "glottal-stop")
#display-sym(ipa.sym.glottal-stop.raised, "Superscript glottal stop", "glottal-stop.raised")
#display-sym(ipa.sym.glottal-stop.reversed, "Reversed glottal stop", "glottal-stop.reversed")
#display-sym(ipa.sym.glottal-stop.reversed.barred, "Barred reversed glottal stop", "glottal-stop.reversed.barred")
#display-sym(ipa.sym.glottal-stop.reversed.barred.raised, "Superscript barred reversed glottal stop", "glottal-stop.reversed.barred.raised")
#display-sym(ipa.sym.glottal-stop.reversed.raised, "Superscript reversed glottal stop", "glottal-stop.reversed.raised")
#display-sym(ipa.sym.glottal-stop.barred, "Barred glottal stop", "glottal-stop.barred")
#display-sym(ipa.sym.glottal-stop.barred.raised, "Superscript barred glottal stop", "glottal-stop.barred.raised")
#display-sym(ipa.sym.glottal-stop.inverted, "Inverted glottal stop", "glottal-stop.inverted", note: [Obsolete])

#display-sym(ipa.sym.lezh, "Lower-case l-ezh ligature", "lezh")
#display-sym(ipa.sym.lezh.raised, "Superscript lower-case l-ezh ligature", "lezh.raised")

#display-sym(ipa.sym.oe, "Lower-case o-e ligature", "oe")
#display-sym(ipa.sym.oe.raised, "Superscript lower-case o-e ligature", "oe.raised")

#display-sym(ipa.sym.OE, "Small-capital o-e ligature", "OE")
#display-sym(ipa.sym.OE.raised, "Superscript small-capital o-e ligature", "OE.raised")

#display-sym(ipa.sym.pipe, "Pipe", "pipe")
#display-sym(ipa.sym.pipe.double, "Doubel pipe", "pipe.double")
#display-sym(ipa.sym.pipe.double, "Superscript double pipe", "pipe.double.raised")
#display-sym(ipa.sym.pipe.double-barred, "Double-barred pipe", "pipe.double-barred")
#display-sym(ipa.sym.pipe.double-barred, "Superscript double-barred pipe", "pipe.double-barred.raised")
#display-sym(ipa.sym.pipe.raised, "Superscript pipe", "pipe.raised")

#display-sym(ipa.sym.rams-horn, "Ram's horn", "rams-horn")
#display-sym(ipa.sym.rams-horn.raised, "Superscript ram's horn", "rams-horn.raised")

#display-sym(ipa.sym.placeholder.circle, "Dotted circle placeholder", "placeholder.circle")
#display-sym(ipa.sym.placeholder.blank, "Non-breaking space (used as a placeholder)", "placeholder.blank")

== Suprasegmentals

#display-sym(ipa.sym.undertie, "Undertie", "undertie")

#display-sym(ipa.sym.stress-mark.primary, "Primary stress mark", "stress-mark.primary")
#display-sym(ipa.sym.stress-mark.secondary, "Secondary stress mark", "stress-mark.secondary")

#display-sym(ipa.sym.syllable-break, "Syllable break", "Syllable break")

#display-sym(ipa.sym.length-mark.long, "Long length mark", "length-mark.long")
#display-sym(ipa.sym.length-mark.half-long, "Half-long length mark", "length-mark.half-long")

#display-sym(ipa.sym.group-mark.minor, "Minor group mark", "group-mark.minor")
#display-sym(ipa.sym.group-mark.major, "Major group mark", "group-mark.major")

#display-sym(ipa.sym.upstep, "Upstep mark", "upstep")
#display-sym(ipa.sym.downstep, "Downstep mark", "downstep")

#display-sym(ipa.sym.global-rise, "Global rise mark", "global-rise")
#display-sym(ipa.sym.global-fall, "Global fall mark", "global-fall")

#display-sym(ipa.sym.tone-bar.extra-high, "Extra-high tone-bar", "tone-bar.extra-high")
#display-sym(ipa.sym.tone-bar.high, "High tone-bar", "tone-bar.high")
#display-sym(ipa.sym.tone-bar.mid, "Mid tone-bar", "tone-bar.mid")
#display-sym(ipa.sym.tone-bar.low, "Low tone-bar", "tone-bar.low")
#display-sym(ipa.sym.tone-bar.extra-low, "Extra-low tone-bar", "tone-bar.extra-low")

== Brackets

#display-sym(ipa.sym.bracket.angle.left, "Left angle bracket", "bracket.angle.left")
#display-sym(ipa.sym.bracket.angle.right, "Right angle bracket", "bracket.angle.right")
#display-sym(ipa.sym.bracket.angle.double.left, "Left double angle bracket", "bracket.angle.double.left")
#display-sym(ipa.sym.bracket.angle.double.right, "Right double angle bracket", "bracket.angle.double.right")
#display-sym(ipa.sym.bracket.paren.left, "Left parenthesis", "bracket.paren.left")
#display-sym(ipa.sym.bracket.paren.left.raised, "Superscript left parenthesis", "bracket.paren.left.raised")
#display-sym(ipa.sym.bracket.paren.right, "Right parenthesis", "bracket.paren.right")
#display-sym(ipa.sym.bracket.paren.right.raised, "Superscript right parenthesis", "bracket.paren.right.raised")
#display-sym(ipa.sym.bracket.paren.double.left, "Left double parenthesis", "bracket.paren.double.left")
#display-sym(ipa.sym.bracket.paren.double.right, "Right double parenthesis", "bracket.paren.double.right")
#display-sym(ipa.sym.bracket.square.left, "Left square bracket", "bracket.square.left")
#display-sym(ipa.sym.bracket.square.right, "Right square bracket", "bracket.square.right")
#display-sym(ipa.sym.bracket.square.double.left, "Left double square bracket", "bracket.square.double.left")
#display-sym(ipa.sym.bracket.square.double.right, "Right double square bracket", "bracket.square.double.right")


== Deprecated ligatures

The following ligatures for affricates are deprecated. It is generally recommended to use a combination of the constituent symbols, possibly with a tie-bar (see #inline-code[```typst #ipa.diac.tie()```]) to indicate that they represent a single entity.

#display-sym(ipa.sym.dezh, "Lower-case d-ezh ligature", "dezh", note: [Deprecated])
#display-sym(ipa.sym.dezh.raised, "Superscript lower-case d-ezh ligature", "dezh.raised", note: [Deprecated])
#display-sym(ipa.sym.dz, "Lower-case d-z ligature", "dz", note: [Deprecated])
#display-sym(ipa.sym.dz.raised, "Superscript lower-case d-z lgiature", "dz.raised", note: [Deprecated])
#display-sym(ipa.sym.dz.curly, "Lower-case d-curly-z ligature", "dz.curly", note: [Deprecated])
#display-sym(ipa.sym.dz.curly.raised, "Superscript lower-case d-curly-z ligature", "dz.curly.raised", note: [Deprecated])
#display-sym(ipa.sym.tesh, "", "tesh", note: [Deprecated])
#display-sym(ipa.sym.tesh.raised, "", "tesh.raised", note: [Deprecated])
#display-sym(ipa.sym.ts, "Lower-case t-s ligature", "ts", note: [Deprecated])
#display-sym(ipa.sym.ts.raised, "Superscript lower-case t-s ligature", "ts.raised", note: [Deprecated])
#display-sym(ipa.sym.tc.tail.curly, "Lower-case t-curly-tail-c ligature", "tc.tail.curly", note: [Deprecated])
#display-sym(ipa.sym.tc.tail.curly.raised, "Superscript lower-case t-curly-tail-c ligature", "tc.tail.curly.raised", note: [Deprecated])

== Aliases <sym-aliases>

Several of the symbols listed in the previous sections are also commonly known by other names (an _alias_) or should be logically referenceable by such an alias (e.g. a schwa is really a turned e). In a few cases, an alias might simply represent a common short-hand for the full symbol name (e.g. `length-mark` for `length-mark.primary`). For convenience, #pkg includes the following aliases.

#display-symas(ipa.sym.alpha, "alpha", (
  "a.cursive",
  "a.script",
  "a.single-storey",
))
#display-symas(ipa.sym.alpha.raised, "alpha.raised", (
  "a.cursive.raised",
  "a.script.raised",
  "a.single-storey.raised",
))
#display-symas(ipa.sym.alpha.turned, "alpha.turned", (
  "a.cursive.turned",
  "a.script.turned",
  "a.single-storey.raised",
))
#display-symas(ipa.sym.alpha.turned.raised, "alpha.turned.raised", (
  "a.cursive.turned.raised",
  "a.script.turned.raised",
  "a.single-storey.raised",
))
#display-symas(ipa.sym.c.tail.curly, "c.tail.curly", (
  "c.tail",
))
#display-symas(ipa.sym.c.tail.curly.raised, "c.tail.curly.raised", (
  "c.tail.raised",
))
#display-symas(ipa.sym.d.tail.right, "d.tail.right", (
  "d.retroflex",
  "d.tail",
))
#display-symas(ipa.sym.schwa, "schwa", (
  "e.turned",
))
#display-symas(ipa.sym.schwa.hook, "schwa.hook", (
  "e.turned.hook",
))
#display-symas(ipa.sym.schwa.raised, "schwa.raised", (
  "e.turned.raised",
))
#display-symas(ipa.sym.g, "g", (
  "g.single-storey",
))
#display-symas(ipa.sym.g.hook-top, "g.hook-top", (
  "g.single-storey.hook-top",
))
#display-symas(ipa.sym.g.raised, "g.raised", (
  "g.single-storey.raised",
))
#display-symas(ipa.sym.h.engma, "h.engma", (
  "hengma",
))
#display-symas(ipa.sym.h.engma.hook-top, "h.engma.hook-top", (
  "hengma.hook-top",
))
#display-symas(ipa.sym.h.engma.hook-top.raised, "h.engma.hook-top.raised", (
  "hengma.hook-top.raised",
))
#display-symas(ipa.sym.h.engma.raised, "h.engma.raised", (
  "hengma.raised",
))
#display-symas(ipa.sym.h.turned.fish-hook.tail.right, "h.turned.fish-hook.tail.right", (
  "h.turned.fish-hook.tail",
))
#display-symas(ipa.sym.j.tail.curly, "j.tail.curly", (
  "j.tail",
))
#display-symas(ipa.sym.j.tail.curly.raised, "j.tail.curly.raised", (
  "j.tail.raised",
))
#display-symas(ipa.sym.l.tail.right, "l.tail.right", (
  "l.retroflex",
  "l.tail",
))
#display-symas(ipa.sym.l.tail.right.raised, "l.tail.right.raised", (
  "l.retroflex.raised",
  "l.tail.raised",
))
#display-symas(ipa.sym.m.engma, "m.engma", (
  "mengma",
))
#display-symas(ipa.sym.m.engma.raised, "m.engma.raised", (
  "mengma.raised",
))
#display-symas(ipa.sym.n.engma, "n.engma", (
  "enmga",
))
#display-symas(ipa.sym.n.engma.raised, "n.engma.raised", (
  "enmga.raised",
))
#display-symas(ipa.sym.n.tail.right, "n.tail.right", (
  "n.retroflex",
  "n.tail",
))
#display-symas(ipa.sym.n.tail.right.raised, "n.tail.right.raised", (
  "n.retroflex.raised",
  "n.tail.raised",
))
#display-symas(ipa.sym.r.tail.right, "r.tail.right", (
  "r.retroflex",
  "r.tail",
))
#display-symas(ipa.sym.r.tail.right.raised, "r.tail.right.raised", (
  "r.retroflex.raised",
  "r.tail.raised",
))
#display-symas(ipa.sym.r.turned.tail.right, "r.turned.tail.right", (
  "r.turned.retroflex",
  "r.turned.tail",
))
#display-symas(ipa.sym.r.turned.tail.right.raised, "r.turned.tail.right.raised", (
  "r.turned.retroflex.raised",
  "r.turned.tail.raised",
))
#display-symas(ipa.sym.s.tail.right, "s.tail.right", (
  "s.retroflex",
  "s.tail",
))
#display-symas(ipa.sym.s.tail.right.raised, "s.tail.right.raised", (
  "s.retroflex.raised",
  "s.tail.raised",
))
#display-symas(ipa.sym.t.tail.right, "t.tail.right", (
  "t.retroflex",
  "t.tail",
))
#display-symas(ipa.sym.t.tail.right.raised, "t.tail.right.raised", (
  "t.retroflex.raised",
  "t.tail.raised",
))
#display-symas(ipa.sym.upsilon, "upsilon", (
  "u.horseshoe",
))
#display-symas(ipa.sym.upsilon.raised, "upsilon.raised", (
  "u.horseshoe.raised",
))
#display-symas(ipa.sym.v.cursive, "v.cursive", (
  "v.script",
))
#display-symas(ipa.sym.v.cursive.raised, "v.cursive.raised", (
  "v.script.raised",
))
#display-symas(ipa.sym.v.turned, "v.turned", (
  "wedge",
))
#display-symas(ipa.sym.v.turned.raised, "v.turned.raised", (
  "wedge.raised",
))
#display-symas(ipa.sym.z.tail.right, "z.tail.right", (
  "z.retroflex",
  "z.tail",
))
#display-symas(ipa.sym.z.tail.right.raised, "z.tail.right.raised", (
  "z.retroflex.raised",
  "z.tail.raised",
))
#display-symas(ipa.sym.eth, "eth", (
  "edh",
))
#display-symas(ipa.sym.placeholder.circle, "placeholder.circle", (
  "placeholder",
))
#display-symas(ipa.sym.stress-mark.primary, "stress-mark.primary", (
  "stress-mark",
))
#display-symas(ipa.sym.length-mark.long, "length-mark.long", (
  "length-mark",
))
#display-symas(ipa.sym.group-mark.major, "group-mark.major", (
  "group-mark",
))
#display-symas(ipa.sym.tc.tail.curly, "tc.tail.curly", (
  "tc.tail",
))
#display-symas(ipa.sym.tc.tail.curly.raised, "tc.tail.curly.raised", (
  "tc.tail.raised",
))

= List of available IPA diacritics <diac-guide>

The following is a comprehensive list of the diacritics implemented by #pkg.

Each entry shows to the left the diacritic mark itself, here in the font
"#fonts.text" applied to a dotted-circle placeholder
'#ipa.sym.placeholder', with the dashed lines showing the baseline and
cap-height, and the dotted lines showing the descender- and ascender-heights of 
the font.

Next to each entry's illustration is shown:
- The diacritic's IPA name in boldface.
- The symbol's use, i.e. what the diacritic signifies when applied to a symbol.
- The symbols canonical name in #pkg, which can be either used as the
  fully-qualified #inline-code[```typc ipa.diac.{NAME}(...)```] anywhere or as
  just #inline-code[```typc {NAME}(...)```]
  inside a ```typc ipa.text("...")``` expression.
  For example, if the name is given as
  #inline-code(```typc nasalized(base: symbol | str)```), you can use either
  #inline-code[```typc ipa.diac.nasalized(ipa.sym.schwa)```] or
  #inline-code[```typc ipa.text("nasalized(schwa)")```] to encode
  #highlight[#ipa.diac.nasalized(ipa.sym.schwa)].
- The diacritic's escape code, which is the Unicode codepoint for the diacritic
  surrounded by #inline-code[```typm \u{...}```].
- Aliases that can be used for the same diacritic, if any.
- A note on the diacritic's use (if any). For example, whether it is
  obsolete or deprecated.

#let display-diac(symbol, code, ipa-name, ipa-use, escape: auto) = block(
  width: 100%,
  breakable: false,
  above: auto,
  below: 0.25cm,
)[
  #if escape == auto {
    escape = "\u{" + lower(int-to-hex(str(symbol.replace(ipa.sym.placeholder, "")).to-unicode())) + "}"
  }
  #grid(columns: (1cm, 1fr), gutter: 0.25cm)[
    #rect(width: 1cm, height: 1cm, stroke: rgb("#222") + 0.25mm, radius: 0.2em)[
      #set align(center + horizon)
      #set text(size: 1.5em)
      #place(
        top + left, dx: -0.1cm, dy: 0.035cm,
        line(length: 0.9cm, stroke: (paint: rgb("#bbb"), thickness: 0.25mm, dash: "dotted"))
      )
      #place(
        top + left, dx: -0.1cm, dy: 0.15cm,
        line(length: 0.9cm, stroke: (paint: rgb("#aaa"), thickness: 0.25mm, dash: "densely-dashed"))
      )
      #place(
        top + left, dx: -0.1cm, dy: 0.5cm,
        line(length: 0.9cm, stroke: (paint: rgb("#aaa"), thickness: 0.25mm, dash: "densely-dashed"))
      )
      #place(
        top + left, dx: -0.1cm, dy: 0.64cm,
        line(length: 0.9cm, stroke: (paint: rgb("#bbb"), thickness: 0.25mm, dash: "dotted"))
      )
      #symbol
    ]
  ][
    #set par(justify: false, leading: 0.5em)
    #set align(left + top)
    #set text(size: 0.75em)
    #strong(ipa-name)
  ]
]

#include "_list-diacritics.typ"

= License

#pkg is #sym.copyright #doc.date.year() by #doc.author.split(" <").at(0).

#pkg, including its documentation and this manual, is licensed under the
*MIT License*.

The License text is as follows:

#block(stroke: 0.25mm + black, radius: 0.2em, inset: 0.5em)[
  #set text(font: fonts.code, size: 0.75em)
  Copyright #doc.date.year() #doc.author.split(" <").at(0)

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the “Software”), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
]

The source code is available from\ #link("https://github.com/thatfloflo/tyipa").

= Problems & suggestions

#pkg started out as a little experiment to learn more about Typst. There are
probably a few bugs I haven't spotted, and there will be things that could've
been done better or can be improved.

So whether you have found a bug, or you have a suggestion
for improving #pkg (including this manual!), or you have some other question or
feedback regarding #pkg, please post these to the issue tracker on the official
GitHub  repository at #link("https://github.com/thatfloflo/tyipa"). Thank you.







#set heading(numbering: "A.1", supplement: [Appendix])
#counter(heading).update(0)
#set page(columns: 1)

= Extended example: The North Wind and the Sun <extended-text-example>
Broad American English transcription of _The North Wind and the Sun_ passage from the Handbook of the International Phonetic Association (IPA, 1994, p. 44).
#example[
  ```typst
#ipa.text("eth schwa  stress-mark n o r.turned theta  stress-mark.secondary w I n d  schwa n  (theta) schwa  stress-mark s v.turned n  w schwa.hook  d I s stress-mark p j u t I n.engma  stress-mark w I tied(t esh)  w schwa z  eth schwa  stress-mark s t r.turned alpha n.engma g schwa.hook,  w epsilon n  schwa  stress-mark t r.turned ae v schwa l schwa.hook  stress-mark.secondary k e m  schwa stress-mark l alpha n.engma  stress-mark r.turned ae p t  I n  schwa  stress-mark w o r.turned m  stress-mark k l o k.")

#ipa.text("eth e  schwa stress-mark g r.turned i d  eth schwa t  eth schwa  stress-mark w wedge n  h u  stress-mark f schwa.hook s t  s schwa k stress-mark s i d schwa d  I n  stress-mark m e k I engma  eth schwa  stress-mark r.turned ae v schwa l schwa.hook  stress-mark t e k  I z  stress-mark k l o k  stress-mark.secondary alpha f  esh upsilon d  b i  k schwa n stress-mark s I d schwa.hook d  stress-mark s t r.turned alpha engma g schwa.hook  eth schwa n  eth I  stress-mark schwa eth schwa.hook .")

#ipa.text("eth epsilon n  eth schwa  stress-mark n o r.turned theta  stress-mark.secondary w I n d  stress-mark b l u  schwa z  i  stress-mark k upsilon d ,  b schwa t  eth schwa  stress-mark m o r.turned  h i  stress-mark b l u  eth schwa  stress-mark m o r.turned  stress-mark k l o s l i  d I d  eth schwa  stress-mark t r.turned v l schwa.hook  stress-mark f o l d  h I z  stress-mark k l o k  schwa stress-mark r.turned a upsilon n d  I m ;")

#ipa.text("stress-mark.secondary ae n  schwa t  stress-mark l ae s t  eth schwa  stress-mark n o r.turned eth  stress-mark.secondary w I n d  stress-mark.secondary g e v  stress-mark wedge p  eth i  schwa stress-mark t epsilon m p t .  stress-mark eth epsilon n  eth schwa  stress-mark wedge n  stress-mark esh a I n d  stress-mark.secondary a upsilon t  stress-mark w o r.turned m l i,  schwa n d  I stress-mark m i d i schwa t l i  eth schwa  stress-mark t r.turned ae v l schwa.hook  stress-mark t upsilon k  stress-mark.secondary alpha f  I z  stress-mark k l o k.")

#ipa.text("schwa n  stress-mark s o  eth schwa  stress-mark n o r.turned theta  stress-mark.secondary w I n d  w schwa z  schwa stress-mark b l a I ezh  t I  k schwa n stress-mark f epsilon s  eth schwa t  eth schwa  stress-mark s wedge n w schwa z  eth schwa  stress-mark s t r.turned alpha engma g schwa.hook  schwa v  eth schwa  stress-mark t u.")
  ```
][
#ipa.text("
  eth schwa  stress-mark n o r.turned theta  stress-mark.secondary w I n d  schwa n  (theta) schwa  stress-mark s v.turned n  w schwa.hook  d I s stress-mark p j u t I n.engma  stress-mark w I tied(t esh)  w schwa z  eth schwa  stress-mark s t r.turned alpha n.engma g schwa.hook,  w epsilon n  schwa  stress-mark t r.turned ae v schwa l schwa.hook  stress-mark.secondary k e m  schwa stress-mark l alpha n.engma  stress-mark r.turned ae p t  I n  schwa  stress-mark w o r.turned m  stress-mark k l o k.
")

#ipa.text("
  eth e  schwa stress-mark g r.turned i d  eth schwa t  eth schwa  stress-mark w wedge n  h u  stress-mark f schwa.hook s t  s schwa k stress-mark s i d schwa d  I n  stress-mark m e k I engma  eth schwa  stress-mark r.turned ae v schwa l schwa.hook  stress-mark t e k  I z  stress-mark k l o k  stress-mark.secondary alpha f  esh upsilon d  b i  k schwa n stress-mark s I d schwa.hook d  stress-mark s t r.turned alpha engma g schwa.hook  eth schwa n  eth I  stress-mark schwa eth schwa.hook .
")

#ipa.text("
  eth epsilon n  eth schwa  stress-mark n o r.turned theta  stress-mark.secondary w I n d  stress-mark b l u  schwa z  i  stress-mark k upsilon d ,  b schwa t  eth schwa  stress-mark m o r.turned  h i  stress-mark b l u  eth schwa  stress-mark m o r.turned  stress-mark k l o s l i  d I d  eth schwa  stress-mark t r.turned v l schwa.hook  stress-mark f o l d  h I z  stress-mark k l o k  schwa stress-mark r.turned a upsilon n d  I m ;
")

#ipa.text("
  stress-mark.secondary ae n  schwa t  stress-mark l ae s t  eth schwa  stress-mark n o r.turned eth  stress-mark.secondary w I n d  stress-mark.secondary g e v  stress-mark wedge p  eth i  schwa stress-mark t epsilon m p t .  stress-mark eth epsilon n  eth schwa  stress-mark wedge n  stress-mark esh a I n d  stress-mark.secondary a upsilon t  stress-mark w o r.turned m l i,  schwa n d  I stress-mark m i d i schwa t l i  eth schwa  stress-mark t r.turned ae v l schwa.hook  stress-mark t upsilon k  stress-mark.secondary alpha f  I z  stress-mark k l o k.
")

#ipa.text("
  schwa n  stress-mark s o  eth schwa  stress-mark n o r.turned theta  stress-mark.secondary w I n d  w schwa z  schwa stress-mark b l a I ezh  t I  k schwa n stress-mark f epsilon s  eth schwa t  eth schwa  stress-mark s wedge n w schwa z  eth schwa  stress-mark s t r.turned alpha engma g schwa.hook  schwa v  eth schwa  stress-mark t u.
")
]
