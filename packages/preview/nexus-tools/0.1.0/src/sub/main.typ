/**
= Main
```typ
#import "@preview/nexus-tools:0.1.0"
```

== Custom Defaults
:default:

Substitutes Typst defaults for custom ones, allowing to set new defaults that
can be easily changed using `#set` rules; it works by mapping custom defaults to
the originals, replacing them when in use.
**/
#let default(
  when: false, /// <- boolean
    /// Condition to apply custom default. |
  value: (:), /// <- dictionary | any
    /// Custom default value (condition is `true`). |
  otherwise: (:), /// <- dictionary | any
    /// Alternative value when default is not being used (condition is `false`). |
  disabled, /// <- boolean
    /// Disable custom default when `true`. |
) = {
  if disabled {return}
  /**
  This command is commonly used inside `#set` rules.
  **/
  if when {return value}
  else {return otherwise}
}


/**
== Content to String
:content2str:
Converts content to string.

data <- content
  Content data
**/
#let content2str(data) = {
  if type(data) != content {data = [#data]}
  
  if data.has("text") {
    if type(data.text) == str {data.text}
    else {content2str(data.text)}
  }
  else if data.has("children") {data.children.map(content2str).join("")}
  else if data.has("body") {content2str(data.body)}
  else if data == [ ] {" "}
  else if data == linebreak() {"\n"}
  else if data == parbreak() {"\n\n"}
}