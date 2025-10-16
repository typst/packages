#import "const-state.typ":hei-ti
#let _create-seal(
  dash: "dashed",
  supplement: "",
  info: (:),
) = {
  assert(type(info) == dictionary, message: "expected dictionary, found " + str(type(info)))
  set par(spacing: 10pt)
  set text(font: hei-ti, size: 12pt)
  set align(center)
  set grid(columns: 2, align: horizon, gutter: .5em)
  if supplement != "" { text(tracking: .8in, supplement) }
  grid(
    columns: if info.len() == 0 { 1 } else { info.len() },
    gutter: 1em,
    ..for (key, value) in info {
      (
        grid(
          key,
          value,
        ),
      )
    }
  )
  line(length: 100%, stroke: (dash: dash))
}

#let draft(
  name: "草稿纸",
  student-info: (
    姓名: underline[~~~~~~~~~~~~~],
    准考证号: underline[~~~~~~~~~~~~~~~~~~~~~~~~~~],
    考场号: underline[~~~~~~~],
    座位号: underline[~~~~~~~],
  ),
  dash: "solid",
  supplement: "",
) = {
  set page(margin: .5in, header: none, footer: none)
  title(name.split("").join(h(1em)), bottom: 0pt)
  _create-seal(dash: dash, supplement: supplement, info: student-info)
}