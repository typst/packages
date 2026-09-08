#let report(
  title: "标题",
  subtitle: "副标题",
  student: (name: "姓名", id: "学号"),
  school: "学院",
  major: "专业",
  class: "班级",
  date: datetime.today(),
  logo: true,
  accent-color: rgb(0, 86, 32),
  alpha: 60%,
  body,
) = {
  set document(
    author: student.name,
    title: title,
  )

  set heading(numbering: (..nums) => {
    let nums = nums.pos()

    if nums.len() == 1 {
      numbering("一", ..nums)
    } else {
      numbering("1.1", ..nums)
    }
  })

  set par(justify: true)

  set text(
    font: "Noto Serif CJK SC",
    lang: "zh",
    size: 12pt,
  )

  show link: set text(fill: blue)

  show raw: set text(
    font: "Maple Mono NFMono",
    features: ("cv01", "cv02", "cv04"),
  )
  show raw.where(block: true): it => block(
    fill: luma(90%),
    inset: 1em,
    radius: 0.2em,
    width: 100%,
    it,
  )
  show raw.where(block: false): it => box(
    fill: luma(90%),
    inset: (x: 0.2em),
    outset: (y: 0.2em),
    radius: 0.2em,
    it,
  )

  let primary-color = accent-color
  let secondary-color = color.mix(color.rgb(100%, 100%, 100%, alpha), primary-color, space:rgb)

  page({
    if logo == true {
      place(top + right, image("../assets/images/logo.png", width: 40%))
    }
    place(top + left, dx: -35%, dy: -28%, circle(radius: 150pt, fill: primary-color))
    place(top + left, dx: -10%, circle(radius: 75pt, fill: secondary-color))
    place(bottom + right, dx: 40%, dy: 30%, circle(radius: 150pt, fill: secondary-color))

    set align(center)

    v(2fr)

    text(size: 3em, weight: "bold", title)

    v(0em)

    text(size: 2em, weight: "bold", subtitle)

    v(0em)

    text(size: 1.2em, date.display())

    v(2fr)

    text(font: "ChillKai", size: 1.5em, weight: "bold", student.name + " " + student.id)

    v(0em)

    text(font: "ChillKai", size: 1.2em, school + " " + major)

    v(0em)

    text(font: "ChillKai", size: 1.2em, class)
  })

  body
}