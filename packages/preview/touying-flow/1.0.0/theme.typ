#import "lib.typ": *
#import "components.typ" as flowcomponents:*
#let _typst-builtin-repeat = repeat

//页眉
#let flow-header(self) = {
  if self.store.navigation == "sidebar" {
    place(
      right + top,
      {
        v(4em)
        show: block.with(width: self.store.sidebar.width, inset: (x: 1em))
        set align(left)
        set par(justify: false)
        set text(size: .9em)
        components.custom-progressive-outline(
          self: self,
          level: auto,
          alpha: self.store.alpha,
          text-fill: (self.colors.primary, self.colors.neutral-darkest),
          text-size: (1em, .9em),
          vspace: (-.2em,),
          indent: (0em, self.store.sidebar.at("indent", default: .5em)),
          fill: (self.store.sidebar.at("fill", default: _typst-builtin-repeat[.]),),
          filled: (self.store.sidebar.at("filled", default: false),),
          paged: (self.store.sidebar.at("paged", default: false),),
          short-heading: self.store.sidebar.at("short-heading", default: true),
        )
      },
    )
  } else if self.store.navigation == "mini-slides" {
    // components.mini-slides(
    //   self: self,
    //   fill: self.colors.primary,
    //   alpha: self.store.alpha,
    //   display-section: self.store.mini-slides.at("display-section", default: false),
    //   display-subsection: self.store.mini-slides.at("display-subsection", default: true),
    //   short-heading: self.store.mini-slides.at("short-heading", default: true),
    // )
    flowcomponents.mini-slides(
      self: self,
      fill: self.colors.primary,
      alpha: self.store.alpha,
      display-section: self.store.mini-slides.at("display-section", default: false),
      display-subsection: self.store.mini-slides.at("display-subsection", default: true),
      short-heading: self.store.mini-slides.at("short-heading", default: true),
    )
  }

  
}

//页脚
#let flow-footer(self) = {
  set align(bottom)
  set text(size: 0.8em)
  show: pad.with(.5em)
  components.left-and-right(
    grid(
  rows: (1fr,1fr),
  gutter: 3pt,
  text(fill: self.colors.primary, utils.call-or-display(self, self.store.footer), size: .8em),
  text(fill: self.colors.primary.lighten(40%), utils.call-or-display(self, self.store.footer-alt), size: .7em),
),
    
    text(fill: self.colors.primary, utils.call-or-display(self, self.store.footer-right), size: 1em),
  )
}

/// Default slide function for the presentation.
///
/// - `config` is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - `repeat` is the number of subslides. Default is `auto`，which means touying will automatically calculate the number of subslides.
///
///   The `repeat` argument is necessary when you use `#slide(repeat: 3, self => [ .. ])` style code to create a slide. The callback-style `uncover` and `only` cannot be detected by touying automatically.
///
/// - `setting` is the setting of the slide. You can use it to add some set/show rules for the slide.
///
/// - `composer` is the composer of the slide. You can use it to set the layout of the slide.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]] will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - `..bodies` is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
/// 好的，去掉注释后的内容如下：

// - `config` 是幻灯片的配置。你可以使用 `config-xxx` 来设置幻灯片的配置。要进行更多的配置，你可以使用 `utils.merge-dicts` 将多个配置合并。

// - `repeat` 是子幻灯片的数量。默认值为 `auto`，这意味着 touying 将自动计算子幻灯片的数量。

//   当你使用 `#slide(repeat: 3, self => [ .. ])` 样式代码创建幻灯片时，`repeat` 参数是必需的。回调样式的 `uncover` 和 `only` 不能被 touying 自动检测到。

// - `setting` 是幻灯片的设置。你可以使用它为幻灯片添加一些设置/显示规则。

// - `composer` 是幻灯片的布局。你可以用它来设置幻灯片的布局。

//   例如，`#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` 将幻灯片分为三部分。第一部分和最后一部分各占幻灯片的 1/4，第二部分占幻灯片的 1/2。

//   如果传递一个非函数值（如 `(1fr, 2fr, 1fr)`），它将被视为 `components.side-by-side` 函数的第一个参数。

//   `components.side-by-side` 函数是 `grid` 函数的简单封装。这意味着你可以使用 `grid.cell(colspan: 2, ..)` 让单元格占据两列。

//   例如，`#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` 会让 `Footer` 单元格占据两列。

//   如果你想自定义布局，可以将一个函数传递给 `composer` 参数。该函数应该接收幻灯片的内容并返回幻灯片的内容，如 `#slide(composer: grid.with(columns: 2))[A][B]`。

// - `..bodies` 是幻灯片的内容。你可以使用 `#slide[A][B][C]` 这样的语法调用 `slide` 函数来创建一个幻灯片。
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-lightest,
      header: flow-header,
      footer: flow-footer,
    ),
    config-common(subslide-preamble: self.store.subslide-preamble),
  )
  let new-setting(body) = {
    set text(fill: self.colors.neutral-darkest)
    setting(body)
  }
  touying-slide(self: self, config: config, repeat: repeat, setting: setting, composer: composer, ..bodies)
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: flow-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.city,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle], extra: [Extra information])
/// ```
///
/// - `extra` is the extra information you want to display on the title slide.
#let title-slide(
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = {
    set text(fill: self.colors.neutral-darkest)
    set align(center + horizon)
    block(
      width: 100%,
      inset: 3em,
      {
        block(
          fill: self.colors.neutral-light,
          inset: 1em,
          width: 100%,
          radius: 0.2em,
          text(size: 1.3em, fill: self.colors.primary, text(weight: "medium", info.title)) + (
            if info.subtitle != none {
              linebreak()
              text(size: 0.9em, fill: self.colors.primary, info.subtitle)
            }
          ),
        )
        set text(size: .8em)
        if info.author != none {
          block(spacing: 1em, info.author)
        }
        v(1em)
        if info.date != none {
          block(spacing: 1em, utils.display-info-date(self))
        }
        set text(size: .8em)
        if info.institution != none {
          block(spacing: 1em, info.institution)
        }
        if extra != none {
          block(spacing: 1em, extra)
        }
      },
    )
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.neutral-lightest, margin: 0em),
  )
  touying-slide(self: self, body)
})


/// Outline slide for the presentation.
#let outline-slide(title: utils.i18n-outline-title, ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-lightest,
      footer: flow-footer,
    ),
  )
  touying-slide(
    self: self,
    components.adaptive-columns(
      start: text(
        1.2em,
        fill: self.colors.primary,
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


/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - `title` is the title of the slide. Default is `utils.i18n-outline-title`.
///
/// - `body` is the contents of the slide.
#let new-section-slide(title: utils.i18n-outline-title, ..args, body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      fill: self.colors.neutral-lightest,
      footer: none,
      header: none,
      margin: (top: 1.5em, bottom: 1.5em),
    ),
  )
  touying-slide(
    self: self,
    components.adaptive-columns(
      start: align(right)[#text(
        2em,
        fill: self.colors.primary,
        weight: "bold",
        utils.call-or-display(self, title),
        // font: Ar,
      )],
      // text("123"),
      text(
        fill: self.colors.neutral-darkest,
        // font: Xe,
        // font:"Times New Roman",
        flowcomponents.progressive-outline(alpha: self.store.alpha, title: none, indent: 1em, depth: self.slide-level, ..args),
      ),
    ),
  )
})


/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
#let focus-slide(body) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.primary, margin: 2em),
  )
  set text(fill: self.colors.neutral-lightest, size: 1.5em)
  touying-slide(self: self, align(horizon + center, body))
})

#let end-slide(outline-size:.8em,body) = touying-slide-wrapper(self =>{
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    // config-page(fill: self.colors.primary, margin: 2em),
    // config-page(
    //   footer:  flow-footer,
    // )
  )
  
  touying-slide(
    self: self,
    grid(
      columns: (2fr,1fr),
      {
      set text(fill: self.colors.primary, size: 2em)
      block(height: 100%, width: 100%,align(horizon+center,body))
      },
      place(
      right + top,
      {
        // v(4em)
        show: block.with(width: self.store.sidebar.width, inset: (x:0em))
        set align(left)
        set par(justify: false)
        set text(size: outline-size)
        components.adaptive-columns(
          text(
            outline(title: none, indent: .5em, depth: none, fill: none)
          )
        )

        // components.custom-progressive-outline(
        //   self: self,
        //   level: auto,
        //   alpha: self.store.alpha,
        //   text-fill: (self.colors.primary, self.colors.neutral-darkest),
        //   text-size: (1em, .9em),
        //   vspace: (-.2em,),
        //   indent: (0em, self.store.sidebar.at("indent", default: .5em)),
        //   fill: (self.store.sidebar.at("fill", default: _typst-builtin-repeat[.]),),
        //   filled: (self.store.sidebar.at("filled", default: false),),
        //   paged: (self.store.sidebar.at("paged", default: false),),
        //   short-heading: self.store.sidebar.at("short-heading", default: true),
        // )
      })
    )
  )
})

/// Touying flow theme.
///
/// Example:
///
/// ```typst
/// #show: flow-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// - `aspect-ratio` is the aspect ratio of the slides. Default is `16-9`.
///
/// - `navigation` is the navigation of the slides. You can choose from `"sidebar"`, `"mini-slides"`, and `none`. Default is `"sidebar"`.
///
/// - `sidebar` is the configuration of the sidebar. You can set the width, filled, numbered, indent, and short-heading of the sidebar. Default is `(width: 10em, filled: false, numbered: false, indent: .5em, short-heading: true)`.
///   - `width` is the width of the sidebar.
///   - `filled` is whether the outline in the sidebar is filled.
///   - `numbered` is whether the outline in the sidebar is numbered.
///   - `indent` is the indent of the outline in the sidebar.
///   - `short-heading` is whether the outline in the sidebar is short.
///
/// - `mini-slides` is the configuration of the mini-slides. You can set the height, x, display-section, display-subsection, and short-heading of the mini-slides. Default is `(height: 4em, x: 2em, display-section: false, display-subsection: true, short-heading: true)`.
///   - `height` is the height of the mini-slides.
///   - `x` is the x of the mini-slides.
///   - `display-section` is whether the slides of section is displayed in the mini-slides.
///   - `display-subsection` is whether we add linebreak between subsections.
///   - `short-heading` is whether the mini-slides is short. Default is `true`.
///
/// - `footer` is the footer of the slides. Default is `none`.
///
/// - `footer-right` is the right part of the footer. Default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// - `primary` is the primary color of the slides. Default is `rgb("#0c4842")`.
///
/// - `alpha` is the alpha of transparency. Default is `60%`.
///
/// - `outline-title` is the title of the outline. Default is `utils.i18n-outline-title`.
///
/// - `subslide-preamble` is the preamble of the subslide. Default is `self => block(text(1.2em, weight: "bold", fill: self.colors.primary, utils.display-current-heading(depth: self.slide-level)))`.
///
/// ----------------------------------------
///
/// The default colors:
///
/// ```typ
/// config-colors(
///   neutral-darkest: rgb("#000000"),
///   neutral-dark: rgb("#202020"),
///   neutral-light: rgb("#f3f3f3"),
///   neutral-lightest: rgb("#ffffff"),
///   primary: rgb("#0c4842"),
/// )
/// ```
#let flow-theme(
  aspect-ratio: "16-9",
  navigation: "sidebar",
  sidebar: (width: 10em, filled: false, numbered: false, indent: .5em, short-heading: true),
  mini-slides: (height: 3em, x: 2em, display-section: false, display-subsection: true, short-heading: true),
  footer: none,
  footer-alt: none,
  footer-right: context utils.slide-counter.display() + " / " + utils.last-slide-number,
  primary: rgb("#004098"),
  secondary: rgb("#543795"),
  alpha: 25%,
  subslide-preamble: self => block(
    text(1.2em, weight: "bold", fill: self.colors.primary, utils.display-current-heading(depth: self.slide-level)),
  ),
  ..args,
  body,
) = {
  set text(size: 20pt)
  set par(justify: true)

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: if navigation == "sidebar" {
        (top: 2em, bottom: 1em, x: sidebar.width)
      } else if navigation == "mini-slides" {
        (top: mini-slides.height, bottom: 2em, x: mini-slides.x)
      } else {
        (top: 2em, bottom: 2em, x: mini-slides.x)
      },
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
        init: (self: none, body) => {
        show strong: self.methods.alert.with(self: self)
        show heading: set text(self.colors.primary)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      neutral-darkest: rgb("#000000"),
      neutral-dark: rgb("#202020"),
      neutral-light: rgb("#f3f3f3"),
      neutral-lightest: rgb("#ffffff"),
      primary: primary,
    ),
    // save the variables for later use
    config-store(
      navigation: navigation,
      sidebar: sidebar,
      mini-slides: mini-slides,
      footer: footer,
      footer-alt:footer-alt,
      footer-right: footer-right,
      alpha: alpha,
      subslide-preamble: subslide-preamble,
    ),
    ..args,
  )
  show: codly-init.with()

  show emph: it => {  
    underline(stroke: (thickness: 1em, paint: primary.transparentize(95%), cap: "round"),offset: -7pt,background: true,evade: false,extent: -8pt,text(primary, it.body))
  }

  show outline.entry.where(
    level: 1
  ): it => {
    v(1em, weak: true)
    text(primary, it.body)
  }

  show :show-cn-fakebold // Used to display bold Chinese text

  // codly(
  //   display-icon: true,
  //   // default-color: rgb("#283593"),
  //   fill: rgb("ffffff").transparentize(100%),
  //   stroke: 1pt + luma(200),
  //   // fill:none,
  //   zebra-fill: luma(0).transparentize(96%),
  //   breakable: true,
  //   // number-format: none,
  // )

  body
}