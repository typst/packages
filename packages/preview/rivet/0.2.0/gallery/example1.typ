#import "../src/lib.typ": schema, config

#let example = schema.load("/gallery/example1.yaml")
#schema.render(example, config: config.config(
  full-page: true
))