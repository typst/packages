#import "@local/latex-lookalike:0.1.0"

#set heading(numbering: "1.1")

// Style outline as LaTeX "Table of contents".
#show: latex-lookalike.style-outline

#outline()

= foo

#lorem(10)

== bar

#lorem(10)

== baz

#lorem(10)

=== hoge

#lorem(10)

=== fuga

#lorem(10)

= qux

#lorem(10)

== fob

#lorem(10)
