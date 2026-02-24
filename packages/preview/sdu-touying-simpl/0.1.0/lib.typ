#import "dependency.typ": *
#let sdu-red=rgb("#880000")
#let sdu-logo = image("../img/sdu.png", width: 40%)
#set text(region: "CN")
#let title-slide(
  config:(:),
  extra:none,
  ..args
)=touying-slide-wrapper(self=>{
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em)
  )
  let info=self.info+args.named()
  let body={
    
    if info.logo!=none{
      align(center+horizon,info.logo)
    }
    let  content={
      block(
        fill: self.colors.primary,
        inset: 1.5em,
        radius: 0.5em,
        breakable: false,
        width: 80%,
        {
          text(size: 1.2em, fill: self.colors.neutral-lightest, weight: "bold", info.title)
          if info.subtitle != none {
            parbreak()
            text(size: 1.0em, fill: self.colors.neutral-lightest, weight: "bold", info.subtitle)
          }
        },
      )
      grid(
        text(fill:black,info.author)
      )
      v(0.2em)
      // 介绍
      if info.institution != none {
        parbreak()
        text(size: 0.8em, info.institution)
      }
      // 日期
      if info.date != none {
        parbreak()
        text(size: 1.0em, datetime.today().display())
      }
    }
    align(center+horizon,content)
  }
  touying-slide(self: self,body)
})

#let sdu-footer(self) ={
  set align(bottom+center)
  set text(size: 0.8em)
  show: pad.with(.0em)
  block(
    width: 100%,
    fill: self.colors.primary,
    grid(
      columns: (auto,auto, 0.9fr, auto,auto,auto),
      h(0.5em),
      text(fill: self.colors.neutral-lightest.lighten(40%), utils.call-or-display(self, self.store.footer-a)),
      none,
      text(fill: self.colors.neutral-lightest.lighten(10%), utils.call-or-display(self, self.store.footer-d)),
      h(0.5em),
      text(fill: self.colors.neutral-lightest.lighten(10%), utils.call-or-display(self, self.store.footer-g)),
      v(0.2em)
    )
  )
  
}

#let footer-backend(self)={
  self=>[
      #if self.store.footer == true {  
        set text(0.7em)
        // Colored Style
        if (self.store.theme=="full") {
            columns(2, gutter:0cm)[
              // Left side of the Footer
              #align(left)[#block(
                width: 100%,
                outset: (left:0.3*self.store.space, bottom: 0cm),
                height: 0.1*self.store.space,
                fill: self.colors.primary,
                inset: (right:3pt)
              )[
                #v(0.1*self.store.space)
                #set align(right)
                #smallcaps()[#if self.info.author != none {self.info.author} else {title}]
                ]
              ]
              // Right Side of the Footer
              #align(right)[#block(
                width: 100%,
                outset: (right:2*self.store.space, bottom: 0cm),
                height: 0.1*self.store.space,
                fill: self.colors.primary,
                inset: (left: 3pt)
              )[
                #v(0.1*self.store.space)
                #set align(left)
                #if self.info.subtitle != none {
                    self.info.subtitle
                } else if subtitle != none {
                    subtitle
                } else if authors != none {
                      if (type(authors) != array) {authors = (authors,)}
                      authors.join(", ", last: " and ")
                    } else [#date]
              ]
            ]
            ]
          } 
          // Normal Styling of the Footer
          else if (self.store.theme == "normal") {
            box()[#line(length: 50%, stroke: 2pt+self.colors.primary )]
            box()[#line(length: 50%, stroke: 2pt+self.colors.primary)]
            v(-0.2cm)
            grid(
              columns: (1fr, 1fr),
              align: (right,left),
              
              inset: 5pt,
              [#smallcaps()[
                #if self.info.author != none {self.info.author} else {title}]],
              [#if self.info.subtitle != none {
                  self.info.subtitle
              } else if subtitle != none {
                  subtitle
              } else if authors != none {
                    if (type(authors) != array) {authors = (authors,)}
                    authors.join(", ", last: " and ")
                  } else [#date]
              ],
              
            )
          }
        } 
      ]
}
#let slide(
  config:(:),
  title: auto,
  subtitle: auto,
  header: auto,
  footer: auto,
  display-current-section: auto,
  ..args,
) = touying-slide-wrapper(self => {
  if title != auto {
    self.title = title
  }
  if subtitle != auto {
    self.subtitle = subtitle
  }
  if header != auto {
    self.header = header
  }
  if footer != auto {
    self.footer = footer
  }
  if display-current-section != auto {
    self.display-current-section = display-current-section
  }
  touying-slide(
    ..args.named(),
    self: self,
    setting: body => {
      show: args.named().at("setting", default: body => body)
      align(horizon, body)
    },
    ..args.pos(),
  )
})

#let new-section-slide(config:(:),title: utils.i18n-outline-title, ..args, body) = touying-slide-wrapper(self=>{
  self = utils.merge-dicts(
    self,
    config-page(),
  )
   touying-slide(
    self: self,
    config: config,
    components.adaptive-columns(
      start: text(
        1.2em,
        fill: self.colors.primary,
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


#let ending-slide(config:(:), title: none, body) = touying-slide-wrapper(self=>{
  let content = {
    set align(center + horizon)
    if title != none {
      block(
        fill: self.colors.tertiary,
        inset: (top: 0.7em, bottom: 0.7em, left: 3em, right: 3em),
        radius: 0.5em,
        text(size: 1.5em, fill: self.colors.neutral-lightest, title),
      )
    }
    body
  }
  touying-slide(self: self, content)
})

#let slides(config:(:), title-slide: true, slide-level: 1, ..args) = touying-slide-wrapper(self=>{
  if title-slide {
    title-slide(self: self)
  }
  touying-slides(self: self, slide-level: slide-level, ..args)
})


#let focus-slide(config:(:),background-color: none,background-img:none,body)=touying-slide-wrapper(self => {
  let background-color = if background-img == none and background-color ==  none {
    self.colors.primary
  } else {
    background-color
  }
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
  )
  set text(fill: white, size: 2em)
  touying-slide(self: self,align(horizon, body))
})

#let matrix-slide(config: (:), columns: none, rows: none, ..bodies) = touying-slide-wrapper(self => {
    self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
  )
  touying-slide(self: self, config: config, composer: (..bodies)=>{
    let bodies = bodies.pos()
    let columns = if type(columns) == int {
      (1fr,) * columns
    } else if columns == none {
      (1fr,) * bodies.len()
    } else {
      columns
    }
    let num-cols = columns.len()
    let rows = if type(rows) == int {
      (1fr,) * rows
    } else if rows == none {
      let quotient = calc.quo(bodies.len(), num-cols)
      let correction = if calc.rem(bodies.len(), num-cols) == 0 { 0 } else { 1 }
      (1fr,) * (quotient + correction)
    } else {
      rows
    }
    let num-rows = rows.len()
    if num-rows * num-cols < bodies.len() {
      panic("number of rows (" + str(num-rows) + ") * number of columns (" + str(num-cols) + ") must at least be number of content arguments (" + str(bodies.len()) + ")")
    }
    let cart-idx(i) = (calc.quo(i, num-cols), calc.rem(i, num-cols))
    let color-body(idx-body) = {
      let (idx, body) = idx-body
      let (row, col) = cart-idx(idx)
      let color = if calc.even(row + col) { white } else { silver }
      set align(center + horizon)
      rect(inset: .5em, width: 100%, height: 100%, fill: color, body)
    }
    let content = grid(
      columns: columns, rows: rows,
      gutter: 0pt,
      ..bodies.enumerate().map(color-body)
    )
    content
  },..bodies)
})

#let sdu-theme(
  aspect-ratio: "16-9",
  footer-line-color:none,
  footer-columns:true,
  footer-a:self=>self.info.author,
  footer-b:self=>utils.info-date(self),
  footer-c:self=>if self.info.short-title == auto {
    self.info.title
  }else{
    self.info.short-title
  },
  footer-d:context utils.slide-counter.display() + " / " + utils.last-slide-number,
  footer-g: self => {
    link("https://github.com/Dregen-Yor/sdu-typst-touying",image("img/github-mark-white.svg",width:1.2em))
  },
  ..args,
  body
)={

  show: touying-slides.with(
    config-colors(
      primary: sdu-red,
      primary-dark: rgb("#004098"),
      secondary: rgb("#ffffff"),
      tertiary: sdu-red,
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
      themeblue: rgb("#4285f4"),
      themegreen: rgb("#34a853"),
      themeyellow: rgb("#fbbc05"),
      themered: rgb("#ea4335"),
    ),
    config-store(
      align: align,
      count: true,
      theme: "normal",
      alpha: 60%,
      footer:true,
      space:1cm,
      sdu-knob-marker :self=> box(
        width: 0.5em,
        place(
          dy: 0.1em,
          circle(
            fill: gradient.radial(self.colors.primary.lighten(100%), self.colors.primary.darken(40%), focal-center: (30%, 30%)),
            radius: 0.25em,
          ),
        ),
      ),
      footer-a: footer-a,
      footer-b: footer-b,
      footer-c: footer-c,
      footer-d: footer-d,
      footer-line-color: footer-line-color,
      footer-g:footer-g,
    ),
    config-common(
      new-section-slide-fn: new-section-slide,
    ),
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (top: 2.5cm, bottom: 2cm, x: 1.3cm),
      header: self=>[
        #align(left+top)[
          #context {  
            let page = here().page()
            let headings = query(selector(heading.where(level: 2)))
            let heading = headings.rev().find(x => x.location().page() <= page)
            if heading != none {
              if (self.store.theme == "full") {
                block(
                  width:100%,
                  fill: self.colors.primary,
                  height: self.store.space*1.8,
                  // outset: (x: 0.5 * self.store.space)
                )[
                  #set text(1.4em, weight: "bold", fill: white)
                  #v(self.store.space / 2)
                  #heading.body 
                  #if not heading.location().page() == page [
                    #{numbering("(i)", page - heading.location().page() + 1)}
                  ]
                ]
              }
              else if (self.store.theme == "normal") {
                v(self.store.space /1)
                // h(self)
                set text(1.4em, weight: "bold", fill: self.colors.primary)
                block(h(1cm)+heading.body +
                  if not heading.location().page() == page [
                    #{numbering("(i)", page - heading.location().page() + 1)}
                  ]
                )
              }
            }
          }
        ]
        
    // COUNTER
      #if self.store.count == true {
        v(-self.store.space/1)
        align(right+top)[
          #context {
            let last = counter(page).final().first()
            let current = here().page()
            // Before the current page
            for i in range(1,current) {
              link((page:i, x:0pt,y:0pt))[
                #box(circle(radius: 0.08cm, fill: self.colors.primary, stroke: 1pt+self.colors.primary)) 
              ]
            }
            // Current Page
            link((page:current, x:0pt,y:0pt))[
                #box(circle(radius: 0.08cm, fill: self.colors.primary, stroke: 1pt+self.colors.primary)) 
              ]
            // After the current page
            for i in range(current+1,last+1) {
              link((page:i, x:0pt,y:0pt))[
                #box(circle(radius: 0.08cm, stroke: 1pt+self.colors.primary)) 
              ]
            }
            }
            #h(1cm)
          ] 
        }
      ],
      footer:sdu-footer,
      header-ascent:2cm,
      footer-descent:0%,
      
    ),
    config-methods(
      slide:slide,
      title-slide:title-slide,
      // outline-slide:outline-slide,
      new-section-slide:new-section-slide,
      ending-slide:ending-slide,
      focus-slide:focus-slide,
      matrix-slide:matrix-slide,
      slides:slides,
      touying-new-section-slide:new-section-slide,
      alert:(self:none,it)=>text(fill:self.colors.primary, it),
      tblock:(self:none,title:none,it)=>{
        grid(
          columns: 1,
          row-gutter: 0pt,
          block(
          fill: self.colors.primary-dark,
          width: 100%,
          radius: (top: 6pt),
          inset: (top: 0.4em, bottom: 0.3em, left: 0.5em, right: 0.5em),
          text(fill: self.colors.neutral-lightest, weight: "bold", title),
        ),
          rect(
            fill: gradient.linear(self.colors.primary-dark, self.colors.primary.lighten(90%), angle: 90deg),
            width: 100%,
            height: 4pt,
          ),
          block(
            fill: self.colors.primary.lighten(90%),
            width: 100%,
            radius: (bottom: 6pt),
            inset: (top: 0.4em, bottom: 0.5em, left: 0.5em, right: 0.5em),
            it,
          ),
        )
      },
      init: (self: none, body) => {
        set text(size: 20pt)
        show heading: set text(fill: self.colors.primary)
        set list(marker: self.store.sdu-knob-marker)
        show figure.caption: set text(size: 0.6em)
        show footnote.entry: set text(size: 0.6em)
        show link: it => if type(it.dest) == str {
          set text(fill: self.colors.primary)
          it
        } else {
          it
        }
        body
      },
    ),
    ..args
  )
  body
}