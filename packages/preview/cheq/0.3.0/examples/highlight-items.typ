#import "@preview/cheq:0.3.0": checklist

#set page(width: auto, height: auto, margin: 2em)

#show: checklist.with(
  highlight-map: (
    "/": it => {text(weight: "bold", fill: rgb("#BB1615"), it)},
    "!": it => {text(weight: "bold", it)},
  ), 
)

= Solar System Exploration, 1950s – 1960s

- [ ] Mercury
- [x] Venus
- [x] Earth (Orbit/Moon)
- [x] Mars
- [-] Jupiter
- [/] Saturn
- [ ] Uranus
- [!] Neptune
- [?] Comet Halley
- [N] Oort Cloud

#show: checklist.with(highlight: false)

= Solar System Exploration, 1950s – 1960s

- [ ] Mercury
- [x] Venus
- [x] Earth (Orbit/Moon)
- [x] Mars
- [-] Jupiter
- [/] Saturn
- [ ] Uranus
- [!] Neptune
- [?] Comet Halley
- [N] Oort Cloud