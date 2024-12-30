#import "../lib.typ": checklist

#set page(width: auto, height: auto, margin: 2em)

#show: checklist.with(fill: luma(95%), stroke: blue, radius: .2em)

= Solar System Exploration, 1950s – 1960s

- [ ] Mercury
- [x] Venus
- [x] Earth (Orbit/Moon)
- [x] Mars
- [-] Jupiter
- [/] Saturn
- [ ] Uranus
- [ ] Neptune
- [ ] Comet Haley

#show: checklist.with(marker-map: (" ": sym.ballot, "x": sym.ballot.x, "-": sym.bar.h, "/": sym.slash.double))

= Solar System Exploration, 1950s – 1960s

- [ ] Mercury
- [x] Venus
- [x] Earth (Orbit/Moon)
- [x] Mars
- [-] Jupiter
- [/] Saturn
- [ ] Uranus
- [ ] Neptune
- [ ] Comet Haley