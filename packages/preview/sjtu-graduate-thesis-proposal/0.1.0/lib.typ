#import "@preview/cuti:0.2.1": show-cn-fakebold

// --- 全局辅助函数与变量 ---

// 1. 定义打勾和方框（对应 LaTeX 的 \mychecked / \myunchecked）
// 勾使用加粗 Times，方框使用宋体并稍微放大以对齐视觉
#let mychecked = text(weight: "bold", font: "Times New Roman", "✓")
#let myunchecked = text(font: "SimSun", size: 1.0em, "□")

// 2. 蓝色下划线链接函数（还原 Word 蓝色链接效果）
#let blue-link(url, content) = {
  let link-color = rgb("#0000FF") // 深蓝色
  link(url)[
    #text(fill: link-color)[
      #underline(offset: 3pt, stroke: 0.5pt + link-color)[#content]
    ]
  ]
}

// --- Project 模板主函数 ---

#let project(
  title: "",
  student-id: "",
  name: "",
  degree-program: "",
  study-mode: "",
  supervisor: "",
  school: "",
  major: "",
  date: "",
  venue: "",
  body,
) = {
  // 1. 基础页面设置
  set page(
    paper: "a4",
    margin: (top: 2.5cm, bottom: 2.5cm, left: 2.8cm, right: 2.8cm),
  )
  
  // 2. 字体与伪粗体插件应用
  show: show-cn-fakebold
  // 全局默认字号 12pt (小四)，优先英文 Times，中文默认宋体
  set text(font: ("Times New Roman", "SimSun"), size: 12pt, lang: "zh")

  // 4. 标题样式：实现悬挂缩进
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

  // --- 封面页 ---
  set page(numbering: none)
  
  align(center)[
    // 建议预先将 PDF 转为 SVG 避免图层警告，若无则继续使用 PDF
    #image("./figures/sjtu-logo.pdf", width: 8.5cm)
    #v(0.5cm) // 对应 LaTeX \vspace{-1.0cm} 的微调效果
    #text(font: ("Times New Roman", "SimSun"), weight: "bold", size: 26pt)[研究生学位论文开题报告]\
    #v(0.4cm)
    #text(size: 15pt, weight: "bold")[Graduate Thesis/Dissertation Proposal]
    #v(1cm)
  ]

  // 封面表格：对称透明下划线对齐方案
  let field(label-zh, label-en, content) = (
    [
      #set align(left + horizon)
      #block(
        width: 100%,
        stroke: (bottom: white + 0.5pt), 
        inset: (top: 10pt, bottom: 10pt), // 还原 LaTeX arraystretch{1.7} 的高度
      )[
        #set text(font: ("Times New Roman", "KaiTi"), weight: "bold")
        #text(size: 14pt)[#label-zh]#h(0.5em)#text(size: 12pt)[#label-en]
      ]
    ],
    [
      #set align(left + horizon)
      #block(
        width: 100%, 
        stroke: (bottom: 0.5pt), 
        inset: (top: 10pt, bottom: 10pt),
      )[
        #set text(font: ("Times New Roman", "FangSong"), size: 12pt)
        #set par(first-line-indent: 0pt, leading: 0.8em)
        #content
      ]
    ]
  )

  grid(
    columns: (5.55cm, 9.45cm), // 左栏自适应标签宽度，右栏填满
    column-gutter: 0.6em,
    row-gutter: 0pt, 
    ..field("学号", "Student ID", student-id),
    ..field("姓名", "Name", name),
    ..field("学生类别", "Degree Program", degree-program),
    ..field("学习形式", "Study Mode", study-mode),
    ..field("导师", "Supervisor(s)", supervisor),
    ..field("论文题目", "Thesis Title", title),
    ..field("学院", "School", school),
    ..field("专业", "Major", major),
    ..field("开题日期", "Date", date),
    ..field("开题地点", "Venue", venue),
  )

  pagebreak()

  // --- 填报说明页 ---
  align(center)[
    #set text(font: ("Times New Roman", "SimHei"), size: 15pt)
    #{ let q = h(1em); [填#q 报#q 说#q 明] }
    #v(0.2cm)
    #set text(font: ("Times New Roman"), size: 15pt, weight: "bold")
    Instruction
    #v(0.2cm)
  ]

  set text(font: ("Times New Roman", "FangSong"), size: 12pt)
  // 填报说明内部行距较紧凑，不缩进
  set par(first-line-indent: 0pt, leading: 1em, justify: true)

  enum(
    indent: 0em,      // 列表整体缩进
    body-indent: 15pt, // 序号与文字的距离
    spacing: 1.5em,   // 对应 LaTeX 的 parsep
    [
      校本部研究生的开题报告应通过 #blue-link("http://my.sjtu.edu.cn/", "数字交大") 在线提交申请，填写本表并上传系统。特殊情况下经研究生院事先同意，可不上传系统，并使用《上海交通大学研究生论文开题评审表》完成评审。
      #v(0.15em)
      The application for thesis/dissertation proposal should be submitted online through #blue-link("http://my.sjtu.edu.cn/", "My SJTU"). The student shall fill this form and upload it in the system. Under special circumstance, this form does not need to be uploaded and the review can be proceeded with the review form with prior consent from the graduate school.
    ],
    [
      开题报告为A4大小，于左侧装订成册。各栏空格不够时，请自行加页。考核前提前一周送交导师、评审专家审阅。
      #v(0.15em)
      This form should be printed with A4 papers and bound together on the left. If the space left is not enough, please feel free to add extra pages. The print version shall be sent to the supervisor, and the review committee members for review at least one week before the oral presentation.
    ],
    [
      博士生导师可以根据博士生学位论文选题情况自行确定是否进行开题查新，博士学位论文开题查新报告应由查新工作站提供。
      #v(0.15em)
      The supervisor should decide, based on the proposed topics, whether a novelty assessment report is needed or not, which should be conducted by an authorized novelty assessment department.
    ],
    [
      开题报告通过后，定稿版开题报告由研究生、导师各存档一份，无需上传系统。
      #v(0.15em)
      Upon passing the proposal, the final version of this report shall be archived by the graduate student and his/her supervisors for future reference.
    ],
    [
      同等学力研究生开题答辩采用会议形式，硕士邀请至少3名相关学科/专业领域具有硕士研究生指导资格的专家。博士邀请5名相关学科/专业领域具有博士研究生指导资格的专家。
      #v(0.15em)
      The capstone presentation adopts a conference format, and at least three experts with master's degree guidance qualifications in relevant disciplines and professional fields are invited for the master's degree. And five experts with doctoral guidance qualifications in relevant disciplines/professional fields are invited for doctoral guidance.
    ]
  )

  pagebreak()

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

  // 定义全局斜体（emph）的显示规则
  show emph: it => {
  // 针对每一个字符进行处理，确保中文也能被 skew 倾斜
  show regex("[\p{Unified_Ideograph}\p{Punctuation}]"): char   => {
      box(skew(ax: -12deg, char))
    }
    it
  }
  
  body
}