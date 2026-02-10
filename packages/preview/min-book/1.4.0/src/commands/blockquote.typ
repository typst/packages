/**
== Block Quote Command
:blockquote:
A simple alias for `#quote(block: true)` with a shorter attribution option.
**/
#let blockquote(by: none, ..args) = quote(block: true, attribution: by, ..args)