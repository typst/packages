#import "cover.typ": cover, declaration-page
#import "code.typ": apply-code-styling
#import "@preview/cuti:0.4.0": show-cn-fakebold


/// Unofficial WHU (Wuhan University) lab report template.
/// 武汉大学计算机学院课程设计报告模板（非官方社区版）。
///
// #show: whu-report.with(
//   title: "the title of the report",
//   major: "Computer Science",
//   course-name: "Operating System",
//   instructor: "Professor Cai",
//   student-id: "2024302114514",
//   student-name: "QianQiuXingChen",
//   semester: "2025-2026-3",
//   deadline: "2026年7月18日",
//   grade: true,
//   date: "二○二六年七月",
//   show-declaration: true,
//   signature: image("signature.png"),
// )
///
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
///
/// - font-size (length): Base text size / 正文字号
/// - math-color (color): Math equation color / 公式颜色
/// - show-declaration (bool): Include declaration/originality page / 是否显示声明页
/// - declaration-text (content): Custom declaration text / 自定义声明文本
/// - show-toc (bool): Include table of contents / 是否显示目录
/// - toc-title (str,content): TOC title / 目录标题
/// - toc-depth (int): TOC depth / 目录深度
/// - code-theme (str): Syntax highlighting theme file path / 代码高亮主题路径
/// - mono-font (str,array): Monospace font / 等宽字体
/// - body (content): Document body / 文档正文
/// -> content
#let whu-report(
  // Cover page
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
  signature: none,

  // Options
  font-size: 12pt,
  math-color: purple,
  show-declaration: false,
  declaration-text: none,
  show-toc: true,
  toc-title: "目  录",
  toc-depth: 3,
  code-theme: "../assets/code.tmTheme",
  mono-font: ("Jetbrains Mono", "Fira Code", "Consolas", "Ubuntu Mono", "Microsoft YaHei"),
  cn-serif: ("Times New Roman", "SimSun", "Latin Modern Roman", "Songti SC"),
  cn-sans: ("Times New Roman", "SimHei", "Latin Modern Sans", "Heiti SC"),

  body,
) = {
  // Page setup
  set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm))
  set text(font: cn-serif, size: font-size)

  // Chinese fake bold
  show: show-cn-fakebold

  // Math styling
  show math.equation: set text(purple, size: 1em)

  // Code block styling
  apply-code-styling(mono-font: mono-font)
  if code-theme != none {
    set raw(theme: code-theme)
  }

  // Paragraph styling
  set par(justify: true, first-line-indent: 2em)
  show heading: it => it + h(0pt)

  // Cover page
  cover(
    school: school,
    category: category,
    title: title,
    major: major,
    course-name: course-name,
    instructor: instructor,
    student-id: student-id,
    student-name: student-name,
    semester: semester,
    deadline: deadline,
    grade: grade,
    date: date,
  )
  pagebreak()

  // Declaration (optional)
  if show-declaration {
    declaration-page(
      date: deadline,
      decl-body: declaration-text,
      signature: signature,
    )
    pagebreak()
  }

  // Table of Contents
  if show-toc {
    outline(
      title: align(center)[#text(font: cn-sans, size: 18pt)[#toc-title]],
      indent: auto,
      depth: toc-depth,
    )
    pagebreak()
  }
  set par(justify: true, first-line-indent: 2em, leading: 23pt-1em)
  set text(top-edge: 0.6em, bottom-edge: -0.2em)
  set text(size: 12pt, font: cn-serif)
  set raw(theme: "../assets/code.tmTheme")

  show raw.where(block: true): it => {
    let lang = if it.has("lang") { it.lang } else { "TEXT" }
    block(
      fill: rgb("#FAFAF9"),
      stroke: 0.5pt + rgb("#CCD1D9"),
      radius: 3pt,
      width: 100%,
      inset: 0pt,
      clip: true,
      
      block(
        width: 100%,
        inset: 12pt,
        [
          #set par(justify: false, first-line-indent: 0pt,leading: 0.8em)
          #set text(font: mono-font, size: 9pt)
          #it
        ]
      ),
      
    )
  }
  show raw.where(block: false): it => {
      set text(size: 9pt,font: mono-font,rgb("#A9504A"),)
      box(
        fill: rgb("#E5E5E4"),
        inset: (x: 2pt, y: 0pt),
        outset: (y: 3pt),
        radius: 4pt,
        it,
      )
}

  // Main content
  set page(numbering: "1")
  set heading(numbering: "1.1")
  counter(page).update(1)

  body
}

/// Switch to appendix numbering (A.1, A.2, ...). 切换附录编号格式。
/// Call after the main content and before the appendix. 在正文之后、附录之前调用。
///
/// #pagebreak()
/// #show: appendix-style
/// = 附录
/// == 代码段
#let appendix-style(it) = {
  counter(heading).update((0, 0))
  show heading.where(level: 1): it => {
    set align(center)
    set text(size: 1.5em)
    v(1em)
    it
    v(0.8em)
  }
  set heading(numbering: "A.1")
  it
}

// the following is a teacher comment template, 
// which can be used in the report to provide feedback and grading.
// It includes a section for comments and a space 
// for the teacher to provide a score and signature.
#let teacher-comment(
) = {
  [
    #align(center)[
        #v(2em)
        #text(size: 18pt, weight: "bold", font: "SimHei")[教师评语评分]
        #v(2em)
    ]

    #text[
      #set par(justify: true, first-line-indent: 2em)
      评语:
      #for value in range(1,2) {
        " _______________________________________________________________\n"
      }
      #for value in range(1,8) {
          "_________________________________________________________________________\n"
      }
    ]

    #v(4em)
    #align(right)[
      评分:\_\_\_\_\_\_\_\_\_\_\_\_ #h(4em) 评阅人:\_\_\_\_\_\_\_\_\_\_\_
      #h(3em)
    ]
    #align(center)[(备注：对该实验报告给予优点和不足的评价，并给出百分之评分。)]
  ]
}