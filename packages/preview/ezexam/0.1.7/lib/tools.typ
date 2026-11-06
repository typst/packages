#import "const-state.typ": subject-state
// 一种页码格式: "第x页（共xx页）
#let zh-arabic(prefix: "", suffix: "") = (..nums) => {
  let arr = nums.pos()
  [#prefix#h(1em)#subject-state.get()#suffix#h(1em)第#str(arr.at(0))页（共#str(arr.at(-1))页）]
}

#let inline-square(num, width: 1.5em, gap: 0pt, body: "") = {
  set square(stroke: .5pt, width: width)
  grid(
    columns: num,
    gutter: gap,
    ..num * (square(body),)
  )
}

#let multi = text(maroon)[（多选）]

#let color-box(body, color: blue, dash: "dotted", radius: 3pt) = {
  box(
    outset: .35em,
    radius: radius,
    stroke: (
      thickness: .5pt,
      dash: dash,
      paint: color,
    ),
    text(font: kai-ti, color, body),
  )
  h(.8em)
}

