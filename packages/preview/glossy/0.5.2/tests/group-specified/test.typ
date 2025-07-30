#import "/lib.typ": *

#show: init-glossary.with(json("abbreviations.json"))

Reference: @pbr, @zbuffer


#let t(g) = [
  #line(length: 100%)
  *TESTING:* `#glossary(groups: ` #repr(g) `)`
  #glossary(groups: g)
]

#t("abbreviations")                   // "string" : str
#t(("abbreviations"))                 // ("string") : str
#t(("abbreviations",))                // ("string",) : array(str)
#t(("abbreviations","abbreviations")) // ("string","string",) : array(str)

#pagebreak(weak: true)

#t("")                                // empty string should be the empty group
#t((""))                              // empty string should be the empty group
#t(("",))                             // empty string should be the empty group
#t(("",""))                           // empty string should be the empty group

#pagebreak(weak: true)

#t(none)                              // none should be all groups
#t((none))                            // none should be all groups

#pagebreak(weak: true)

#t(("abbreviations",none))            // try to get both groups
