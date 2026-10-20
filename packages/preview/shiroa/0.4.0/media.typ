
#import "xcommand.typ": xcommand, xcommand-html
#import "meta-and-state.typ": shiroa-sys-target

#let xhtml(..args, tag: none, attributes: (:)) = context if shiroa-sys-target() == "paged" {
  xcommand(
    ..args,
    {
      "html,"
      json.encode((
        tag: tag,
        attributes: attributes,
      ))
    },
  )
} else {
  // outer-width: 1024pt, outer-height: 768pt, inner-width: none, inner-height: none,
  xcommand-html(
    tag,
    ..args,
    attributes: attributes,
  )
}

#let iframe = xhtml.with(tag: "iframe")
#let video = xhtml.with(tag: "video")
#let audio = xhtml.with(tag: "audio")
#let div = xhtml.with(tag: "div")
