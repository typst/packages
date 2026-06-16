#import  "/template.typ": tudelftbook

// load page settings, header style etc
#show: tudelftbook

// check if the --forprint= was added as an input variable
#let forprint = "forprint" in sys.inputs

// configure metadata
#let metadata = toml("metadata.toml")
#set document(
    title: metadata.title,
    description: metadata.summary,
    author: metadata.author.join(" "),
    keywords: metadata.keywords
)

#if not forprint [  // when not generating files for the printshop, include cover
    #set page(background: image("cover/cover-frontside.pdf", width: 100%)) 
    #pagebreak()
    #set page(background: none)
    #pagebreak()
]

// frontmatter ////////////////////////////////////////////////////////////////


// prevent next sections from showing up in the outline (i.e. table of contents)
#set heading(outlined: false, numbering: none) 
#let hide-header = state("hide-header", true)

#include "frontmatter/opener.typ"
#include "frontmatter/titlepage_front.typ"
#include "frontmatter/titlepage_rear.typ"
#include "frontmatter/quote.typ"
#include "frontmatter/summary-NL.typ"  // summary can also be put after outline if you prefer
#include "frontmatter/summary-EN.typ"  // summary can also be put after outline if you prefer

#outline(indent:2em, depth: 2)

// main content ///////////////////////////////////////////////////////////////

// ensure that sections from here on out show up in outline (i.e. table of contents) and use
// Numbering in the style of 1, 1.3.4 etc
#label("start-headers") // start adding headers to pages starting from this point
#set heading(outlined: true, numbering: "1.1") 

#counter(page).update(0)  // set current point to be page 1
#include "chapters/01_background/main.typ"
#include "chapters/02_another_chapter/main.typ"
// add more chapters here


#set page(header: [])  // hide header from bibliography
#bibliography((
 "chapters/01_background/literature.bib",
 // add the references for each chapter here if managing per-chapter
))
#pagebreak()
#label("end-chapter-markers") 


// Backmatter /////////////////////////////////////////////////////////////////

#set heading(numbering: none) // we dont want the appendix chapter to have a number


#include "backmatter/cv.typ"
#include "backmatter/publications.typ"

// configure the header for the appendix
#counter(heading).update(0)  // we want to start at A.1, A.2 etc
#set heading(supplement: [Appendix]) // change to appendix format chapter sections
#set heading(numbering: (..nums) => {
    let levels = nums.pos()
    if levels.len() == 1 {
        "Appendix " + str(levels.at(0)) + ":"
    }
})

#show heading.where(level: 2): it =>[
    #block(it.body)
]
#include "appendix/something-for-the-end/something-for-the-end.typ"

#set heading(numbering: none)  // stop this section from starting with "Appendix"
#include "backmatter/acknowledgements.typ"  


#if not forprint [  // when not generating files for the printshop, include cover
    #set page(background: image("cover/cover-backside.pdf", width: 100%)) 
]