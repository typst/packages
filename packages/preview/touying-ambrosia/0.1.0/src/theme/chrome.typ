#import "../touying.typ": components, utils
#import "../components.typ" as ambrosia-components
#import "../utils.typ" as ambrosia-utils
#import "../components/branding.typ": primary-logos, render-primary-logos, render-header-logo, header-logo-visible
#import "flavors.typ": current-flavor
#import "../components/pane-navigation.typ": render-panes
#import "../components/tree-navigation.typ": render-tree
#import "../components/segmented-navigation.typ": render-segments
#import "../components/navigation-buttons.typ": render-navigation-buttons
#import "../components/structural-navigation.typ": render-breadcrumbs, render-section-progress, navigation-label

// The fade's full-opacity end belongs to an empty gutter, not to a label.
#let header-right-inset(self, original) = {
  let reserve = self.store.at("header-logo-reserve", default: 0pt)
  let fade = self.store.at("header-fade-inset", default: 0pt)
  if reserve > 0pt { original + reserve }
  else if fade > 0pt { calc.max(original.to-absolute(), fade) }
  else { original }
}

#let navigation-row(self) = {
  let navigation = self.store.navigation-definition
  let flavor = current-flavor(self)
  block(width: 100%, height: navigation.height, above: 0em, below: 0em, clip: true,
    fill: (flavor.navigation-background)(self), inset: (left: 1.5em, right: header-right-inset(self, 1.5em), y: 0.15em), layout(bounds => context {
      [#metadata((width: bounds.width.pt(), height: bounds.height.pt(),
        placement: navigation.placement))<ambrosia-segment-region>]
      if navigation.renderer != auto { (navigation.renderer)(self) } else { render-segments(self) }
    }))
}

// Portico's metadata band is independent of structural navigation.
#let metadata-banner(self) = block(width: 100%, height: 0.9em,
  fill: self.colors.chrome, inset: (left: 1.5em, right: header-right-inset(self, 1.5em), y: 0.12em), {
    set text(size: 0.5em, fill: self.colors.on-chrome)
    grid(columns: (1fr, 30%), gutter: 1em,
      navigation-label(ambrosia-utils.call-or-display(self, self.store.footer-ab), lines: 1, background: self.colors.chrome),
      navigation-label(ambrosia-utils.call-or-display(self, self.store.footer-aa), lines: 1, background: self.colors.chrome))
  })

// Fill the slide's original header envelope and align its rows to the top.
// A 100% height would include the notes panel when notes are above the slide.
#let header(self) = layout(bounds => context {
  set std.align(top)
  let self = self
  let definition = current-flavor(self)
  let margin = self.page.margin
  let top-margin = if type(margin) == dictionary {
    margin.at("top", default: margin.at("y", default: margin.at("rest", default: auto)))
  } else { margin }
  let (_, page-height) = utils.get-page-dimensions(self)
  let resolve(value, reference) = if type(value) == ratio { value * reference }
    else if type(value) == relative { value.length + value.ratio * reference }
    else { value }
  let envelope = if top-margin == auto { auto } else {
    let resolved-top = resolve(top-margin, page-height).to-absolute()
    calc.max(0pt, resolved-top
      - if self.at("show-only-notes", default: false) { 0pt }
        else { resolve(self.page.header-ascent, resolved-top).to-absolute() })
  }
  let visible = definition.header-logo and header-logo-visible(self)
  let edge = visible and definition.header-logo-placement == "edge"
  let thin = self.store.navigation-definition.kind in ("context", "tree")
  let corner = visible and (definition.header-logo-placement == "corner" or (edge and thin))
  let embedded = edge and not thin
  let logo-self = self
  let background = if corner { self.page.fill }
    else if self.store.navigation-definition.placement == "header" { (definition.navigation-background)(self) }
    else if definition.header-banner { self.colors.chrome }
    else { (definition.header-background)(self) }
  logo-self.store.logo-background = if background == none { self.page.fill } else { background }
  let mark = if corner or embedded { render-header-logo(logo-self, 1.8em, bounds.width * 30% - 0.8em) } else { none }
  // Reserve ink, not paint: wide header bands continue behind an edge mark.
  self.store.header-logo-reserve = if embedded { measure(mark).width + (1.2em).to-absolute() } else { 0pt }
  let fade-width = if corner and type(self.page.fill) == color { definition.header-logo-fade.to-absolute() } else { 0pt }
  assert(fade-width >= 0pt, message: "Header logo fade must not be negative.")
  // All built-in rows reserve this gutter, so the paint fade cannot erase ink.
  self.store.header-fade-inset = if fade-width > 0pt { fade-width + (0.2em).to-absolute() } else { 0pt }
  let rows = grid(row-gutter: 0em,
    if definition.header-banner and self.store.title != none { metadata-banner(self) },
    ambrosia-utils.call-or-display(self, self.store.header-a),
    ambrosia-utils.call-or-display(self, self.store.header-b))
  let rows = if fade-width == 0pt { rows } else {
    block(width: 100%, above: 0em, below: 0em, {
      rows
      place(top + right, block(width: fade-width, height: 100%,
        fill: gradient.linear(self.page.fill.transparentize(100%), self.page.fill), {
          [#metadata((width: fade-width.pt(), target: self.page.fill))<ambrosia-header-fade>]
        }))
    })
  }
  let content = if corner {
    // Thin strips stop beside the mark; their tail fades into its backing.
    grid(columns: (1fr, auto), column-gutter: 0em, align: top,
      rows, block(inset: (left: 0.4em, right: 0.8em), above: 0em, below: 0em, mark))
  } else if embedded {
    block(width: 100%, above: 0em, below: 0em, {
      grid(columns: (1fr, 0pt), rows, box(height: 1.8em))
      place(top + right, block(inset: (left: 0.4em, right: 0.8em), above: 0em, below: 0em, mark))
    })
  } else { rows }
  block(width: 100%, height: envelope, above: 0em, below: 0em,
    breakable: false, grid(row-gutter: 0em,
      context [#metadata((height: {
        let end = query(<ambrosia-header-end>).find(it => it.location().page() == here().page())
        if end == none { 0pt } else { end.location().position().y - here().position().y }
      }.pt()))<ambrosia-header-region>],
      content,
      [#metadata(none)<ambrosia-header-end>]))
})


#let footer(self) = {
  set text(size: .5em)
  set std.align(center + bottom)
  block(breakable: false, above: 0em, below: 0em, grid(
    row-gutter: 0em,
    { set text(size: 2em); ambrosia-utils.call-or-display(self, self.store.footer-b) },
    { set text(size: 2em); if self.store.navigation-definition.placement == "footer" { navigation-row(self) } },
    ambrosia-utils.call-or-display(self, self.store.footer-a),
    if self.store.section-progress { render-section-progress(self) },
    if self.store.progress-bar {
      ambrosia-utils.call-or-display(
        self,
        components.progress-bar(height: 0.2em, self.colors.primary.lighten(30%), self.colors.surface-alt),
      )
    },
  ))
}

// The default footer shares one compact row between branding and controls.
// Custom footer renderers retain ownership of their layout and spacing.
#let footer-logo-enabled(self) = (self.store.footer-logo and primary-logos(self).len() > 0
  and self.page.footer == footer)
#let footer-buttons-enabled(self) = (self.page.footer == footer and self.store.navigation-buttons
  and self.store.navigation-buttons-actions.len() > 0)
#let footer-accessory-height(self) = {
  let logo = if footer-logo-enabled(self) { self.store.footer-logo-height } else { 0em }
  let buttons = if footer-buttons-enabled(self) { 0.95em } else { 0em }
  if logo == 0em and buttons == 0em { return 0em }
  // Keep relative inputs relative, including a user-supplied em text size.
  if logo.abs == 0pt and buttons.abs == 0pt {
    return calc.max(logo.em, buttons.em) * 1em + 0.3em
  }
  // Before layout, mixed units can be resolved against an absolute theme font.
  // For an inherited relative font, reserve a conservative envelope instead.
  if self.store.text-size.em != 0 {
    return calc.max(logo.abs, buttons.abs) + calc.max(logo.em, buttons.em) * 1em + 0.3em
  }
  let resolve(value) = value.abs + value.em * self.store.text-size
  calc.max(resolve(logo), resolve(buttons)) + 0.3em
}

#let with-footer-space(self) = {
  let section-space = self.store.section-progress and self.page.footer == footer
  if not footer-logo-enabled(self) and not footer-buttons-enabled(self) and not section-space { return self }
  let margin = self.page.margin
  if margin == auto { return self }
  if type(margin) != dictionary { margin = (rest: margin) }
  let bottom = margin.at("bottom", default: margin.at("y", default: margin.at("rest", default: 0em)))
  if bottom == auto { bottom = 1em }
  margin.insert("bottom", bottom
    + footer-accessory-height(self)
    + if section-space { 0.8em } else { 0em })
  utils.merge-dicts(self, (page: (margin: margin),))
}

#let header-a(self) = {
  let definition = current-flavor(self)
  let navigation = self.store.navigation-definition
  if navigation.placement != "header" { return }
  if navigation.renderer != auto {
    return block(width: 100%, height: navigation.height, above: 0em, below: 0em, clip: true,
      inset: (right: header-right-inset(self, 0em)), (navigation.renderer)(self))
  }
  if navigation.kind == "tree" {
    return block(width: 100%, height: navigation.height, above: 0em, below: 0em,
      clip: true, render-tree(self))
  }
  if navigation.kind == "segments" { return navigation-row(self) }
  if navigation.kind in ("tabs", "dots", "panes") {
    block(width: 100%, height: navigation.height, above: 0em, below: 0em,
      fill: (definition.navigation-background)(self), clip: true,
      inset: (left: 1.5em, right: header-right-inset(self, 1.5em), y: 0.1em),
      if navigation.kind == "panes" { render-panes(self) } else { ambrosia-components.render-header-navigation(self) })
  } else if navigation.kind == "context" {
    block(width: 100%, height: navigation.height, above: 0em, below: 0em, clip: true, {
      set text(size: .5em)
      grid(
        columns: self.store.header-a-columns,
        rows: 100%,
        rect(
          width: 100%, height: 100%, inset: 0.3em, outset: 0em,
          fill: self.colors.primary, stroke: none,
          std.align(horizon + right, text(fill: self.colors.on-accent,
            navigation-label(ambrosia-utils.call-or-display(self, self.store.header-aa), lines: 1, background: self.colors.primary, alignment: right))),
        ),
        rect(
          width: 100%, height: 100%, inset: (rest: 0.3em, right: header-right-inset(self, 0.3em)), outset: 0em,
          fill: self.colors.primary-light, stroke: none,
          std.align(horizon + left, text(fill: self.colors.foreground,
            navigation-label(ambrosia-utils.call-or-display(self, self.store.header-ab), lines: 1, background: self.colors.primary-light))),
        ),
      )
    })
  }
}

#let header-b(self) = if self.store.title != none { layout(bounds => context {
  let definition = current-flavor(self)
  let block-args = (
    width: 100%,
    height: 1.8em,
    fill: (definition.header-background)(self),
  )
  let title-block-args = (
    inset: (
      left: if self.store.navigation-body-insets == none { definition.header-title-inset-left } else { self.store.navigation-body-insets.left },
      right: header-right-inset(self, if self.store.navigation-body-insets == none { definition.header-title-inset-right } else { self.store.navigation-body-insets.right }),
      top: 0.15em,
      bottom: 0.15em,
    ),
  )
  let text-args = (
    title: (
      size: 1.3em,
      weight: "bold",
      fill: (definition.header-title)(self),
    ),
    subtitle: (
      size: 1.0em,
      weight: "semibold",
      fill: (definition.header-subtitle)(self),
    ),
  )

  let logo-self = self
  let logo-background = (definition.header-background)(self)
  logo-self.store.logo-background = if logo-background == none { self.page.fill } else { logo-background }
  let header-logo = if definition.header-logo and definition.header-logo-placement == "title" and header-logo-visible(self) {
    block(
      inset: (right: 0.8em, top: 0.2em, bottom: 0.2em),
      grid(
        rows: block-args.height - 0.4em,
        render-header-logo(logo-self, block-args.height - 0.4em, bounds.width * 30%),
      ),
    )
  } else { none }
  let title-block = block(
    ..title-block-args,
    if self.store.navigation-definition.placement == "title" {
      text(..text-args.title,
        if self.store.navigation-definition.renderer != auto { (self.store.navigation-definition.renderer)(self) }
        else { render-breadcrumbs(self) })
    } else {
      ambrosia-utils.adaptive-prose-display-title-subtitle(
        text(..text-args.title, ambrosia-utils.call-or-display(self, self.store.title)),
        text(..text-args.subtitle, ambrosia-utils.call-or-display(self, self.store.subtitle)),
      )
    },
  )
  block(
    ..block-args,
    std.align(horizon,
      if header-logo == none {
        title-block
      } else {
        grid(
          columns: (1fr, auto),
          gutter: 0.5em,
          align: (left + horizon, right + horizon),
          title-block,
          header-logo,
        )
      }
    ),
  )
})
}

#let footer-a(self) = context {
  let minimal = current-flavor(self).footer-style == "minimal"
  let author = ambrosia-utils.call-or-display(self, self.store.footer-aa)
  let title = ambrosia-utils.call-or-display(self, self.store.footer-ab)
  let date = ambrosia-utils.call-or-display(self, self.store.footer-ac)
  let number = ambrosia-utils.call-or-display(self, self.store.footer-ad)
  let columns = if self.store.footer-a-columns != auto { self.store.footer-a-columns } else {
    (20%, 1fr, measure(box(date)).width + 0.8em,
      measure(box(number)).width + if minimal { 0.8em } else { 3.8em })
  }
  let field(body, background, alignment: center, complete: false) = ambrosia-utils.fitted-footer-field(
    body, background: background, alignment: alignment,
    min-scale: self.store.footer-min-scale, complete: complete)
  if minimal {
    return block(inset: (x: 3em), grid(
      columns: columns, rows: 1.5em, gutter: 0.5em,
      text(fill: self.colors.muted, field(author, self.page.fill, alignment: left)),
      text(fill: self.colors.muted, field(title, self.page.fill)),
      text(fill: self.colors.muted, field(date, self.page.fill, complete: true)),
      text(fill: self.colors.primary, field(number, self.page.fill, alignment: right, complete: true)),
    ))
  }
  let cell(fill, text-fill, inset: 0.3em, complete: false, it) = rect(
    width: 100%, height: 100%, inset: inset, outset: 0em, fill: fill, stroke: none,
    text(fill: text-fill, field(it, fill, complete: complete)))
  grid(columns: columns, rows: 1.5em,
    cell(self.colors.primary, self.colors.on-accent, inset: (left: 3em, rest: 0.3em), author),
    cell(self.colors.primary-light, self.colors.foreground, title),
    cell(self.colors.primary, self.colors.on-accent, complete: true, date),
    cell(self.colors.primary, self.colors.on-accent, inset: (right: 3em, rest: 0.3em), complete: true, number),
  )
}


#let footer-b(self) = {
  if not footer-logo-enabled(self) and not footer-buttons-enabled(self) { return }
  let height = footer-accessory-height(self)
  block(width: 100%, height: height, above: 0em, below: 0em,
    inset: (x: 1.5em, y: 0.15em), layout(bounds => context {
      [#metadata((height: bounds.height.pt(), row-height: height.to-absolute().pt(), width: bounds.width.pt()))<ambrosia-footer-accessories>]
      let cells = ()
      if footer-buttons-enabled(self) {
        let controls = text(size: 0.8em, render-navigation-buttons(self: self,
          actions: self.store.navigation-buttons-actions, opacity: self.store.navigation-buttons-opacity))
        let size = measure(controls)
        cells.push(box(width: size.width, height: size.height, {
          [#metadata((width: size.width.pt(), height: size.height.pt()))<ambrosia-navigation-buttons-region>]
          controls
        }))
      }
      if footer-logo-enabled(self) {
        let logo-self = self
        logo-self.store.logo-background = self.page.fill
        cells.push(render-primary-logos(logo-self, self.store.footer-logo-height, bounds.width * 30%, kind: "footer"))
      }
      grid(columns: (1fr,) + (auto,) * cells.len(), column-gutter: 0.5em,
        align: right + horizon, [], ..cells)
    }))
}
