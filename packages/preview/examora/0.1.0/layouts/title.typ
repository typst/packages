#let title(
  info: (:),
  font: ("Times New Roman", "KaiTi"),
  font-size: 1.5em,
  type: "A卷",
  method: "闭卷",
  title-underline: true,
  info-size: 0.85em,
) = context {
  let info = (
    (
      school: "布鲁斯特大学",
      date: datetime.today(),
      time: [],
      duration: [120 分钟],
      subject: "高等数学",
      class: "",
      major: "",
      columns: -1,
    )
      + info
  )

  align(right)[考试方式：#underline(method)]

  text(font: font, size: font-size, weight: "bold")[
    #align(center)[
      #info.school #if title-underline {underline(info.subject + type)} else {info.subject + type} 试卷
    ]]

  set text(size: info-size)

  let fields = ()
  if info.major != "" {
    fields.push([适用专业：#underline(info.major)])
  }
  if info.class != "" {
    fields.push([适用班级：#underline(info.class)])
  }
  fields.push([考试日期：#underline(info.date.display() + if info.time == "" { "" } else { " " + info.time })])
  fields.push([时间：#underline(info.duration + " 共" + [#counter(page).final().first()] + "页")])

  if info.columns > 0 {
    grid(
      columns: (1fr,) * info.columns,
      align: left,
      inset: 0.4em,
      ..fields
    )
  } else {
    align(center)[
      #set par(justify: true)
      #for ct in fields {
        [#box[#ct] #h(5pt)]
      }
    ]
  }
}
