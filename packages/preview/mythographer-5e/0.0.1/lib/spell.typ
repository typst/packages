#import "config.typ"
#import "core.typ"
#import "utils.typ"

#import "external.typ"

#let dnd-spell(
  config: (:),
  title,
  level,
  time,
  range,
  components,
  duration,
  body,
) = core.fn-wrapper(self => {
  if config != (:) {
    self = utils.merge-dicts(self, config)
  }

  set text(font: self.font.spell.font, size: self.font.spell.size, weight: "regular")

  text(fill: self.fill.spell.title)[
    #smallcaps[#title]
    #linebreak()
  ]

  text(style: "italic")[
    #level
    #linebreak()
  ]

  let sing-or-plur = "sing"
  if (components.text.split(regex("[,]")).len() > 1) {
    sing-or-plur = "plur"
  }
  
  text[*#external.transl("casting-time")*: #time]
  linebreak()
  text[*#external.transl("range")*: #range]
  linebreak()
  text[*#external.transl("component", t: sing-or-plur)*: #components]
  linebreak()
  text[*#external.transl("duration")*: #duration]
  // set par(justify:true, spacing: 0.65em)
  linebreak()
  // TODO: fix this spacing
  // https://staging.typst.app/docs/reference/model/par/#parameters-justification-limits
  body
})
