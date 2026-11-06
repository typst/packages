#import "../setup.typ": mainmatter-or-appendix

#show: mainmatter-or-appendix.with(mode: (mainmatter: false, appendix: true))

= This is first appendix

#lorem(100)

== this is a subsection of first appendix

#lorem(1000)

= This is second appendix

#lorem(100)

== This is a subsection in second appendix

#lorem(100)
