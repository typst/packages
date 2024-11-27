#import "../../utils/datetime-display.typ": datetime-zh-display
#import "../../utils/justify-text.typ": justify-text
#import "../../utils/style.typ": 字号, 字体
#import "../../utils/anonymous-info.typ": anonymous-info

// 研究生封面
#let postgraduate-titlepage(
  // documentclass 传入的参数
  anonymous: false,
  twoside: false,
  // fonts: (:),
  info: (:),
  // 其他参数
  cover-meta-font: "宋体",
  cover-meta-size: "三号", 
  cover-title-font: "黑体",
  cover-title-size: "二号", 
  bold-info-keys: ("title", "school-name"),
  bold-level: "bold",
  stoke-width: 0.5pt,
  min-title-lines: 2,
  min-reviewer-lines: 5,
  info-inset: (bottom: -2pt),
) = {
  // 对参数进行处理
  // 如果是字符串，则使用换行符将标题分隔为列表
  if type(info.title) == str {
    info.title = info.title.split("\n")
  }
  if type(info.title-en) == str {
    info.title-en = info.title-en.split("\n")
  }
  if type(info.department) == str {
    info.department = info.department.split("\n")
  }
  assert(type(info.submit-date) == datetime, message: "submit-date must be datetime.")

  // 内置辅助函数
  let info-style(
    body, 
    weight: "regular",
    font: 字体.at(cover-meta-font, default: 字体.宋体),
    size: 字号.at(cover-meta-size, default: 字号.三号),
    align-type: "default", // str(justify), str(default), left, right, center, 
  ) = {
    rect(
      width: 100%, 
      // inset: info-inset,
      stroke: none,
      text(
        font: font, size: size, 
        weight: weight,
        if (align-type == "justify") {
          justify-text(with-tail: true, body)
        } else if (align-type == "default") {
          body
        } else {align(align-type, body)}
      )
    )
  }

  let docname(
    body, weight: "bold",
    font: 字体.宋体,
    size: 字号.一号,
    leading-scale: 1.2,
  ) = {
    rect(
      width: 100%,
      stroke: none,
      text(
        font: font, size: size,
        weight: weight,
        par(body, leading: size * leading-scale)
      )) 
  }
  let docname-en = docname.with(font: 字体.宋体, size: 字号.三号, weight: "regular")
  let title = docname.with(font: 字体.黑体, size: 字号.二号)
  let title-en = docname-en.with(font: 字体.宋体, size: 字号.二号)
  let address-en = docname-en
  let anonymous-info = anonymous-info.with(anonymous: anonymous)

  // 正式渲染
  // 中文题名页
  block(height: 1.38cm, grid(
    columns: (auto, auto, auto, auto), 
    info-style("学校代码：", align-type: right),
    info-style(anonymous-info(info.school-code)),
    info-style("研究生学号：", align-type: right),
    info-style(anonymous-info(info.student-id)),
  ))
  block(height: 3.9cm, grid(
    columns: auto, 
    align: center,
    if info.degreetype == "academic" {
    if info.doctype == "doctor" { 
      docname(anonymous-info(info.school-name) + "博士学位论文")
      } else {
        docname(anonymous-info(info.school-name) + "硕士学位论文")
      }
    } else if info.degreetype == "professional" {
      if info.is-fulltime { 
        docname(anonymous-info(info.school-name) + "\n硕士专业学位论文（全日制）")
        } else { 
          docname(anonymous-info(info.school-name) + "\n硕士专业学位论文（非全日制）")
        }
    }
  ))
  // 论文题目
  block(height: 2.67cm, grid(
    columns: auto, 
    align: center,
    title(info.title.join("\n"), font: 字体.黑体, size: 字号.二号, leading-scale: 1.0),
  ))

  // 学生与指导老师信息
  { 
    set align(center+horizon)
    block(width: 10cm, grid(
    align: (center, left),
    columns: (4.33cm, 5cm),
    rows: (0.99cm, 1.07cm, 1.14cm, 1.17cm, 1.23cm),
    info-style("姓名", align-type: "justify"),
    info-style(anonymous-info(info.author)),
    ..(if info.degreetype == "professional" {(
      {
        info-style("专业学位类型", align-type: "justify")
      },
      // info-style(info.degree + "（" + info.major + "）"),
      info-style(anonymous-info(info.degree)),
    )} else {(
      info-style("专业名称", align-type: "justify"),
      info-style(anonymous-info(info.major)),
    )}),
    info-style("指导教师", align-type: "justify"),
    info-style(info.supervisor.map(str => anonymous-info(str)).intersperse(" ").sum()),
    ..(if info.supervisor-ii != () {(
      info-style("　"),
      info-style(info.supervisor-ii.map(str => anonymous-info(str)).intersperse(" ").sum()),
    )} else { () }),
    info-style("培养单位", align-type: "justify"),
    info-style(anonymous-info(info.department.join("\n"))),
  ))
  v((9.54cm-(0.99cm+1.07cm+1.14cm+1.17cm+1.23cm))/2)
  }

  {
    set align(center+bottom)
    block(height: 2.67cm, grid(
      columns: auto, 
      align: center,
      text(datetime-zh-display(info.submit-date, anonymous: anonymous), font: 字体.宋体, size: 字号.三号)
    ))
  }
  pagebreak(weak: true, to: if twoside { "odd" })
 

  // 英文题名页
  block(height: 1.64cm, grid(
    columns: auto, 
    align: center,
    if info.degreetype == "academic" {
    if info.doctype == "doctor" { 
      docname-en("A Dissertation Submitted to "+ anonymous-info(info.school-name-en) 
      + "For the Doctor Degree of " + anonymous-info(info.degree-en))
      } else {
        docname-en("A Dissertation Submitted to "+ anonymous-info(info.school-name-en)
      + "For the Master  Degree of " + anonymous-info(info.degree-en))
      }
    } else if info.degreetype == "professional" {
      if info.is-fulltime { 
        docname-en("A Dissertation Submitted to "+ anonymous-info(info.school-name-en)
        + "\nFor the Full-Time Master of Professional Degree of\n" + anonymous-info(info.degree-en))
        } else { 
          docname-en("A Dissertation Submitted to "+ anonymous-info(info.school-name-en)
        + "\nFor the Part-Time Master of Professional Degree of\n" + anonymous-info(info.degree-en))
        }
    }
  ))
  v(2.73cm)
  //论文题目
  block(height: 2.67cm, grid(
    columns: auto, 
    align: center,
    title-en(info.title-en.join("\n"), leading-scale: 0.8),
  ))

  // 学生与指导老师信息
  { 
    set align(center+horizon)
    block(width: 88%, grid(
    align: (center, left),
    columns: (6.99cm, auto),
    rows: (0.99cm, 1.07cm, 1.14cm, 1.17cm, 1.23cm),
    ..(if info.doctype == "doctor" {(
      {
        info-style("Ph.D. Candidate: ", align-type: right)
      }, 
      info-style(anonymous-info(info.author-en)),
    )} else {(
      info-style("Master Candidate: ", align-type: right), 
      info-style(anonymous-info(info.author-en)),
    )}),
    ..(if info.degreetype == "professional" {(
      {
        info-style("Professional Degree Type: ", align-type: right)
      },
      info-style(anonymous-info(info.degree-en)),
    )} else {(
      info-style("Major: ", align-type: right),
      info-style(anonymous-info(info.major-en)),
    )}),
    info-style("Supervisor: ", align-type: right),
    info-style(info.supervisor-en.map(str => anonymous-info(str)).intersperse(" ").sum()),
    ..(if info.supervisor-ii-en != () {(
      info-style("　"),
      info-style(info.supervisor-ii-en.map(str => anonymous-info(str)).intersperse(" ").sum()),
    )} else { () }),
  ))
  v((9.54cm-(0.99cm+1.07cm+1.14cm+1.17cm+1.23cm))/2)
  }

  {
    set align(center+bottom)
    block(height: 3.55cm, grid(
      columns: auto, 
      align: center,
      if anonymous {
        address-en("▢▢▢▢▢▢\n▢▢▢▢▢")
      } else {
        address-en("China University of Geosciences\nWuhan 430074 P.R. China")
      }
    ))
  }
  pagebreak(weak: true, to: if twoside { "odd" })
}

// 封面测试代码
// #import "/template/thesis-info.typ": thesis-info  
// #show: postgraduate-titlepage(info: thesis-info, anonymous: true)
