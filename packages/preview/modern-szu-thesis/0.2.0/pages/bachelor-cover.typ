#import "../utils/datetime-display.typ": datetime-display
#import "../utils/style.typ": 字号, 字体
#import "../utils/custom-cuti.typ": show-cn-fakebold

// 本科生封面
#let bachelor-cover(
  // documentclass 传入的参数
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  stoke-width: 1pt,
  min-title-lines: 2,
  info-inset: (x: 0pt, bottom: 1pt),
  info-key-width: 72pt,
  info-key-font: "黑体",
  info-value-font: "楷体",
  column-gutter: 0pt,
  row-gutter: 11.5pt,
  anonymous-info-keys: ("grade", "student-id", "author", "supervisor", "supervisor-ii"),
  bold-info-keys: ("title","author", "major", "department", "student-id","supervisor" ),
  bold-info-value: ("title","author", "major", "department", "student-id","supervisor" ),
  bold-level: "bold",
  datetime-display: datetime-display,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "深圳大学学位论文"),
    grade: "20XX",
    student-id: "1234567890",
    author: "张三",
    department: "某学院",
    major: "某专业",
    supervisor: ("李四", "教授"),
    submit-date: datetime.today(),
  ) + info

  // 2.  对参数进行处理
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  // 2.2 根据 min-title-lines 填充标题
  info.title = info.title + range(min-title-lines - info.title.len()).map((it) => "　")
  // 2.3 处理提交日期
  if type(info.submit-date) == datetime {
    info.submit-date = datetime-display(info.submit-date)
  }

  // 3.  内置辅助函数
  let info-key(body,width:100%, stroke:none) = {
    if stroke == none {
      set align(left)
      grid.cell(
      rect(
        width: width,
        inset: info-inset,
        stroke: none,
        text(
          font: fonts.at(info-key-font, default: "黑体"),
          size: 字号.三号,
          body
        ),
      )
      )
    }
    else {
      set align(left)
      //让stroke和右侧的value连接上，
      v(1pt)
      rect(
        width: width,
        inset: info-inset,
        stroke: (bottom: stoke-width + black),
        text(
          font: fonts.at(info-key-font, default: "黑体"),
          size: 字号.三号,
          body
        ),
      )
    }

    }

  let info-value(key, body, width:100%) = {
    set align(center)
    rect(
      width: width,
      inset: info-inset,
      stroke: (bottom: stoke-width + black,),
      text(
        font: fonts.at(info-value-font, default: "宋体"),
        size: 字号.三号,
        weight: if (key in bold-info-keys) { bold-level } else { "regular" },
        bottom-edge: "descender",
        body,
      ),
    )
  }

  let info-long-value(key, body,width:100%,colspan:1) = {
    grid.cell(colspan: colspan,
      info-value(
        key,
        if anonymous and (key in anonymous-info-keys) {
          "██████████"
        } else {
            if (key in bold-info-value){
            text(show-cn-fakebold(body))  
            }
            else {
              body
            }
        },width:width,
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
  

  // 4.  正式渲染
  
  pagebreak(weak: true, to: if twoside { "odd" })

  // 居中对齐
  set align(center)

  // 匿名化处理去掉封面标识
  if anonymous {
    v(52pt)
  } else {
    // 封面图标
    v(6pt)
    //image("../assets/vi/nju-emblem.svg", width: 2.38cm)
    v(22pt)
    // 调整一下左边的间距
    pad(image("../assets/vi/szu.svg", width: 200pt), left: 0.4cm)
    v(-5pt)
  }

  // 将中文之间的空格间隙从 0.25 em 调整到 0.5 em
  text(size: 字号.小一, font: fonts.黑体, spacing: 200%,)[本 科 毕 业 论 文 (设计) ]
  
  if anonymous {
    v(155pt)
  } else {
    v(67pt)
  }

  block(width: 318pt, grid(
    columns: (info-key-width, 1fr),
    column-gutter: column-gutter,
    row-gutter: row-gutter,
    info-key("题目："),
    info-long-value("title", info.title.at(0), width: 112%),
    info-long-value("title",info.title.at(1),colspan: 2,width: 105%),
    info-key("姓名："),
    info-long-value("author", info.author, width: 112%),
    info-key("专业："),
    info-long-value("major", info.major, width: 112%),
    info-key("学院："),
    info-long-value("department", info.department, width: 112%),
    info-key("学号："),
    info-long-value("student-id", info.student-id, width: 112%),
    info-key("指导教师："),
    info-long-value("supervisor", info.supervisor.at(0)),
    info-key("职称："),
    info-long-value("supervisor", info.supervisor.at(1), width: 110%),
    // ..(if info.supervisor-ii != () {(
    //   info-key("第二导师"),
    //   info-short-value("supervisor-ii", info.supervisor-ii.at(0)),
    //   info-key("职　　称"),
    //   info-short-value("supervisor-ii", info.supervisor-ii.at(1)),
    // )} else {()}),
    // info-key("提交日期"),
    // info-long-value("submit-date", info.submit-date),
  ))

  v(6cm)
  set text(size: 16pt)
  info.submit-date
}

