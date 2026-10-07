// 根据 ../组会PPT模版.pptx 重建，使用 Touying 0.7.4。
// 页面尺寸与原 PPT 一致：960 × 540 pt（16:9）。
#import "@preview/touying:0.7.4": *

#let tsinghua-purple = rgb("660874")
#let tsinghua-magenta = rgb("d93379")
#let red = rgb("d62728")
#let blue = rgb("005795")
#let green = rgb("1a5f1a")
#let orange = rgb("c45c00")
#let university-logo = "university-logo.svg"

// 所有绝对定位以原 PPT 的 point 坐标为基准，正文仍采用正常文档流。
#let at(x, y, body) = place(top + left, dx: x, dy: y, body)
#let fitted(width, height, body) = block(width: width, height: height)[
  #align(center + horizon, body)
]

// 接受图片或任意自定义 content；不拉伸图片比例。
#let scale-to-fit(body, width, height) = context {
  let size = measure(body)
  let factor = calc.min(width / size.width, height / size.height)
  scale(x: factor * 100%, y: factor * 100%, reflow: true, body)
}

#let brand-background(self) = {
  if self.store.cover-logo != none {
    at(610.54pt, 30.67pt, fitted(310.24pt, 74.8pt,
      scale-to-fit(self.store.cover-logo, 310.24pt, 74.8pt)))
  }
  if self.store.campus != none {
    at(623.5pt, 485.25pt, scale-to-fit(self.store.campus, 331.5pt, 39pt))
  }
}

#let cover-background(self) = {
  at(47.18pt, 136.72pt, rect(width: 865.63pt, height: 149.87pt,
    fill: rgb("f2f2f2"), stroke: none))
  // 原母版的半闭框与右下角短横条。
  at(47.18pt, 136.72pt, polygon(fill: self.colors.primary, stroke: none,
    (0pt, 0pt), (64.71pt, 0pt), (49.52pt, 15.2pt),
    (15.2pt, 15.2pt), (15.2pt, 53.14pt), (0pt, 68.34pt)))
  at(800.14pt, 270pt, rect(width: 112.68pt, height: 16.59pt,
    fill: self.colors.primary, stroke: none))
  brand-background(self)
}

#let part-label(self) = context {
  let current = utils.current-heading(level: 1)
  if current != none {
    let sections = query(heading.where(level: 1))
    let n = sections.position(h => h.location() == current.location()) + 1
    self.store.part-prefix + " " + (if n < 10 { "0" } else { "" }) + str(n)
  }
}

// 日期与副标题共用一行；同一段落内的页码与日期共享基线。
#let report-footer(self, fill: none, page-number: false, cover: false) = {
  if fill == none { fill = self.colors.primary }
  let info = self.info
  let has-date = info.date != none and info.date != []
  let has-subtitle = info.subtitle != none and info.subtitle != []
  let x = if cover { 47.18pt } else { 36pt }
  let y = if cover { 476.25pt } else { 506.09pt }
  let height = if cover { 39pt } else { 33.91pt }
  let width = if cover { 583.5pt - x - 18pt } else { 935pt - x }
  at(x, y, block(width: width, height: height)[
    #align(left + if cover { bottom } else { horizon })[
      #set text(font: self.store.font, size: 18pt, fill: fill)
      // 封面按实际文字边界与校园图下缘（515.25pt）对齐。
      #show: body => if cover { text(top-edge: "bounds", bottom-edge: "bounds", body) } else { body }
      #if self.store.footer == auto {
        if has-date {
          if type(info.date) == datetime { info.date.display("[year]-[month]-[day]") }
          else { info.date }
        }
        if has-date and has-subtitle { h(18pt) }
        if has-subtitle { text(font: self.store.subtitle-font, size: 18pt, info.subtitle) }
      } else if self.store.footer != none { self.store.footer }
      #h(1fr)
      #if page-number { context utils.slide-counter.display() }
    ]
  ])
}

#let content-background(self, title: auto, part: auto) = {
  at(0pt, 0pt, rect(width: 960pt, height: 65.6pt,
    fill: self.colors.primary, stroke: none))
  at(0pt, 506.09pt, rect(width: 960pt, height: 33.91pt,
    fill: self.colors.primary, stroke: none))
  set text(fill: white)
  at(36.8pt, 5.9pt, block(width: 115pt, height: 53.76pt)[
    #align(left + horizon, text(28pt, if part == auto { part-label(self) } else { part }))
  ])
  at(160pt, 5.9pt, block(width: 637pt, height: 53.76pt)[
    #align(center + horizon, text(self.store.title-size,
      utils.fit-to-width.with(grow: false, 637pt)(
        if title == auto { utils.display-current-heading(level: 2, numbered: false) } else { title }
      )))
  ])
  if self.store.header-logo != none {
    let scaled-logo = scale-to-fit(self.store.header-logo, 10000pt, 40pt)
    place(horizon + right, dx: -20pt, dy: -270pt + 32pt, scaled-logo)
  }
  report-footer(self, fill: white, page-number: self.store.show-page-number)
}

// 常规正文页，也由二级标题 == 自动调用。支持 #pause 和多栏 composer。
#let slide(title: auto, part: auto, config: (:), repeat: auto,
  setting: body => body, composer: auto, ..bodies) = touying-slide-wrapper(self => {
  touying-slide(self: self,
    config: utils.merge-dicts(config-page(
      foreground: content-background(self, title: title, part: part)), config),
    repeat: repeat, setting: setting, composer: composer, ..bodies)
})

// config-info 居中；副标题默认随日期显示在左下角。
#let title-slide(title: auto, subtitle: auto, inline-subtitle: false,
  logo: auto, extra: none, config: (:)) = touying-slide-wrapper(self => {
  let info = self.info
  let title = if title == auto { info.title } else { title }
  let subtitle = if subtitle == auto { info.subtitle } else { subtitle }
  self.info.subtitle = subtitle
  if logo != auto { self.store.cover-logo = logo }
  touying-slide(self: self,
    config: utils.merge-dicts(config-common(detect-overflow: false), config-page(
      margin: 0pt, background: cover-background(self), foreground: report-footer(self, cover: true)), config),
    {
      at(83.04pt, 159.69pt, block(width: 793.93pt, height: 97pt)[
        #align(center + horizon)[
          #set text(fill: self.colors.primary, size: 36pt)
          #title
          #if inline-subtitle and subtitle != none and subtitle != [] {
            h(0.25em); subtitle
          }
        ]
      ])
      at(83.04pt, 322pt, block(width: 793.93pt)[
        #set align(center)
        #set text(size: 22pt, fill: black)
        #set par(leading: 0.8em)
        #if info.author != none and info.author != [] { [#info.author]; parbreak() }
        #if info.institution != none and info.institution != [] { info.institution; parbreak() }
        #extra
      ])
    })
})

// active: none 为总目录；auto 高亮当前章节；整数为从 1 开始的行号。
#let render-outline(self, title: [CONTENTS], items: none,
  active: none, v-spacing: auto, config: (:)) = {
  let background(self) = {
    at(44.96pt, 0pt, rect(width: 26.14pt, height: 540pt,
      fill: self.colors.primary, stroke: none))
    brand-background(self)
    at(120.8pt, 64pt, text(size: 32pt, fill: self.colors.primary, title))
  }
  if self.store.show-contents {
    touying-slide(self: self,
      config: utils.merge-dicts(config-page(
        margin: (left: 120.8pt, right: 90pt, top: 120pt, bottom: 120pt),
        background: background(self), foreground: none), config),
      {
        set text(size: 28pt)
        context {
          let sections = query(heading.where(level: 1, outlined: true))
          let entries = if items != none { items }
            else { sections.map(h => link(h.location(), h.body)) }
          let active = if active == auto {
            let current = utils.current-heading(level: 1)
            let index = sections.position(h => current != none and h.location() == current.location())
            if index != none { index + 1 } else { none }
          } else { active }
          let gap = if v-spacing == auto { self.store.outline-v-spacing } else { v-spacing }
          let rows = entries.enumerate().map(((i, entry)) => {
            let color = if active == none { black }
              else if i + 1 == active { self.colors.primary } else { rgb("999999") }
            text(fill: color, grid(columns: (10.5pt, 1fr), column-gutter: 12pt,
              align: left + horizon,
              box(width: 10.5pt, height: 10.5pt, fill: color), entry))
          })
          if rows.len() > 0 {
            // 对称的可用区域以整张 slide 的 270pt 为中心。
            // 自动间距铺满该区域；单行或手动间距时将整个文本组居中。
            block(height: 300pt, width: 100%, align(horizon,
              stack(dir: ttb,
                spacing: if gap == auto and rows.len() > 1 { 1fr }
                  else if gap == auto { 0pt } else { gap },
                ..rows)))
          }
        }
      })
  }
}

// items 为 none 时自动读取所有一级标题；也可传入内容数组。
#let outline-slide(title: [CONTENTS], items: none, active: none,
  v-spacing: auto, config: (:)) = touying-slide-wrapper(self => {
  render-outline(self, title: title, items: items, active: active,
    v-spacing: v-spacing, config: config)
})

// 每个一级标题开始前显示目录，高亮对应章节。
#let section-slide(body, config: (:)) = touying-slide-wrapper(self => {
  render-outline(self, active: auto, config: config)
})

#let closing-slide(body: [谢谢！], subtitle: [], config: (:)) = touying-slide-wrapper(self => {
  self.info.author = none
  self.info.institution = none
  // 封面装饰与结束页保持一致，文字仍可编辑。
  touying-slide(self: self,
    config: utils.merge-dicts(config-common(detect-overflow: false), config-page(
      margin: 0pt, background: cover-background(self), foreground: report-footer(self, cover: true)), config),
    {
      at(83.04pt, 205pt, text(size: 36pt, fill: self.colors.primary, body))
      at(83.04pt, 325pt, text(size: 24pt, fill: self.colors.primary, subtitle))
    })
})

#let read-svg-and-replace-fill(name, fill, all: false) = {
  let svg = read("assets/" + name)
  let re = regex("fill:#[0-9a-fA-F]{6}")
  let re2 = regex("fill=\"#[0-9a-fA-F]{6}\"")
  if all{
    image(bytes(
      svg.replace(
        re, "fill:" + fill.to-hex()
      ).replace(
        re2, 
        "fill=\"" + fill.to-hex() + "\"",
      )
      ), format: "svg")
  }
  else{
    image(bytes(svg.replace(
      "fill:" + tsinghua-purple.to-hex(), "fill:" + fill.to-hex()).replace(
        "fill=\"" + tsinghua-purple.to-hex() + "\"",
        "fill=\"" + fill.to-hex() + "\"",
      )
      ), 
      format: "svg")
  }
}


#let group-meeting-theme(
  font: ("Arial", "SimHei"), body-size: 22pt, title-size: 28pt,
  math-font: "New Computer Modern Math", subtitle-font: ("Arial", "STXinwei"),
  primary: tsinghua-purple, cover-logo-name: university-logo,
  header-logo-name: university-logo, cover-logo: none, header-logo: none, campus: none,
  part-prefix: "Part", footer: auto, show-page-number: true,
  section-slides: true, outline-v-spacing: auto, show-contents: true, ..args, body,
) = {
  if cover-logo == none{
    cover-logo = read-svg-and-replace-fill(cover-logo-name, primary)
  }
  else if type(cover-logo) == str{
    cover-logo = image(cover-logo)
  }
  if header-logo == none{
    header-logo = read-svg-and-replace-fill(header-logo-name, white, all: true)
  }
  else if type(header-logo) == str{
    header-logo = image(header-logo)
  }

  if campus == none{
    campus = read-svg-and-replace-fill("campus.svg", primary)
  }
  
  show: touying-slides.with(
    config-page(width: 960pt, height: 540pt, fill: white,
      margin: (left: 72pt, right: 72pt, top: 91pt, bottom: 55pt),
      header: none, footer: none),
    config-common(slide-fn: slide, slide-level: 2,
      new-section-slide-fn: if section-slides { section-slide } else { none },
      receive-body-for-new-section-slide-fn: false,
      breakable: false, detect-overflow: true),
    config-colors(primary: primary),
    config-info(title: [中文标题], subtitle: [English title],
      author: none, institution: none, date: none),
    config-store(cover-logo: cover-logo, header-logo: header-logo, campus: campus,
      title-size: title-size, part-prefix: part-prefix, font: font,
      subtitle-font: subtitle-font, outline-v-spacing: outline-v-spacing,
      show-contents: show-contents,
      footer: footer, show-page-number: show-page-number),
    config-methods(init: (self: none, body) => {
      set text(font: font, size: body-size, lang: "zh")
      show math.equation: set text(font: math-font)
      set par(leading: 0.65em)
      set list(marker: [▪], indent: 0pt, body-indent: 0.55em, spacing: 0.7em)
      show heading: set text(fill: primary)
      show footnote.entry: set text(size: 18pt)
      body
    }, alert: utils.alert-with-primary-color),
    ..args,
  )
  body
}
