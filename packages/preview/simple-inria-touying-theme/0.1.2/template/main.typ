#import "@preview/touying:0.6.3": *
#import "@preview/simple-inria-touying-theme:0.1.2": *

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

= Another slide with very long title to be sized accordingly in the header of the slide

More Content
