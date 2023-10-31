#import "@preview/tidy:0.1.0"
#import "utils.typ": *
#import "../marginalia.typ"
#let module = tidy.parse-module(read("../marginalia.typ"), scope: (marginalia: marginalia))

#show raw.where(lang: "standalone"): text => {
  standalone-margin-note-example(raw(text.text, lang: "typ"))
}

#show raw.where(lang: "standalone-ttb"): text => {
  standalone-margin-note-example(raw(text.text, lang: "typ"), direction: ttb)
}

#set page(numbering: "1/1", paper: "a4")

= Marginalia manual

Version 0.2

== Functions

#show-module-fn(module, "margin-note-defaults")

#line(length: 100%)

#show-module-fn(module, "set-margin-note-defaults")

#line(length: 100%)

#show-module-fn(module, "margin-note")

== Example

```standalone-ttb
= Document Title
#lorem(15)#margin-note(side: left)[Left note]
#lorem(10)#margin-note[Right note]
#lorem(5)#margin-note(stroke: green)[Green stroke, auto-offset]
#lorem(10)#margin-note(side: left, dy: -50pt)[Manual offset]
#lorem(10)
```