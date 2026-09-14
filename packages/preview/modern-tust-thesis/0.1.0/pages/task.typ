#import "../utils/style.typ": zihao, ziti
#import "../utils/uline.typ": uline, uline-center

#let task-page(
  info: (:),
  twoside: false,
  body: none,
  start-date: none,
  end-date: none,
  sign-date: none,
) = {
  let school = info.at("school", default: "人工智能")
  let major = info.at("major", default: "专业")
  let student-id = info.at("student-id", default: "学号")
  let name = info.at("name", default: "姓名")
  let supervisor = info.at("supervisor", default: "指导教师")
  let title = info.at("title", default: "论文题目")

  pagebreak()
  set page(
    header: none,
    footer: none,
    margin: (top: 25mm, bottom: 30mm, left: 25mm, right: 20mm),
    header-ascent: 7.5mm,
    footer-descent: 17mm,
  )
  set text(font: ziti.fangsong, size: zihao.xiaosi)
  set par(leading: 18pt, first-line-indent: 0em)

  align(center, {
    text(font: ziti.heiti, size: zihao.sanhao, weight: "bold")[天津科技大学本科毕业设计（论文）任务书]
  })

  v(12pt)
  align(center, {
    uline-center(3cm)[#school] + [学院] + uline-center(3cm)[#major] + [专业]
    v(6pt)
    [学生学号：] + uline-center(2cm)[#student-id] + [学生姓名：] + uline-center(2.5cm)[#name] + [指导教师姓名：] + uline-center(2.5cm)[#supervisor]
    v(6pt)
    if start-date != none and end-date != none {
      [完成期限：] + uline-center(1.5cm)[#start-date.year] + [年] + uline-center(1.5cm)[#start-date.month] + [月] + uline-center(1.5cm)[#start-date.day] + [日至]
      uline-center(1.5cm)[#end-date.year] + [年] + uline-center(1.5cm)[#end-date.month] + [月] + uline-center(1.5cm)[#end-date.day] + [日]
    } else {
      [完成期限：] + uline-center(1.5cm)[#h(1cm)] + [年] + uline-center(1.5cm)[#h(0.5cm)] + [月] + uline-center(1.5cm)[#h(0.5cm)] + [日至]
      uline-center(1.5cm)[#h(1cm)] + [年] + uline-center(1.5cm)[#h(0.5cm)] + [月] + uline-center(1.5cm)[#h(0.5cm)] + [日]
    }
  })

  v(12pt)
  [一、题目名称：] + uline(10cm)[#title]
  v(12pt)
  [二、设计（论文）内容及要求：]
  v(6pt)
  
  // 任务书内容区域 - 模仿LaTeX UnderlineCentered
  if body != none {
    set text(font: ziti.fangsong, size: zihao.xiaosi)
    set par(leading: 12pt, first-line-indent: 2em, justify: false)
    
    // 固定行距（对应LaTeX的spacing{2}即2倍baselineskip）
    let line-spacing = 24pt  // 12pt字号 * 2 = 24pt行距
    
    // 使用layout和context来测量和绘制
    layout(size => context {
      // 先测量内容高度
      let measured = measure(
        block(width: size.width, body)
      )
      let content-height = measured.height
      
      // 计算需要多少条横线（不加1，精确匹配内容）
      let num-lines = calc.ceil(content-height / line-spacing)
      
      // 创建一个固定高度的容器
      block(
        width: 100%, 
        height: content-height,  // 限制高度为内容高度
        {
          // 绘制横线（用place放在后面作为背景）
          for i in range(num-lines) {
            place(
              top + left,
              dy: i * line-spacing + 20pt,  // 20pt是基线位置调整
              line(length: 100%, stroke: 0.5pt)
            )
          }
          
          // 内容放在最上层
          body
        }
      )
    })
  }

  v(12pt)
  align(right, {
    [指导教师签字：] + uline(4cm)[]
    v(6pt)
    if sign-date != none {
      [填写日期：] + uline(2cm)[#sign-date.year] + [年] + uline(1cm)[#sign-date.month] + [月] + uline(1cm)[#sign-date.day] + [日]
    } else {
      [填写日期：] + uline(2cm)[] + [年] + uline(1cm)[] + [月] + uline(1cm)[] + [日]
    }
  })
}
