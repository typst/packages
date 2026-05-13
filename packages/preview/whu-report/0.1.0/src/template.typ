#import "cover.typ": cover, declaration-page
#import "code.typ": apply-code-styling
#import "@preview/cuti:0.2.1": show-cn-fakebold

/// WHU (Wuhan University) course design report template.
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
/// - course (str): College/department name
/// - title (str): Report category title
/// - subtitle (str): Specific report title
/// - instructor (str): Instructor name
/// - student-id (str): Student ID
/// - student-name (str): Student name
/// - major (str): Major name
/// - course-name (str): Course name
/// - date (str): Report date
/// - font-size (length): Base text size
/// - math-color (color): Math equation color
/// - show-declaration (bool): Include declaration/originality page
/// - declaration-text (content): Custom declaration text
/// - show-toc (bool): Include table of contents
/// - toc-title (str,content): TOC title
/// - toc-depth (int): TOC depth
/// - code-theme (str): Syntax highlighting theme file path
/// - mono-font (str,array): Monospace font
/// - body (content): Document body
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

/// Switch to appendix numbering (A.1, A.2, ...).
/// Call after the main content and before the appendix.
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
