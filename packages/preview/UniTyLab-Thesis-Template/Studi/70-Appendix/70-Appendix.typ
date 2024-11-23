// Imports
#import "../../Template/config.typ": *



// Appendix Config
#set page(
  footer: context {
    set align(center)
    set text(11pt)
    [Appendix - ]
    counter(page).display("1 / 1", both: true)
})

#set heading(
  numbering: "A.1.",
  supplement: [Appendix],
)

// Reset Counter
#counter(page).update(1)
#counter(heading).update(0)

#pagebreak()

#show <appendix>: set text(size: 25pt,)

//name => text(23pt, underline[name])

#heading(
  level: 1, 
  numbering: none, 
  [#underline[Appendix]<appendix>]
) 

// ==================================================================

= MY STUFF GOES HERE!
#lorem(100)
== asdfsadfa
== asdfasdf

= asdfasdfasfd
== asdfsdfaf
== asdfasdf


