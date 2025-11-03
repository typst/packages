#import "@preview/chribel:1.0.0": chribel, callout, chribel-add-callout-template
#import "@preview/tableau-icons:0.334.1": ti-icon

#set page(flipped: true, paper: "a4")
#set text(lang: "en", region: "CH")

#let pill(content, fill) = {
  box(text(font: "Fantasque Sans Mono",content), inset: (x: 3pt), outset: (y: 3pt), fill: fill, radius: 3pt)
}

#let tytyp = (
  content: pill([content],rgb("#a6ebe6")),
  array: pill([array],rgb("#f9dfff")),
  dictionary: pill([dictionary],rgb("#f9dfff")),
  integer: pill([integer], rgb("#ffecbf")),
  datetime: pill([datetime], rgb("#b7daec")),
  color: pill([color],gradient.linear(angle: 7deg,(rgb("#7cd5ff"),0%),(rgb("#a6fbca"), 33%),(rgb("#fff37c"),66%),(rgb("#ffa49d"),100%))),
  string: pill([string],rgb("#d1ffe2")),
  length: pill([length], rgb("#ffecbf"))
)

#let default-red(value) = {
  text(0.8em)[default: #text(red, value)]
}
#let default-normal(cont) = {
  text(0.8em)[default: #cont]
}

#show: chribel.with(
  title: [Chribel Template],
  subtitle: [Template Description],
  authors: ([Joel]),
  subject: (
    short: [Typst is #box(height:0pt,ti-icon("heart-filled", fill: red,baseline: -0.8em))],
    long: none
  ),
  columns-count: 3,
  links: (text: [#box(height: 0pt,ti-icon("book-2", baseline: -0.825em))Source Code], link: "https://codeberg.org/joelvonrotz/typst-chribel-template"),
  university: [School of Typst],
  creation-date: datetime.today()
)
#metadata("Position of the Titleblock")<loc:titleblock>

#let callout-types = ("info","warning","correct","incorrect","tip", "example")

#let argument(content) = {
  show terms.item: it => context {
    set par(justify: false)
    let term = text(font: "Fantasque Sans Mono",strong(it.term))
    set par(hanging-indent: 2em)
    term
    terms.separator
    it.description
    linebreak()
  }

  set text(0.9em)
  block(
    above: 1.5em,
    below: 1.5em,
    width: 100%,
    height: auto,
    stroke: gray + 0.5pt,
    inset: (top: 8pt, rest: 6pt),
    radius: 3pt,
    {
      set align(left)
      // title block
      place(top+left, dy:  -8pt - 0.5em, dx: -2pt,
        box(fill:white, inset: (x: 2pt), outset: (y: 1pt), text( gray, "Arguments"))
      )        
      content
    }
  )
}

/* ------------------------------------------------------------------------ */

#outline()

#colbreak()

#show link: underline
#show link: set text(blue)

= How to use the template 

1. Install fonts: 
  - Atkinson Hyperlegible Next (#link("https://www.brailleinstitute.org/freefont/",text(blue,[Link])))
  - Fantasque Sans Mono (#link("https://github.com/belluzj/fantasque-sans",text(blue,[Link])))
  - Arvo (#link("https://antonkoovit.com/typefaces/arvo",text(blue,[Link])))
  - Tabler.io Icons (#link("https://tabler.io/icons",[Link]) or if you don't have the money #link("https://codeberg.org/joelvonrotz/tableau-icons/src/branch/main/fonts",[Link]))
2. Import the package
  ```typ
  #import "@preview/chribel:1.0.0": chribel, callout, // chribel-add-callout-template // if custom defined callouts is desired 
  ```

3. Then put the following block before your content to then edit or to see where the fields are all used in the document.
  ```typ
  #show: chribel.with(
    title: [`<title>`],
    subtitle: [`<subtitle>`],
    authors: ([`<authors>`]),
    subject: (
      short: [`<subject-short>`],
      long: [`<subject-long>`]
    ),
    columns-count: 3,
    links: (text: [`<link-text>`], link: "<link-href>"),
    university: [`<university>`],
    creation-date: datetime.today()
    accent-color: rgb("#2e6bba")
  )
  ```
  

#argument[
  / title: #tytyp.content #h(1fr) #default-red[none]\
     The title of the document
  / subtitle: #tytyp.content#h(1fr) #default-red[none]\
     The subtitle of the document
  / authors: #tytyp.content | #tytyp.array\(#tytyp.content)#h(1fr) #text(0.8em)[default: #text(red)[none]]\
     A single author or list of authors, which gets displayed in the #link(<loc:titleblock>)[titleblock]) on the first page.
  / subject: #tytyp.dictionary#h(1fr) #default-normal[\(#text(red)[none],#text(red)[none])]\
     If the document is for a specific subject, this dictionary  can be configured with the entries `long` and `short` (although `long` is actually not used). Use the entry `short` for everything else, if not applicable.
  / university: #tytyp.content#h(1fr) #default-red[none]\
     Name of the university or workplace
  / columns-count: #tytyp.integer#h(1fr)#default-red[2]\
     Splits the document into the given amount of columns.
  / links: #tytyp.dictionary | #tytyp.array\(#tytyp.dictionary)#h(1fr) #default-red[none]\
     A dictionary with the entries `text` and `href` to display links in the #link(<loc:titleblock>)[titleblock]). Also supports multiple links by passing an array of dictionaries. 
  / creation-date: #tytyp.datetime#h(1fr) #default-normal[#raw(lang: "typst","#datetime.today()")]\
    The date of creation of the document, which will be displayed in the left footer side.
  / accent-color: #tytyp.color#h(1fr)#default-normal[#raw(lang: "typst","#rgb(\"2e6bba\")")]\
    The color used for the heading underlines and link boxes in the titleblock
]

== Multiple Authors and Links

The template supports multiple authors and links, which have to be given as arrays. The authors are an array of _content_, while the links would be a dictionary array with the entries `text` for the _replacement text_ and `link` for the hyperlink itself.



#callout(type: "example")[



```typ
title: [Template],
subtitle: [Summary Template for Typst],
authors: (
  [The author], [The other author], [Some funny author]
),
links: (
  (text: [Source Code], link: "https://codeberg.org/"),
  (text: [Search Engine], link: "https://duckduckgo.com/"),
  (text: [Touch Grass], link: "https://www.touchgrasss.com/")
)
```

*Result*:
#v(-0.5em)
#box(stroke: (paint: gray, dash: "dotted"))[
  #image("result_multiple.png")

]
]


  


== Callout



The template includes some simple, minimal callouts to put emphasis on some content. To create one, `#callout` with the following parameters can be used.



#callout(type: "info")[
  This callout is created using following snippet
  ```typ
  #callout(type: "info")[This callout is created using following command]
  ```
]

```typ
#callout(
  type: "info",
  title: none,
  width: 100%,
  height: auto,
  icon: auto,
  paint: none,
  content
)
```

#argument[
  / type: #tytyp.string#h(1fr)#default-red["info"]\
    Possible values are #callout-types.map(x =>text(rgb("#228B22"),raw("\"" + x + "\""))).join([, ]). If a different string is given, a "invalid" callout box is given, which is just gray and has a question mark as an icon.
  / title: #tytyp.content#h(1fr)#default-red[none]\
    The title of the callout block.\ `none`: the title for the given `type` is used. 
  / width: #tytyp.length#h(1fr)#default-red[100%]\
    Width of the callout box. When smaller than the maximum width, the box is automatically centered.
  / height: #tytyp.length#h(1fr)#default-red[auto]\
    Height of the callout box. Recommended to leave at `auto`.
  / icon: #tytyp.string#h(1fr)#default-red[auto]\
    The icon, which gets displayed next to the callout title. The name can be taken from #link("https://tabler.io/icons")[tabler.io/icons].\ `auto` uses the assigned icon of the given `type`.\ `none` disables the icon.
  / paint: #tytyp.color#h(1fr)#default-red[none]\
    Overwrite the defaulted color of the callout box and title color.\ `none` uses assigned colors of the given `type`.
]




=== Language Context

The provided callouts adapt their default titles based on the document language. So far only German (`de`) and English (`en`) are supported and shown below:

#columns(2)[

  ```typ
  #set text(lang: "en")
  ```

  #for typ in callout-types {
    callout(type: typ)[]
  }
  
  #colbreak()
  
  ```typ
  #set text(lang: "de")
  ```

  #set text(lang: "de")

  #for typ in callout-types {
    callout(type: typ)[]
  }
]

== Invalid Callout Type

As mentioned in before, passing a callout type not in the valid list generates an _invalid callout_. It's just a grayed out callout. Title is also language specific!

#callout(type:"blabla")[
  ```typ
  #callout(type:"blabla")[]
  ```
]

== Adding Callout Styles

It's also possible to add new callout styles in your template if needed:

#chribel-add-callout-template("dog", (
  color: rgb("#7c5735"),
  icon: "dog",
  placeholder: "Hello World"
))

```typ
#import "@preview/chribel:1.0.0": chribel, callout, chribel-add-callout-template

#chribel-add-callout-template("dog", ( color: rgb("#7c5735"), icon: "dog", placeholder: "Hello World"))
```

Which then can be used for the new callout!

#callout(type: "dog")[
  Hello World
]




== Additional snippets this document uses

=== Highlight Links

```typ
#show link: underline
#show link: set text(blue)
```

=== Arguments Box

```typ
#let argument(content) = {
  show terms.item: it => context {
    set par(justify: false)
    let term = text(font: "Fantasque Sans Mono",strong(it.term))
    set par(hanging-indent: 2em)
    term
    terms.separator
    it.description
    linebreak()
  }

  set text(0.9em)
  block(
    above: 1.5em,
    below: 1.5em,
    width: 100%,
    height: auto,
    stroke: gray + 0.5pt,
    inset: (top: 8pt, rest: 6pt),
    radius: 3pt,
    {
      set align(left)
      // title block
      place(top+left, dy:  -8pt - 0.5em, dx: -2pt,
        box(fill:white, inset: (x: 2pt), outset: (y: 1pt), text( gray, "Arguments"))
      )        
      content
    }
  )
}
```