#import "@preview/touying:0.7.0": *

// 依据校徽主题色莫奈取色
#let monet-colors = (
  p-50: rgb("#fcebee"),
  p-100: rgb("#f8ccd3"),
  p-200: rgb("#e5989c"),
  p-500: rgb("#e6413f"),
  p-700: rgb("#c52f37"),
  p-800: rgb("#b82930"),
  p-900: rgb("#a82026"),
  c-50: rgb("#def2f2"),
  primary: rgb("#b82930"),
  neutral-lightest: rgb("#fcebee"),
  neutral-darkest: rgb("#a82026"),
)

// 辅助函数：自动设定 logo 宽高
#let auto-size-logo(logo, h) = {
  if logo == none { return none }
  set image(height: h)
  box(height: h, logo)
}

// 首页
#let title-slide(..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = block(width: 100%, height: 100%, {
    set std.align(center)
    v(1.5fr)
    auto-size-logo(image("../asset/cdu.png"), 7em)
    v(1fr)
    block(inset: (x: 2em), {
      text(size: 3.5em, fill: self.colors.p-800, strong(info.title))
      if info.subtitle != none {
        v(0.8em)
        text(size: 1.8em, fill: self.colors.p-700.opacify(80%), info.subtitle)
      }
    })
    v(2fr)
    block(fill: self.colors.p-800, width: 100%, inset: (y: 2em), {
      set text(fill: white, size: 1.2em)
      grid(
        columns: (1fr, 1fr, 1fr),
        info.author, info.institution, utils.display-info-date(self),
      )
    })
  })
  let self = utils.merge-dicts(self, config-page(header: none, footer: none, margin: 0pt))
  touying-slide(self: self, body)
})

#let outline-slide(title: [CONTENTS]) = touying-slide-wrapper(self => {
  let body = {
    set std.align(left + horizon)
    pad(x: 3em, {
      stack(spacing: 3em,
        block(inset: (bottom: 0.5em), stroke: (bottom: 2pt + self.colors.p-500), {
          text(size: 2.8em, fill: self.colors.p-800, strong(title))
        }),
        
        {
          set text(size: 1.5em, fill: self.colors.p-900)
          
          show outline.entry: it => {
            let loc = it.element.location()
            let numbering-format = it.element.numbering
            let num = if numbering-format != none {
              numbering(numbering-format, ..counter(heading).at(loc))
            } else {
              "•" 
            }
            
            v(1.2em) 
            grid(columns: (2.5em, 1fr), column-gutter: 0.5em,
              text(fill: self.colors.p-500, weight: "bold", num),
              it.element.body
            )
          }

          outline(title: none, depth: 1)
        }
      )
    })
  }

  let self = utils.merge-dicts(self, config-page(
    fill: white,
    header: none, 
    footer: none,
    margin: (x: 2.5em, y: 0pt)
  ))
  
  touying-slide(self: self, body)
})

// 分段页
#let focus-slide(title: none) = touying-slide-wrapper(self => {
  let body = {
    set std.align(center + horizon)
    
    let display-title = if title != none { title } else {
      utils.display-current-heading(level: 1)
    }
    
    stack(
      spacing: 3.5em,
      text(size: 1.4em, fill: self.colors.p-200, weight: "bold", tracking: 0.3em)[SECTION],
      
      text(size: 3.8em, fill: self.colors.p-800, strong(display-title)),
      
      std.align(center, line(length: 15%, stroke: 4pt + self.colors.p-500)),
    )
  }
  
  let self = utils.merge-dicts(self, config-page(
    fill: white,
    header: none,
    footer: none,
    margin: (x: 2.5em),
  ))
  
  touying-slide(self: self, body)
})

// 幻灯片
#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  let h-height = 3.2em
  
  let header-bg(self) = {
    let current-title = utils.display-current-heading(level: 2)
    place(top, block(
      fill: self.colors.p-50,
      width: 100%,
      height: h-height,
      inset: (x: 1.5em),
      stroke: (bottom: 0.5pt + self.colors.p-100),
      {
        grid(
          columns: (auto, 1fr),
          rows: h-height,
          align: horizon,
          stack(
            dir: ltr,
            spacing: 0.8em,
            std.align(horizon, auto-size-logo(image("../asset/cdu.png"), 1.8em)),
            
            std.align(horizon, text(weight: "bold", size: 1.3em, fill: self.colors.p-800, current-title)),
          ),
        )
      },
    ))
  }
  
  let footer(self) = {
    set std.align(right + bottom)
    set text(size: 0.9em, fill: self.colors.p-900.opacify(70%))
    pad(right: 1.5em, bottom: 0.8em, self.info.author)
  }
  
  let self = utils.merge-dicts(self, config-page(
    margin: (top: 0pt, bottom: 0pt, x: 2.5em),
    header: none,
    background: header-bg(self),
    footer: footer,
    footer-descent: 0pt,
  ))
  
  set text(fill: self.colors.p-900, size: 18pt)

  show raw.where(block: true): it => block(
    fill: monet-colors.neutral-lightest,
    inset: 10pt,
    radius: 4pt,
    width: 100%,
    it,
  )
  
  let safe-body(body) = {
    set std.align(top)
    v(h-height + 1.2em)
    setting(body)
  }
  
  touying-slide(self: self, config: config, repeat: repeat, setting: safe-body, composer: composer, ..bodies)
})

#let end-slide(content: [感谢聆听], ..args) = touying-slide-wrapper(self => {
  let info = self.info + args.named()
  let body = {
    set std.align(center + horizon)
    auto-size-logo(image("../asset/cdu.png"), 10em)
    v(2.5em)
    text(size: 4em, fill: self.colors.p-800, strong(content))
  }
  let self = utils.merge-dicts(self, config-page(fill: self.colors.p-50, header: none, footer: none, margin: 0pt))
  touying-slide(self: self, body)
})

#let cdu-theme(
  aspect-ratio: "16-9",
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(..utils.page-args-from-aspect-ratio(aspect-ratio), margin: (top: 0em, bottom: 0em, x: 2.5em)),
    config-common(slide-fn: slide),
    config-methods(alert: utils.alert-with-primary-color),
    config-colors(..monet-colors),
    ..args,
  )
  body
}
