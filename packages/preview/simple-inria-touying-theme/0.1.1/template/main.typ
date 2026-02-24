#import "@preview/touying:0.6.1": *
#import "@preview/simple-inria-touying-theme:0.1.1": *

#show: inria-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Authors],
    date: datetime.today(),
  ),
  footer-progress: true,
  section-slides: true,
  black-title: true,
)

#title-slide()

= First Slide

Content

= New Section <touying:hidden>

#new-section-slide([Hello there!])

= Another Slide

More Content
