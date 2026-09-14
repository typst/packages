// Layout primitives for Touying Endfield Theme (header/footer).

#import "@preview/touying:0.6.3": *
#import "../custom-components.typ"

#let _typst-builtin-repeat = repeat

#let endfield-header(self) = {
  if self.store.navigation == "sidebar" {
    place(
      left + top,
      {
        show: block.with(
          width: self.store.sidebar.width - 1em,
          inset: 1em,
          fill: self.colors.neutral-dark.darken(50%),
          height: 24em, // hack to make it just above footer: 24em - 0.5em x 2 (padding) - 0.8em (footer height) = 22.2em
        )
        set align(left)
        set par(justify: false)
        set text(size: .9em)
        components.custom-progressive-outline(
          self: self,
          level: auto,
          alpha: self.store.alpha,
          text-fill: (self.colors.primary, self.colors.neutral-lightest),
          text-size: (1em, .9em),
          vspace: (-.2em,),
          indent: (0em, self.store.sidebar.at("indent", default: .5em)),
          fill: (
            self.store.sidebar.at("fill", default: _typst-builtin-repeat[.]),
          ),
          filled: (self.store.sidebar.at("filled", default: false),),
          paged: (self.store.sidebar.at("paged", default: false),),
          short-heading: self.store.sidebar.at("short-heading", default: true),
        )
      },
    )
  } else if self.store.navigation == "mini-slides" {
    block(
      fill: self.colors.neutral-dark.darken(50%),
      height: self.store.mini-slides.height - 1em,
      custom-components.mini-slides(
        self: self,
        fill: self.colors.primary,
        alpha: self.store.alpha,
        display-section: self.store.mini-slides.at("display-section", default: false),
        display-subsection: self.store.mini-slides.at("display-subsection", default: true),
        linebreaks: false,
        inline: self.store.mini-slides.at("inline", default: false),
        spacing: self.store.mini-slides.at("spacing", default: .5em),
        short-heading: self.store.mini-slides.at("short-heading", default: true),
        current-slide-sym: self.store.mini-slides.at(
          "current-slide-sym",
          default: $triangle.small.b.filled$,
        ),
        other-slides-sym: self.store.mini-slides.at(
          "other-slides-sym",
          default: $triangle.small.t.stroked$,
        ),
      ),
    )
    v(1em)
  }
}

#let endfield-footer(self) = {
  set align(bottom)
  set text(size: 0.8em)
  stack(
    dir: ttb,
    if self.store.navigation == "sidebar" {
      line(stroke: .2em + self.colors.primary, length: 100%)
    } else {
      stack(
        dir: ltr,
        line(stroke: .2em + self.colors.neutral-dark.darken(50%), length: 2em),
        line(stroke: .2em + cmyk(100%, 0%, 0%, 0%), length: 2em),
        line(stroke: .2em + cmyk(0%, 100%, 0%, 0%), length: 2em),
        line(stroke: .2em + self.colors.primary, length: 100% - 2em * 3), // to fill the rest
      )
    },
    block(
      fill: self.colors.neutral-dark.darken(50%),
      width: 100%,
      inset: .5em,
      components.left-and-right(
        text(
          fill: self.colors.neutral-light,
          utils.call-or-display(self, self.store.footer),
        ),
        block(
          fill: self.colors.neutral-dark.darken(20%),
          outset: .5em,
          text(
            fill: self.colors.neutral-light,
            utils.call-or-display(self, self.store.footer-right),
          ),
        ),
      ),
    ),
  )
}

