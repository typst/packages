#import "../utils/datetime-display.typ": datetime-display
#import "../utils/style.typ": 字号, 字体
#import "../utils/custom-cuti.typ" : fakebold

#let bachelor-detail(
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  stoke-width: 0.5pt,
  min-title-lines: 2,
  info-inset: (x: 0pt, bottom: 1pt),
  info-key-width: 100pt,
  info-key-font: "黑体",
  info-value-font: "宋体",
  column-gutter: 0pt,
  row-gutter: 11.5pt,
  anonymous-info-keys: ("grade", "student-id", "author", "supervisor", "supervisor-ii"),
  bold-info-keys: ("title",),
  bold-level: "bold",
  datetime-display: datetime-display,
  ) = {
  if type(info.submit-date) == datetime {
    info.submit-date = datetime-display(info.submit-date)
  }
  let info-key(body) = {
    set align(center)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      text(
        font: fonts.at(info-key-font, default: "黑体"),
        size: 字号.四号,
        body
      ),
    )
  }

  let info-value(key, body) = {
    set align(left)
    rect(
      width: 100%,
      inset: info-inset,
      stroke: none,
      text(
        font: fonts.at(info-value-font, default: "宋体"),
        size: 字号.四号,
        weight: if (key in bold-info-keys) { bold-level } else { "regular" },
        bottom-edge: "descender",
        body,
      ),
    )
  }

  let info-long-value(key, body) = {
    grid.cell(colspan: 1,
      info-value(
        key,
        if anonymous and (key in anonymous-info-keys) {
          "██████████"
        } else {
          body
        }
      )
    )
  }

  let info-short-value(key, body) = {
    info-value(
      key,
      if anonymous and (key in anonymous-info-keys) {
        "█████"
      } else {
        body
      }
    )
  }
  
  pagebreak(weak: true,to:"odd")
  v(字号.小四*4)
  set align(center)
  fakebold(text(font:fonts.宋体,size:字号.小二,weight:"bold")[燕山大学本科生毕业设计（论文）])
  v(字号.小二*2)
  text(font:fonts.黑体,size:字号.二号,info.title)
  v(字号.小二*12)
  block(width: auto,grid(
    columns: (3.03cm+0.75cm ,5.75cm),
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    // stroke: stoke-width,
    info-key("学　         　院："),
    info-long-value("department", info.department),
    info-key("专　         　业："),
    info-long-value("major", info.major),
    info-key("姓　         　名："),
    info-long-value("author", info.author),
    info-key("学　         　号："),
    info-long-value("student-id", info.student-id),
    info-key("指   导   教   师："),
    info-long-value("supervisor", info.supervisor.at(0)),
    info-key("答   辩   日   期："),
    info-long-value("submit-date", info.submit-date),
  ))
  pagebreak(weak:false,to:"even")
}