
#import "mod.typ": *
#show: style

#heading(level: 1, outlined: false, "目录")

#{
  show: outline-font-style
  outline(title: none)
}

= 图目录

#outline(title: none, target: figure.where(kind: image))

= 表目录

#outline(title: none, target: figure.where(kind: table))


#switch-two-side(双页模式)
