#import "@preview/rivet:0.3.1": schema, config

#let example = schema.load(yaml("./example2.yaml"))
#schema.render(example, config: config.blueprint(
  full-page: true,
  left-labels: true
))