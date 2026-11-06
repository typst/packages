#import "../../utils/indent.typ": indent
#import "../../utils/style.typ": 字号, 字体

// 学术声明页
#let postgraduate-declaration(
  anonymous: false,
  twoside: false,
  info: (:),
) = {
  // 如果需要匿名则短路返回
  if anonymous {
    return
  }

  // 适应标题过长
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }

  // 1. 原创性声明
  v(字号.五号 * 2)
  align(
    center,
    text(
      font: 字体.黑体,
      size: 字号.三号,
      weight: "bold",
      "中国地质大学（武汉）研究生学位论文原创性声明",
    ),
  )
  v(字号.五号 * 3.0)

  set text(font: 字体.宋体, size: 字号.四号)
  let title = info.at("title").join("")
  let doctype = {
    if (info.at("doctype") == "master") {
      "硕士"
    } else {
      "博士"
    }
  }
  par(justify: true, first-line-indent: 2em, leading: 字号.四号*2)[
    本人郑重声明：本人所呈交的#doctype;学位论文《#title;》，是本人在导师的指导下，在中国地质大学（武汉）攻读#doctype;学位期间独立进行研究工作所取得的成果。论文中除已注明部分外不包含他人已发表或撰写过的研究成果，对论文的完成提供过帮助的有关人员已在文中说明并致以谢意。\
    #v(1em)
    本人所呈交的#doctype;学位论文没有违反学术道德和学术规范，没有侵权行为，并愿意承担由此而产生的法律责任和法律后果。
  ]

  v(3.9em)

  align(right + top,
    box(
      grid(
        align: (left, right, right),
        columns: (auto, auto, 5.6em),
        column-gutter: (0.5em),
        gutter: 2em,
        grid.cell("学位论文作者签名：", colspan: 2), grid.cell("", stroke: (bottom: 0.5pt + black)),
        "日" + h(2em) + "期：", grid.cell(text("年") + h(2em) + text("月") + h(2em) + text("日"), colspan:2),
      )
    )
  )

  pagebreak(weak: true, to: if twoside { "odd" })
  
  // 2. 导师承诺书
  v(字号.五号 * 2)
  align(
    center,
    text(
      font: 字体.黑体,
      size: 字号.三号,
      weight: "bold",
      "中国地质大学（武汉）研究生学位论文导师承诺书",
    ),
  )
  v(字号.五号 * 3.0)

  set text(font: 字体.宋体, size: 字号.四号)
  let title = info.at("title").join("")
  let doctype = {
    if (info.at("doctype") == "master") {
      "硕士"
    } else {
      "博士"
    }
  }
  par(justify: true, first-line-indent: 2em, leading: 字号.四号*2)[
    本人郑重声明：本人所指导的#doctype;学位论文《#title;》，是在本人的指导下，研究生在中国地质大学（武汉）攻读#doctype;学位期间独立进行研究工作所取得的成果，论文由研究生独立完成。\
    #v(1em)
    研究生所呈交的#doctype;学位论文没有违反学术道德和学术规范，没有侵权行为，并愿意承担由此而产生的与导师相关的责任和后果。
  ]

  v(3.9em)

  align(right + top,
    box(
      grid(
        align: (left, right, right),
        columns: (auto, auto, 5.6em),
        column-gutter: (0.5em),
        gutter: 2em,
        grid.cell("指导教师（签字）：", colspan: 2), grid.cell("", stroke: (bottom: 0.5pt + black)),
        "日" + h(2em) + "期：", grid.cell(text("年") + h(2em) + text("月") + h(2em) + text("日"), colspan:2),
      )
    )
  )
  pagebreak(weak: true, to: if twoside { "odd" })
  // 3. 使用授权书 
  v(字号.五号 * 2)
  align(
    center,
    text(
      font: 字体.黑体,
      size: 字号.三号,
      weight: "bold",
      "中国地质大学（武汉）学位论文使用授权书",
    ),
  )
  v(字号.五号 * 3.0)

  set text(font: 字体.宋体, size: 字号.四号)
  let title = info.at("title").join("")
  let doctype = {
    if (info.at("doctype") == "master") {
      "硕士"
    } else {
      "博士"
    }
  }
  par(justify: true, first-line-indent: 2em, leading: 字号.四号*2)[
    本人授权中国地质大学（武汉）可采用影印、缩印、数字化或其它复制手段保存本学位论文；学校可向国家有关部门或机构送交本学位论文的电子版全文，编入有关数据库进行检索、下载及文献传递服务；同意在校园网内提供全文浏览和下载服务。\
    #v(1em)
    涉密论文解密后适用于本授权书。
  ]

  v(3.9em)

  align(right + top,
    box(
      grid(
        align: (left, right, right),
        columns: (auto, auto, 5.6em),
        column-gutter: (0.5em),
        gutter: 2em,
        grid.cell("学位论文作者签名：", colspan: 2), grid.cell("", stroke: (bottom: 0.5pt + black)),
        "日" + h(2em) + "期：", grid.cell(text("年") + h(2em) + text("月") + h(2em) + text("日"), colspan:2),
      )
    )
  )
  pagebreak(weak: true, to: if twoside { "odd" })
}

// 测试代码
// #import "../../mythesis/test-text.typ": mainmatter-parms
// #show: postgraduate-declaration(info: mainmatter-parms.info)