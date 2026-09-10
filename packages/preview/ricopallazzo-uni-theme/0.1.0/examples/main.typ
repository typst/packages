#import "@preview/touying:0.7.4": *
#import "../src/theme.typ": *

#show: ricopallazzo-uni-theme.with(aspect-ratio: "presentation-16-9", 
                               theme: "orange",
                               title: "Test Title",
                               short_title: "Short Test Title",
                               author: "Alberto Bertoncini",
                               institute: "UNIMI",
                               logo: "assets/logo_RGB_negative_circle.png",
                               logo_name: "assets/logo_coutour_name.png",
                               progress: "slide-by-section",
                               prefix: "triangle")

#title-slide()

= First section 
== First Slide
#lorem(100)

== Second Slide 
#lorem(300)

= Second Section 

== First slide 

== Second Slide


