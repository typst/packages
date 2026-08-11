// Slide-level functions for Touying Endfield Theme.

#import "@preview/touying:0.6.3": *
#import "./layout.typ": endfield-header, endfield-footer

/// Default slide function for the presentation.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. You can use `utils.merge-dicts` to merge them.
/// - repeat (int, auto): The number of subslides. Default is `auto`.
/// - setting (function): Set/show rules applied within the slide.
/// - composer (function, array): Layout composer of the slide.
/// - bodies (array): Slide contents. Use `#slide[A][B]` form.
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(
    self,
    config-page(header: endfield-header, footer: endfield-footer),
    config-common(subslide-preamble: self.store.subslide-preamble),
  )
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: setting,
    composer: composer,
    ..bodies,
  )
})

/// Title slide for the presentation.
#let title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    // Avoid `set page(..)` inside the slide body: touying >= 0.6.3 adds a
    // trailing layout anchor after the body, and page-level set rules can leak
    // to it and create an extra blank page between slides.
    config-page(margin: 2em),
  )
  let info = self.info + args.named()
  let body = {
    set text(fill: self.colors.neutral-darker)
    set align(left + horizon)
    block(
      width: 100%,
      inset: 1em, // and page margin total 3em, basically a trick to make the footnote align well
      {
        block(
          fill: self.colors.neutral-dark.darken(50%),
          width: 100%,
          stack(
            dir: ltr,
            spacing: 1em,
            block(
              fill: self.colors.primary,
              inset: 0em,
              outset: 0em,
              width: 0.5em,
              height: self.store.title-height,
            ),
            text(
              size: 1.3em,
              fill: self.colors.neutral-lightest.lighten(40%),
              text(weight: "black", info.title),
            ) + (
              if info.subtitle != none {
                linebreak()
                text(size: 0.9em, fill: self.colors.neutral-lightest, info.subtitle)
              }
            ),
          ),
        )
        set text(size: .8em)

        if info.author != none { block(spacing: 1em, info.author) }
        v(1em)
        if info.date != none { block(spacing: 1em, text(utils.display-info-date(self))) }
        set text(size: .8em)
        if info.institution != none { block(spacing: 1em, info.institution) }
        if extra != none { block(spacing: 1em, extra) }
      },
    )
  }
  // Title slide should never create extra subslides; force repeat = 1 to avoid
  // accidental blank pages from auto-repeat inference.
  touying-slide(self: self, repeat: 1, body)
})

/// Outline slide for the presentation.
#let outline-slide(
  config: (:),
  title: utils.i18n-outline-title,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(footer: endfield-footer, header: endfield-header),
  )
  touying-slide(
    self: self,
    config: config,
    components.adaptive-columns(
      start: text(
        1.2em,
        fill: self.colors.neutral-darkest,
        weight: "bold",
        utils.call-or-display(self, title),
      ),
      text(
        fill: self.colors.neutral-darkest,
        outline(title: none, indent: 1em, depth: self.slide-level, ..args),
      ),
    ),
  )
})

/// New section slide for the presentation.
#let new-section-slide(
  config: (:),
  title: utils.i18n-outline-title,
  ..args,
  body,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(header: endfield-header, footer: endfield-footer),
  )
  touying-slide(
    self: self,
    config: config,
    components.adaptive-columns(
      start: text(
        1.2em,
        fill: self.colors.neutral-darkest,
        weight: "bold",
        utils.call-or-display(self, title),
      ),
      text(
        fill: self.colors.neutral-darkest,
        components.progressive-outline(
          alpha: self.store.alpha,
          title: none,
          indent: 1em,
          depth: self.slide-level,
          ..args,
        ),
      ),
    ),
  )
})

/// Focus on some content.
#let focus-slide(config: (:), body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.primary, margin: 2em),
  )
  set text(fill: self.colors.neutral-darker, size: 2em, weight: "bold")
  touying-slide(self: self, config: config, align(horizon + center, body))
})

