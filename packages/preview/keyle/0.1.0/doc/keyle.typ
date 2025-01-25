#import "@preview/mantys:0.1.4": *
// Vendored because of https://github.com/jneug/typst-mantys/pull/20
#let cmdref(name) = {
  link(cmd-label(name), cmd-(name))
}
// End Vendored

#import "../src/keyle.typ"

#let lib-name = package[keyle]

#show: mantys.with(..toml("../typst.toml"), date: datetime.today(), examples-scope: (keyle: keyle))
#show link: underline

// end of preamble

= About

#lib-name is a library that allows you to create HTML `<kbd>` like keyboard shorts simple and easy.

The name, `keyle`, is a combination of `key` and `style`.

This project is inspired by #link("http://github.com/auth0/kbd")[auth0/kbd] and #link("https://github.com/dogezen/badgery")[dogezen/badgery].
Send them respect!

#v(2em)

#keyle.kbd-example
#keyle.kbd-mac-example
#keyle.kbd-com-example

#v(2em)
#keyle.kbd-set-style(keyle.kbd-styles.deep-blue)
#keyle.kbd-example

#v(2em)
#keyle.kbd-set-style(keyle.kbd-styles.type-writer)
#keyle.kbd-example

= Usage

#lib-name is imported using
#codesnippet[```typ
  #import "@preview/keyle:0.1.0"
```]

Basic usage is as follows, see #cmdref("kbd") for more details:

#keyle.kbd-set-style(keyle.kbd-styles.standard)

#example(```typst
  #keyle.kbd("Ctrl", "C")
```)

Also you can change the style of the keyboard. See #cmdref("kbd-set-style") for more details.

#example(```typst
  #keyle.kbd-set-style("deep-blue")
  #keyle.kbd("Alt")
  #keyle.kbd-set-style("type-writer")
  #keyle.kbd("Enter")
  #keyle.kbd-set-style("standard")
```)

You can also use the constants `mac-key` and `com-key` to get the key names for Mac and Windows/Linux respectively.

#example(```typst
  #keyle.kbd(keyle.mac-key.control, keyle.mac-key.shift, "A")
```)

== Available constants

=== `kbd-styles`

Use `kbd-styles` to get available styles.

#example(```typ
  #keyle.kbd-styles
```)

=== `mac-key` and `com-key`

Use `mac-key` and `com-key` to get the key names for Mac and Windows/Linux respectively.

#example(```typ
  #keyle.mac-key
```)

#example(```typ
  #keyle.com-key
```)

= Available commands

#tidy-module(read("../src/keyle.typ"), name: "keyle", include-example-scope: true)
