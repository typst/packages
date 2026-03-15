#import "@preview/chribel:1.1.1": callout, chribel, chribel-add-callout-template

#import "@preview/tableau-icons:0.334.1": ti-icon

#set page(flipped: true, paper: "a4")
#set text(lang: "en", region: "CH")

#let pill(content, fill) = {
  box(text(font: "Fantasque Sans Mono", content), inset: (x: 3pt), outset: (y: 3pt), fill: fill, radius: 3pt)
}


#set list(marker: text(blue, $arrow.r.hook$))

#let tytyp = (
  content: pill([content], rgb("#a6ebe6")),
  array: pill([array], rgb("#f9dfff")),
  dictionary: pill([dictionary], rgb("#f9dfff")),
  integer: pill([integer], rgb("#ffecbf")),
  datetime: pill([datetime], rgb("#b7daec")),
  color: pill([color], gradient.linear(
    angle: 7deg,
    (rgb("#7cd5ff"), 0%),
    (rgb("#a6fbca"), 33%),
    (rgb("#fff37c"), 66%),
    (rgb("#ffa49d"), 100%),
  )),
  string: pill([string], rgb("#d1ffe2")),
  length: pill([length], rgb("#ffecbf")),
  function: pill([function], rgb("#d1d4fd")),
)

#let default-red(value) = {
  text(0.8em)[default: #text(red, value)]
}
#let default-normal(cont) = {
  text(0.8em)[default: #cont]
}

#let version = "1.1.1"

#show: chribel.with(
  title: [Chribel Template],
  subtitle: [Template Description v#version],
  authors: [Joel],
  subject: (
    short: [Typst is #box(height: 0pt, ti-icon("heart-filled", fill: red, baseline: -0.8em))],
    long: none,
  ),
  columns-count: 3,
  links: (
    text: [#box(height: 0pt, ti-icon("book-2", baseline: -0.825em))Source Code],
    link: "https://codeberg.org/joelvonrotz/typst-chribel-template",
  ),
  university: [School of Typst],
  creation-date: datetime.today(),
)
#metadata("Position of the Titleblock")<loc:titleblock>

#show raw: set text(font: "Fantasque Sans Mono", 1.0em)

#show raw.where(block: true, lang: "example"): it => context{
  set text(1em/0.8)
  show grid: set block(sticky: true)
  block(
    stroke: gray+0.5pt, inset: 0.5em, radius: 0.8em,
    {
      raw(it.text, lang: "typst", block: true)
      
      grid(
        columns: (auto,1fr,auto,1fr,auto,), align: horizon, column-gutter: 0.25em,
        ti-icon("arrow-narrow-down-dashed", fill: gray),
        line(length: 100%, stroke: (dash: "dashed", paint: gray, thickness: 0.5pt)),
        text(gray, 0.8em, [Output]),
        line(length: 100%, stroke: (dash: "dashed", paint: gray, thickness: 0.5pt)),
        ti-icon("arrow-narrow-down-dashed", fill: gray),
      )
      v(-0.5em)

      eval(it.text, mode: "markup", scope: (
        chribel-add-callout-template: chribel-add-callout-template,
        callout: callout,
        ti-icon: ti-icon
      ))
    }
  )
}



#let callout-types = ("info", "warning", "important", "caution", "tip", "correct", "incorrect", "example")

#let argument(content) = {
  show terms.item: it => context {
    set par(justify: false)
    let term = text(font: "Fantasque Sans Mono", strong(it.term))
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
      place(top + left, dy: -8pt - 0.5em, dx: -2pt, box(fill: white, inset: (x: 2pt), outset: (y: 1pt), text(
        gray,
        "Arguments",
      )))
      content
    },
  )
}

/* ------------------------------------------------------------------------ */

#outline()

#colbreak()

#show link: underline.with(offset: 0.15em)
#show link: set text(blue)

= How to use the template

1. Install fonts:
  - Atkinson Hyperlegible Next (#link("https://www.brailleinstitute.org/freefont/", text(blue, [Link])))
  - Fantasque Sans Mono (#link("https://github.com/belluzj/fantasque-sans", text(blue, [Link])))
  - Arvo (#link("https://antonkoovit.com/typefaces/arvo", text(blue, [Link])))
  - Tabler.io Icons (#link("https://tabler.io/icons", [Link]) or if you don't have the money #link("https://codeberg.org/joelvonrotz/tableau-icons/src/branch/main/fonts", [Link]))
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
  / creation-date: #tytyp.datetime#h(1fr) #default-normal[#raw(lang: "typst", "#datetime.today()")]\
    The date of creation of the document, which will be displayed in the left footer side.
  / accent-color: #tytyp.color#h(1fr)#default-normal[#raw(lang: "typst", "#rgb(\"2e6bba\")")]\
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
  style: "minimal", type: "info",
  title:  none,     width:  100%,
  height: auto,     icon:   auto,
  paint:  none,
  content
)
```

#argument[
  / style: #tytyp.string | #tytyp.function#h(1fr)#default-red["minimal"]\
    Determines how the callout is rendered. Valid values are #(`"minimal"`, `"quarto"`, `"compact"`).map(x => raw(x.text, lang: "typc")).join([, ]). If a function in the shape of
    #raw("(title,icon,content,paint,height,width)=>{}", lang: "typc")\
    is given, this function is instead called!
  / type: #tytyp.string#h(1fr)#default-red["info"]\
    Possible values are #callout-types.map(x => text(rgb("#228B22"), raw("\"" + x + "\""))).join([, ]). If a different string is given, a "invalid" callout box is given, which is just gray and has a question mark as an icon.
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


#colbreak()

=== Language Context

The provided callouts adapt their default titles based on the document language. So far only German (`de`) and English (`en`) are supported and shown below:

#columns(2)[

  ```typ
  #set text(lang: "en")
  ```

  #for typ in callout-types.slice(0, 5) {
    callout(type: typ)[] + v(-0.25em)
  }

  #colbreak()
  ```typ
  #set text(lang: "de")
  ```

  #set text(lang: "de")

  #for typ in callout-types.slice(0, 5) {
    callout(type: typ)[] + v(-0.25em)
  }
]

=== Callout Styles

By default, the style #raw(lang: "typc", `"minimal"`.text) is used. There is two other predefined styles called #raw(lang: "typc", `"quarto"`.text) and #raw(lang: "typc", `"compact"`.text). The first one is a replication of the #link("https://quarto.org/docs/authoring/callouts.html")[Quarto Callouts], the latter is a inline based callout.


- Using style #raw(`"quarto"`.text, lang: "typc"):

#grid(
  columns: (1fr,1fr),
  column-gutter: 1em,
  row-gutter: 1em,
  ..for typ in callout-types {
    (callout(type: typ, style: "quarto", lorem(4)),)
  },
) 

- Using style #raw(`"compact"`.text, lang: "typc")

#stack( spacing: 1em,
  ..for typ in callout-types {
  (callout(type: typ, style: "compact", lorem(4)),)
})

=== Custom Callouts <sec:customcallouts>

If you don't like the provided styles, you can create your own ones. Define a function (#raw(lang: "typst",`#let func(..)`.text)) or inline function (#raw(lang: "typc", `(..) => {}`.text)) similar to the example below. Then pass a function in the shape of...

#align(center, raw(lang: "typc", `(title, icon, content, paint, height, width) => {}`.text))

...to the `style`-parameter of the #raw(`#callout(..)`.text, lang: "typ") function.

#callout(style: "compact", type: "caution")[The parameter `icon` returns the converted icon (not the label, but the actual icon)]


```example
#let custom-callout(title,icon,content,paint,
    height,width) = { box(stroke: paint, inset: 0.25em, fill: white, radius: 0.5em,[#strong[#icon#title] #content])
  }

#callout(style: custom-callout)[Hello World]
```

#callout(title: [Set default styling], type: "tip")[
  If you want to replace the default styling (#raw(lang: "typc", `"minimal"`.text)) with your own one, overwrite the #raw(lang: "typst", `#callout(..)`.text) function:

  ```example
  #callout[Hello]

  #let custom-callout(title,icon,content,paint,
    height,width) = { box(stroke: paint, inset: 0.25em, fill: white, radius: 0.5em,[#strong[#icon#title] #content])
  }

  #let callout = callout.with(style: custom-callout)

  #callout[Hello]
  ```
]

== Invalid Callout Type

As mentioned before, passing a callout type not in the type list generates an _"invalid" callout_. It's just a grayed out callout and a respective title is set. The title is also language specific!

#callout(type: "blabla")[
  ```typ
  #callout(type:"blabla")[]
  ```
]

#colbreak()

== Adding Callout Types

It's also possible to add new callout styles in your template if needed. For this additionally import the #raw(lang: "typc","chribel-add-callout-template()") function:

```typ
#import "@preview/chribel:1.0.0": chribel, callout, chribel-add-callout-template
```

And then you can add the configuration function anywhere in the function (but set styles *cannot* be used before it!).

```typ
#chribel-add-callout-template(
  name,
  config : (
    color:  ..,
    icon: ..,
    placeholder: ..
  )
)
```

#argument[
  / name: #tytyp.string\
    The name of the new callout type. This will be used in the `callout` function to access the type.
  / config: #tytyp.string\
    The callout configuration, which gets applied to the 
  #block(inset: (left: 2em),[
  / color: #tytyp.color\
    The accent color for the callout stroke, background color and icon color.
  / icon: #tytyp.string\
    The icon label name of the desired #link("https://tabler.io/icons")[tabler.io icons]. Don't forget to add `-filled` if you want the filled variant of the icon.
  / placeholder: #tytyp.content\
    The title of the callout. The name _Placeholder_ is used, since you can overwrite the title and this content is used if no custom title is set.
  ])
]

Following page shows an example:



```example
#chribel-add-callout-template("dog", (
  color: rgb("#7c5735"),
  icon: "dog",
  placeholder: "Hello World",
))

#callout(type: "dog")[
  Hello World
]
```

#set heading(outlined: false)
== Additional used snippets

Some snippets used for this manual!

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
    above: 1.5em, below: 1.5em,
    width: 100%, height: auto,
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

#set heading(outlined: true)
#colbreak()
= Changelog

== 1.1.1

- Reimplemented the #raw(lang: "typc",`"compact"`.text) styling to work inside other callouts.
- Added current version number to this manual
- Replaced `func` with extended `style` parameter $->$ allows now selecting custom function or predefined styles.

== 1.1.0

- Expanded `#callout` functions with support for custom render functions (via parameter `func: ..`) 
- Added `style` parameter to `#callout` with three options: #(`"minimal"`, `"quarto"`, `"compact"`).map(x => raw(x.text, lang: "typc")).join([, ])
- Added callou type #(`"caution"`, `"important"`).map(x => raw(x.text, lang: "typc")).join([ and ]).
- Removed `sticky` parameter from raw blocks

== 1.0.0

- initial release -- added functions `#callout`\ `#chribel`, `#chribel-add-callout-template`
