// ShuimuTouying
// a THU Touying theme.
// Authors: Mason Chen
// Inspired by Stargazer theme

#import "@preview/touying:0.7.4": *


/// 主题颜色配置。
#let shuimu-colors(
  primary: rgb("#660874"),
  primary-dark: rgb("#320439"),
  neutral-lightest: rgb("#ffffff"),
  neutral-darkest: rgb("#000000"),
) = (
  primary: primary,
  primary-dark: primary-dark,
  neutral-lightest: neutral-lightest,
  neutral-darkest: neutral-darkest,
)

/// 主题字体与字号配置。
#let shuimu-fonts(
  main: ("Linux Libertine", "Palatino", "Noto Serif CJK SC", "Songti SC"),
  body-size: 20pt,
  navigation-size: 0.7em,
  title-slide-title-size: 1.2em,
  title-slide-subtitle-size: 1.0em,
  title-slide-info-size: 0.7em,
  outline-size: 1.2em,
  outline-number-size: 0.75em,
  section-title-size: 2.5em,
  section-body-size: 0.8em,
  focus-size: 1.5em,
  footer-size: 0.5em,
  caption-size: 0.6em,
  footnote-size: 0.6em,
  header-title-size: 1.3em,
) = (
  main: main,
  body-size: body-size,
  navigation-size: navigation-size,
  title-slide-title-size: title-slide-title-size,
  title-slide-subtitle-size: title-slide-subtitle-size,
  title-slide-info-size: title-slide-info-size,
  outline-size: outline-size,
  outline-number-size: outline-number-size,
  section-title-size: section-title-size,
  section-body-size: section-body-size,
  focus-size: focus-size,
  footer-size: footer-size,
  caption-size: caption-size,
  footnote-size: footnote-size,
  header-title-size: header-title-size,
)


/// 基础视觉组件

/// Shuimu 主题列表标记：复用 Touying knob marker，并按默认正文字体做视觉垂直对齐。
#let _shuimu-list-marker(primary: rgb("#005bac")) = move(
  dy: -0.7em,
  components.knob-marker(primary: primary),
)

/// 渲染带标题栏的内容块，用于公式、定理、定义等需要被强调的内容。
#let _render-titled-block(self: none, title: none, body) = {
  block(
    breakable: false,
    grid(
      columns: 1,
      row-gutter: 0pt,

      // 顶部标题栏
      block(
        fill: self.colors.primary,
        width: 100%,
        radius: (top: 6pt),
        inset: (top: 0.4em, bottom: 0.3em, left: 0.5em, right: 0.5em),
        text(fill: self.colors.neutral-lightest, weight: "bold", title),
      ),

      // 连接标题栏和内容区的渐变分割线
      rect(
        fill: gradient.linear(
          self.colors.primary,
          self.colors.primary.lighten(90%),
          angle: 90deg,
        ),
        width: 100%,
        height: 4pt,
      ),

      // 内容区
      block(
        fill: self.colors.primary.lighten(90%),
        width: 100%,
        radius: (bottom: 6pt),
        inset: (top: 0.4em, bottom: 0.5em, left: 0.5em, right: 0.5em),
        body,
      ),
    ),
  )
}

/// 带标题栏的内容块，可在正文页中强调公式、定理、定义或阶段性结论。
#let titled-block(title: none, body) = touying-fn-wrapper(
  _render-titled-block.with(
    title: title,
    body,
  ),
)

/// 收集 mini-frame 和目录页使用的章节导航数据。
///
/// 返回值中的每个章节包含：
/// - heading-title: 一级标题内容。
/// - heading-location: 一级标题位置，用于链接回章节起点。
/// - slide-markers: 该章节下可导航的物理页标记，已排除 focus-slide 与 Touying skip 页。
#let _collect-navigation-sections() = {
  let section-headings = query(heading.where(level: 1, outlined: true))

  if section-headings.len() == 0 {
    ()
  } else {
    let focus-slide-skip-pages = query(<touying-skip-dot>).map(s => s
      .location()
      .page())
    let touying-skip-pages = query(<touying:skip>).map(s => s.location().page())
    let skipped-pages = focus-slide-skip-pages + touying-skip-pages
    let heading-pages = section-headings.map(heading => heading
      .location()
      .page())
    let slide-marker-locations = query(<touying-slide-page>).map(
      marker => marker.location(),
    )
    let slide-pages = slide-marker-locations.map(location => location.page())
    let known-pages = heading-pages + skipped-pages + slide-pages
    let last-known-page = calc.max(..known-pages)
    let navigation-sections = ()

    for (section-index, heading) in section-headings.enumerate() {
      let section-start-page = heading.location().page()
      let section-end-page = if section-index + 1 < section-headings.len() {
        section-headings.at(section-index + 1).location().page()
      } else {
        last-known-page + 1
      }

      navigation-sections.push((
        heading-title: heading.body,
        heading-location: heading.location(),
        slide-markers: slide-marker-locations
          .filter(location => (
            section-start-page <= location.page()
              and location.page() < section-end-page
          ))
          .filter(location => location.page() not in skipped-pages)
          .map(location => (page: location.page(), location: location)),
      ))
    }

    navigation-sections
  }
}


/// Mini-frames 导航栏
#let _render-mini-frame-navigation(self: none) = {
  let navigation-background = self.colors.primary-dark
  let navigation-text-color = self.colors.neutral-lightest
  let fonts = self.store.fonts

  context {
    let navigation-sections = _collect-navigation-sections()
    let current-page = here().page()

    // 当前章节是起始页不晚于当前页的最后一个一级标题。
    let current-section-index = -1
    for (section-index, section) in navigation-sections.enumerate() {
      if section.heading-location.page() <= current-page {
        current-section-index = section-index
      }
    }

    block(
      width: 100%,
      fill: navigation-background,
      inset: (top: 0.6em, bottom: 0.4em, x: 2em),
      {
        set text(size: fonts.navigation-size)
        set align(left + horizon)

        grid(
          columns: navigation-sections.map(_ => auto),
          column-gutter: 1.5em,

          ..navigation-sections
            .enumerate()
            .map(((section-index, section)) => {
              let is-current-section = (section-index == current-section-index)

              // 激活章节用实色，非激活章节降低透明度。
              let navigation-item-color = if is-current-section {
                navigation-text-color
              } else {
                navigation-text-color.transparentize(60%)
              }

              let section-title-link = link(
                section.heading-location,
                text(
                  fill: navigation-item-color,
                  weight: "bold",
                  section.heading-title,
                ),
              )

              let slide-dot-links = if section.slide-markers.len() > 0 {
                stack(
                  dir: ltr,
                  spacing: 4pt,
                  ..section.slide-markers.map(slide-marker => {
                    let is-current-slide-marker = (
                      slide-marker.page == current-page
                    )

                    link(
                      slide-marker.location,
                      box(
                        circle(
                          radius: 2.5pt,
                          stroke: (
                            paint: navigation-item-color,
                            thickness: 0.8pt,
                          ),
                          fill: if is-current-slide-marker {
                            navigation-item-color
                          } else {
                            none
                          },
                        ),
                      ),
                    )
                  }),
                )
              } else {
                v(5pt)
              }

              stack(
                dir: ttb,
                spacing: 0.4em,
                section-title-link,
                slide-dot-links,
              )
            })
        )
      },
    )
  }
}




/// 页面蓝图
/// 这里定义了不同类型的幻灯片（普通页、封面、目录、章节页、结束页）的逻辑

/// 1. 正文页 (Slide)
///
/// 继承主题默认页眉、页脚与正文对齐方式，也允许单页临时覆盖这些设置。
#let slide(
  title: auto,
  header: auto,
  footer: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  // 处理参数覆盖：如果用户传入了特定的 header/footer，覆盖全局 store
  if align != auto {
    self.store.align = align
  }
  if title != auto {
    self.store.header-title = title
  }
  if header != auto {
    self.store.slide-header = header
  }
  if footer != auto {
    self.store.footer-bar = footer
  }
  let slide-setting = body => {
    show: std.align.with(self.store.align)
    show: setting
    // mini-frame 导航通过这个隐藏标记定位每一张物理页。
    [#hide[#"" <touying-slide-page>]]
    body
  }
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: slide-setting,
    composer: composer,
    ..bodies,
  )
})


/// 2. 封面页 (Title Slide)

/// 将同一角色下的多人姓名拆成固定列数的网格，避免封面人员列表过宽。
#let _render-cover-person-grid(
  self: none,
  role-label,
  person-list,
  max-person-columns: 3,
) = {
  if person-list.len() == 0 {
    none
  } else {
    let grid-cells = ()

    let row-start = 0
    let role-row-index = 0
    while row-start < person-list.len() {
      let person-row = person-list.slice(row-start, calc.min(
        row-start + max-person-columns,
        person-list.len(),
      ))

      grid-cells.push(text(fill: self.colors.neutral-darkest, if role-row-index
        == 0 {
        role-label
      } else { [] }))
      for person in person-row {
        grid-cells.push(text(
          fill: self.colors.primary,
          weight: "bold",
          person,
        ))
      }
      grid-cells += ([],) * (max-person-columns - person-row.len())

      row-start += max-person-columns
      role-row-index += 1
    }

    grid(
      columns: (auto,) + (auto,) * max-person-columns,
      column-gutter: 0.5em,
      row-gutter: 0.5em,
      ..grid-cells,
    )
  }
}

/// 封面页。
#let title-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
  )
  self.store.header-title = none // 封面不需要页眉标题
  let presentation-info = self.info + args.named()

  let ensure-array(value) = if type(value) == array { value } else { (value,) }

  // 封面将每个角色渲染为一组“角色标签 + 人员姓名”行。
  let cover-person-groups = ()
  if "author" in presentation-info and presentation-info.author != none {
    cover-person-groups.push(("作者：", ensure-array(presentation-info.author)))
  }
  if "reporter" in presentation-info and presentation-info.reporter != none {
    cover-person-groups.push((
      "报告人：",
      ensure-array(presentation-info.reporter),
    ))
  }
  if (
    "supervisor" in presentation-info and presentation-info.supervisor != none
  ) {
    cover-person-groups.push((
      "导师：",
      ensure-array(presentation-info.supervisor),
    ))
  }

  let title-slide-body = {
    let fonts = self.store.fonts

    show: std.align.with(center + horizon)
    // 标题框
    block(
      fill: self.colors.primary,
      inset: 1.5em,
      radius: 0.5em,
      breakable: false,
      {
        text(
          size: fonts.title-slide-title-size,
          fill: self.colors.neutral-lightest,
          weight: "bold",
          presentation-info.title,
        )
        if presentation-info.subtitle != none {
          parbreak()
          text(
            size: fonts.title-slide-subtitle-size,
            fill: self.colors.neutral-lightest,
            weight: "bold",
            presentation-info.subtitle,
          )
        }
      },
    )

    // 人员列表（每个角色一行，前缀 + 姓名横排，整体居中）
    for (role-label, person-list) in cover-person-groups {
      align(center, _render-cover-person-grid(
        self: self,
        role-label,
        person-list,
      ))
    }
    v(0.5em)

    // 机构与日期
    if presentation-info.institution != none {
      parbreak()
      text(size: fonts.title-slide-info-size, presentation-info.institution)
    }
    if presentation-info.date != none {
      parbreak()
      text(size: fonts.title-slide-info-size, utils.display-info-date(self))
    }
  }
  touying-slide(self: self, title-slide-body)
})



/// 3. 目录页 (Outline Slide)

/// 目录页基于一级标题生成章节列表，并链接到每个章节起点。
#let outline-slide(
  config: (:),
  title: utils.i18n-outline-title,
) = touying-slide-wrapper(self => {
  self.store.header-title = title
  touying-slide(
    self: self,
    config: config,
    std.align(
      self.store.align,
      context {
        let fonts = self.store.fonts

        set text(
          fill: self.colors.primary-dark,
          weight: "bold",
          size: fonts.outline-size,
        )

        let navigation-sections = _collect-navigation-sections()

        if navigation-sections.len() > 0 {
          stack(
            dir: ttb,
            spacing: 1.5em,
            ..navigation-sections
              .enumerate()
              .map(((section-index, section)) => {
                let section-number-badge = box(
                  width: 1.1em,
                  height: 1.1em,
                  radius: 50%,
                  fill: self.colors.primary,
                  place(
                    center + horizon,
                    text(
                      fill: self.colors.neutral-lightest,
                      weight: "bold",
                      size: fonts.outline-number-size,
                      top-edge: "bounds",
                      bottom-edge: "bounds",
                      str(section-index + 1),
                    ),
                  ),
                )
                box(
                  stack(
                    dir: ltr,
                    spacing: 0.5em,
                    section-number-badge,
                    link(section.heading-location, section.heading-title),
                  ),
                )
              }),
          )
        } else {
          [No sections found.]
        }
      },
    ),
  )
})


/// 4. 章节页 (New Section Slide)
/// 本质上是带标题的目录页

#let new-section-slide(
  config: (:),
  title: auto,
  ..args,
) = touying-slide-wrapper(self => {
  let section-slide-body = args.pos().sum(default: none)

  touying-slide(
    self: self,
    config: config,
    std.align(center + horizon, {
      let fonts = self.store.fonts

      let section-title = if title != auto {
        title
      } else {
        utils.display-current-heading(level: 1)
      }
      text(
        fill: self.colors.primary,
        weight: "bold",
        size: fonts.section-title-size,
        section-title,
      )
      if section-slide-body != none {
        parbreak()
        v(0.5em)
        text(
          fill: self.colors.primary,
          weight: "bold",
          size: fonts.section-body-size,
          section-slide-body,
        )
      }
    }),
  )
})


/// 5. 焦点页 (Focus Slide)

/// 用纯色背景展示短句或 Q&A，且不计入幻灯片页码。
#let focus-slide(
  config: (:),
  align: horizon + center,
  body,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: self.colors.primary,
      margin: 2em,
      header: none,
      footer: none,
    ),
  )
  set text(
    fill: self.colors.neutral-lightest,
    weight: "bold",
    size: self.store.fonts.focus-size,
  )
  touying-slide(self: self, config: config, {
    [#hide[#"" <touying-skip-dot>]]
    std.align(align, body)
  })
})


/// 主题入口与全局配置。
///
/// header-title 控制普通页页眉标题；footer-* 参数分别控制页脚中的报告人、
/// 作者、报告标题与页码计数。

#let shuimu-touying-theme(
  aspect-ratio: "16-9",
  align: horizon,
  theme-colors: shuimu-colors(),
  theme-fonts: shuimu-fonts(),
  display-section-slides: false, // 是否显示章节页
  header-title: self => utils.display-current-heading(depth: self.slide-level),
  footer-reporter: self => if "reporter" in self.info
    and self.info.reporter != none {
    self.info.reporter
  } else {
    self.info.author
  },

  footer-author: self => self.info.author,

  footer-deck-title: self => if self.info.short-title == auto {
    self.info.title
  } else {
    self.info.short-title
  },

  footer-slide-counter: context utils.slide-counter.display()
    + " / "
    + utils.last-slide-number,
  ..args,
  body,
) = {
  let fonts = theme-fonts
  // 定义全局页眉布局
  let render-header(self) = {
    set std.align(top)
    set text(font: fonts.main)
    stack(
      dir: ttb, // 从上到下排列
      spacing: 0em, // 去除中间的缝隙

      // 1. 顶部的导航栏
      _render-mini-frame-navigation(self: self),

      // 2. 下面的幻灯片标题栏
      utils.call-or-display(self, self.store.slide-header),
    )
  }

  // 定义全局页脚布局
  let render-footer(self) = {
    set text(font: fonts.main, size: fonts.footer-size)
    set std.align(center + bottom)
    utils.call-or-display(self, self.store.footer-bar)
  }

  // 初始化 Touying 系统(组装主题)
  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      header: render-header,
      footer: render-footer,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 4.5em, bottom: 2.5em, x: 2.5em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: if display-section-slides {
        new-section-slide
      } else {
        none
      },
      receive-body-for-new-section-slide-fn: true,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(font: fonts.main, size: fonts.body-size)
        set list(marker: _shuimu-list-marker(primary: self.colors.primary))
        show figure.caption: set text(size: fonts.caption-size)
        show footnote.entry: set text(size: fonts.footnote-size)
        show heading: set text(fill: self.colors.primary, weight: "black")
        set super(typographic: false) // 关闭字体默认的上标样式，防止冲突
        show link: link-element => if type(link-element.dest) == str {
          set text(fill: self.colors.primary)
          link-element
        } else {
          link-element
        }
        show figure.where(kind: table): set figure.caption(position: top)
        body
      },
      alert: utils.alert-with-primary-color,
      titled-block: _render-titled-block,
    ),
    config-colors(..theme-colors),
    // 将主题配置保存到 Touying store，供页眉、页脚和单页覆盖逻辑读取。
    config-store(
      align: align,
      fonts: fonts,
      header-title: header-title,
      footer-reporter: footer-reporter,
      footer-author: footer-author,
      footer-deck-title: footer-deck-title,
      footer-slide-counter: footer-slide-counter,

      slide-header: self => if self.store.header-title != none {
        block(
          width: 100%,
          height: 1.8em,
          fill: self.colors.primary,
          place(
            left + horizon,
            text(
              fill: self.colors.neutral-lightest,
              weight: "bold",
              size: self.store.fonts.header-title-size,
              utils.call-or-display(self, self.store.header-title),
            ),
            dx: 1.5em,
          ),
        )
      },

      footer-bar: self => {
        show strong: strong-content => strong-content.body
        let footer-cell(fill: none, content) = rect(
          width: 100%,
          height: 100%,
          inset: 1mm,
          outset: 0mm,
          fill: fill,
          stroke: none,
          std.align(horizon, text(fill: self.colors.neutral-lightest, content)),
        )

        let footer-reporter-content = utils.call-or-display(
          self,
          self.store.footer-reporter,
        )
        let footer-author-content = utils.call-or-display(
          self,
          self.store.footer-author,
        )
        let footer-title-content = utils.call-or-display(
          self,
          self.store.footer-deck-title,
        )
        let footer-counter-content = utils.call-or-display(
          self,
          self.store.footer-slide-counter,
        )

        grid(
          columns: (
            if footer-reporter-content != none { 15% } else { 0pt },
            if footer-author-content != none { 15% } else { 0pt },
            1fr,
            5em,
          ),
          rows: 1.5em,
          footer-cell(fill: self.colors.primary, if footer-reporter-content
            != none { footer-reporter-content }),
          footer-cell(fill: self.colors.primary, if footer-author-content
            != none { footer-author-content }),
          footer-cell(fill: self.colors.primary, footer-title-content),
          footer-cell(fill: self.colors.primary, footer-counter-content),
        )
      },
    ),
    ..args,
  )

  body
}
