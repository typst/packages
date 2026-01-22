#import "./dependency.typ": *

// Color definition from: https://xcb.buaa.edu.cn/info/1091/2057.htm
#let buaa-blue = rgb(0, 61, 166)
#let sky-blue = rgb(0, 155, 222)
#let chinese-red = rgb(195, 13, 35)
#let quality-grey = rgb(135, 135, 135)
#let pro-gold = rgb(210, 160, 95)
#let pro-silver = rgb(209, 211, 211)
#let buaa-blue-grad = gradient.linear(buaa-blue, buaa-blue.lighten(80%))

#let buaa-header(self) = {
  let block-grad = gradient.linear(
    (self.colors.primary, 0%),
    (white, 95%),
    (white, 100%),
  )
  set text(size: 20pt)
  let body = {
    grid(
      columns: (1fr, auto),
      block(
        fill: block-grad,
        height: 100%,
        width: 100%,
        inset: (left: 1em, right: 1em),
        align(
          left + horizon,
          text(1.5em, fill: white, weight: "bold", utils.display-current-heading(level: 2)),
        ),
      ),
      block(
        height: 100%,
        inset: (right: 1em),
        align(
          right + horizon,
          image("../icon/SchoolBadgeBlue-1.svg", height: 60%),
        ),
      ),
    )
  }

  body
}

#let buaa-footer(self) = {
  set text(size: 20pt)
  let body = context {
    block(
      height: 100%,
      width: 100%,
      inset: (x: 1em),
      align(
        right + horizon,
        text(1em, fill: self.colors.pro-silver, utils.slide-counter.display()),
      ),
    )
  }

  body
}

#let slide(
  title: auto,
  config: (:),
  body,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-page(
      header: buaa-header,
      footer: buaa-footer,
    ),
  )
  touying-slide(self: self, body, ..args)
})

#let title-slide(
  config: (:),
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
  )
  set text(size: 20pt)
  let info = self.info + args.named()
  let body = {
    set par(leading: 1.5em)
    grid(
      rows: (4fr, 2fr),
      block(
        fill: self.colors.primary-grad,
        height: 100%,
        width: 100%,
        inset: 3em,
        {
          set text(fill: white)
          align(
            left + top,
            image("../icon/SchoolBadgeWhite-1.svg", height: 3em)
              + text(2em, weight: "bold", info.title)
              + (
                if info.subtitle != none {
                  linebreak()
                  text(1.5em, info.subtitle)
                }
              )
              + place(
                right + horizon,
                dx: 6em,
                dy: 1.5em,
                image("../icon/SchoolBadgeWhite-2.svg", height: 20em),
              ),
          )
        },
      ),
      block(
        height: 100%,
        width: 100%,
        inset: (x: 3em, y: 1em),
        {
          set text(1em, fill: self.colors.primary)
          align(
            left + horizon,
            (
              if info.author != none {
                info.author
              }
            )
              + (
                if info.institution != none {
                  h(2.5em)
                  text(fill: self.colors.primary, "|")
                  h(2.5em)
                  info.institution
                }
              )
              + (
                if info.date != none {
                  linebreak()
                  utils.display-info-date(self)
                }
              ),
          )
        },
      ),
    )
  }
  touying-slide(self: self, body)
})

#let new-section-slide(
  config: (:),
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
  )
  set text(size: 20pt)
  let body = {
    grid(
      rows: (1fr, 3fr, 1fr),
      block(
        width: 100%,
        height: 100%,
        place(
          bottom,
          dy: -0.5em,
          rect(
            width: 100%,
            height: 0.25em,
            stroke: none,
            fill: self.colors.primary-grad,
          ),
        )
          + place(
            left + horizon,
            dx: 1em,
            dy: -0.25em,
            image("../icon/SchoolBadgeBlue-1.svg", height: 40%),
          ),
      ),
      block(
        height: 100%,
        width: 100%,
        fill: self.colors.primary-grad,
        inset: (left: 8em, right: 3em),
        align(
          horizon,
          grid(
            columns: (auto, 4em, auto),
            align: horizon + center,
            text(5em, fill: white, weight: "bold", utils.display-current-heading-number(numbering: "01")),
            line(angle: 90deg, length: 5em, stroke: (paint: white, thickness: 2.5pt, cap: "round")),
            move(
              dy: 0.2em,
              text(3em, fill: white, weight: "bold", utils.display-current-heading(level: 1, numbered: false)),
            ),
          ),
        )
          + place(
            right + horizon,
            dx: 6em,
            image("../icon/SchoolBadgeWhite-2.svg", height: 20em),
          ),
      ),
      block(
        width: 100%,
        height: 100%,
        place(
          top,
          dy: 0.5em,
          rect(
            width: 100%,
            height: 0.25em,
            stroke: none,
            fill: self.colors.primary-grad,
          ),
        ),
      ),
    )
  }
  touying-slide(self: self, body)
})

#let outline-slide(
  config: (:),
  title: utils.i18n-outline-title,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
  )
  set text(size: 20pt)
  let block-grad = gradient.linear(
    dir: ttb,
    (self.colors.primary, 0%),
    (self.colors.primary-light, 40%),
    (self.colors.primary-light, 60%),
    (self.colors.primary-lightest, 100%),
  )
  let circled-numbering(..nums) = {
    let n = nums.pos().last()
    box(
      baseline: 0.4em,
      inset: (right: 0.5em),
      circle(
        radius: 0.8em,
        stroke: none,
        inset: 0pt,
        fill: self.colors.primary-light,
        align(
          center + horizon,
          text(1em, fill: white, weight: "bold", str(n)),
        ),
      ),
    )
  }
  let body = {
    grid(
      columns: (2fr, 5fr),
      block(
        height: 100%,
        width: 100%,
        fill: block-grad,
        inset: (top: 1.5em, bottom: 1em, x: 1em),
        place(
          center + top,
          image("../icon/SchoolBadgeWhite-3.svg", width: 100%),
        )
          + place(
            center + horizon,
            text(2.5em, fill: white, weight: "bold", title),
          ),
      ),
      block(
        height: 100%,
        width: 100%,
        inset: (left: 5em),
        align(
          center + horizon,
          text(
            1.8em,
            fill: self.colors.primary-light,
            weight: "bold",
            components.custom-progressive-outline(
              depth: 1,
              vspace: (0em,),
              numbered: (true,),
              numbering: (circled-numbering,),
            ),
          ),
        ),
      ),
    )
  }
  touying-slide(self: self, body)
})

#let end-slide(
  remark: [Thanks for Listening],
  config: (:),
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
  )
  set text(size: 20pt)
  let body = {
    grid(
      rows: (1fr, 3fr, 1fr),
      block(
        width: 100%,
        height: 100%,
        place(
          bottom,
          dy: -0.5em,
          rect(
            width: 100%,
            height: 0.25em,
            stroke: none,
            fill: self.colors.primary-grad,
          ),
        )
          + place(
            left + horizon,
            dx: 1em,
            dy: -0.25em,
            image("../icon/SchoolBadgeBlue-1.svg", height: 40%),
          ),
      ),
      block(
        height: 100%,
        width: 100%,
        fill: self.colors.primary-grad,
        place(
          center + horizon,
          text(2.5em, fill: white, weight: "bold", remark),
        )
          + place(
            center + horizon,
            image("../icon/SchoolBadgeWhite-2.svg", height: 90%),
          ),
      ),
      block(
        height: 100%,
        width: 100%,
        fill: white,
        place(
          top,
          dy: 0.5em,
          rect(
            width: 100%,
            height: 0.25em,
            stroke: none,
            fill: self.colors.primary-grad,
          ),
        )
          + place(
            top + left,
            dy: 1.5em,
            dx: 1.5em,
            text(1em, fill: self.colors.primary, self.info.author),
          )
          + (
            if self.info.date != none {
              place(
                top + right,
                dy: 1.5em,
                dx: -1.5em,
                text(1em, fill: self.colors.primary, utils.display-info-date(self)),
              )
            }
          ),
      ),
    )
  }
  touying-slide(self: self, body)
})

#let buaa-theme(
  aspect-ratio: "16-9",
  ..args,
  body,
) = {
  set text(size: 20pt)
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      margin: (x: 2em, bottom: 30pt, top: 70pt),
      header-ascent: 17.5pt,
      footer-descent: 0pt,
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-colors(
      primary: buaa-blue,
      primary-light: buaa-blue.lighten(20%),
      primary-lighter: buaa-blue.lighten(50%),
      primary-lightest: buaa-blue.lighten(80%),
      secondary: sky-blue,
      tertiary: chinese-red,
      quality-grey: quality-grey,
      pro-gold: pro-gold,
      pro-silver: pro-silver,
      primary-grad: buaa-blue-grad,
    ),
    config-info(
      date: datetime.today(),
    ),

    ..args,
  )
  set heading(numbering: numbly("{1}.", default: "1.1"))
  set par(justify: true)
  body
}
