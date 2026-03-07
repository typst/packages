// THUTouying theme.
// Authors: Mason Chen
// Inspired by Stargazer theme

#import "@preview/touying:0.6.1": *




/// 基础视觉组件 (The Bricks)
/// 这里定义了页面内部的小组件，比如“定理块”或者带有特定样式的方块

/// 文本块
#let _tblock(self: none, title: none, it) = {
  grid(
    columns: 1,
    row-gutter: 0pt,

    // 1. 顶部标题栏
    block(
      fill: self.colors.primary, //这里从primary-dark改为primary
      width: 100%,
      radius: (top: 6pt),
      inset: (top: 0.4em, bottom: 0.3em, left: 0.5em, right: 0.5em),
      text(fill: self.colors.neutral-lightest, weight: "bold", title),
    ),

    // 2. 渐变分割线
    rect(
      fill: gradient.linear(
        self.colors.primary,  //这里从primary-dark改为primary
        self.colors.primary.lighten(90%),
        angle: 90deg,
      ),
      width: 100%,
      height: 4pt,
    ),

    // 3. 底部内容区域
    block(
      fill: self.colors.primary.lighten(90%),
      width: 100%,
      radius: (bottom: 6pt),
      inset: (top: 0.4em, bottom: 0.5em, left: 0.5em, right: 0.5em),
      it,
    ),
  )
}

/// 导出函数：定理块 (Theorem Block) 的包装器
/// Theorem block for the presentation.
///
/// - title (string): The title of the theorem. Default is `none`.
///
/// - it (content): The content of the theorem.
#let tblock(title: none, it) = touying-fn-wrapper(_tblock.with(
  title: title,
  it,
))

/// 辅助函数：获取文档的章节和子页面结构
/// 返回结构: ((title: content, loc: location, children: (loc: location, ...)), ...)
#let get-sections(self) = {
  // 1. 获取所有标题
  let all-headings = query(heading)
  
  let sections = ()
  let current-section = none

  // 2. 遍历标题构建层级
  for h in all-headings {
    if h.level == 1 {
      // 遇到一级标题：归档上一个章节，开始新章节
      if current-section != none { sections.push(current-section) }
      current-section = (
        title: h.body, 
        loc: h.location(), // 存入 location 对象
        children: ()
      )
    } else if h.level == 2 {
      // 遇到二级标题：加入当前章节的 children
      if current-section != none {
        // 这里的 children 我们直接存整个标题元素，方便后续取 location
        current-section.children.push(h)
      }
    }
  }
  // 归档最后一个章节
  if current-section != none { sections.push(current-section) }
  
  sections
}


/// Mini-frames 导航栏
#let mini-frames-navigation(self: none) = {
  let primary-color = self.colors.primary-dark 
  let text-color = self.colors.neutral-lightest
  
  context {
    // 获取章节结构和当前页码
    let sections = get-sections(self)
    let current-page = here().page()
    
    // 计算当前激活的是哪个章节 (Active Section)
    // 逻辑：找到最后一个起始页码小于等于当前页码的章节
    let active-section-index = -1
    for (i, section) in sections.enumerate() {
      if section.loc.page() <= current-page {
        active-section-index = i
      }
    }
    
    block(
      width: 100%, 
      fill: primary-color, 
      inset: (top: 0.6em, bottom: 0.4em, x: 2em),
      {
        set text(size: 0.7em)
        set align(left + horizon)
        
        grid(
          columns: sections.map(_ => auto),
          column-gutter: 1.5em,
          
          // 使用 enumerate 获取索引，以便判断是否为当前章节
          ..sections.enumerate().map(((i, section)) => {
            // A. 判断本列是否需要高亮
            let is-active-section = (i == active-section-index)
            
            // B. 定义颜色：激活章节用纯白，非激活章节用 60% 透明度的白(变暗)
            let section-color = if is-active-section {
              text-color
            } else {
              text-color.transparentize(60%)
            }

            // C. 渲染标题 (应用 section-color)
            let title = link(
              section.loc, 
              text(fill: section-color, weight: "bold", section.title)
            )
            
            // D. 渲染小圆点
            let dots = if section.children.len() > 0 {
              stack(
                dir: ltr,
                spacing: 4pt,
                ..section.children.map(subsection => {
                  let loc = subsection.location()
                  let page-num = loc.page()
                  
                  // E. 严格判断是否为当前页 (用于实心/空心)
                  let is-current-page = (page-num == current-page)
                  
                  link(
                    loc,
                    box(
                      circle(
                        radius: 2.5pt,
                        // 描边颜色跟随章节颜色 (变暗或高亮)
                        stroke: (paint: section-color, thickness: 0.8pt),
                        // 填充颜色：只有当前页才填充，且颜色跟随章节高亮状态
                        // 以前的逻辑可能导致了之前的页也是实心，现在严格限制为 is-current-page
                        fill: if is-current-page { section-color } else { none } 
                      )
                    )
                  )
                })
              )
            } else {
              v(5pt) 
            }

            stack(
              dir: ttb,
              spacing: 0.4em,
              title,
              dots
            )
          })
        )
      }
    )
  }
}




/// 页面蓝图 (The Blueprints)
/// 这里定义了不同类型的幻灯片（普通页、封面、目录、章节页、结束页）的逻辑

/// Default slide function for the presentation.
///
/// - title (string): The title of the slide. Default is `auto`.
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
/// 
/// 1. 正文页 (Slide)
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
    self.store.title = title
  }
  if header != auto {
    self.store.header = header
  }
  if footer != auto {
    self.store.footer = footer
  }
  let new-setting = body => {
    show: std.align.with(self.store.align)
    show: setting
    body
  }
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: new-setting,
    composer: composer,
    ..bodies,
  )
})


/// 2. 封面页 (Title Slide)
/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: stargazer-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.city,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle])
/// ```
///
/// - config (dictionary): The configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
#let title-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
  )
  self.store.title = none // 封面不需要页眉标题
  let info = self.info + args.named()

  // 处理多作者的情况
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }

  let body = {
    show: std.align.with(center + horizon)
    // 标题框
    block(
      fill: self.colors.primary,
      inset: 1.5em,
      radius: 0.5em,
      breakable: false,
      {
        text(
          size: 1.2em,
          fill: self.colors.neutral-lightest,
          weight: "bold",
          info.title,
        )
        if info.subtitle != none {
          parbreak()
          text(
            size: 1.0em,
            fill: self.colors.neutral-lightest,
            weight: "bold",
            info.subtitle,
          )
        }
      },
    )

    // 作者列表
    grid(
      columns: (1fr,) * calc.min(info.authors.len(), 3),
      column-gutter: 1em,
      row-gutter: 1em,
      ..info.authors.map(author => text(fill: black, author)),
    )
    v(0.5em)
    
    // 机构与日期
    if info.institution != none {
      parbreak()
      text(size: 0.7em, info.institution)
    }
    // date
    if info.date != none {
      parbreak()
      text(size: 1.0em, utils.display-info-date(self))
    }
  }
  touying-slide(self: self, body)
})



/// 3. 目录页 (Outline Slide)
/// Outline slide for the presentation.
///
/// - config (dictionary): is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - title (string): is the title of the outline. Default is `utils.i18n-outline-title`.
///
/// - level (int, none): is the level of the outline. Default is `none`.
///
/// - numbered (boolean): is whether the outline is numbered. Default is `true`.
#let outline-slide(
  config: (:),
  title: utils.i18n-outline-title,
  ..args,
) = touying-slide-wrapper(self => {
  self.store.title = title
  touying-slide(
    self: self,
    config: config,
    std.align(
      self.store.align,
      context {
        set text(fill: self.colors.primary-dark, weight: "bold", size: 1.2em)
        
        // 1. 获取章节数据
        let sections = get-sections(self)
        
        // 2. 渲染为标准列表
        if sections.len() > 0 {
          list(
            // 自定义列表符号：使用主色的实心圆点
            marker: text(fill: self.colors.primary-dark)[●], 
            // 列表间距
            body-indent: 0.5em,
            indent: 1em,
            spacing: 1.5em, 
            
            // 3. 循环生成列表项
            ..sections.map(section => {
              link(section.loc, section.title)
            })
          )
        } else {
          [No sections found.]
        }
      }
    ),
  )
})


/// 4. 章节页 (New Section Slide)
/// 本质上是带标题的目录页
/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - config (dictionary): is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - title (content, function): is the title of the section. The default is `utils.i18n-outline-title`.
///
/// - level (int): is the level of the heading. The default is `1`.
///
/// - numbered (boolean): is whether the heading is numbered. The default is `true`.
///
/// - body (none): is the body of the section. It will be passed by touying automatically.
#let new-section-slide(
  config: (:),
  title: auto,
  ..args,
) = touying-slide-wrapper(self => {
  let body = args.pos().sum(default: none)

  touying-slide(
    self: self,
    config: config,
    std.align(center + horizon, {
      set text(fill: self.colors.primary, weight: "bold", size: 2.5em)
      
      if title != auto {
        title
        if body != none {
          parbreak()
          v(0.5em)
          set text(size: 0.8em) 
          body
        }
      } else if body != none {
        body
      } else {
        utils.display-current-heading(level: 1)
      }
    })
  )
})


/// 5. 焦点页 (Focus Slide)
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
  set text(fill: self.colors.neutral-lightest, weight: "bold", size: 1.5em)
  touying-slide(self: self, config: config, std.align(align, body))
})


/// 6. 结束页 (Ending Slide)
/// End slide for the presentation.
///
/// - config (dictionary): is the configuration of the slide. You can use `config-xxx` to set the configuration of the slide. For more several configurations, you can use `utils.merge-dicts` to merge them.
///
/// - title (string): is the title of the slide. The default is `none`.
///
/// - body (array): is the content of the slide.
#let ending-slide(config: (:), title: none, body) = touying-slide-wrapper(
  self => {
    let content = {
      set std.align(center + horizon)
      if title != none {
        block(
          fill: self.colors.primary,
          inset: (top: 0.7em, bottom: 0.7em, left: 3em, right: 3em),
          radius: 0.5em,
          text(size: 1.5em, fill: self.colors.neutral-lightest, title),
        )
      }
      body
    }
    touying-slide(self: self, config: config, content)
  },
)




/// 主题入口与全局配置 (The Architect)
/// 将所有组件组装在一起


/// Touying stargazer theme.
///
/// Example:
///
/// ```typst
/// #show: shuimu-touying-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// Consider using:
///
/// ```typst
/// #set text(font: "Fira Sans", weight: "light", size: 20pt)`
/// #show math.equation: set text(font: "Fira Math")
/// #set strong(delta: 100)
/// #set par(justify: true)
/// ```
/// The default colors:
///
/// ```typst
/// config-colors(
///   primary: rgb("#660874"),
///   primary-dark: rgb("#004078"),
///   secondary: rgb("#ffffff"),
///   tertiary: rgb("#005bac"),
///   neutral-lightest: rgb("#ffffff"),
///   neutral-darkest: rgb("#000000"),
/// )
/// ```
///
/// - aspect-ratio (string): is the aspect ratio of the slides. The default is `16-9`.
///
/// - align (alignment): is the alignment of the content. The default is `horizon`.
///
/// - title (content, function): is the title in the header of the slide. The default is `self => utils.display-current-heading(depth: self.slide-level)`.
///
/// - header-right (content, function): is the right part of the header. The default is `self => self.info.logo`.
///
/// - footer (content, function): is the footer of the slide. The default is `none`.
///
/// - footer-right (content, function): is the right part of the footer. The default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
///
/// - progress-bar (boolean): is whether to show the progress bar in the footer. The default is `true`.
///
/// - footer-columns (array): is the columns of the footer. The default is `(25%, 25%, 1fr, 5em)`.
///
/// - footer-a (content, function): is the left part of the footer. The default is `self => self.info.author`.
///
/// - footer-b (content, function): is the second left part of the footer. The default is `self => utils.display-info-date(self)`.
///
/// - footer-c (content, function): is the second right part of the footer. The default is `self => if self.info.short-title == auto { self.info.title } else { self.info.short-title }`.
///
/// - footer-d (content, function): is the right part of the footer. The default is `context utils.slide-counter.display() + " / " + utils.last-slide-number`.
#let shuimu-touying-theme(
  aspect-ratio: "16-9",
  align: horizon,
  alpha: 20%, // 目录透明度
  display-section-slides: false, // 是否显示章节页
  title: self => utils.display-current-heading(depth: self.slide-level),
  // 删除了 unused header-right
  // 删除了 ununsed progress-bar
  // 页脚各部分配置（可通过传参修改）
  footer-columns: (35%, 1fr, 5em),
  footer-a: self => self.info.author,
  // 删除了 unused footer-b 的参数定义
  footer-c: self => if self.info.short-title == auto {
    self.info.title
  } else {
    self.info.short-title
  },
  footer-d: context utils.slide-counter.display()
    + " / "
    + utils.last-slide-number,
  ..args,
  body,
) = {
  // 定义全局页眉布局
  let header(self) = {
    set std.align(top)
    stack(
      dir: ttb,       // 从上到下排列
      spacing: 0em,   // 去除中间的缝隙
      
      // 1. 顶部的导航栏
      mini-frames-navigation(self: self),
      
      // 2. 下面的幻灯片标题栏
      utils.call-or-display(self, self.store.header)
    )
  }

  // 定义全局页脚布局
  let footer(self) = {
    set text(size: .5em)
    set std.align(center + bottom)
    grid(
      rows: (auto, auto),
      utils.call-or-display(self, self.store.footer),
    )
  }

  // 初始化 Touying 系统(组装主题)
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header: header,
      footer: footer,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 3.5em, bottom: 2.5em, x: 2.5em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: if display-section-slides { 
        new-section-slide 
      } else { 
        none 
      },
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 20pt)
        set list(marker: components.knob-marker(primary: self.colors.primary))
        show figure.caption: set text(size: 0.6em)
        show footnote.entry: set text(size: 0.6em)
        show heading: set text(fill: self.colors.primary)
        show link: it => if type(it.dest) == str {
          set text(fill: self.colors.primary)
          it
        } else {
          it
        }
        show figure.where(kind: table): set figure.caption(position: top)

        body
      },
      alert: utils.alert-with-primary-color,
      tblock: _tblock,
    ),
    config-colors(
      primary: rgb("#660874"), //参考了清华大学视觉形象识别系统（https://vi.tsinghua.edu.cn/gk/xxbz/scgf.htm）的参数，经过换算后为#660874
      primary-dark: rgb("#320439"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    // save the variables for later use
    config-store(
      align: align,
      alpha: alpha,
      title: title,
      footer-columns: footer-columns,
      footer-a: footer-a,
      footer-c: footer-c,
      footer-d: footer-d,

      // 删除了 unused navigation 键
      
      header: self => if self.store.title != none {
        block(
          width: 100%,
          height: 1.8em,
          fill: self.colors.primary,
          place(
            left + horizon,
            text(
              fill: self.colors.neutral-lightest,
              weight: "bold",
              size: 1.3em,
              utils.call-or-display(self, self.store.title),
            ),
            dx: 1.5em,
          ),
        )
      },
 
      footer: self => {
        let cell(fill: none, it) = rect(
          width: 100%,
          height: 100%,
          inset: 1mm,
          outset: 0mm,
          fill: fill,
          stroke: none,
          std.align(horizon, text(fill: self.colors.neutral-lightest, it)),
        )
        grid(
          columns: self.store.footer-columns,
          rows: (1.5em, auto),
          cell(fill: self.colors.primary, utils.call-or-display(
            self,
            self.store.footer-a,
          )),
          cell(fill: self.colors.primary, utils.call-or-display(
            self,
            self.store.footer-c,
          )),
          cell(fill: self.colors.primary, utils.call-or-display(
            self,
            self.store.footer-d,
          )),
        )
      },
    ),
    ..args,
  )

  body
}
