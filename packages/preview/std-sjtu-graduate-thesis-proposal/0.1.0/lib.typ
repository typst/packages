#import "@preview/cuti:0.2.1": show-cn-fakebold
#let today-date = datetime.today().display("[year]-[month]-[day]")

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
  proposed-title: "",
  source-of-research-project: "",
  other-project-name: "",
  signature-image: none,
  signature-text: none,
  signature-date: "",
  body,
) = {

  // --- 自动化映射与错误处理逻辑 ---
  let d-map = (
    "ad": "学术型博士生 Academic Doctoral Student",
    "pd": "专业型博士生 Professional Doctoral Student",
    "am": "学术型硕士生 Academic Master Student",
    "pm": "专业型硕士生 Professional Master Student"
  )
  let s-map = (
    "f": "全日制 Full-time",
    "p": "非全日制 Part-time",
    "e": "同等学力学生"
  )

  // 处理学生类别
  let display-degree = if degree-program in d-map {
    d-map.at(degree-program)
  } else if degree-program in d-map.values() {
    degree-program // 如果已经是完整全称则保持
  } else {
    text(fill: red, weight: "bold")[无效类别(请填ad/pd/am/pm)]
  }

  // 处理学习形式
  let display-study = if study-mode in s-map {
    s-map.at(study-mode)
  } else if study-mode in s-map.values() {
    study-mode // 如果已经是完整全称则保持
  } else {
    text(fill: red, weight: "bold")[无效形式(请填f/p/e)]
  }

  // 处理论文题目
  let display-title = if proposed-title == "" or proposed-title == title {
    title
  } else {
    proposed-title
  }

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
    #image("./figures/sjtu-logo.pdf", width: 8.5cm)
    #v(0.5cm)
    #text(font: ("Times New Roman", "SimSun"), weight: "bold", size: 26pt)[研究生学位论文开题报告]\
    #v(0.4cm)
    #text(size: 15pt, weight: "bold")[Graduate Thesis/Dissertation Proposal]
    #v(1cm)
  ]

  // 封面表格
  let field(label-zh, label-en, content) = (
    [
      #set align(left + horizon)
      #block(
        width: 100%,
        stroke: (bottom: white + 0.5pt), 
        inset: (top: 10pt, bottom: 10pt),
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

  align(center)[
    #grid(
      columns: (5.55cm, 9.45cm),
      column-gutter: 0.6em,
      row-gutter: 0pt,
      ..field("学号", "Student ID", student-id),
      ..field("姓名", "Name", name),
      ..field("学生类别", "Degree Program", display-degree),
      ..field("学习形式", "Study Mode", display-study),
      ..field("导师", "Supervisor(s)", supervisor),
      ..field("论文题目", "Thesis Title", title),
      ..field("学院", "School", school),
      ..field("专业", "Major", major),
      ..field("开题日期", "Date", date),
      ..field("开题地点", "Venue", venue),
    )
  ]

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

  // --- 课题来源多选处理逻辑 ---
  // 确保输入是数组，并将元素转为整数
  let raw-sources = if type(source-of-research-project) == array {
    source-of-research-project.map(it => int(it))
  } else if source-of-research-project != "" and source-of-research-project != none {
    (int(source-of-research-project),)
  } else {
    ()
  }

  // 排除掉 1-7 以外的无效数字
  let selected-sources = raw-sources.filter(it => it >= 1 and it <= 7)

  // 判断是否至少选择了一项
  let has-selection = selected-sources.len() > 0

  // 统一定义提示文字，仅改变颜色
  let instruction-color = if has-selection { black } else { red }
  let instruction-text = text(fill: instruction-color, weight: if has-selection { "regular" } else { "bold" })[
    请在合适选项前画 #mychecked #h(0.5em) Please select proper options by "#mychecked".
  ]

  // 处理"其它"选项的内容
  let other-content = if selected-sources.contains(7) {
    // 选中了"其它"
    if other-project-name != "" and other-project-name != none {
      // 有传入名称，正常显示
      box(
        width: 7cm,
        stroke: (bottom: 0.5pt),
        inset: (bottom: 3pt),
        baseline: 3pt
      )[#other-project-name]
    } else {
      // 选中但没传入名称，显示红色提示
      box(
        width: 7cm,
        stroke: (bottom: 0.5pt),
        inset: (bottom: 3pt),
        baseline: 3pt
      )[#text(fill: red, weight: "bold")[在此处填写内容]]
    }
  } else {
    // 未选中"其它"，显示空白横线
    box(
      width: 7cm,
      stroke: (bottom: 0.5pt),
      inset: (bottom: 3pt),
      baseline: 3pt
    )[ ]
  }

  // 课题基本信息表
  table(
    columns: (3.75cm, 11.5cm),
    stroke: 0.5pt,
    inset: 7pt,
    align: horizon,
    text(font: ("Times New Roman", "FangSong"))[论文题目 \ Proposed Title],
    text(font: ("Times New Roman", "FangSong"))[#display-title],

    text(font: ("Times New Roman", "FangSong"))[研究课题来源 \ Source of Research \ Project],
    [
      #set text(font: ("Times New Roman", "FangSong"), size: 12pt)
      #set par(first-line-indent: 0pt, leading: 0.8em)
      #instruction-text \
      #v(-0.5em)
      #grid(
        columns: (1.5em, 1fr),
        row-gutter: 1em,
        align(center)[#(if selected-sources.contains(1) {mychecked} else {myunchecked})], [国家自然科学基金课题 NSFC Research Grants],
        align(center)[#(if selected-sources.contains(2) {mychecked} else {myunchecked})], [国家社会科学基金 National Social Science Fund of China],
        align(center)[#(if selected-sources.contains(3) {mychecked} else {myunchecked})], [国家重大科研专项 National Key Research Projects],
        align(center)[#(if selected-sources.contains(4) {mychecked} else {myunchecked})], [其它纵向科研课题 Other Governmental Research Grants],
        align(center)[#(if selected-sources.contains(5) {mychecked} else {myunchecked})], [企业横向课题 R&D Projects from Industry],
        align(center)[#(if selected-sources.contains(6) {mychecked} else {myunchecked})], [自拟课题 Self-proposed Project],
        align(center)[#(if selected-sources.contains(7) {mychecked} else {myunchecked})], [
          其它 Other #h(0.2em) #other-content
        ]
      )
    ]
  )

  // 表格标题放在顶部
  show figure.where(
    kind: table
  ): set figure.caption(position: top)

  body

  v(2em)
  // 局部重置所有缩进设置
  set par(first-line-indent: 0pt)
  // 局部屏蔽我们在 template 里写的强制间距补丁
  show par: it => it 
  set text(font: ("Times New Roman", "FangSong"), weight: "bold")

  [本人承诺：开题报告中的内容真实无误，若有不实，愿承担相应的责任和后果。I hereby declare and confirm that the details provided in this Form are valid and accurate. If anything untruthful found, I will bear the corresponding liabilities and consequences.]

  v(1em)

  grid(
    columns: (10cm, 1fr),
    align: horizon,
    [
      学生签字/Signature:
      #{
        // 逻辑判断
        if signature-image != none and signature-image != "" {
          // 如果是图片，保留 box 以控制 baseline 避免图片"悬浮"
          h(0.2em)
          box(baseline: 20%, image("./template/"+signature-image, height: 1.2em))
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