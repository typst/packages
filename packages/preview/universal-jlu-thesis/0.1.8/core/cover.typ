#import "fonts.typ": *

// 标题下划线函数
#let title-underline(width: 310pt) = {
  line(length: width, stroke: 0.5pt)
}

// 修复后的多行标题处理函数 - 支持1-2行自适应
#let title-with-lines(content, max-width: 310pt, font-size: 16pt, font-family: fonts.song) = {
  // 创建带下划线的容器
  stack(
    spacing: 0pt,
    // 文本内容 - 动态高度，但最小为2行
    box(
      width: max-width,
      height: 2.8em, // 设置为稍大的固定高度以容纳2行
      [
        #set align(center + top) // 改为顶部对齐，避免单行时居中到中间
        #set text(size: font-size, weight: "bold", font: font-family)
        #set par(leading: 1em) // 设置行间距
        #content
      ]
    ),
    // 下划线位置调整
    v(-1.4em),
    // 固定显示2条下划线
    stack(
      spacing: 2.5em,
      title-underline(width: max-width),
      title-underline(width: max-width)
    )
  )
}

// 信息行函数
#let info-line(label, content, width: 11cm) = {
  grid(
    columns: (auto, width),
    column-gutter: 0em,
    align: (left, center),
    gutter: 0pt,
    [#text(size: 16pt, weight: "bold", font: fonts.song)[#label]],
    stack(
      spacing: 0pt,
      // 文本
      box(
        width: width,
        height: 1.2em,
        [
          #set align(center + horizon)
          #set text(size: 16pt, weight: "bold", font: fonts.song)
          #content
          #v(0.1em)
        ]
      ),
      // 下划线位置调整
      v(0.1em),
      title-underline(width: width)
    )
  )
}

// 多字段单行函数 - 用于学生姓名班级学号和指导教师职称
#let multi-field-line(fields) = {
  context {
    // 固定总宽度与 info-line 一致
    let total-width = 13.2cm
    // 为每个标签分配足够宽度，避免中文被挤成竖排
    let label-widths = fields.map(f => {
      measure(text(size: 16pt, weight: "bold", font: fonts.song)[#f.label]).width + 0.2em
    })
    let labels-total-width = label-widths.fold(0pt, (a, b) => a + b)

    // 内容区优先使用传入宽度，保证 width 参数生效
    let available-content-width = total-width - labels-total-width
    let requested-content-widths = fields.map(f => f.width)
    let requested-content-widths-sum = requested-content-widths.fold(0pt, (a, b) => a + b)
    let width-delta = available-content-width - requested-content-widths-sum
    let content-widths = if fields.len() > 0 {
      // 保持前面字段宽度不变，把总宽度误差吸收到最后一个字段
      range(0, fields.len()).map(i => {
        if i == fields.len() - 1 {
          requested-content-widths.at(i) + width-delta
        } else {
          requested-content-widths.at(i)
        }
      })
    } else {
      ()
    }
    
    stack(
      spacing: 0pt,
      // 内容行
      box(
        width: total-width,
        [
          #set text(size: 16pt, weight: "bold", font: fonts.song)
          #grid(
            columns: range(0, fields.len()).map(i => (label-widths.at(i), content-widths.at(i))).flatten(),
            column-gutter: 0pt,
            row-gutter: 0pt,
            align: (left, center),
            ..range(0, fields.len()).map(i => {
              let f = fields.at(i)
              (
                box(
                  width: label-widths.at(i),
                  height: 1.2em,
                  [
                    #set align(left + horizon)
                    #f.label
                  ]
                ),
                box(
                  width: content-widths.at(i),
                  height: 1.2em,
                  [
                    #set align(center + horizon)
                    #f.content
                    #v(0.1em)
                  ]
                )
              )
            }).flatten()
          )
        ]
      ),
      // 下划线行
      v(0.1em),
      box(
        width: total-width,
        grid(
          columns: range(0, fields.len()).map(i => (label-widths.at(i), content-widths.at(i))).flatten(),
          column-gutter: 0pt,
          row-gutter: 0pt,
          ..range(0, fields.len()).map(i => {
            (
              [],
              title-underline(width: content-widths.at(i))
            )
          }).flatten()
        )
      )
    )
  }
}

// 封面制作函数 - 压缩间距版本
#let make-cover(
  ctitle: "",
  etitle: "", 
  author: "",
  class: "",
  student-id: "",
  school: "",
  major: "",
  mentor: "",
  mentor-title: "",
  date: auto
) = {
  // 处理日期格式
  let display-date = if date == auto {
    let now = datetime.today()
    str(now.year()) + "年" + str(now.month()) + "月"
  } else if type(date) == datetime {
    str(date.year()) + "年" + str(date.month()) + "月"
  } else {
    str(date)
  }
  
  page(margin: (top: 30pt, bottom: 30pt, left: 30pt, right: 30pt))[
    #set align(center)
    #v(44pt)
    
    // 校徽 - 缩小尺寸
    #image("../assets/images/logo.png", width: 67.5%)
    #v(18pt)
    
    // 标题
    #text(size: 36pt, weight: "bold", font: fonts.song)[本科生毕业论文（设计）]
    #v(48pt)
    
    // 中英文题目表格 - 调整为无间距的网格布局
    #grid(
      columns: (auto, 310pt),
      column-gutter: 0pt, // 移除列间距
      row-gutter: 15pt,
      align: (left, center),
      
      // 中文题目行
      [#text(size: 16pt, weight: "bold", font: fonts.song)[中文题目]],
      title-with-lines(ctitle, font-size: 16pt, font-family: fonts.song),
      
      // 英文题目行  
      [#text(size: 16pt, weight: "bold", font: fonts.song)[英文题目]],
      title-with-lines(etitle, font-size: 16pt, font-family: fonts.main),
    )
    
    #v(80pt)
    
    // 学生信息 - 压缩间距
    #stack(
      spacing: 17.5pt,
      // 第一行：学生姓名、班级、学号
      multi-field-line((
        (label: [学生姓名], content: author, width: 4.4cm),
        (label: [班级], content: class, width: 1.2cm),
        (label: [学号], content: student-id, width: 4.0cm),
      )),
      info-line([学#h(2em)院], school),
      info-line([专#h(2em)业], major),
      // 最后一行：指导教师、职称
      multi-field-line((
        (label: [指导教师], content: mentor, width: 4.8cm),
        (label: [职称], content: mentor-title, width: 4.8cm),
      )),
    )
    
    #v(60pt)
    #text(size: 16pt, weight: "bold", font: fonts.song)[#display-date]
    #v(1fr)
  ]
}