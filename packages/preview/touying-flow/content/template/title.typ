#import "../../theme.typ": *
// #import "../../lib.typ"

#show: dewdrop-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.title,
  footer-alt: self => self.info.subtitle,
  navigation: "mini-slides",
  config-info(
    title: [这是空白模板文件，新建slide的时候，直接copy该文件夹，然后修改新的文件即可],
    subtitle: [就像`content/your_slide_title`文件夹一样],
    author: [Quaternijkon],
    date: datetime.today(),
    institution: [XXXX, USTC],
  ),
)

#show :show-cn-fakebold

// #set heading(numbering: numbly("{1}.", default: "1.1"))

#let primary= rgb("#004098")//theme.typ里有一个同RGB的颜色，记得一起修改。

/*
用于实现类似荧光笔的效果，使用方法：

_文字_

或者

#emph[文字]

*/
#show emph: it => {  
  underline(stroke: (thickness: 1em, paint: primary.transparentize(95%), cap: "round"),offset: -7pt,background: true,evade: false,extent: -8pt,text(primary, it.body))
}


#show outline.entry.where(
  level: 1
): it => {
  v(1em, weak: true)
  text(primary, it.body)
}

#title-slide()

= #smallcaps("Start")//大标题

== Page             //slide标题