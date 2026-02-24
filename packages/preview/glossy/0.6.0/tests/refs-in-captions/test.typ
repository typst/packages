#import "/lib.typ": *

// Our test glossary
#show: init-glossary.with((
    ShortInHeader: "short used in header",
    ShortInCaption: "short used in caption",
    LongInHeader: "long used in header",
    LongInCaption: "long used in caption",
    BothInHeader: "both used in header",
    BothInCaption: "both used in caption",
    NormalInHeader: "unmodified use in header",
    NormalInCaption: "unmodified use in caption",
))

// Configure styling

#set page(numbering: "1")
#set page(margin: 0.5in)
#set page(height: auto)
#set text(size: 10pt)

// Outlines

#outline(title:"Table of Contents", indent: auto)
#outline(title: "List of Figures", target: figure.where(kind: image))
#block(
  height:7em,
  glossary(title: "List of Abbreviations", theme: theme-twocol)
)

#line(length: 100%)

// Doc Body

// Use all the terms in headings
#heading(level: 1, outlined: false, [Use terms in HEADERS])

=== `@ShortInHeader:short` = "@ShortInHeader:short"
=== `@LongInHeader:long` = "@LongInHeader:long"
=== `@BothInHeader:both` = "@BothInHeader:both"
=== `@NormalInHeader` = "@NormalInHeader"

#line(length: 100%)

// Use all the terms in captions
#heading(level: 1, outlined: false, [Use terms in CAPTIONS])

#figure([], caption: [`@ShortInCaption:short` = "@ShortInCaption:short"])
#figure([], caption: [`@LongInCaption:long` = "@LongInCaption:long"])
#figure([], caption: [`@BothInCaption:both` = "@BothInCaption:both"])
#figure([], caption: [`@NormalInCaption` = "@NormalInCaption"])

#line(length: 100%)

// Now use the terms in the body to see if they handle "first use" correctly
#heading(level: 1, outlined: false, [Use terms in BODY])

First `@ShortInHeader` = "@ShortInHeader".
Second `@ShortInHeader` = "@ShortInHeader"

First `@LongInHeader` = "@LongInHeader".
Second `@LongInHeader` = "@LongInHeader".

First `@BothInHeader` = "@BothInHeader".
Second `@BothInHeader` = "@BothInHeader".

First `@NormalInHeader` = "@NormalInHeader".
Second `@NormalInHeader` = "@NormalInHeader".

#v(0.5em)

First `@ShortInCaption` = "@ShortInCaption".
Second `@ShortInCaption` = "@ShortInCaption"

First `@LongInCaption` = "@LongInCaption".
Second `@LongInCaption` = "@LongInCaption".

First `@BothInCaption` = "@BothInCaption".
Second `@BothInCaption` = "@BothInCaption".

First `@NormalInCaption` = "@NormalInCaption".
Second `@NormalInCaption` = "@NormalInCaption".
