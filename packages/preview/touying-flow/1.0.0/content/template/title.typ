#import "@preview/touying-flow:1.0.0":*
#show: flow-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.title,
  footer-alt: self => self.info.subtitle,
  navigation: "mini-slides",
  config-info(
    title: [Title],
    subtitle: [Subtitle],
    author: [Quaternijkon],
    date: datetime.today(),
    institution: [USTC],
  ),
)

#let primary= rgb("#004098")

#show :show-cn-fakebold // Used to display bold Chinese text

// Set the style for the title
// #set heading(numbering: numbly("{1}.", default: "1.1"))
#show outline.entry.where(
  level: 1
): it => {
  v(1em, weak: true)
  text(primary, it.body)
}


/*
highlighter. Usage:
_Your text_
or
#emph[Your text]
*/
#show emph: it => {  
  underline(stroke: (thickness: 1em, paint: primary.transparentize(95%), cap: "round"),offset: -7pt,background: true,evade: false,extent: -8pt,text(primary, it.body))
}

#title-slide()

= #smallcaps("Section")

== Page            