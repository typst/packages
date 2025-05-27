#import "../src/lib.typ": schema, config

#let example = schema.load("/gallery/example2.yaml")
#schema.render(example, config: config.blueprint(
  full-page: true,
  left-labels: true
))