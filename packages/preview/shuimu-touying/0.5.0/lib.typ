// shuimu-touying：清华紫配色的 Touying 幻灯片主题，版式参考 thubeamer。
// 派生自 Touying 的 Stargazer 主题（MIT），版权声明见 NOTICE。
// Author: Mason Chen

#import "@preview/touying:0.8.0": *


// ───── 主题配置 ─────

/// 主题配色。primary-dark 为 auto 时由 primary 加深得到。
#let shuimu-colors(
  primary: rgb("#660874"),
  primary-dark: auto,
  neutral-lightest: rgb("#ffffff"),
  neutral-darkest: rgb("#000000"),
) = (
  primary: primary,
  primary-dark: if primary-dark == auto { primary.darken(50%) } else {
    primary-dark
  },
  neutral-lightest: neutral-lightest,
  neutral-darkest: neutral-darkest,
)

/// 主题字体与字号。字号是相对正文的 em 值，outline-number-size 相对目录文字。
#let shuimu-fonts(
  main: ("Libertinus Serif", "Noto Serif CJK SC"),
  mono: "DejaVu Sans Mono",
  math: "New Computer Modern Math",
  body-size: 20pt,
  navigation-size: 0.7em,
  header-title-size: 1.3em,
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
) = (
  main: main,
  mono: mono,
  math: math,
  body-size: body-size,
  navigation-size: navigation-size,
  header-title-size: header-title-size,
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
)


// ───── 内部工具 ─────

/// 把单个值包成数组。
#let _to-array(value) = if type(value) == array { value } else { (value,) }

/// 把多人姓名连成一段文字，分隔符随 text.lang 变化。
#let _join-names(names) = context names.join(
  if text.lang == "zh" { "、" } else { ", " },
)

/// 主色背景上的文字样式：浅色文字；strong（Touying 默认渲染为主色 alert）和标题不再染成主色。
#let _on-primary(self, body) = {
  set text(fill: self.colors.neutral-lightest)
  show strong: it => text(weight: "bold", it.body)
  show heading: set text(fill: self.colors.neutral-lightest)
  body
}

// ───── 内容块 ─────

/// 渲染 titled-block：标题栏、渐变分隔线和内容区。内容区固定用正文颜色，放在焦点页里也能看清。
#let _render-titled-block(self: none, title: none, body) = {
  let body-fill = self.colors.primary.lighten(90%)
  let title-bar = if title != none {
    (
      block(
        width: 100%,
        fill: self.colors.primary,
        radius: (top: 6pt),
        inset: (top: 0.4em, bottom: 0.3em, x: 0.5em),
        _on-primary(self, text(weight: "bold", title)),
      ),
      rect(
        width: 100%,
        height: 4pt,
        fill: gradient.linear(self.colors.primary, body-fill, angle: 90deg),
      ),
    )
  }
  block(breakable: false, stack(
    ..title-bar,
    block(
      width: 100%,
      fill: body-fill,
      radius: if title == none { 6pt } else { (bottom: 6pt) },
      inset: (top: 0.4em, bottom: 0.5em, x: 0.5em),
      {
        set text(fill: self.colors.neutral-darkest)
        body
      },
    ),
  ))
}

/// 带标题栏的内容块。内容以位置参数交给 touying-fn-wrapper-raw，Touying 才会解析其中的动画；标题不解析。
#let titled-block(title: none, body) = touying-fn-wrapper-raw(
  _render-titled-block.with(title: title),
  body,
)


// ───── mini-frame 导航 ─────

/// 收集导航栏和目录页用的章节数据，返回字典数组，字段为 heading、start、end、slides；
/// slides 为 (start, end) 字典数组，所有区间都是不含 end 的页码区间。
/// 章节由进入目录的一级标题和带 <touying:unoutlined>/<touying:hidden> 的一级标题划分（只返回前者），
/// 其他不进目录的一级标题（如 #outline() 自带的）不参与划分。
/// 带 <shuimu-nav-slide> 标记的幻灯片各对应一个圆点，区间到下一张幻灯片为止，动画子页和续页共用。
#let _collect-navigation-sections() = {
  // 把起始页码序列配成 (start, end)，最后一项的 end 为无穷
  let page-ranges(starts) = starts.zip(starts.slice(1) + (calc.inf,))
  let slide-starts = query(<touying-metadata>)
    .filter(it => (
      type(it.value) == dictionary
        and it.value.at("kind", default: none) == "touying-new-slide"
    ))
    .map(it => it.location().page())
  let navigable-pages = query(<shuimu-nav-slide>).map(it => it.location().page())
  let slides = page-ranges(slide-starts)
    .filter(((start, _)) => start in navigable-pages)
    .map(((start, end)) => (start: start, end: end))

  let section-headings = query(heading.where(level: 1)).filter(it => (
    it.outlined
      or (
        it.has("label")
          and str(it.label) in ("touying:unoutlined", "touying:hidden")
      )
  ))
  section-headings
    .zip(page-ranges(section-headings.map(it => it.location().page())))
    .filter(((section-heading, _)) => section-heading.outlined)
    .map(((section-heading, (start, end))) => (
      heading: section-heading,
      start: start,
      end: end,
      slides: slides.filter(slide => start <= slide.start and slide.start < end),
    ))
}

/// 页眉顶部的导航栏：每章一列（章节名加一行圆点），高亮当前章节和幻灯片；放不下时整体缩小到一行。
#let _render-mini-frame-navigation(self) = context {
  let sections = _collect-navigation-sections()
  if sections == () { return }
  let current-page = here().page()
  let is-current(item) = item.start <= current-page and current-page < item.end
  let dot-radius = 2.5pt
  let dot-gap = 4pt

  let slide-dot(slide, color) = link(
    (page: slide.start, x: 0pt, y: 0pt), // 页坐标比 location 解析得快
    box(circle(
      radius: dot-radius,
      stroke: (paint: color, thickness: 0.8pt),
      fill: if is-current(slide) { color },
    )),
  )

  // 章节列：章节名在上，固定高度的圆点行在下，没有圆点的章节也能对齐
  let section-column(title, dot-row) = stack(
    spacing: 0.4em,
    title,
    box(height: 2 * dot-radius, dot-row),
  )
  let render-section(section) = {
    let color = if is-current(section) {
      self.colors.neutral-lightest
    } else {
      self.colors.neutral-lightest.transparentize(60%)
    }
    section-column(
      link(
        section.heading.location(),
        text(fill: color, weight: "bold", section.heading.body),
      ),
      stack(
        dir: ltr,
        spacing: dot-gap,
        ..section.slides.map(slide => slide-dot(slide, color)),
      ),
    )
  }
  // 测量用的骨架：与 render-section 同尺寸，但没有链接、颜色和圆点，排版开销小得多
  let skeleton-section(section) = section-column(
    text(weight: "bold", section.heading.body),
    box(width: calc.max(
      0pt,
      section.slides.len() * (2 * dot-radius + dot-gap) - dot-gap,
    )),
  )
  // 各章横向排开；stack 只排一遍，auto 列的 grid 要为列宽、行高各多测一遍
  let navigation-row(cells) = stack(dir: ltr, spacing: 1.5em, ..cells)

  block(
    width: 100%,
    fill: self.colors.primary-dark,
    inset: (top: 0.6em, bottom: 0.4em, x: 2em),
    _on-primary(self, {
      set text(size: self.store.fonts.navigation-size)
      show linebreak: [ ] // 章节名里的手动换行在导航栏中压成一行
      // 在 layout 中测量才能用上前面的 set/show 规则
      layout(size => {
        let natural = measure(navigation-row(sections.map(skeleton-section)))
        let navigation = navigation-row(sections.map(render-section))
        if natural.width <= size.width { navigation } else {
          // 不用 reflow（会再排一遍），按骨架尺寸直接给出缩放后的占位框；固定内部宽度，章节名才不折行
          let ratio = size.width / natural.width
          box(width: size.width, height: natural.height * ratio, scale(
            ratio * 100%,
            origin: top + left,
            box(width: natural.width, navigation),
          ))
        }
      })
    }),
  )
}


// ───── 页眉与页脚 ─────

/// 解析 store.header-title：函数先求值，auto 取当前标题（层级不超过 slide-level），没有标题时为 none。
/// 标题栏和备注面板共用；需在 context 中调用。
#let _resolve-header-title(self) = {
  let title = self.store.header-title
  if type(title) == function { title = title(self) }
  if title != auto { return title }
  let current = utils.current-heading(depth: self.slide-level)
  if current == none { return none }
  // 样式同 utils.display-current-heading 的默认值，但不再查第二遍标题
  if current.numbering != none {
    std.numbering(current.numbering, ..counter(heading).at(current.location()))
    h(.3em)
  }
  current.body
}

/// 导航栏下方的标题栏，没有标题时不显示；标题过长时缩小到一行。
#let _render-title-bar(self) = context {
  let title = _resolve-header-title(self)
  if title == none { return }
  block(
    width: 100%,
    inset: (x: 1.5em),
    fill: self.colors.primary,
    {
      set text(weight: "bold", size: self.store.fonts.header-title-size)
      block(height: 1.4em, std.align(
        left + horizon,
        _on-primary(self, utils.fit-to-width(grow: false, 100%, [#title])),
      ))
    },
  )
}

/// 页脚四栏。先求值（调用函数、拼接数组），值为 none 的栏收起。
#let _render-footer-bar(self) = {
  let resolve(it) = {
    if type(it) == function { it = it(self) }
    if it == () { it = none }
    if type(it) == array { it = _join-names(it) }
    if it != none { [#it] }
  }
  let cells = (
    (15%, self.store.footer-reporter),
    (15%, self.store.footer-author),
    (1fr, self.store.footer-deck-title),
    (5em, self.store.footer-slide-counter),
  )
    .map(((width, it)) => (width, resolve(it)))
    .filter(((_, it)) => it != none)

  block(
    width: 100%,
    height: 1.5em,
    fill: self.colors.primary,
    _on-primary(self, grid(
      columns: cells.map(((width, _)) => width),
      rows: 100%,
      inset: 1mm,
      align: center + horizon,
      ..cells.map(((_, it)) => utils.fit-to-width(grow: false, 100%, it)),
    )),
  )
}


// ───── 幻灯片 ─────

/// 正文页。参数覆盖本页 self 中的设置；插入 <shuimu-nav-slide> 标记（metadata，不参与排版）供导航识别。
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
  self = utils.merge-dicts(self, config)
  if title != auto { self.store.header-title = title }
  if header != auto { self.store.header = header }
  if footer != auto { self.store.footer = footer }
  if align != auto { self.store.align = align }
  let slide-setting = body => {
    show: std.align.with(self.store.align)
    show: setting
    [#metadata(none) <shuimu-nav-slide>]
    body
  }
  touying-slide(
    self: self,
    repeat: repeat,
    setting: slide-setting,
    composer: composer,
    ..bodies,
  )
})


/// 封面角色标签，按 text.lang 选择，缺省用英文。
#let _default-role-labels = (
  zh: (author: [作者：], reporter: [报告人：], supervisor: [导师：]),
  en: (author: [Author:], reporter: [Presenter:], supervisor: [Supervisor:]),
)

/// 封面上一个角色的人员网格：角色标签加姓名，每行最多三人。
#let _render-cover-person-grid(self, role-label, people) = grid(
  columns: 1 + calc.min(people.len(), 3),
  column-gutter: 0.5em,
  row-gutter: 0.5em,
  ..people
    .chunks(3)
    .enumerate()
    .map(((row-index, row)) => (
      if row-index == 0 { role-label },
      ..row.map(person => text(fill: self.colors.primary, weight: "bold", person)),
    ))
    .join(),
)

/// 封面页：标题框、作者/报告人/导师、机构和日期；命名参数临时覆盖 config-info。
#let title-slide(
  config: (:),
  role-labels: (:),
  ..overrides,
) = touying-slide-wrapper(self => {
  assert(
    overrides.pos().len() == 0,
    message: "title-slide 不接受位置参数，请用命名参数覆盖 config-info 中的字段",
  )
  self = utils.merge-dicts(self, config)
  self.store.header-title = none
  let info = self.info + overrides.named()
  let fonts = self.store.fonts

  let body = {
    if info.title != none {
      block(
        fill: self.colors.primary,
        inset: 1.5em,
        radius: 0.5em,
        breakable: false,
        _on-primary(self, {
          set text(weight: "bold")
          text(size: fonts.title-slide-title-size, info.title)
          if info.subtitle != none {
            parbreak()
            text(size: fonts.title-slide-subtitle-size, info.subtitle)
          }
        }),
      )
    }

    context {
      let labels = (
        _default-role-labels.at(text.lang, default: _default-role-labels.en)
          + role-labels
      )
      for role in ("author", "reporter", "supervisor") {
        let people = info.at(role, default: none)
        if people != none {
          _render-cover-person-grid(self, labels.at(role), _to-array(people))
        }
      }
    }
    v(0.5em)

    set text(size: fonts.title-slide-info-size)
    if info.institution != none {
      parbreak()
      info.institution
    }
    if info.date != none {
      parbreak()
      utils.display-info-date((..self, info: info))
    }
  }
  touying-slide(self: self, setting: std.align.with(center + horizon), body)
})


/// 目录页：列出章节并链接到起点。按实测高度选择最少的栏数（最多四栏），仍放不下时整体缩小。
#let outline-slide(
  config: (:),
  title: utils.i18n-outline-title,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(self, config)
  self.store.header-title = title
  let fonts = self.store.fonts

  // number 为 none 时只占位，不画徽标
  let number-badge(number) = box(
    width: 1.1em,
    height: 1.1em,
    radius: 50%,
    fill: if number != none { self.colors.primary },
    if number != none {
      place(center + horizon, text(
        fill: self.colors.neutral-lightest,
        size: fonts.outline-number-size,
        top-edge: "bounds",
        bottom-edge: "bounds",
        number,
      ))
    },
  )

  let outline-list = context {
    let sections = _collect-navigation-sections()
    if sections == () { return }
    // 有章节编号时徽标显示编号，否则显示序号
    let any-numbered = sections.any(section => section.heading.numbering != none)
    set text(
      fill: self.colors.primary-dark,
      weight: "bold",
      size: fonts.outline-size,
    )
    let items = sections
      .enumerate()
      .map(((index, section)) => {
        let number = if section.heading.numbering != none {
          str(counter(heading).at(section.heading.location()).first())
        } else if not any-numbered {
          str(index + 1)
        }
        grid(
          columns: (auto, 1fr),
          column-gutter: 0.5em,
          align: left + horizon,
          number-badge(number),
          link(section.heading.location(), section.heading.body),
        )
      })
    layout(size => {
      let row-gutter = 1.5em.to-absolute()
      let column-gutter = 2em.to-absolute()
      // 按栏宽实测（长章节名会折行）得到的总高度
      let total-height(column-count) = {
        let column-width = (
          (size.width - (column-count - 1) * column-gutter) / column-count
        )
        let item-height = calc.max(
          ..items.map(item => measure(item, width: column-width).height),
        )
        let row-count = calc.ceil(items.len() / column-count)
        row-count * item-height + (row-count - 1) * row-gutter
      }
      // 每种栏数只测一次高度：取第一个放得下的，都放不下时取最矮的
      let candidates = range(1, 5).map(n => (columns: n, height: total-height(n)))
      let chosen = candidates.find(it => it.height <= size.height)
      if chosen == none { chosen = candidates.sorted(key: it => it.height).first() }
      let row-count = calc.ceil(items.len() / chosen.columns)
      // 按列排列
      let outline-grid = grid(
        columns: (1fr,) * chosen.columns,
        column-gutter: column-gutter,
        row-gutter: row-gutter,
        ..range(row-count)
          .map(row => range(chosen.columns).map(column => items.at(
            column * row-count + row,
            default: none,
          )))
          .flatten(),
      )
      if chosen.height <= size.height { outline-grid } else {
        // 固定排版宽度，折行才与测量一致
        scale(
          size.height / chosen.height * 100%,
          origin: top + left,
          reflow: true,
          box(width: size.width, outline-grid),
        )
      }
    })
  }
  touying-slide(self: self, setting: std.align.with(self.store.align), outline-list)
})


/// 章节页：居中显示章节名和可选说明。Touying 自动调用时只传一个位置参数 none。
#let new-section-slide(
  config: (:),
  title: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  assert(
    bodies.named().len() == 0,
    message: "new-section-slide 收到未知的命名参数：" + repr(bodies.named().keys()),
  )
  self = utils.merge-dicts(self, config)
  self.store.header-title = none
  let fonts = self.store.fonts
  let description = bodies.pos().sum(default: none)

  let body = {
    set text(fill: self.colors.primary, weight: "bold")
    text(
      size: fonts.section-title-size,
      if title == auto { utils.display-current-heading(level: 1) } else { title },
    )
    if description != none {
      parbreak()
      v(0.5em)
      text(size: fonts.section-body-size, description)
    }
  }
  touying-slide(self: self, setting: std.align.with(center + horizon), body)
})


/// 焦点页：主色背景，冻结页码，没有页眉页脚。
#let focus-slide(
  config: (:),
  align: horizon + center,
  body,
) = touying-slide-wrapper(self => {
  // 先合并 config 取得本页主色，最后再合并一次让用户配置优先
  self = utils.merge-dicts(self, config)
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(
      fill: self.colors.primary,
      margin: 3em,
      header: none,
      footer: none,
    ),
    config,
  )
  let focus-setting = body => {
    set text(weight: "bold", size: self.store.fonts.focus-size)
    _on-primary(self, std.align(align, body))
  }
  touying-slide(self: self, setting: focus-setting, body)
})


/// 演讲者备注面板（notes-fn）：只设置配色，布局由 touying-notes 完成。
/// 页眉与标题栏文字一致；标题栏隐藏的页面（如章节页）退回显示当前标题。
#let _render-notes(self: none, ..args) = touying-notes(
  self: self,
  header: self => pad(x: 32pt, y: 16pt, _on-primary(self, text(weight: "bold", context {
    let title = _resolve-header-title(self)
    if title == none { utils.display-current-heading(depth: self.slide-level) } else { title }
  }))),
  header-fill: self.colors.primary,
  fill: self.colors.neutral-lightest,
  ..args,
)


// ───── 主题入口 ─────

/// 主题入口：组装 Touying 的页面、方法、颜色和 store 配置。
#let shuimu-touying-theme(
  aspect-ratio: "16-9",
  lang: "zh",
  align: horizon,
  theme-colors: shuimu-colors(),
  theme-fonts: shuimu-fonts(),
  display-section-slides: false,
  header-title: auto,
  footer-reporter: self => self.info.at("reporter", default: none),
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
  // 语言和参考文献规则放在 init 之外，Touying 的 article 模式（不调用 init）下也生效。
  // 参考文献页通常用 `== 参考文献` 作标题，不生成自带标题；显式写出的标题也不进入导航。
  set text(lang: lang)
  set bibliography(title: none)
  show bibliography: set heading(outlined: false)
  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      header: self => {
        set std.align(top)
        stack(
          utils.call-or-display(self, self.store.navigation),
          utils.call-or-display(self, self.store.header),
        )
      },
      footer: self => {
        set text(size: self.store.fonts.footer-size)
        set std.align(center + bottom)
        utils.call-or-display(self, self.store.footer)
      },
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (
        // 容纳导航栏（上下 inset 1em、圆点行及间距约 0.7em、一行章节名）和标题栏（1.4 倍字号），默认 4.5em
        top: 1.7em
          + 1.4 * theme-fonts.navigation-size
          + 1.4 * theme-fonts.header-title-size,
        bottom: 2.5em,
        x: 2.5em,
      ),
    ),
    config-common(
      slide-fn: slide,
      notes-fn: _render-notes,
      new-section-slide-fn: if display-section-slides { new-section-slide },
    ),
    config-methods(
      init: (self: none, body) => {
        let fonts = self.store.fonts
        set text(
          font: fonts.main,
          size: fonts.body-size,
          fill: self.colors.neutral-darkest,
        )
        // Touying 只把 author 写入 PDF 元数据，没有 author 时用 reporter 补上
        let reporter = self.info.at("reporter", default: none)
        set document(
          author: _to-array(reporter).map(it => utils.markup-text(it)),
        ) if self.info.author == none and reporter != none

        // Touying 的渐变圆点标记，上移一点与文字居中
        set list(marker: box(
          baseline: -0.1em,
          components.knob-marker(primary: self.colors.primary),
        ))
        show raw: set text(font: (.._to-array(fonts.mono), .._to-array(fonts.main)))
        show math.equation: it => {
          set text(font: (.._to-array(fonts.math), .._to-array(fonts.main)))
          // 公式默认字重 450 会让中文回退字体选中偏粗的 Medium，只在默认字重时改回常规
          show regex("\p{Han}+"): han => context if text.weight == 450 {
            text(weight: "regular", han)
          } else { han }
          it
        }
        show heading: set text(fill: self.colors.primary, weight: "black")
        show figure.caption: set text(size: fonts.caption-size)
        show figure.where(kind: table): set figure.caption(position: top)
        show footnote.entry: set text(size: fonts.footnote-size)
        // 外链染成主色；主色背景上（_on-primary 把文字设为 neutral-lightest）保持当前颜色
        show link: it => if type(it.dest) == str {
          context if text.fill != self.colors.neutral-lightest {
            text(fill: self.colors.primary, it)
          } else { it }
        } else { it }
        // 统一用合成上标，各字体下引文标注 [1] 效果一致
        set super(typographic: false)
        // 正文页的 horizon 对齐会让参考文献编号竖直居中，这里改回顶部对齐
        show bibliography: set std.align(top)
        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(..theme-colors),
    // 页眉、页脚和各页面函数从 store 读取这些配置，单页可以覆盖
    config-store(
      align: align,
      fonts: theme-fonts,
      header-title: header-title,
      navigation: _render-mini-frame-navigation,
      header: _render-title-bar,
      footer: _render-footer-bar,
      footer-reporter: footer-reporter,
      footer-author: footer-author,
      footer-deck-title: footer-deck-title,
      footer-slide-counter: footer-slide-counter,
    ),
    ..args,
  )

  body
}
