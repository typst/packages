#import "@preview/touying-wave-hhu:0.1.0": *

#show: hhu-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Author],
    date: datetime.today(),
    institution: [Institution],
  ),
  config-page(
    footer: (self) => {
      self.info.title
    }
  )
)

#title-slide()
