#import "../src/heroic.typ": icon, hi

#set page(width: auto, height: auto, margin: 1cm)

Use `#icon` to add icons as images as seen in @map-pin-icon.
#figure(
  icon("map-pin", height: 2cm, color: green),
  caption: [`map-pin` icon],
) <map-pin-icon>

Use #text(fill: orange)[#hi("megaphone", solid: false) `#hi`] for context aware inline icons\
that adapt to the surrounding text.


#hi("megaphone") #hi("megaphone", solid: false)

#hi("microphone") #hi("microphone", solid: false)
