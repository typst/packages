#import "fonts.typ": *

// 标题下划线函数
#let title-underline(width: 310pt) = {
  line(length: width, stroke: 0.5pt)
}

// 修复后的多行标题处理函数 - 支持1-2行自适应
#let title-with-lines(content, max-width: 310pt, font-size: 16pt) = {
  // 创建带下划线的容器
  stack(
    spacing: 0pt,
    // 文本内容 - 动态高度，但最小为2行
    box(
      width: max-width,
      height: 2.8em, // 设置为稍大的固定高度以容纳2行
      [
        #set align(center + top) // 改为顶部对齐，避免单行时居中到中间
        #set text(size: font-size, weight: "bold", font: fonts.song)
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

// 封面制作函数 - 压缩间距版本
#let make-cover(
  ctitle: "",
  etitle: "", 
  author: "",
  student-id: "",
  school: "",
  major: "",
  mentor: "",
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
      title-with-lines(ctitle, font-size: 16pt),
      
      // 英文题目行  
      [#text(size: 16pt, weight: "bold", font: fonts.song)[英文题目]],
      title-with-lines(etitle, font-size: 16pt),
    )
    
    #v(80pt)
    
    // 学生信息 - 压缩间距
    #stack(
      spacing: 17.5pt,
      info-line([学生姓名], author),
      info-line([学#h(2em)号], student-id),
      info-line([学#h(2em)院], school),
      info-line([专#h(2em)业], major),
      info-line([指导教师], mentor),
    )
    
    #v(60pt)
    #text(size: 16pt, weight: "bold", font: fonts.song)[#display-date]
    #v(1fr)
  ]
}