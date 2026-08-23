#import "@preview/rivet:0.3.1": schema, config

#let example = schema.load(yaml("./example1.yaml"))
#schema.render(example, config: config.config(
  full-page: true
))