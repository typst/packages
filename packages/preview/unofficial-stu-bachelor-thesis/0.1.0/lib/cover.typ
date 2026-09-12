#import "font_config.typ": *

/************论文封面************/

#let bachelor-cover(
  info: (:
    // title:
    // college:
    // department:
    // gradeandmajor:
    // author:
    // student-id:
    // supervisor:
    // submit-date:
  ), //传入参数
) = {
  /** 定义封面中的各信息的默认值，如果用户设置了则用设置值覆盖 **/
  //处理文章题目是多行的情况
  // 2.1 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    let title-clusters = info.title.clusters()
    let title-splited = (
      title-clusters.slice(0, int(title-clusters.len() / 2)),
      title-clusters.slice(int(title-clusters.len() / 2)),
    )
    info.title = (
      strong(title-splited.first().sum()),
      strong(title-splited.last().sum()),
    )
  }

  /** 定义渲染所需函数 **/
  //封面标题信息
  let info-key(body) = {
    rect(
      // 矩形容器
      width: 100%, // 占满父容器宽度
      inset: (x: 0pt, bottom: 22pt), // 内边距引用全局变量
      stroke: none, // 无边框线
      text(
        // 文本内容
        size: 三号, // 三号字（约16pt）
        body, // 接收的文本内容
      ),
    )
  }

  let info-value(key, body) = {
    set align(center)
    rect(
      width: 100%,
      inset: (x: 0pt, bottom: 1pt), // 左右无内边距，底部内边距为0pt
      stroke: (bottom: 0.5pt + black), // 底部边框：0.5pt黑色实线（常用于分隔线）
      text(
        size: 三号,
        bottom-edge: "descender", // 文本基线对齐（避免字符下沉导致的间距不均）
        body,
      ),
    )
  }

  let info-value-noline(body) = {
    set align(center)
    rect(
      width: 100%,
      inset: (x: 0pt, bottom: 0pt), // 左右无内边距，底部内边距为0pt
      stroke: none, // 无边框线
      text(
        size: 三号,
        bottom-edge: "descender", // 文本基线对齐（避免字符下沉导致的间距不均）
        body,
      ),
    )
  }

  let info-long-value(key, body) = {
    grid.cell(
      colspan: 3, // 横向合并3列（适配多列布局需求）
      info-value(key, body), // 嵌套调用 info-value 函数
    )
  }

  /** 正式渲染 **/
  //页面设置
  set page(margin: (top: 2.54cm, right: 3.17cm, bottom: 2.54cm, left: 3.17cm))
  set align(center)
  set text(font: 宋体, lang: "zh")

  //中文伪加粗
  show: cn-fake-bold

  //居左的logo
  align(left, info.stu_logo)

  //输入一个空行，大小为四号字体
  v(四号)

  //使用宋体一号字体居中写“毕业论文（设计）”
  text(size: 一号)[*毕业论文（设计）*]

  //输入四个空行，大小为五号字体
  v(4 * 五号)

  //columns参数定义了四列，分别是72pt、1fr、72pt、1fr，这意味着前两列和后两列分别占据固定宽度和剩余空间。column-gutter和row-gutter调整列间和行间的间距。
  block(width: info.cover-width, grid(
    columns: (5 * 三号, 1fr, 5 * 三号, 1fr),
    //调整列间距
    row-gutter: 五号,
    info-key("题　　目："),
    //这里使用展开符将文章题目的多行逐行进行处理，在每行之间使用info-keyhanshu添加一个分隔符
    ..info
      .title
      .map(s => info-long-value("title", s))
      .intersperse(info-key("　")),

    info-key("学　　院："),
    info-long-value("学院", info.college),

    info-key("系　　别："),
    info-long-value("系别", info.department),

    info-key("专业年级："),
    info-long-value("专业年级", info.gradeandmajor),

    info-key("学生姓名："),
    info-long-value("学生姓名", info.author),

    info-key("学　　号："),
    info-long-value("学号", info.student-id),

    info-key("指导老师："),
    info-long-value("指导老师", info.supervisor),
  ))

  v(五号 + 小四)
  info-value-noline(
    "完成时间：" + info.submit-date.display("[year]年[month padding:none]月"),
  )

  // 结束，下一页
  pagebreak()
}
