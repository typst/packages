
#import "xcommand.typ": xcommand

#let xhtml(..args, tag: none, attributes: (:)) = xcommand(
  ..args,
  {
    "html,"
    json.encode((
      tag: tag,
      attributes: attributes,
    ))
  },
)

#let iframe = xhtml.with(tag: "iframe")
#let video = xhtml.with(tag: "video")
#let audio = xhtml.with(tag: "audio")
#let div = xhtml.with(tag: "div")
