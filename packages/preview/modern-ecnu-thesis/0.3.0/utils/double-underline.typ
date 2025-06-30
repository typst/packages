// 双下划线
#let double-underline(body) = style(styles => {
  let size = measure(body, styles)
  stack(
    body,
    v(3pt),
    line(length: size.width),
    v(2pt),
    line(length: size.width),
  )
})