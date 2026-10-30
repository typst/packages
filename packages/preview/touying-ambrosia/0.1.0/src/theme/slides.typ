#import "../touying.typ": *
#import "../assets.typ"
#import "../colors.typ"
#import "../components.typ" as ambrosia-components
#import "../utils.typ" as ambrosia-utils
#import "../components/branding.typ": render-primary-logos
#import "../citations.typ" as footcite
#import "../navigation.typ": resolve-navigation
#import "render.typ": touying-slide
#import "title.typ": modern-title-slide, title-slide
#import "../palettes.typ"
#import "special.typ": section-slide, image-slide
#import "watermark.typ": with-watermark
#import "../components/agenda.typ": fitted-outline, focused-outline

/// Default slide function for the presentation.
///
/// - title (string): The title of the slide. Default is `auto`.
///
/// - subtitle (string): The subtitle of the slide. Default is `auto`.
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - repeat (auto): The number of subslides. Default is `auto`, which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - setting (dictionary): The setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - composer (function): The composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - bodies (content): The contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
#let slide(
  title: auto,
  subtitle: auto,
  header: auto,
  footer: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto {
    self.store.align = align
  }
  self.store.breadcrumb-title = title
  if title != auto {
    self.store.title = title
  }
  if subtitle != auto {
    self.store.subtitle = subtitle
  }
  if header != auto {
    self.page.header = header
  }
  if footer != auto {
    self.page.footer = footer
  }
  let new-setting = body => {
    show: ambrosia-components.apply-context-components.with(self: utils.merge-dicts(self, config))
    show: std.align.with(self.store.align)
    show: setting
    body
  }
  touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: composer, ..bodies)
})


/// Outline slide for the presentation.
///
/// - config (dictionary): is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - title (string): is the title of the outline. Default is `ambrosia-utils.i18n-outline-title`.
///
/// - level (int, none): is the level of the outline. Default is `none`.
///
/// - numbered (boolean): is whether the outline is numbered. Default is `true`.
#let outline-slide(
  config: (:),
  title: ambrosia-utils.i18n-outline-title,
  numbered: true,
  level: none,
  depth: 1,
  style: auto,
  /// Agenda typography; auto follows the theme's agenda-text-size.
  /// -> auto | length
  text-size: auto,
  /// Leader content between a heading and its slide number; auto inherits outline-fill.
  /// -> auto | content | none
  fill: auto,
  min-scale: auto,
  start: auto,
  overflow: "window",
  watermark: auto,
  ..args,
) = touying-slide-wrapper(self => {
  self = with-watermark(utils.merge-dicts(self, config), "outline", enabled: watermark)
  let get-label = self => {
    std.label("touying-outline:" + str(here().page()))
  }
  self.store.title = self => {
    context {
      let target = get-label(self)
      if query(target).len() == 1 {
        [#link(target, title)<touying-link>]
      } else {
        [#link((page: here().page(), x: 0pt, y: 0pt), title)<touying-link>]
      }
    }
  }
  self.store.breadcrumb-title = title
  self.store.header-aa = self.store.title
  self.store.header-ab = none
  touying-slide(self: self, config: config,
    setting: body => {
      {
        set heading(numbering: none)
        show heading: none
        std.heading(utils.call-or-display(self, title), level: 1, outlined: false, bookmarked: true)
      }
      context [#metadata(none)#get-label(self)]
      fitted-outline(self, style: style, text-size: text-size, fill: fill, depth: depth, level: level, numbered: numbered,
        min-scale: min-scale, start: start, overflow: overflow,
        selector-filter: ambrosia-utils.appendix-filter, body: body)
    },
    args.pos().sum(default: []),
  )
})


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - config (dictionary): is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - title (content, function): is the title of the section. The default is `ambrosia-utils.i18n-outline-title`.
///
/// - level (int): is the level of the heading. The default is `1`.
///
/// - numbered (boolean): is whether the heading is numbered. The default is `true`.
///
/// - body (none): is the body of the section. It will be passed by touying automatically.
#let new-section-slide(
  config: (:),
  title: ambrosia-utils.i18n-outline-title,
  level: 1,
  depth: 3,
  style: auto,
  /// Agenda typography; auto follows the theme's agenda-text-size.
  /// -> auto | length
  text-size: auto,
  /// Leader content for current and neighboring agenda entries.
  /// -> auto | content | none
  fill: auto,
  numbered: true,
  min-scale: auto,
  neighbors: 1,
  watermark: auto,
  ..args,
  body,
) = touying-slide-wrapper(self => {
  self = with-watermark(utils.merge-dicts(self, config), "section", enabled: watermark)
  let get-label = self => {
    std.label("touying-section-outline:" + str(here().page()))
  }
  if self.store.at("subtitle", default: none) != none {
    self.store.subtitle = self => {
      context {
        let target = get-label(self)
        if query(target).len() == 1 {
          [#link(target, title)<touying-link>]
        } else {
          let heading = ambrosia-utils.current-heading(depth: 1, level: 1, selector-filter: ambrosia-utils.appendix-filter)
          [#link(heading.location(), title)<touying-link>]
        }
      }
    }
  } else {
    self.store.title = title
  }
  self.store.header-aa = self.store.title
  self.store.header-ab = self.store.subtitle
  touying-slide(self: self, config: config,
    setting: body => {
      context [#metadata(none)#get-label(self)]
      focused-outline(self, style: style, text-size: text-size, fill: fill, depth: depth, level: level, numbered: numbered,
        min-scale: min-scale, neighbors: neighbors,
        selector-filter: ambrosia-utils.appendix-filter, body: body)
    },
    args.pos().sum(default: []) + body,
  )
})



/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
///
/// - config (dictionary): is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - align (alignment): is the alignment of the content. The default is `horizon + center`.
#let focus-slide(
  config: (:),
  align: horizon + center,
  fill: auto,
  text-fill: auto,
  body,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-store(navigation: none, section-progress: false, navigation-buttons: false),
    config-page(
      fill: if fill == auto { gradient.linear(self.colors.primary, self.colors.neutral-dark, angle: 45deg) } else {
        fill
      },
      margin: 2em,
      header: none,
      footer: self => {
        place(
          right + bottom,
          if self.store.logo-focus == auto {
            let logo-self = self
            logo-self.store.logo-background = self.page.fill
            context render-primary-logos(logo-self, 1em, page.width * 30%, kind: "focus")
          } else { box(height: 1em, ambrosia-utils.call-or-display(self, self.store.logo-focus)) },
          dx: -0.1em,
          dy: -0.1em,
        )
      },
    ),
  )
  let foreground = if text-fill != auto { text-fill }
    else if fill == none { self.colors.foreground }
    else if type(fill) == color and palettes.contrast(white, fill) < 4.5 { black }
    else { self.colors.neutral-lightest }
  set text(fill: foreground, weight: "bold", size: 1.5em)
  touying-slide(self: self, config: config, setting: std.align.with(align), body)
})


/// Bibliography slide for the presentation.
///
/// - config (dictionary): is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - title (string): is the title of the bibliography. Default is `ambrosia-utils.i18n-bibliography-title`. This is shown as the slide title, while the real title of the bibliography is set to `none`.
#let bibliography-slide(
  config: (:),
  title: ambrosia-utils.i18n-bibliography-title,
  marker: auto,
  ..args,
) = touying-slide-wrapper(self => {
  self.store.title = title
  self.store.breadcrumb-title = title
  self.store.header-aa = title
  self.store.header-ab = none
  touying-slide(
    self: self,
    config: config,
    std.align()[
      #{
        set heading(numbering: none)
        show heading: none
        std.heading(utils.call-or-display(self, title), level: 1, outlined: false, bookmarked: true)
      }
      #set text(size: 0.7em)
      #footcite.scoped-bibliography(..args, marker: if marker != auto { marker }
        else if args.named().at("style", default: auto) != auto { "native" }
        else { self.store.bibliography-marker })
    ],
  )
})


/// Register a bibliography without showing its reference list.
#let hidden-bibliography(..args) = only("h", footcite.scoped-bibliography(hidden: true, ..args))


// Closing layouts live separately from the ordinary slide helpers.
#import "ending.typ": render-ending-slide, ending-slide

#let backup-slide(
  title: auto,
  subtitle: auto,
  config: (:),
  ..bodies,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
  )
  if title != auto {
    self.store.title = title
  }
  if subtitle != auto {
    self.store.subtitle = subtitle
  }
  touying-slide(self: self, config: config, ..bodies)
})
