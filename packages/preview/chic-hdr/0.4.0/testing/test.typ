#import "../chic-hdr.typ": *

#set page("a6")

#set heading(numbering: "I.a.")

#show: chic.with(
    skip: (-1),
    chic-separator(1pt),
    chic-header(
        left-side: emph(
            chic-heading-name(
                level: 2,
                dir: "prev"
            )
        ),
        right-side: "Test document"
    ),
    chic-footer(
        center-side: chic-page-number()
    )
)

= Introduction

#lorem(100)

== Objectives

#lorem(50)

== Details

#lorem(150)

=== Minimal errors

#lorem(20)

=== Another considerations

#lorem(25)

= Climax

#lorem(150)

#lorem(300)