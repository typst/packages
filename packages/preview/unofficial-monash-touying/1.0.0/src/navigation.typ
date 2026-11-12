// Outline slide and section divider slides.

#import "@preview/touying:0.8.0": components, config-common, config-page, touying-slide, touying-slide-wrapper, utils
#import "design.typ": *
#import "slides.typ": hidden-heading
#import "appendix.typ": appendix-marker, section-label
#import "section-list.typ": outline-entry, section-grid, section-window, shrink-to-fit

// Page setup shared by the navigation slides: no title bar, no footer.
#let _plain-page(self) = config-page(
  header: none,
  footer: none,
  margin: (x: page-margin-x * 2, y: self.store.font-size * 1.6),
)

#let _outline-body(self, title, depth) = {
  block(width: 100%, below: 1.4em, {
    set block(spacing: .45em)
    block(text(size: 1.35em, fill: monash-blue, weight: "bold", utils.call-or-display(self, title)))
    monash-accent-rule(width: 4.2em, height: 3pt, paint: self.store.accent-color)
  })
  if depth == 1 {
    block(width: 100%, inset: (left: .35cm), section-grid(self))
  } else {
    block(width: 82%, inset: (left: .35cm), {
      set par(leading: .62em)
      components.custom-progressive-outline(
        self: self,
        level: none,
        depth: depth,
        numbered: (false,),
        title: none,
        show-current: (level, it) => outline-entry(self, it),
      )
    })
  }
}

// Builds the outline slide for `self`. Used by `outline-slide` and by
// `title-slide`, which emits one automatically.
#let outline-slide-fn(self, title: auto, depth: 1, config: (:)) = {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    _plain-page(self),
    config,
  )
  let title = if title == auto { utils.i18n-outline-title } else { title }
  touying-slide(self: self, {
    appendix-marker(self)
    hidden-heading(self, title)
    shrink-to-fit(_outline-body(self, title, depth))
  })
}

/// Outline slide listing the main sections. Appendix sections are omitted.
#let outline-slide(
  /// Slide title. `auto` uses Touying's localised "Outline".
  title: auto,
  /// Deepest heading level listed.
  depth: 1,
  /// Touying configuration for this slide.
  config: (:),
) = touying-slide-wrapper(outline-slide-fn.with(
  title: title,
  depth: depth,
  config: config,
))

// Number and title share one grid row, centred against each other, so a
// multi-line title stays aligned with its number; the outline sits in the
// title column below.
#let _section-layout(self, level, outline) = context {
  let current = utils.current-heading(level: level)
  let label = if current != none { section-label(current.location(), level: level) }
  let size = self.store.font-size
  align(center, block(width: 86%, align(left, grid(
    columns: (auto, 1fr),
    column-gutter: size * 1.1,
    row-gutter: size * 1.4,
    align: (right + horizon, left + horizon),
    text(size: size * 4.1, fill: self.store.accent-color, weight: "bold", label),
    {
      set par(leading: .35em)
      text(
        size: size * 2.05,
        fill: monash-blue,
        weight: "bold",
        utils.display-current-heading(level: level, numbered: false),
      )
    },
    [],
    outline,
  ))))
}

#let _section-outline(self, level) = context {
  let current = utils.current-heading(level: level)
  if current != none { section-window(self, level, current.location()) }
}

/// Section divider slide, created automatically for every level-one
/// heading unless `section-slides: false`. It shows the section number and
/// title above an outline that highlights the current section. Appendix
/// sections are lettered and show no outline.
#let new-section-slide(
  /// Touying configuration for this slide.
  config: (:),
  /// Heading level of the section.
  level: 1,
  /// Kept for Touying compatibility; the number is always shown.
  numbered: true,
  /// Content after the heading, when Touying passes it.
  body,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    _plain-page(self),
    config,
  )
  let appendix = self.at("appendix", default: false)
  touying-slide(self: self, setting: std.align.with(horizon), {
    appendix-marker(self)
    shrink-to-fit(_section-layout(self, level, if not appendix { _section-outline(self, level) }))
    body
  })
})
