#import "global.typ": *

// Not listed in table of contents (the outline)
// Not numbered
#heading(outlined: false, numbering: none)[
  Glossary
]

// Add list of terms
// Usage within text will then be #gls(<key>) or plurals #glspl(<key>)
#print-glossary(
  (
      (
      key: "cow",
      short: "COW",
      long: "Copy on Write",
      desc: [Copy on Write is a memory allocation strategy where arrays are copied if they are to be modified.],
    ),
    (
      key: "gc",
      short: "GC",
      long: "Garbage Collection",
      desc: [Garbage collection is the common name for the term automatic memory management.],
    )
  )
)
