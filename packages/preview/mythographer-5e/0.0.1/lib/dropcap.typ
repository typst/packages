#import "@preview/droplet:0.3.1": dropcap

#import "config.typ"
#import "core.typ"
#import "utils.typ"

#let dnd-dropcap(config: (:), letter, smalcap, body) = core.fn-wrapper(self => {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }
  
  dropcap(
    height: 4,
    justify: true,
    gap: 4pt,
    font: self.font.dropcap.font,
  )[#letter #smallcaps[#smalcap] #body]
})
