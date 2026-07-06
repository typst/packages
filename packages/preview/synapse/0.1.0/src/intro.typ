#import "notion.typ": _get-meta, _is-existing-notion, _notions
#import "config.typ": _is-mode
#import "utils.typ": _get-notion-display, _get-styled-text

/// A marker that displays where the notions anchors points are, and also serves as a visual indicator for the introduction of a notion. Only used in composition mode.
#let _intro-marker(repr) = {
  if _is-mode("composition") {
    box(
      place(
        highlight(
          text(
            repr,
            size: .7em,
          ),
          fill: rgb("#ff7171"),
          extent: .5pt,
          radius: .1em,
        ) + line(angle: -90deg, length: 1.5em, stroke: rgb("#ff7171")),
        dy: -1.5em,
        dx: -.5pt,
        clearance: 0pt,
      ),
      width: 0pt,
    )
    h(0pt, weak: true)
  }
}


/// Apply the syn-style to a notion without any label or link
#let _styled-intro(notion, body) = (
  context {
    if not _is-existing-notion(notion) {
      panic("Notion " + notion + " not found: " + repr(
        _notions.get().at(0).keys(),
      ))
    }
    let meta = _get-meta(notion)
    let styled-text = _get-styled-text(meta, "intro-style")
    _get-notion-display(meta, "intro-style", notion, body)
  }
)

/// Apply the given notion label to the body without any style or link
#let _labeled-intro(notion, body) = (
  context {
    if not _is-existing-notion(notion) {
      panic("Notion " + notion + " not found: " + repr(
        _notions.get().at(0).keys(),
      ))
    }
    let meta = _get-meta(notion)
    if meta.url != none {
      panic("Notion " + notion + " has a URL: " + meta.url + ", so it cannot be labeled")
    }
    if meta.introduced == true {
      panic("Notion " + notion + " has already been introduced, so it cannot be labeled")
    }
    _notions.update(old => {
      old.at(1).at(old.at(0).at(notion)).introduced = true
      return old
    })
    if meta.anchored == true {
      body // don't add a label if the notion is anchored, because the label will be on the anchor point instead of the notion itself
    } else {
      [
        #_intro-marker(notion)
        #body
        #label(meta.repr)
      ]
    }
  }
)

#let str-intro(notion, body) = {
  _labeled-intro(notion, _styled-intro(notion, body))
}