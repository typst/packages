
#let sidecaption(
  body, 
  direction: ltr, 
  label: none,
  spacing: 1em,
  caption-width: 67%,
  caption-padding: arguments(),
) = {
  show figure: (it)=>{
    stack(
      spacing: spacing,
      dir: direction,
      block(
        width: (caption-width) - (spacing), 
        pad(..caption-padding, it.caption)
      ), 
      it.body
    )
  }
  place(float: true, auto, [#body#label])
}