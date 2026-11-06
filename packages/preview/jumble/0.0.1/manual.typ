#import "@preview/tidy:0.4.0"
#import "src/lib.typ"
#import "gallery/readme_banner.typ" as banner

#set document(
  title: "Jumble v" + str(lib.version) + " manual",
  author: "LordBaryhobal"
)
#set text(font: "Source Sans 3")
#set page(
  header: [
    jumble #sym.dash.em v#lib.version
  ],
  footer: context {
    if counter(page).get().first() != 1 {
      align(center, counter(page).display("1 / 1", both: true))
    }
  }
)
#set heading(numbering: (..num) => if num.pos().len() < 4 {
  numbering("1.1", ..num)
})

#let code-block(code) = {
  let txt = code.text
  txt = txt.replace("$version", str(lib.version))
  return box(
    raw(
      txt,
      lang: code.lang,
      block: true
    ),
    fill: luma(95%),
    inset: 1em,
    radius: 0.5em,
    stroke: luma(80%) + 0.5pt
  )
}

#align(center)[
  #v(1cm)
  #text(size: 2em)[
    *#banner.txt*
  ]

  #text(size: 1.5em)[
    #banner.colorize-hex(banner.cipher)
  ]
  
  #v(0.5cm)

  _by LordBaryhobal_

  #v(3cm)

  #text(
    size: 1.8em
  )[
    *Manual*
  ]

]

#v(1fr)

#box(
  width: 100%,
  stroke: black,
  inset: 1em,
  outline(
    indent: 1em,
    depth: 2
  )
)

#pagebreak(weak: true)

= Introduction

This package provides several common hashing algorithms and other related functions. All functions are directly available in the package's namespace (i.e. no need to import sub-modules).

To use it, you can simply import the package as a whole:\
#pad(left: 1em, code-block(```typ
#import "@preview/jumble:$version"
...
#jumble.md5(msg)
```))
or import specific functions (or all):\
#pad(left: 1em, code-block(```typ
#import "@preview/jumble:$version": md5
...
#md5(msg)
```))

#pagebreak(weak: true)

= Reference

#let mod = tidy.parse-module.with(
  scope: (jumble: lib),
  preamble: "#import jumble: *;"
)

#let sha-doc = mod(
  read("src/sha.typ"),
  name: "SHA"
)
#tidy.show-module(sha-doc)

#pagebreak(weak: true)

#let md-doc = mod(
  read("src/md.typ"),
  name: "MD"
)
#tidy.show-module(md-doc)

#pagebreak(weak: true)

#let misc-doc = mod(
  read("src/misc.typ"),
  name: "misc"
)
#tidy.show-module(misc-doc)

#pagebreak(weak: true)

#let base-doc = mod(
  read("src/base.typ"),
  name: "base"
)
#tidy.show-module(base-doc)

#pagebreak(weak: true)

#let utils-doc = mod(
  read("src/utils.typ"),
  name: "utils"
)
#tidy.show-module(utils-doc)