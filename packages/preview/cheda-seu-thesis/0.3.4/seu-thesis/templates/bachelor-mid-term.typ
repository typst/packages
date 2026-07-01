#import "@preview/cuti:0.3.0"
#import "../utils/fonts.typ": 字体, 字号

#let bachelor-mid-term-conf(
  student-id: none,
  name: none,
  school: none,
  major: none,
  title: none,
  progress: none,
  completed-work: none,
  next-steps: none,
  issues-and-solution: none,
  weekly-meetings: none,
  guidance-quality: 1,
) = {
  assert(type(guidance-quality) == int and guidance-quality <= 4 and guidance-quality >= 1, message: "教师指导类型需要为1~4的整数，越小表示指导越有力")

  set par(first-line-indent: 0pt, hanging-indent: 0pt, justify: false)
  set page(margin: (x: 3.17cm, y: 2.54cm))
  set text(font: 字体.宋体, size: 字号.五号, lang: "zh", region: "cn")
  set align(center)

  let no-space = context v(-par.spacing)
  let checkbox(a, b) = {
    assert(type(a) == int and type(b) == int)
    if(a == b) {
      box(image("../assets/icon/Checked.svg"))
    } else {
      box(image("../assets/icon/Box.svg"))
    }
  }

  text(font: 字体.黑体, size: 字号.四号, "东南大学毕业设计（论文）中期检查表")
  v(-8pt)
  text(font: 字体.宋体, size: 字号.小四, "（学生用表）")

  set table(stroke: 0.5pt)

  {
    set align(left)
    set par(spacing: 0.6em)
    table(
      rows: (0.8cm, ),
      columns: (2.24cm, 5.45cm, 2.3cm, 5.44cm),
      // 原始表格的右侧就是溢出的，所以这里也设置成溢出的
      align: (center + horizon, left + horizon),
      [学号], [#student-id], [姓名], [#name],
      [学院], [#school], [专业], [#major],
      [课题名称], table.cell(colspan: 3, align: center)[#title]
    )

    no-space

    table(
      columns: (5.08cm, 10.35cm),
      align: (center + horizon, left + top),
      inset: 7.8pt,
      [毕业设计（论文）进展], [#progress]
    )

    no-space

    table(
      columns: 15.43cm,
      {
        [
          1、现阶段已完成的工作 #linebreak()
          #completed-work
        ]
      },
      {
        [
          2、下一步工作计划 #linebreak()
          #next-steps
        ]
      },
      {
        [
          3、存在的问题及解决方法 #linebreak()
          #issues-and-solution
        ]
      },
      {
        [
          4、平均每周与指导教师沟通或见面次数（或时长） #linebreak()
          #weekly-meetings
        ]
      },
      {
        [
          5、在毕业设计开展的过程中，你是否得到了指导教师的有力指导？ #linebreak()
          #h(2em) #checkbox(1, guidance-quality) 得到有力的指导 #linebreak()
          #h(2em) #checkbox(2, guidance-quality) 得到一般性的指导 #linebreak()
          #h(2em) #checkbox(3, guidance-quality) 得到少许指导 #linebreak()
          #h(2em) #checkbox(4, guidance-quality) 没有得到指导 #linebreak()
        ]
      }
      
    )

    // no-space

    // 使用 block 的方案，需要 v(1fr) 换页
    // block(
    //   breakable: true,
    //   stroke: 0.5pt,
    //   inset: 5pt,
    //   width: 15.43cm,

    //   {
    //   }
    // )
  }
}

#bachelor-mid-term-conf()