#import "/utils/datetime-display.typ": datetime-display
#import "/utils/style.typ": 字号, 字体, sysucolor

// 封面
#let cover(
  info: (:),

  // 其他参数
  stoke-width: 0.5pt,
  min-title-lines: 2,
  info-inset: (x: 0pt, bottom: 1pt),
  info-key-width: 72pt,
  info-key-font: "黑体",
  info-value-font: "宋体",
  column-gutter: -3pt,
  row-gutter: 11.5pt,
  bold-info-keys: ("title",),
  bold-level: "bold",
) = {

  assert(type(info.title) == array)
  assert(type(info.author) == dictionary)

  info.title = info.title + range(min-title-lines - info.title.len()).map((it) => "　")
  if type(info.submit-date) == datetime {
    info.submit-date = datetime-display(info.submit-date)
  }

  // 内置辅助函数
  let info-key(
    font: 字体.at(info-key-font, default: "黑体"),
    size: 字号.小三,
    body,
  ) = {
    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      text(
        font: font,
        size: size,
        body,
      ),
    )
  }

  let info-value(
    font: 字体.at(info-value-font, default: "宋体"),
    size: 字号.小三,
    key,
    body,
  ) = {
    set align(center)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: (bottom: stoke-width + black),
      text(
        font: font,
        size: size,
        weight: if (key in bold-info-keys) { bold-level } else { "regular" },
        bottom-edge: "descender",
        body,
      ),
    )
  }

  let info-long-value(
    font: 字体.at(info-value-font, default: "宋体"),
    size: 字号.小三,
    key,
    body,
  ) = {
    grid.cell(colspan: 3,
      info-value(
        font: font,
        size: size,
        key,
        body,
      )
    )
  }

  let info-short-value(
    font: 字体.at(info-value-font, default: "宋体"),
    size: 字号.小三,
    key,
    body
  ) = {
    info-value(
      font: font,
      size: size,
      key,
      body,
    )
  }

  // 正式渲染
  // 居中对齐
  set align(center)

  // 封面校徽
  // 使用校方官方 VI 系统的 logo，来源：https://home3.sysu.edu.cn/sysuvi/index.html
  image("/assets/vi/sysu_logo.svg", width: 3cm)

  text(size: 字号.小初, font: 字体.宋体, weight: "bold", fill: sysucolor.green)[本科生毕业论文（设计）]
  v(-2em)
  line(length: 200%, stroke: 0.12cm + sysucolor.green);
  v(-0.8em)
  line(length: 200%, stroke: 0.05cm + sysucolor.green);
  v(1.5cm)

  // 论文题目
  h(0.7cm)
  block(width: 100%, grid(
    columns: (25%, 1fr, 75%, 1fr),
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    info-key(size: 字号.二号, "题目："),
    ..info.title.map((s) =>
      info-long-value(size: 字号.二号, font: 字体.黑体, "title", s)
    ).intersperse(info-key(size: 字号.二号, "　")),
  ))
  v(2.7cm)

  // 学生与指导老师信息
  set align(center + bottom)
  block(width: 75%, grid(
    columns: (info-key-width, 1fr, info-key-width, 1fr),
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    info-key("姓　　名"),
    info-long-value("author", info.author.name),
    info-key("学　　号"),
    info-long-value("student-id", info.author.sno),
    info-key("院　　系"),
    info-long-value("department", info.author.department),
    info-key("专　　业"),
    info-long-value("major", info.author.major),
    info-key("指导教师"),
    info-long-value("supervisor", info.supervisor.join(" ")),
  ))
  v(2em)

  text(font: 字体.黑体, size: 字号.小四)[#info.submit-date]
}
