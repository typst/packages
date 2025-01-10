#import "../setup.typ": mainmatter_or_appendix

#show: mainmatter_or_appendix.with(mode: (mainmatter: false, appendix: true))

= this is a appendix

#lorem(100)

== test test test

#lorem(100)
