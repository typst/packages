#import "@preview/polylux:0.4.0": *
#import "@local/cetramed-polylux:0.1.0" as cetramed

#show: cetramed.setup

// you can use `cetramed.ukj-blue` to access the color used for headings etc.

#cetramed.title-slide(
  group: [Name of group],
  title: [Title of presentation],
  subtitle: [The subtitle],
  extra: [Name of speaker, Date],
)

#slide[
  = Title of slide

  some content

  - with
  - bullet
    - points
]
