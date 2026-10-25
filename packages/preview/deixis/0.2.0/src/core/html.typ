// HTML export links marks and bodies through their internal label spellings.
// Typst-assigned anchors would need another layout pass after a destination
// settles, which deep scope chains cannot afford. Only these helpers target
// the deixis-mark-*/deixis-body-* names, so the ids stay unique.
#import "native.typ": _std-target, _std-link
#let _deixis-html-anchor(lbl) = if lbl != none and _std-target() == "html" {
  html.elem("span", attrs: (id: str(lbl)))
}

#let _deixis-html-link(lbl, body) = if _std-target() == "html" {
  html.elem("a", attrs: (href: "#" + str(lbl)), body)
} else { _std-link(lbl, body) }
