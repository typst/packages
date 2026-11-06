#import "global.typ": *
#import "glossary-definitions.typ": gls-entries

// Not listed in table of contents (the outline)
// Not numbered
#heading(outlined: false, numbering: none)[
  Glossary
]

// Hints:
// * Add list of terms in file glossary-definitions.typ
// * Usage within text will then be #gls(<key>) or plurals #glspl(<key>)



// Output the glossary. The entries will be sorted by key.
//
// FIX left alignment of glossary:
//      With glossary 0.5.1 it is necessary
//      to overwrite figure captions to be aligned left
#show figure: set block(inset: (top: .1em))
#show figure.caption: c => block(width:100%,align(left, c.body))
#print-glossary(gls-entries)
