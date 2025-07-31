#import "lib.typ": *

#show: kunskap.with(
    title: "Kunskap: a report template",
    author: "Marcel Bollmann",
    date: "October 27, 2024",
    header: "Typst templates",
)

This template is mainly intended for academic documents such as reports,
assignments, course documents, and so on.  Its name, _"kunskap"_, means
_knowledge_ in Swedish.

= Feature demonstration

The default fonts are _Noto Serif_ for the body and _Source Sans_ for the
headings.  The default monospace font is _Hack_ or _Source Code Pro_.  Links
will be #link("https://www.color-name.com/hex/3282b8")[highlighted in a
steel-blue-ish hue].

1. Lists are indented.
    1. Numbered lists uses numbers (first level) and letters (second level).
        1. ...and Roman numerals for the third level.

- #lorem(5)
    - #lorem(5)
        - #lorem(5)

/ Term lists: These are also indented.  #lorem(30)

== Second-level heading

Headings are not numbered by default, since this template is intended for
shorter documents, but you can of course define a numbering:

```typst
#set heading(numbering: "1.")
```

As you can see, code blocks are also indented and have a light gray background.
The same happens for `inline raw text`.

=== Third-level heading
This level is already intended to be used as a "paragraph heading."  #lorem(15)

#pagebreak()
= Second page

After the first page, the header text will be set in a #text-muted[muted color],
with the title of the report on the right-hand side.  I typically use the
left-hand side of the header for the name of the course or some other context
for this report, but feel free to repurpose it, leave it empty, or just redefine
the header altogether:

```typst
#set page(header: {
    set text(font: "Source Sans 3", weight: "medium", fill: muted-color)
    set align(center)
    [A centered header]
})
```

== Blockquotes

#quote(block: true, attribution: [from the Henry Cary literal translation of 1897])[
  ... I seem, then, in just this little thing to be wiser than this man at
  any rate, that what I do not know I do not think I know either.
]


== Missing features

/ #emoji.crossmark Bibliography: Styling related to bibliographies is currently missing.
/ #emoji.crossmark Outline: Styling for outlines (e.g. table of contents) is currently missing.
/ #emoji.crossmark Tables: Global styling for tables is currently missing.


= Credits

This template started out by emulating the layout of course documents in
#link("https://liu.se/en/employee/marku61")[Marco Kuhlmann]'s courses at
Linköping University.  On the technical side, this template took a lot of
inspiration from #link("https://github.com/talal/ilm/blob/main/lib.typ")[the
`ilm` template], even if the design decisions may be radically different.

