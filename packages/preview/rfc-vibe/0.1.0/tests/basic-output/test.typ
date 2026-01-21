#import "/lib.typ": *

#set page(paper: "us-letter", margin: 0.75in)
#set par(justify: true)
#set text(size: 10pt)

= `rfc-vibe` package

This package makes it easy to use the exact keywords, boilerplate, and
definitions provided by #bcp14, #rfc2119, and #rfc8174.

== Keywords

Use the keywords according to these examples. Note that the *`-quoted`* versions
are only for the unique situation when you want the keywords included in
quotation marks. This is not necessary in normal usage.

#grid(
  columns: (auto, 1fr, auto),

  table(
    columns: 2,
    [*`#must`            *], [#must],
    [*`#must-not`        *], [#must-not],
    [*`#required`        *], [#required],
    [*`#shall`           *], [#shall],
    [*`#shall-not`       *], [#shall-not],
    [*`#should`          *], [#should],
    [*`#should-not`      *], [#should-not],
    [*`#recommended`     *], [#recommended],
    [*`#not-recommended` *], [#not-recommended],
    [*`#may`             *], [#may],
    [*`#optional`        *], [#optional],
  ),
  [],
  table(
    columns: 2,
    [*`#must-quoted`            *], [#must-quoted],
    [*`#must-not-quoted`        *], [#must-not-quoted],
    [*`#required-quoted`        *], [#required-quoted],
    [*`#shall-quoted`           *], [#shall-quoted],
    [*`#shall-not-quoted`       *], [#shall-not-quoted],
    [*`#should-quoted`          *], [#should-quoted],
    [*`#should-not-quoted`      *], [#should-not-quoted],
    [*`#recommended-quoted`     *], [#recommended-quoted],
    [*`#not-recommended-quoted` *], [#not-recommended-quoted],
    [*`#may-quoted`             *], [#may-quoted],
    [*`#optional-quoted`        *], [#optional-quoted],
  ),
)

== Boilerplate

According to #rfc8174, "authors who follow these guidelines should incorporate
this phrase near the beginning of their document." Do that with *`#rfc-keyword-boilerplate`*:

#pad(left: 1em, rfc-keyword-boilerplate)

== Definitions

Although not required (and maybe discouraged), you can include the definitions of the individual keywords in your document individually with
*`#rfc-keyword-must-definition`*,
*`#rfc-keyword-must-not-definition`*,
*`#rfc-keyword-should-definition`*,
*`#rfc-keyword-should-not-definition`*, or
*`#rfc-keyword-may-definition`*.

Or, you can include definitions of all keywords with *`#rfc-keyword-definitions`*:
#pad(left: 1em, rfc-keyword-definitions)
