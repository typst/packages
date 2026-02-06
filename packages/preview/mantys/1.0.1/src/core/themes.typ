#import "../util/utils.typ": dict-merge

#import "../themes/default.typ": default
#import "../themes/modern.typ"
#import "../themes/cnltx.typ"
#import "../themes/orly.typ"


#let themable-init(theme) = body => {
  show <mantys:themable>: it => {
    let element = it.value
    (element.func)(theme, ..element.args)
  }
}

#let themable(func, kind: "themable", ..args) = [#metadata((func: func, args: args.pos(), kind: kind))<mantys:themable>]


#let create-theme(..theme-args, base-theme: default) = {
  if type(base-theme) == module {
    base-theme = dictionary(base-theme)
  }
  return dict-merge(base-theme, theme-args.named())
}


#let color-theme(primary, secondary, ..theme-args, base-theme: default) = {
  return create-theme(
    primary: primary,
    secondary: secondary,
    heading: (
      fill: primary,
    ),
    emph: (
      link: secondary,
      package: primary,
    ),
    ..theme-args.named(),
    base-theme: base-theme,
  )
}
