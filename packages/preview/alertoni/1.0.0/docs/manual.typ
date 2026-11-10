#import "@preview/alertoni:1.0.0"
#import "@preview/tableau-icons:0.344.0": ti-icon
#import "@preview/shadowed:0.3.0": shadow
#import "@preview/tidy:0.4.3"

#let package-name = "Alertoni"

#let typst-toml = toml("../typst.toml")

#set smartquote(
  quotes: (
    double: (sym.quote.chevron.double.l, sym.quote.chevron.double.r),
    single: (sym.quote.chevron.l, sym.quote.chevron.r),
  ),
)

#let my-link(link, body) = {
  underline(offset: 0.15em, text(blue, std.link(link, body)))
}

#show `#callout`.text: my-link(label("-callout()"), `#callout`)
#show `#new-type`.text: my-link(label("-new-type()"), `#new-type`)
#show `#set-icons`.text: my-link(label("-set-icons()"), `#set-icons`)

#show raw.where(block: true): it => {
  show `callout`.text: set text(9.5pt)
  show `new-type`.text: set text(9.5pt)
  show `set-icons`.text: set text(9.5pt)

  show `callout`.text: link(label("-callout()"), `callout`)
  show `new-type`.text: link(label("-new-type()"), `new-type`)
  show `set-icons`.text: link(label("-set-icons()"), `set-icons`)

  show `callout`.text: underline(offset: 0.2em, "callout")
  show `new-type`.text: underline.with(offset: 0.2em)
  show `set-icons`.text: underline.with(offset: 0.2em)
  it
}


/* -------------------------------------------------------------------------- */
/*                               Show/Set Rules                               */
/* -------------------------------------------------------------------------- */


#alertoni.new-type(
  name: "package",
  color: blue,
  icon: ti-icon("package"),
  placeholder: raw(package-name),
)

#let package-func(title, icon, content, paint, height, width) = {
  box(fill: paint.lighten(80%), outset: (y: 0.15em), inset: (right: 0.25em), radius: 0.2em, grid(
    columns: 2,
    align: horizon,
    gutter: 0.25em,
    text(top-edge: "bounds", bottom-edge: "bounds", white, box(
      grid(
        columns: 2,
        gutter: 0.25em,
        icon, strong(title),
      ),
      fill: paint,
      outset: (y: 0.15em),
      inset: (x: 0.15em),
      radius: 0.2em,
    )),
    content,
  ))
}


#set page(
  paper: "a4",
  margin: 2.5cm,
  footer: block(width: 100%, stroke: (top: (paint: gray, thickness: 0.5pt, dash: "dashed")), inset: (top: 0.5em), align(
    center,
    context [#counter(page).at(here()).first() #text(gray, [/]) #counter(page).final().first()],
  )),
  header: context if here().page() != 1 {
    block(width: 100%, stroke: (bottom: (paint: gray, thickness: 0.5pt, dash: "dashed")), inset: (bottom: 0.5em))[
      #alertoni.callout(
        type: "package",
        text(number-width: "tabular", raw(typst-toml.package.version)),
        style: package-func,
      )
      #h(1fr)
      _Package Documentation_
    ]
  },
)

#set text(lang: "en", region: "CH", font: ("Atkinson Hyperlegible Next", "Noto Color Emoji"), 11pt)



#show heading.where(level: 1): set text(20pt)
#show heading.where(level: 1): set block(above: 1em, below: 1em)
#show heading.where(level: 1, outlined: true): set heading(numbering: (..n) => (
  text(blue, numbering("I", ..n)) + text(gray, weight: "regular", [ \\])
))

#show heading.where(level: 2): set heading(numbering: (..n) => {
  [#text(gray, weight: "regular", numbering("I.", n.at(0)))#text(blue, numbering("1", n.at(1)))]
})

#show heading.where(level: 3): set heading(numbering: (..n) => {
  [#text(gray, weight: "regular", numbering("I.1.", ..n.pos().slice(0, 2)))#text(blue, numbering("a", ..n
      .pos()
      .slice(2, 3)))]
})



#set list(marker: text(blue, sym.bullet))

#set enum(numbering: n => box(fill: blue, outset: 2pt, radius: 0.2em, text(
  white,
  weight: "bold",
  top-edge: "bounds",
  bottom-edge: "bounds",
  number-width: "tabular",
  numbering("1.", n),
)))



#show raw: set text(font: "Fantasque Sans Mono", 9.5pt)
#show raw.where(block: false): set text(11pt)

#let my-style(title, _, body, paint, _, _) = {
  text(paint, strong[#title ]) + [#body]
}

#show raw.where(block: true, lang: "example").or(raw.where(block: true, lang: "vexample")): it => {
  show grid: set block(sticky: true)

  let inner-inset = if it.lang == "example" { 6pt } else { 6pt }
  let outer-inset = if it.lang == "example" { 3pt } else { 3pt }
  let radius = 4pt
  let spacing = if it.lang == "example" { 5pt } else { 7pt }
  let dir = if it.lang == "example" { ltr } else { ttb }

  let hide-hidden = ()
  let apply-hidden = ()

  for l in it.lines {
    if l.text.starts-with("///") {
      apply-hidden += ((text: l.text.slice(3).trim()),)
    } else if l.text.starts-with("//!") {
      hide-hidden += ((text: l.text.slice(3).trim()),)
    } else {
      hide-hidden += (l,)
      apply-hidden += (l,)
    }
  }

  let arrangement(width: 100%, height: auto) = stack(
    dir: dir,
    spacing: spacing,
    block(
      ..if it.lang == "example" { (width: width / 2 - spacing / 2, inset: (left: outer-inset)) },
      height: height,
      block(
        stroke: rgb("#e2e3e8") + 1pt,
        radius: radius,
        width: 100%,
        height: height,
        inset: inner-inset,
        {
          let lines = it.lines

          raw(hide-hidden.map(x => x.text).join("\n"), lang: "typst", block: true)
        },
      ),
    ),
    block(
      ..if it.lang == "example" { (width: width / 2 - spacing / 2) } else { (width: 100%) },
      inset: inner-inset,
      height: height,
      stroke: (paint: rgb("#e2e3e8"), thickness: 1pt, dash: "dashed"),
      radius: radius,
      {
        set text(font: "Atkinson Hyperlegible Next", 9.5pt)
        eval(apply-hidden.map(x => x.text).join("\n"), mode: "markup", scope: (
          at: alertoni,
          my-style: my-style,
          ti-icon: ti-icon,
        ))
      },
    ),
  )

  if it.lang == "example" {
    layout(size => {
      arrangement(height: measure(arrangement(width: size.width)).height)
    })
  } else {
    block(arrangement(), inset: outer-inset)
  }
}



#show divider: set align(center)
#show divider: block(above: 1cm, below: 1cm, text(
  blue,
  top-edge: "bounds",
  bottom-edge: "bounds",
)[`<`$ast.op$`>` #box(line(length: 60%, stroke: blue + 0.75pt), baseline: -0.24em) `<`$ast.op$`>`])




/* -------------------------------------------------------------------------- */
/*                                  Functions                                 */
/* -------------------------------------------------------------------------- */

#let pill(content, fill) = {
  box(text(font: "Fantasque Sans Mono", content), inset: (x: 3pt), outset: (y: 3pt), fill: fill, radius: 3pt)
}

#let tytyp = (
  content: pill([content], rgb("#a6ebe6")),
  array: pill([array], rgb("#f9dfff")),
  dictionary: pill([dictionary], rgb("#f9dfff")),
  arguments: pill([arguments], rgb("#ffdfdf")),
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

#let typst-toml = toml("../typst.toml")

#let callout-types = ("info", "warning", "important", "caution", "tip", "correct", "incorrect", "example")

#let code-block = block.with(width: 100%, inset: 0.5em, stroke: gray.lighten(50%), radius: 0.3em)


#let argument(content, prefix: none) = {
  show terms: it => pad(left: it.indent + it.hanging-indent, stack(
    ..it.children.map(item => {
      h(-it.hanging-indent)
      text(font: "Fantasque Sans Mono", if prefix == none [#strong(item.term)] else {
        assert(type(prefix) == str, message: "prefix must be a string")
        let label = ("param", prefix, item.term.text)
        [#strong(item.term) #metadata(label) #std.label(label.join(":"))]
      })
      it.separator
      item.description
    }),
    spacing: 1.2em,
  ))

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



/* -------------------------------------------------------------------------- */
/*                                   Content                                  */
/* -------------------------------------------------------------------------- */




#place(
  top + center,
  scope: "parent",
  float: true,
  {
    v(1cm)
    image("banner.svg")
  },
)
#v(2cm)

#divider()

#[
  #set heading(outlined: false)
  = About
]
#emph(package-name) is a package that introduces various callouts types with three different styles. In addition the package supports custom callout types, custom styling and switching icon sets.




#divider()

#{
  show "<package-name>": typst-toml.package.name
  show "<package-version>": typst-toml.package.version
  ```example
  //! #import "@preview/<package-name>:<package-version>" as at

  #at.callout(
    type: "important",
    title: [Kitty!],
    [
      #image("./images/little-kitty.jpg")
    ]
  )
  ```
}

#place(right, dy: 0.6em, dx: -0.5em, {
  show heading.where(level: 1): set block(above: 2em, below: 1em)
  show link: underline.with(offset: 0.15em)
  show link: set text(blue)

  text(
    0.8em,
  )[Photo by #my-link("https://unsplash.com/@kotecinho?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText")[Kote Puerto] on #my-link("https://unsplash.com/photos/white-and-gray-kitten-on-white-textile-so5nsYDOdxw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText")[Unsplash]]
})

#pagebreak()

#outline()

#pagebreak()
/* -------------------------------------------------------------------------- */
/*                                Main Content                                */
/* -------------------------------------------------------------------------- */

#show heading.where(level: 1): set block(above: 2em, below: 1em)

= Installation <sec:installation>

#set footnote(numbering: n => text(red, font: "Fantasque Sans Mono", strong[#n]))


#[
  #show `<version>`.text: typst-toml.package.version
  #show `<name>`.text: typst-toml.package.name



  1. / Install Tabler.io font:
    - Tabler.io Icons (#my-link("https://tabler.io/icons", [Webpage Link]) or #my-link("https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/dist/fonts/", [CDN JsDelivr Page])#footnote[You can build the font yourself, the building scripts are available at #my-link("https://github.com/tabler/tabler-icons", "https://github.com/tabler/tabler-icons"). Thus I believe you should have access to these files as well. *But support the icon designers if you can!*])

    #alertoni.callout(
      type: "important",
      width: auto,
    )[At default settings, this font *is required*!]

  2. / Import the package: in three different ways

    - Via Typst Universe\

      #code-block(```typ
      #import "@preview/<name>:<version>" as at
      ```)

    - Downloading or cloning the repository #raw(lang: "bash", "\"" + typst-toml.package.repository + "\"") and then including the `exports.typ` file.\

      #code-block(```typ
      #import "./path/to/typst-alertoni/exports.typ" as at
      ```)
    - Via `@local` namespace\

      #code-block(```typ
      #import "@local/<name>:<version>" as at
      ```)
]



= Usage <sec:usage>

== Callout Styles <sec:styles>

_Styles_ in the context of #emph(package-name) is how the callout look, so the drawing style. The package comes with three predefined styles and allows for user defined styles.

=== Predefined Styles <sec:styles:predefined>

The three predefined styles are #(`"minimal"`, `"compact"`, `"quarto"`).map(x => x.text).map(raw.with(lang: "typc")).join([, ]). The last style #raw(`"quarto"`.text, lang: "typc") is inspired by (aka. almost identical copy of) Quarto's #my-link("https://quarto.org/docs/authoring/callouts.html")[callout blocks].

```example
/// #set raw(lang: "typc")
#at.callout(
  style: "minimal", [Style `"minimal"`]
)
```

```example
/// #set raw(lang: "typc")
#at.callout(
  style: "quarto", [Style `"quarto"`]
)
```

```example
/// #set raw(lang: "typc")
#at.callout(
  style: "compact", [Style `"compact"`]
) -- it is also an inline style.
```


#pagebreak()

=== Creating & Using Custom Callout Styles <sec:styles:custom>

To allow for a more individual customization of the style, a custom callout style can be defined. To "assign" a custom style, a function in the shape of

#code-block(```typc
(title, icon, content, paint, height, width) => {...}
```)


is passed onto the #my-link(<-callout.style>, `style`) parameter of the `#callout` function.

```example
#let my-style(title,_,body,paint,_,_) = {
  text(paint, strong[#title ]) + [#body]
}

#at.callout(style: my-style, [
  about a new style!
])
```

#alertoni.callout(
  type: "important",
  title: [Global Configuration?],
  [
    The function is only applied to the callout function it was passed into. To "globally" set a style, see #my-link(<sec:tipstricks:global>, [Tips & Tricks -- Global Configuration]).

  ],
  width: 80%,
)

== Callout Types <sec:types>

Callout types define the kind of callouts. As with the styles, the package comes with various predefined types and allows for user defined ones to be added.

=== Predefined Types <sec:types:predefined>

#raw(
  lang: "example",
  callout-types
    .map(x => {
      (
        `#at.callout(type: "`.text
          + x
          + `",`.text
          + " " * (calc.max(..callout-types.map(x => x.len())) - x.len())
          + ` [])`.text
      )
    })
    .join("\n"),
  block: true,
)

=== Creating & Using Custom Callout Types <sec:types:custom>

To add custom callout types, the function #my-link(label("-new-type()"), `#new-type()`) is used. Calling this function places the configuration as a state at the call location, meaning you won't be able to use the type BEFORE the call. I recommend setting the types before the overall content!

Each callout type has an "ID" associated to a couple of configurations: `color`, `icon` and `placeholder`. The term _placeholder_ is used, because the title of the callout is using a placeholder title when no title is specified!

Now let's create a callout type #raw(`"pizza"`.text, lang: "typc"):

#code-block(```typst
#at.new-type(
  name: "pizza",
  color: red,
  icon: [🍕],
  placeholder: "Pizza Time!"
)
```)

#let type-name = "pizza"
#let paint = red
#let icon = [🍕]
#let placeholder = "Pizza Time!"

#alertoni.new-type(
  name: "pizza",
  color: red,
  icon: [🍕],
  placeholder: "Pizza Time!",
)


With the type added, you can now create callouts and use #raw(`"pizza"`.text, lang: "typc") as type to use it.

```example
#at.callout(type: "pizza")[#lorem(10)]
```

#alertoni.callout(type: "important", width: auto, [
  `#new-type` will overwrite existing entries.
])

== Language Context <sec:types:language>

The predefined types and, if configured, user defined types can have language specific titles. These get automatically selected when setting the respective language via #raw(`#set text(lang: "..."))`.text, lang: "typst").

#alertoni.callout(
  type: "caution",
  width: auto,
  [If no title is found, `#callout` will throw an error, unless a #box(stroke: gray + 0.5pt, outset: (y: 0.3em), inset: (x: 0.2em), radius: 0.2em, `fallback`) entry exists!],
)

#code-block({
  show "cal!lout": "cal" + sym.zwj + "lout"
  ```typst
  #let type-name = "pizza"
  #let paint = red
  #let icon = [🍕]
  #let placeholder = (
    fallback: "Pizza Time?" // required if other languages besides the ones below are used
    en: "Pizza Time!",
    de: "Pizza Zeit!"
  )

  #at.new-type(
    name: type-name,
    color: paint,
    icon: icon,
    placeholder: placeholder
  )
  ```
})

#let type-name = "pizza"
#let paint = red
#let icon = [🍕]
#let placeholder = (
  en: "Pizza Time!",
  de: "Pizza Zeit!",
  fallback: "Pizza Time?",
)

#alertoni.new-type(
  name: type-name,
  color: paint,
  icon: icon,
  placeholder: placeholder,
)

With the type added, you can now create callouts and use #raw(`"pizza"`.text, lang: "typc") as type to use it. Since the placeholder has translations, the callout function will try to select the respective one.

#colbreak()

```example
#set text(lang: "en")
#at.callout(type: "pizza")[#lorem(6)]

#set text(lang: "de")
#at.callout(type: "pizza", [#lorem(6)])

#set text(lang: "es")
#at.callout(type: "pizza", lorem(6))
```


== Modifying the Icon Set  <sec:iconset>

Per default #emph(package-name) uses the package #my-link("https://typst.app/universe/package/tableau-icons/")[`tableau-icons`] for drawing the icons in the callout. This is internally done via a lookup table (LUT), where each style is assigned an icon as `content`. This of course can be changed via the `#set-icons` function.

```example
#let icon-set = (
  "info": [*i*],
  "warning": [*!*],
  "important": [*!!!*],
)

#at.set-icons(icon-set)

#at.callout(type: "info", [])
#at.callout(type: "warning", [])
#at.callout(type: "important", [])
```

#alertoni.set-icons(auto)

#alertoni.callout(
  type: "info",
  width: auto,
  [
    When setting icons, existing entries in the internal dictionary\ are updated and new entries are appended.
  ],
)

#let icon-set = (
  "info": [*i*],
  "warning": [*!*],
  "important": [*!!!*],
)
#alertoni.set-icons(icon-set)

The `#set-icons` function also supports reseting the icons back to default by passing #raw("auto", lang: "typc"). This also clears #text(red, [all]) user defined icons.

```example
#at.callout(type: "info", [])
#at.set-icons(auto)
#at.callout(type: "info", [])
```

#pagebreak()

= Tips & Tricks  <sec:tipstricks>

== Global Configuration <sec:tipstricks:global>

To globally change the callout style, default type, you can overload the `#callout` function using #raw(`#at.callout.with(..)`.text, lang: "typst"):

```example
#let quarto-tip = at.callout.with(style: "quarto", type: "tip")

#quarto-tip[Hello!]
```

#alertoni.callout(type: "caution", width: 80%)[
  If you have a multi file project, place it in a "preamble" file, that gets imported in every subdocument that requires callouts.
]

#alertoni.callout(type: "important", width: 80%)[
  The reason for this kind of implementation is, that I don't want to use custom type packages like #my-link("https://typst.app/universe/package/elembic/", `elembic`) (for now), as I'm waiting for Typst to officially support custom types.


  It's not the best solution, but a useable workaround until Typst supports custom types. Once these are added, the callout configuration will be configurable via (hopefully):

  #code-block(```typst
  #set at.callout(style: my-style, type: "tip")
  ```)
]


== Writing Shortcut <sec:tipstricks:writing>

To make writing a bit easier or flow nicer, the `#callout` function has a little trick up its sleeve using positonal arguments. By passing an additional positional argument, the first one will be used for the title and the second one as body.

#align(center, table(
  stroke: 0.5pt,
  align: (center, left),
  columns: 2,
  table.header(strong[$\#$ of `pos()`], strong[Effect]),
  [$1$], [`[0]`: Body of callout],
  [$2$], [`[0]`: Title of callout\ `[1]`: Body of callout],
  [$"otherwise"$], [Error is thrown],
))

The argument switchup was done to make it easier to read the code line. When reading callouts, usually title is read first, then body.

```example
#at.callout[No shorthand version]

#at.callout[Shorthand][Version!]
```

#pagebreak()

== Function Shortcuts <sec:tipstricks:function>

Another handy use of #raw(`#at.callout.with(..)`.text, lang: "typst") is to create functions for each callout type. For a #raw(`#info`.text, lang: "typst") callout function, you'd declare

```example
#let info = at.callout.with(type:"info")

#info(title: [Lorem Ipsum!])[#lorem(10)]
```

Function shortcuts were not implemented in the package, as it might conflict with functions in your document. But to make life a bit easier, below are all the predefined types as functions you can copy into your project!

#code-block(inset: 1em, raw(
  block: true,
  lang: "typst",
  `#import "@preview/alertoni:1.0.0" as at`.text
    + "\n\n"
    + callout-types
      .map(t => {
        str(`#let <type> = at.callout.with(type: "<type>")`.text.replace("<type>", t))
      })
      .join("\n"),
))

#pagebreak()

= API Reference <sec:apiref>

#alertoni.set-icons(auto) // just so docs are clean of any modifications!
#let docs = tidy.parse-module(read("../src/callouts.typ"), scope: (
  at: alertoni,
  tytyp: tytyp,
  code-block: code-block,
  burger-image: image.with("./images/burger.png"),
))

#context outline(target: heading.where(level: 2).after(here()), title: none)
#v(2em)

#tidy.show-module(docs, style: tidy.styles.default, first-heading-level: 1, show-outline: false)


= Changelog


#show heading.where(level: 2): set heading(numbering: none, outlined: false)
#show heading.where(level: 2): it => {
  show regex(`\d\.\d\.\d`.text): set text(blue)
  show regex(`\\`.text): set text(gray, weight: "regular")

  it
}

== 1.0.0 \\ Initial Release

- Added functions `#callout`, `#new-type`, `#set-icons` with documentation!
