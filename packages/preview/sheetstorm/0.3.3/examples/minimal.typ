#import "@preview/sheetstorm:0.3.3" as sheetstorm: task

#show: sheetstorm.setup.with(
  title: "Minimal Example",
  authors: "John Doe",
)

#task[
  This is how the template looks with no/minimal configuration.
]

#task(lorem(1000))
