// * Add list of terms

#let gls-entries = (
    (
      key: "gc", short: "GC", long: "Garbage Collection", description: [Garbage collection is the common name for the term automatic memory management.],
    ),
    (
      key: "cow", short: "COW", long: "Copy on Write", description: [Copy on Write is a memory allocation strategy where arrays are copied if they
        are to be modified.],
    ),
    (
      key: "svg", short: "SVG", long: "Scalable Vector Graphics", description: [A vector image format.],
    ),
    (
      key: "csv", short: "CSV", long: "Comma-separated Values ", description: [A human readable, plain text file format using commas to separate the values.],
    ),
)

// Hints:
// * Usage within text will then be #gls(<key>) or plurals #glspl(<key>)
