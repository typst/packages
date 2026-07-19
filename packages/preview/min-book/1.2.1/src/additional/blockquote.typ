/**
== Block Quote Command

:blockquote:

Adds a block of quotation, a simple alias to `#quote(block: true)`, with a
smaller and more semantic `#quote(attribution)` option as `#blockquote(by)`.
**/
#let blockquote(by: none, ..args) = quote(block: true, attribution: by, ..args)