#import "../utils/datetime-display.typ": datetime-display
#import "../utils/style.typ": 字号, 字体
#import "../utils/custom-cuti.typ": fakebold
#import "../utils/indent.typ": fake-par,indent

// 本科生封面
#let bachelor-cover(
  // documentclass 传入的参数
  anonymous: false,
  twoside: false,
  fonts: (:),
  info: (:),
  // 其他参数
  stoke-width: 0.5pt,
  min-title-lines: 2,
  info-inset: (x: 0pt, bottom: 1pt),
  info-key-width: 72pt,
  info-key-font: "黑体",
  info-value-font: "楷体",
  column-gutter: 22pt,
  row-gutter: 11.5pt,
  anonymous-info-keys: ("grade", "student-id", "author", "supervisor", "supervisor-ii"),
  bold-info-keys: ("title",),
  bold-level: "bold",
  datetime-display: datetime-display,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  info = (
    title: ("基于 Typst 的", "南京大学学位论文"),
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
  let info-key(body) = {
    // rect(
    //   width: 100%,
    //   inset: info-inset,
    //   stroke: none,
      text(
        font: fonts.at(info-key-font, default: "黑体"),
        size: 字号.小二,
        body
      )
    // )
  }

  let info-value(key, body) = {
    // set align(left)
    // rect(
    //   width: 100%,
    //   inset: info-inset,
    //   stroke: none,
      text(
        font: fonts.at(info-value-font, default: "楷体"),
        size: 字号.小二,
        weight: if (key in bold-info-keys) { bold-level } else { "regular" },
        bottom-edge: "descender",
        body,
      )
    // )
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
  

  // 4.  正式渲染
  pagebreak(weak:true,to:"odd" ) 
  // 居中对齐
  set align(center)
  image("../assets/vi/ysulogo.png", height: 1.86cm,width: 6.33cm )
  v(40pt) 
  fakebold(text(size: 字号.小初, font: fonts.黑体)[本科生毕业设计（论文）])
  v(32pt*2)
  set align(left)
  // set par(leading: 2em, justify:true )
  indent
  text(size: 字号.小二, font: fonts.黑体, "论文题目")
  h(column-gutter)
  text(size: 字号.小二, font: fonts.楷体, weight: "regular", info.title.at(0))
  v(22.35pt*5*1.25 )
  // grid(
  //   columns: (info-key-width,340pt),
  //   column-gutter: column-gutter,
  //   row-gutter: row-gutter,
  //   info-key("作者姓名"),
  //   info-long-value("author", info.author),
  //   info-key("专　　业"),
  //   info-long-value("major", info.major),
  //   info-key("指导教师"),
  //   info-long-value("supervisor", info.supervisor.sum()),
  // )
  [
    #indent#info-key("作者姓名")
    #h(column-gutter)
    #info-long-value("author", info.author)
    #v(row-gutter)
    #indent #info-key("专　　业")
    #h(column-gutter)
    #info-long-value("major", info.major)
    #v(row-gutter)
    #indent #info-key("指导教师")
    #h(column-gutter)
    #info-long-value("supervisor", info.supervisor.sum())
  ]

  v(字号.小四*5)
  set align(center)
  text(font:字体.宋体,size:字号.小二,weight: "bold",info.submit-date)

}