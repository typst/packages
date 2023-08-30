
#let apply(
  variant: "rose-pine"
) = {
  return  (content) => [
    #import "themes/" + variant + ".typ": theme
    #theme(content)
  ]
}
