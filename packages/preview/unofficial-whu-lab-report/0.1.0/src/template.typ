#import "cover.typ": cover, declaration-page
#import "code.typ": apply-code-styling
#import "@preview/cuti:0.4.0": show-cn-fakebold

/// Unofficial WHU (Wuhan University) lab report template.
/// 武汉大学计算机学院课程设计报告模板（非官方社区版）。
///
/// #show: whu-report.with(
///   course: "计算机学院",
///   subtitle: "线性回归实验报告",
///   instructor: "DLX",
///   student-id: "202430000****",
///   student-name: "whoisKIWIIZZZ",
///   major: "计算机弘毅班",
///   course-name: "机器学习",
/// )
///
/// = Section
/// Content...
///
/// - course (str): College/department name / 学院名称
/// - title (str): Report category title / 报告类别
/// - subtitle (str): Specific report title / 报告标题
/// - instructor (str): Instructor name / 指导教师
/// - student-id (str): Student ID / 学号
/// - student-name (str): Student name / 学生姓名
/// - major (str): Major name / 专业名称
/// - course-name (str): Course name / 课程名称
/// - date (str): Report date / 报告日期
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
  course: "武汉大学计算机学院",
  title: "本科生课程设计报告",
  subtitle: none,
  instructor: none,
  student-id: none,
  student-name: none,
  major: none,
  course-name: none,
  date: none,

  // Options
  font-size: 12pt,
  math-color: purple,
  show-declaration: false,
  declaration-text: none,
  show-toc: true,
  toc-title: none,
  toc-depth: 3,
  code-theme: "../assets/code.tmTheme",
  mono-font: ("Jetbrains Mono"),
  cn-serif: ("Latin Modern Roman", "Songti SC"),

  body,
) = {
  // Page setup
  set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm))
  set text(font: cn-serif, size: font-size)

  // Chinese fake bold
  show: show-cn-fakebold

  // Replace Chinese punctuation with English
  show "，": ","
  show "。": "."

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
    course: course,
    title: title,
    subtitle: subtitle,
    instructor: instructor,
    student-id: student-id,
    student-name: student-name,
    major: major,
    course-name: course-name,
    date: date,
  )
  pagebreak()

  // Declaration (optional)
  if show-declaration {
    declaration-page(
      student-name: student-name,
      date: date,
      decl-body: declaration-text,
    )
    pagebreak()
  }

  // Table of Contents
  if show-toc {
    outline(
      title: if toc-title != none { toc-title } else { text(size: 16pt, weight: "bold")[目  录] },
      indent: auto,
      depth: toc-depth,
    )
    pagebreak()
  }
  set raw(theme: "../assets/code.tmTheme")
  show raw.where(block: true): it => {
  let lang = if it.has("lang") { it.lang } else { "TEXT" }
  set text(size: 9pt,font: ("Jetbrains Mono","SongTi SC"))
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
        it,
      ),
    
  )
}
show raw.where(block: false): it => {
    set text(size: 10pt,font: ("JetBrains Mono NL","SongTi SC"),rgb("#A9504A"),)
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
