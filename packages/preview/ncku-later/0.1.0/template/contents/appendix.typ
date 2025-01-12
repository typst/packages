#import "../setup.typ": mainmatter-or-appendix

#show: mainmatter-or-appendix.with(mode: (mainmatter: false, appendix: true))

= this is a appendix

#lorem(100)

== test test test

#lorem(100)
