// ShuimuTouying 
// a THU Touying theme.
// Authors: Mason Chen
// Inspired by Stargazer theme

#import "@preview/touying:0.6.1": *


/// 基础视觉组件 (The Bricks)

/// 文本块
#let _tblock(self: none, title: none, it) = {
  block(
    breakable: false,
    grid(
    columns: 1,
    row-gutter: 0pt,

      // 1. 顶部标题栏
      block(
        fill: self.colors.primary,
        width: 100%,
        radius: (top: 6pt),
        inset: (top: 0.4em, bottom: 0.3em, left: 0.5em, right: 0.5em),
        text(fill: self.colors.neutral-lightest, weight: "bold", title),
      ),

      // 2. 渐变分割线
      rect(
        fill: gradient.linear(
          self.colors.primary,
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
  )
}

/// 导出函数：定理块 (Theorem Block) 的包装器

#let tblock(title: none, it) = touying-fn-wrapper(_tblock.with(
  title: title,
  it,
))

/// 辅助函数：获取文档的章节和子页面结构
/// children 为该章节包含的所有物理页码数组（已排除 focus-slide 等标记了 skip 的页面）
#let _get-sections(self) = {
  let all-headings = query(heading.where(level: 1))
  let skip-pages = query(<touying-skip-dot>).map(s => s.location().page())
  // 用所有 heading 和 skip 标签中的最大页码来推断文档末尾
  let last-known-page = calc.max(
    ..all-headings.map(h => h.location().page()),
    ..skip-pages,
    ..query(<touying-slide-page>).map(s => s.location().page()),
  )
  let sections = ()

  for (i, h) in all-headings.enumerate() {
    let start-page = h.location().page()
    let end-page = if i + 1 < all-headings.len() {
      all-headings.at(i + 1).location().page()
    } else {
      last-known-page + 1
    }

    sections.push((
      title: h.body,
      loc: h.location(),
      children: range(start-page, end-page).filter(p => p not in skip-pages),
    ))
  }

  sections
}


/// Mini-frames 导航栏
#let _mini-frames-navigation(self: none) = {
  let primary-color = self.colors.primary-dark 
  let text-color = self.colors.neutral-lightest
  
  context {
    // 获取章节结构和当前页码
    let sections = _get-sections(self)
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
                ..section.children.map(page-num => {
                  let is-current-page = (page-num == current-page)

                  link(
                    section.loc,
                    box(
                      circle(
                        radius: 2.5pt,
                        stroke: (paint: section-color, thickness: 0.8pt),
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

/// 1. 正文页 (Slide)
/// 
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
    [#hide[#"" <touying-slide-page>]] //注入物理页签，用于导航栏的页码检测
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

#let title-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
  )
  self.store.title = none // 封面不需要页眉标题
  let info = self.info + args.named()

  // 辅助：将单个值统一转为数组
  let to-arr(v) = if type(v) == array { v } else { (v,) }

  // 构建 (前缀, 姓名数组) 列表
  let person-entries = ()
  if "author" in info and info.author != none {
    person-entries.push(("作者：", to-arr(info.author)))
  } 
  if "reporter" in info and info.reporter != none {
    person-entries.push(("报告人：", to-arr(info.reporter)))
  }
  if "supervisor" in info and info.supervisor != none {
    person-entries.push(("导师：", to-arr(info.supervisor)))
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

    // 人员列表（每个角色一行，前缀 + 姓名横排，整体居中）
    for (prefix, persons) in person-entries {
      align(center,
        grid(
          columns: (auto,) + (auto,) * calc.min(persons.len(), 3),
          column-gutter: 0.5em,
          row-gutter: 0.5em,
          text(fill: black, prefix),
          ..persons.map(p => text(fill: black, p)),
        )
      )
    }
    v(0.5em)
    
    // 机构与日期
    if info.institution != none {
      parbreak()
      text(size: 0.7em, info.institution)
    }
    // date
    if info.date != none {
      parbreak()
      text(size: 0.7em, utils.display-info-date(self))
    }
  }
  touying-slide(self: self, body)
})



/// 3. 目录页 (Outline Slide)

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
        let sections = _get-sections(self)
        
        // 2. 渲染为标准列表
        if sections.len() > 0 {
          stack(
            dir: ttb,
            spacing: 1.5em,
            ..sections.enumerate().map(((i, section)) => {
              let num-circle = box(
                width: 1.1em, height: 1.1em, radius: 50%,
                fill: self.colors.primary,
                place(center + horizon, text(fill: white, weight: "bold", size: 0.75em, top-edge: "bounds", bottom-edge: "bounds", str(i + 1)))
              )
              box(stack(dir: ltr, spacing: 0.5em, num-circle, link(section.loc, section.title)))
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
  touying-slide(self: self, config: config, {
    [#hide[#"" <touying-skip-dot>]]
    std.align(align, body)
  })
})


/// 主题入口与全局配置 (The Architect)
/// 将所有组件组装在一起

#let shuimu-touying-theme(
  aspect-ratio: "16-9",
  align: horizon,
  alpha: 20%, // 目录透明度
  display-section-slides: false, // 是否显示章节页
  title: self => utils.display-current-heading(depth: self.slide-level),
  // 删除了 unused header-right
  // 删除了 ununsed progress-bar
  // 页脚各部分配置（可通过传参修改）
  footer-a: self => self.info.reporter,

  footer-b: self => self.info.author,


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
  let main-fonts = ("Linux Libertine","Palatino","Noto Serif CJK SC","Songti SC")
  // 定义全局页眉布局
  let header(self) = {
    set std.align(top)
    set text(font: main-fonts)
    stack(
      dir: ttb,       // 从上到下排列
      spacing: 0em,   // 去除中间的缝隙
      
      // 1. 顶部的导航栏
      _mini-frames-navigation(self: self),
      
      // 2. 下面的幻灯片标题栏
      utils.call-or-display(self, self.store.header)
    )
  }

  // 定义全局页脚布局
  let footer(self) = {
    set text(font: main-fonts, size: .5em)
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
      margin: (top: 4.5em, bottom: 2.5em, x: 2.5em),
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
        set text(font: main-fonts, size: 20pt)
        set list(marker: components.knob-marker(primary: self.colors.primary))
        show figure.caption: set text(size: 0.6em)
        show footnote.entry: set text(size: 0.6em)
        show heading: set text(fill: self.colors.primary,weight: "black")
        set super(typographic: false) // 关闭字体默认的上标样式，防止冲突
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
      footer-a: footer-a,
      footer-b: footer-b,
      footer-c: footer-c,
      footer-d: footer-d,

      // 删除了 navigation 键
      
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
        show strong: it => it.body
        let cell(fill: none, it) = rect(
          width: 100%,
          height: 100%,
          inset: 1mm,
          outset: 0mm,
          fill: fill,
          stroke: none,
          std.align(horizon, text(fill: self.colors.neutral-lightest, it)),
        )

        let footer-a = utils.call-or-display(self, self.store.footer-a)
        let footer-b = utils.call-or-display(self, self.store.footer-b)
        let footer-c = utils.call-or-display(self, self.store.footer-c)
        let footer-d = utils.call-or-display(self, self.store.footer-d)

        grid(
          columns: (
            if footer-a != none { 15% } else { 0pt },
            if footer-b != none { 15% } else { 0pt },
            1fr,
            5em,
          ),
          rows: (1.5em, auto),
          cell(fill: self.colors.primary, if footer-a != none { footer-a }),
          cell(fill: self.colors.primary, if footer-b != none { footer-b }),
          cell(fill: self.colors.primary, footer-c),
          cell(fill: self.colors.primary, footer-d),
        )
      },
    ),
    ..args,
  )

  body
}
