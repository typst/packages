#import "@preview/cuti:0.2.1": show-cn-fakebold
#let today-date = datetime.today().display("[year]-[month]-[day]")

// --- 全局辅助函数 ---

// 1. 打勾和方框
#let mychecked = text(weight: "bold", font: "Times New Roman", "✓")
#let myunchecked = text(font: "SimSun", size: 1.0em, "□")

// 2. 蓝色下划线链接（还原 Word 效果）
#let blue-link(url, content) = {
  let link-color = rgb("#0000FF")
  link(url)[#text(fill: link-color)[#underline(offset: 3pt, stroke: 0.5pt + link-color)[#content]]]
}

// --- Project 主函数 ---

#let project(
  student-id: "",
  name: "",
  supervisor: "",
  major: "",
  school: "",
  enrollment: "",
  degree-program: "",
  date: "",
  dissertation-title: "",
  source-of-research-project: "",
  dissertation-proposal-date: "",
  signature-image: none,
  signature-text: none,
  signature-date: "",
  body,
) = {

  // --- 自动化映射与错误处理逻辑 ---
  let e-map = (
    "a": "直博生 Doctoral Student after Bachelor's",
    "b": "普博生 Regular Doctoral Student",
    "c": "硕博连读生 Combined Master and Doctoral"
  )
  let d-map = (
    "a": "学术型 Academic",
    "p": "专业型 Professional"
  )

  // 处理入学方式
  let display-enrollment = if enrollment in e-map {
    e-map.at(enrollment)
  } else if enrollment in e-map.values() {
    enrollment // 如果已经是完整全称则保持
  } else {
    text(fill: red, weight: "bold")[无效入学方式(请填a/b/c)]
  }

  // 处理学生类别
  let display-degree = if degree-program in d-map {
    d-map.at(degree-program)
  } else if degree-program in d-map.values() {
    degree-program // 如果已经是完整全称则保持
  } else {
    text(fill: red, weight: "bold")[无效类别(请填a/p)] 
  }
  
  // 1. 基础页面设置 (封面边距)
  set page(
    paper: "a4",
    margin: (top: 2.54cm, bottom: 2.54cm, left: 0cm, right: 0cm),
  )
  
  show: show-cn-fakebold
  set text(font: ("Times New Roman", "SimSun"), size: 12pt, lang: "zh")

  // --- 封面页 ---
  set page(numbering: none)
  
  align(center)[
    #image("figures/sjtu-logo.pdf", width: 8.5cm)
    #v(0.0cm)
    #text(weight: "bold", size: 26pt)[博士研究生学位论文年度进展报告]\
    #v(0.0cm)
    #text(size: 15pt, weight: "bold")[Annual Progress Report for SJTU Doctoral Student]
    #v(1cm)
  ]

  // 封面表格函数
  let field(label-zh, label-en, content) = (
    // 左栏：正常撑开高度
    [
      #set align(left + bottom) // 改为 bottom 更有利于下划线视觉对齐
      #block(
        width: 100%,
        stroke: (bottom: white + 0.5pt), // 保持占位，但不显示
        inset: (top: 0pt, bottom: 10pt), 
      )[
        #set text(font: ("Times New Roman", "KaiTi"), weight: "bold")
        #text(size: 14pt)[#label-zh]#h(0.5em)#text(size: 14pt)[#label-en]
      ]
    ],
    // 右栏：使用 context 动态匹配左栏高度并实现垂直居中
    context [
      #set align(left + horizon)
      // 计算左栏可能的高度。由于左栏是 label-zh + label-en
      // 我们将右栏包装在一个支持垂直对齐的 box 中
      #block(
        width: 100%, 
        stroke: (bottom: 0.5pt), 
        inset: (top: 0pt, bottom: 10pt),
        // 关键：将内容物包装，并利用 block 的高度自适应
        // 配合 grid 的 align: bottom 确保下划线平齐
        [
          #set text(font: ("Times New Roman", "FangSong"), size: 14pt)
          #set par(first-line-indent: 0pt, leading: 0.8em)
          #content
        ]
      )
    ]
  )

  align(center)[
    #grid(
      columns: (6.25cm, 10.75cm),
      column-gutter: 0.5em,
      row-gutter: 1.2em,
      // 关键：这里要设为 bottom，保证所有 cell 的底部（即下划线）在同一水平线上
      align: bottom, 
      ..field("学号", "Student ID", student-id),
      ..field("姓名", "Name", name),
      ..field("导师", "Supervisor(s)", supervisor),
      ..field("专业", "Major", major),
      ..field("学院", "School", school),
      ..field("入学方式", "Enrollment", display-enrollment),
      ..field("学生类别", "Degree Program", display-degree),
      ..field("考核日期", "Date", date),
    )
  ]

  pagebreak()

  // --- 填报说明页 ---
  set page(
    margin: (x: 2.8cm, y: 2.5cm),
    header: [
      #set text(size: 9pt, font: ("Times New Roman", "SimSun"))
      #align(center)[上海交通大学博士生年度进展报告#h(0.5em)Annual Progress Review for SJTU Doctoral Student]
      #v(-0.6em)
      #line(length: 100%, stroke: 0.5pt)
      #v(-0.5em)
    ]
  )

  align(center)[
    #set text(font: ("Times New Roman", "SimHei"), size: 15pt)
    #v(0.3cm)
    #{ let q = h(1em); [填#q 报#q 说#q 明] }
    #v(0.2cm)
    #set text(font: ("Times New Roman"), size: 15pt, weight: "bold")
    Instruction
    #v(0.2cm)
  ]

  set text(font: ("Times New Roman", "FangSong"), size: 12pt)
  // 填报说明内部行距较紧凑，不缩进
  set par(first-line-indent: 0pt, leading: 1em, justify: true)
  
  // 说明列表
  enum(
    indent: 0em,      // 列表整体缩进
    body-indent: 10pt, // 序号与文字的距离
    spacing: 1.5em,   // 对应 LaTeX 的 parsep
    [
      博士研究生年度进展报告应通过#blue-link("http://my.sjtu.edu.cn/", "数字交大")在线提交申请，填写本表并上传系统。特殊情况下经研究生院事先同意，可不上传系统，并使用《上海交通大学博士研究生年度进展报告评审表》完成评审。
      #v(0.15em)
      The application for thesis/dissertation work annual progress review should be submitted online through #blue-link("http://my.sjtu.edu.cn/", "My SJTU"). The student shall filled this form and upload it in the system. Under special circumstance, this form does not need to be uploaded and the review can be proceeded with the review form with prior consent from the graduate school.
    ],
    [
      本报告应A4纸双面打印，于左侧钉在一起。各栏空格不够时，请自行加页。考核前提前一周送交导师、评审专家审阅。
      #v(0.15em)
      This report should be printed with A4 papers and bound together on the left. If the space left is not enough, please feel free to add extra pages. The print version shall be sent to the supervisor, and the review committee members for review at least one week before the oral presentation.
    ],
    [
      年度进展报告通过后，定稿版报告由研究生、导师各存档一份，无需上传系统。
      #v(0.15em)
      Upon passing the review, the final version of this report shall be archived by the graduate student and his/her supervisors for future reference.
    ]
  )

  pagebreak()

  // --- 正文页面设置 ---
  set page(
    margin: (
      top: 2.5cm,
      bottom: 1.5cm,
      left: 1.27cm,
      right: 1.27cm,
    ),
    header: [
      #set text(size: 9pt, font: ("Times New Roman", "SimSun"))
      #align(center)[上海交通大学博士生年度进展报告#h(0.5em)Annual Progress Review for SJTU Doctoral Student]
      #v(-0.8em)
      #line(length: 100%, stroke: 0.5pt)
      #v(-0.5em)
    ],
    footer: [
      #set text(size: 9pt, weight: "bold")
      #v(-0.2cm)
      #context {
        let cur = counter(page).at(here()).first()
        let total = counter(page).final().first()
        align(center)[#cur / #total]
      }
    ]
  )
  counter(page).update(1)

  //标题样式：实现悬挂缩进
  set heading(numbering: "1.1.1")
  
  show heading: it => {
    // 取消标题本身的段落缩进，确保编号靠左
    set par(first-line-indent: 0pt)
    let nums = counter(heading).at(it.location())
    
    // 根据级别确定字体和编号格式
    let title-font = if it.level == 1 { ("Times New Roman", "FangSong") } else { ("Times New Roman", "KaiTi") }
    let n_str = if it.level == 1 { numbering("1、", ..nums) } else { numbering(it.numbering, ..nums) }
    
    set text(font: title-font, weight: "bold", size: 12pt)
    
    // 使用 grid 实现悬挂缩进
    // columns: (auto, 1fr) 确保编号占多宽，文字就从哪里对齐
    grid(
      columns: (auto, 1fr),
      column-gutter: 1em, // 编号与文字之间的间距
      inset: (top: if it.level == 1 { 1em } else { 0.8em }, 
              bottom: if it.level == 1 { 0.8em } else { 0.6em }),
      [#n_str],
      [#it.body]
    )
  }

  // --- 正文开始 ---
  // 正文按照 LaTeX 模板默认设为楷体
  set text(font: ("Times New Roman", "KaiTi"))
  // 3. 段落设置：正文首行空两格
  set par(
    justify: true, 
    leading: 1em,      
    spacing: 1.5em,       
    first-line-indent: (amount: 2em, all: true), // 首行缩进两个字符
  )
  set page(numbering: "1")
  counter(page).update(1)

  // 无序列表左缩进 2 字符
  set list(indent: 2em)

  // 有序列表左缩进 2 字符
  set enum(indent: 2em)

  // 术语列表左缩进 2 字符
  set terms(indent: 2em)

  // 定义全局斜体（emph）的显示规则
  show emph: it => {
  // 针对每一个字符进行处理，确保中文也能被 skew 倾斜
  show regex("[\p{Unified_Ideograph}\p{Punctuation}]"): char   => {
      box(skew(ax: -12deg, char))
    }
    it
  }

  // 正文开头的特制表格
  v(-0.1cm)
  align(center)[
    #set text(font: ("Times New Roman", "FangSong"), weight: "bold", size: 14pt)
    博士生年度进展报告 Annual Progress Report
  ]
  v(-0.2cm)

  // --- 课题来源多选处理逻辑 ---
  // 确保输入是数组，并将元素转为整数
  let raw-sources = if type(source-of-research-project) == array {
    source-of-research-project.map(it => int(it))
  } else if source-of-research-project != "" and source-of-research-project != none {
    (int(source-of-research-project),) 
  } else {
    ()
  }

  // 排除掉 1-6 以外的无效数字
  let selected-sources = raw-sources.filter(it => it >= 1 and it <= 6)

  // 判断是否至少选择了一项
  let has-selection = selected-sources.len() > 0
  
  // 统一定义提示文字，仅改变颜色
  let instruction-color = if has-selection { black } else { red }
  let instruction-text = text(fill: instruction-color, weight: if has-selection { "regular" } else { "bold" })[
    请在合适选项前画 #mychecked #h(0.5em) Please select proper options by "#mychecked".
  ]

  align(center)[
    #table(
      columns: (3.67cm, 11.32cm),
      inset: 10pt,
      stroke: 0.5pt,
      align: left + horizon,
      text(font: ("Times New Roman", "FangSong"))[论文题目 \ Dissertation Title], 
      text(font: ("Times New Roman", "FangSong"))[#dissertation-title],
      
      text(font: ("Times New Roman", "FangSong"))[研究课题来源 \ Source of Research Project], 
      [
        #set text(font: ("Times New Roman", "FangSong"), size: 12pt)
        #set par(first-line-indent: 0pt, leading: 0.8em)
        // 直接显示处理好的文字
        #instruction-text \
        #v(-0.5em)
        // 嵌套 grid 以实现分栏对齐
        #grid(
          columns: (1.5em, 1fr), // 第一栏固定宽度放勾选框，第二栏放文字
          row-gutter: 1em,   // 控制复选框行间距
          align(center)[#(if selected-sources.contains(1) {mychecked} else {myunchecked})], [国家自然科学基金课题 NSFC Research Grants],
          align(center)[#(if selected-sources.contains(2) {mychecked} else {myunchecked})], [国家社会科学基金 National Social Science Fund of China],
          align(center)[#(if selected-sources.contains(3) {mychecked} else {myunchecked})], [国家重大科研专项 National Key Research Projects],
          align(center)[#(if selected-sources.contains(4) {mychecked} else {myunchecked})], [其它纵向科研课题 Other Governmental Research Grants],
          align(center)[#(if selected-sources.contains(5) {mychecked} else {myunchecked})], [企业横向课题 R&D Projects from Industry],
          align(center)[#(if selected-sources.contains(6) {mychecked} else {myunchecked})], [自拟课题 Self-proposed Project])
      ],
      text(font: ("Times New Roman", "FangSong"))[论文开题日期 \ Dissertation Proposal Date],
      text(font: ("Times New Roman", "FangSong"))[#dissertation-proposal-date]
    )
  ]

  // 表格标题放在顶部
  show figure.where(
    kind: table
  ): set figure.caption(position: top)
  
  body

  v(2em)
  set text(font: ("Times New Roman", "FangSong"), weight: "bold")
  
  [本人承诺：报告中的内容真实无误，若有不实，愿承担相应的责任和后果。I hereby declare and confirm that the details provided in this Form are valid and accurate. If anything untruthful found, I will bear the corresponding liabilities and consequences.]

  v(1em)

  grid(
    columns: (10cm, 1fr),
    align: horizon,
    [
      学生签字/Signature: 
      #{
        // 逻辑判断
        if signature-image != none and signature-image != "" {
          // 如果是图片，保留 box 以控制 baseline 避免图片“悬浮”
          h(0.2em) 
          box(baseline: 20%, image("template/"+signature-image, height: 1.2em))
        } else if signature-text != none and signature-text != "" {
          // 如果是文本，直接输出，不使用 box
          text(font: ("Times New Roman", "KaiTi"), weight: "regular")[#signature-text]
        } else {
          // 报错提示
          text(fill: red, size: 1em)[请设置签名图片或你的名字]
        }
      }
    ],
    [
      #h(1fr) 日期/Date: #signature-date
    ]
  )

}