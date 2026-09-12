/// Cover page for WHU course design report. 武汉大学课程设计报告封面页。
///
/// - school (str): College/department name / 学校学院
/// - category (str): Report category title / 报告类别
/// - title (str): Specific report title / 报告名称
/// - major (str): Major name / 专业名称
/// - course-name (str): Course name / 课程名称
/// - instructor (str): Instructor name / 指导教师
/// - student-id (str): Student ID / 学号
/// - student-name (str): Student name / 学生姓名
/// - semester (str): Academic semester / 学期
/// - deadline (str): Report deadline / 报告截止日期
/// - grade (bool): Report grade / 报告成绩
/// - date (str): Report date (e.g., "二○二六年五月") / 报告日期
/// -> content

#let SimHei = ("SimHei", "Source Han Sans", "Heiti SC")
#let SimSun = ("SimSun", "Noto Serif CJK SC", "Songti SC")

/// reset the height of the signature image to 2em, 
/// so that it fits the declaration page nicely.
#let zipper(img) = {
  block({
    show image: set image(height: 2.2em)
    img
  })
}

#let cover(
  school: "武汉大学计算机学院",
  category: "本科生课程设计报告",
  title: none,
  major: none,
  course-name: none,
  instructor: none,
  student-id: none,
  student-name: none,
  semester: none,
  deadline: none,
  grade: false,
  date: none,
) = {
  align(center)[
    #v(2em)
    #block[
      #set align(center)
      #set text(top-edge: "ascender", bottom-edge: "descender")
      
      #set par(leading: 0.7em)
      #text(font: SimSun, size: 26pt, weight: "bold")[#school\ #category]
    ]
    #v(5em)

    #if title != none {
        block({
          set par(leading: 32pt-1em)
          text(top-edge: 0.7em, bottom-edge: -0.3em, size: 22pt, weight: "bold", font: SimHei)[#title]
        })
      v(32pt)
    }

    #v(5em)

    #let info = (:)
    #if major != none { info.insert("专 业 名 称", major) }
    #if course-name != none { info.insert("课 程 名 称", course-name) }
    #if instructor != none { info.insert("指 导 教 师", instructor) }
    #if student-id != none { info.insert("学 生 学 号", student-id) }
    #if student-name != none { info.insert("学 生 姓 名", student-name) }
    #if semester != none { info.insert("学 年 学 期", semester) }
    #if deadline != none { info.insert("完 成 时 间", deadline) }
    #if grade == true { info.insert("成     绩 ", "_____________") }
    #grid(
      columns: (auto, auto),
      row-gutter: 1.5em,
      column-gutter: 1em,
      align: (right + horizon, left + horizon), 
      ..info.pairs().map(((label, value)) => (
        text(size: 15pt, font: SimSun)[#label :],
        text(size: 15pt, font: SimSun)[#value],
      )).flatten()
    )

    #v(1fr)
    #if date != none {
      text(size: 18pt, font: SimSun)[#date]
    }
    #v(2em)
  ]
}

/// Declaration of originality page. 原创性声明页。
///
/// - signature (image): Signature image / 签名图片
/// - date (str): Signature date / 签名日期
/// - decl-body (content): Custom declaration text / 自定义声明文本
/// -> content
#let declaration-page(
  date: none,
  decl-body: none,
  signature: none,
) = {
  align(center)[
    #v(2em)
    #text(size: 22pt, weight: "bold", font: SimSun)[郑 重 声 明]
    #v(2em)
  ]

  if decl-body != none {
    par(sjustify: true, first-line-indent: 2em, text(size: 14pt, font: SimSun)[#decl-body])
  } else {
    par(justify: true, first-line-indent: 2em, leading: 23pt-1em)[
      #text(top-edge: 0.7em, bottom-edge: -0.3em, size: 14pt, font: SimSun)[本人呈交的设计报告，是在指导老师的指导下，独立进行实验工作所取得的成果，所有数据、图片资料真实可靠。尽我所知，除文中已经注明引用的内容外，本设计报告不包含他人享有著作权的内容。对本设计报告做出贡献的其他个人和集体，均已在文中以明确的方式标明。本设计报告的知识产权归属于培养单位。
      ]
    ]
  }

  v(4em)
  align(right)[
    #if signature != none {
      text(size: 14pt, font: SimSun)[本人签名：#underline(box(
      baseline: 20%,
      zipper(signature),
      ))]
    } else {
      text(size: 14pt, font: SimSun)[本人签名：\_\_\_\_\_\_\_\_\_\_\_\_]
    }
    #h(4em)
    #if date != none {
      text(size: 14pt, font: SimSun)[日期：#date]
    } else {
      text(size: 14pt, font: SimSun)[日期：\_\_\_\_年\_\_\_\_月\_\_\_\_日]
    }
    #h(4em)
  ]
}
