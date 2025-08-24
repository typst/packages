#import "@preview/touying:0.6.1": *
#import "@preview/touying-ppt-hustvn:0.1.0": *

#show: hust-theme.with(
  theme: "red",
  aspect-ratio: "16-9",
  config-info(
    title: [Your title here],
    subtitle: [Optional subtitle],
  ),
)

#title-slide()

#outline-slide()

= Introduction

== Introduction

#lorem(20)

#pause

#lorem(30)

= Conclusion

== Conclusion

#lorem(30)

#pause

#lorem(20)

#ending-slide(title: [THANK YOU!])
