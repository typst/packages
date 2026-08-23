/// Cover page for WHU course design report. 武汉大学课程设计报告封面页。
///
/// - course (str): College/department name / 学院名称
/// - title (str): Report category title / 报告类别
/// - subtitle (str): Specific report title / 报告标题
/// - instructor (str): Instructor name / 指导教师
/// - student-id (str): Student ID / 学号
/// - student-name (str): Student name / 学生姓名
/// - major (str): Major name / 专业名称
/// - course-name (str): Course name / 课程名称
/// - date (str): Report date (e.g., "二○二六年五月") / 报告日期
/// -> content
#let cover(
  course: "武汉大学计算机学院",
  title: "本科生课程设计报告",
  subtitle: none,
  instructor: none,
  student-id: none,
  student-name: none,
  major: none,
  course-name: none,
  date: none,
) = {
  align(center)[
    #v(2em)
    #text(size: 22pt, weight: "bold", font: "Heiti SC")[#course]
    #v(1em)
    #text(size: 26pt, weight: "bold", font: "Heiti SC")[#title]
    #v(4em)

    #if subtitle != none {
      text(size: 20pt, weight: "bold")[#subtitle]
      v(4em)
    }

    #v(4em)

    #let info = (:)
    #if major != none { info.insert("专  业  名  称", major) }
    #if course-name != none { info.insert("课  程  名  称", course-name) }
    #if instructor != none { info.insert("指  导  教  师", instructor) }
    #if student-id != none { info.insert("学  生  学  号", student-id) }
    #if student-name != none { info.insert("学  生  姓  名", student-name) }

    #grid(
      columns: (auto, auto),
      row-gutter: 1.5em,
      column-gutter: 1em,
      align: (right + horizon, left + horizon), // 保持标签右对齐，内容左对齐
      ..info.pairs().map(((label, value)) => (
        text(size: 14pt, weight: "bold")[#label :],
        text(size: 14pt)[#value],
      )).flatten()
    )

    #v(1fr)
    #if date != none {
      text(size: 14pt)[#date]
    }
    #v(2em)
  ]
}

/// Declaration of originality page. 原创性声明页。
///
/// - student-name (str): Student name / 学生姓名
/// - date (str): Signature date / 签名日期
/// - decl-body (content): Custom declaration text / 自定义声明文本
/// -> content
#let declaration-page(
  student-name: none,
  date: none,
  decl-body: none,
) = {
  align(center)[
    #v(2em)
    #text(size: 18pt, weight: "bold", font: "Heiti SC")[郑  重  声  明]
    #v(2em)
  ]

  if decl-body != none {
    par(justify: true, first-line-indent: 2em, decl-body)
  } else {
    par(justify: true, first-line-indent: 2em)[
      本人呈交的设计报告，是在指导老师的指导下，独立进行实验工作所取得的成果，所有数据、图片资料真实可靠。尽我所知，除文中已经注明引用的内容外，本设计报告不包含他人享有著作权的内容。对本设计报告做出贡献的其他个人和集体，均已在文中以明确的方式标明。本设计报告的知识产权归属于培养单位。
    ]
  }

  v(4em)
  align(right)[
    #if student-name != none {
      [本人签名：#student-name]
    } else {
      [本人签名：____________________]
    }
    #h(4em)
    #if date != none {
      [日期：#date]
    } else {
      [日期：____年____月____日]
    }
    #h(4em)
  ]
}
