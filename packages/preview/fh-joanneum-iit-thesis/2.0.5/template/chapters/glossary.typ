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



// Output the glossary.
// The entries will be sorted by key.
#set align(left)
#print-glossary(gls-entries)
