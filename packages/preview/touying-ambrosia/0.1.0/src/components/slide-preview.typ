#import "context.typ": component-wrapper
#import "../touying.typ": utils
#import "../utils/visibility.typ": is-covered
#import "../utils/metadata.typ": is-kind

#let render-slide-preview(self: none, target, thumbnail: none, width: 35%, caption: none,
  frame: "first", aspect-ratio: auto, radius: 0.25em, stroke: auto,
) = block(width: width, breakable: false, layout(bounds => context {
  let targets = query(target).filter(it => not is-covered(it))
  assert(targets.len() > 0, message: "Slide preview target was not found: " + str(target))
  let first-page = targets.first().location().page()
  let next = query(<touying-metadata>).filter(it => is-kind(it, "touying-new-slide")
    and it.location().page() > first-page).first(default: none)
  let last = query(<touying-last-page>).last(default: none)
  let last-page = if next != none { next.location().page() - 1 }
    else if last != none { last.location().page() } else { counter(page).final().first() }
  let target-page = if frame == "last" { last-page } else if frame == "first" { first-page } else { first-page + frame - 1 }
  assert(target-page <= last-page, message: "Slide preview frame exceeds the target slide's frame count.")
  let destination = (page: target-page, x: 0pt, y: 0pt)
  let (page-width, page-height) = utils.get-page-dimensions(self)
  let ratio = if aspect-ratio == auto { page-width / page-height } else { aspect-ratio }
  assert(type(ratio) in (int, float) and ratio > 0, message: "Slide preview aspect-ratio must be a positive number or auto.")
  let stroke = if stroke == auto { 0.04em + self.colors.border } else { stroke }
  [#metadata((key: str(target) + ":" + str(frame), label: str(target), frame: frame,
    target: target-page, placeholder: thumbnail == none))<ambrosia-slide-preview>]
  link(destination, block(width: 100%, height: bounds.width / ratio,
    above: 0em, below: 0em, radius: radius, stroke: stroke, clip: true,
    fill: self.colors.surface, {
      if thumbnail != none {
        box(width: 100%, height: 100%, thumbnail)
      } else {
        place(center + horizon, text(size: 0.65em, fill: self.colors.muted)[
          Preview Not Exported
          #linebreak()
          ↗ #str(target)
        ])
      }
    }))
  if caption != none { block(above: 0.35em, below: 0em,
    link(destination, text(size: 0.65em, fill: self.colors.muted, caption))) }
}))

/// Linked visual reference to a labeled slide. Supply an exported SVG image for
/// an exact static thumbnail; without one, a clickable placeholder is shown.
#let ambrosia-slide-preview(target, thumbnail: none, width: 35%, caption: none,
  frame: "first", aspect-ratio: auto, radius: 0.25em, stroke: auto,
) = {
  assert(type(target) == label, message: "Slide preview target must be a native label.")
  assert(thumbnail == none or type(thumbnail) == content, message: "Supply thumbnail as image(\"preview.svg\") or none.")
  assert(frame in ("first", "last") or (type(frame) == int and frame > 0), message: "Slide preview frame must be first, last, or a positive integer.")
  component-wrapper(render-slide-preview.with(thumbnail: thumbnail, width: width, caption: caption,
    frame: frame, aspect-ratio: aspect-ratio, radius: radius, stroke: stroke), target)
}
