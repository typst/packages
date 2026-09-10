#import "@preview/touying:0.7.4": *
#import "themes_colors.typ":*

#let alert_box(content, angle: 0deg, content_color: black) = {
  box(
    radius: 0.1em, 
    stroke: (2pt + oklch(40%, 0.2, angle, 100%)), 
    fill: oklch(95%, 0.05, angle, 80%), 
    inset: (x: 0.3em),
    outset: (y: 0.3em),
  )[#text(content_color)[#content]]
}

#let section-counter = counter("section")

#show heading.where(level: 1): it => {
  section-counter.step()
  it
}


#let dots(
  current,
  total,
  active-color,
  section-breaks: (),
  inactive-color: none,
  stroke-color: none,
  radius: 0.15cm,
  spacing: 0.1cm,
)={
    context {

    let elems = ()

    let slides = query(<touying-metadata>).filter(
      it => utils.is-kind(it, "touying-new-slide")
    )

    for i in range(calc.min(total, slides.len())) {

      if section-breaks.contains(i + 1) {
        elems.push(h(0.5em))
      }

      let slide = slides.at(i)

      elems.push(
        link(slide.location())[
          #circle(
            radius: radius,
            fill: if i + 1 <= current {
              active-color
            } else {
              inactive-color
            },
            stroke: 2pt + if stroke-color == none {
              active-color
            } else {
              stroke-color
            },
          )
        ]
      )
    }

    stack(
      dir: ltr,
      spacing: spacing,
      ..elems,
    )
  }
}


#let progress-indicator(self) = context {
  let active = self.colors.neutral-lightest
  let light-grey = self.colors.light-grey
  let dark-grey = self.colors.dark-grey
  
  if self.store.progress == "slide" {
  
    context {
      let current = utils.slide-counter.get().first()
      let total = utils.slide-counter.final().first()

      dots(current, total, active)
    }  
  }

  else if self.store.progress == "section" {

    context {
      let current_page = utils.current-heading().location().page()

      let sections = query(heading.where(level: 1))

      let current_idx = 0

      for sec in sections {
        if sec.location().page() <= current_page {
          current_idx += 1
        }
      }
      dots(current_idx, sections.len(), active)
    }

  }

  else if self.store.progress == "slide-by-section" {

    context{
      let current = utils.slide-counter.get().first()
      let total = utils.slide-counter.final().first()

      let section_breaks = query(heading.where(level: 1)).map(sec => sec.location().page()).slice(1)

      dots(
        current,
        total,
        active,
        section-breaks: section_breaks,
      )
    }

  }

  else if self.store.progress == "mini" {
    context components.mini-slides(display-section:false) 
  }
}

#let header(self) = {
  set align(top)

  show: components.cell.with(
    fill: self.colors.primary,
    inset: (
      top: 0.1em,
      right: 1em,
      bottom: 0em,
      left: 1em,
    )
  )

  let outline = utils.is-kind(self, "new-section-slide")


  grid(
    columns: (1fr, 1fr, auto),
    gutter: 1em,
    [
      #v(1em)
      #stack(
        dir: ttb,
        spacing: 0.15em,

        text(
          size: .7em,
          fill: self.colors.neutral-lightest,
          utils.display-current-heading(level: 1),
        ),

        text(
          size: 1.5em,
          fill: self.colors.neutral-lightest,
          if self.store.title != none {
            utils.call-or-display(self, self.store.title)
          } else {
            utils.display-current-heading(level: 2)
          },
        ),
      )    
    ],
    [
      #if not self.store.is_outline{
      align(center + horizon)[
        #progress-indicator(self)
      ]}
    ],
    [
      #if self.store.logo != none {
        image(self.store.logo, height: 1.85cm)
      }
    ],
  )

} 

#let footer(self) = {
  set align(bottom)

  grid(
    columns: (2fr, auto),
    gutter: 0pt,
    // Left part
    grid(
      columns: (2fr, 1fr),
      rect(
        fill: self.colors.neutral-darkest, // or a light theme color
        width:100%,
        inset: (x: 0.8em, y: 0.2em),
        )[
          #set text(size: 0.8em, fill: black)

          #align(right)[
            #utils.call-or-display(self, self.store.short_title)
          ]

        ],

      rect(
        fill: self.colors.neutral-lightest, // or a light theme color
        width:100%,
        inset: (x: 0.8em, y: 0.2em),
        )[
          #set text(size: 0.8em, fill: black)

          #utils.call-or-display(self, self.store.author)

        ]
      ),

    // Right part
    rect(
      fill: self.colors.primary,
      inset: (x: 0.8em, y: 0.2em),
    )[
      #set text(
        size: 0.8em,
        fill: self.colors.neutral-lightest,
        weight: "bold",
      )

      #context[
        #utils.slide-counter.display() / #utils.last-slide-number
      ]
    ],
  )
}
#let title-slide(
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-page(
      margin: (top:0pt, left:5%, bottom:0pt, right:0pt),
      header: none,
      footer: none,
    ),
  )

  touying-slide(
    self: self,
    ..args,
    [
      #place(top + right)[
        #polygon(
          fill: self.colors.primary,
            (70%, 0%),
            (100%, 0%),
            (100%, 100%),
            (60%, 100%)
          ,
        )
      ]

      #place(right + bottom, dx:-1%, dy:-3%)[
        #image(
          self.store.logo_name,
          width: 10cm,
        )
      ]
      // Foreground
     #place(left + horizon)[
        #block(width: 55%)[
          #align(left + horizon)[
            #block(width: 60%)[
              #stack(
                spacing: 1em,

              text(size: 34pt, weight: "bold")[#self.store.title],

              if self.store.title != none {
                text(size: 22pt, fill: self.colors.dark-grey)[#self.store.short_title]
              },

              v(2em),

              if self.store.author != none {
                text(size: 18pt)[#self.store.author]
              },

              if self.store.institute != none {
                text(size: 16pt)[#self.store.institute]
              },

              if self.store.date {
                text(size: 16pt)[#datetime.display(datetime.today())]
              },
              )
            ]
        ]
      ]]
    ]
  )
})

#let new-section-slide(
    ..args
  ) = touying-slide-wrapper(self => {
    self.store.is_outline = true
    self = utils.merge-dicts(
      self,
      config-page(
        header: header,
        footer: footer, // or simply omit if you want the normal footer
      ),
    )

   

    touying-slide(
      self: self,
      [
          #show outline.entry: it => {
            
            let prefix = if self.store.prefix == "triangle" {
                  text(
                    fill: self.colors.primary,
                    size: 0.7em,
                  )[▶]
                } else if self.store.prefix == "numbering" {
                  it.prefix()
                } else {
                  []
                }

            let relationship = utils.section-relationship(it)
            let current = utils.current-heading()

            let alpha = if relationship < 0 {
                                              40%
                                            } else {
                                              100%
                                            }

            let weight = if relationship == 0 and current.level == it.level {
              "bold"
            } else {
              "regular"
            }

            let size = 15pt

            if calc.abs(relationship) < 0 {
              text(fill: self.colors.dark-grey, weight:weight, size: size, it)
            } else {
              text(
                fill: utils.update-alpha(self.colors.dark-grey, alpha),
                weight: weight,
                size:size,
                link(
                  it.element.location(),
                  it.indented(prefix, it.inner()),
                ),
              )
            }
          }
          #outline(title: none, depth:1)
          
      ],
    )
  })

#let slide(title: auto, ..args) = touying-slide-wrapper(self => {
  self.store.is_outline = false
  if title != auto {
    self.store.title = title
  }
   self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  touying-slide(self: self, ..args)
})

#let ricopallazzo-uni-theme(
  aspect-ratio: "presentation-16-9",
  theme: "blue",
  title: none,
  short_title: none,
  author: none,
  institute: none,
  date: true,
  footer: none,
  logo: "../assets/logo_RGB_negative_circle.png",
  logo_name: "../assets/logo_coutour_name.png",
  progress: "slide",
  prefix: "numbering",
  ..args,
  body,
) = {

  let colors = themes.at(theme, default: themes.blue)
  set text(size: 20pt)

  show: touying-slides.with(
    config-page(
      paper: aspect-ratio,
      margin: (top: 4em, bottom: 1.5em, x: 2em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
      title-slide-fn: title-slide,
    ),
    config-methods(
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: colors.primary,
      neutral-lightest: colors.lightest,
      neutral-darkest: colors.darkest,
      light-grey: colors.light-grey,
      dark-grey: colors.dark-grey
    ),
    config-store(
      title: title,
      short_title: short_title,
      author: author,
      institute: institute,
      date:date,
      footer: footer,
      logo: logo,
      logo_name: logo_name,
      progress: progress,
      prefix: prefix
    ),
    ..args,
  )

  body
}
