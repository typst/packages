#import "../colors.typ": color-schema

#let proof(content) = {
  block(width: 100%)[
    // The word "Proof" in italic
    #text(style: "italic", fill: color-schema.orange.primary)[*Proof*]
    // A small space between the word "Proof" and the main content
    #h(0.3em)
    // Main content of the proof
    #content
    // Start a new line
    #parbreak()
    // Push the following square to the end of the lines
    #h(1fr)
    // A filled square at the end indicating the end of the proof, Q.E.D.
    $square.filled$
  ]
}