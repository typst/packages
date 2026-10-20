#import "@preview/rivet:0.3.1": schema, config

#let example = schema.load(yaml("/gallery/example1.yaml"))
//#schema.render(example)

= Chapter 1
#lorem(50)

= Chapter 2
#lorem(50)

== Section 2.1

#lorem(20)

#figure(
  schema.render(example, config: config.config(all-bit-i: false)),
  caption: "Test schema"
)

#lorem(20)

= Chapter 3