// 双下划线
#let double-underline(body) = context {
  let size = measure(body)
  stack(
    body,
    v(3pt),
    line(length: size.width),
    v(2pt),
    line(length: size.width),
  )
}