//! @Title: 东北师范大学大学学位论文模板
//! @Author: [@Dian Ling](https://github.com/virgiling)
//! @Author: [@Lingshu Zeng](https://github.com/zeroDtree)
//! @Repo: https://github.com/virgiling/NENU-Thesis-Typst
//! @Reference: https://github.com/nju-lug/modern-nju-thesis

#import "layouts/doc.typ": doc
#import "layouts/preface.typ": preface
#import "layouts/mainmatter.typ": mainmatter
#import "layouts/appendix.typ": appendix
#import "pages/fonts-display-page.typ": fonts-display-page
#import "pages/bachelor-cover.typ": bachelor-cover
#import "pages/master-cover.typ": master-cover
#import "pages/master-comm-page.typ": master-comm-page
#import "pages/bachelor-decl-page.typ": bachelor-decl-page
#import "pages/master-decl-page.typ": master-decl-page
#import "pages/abstract.typ": abstract
#import "pages/abstract-en.typ": abstract-en
#import "pages/outline.typ": outline-page
#import "pages/list-of-figures.typ": list-of-figures
#import "pages/list-of-tables.typ": list-of-tables
#import "pages/notation.typ": notation
#import "pages/acknowledgement.typ": acknowledgement
#import "pages/publication-page.typ": publication
#import "pages/decision-page.typ": decision
#import "utils/custom-cuti.typ": *
#import "utils/bilingual-bibliography.typ": bilingual-bibliography
#import "utils/custom-numbering.typ": custom-numbering
#import "utils/custom-heading.typ": active-heading, current-heading, heading-display
#import "@preview/i-figured:0.2.4": show-equation, show-figure
#import "utils/style.typ": font-family, font-size


#let indent = h(2em)

/// 论文模板的入口函数，通过获取全局信息配置，分别发放对应参数的模板
/// -> function
#let thesis(
  /// 文档类型
  ///
  /// 可选择的值为 "bachelor" | "master" | "doctor"，分别表示 本科 ｜ 硕士 ｜ 博士
  /// -> str
  doctype: "bachelor",
  /// 学位类型
  ///
  /// 只有硕士以上的学位才可以选择，值为 "academic" （学术型）| "professional"（专业型）
  /// -> str
  degree: "academic",
  /// 双面模式
  ///
  /// 会在每一个部分后加入空白页，便于打印
  /// -> bool
  twoside: false,
  /// 盲审模式
  ///
  /// 隐藏学校/作者/导师等一切信息，满足盲审要求
  /// -> bool
  anonymous: false,
  /// 参考文献函数
  ///
  /// 一般传入值为 `bibliography.with("ref.bib")`，其中 `ref.bib` 是 biblatex 文件的路径
  /// -> function
  bibliography: none,
  /// 自定义字体
  /// 在 @@font_size 中我们加入了一些默认值，这里用于添加自定义的字体
  /// 但注意需要满足 @@font_size 的格式:
  ///
  /// `fonts = ( 宋体: ("Times New Romans"), 黑体: ( "Arial"), 楷体: ("KaiTi"), 仿宋: ("FangSong"), 等宽: ("Courier New")`
  /// -> dictionary
  fonts: (:),
  /// 论文以及个人信息
  /// - title: 论文中文题目
  /// - title-en: 论文英文题目
  /// - grade: 年级
  /// - student-id: 学号
  /// - author: 作者中文名
  /// - author-en: 作者英文名
  /// - secret-level: 密级中文
  /// - secret-level-en: 密级英文
  /// - department: 院系中文名
  /// - department-en: 院系英文名
  /// - discipline: 一级学科中文名
  /// - discipline-en: 一级学科英文名
  /// - major: 二级学科中文名
  /// - major-en: 二级学科英文名
  /// - field: 研究方向中文
  /// - field-en: 研究方向英文
  /// - supervisor: 导师信息(姓名, 职称)
  /// - supervisor-en: 导师英文信息
  /// - submit-date: 提交日期
  /// - school-code: 学校代码
  /// - reviewers: 论文评阅人
  ///   - name: 姓名
  ///   - workplace: 工作单位/职称
  ///   - evaluation: 总体评价
  /// - committee-members: 答辩委员会成员
  ///   - name: 姓名
  ///   - workplace: 工作单位/职称
  ///   - title: 总体评价
  /// -> dictionary
  info: (:),
) = {
  fonts = font-family + fonts
  info = (
    (
      title: ("毕业论文中文题目", "有一点长有一点长有一点长有一点长有一点长有一点长"),
      title-en: "Analysis of the genetic diversity within and between the XX population revealed by AFLP marker",
      grade: "20XX",
      student-id: "1234567890",
      author: "张三",
      author-en: "San Zhang",
      secret-level: "无",
      secret-level-en: "Unclassified",
      department: "信息科学与技术学院",
      department-en: "School of Information Science and Technology",
      discipline: "计算机科学与技术",
      discipline-en: "Computer Science and Technology",
      major: "计算机科学",
      major-en: "Computer Science",
      field: "人工智能",
      field-en: "Artificial Intelligence",
      supervisor: ("李四", "教授"),
      supervisor-en: "Professor My Supervisor",
      submit-date: datetime.today(),
      school-code: "10200",
      reviewers: (
        (name: "张三", workplace: "工作单位", evaluation: "总体评价"),
        (name: "李四", workplace: "工作单位", evaluation: "总体评价"),
        (name: "王五", workplace: "工作单位", evaluation: "总体评价"),
        (name: "赵六", workplace: "工作单位", evaluation: "总体评价"),
        (name: "孙七", workplace: "工作单位", evaluation: "总体评价"),
      ),
      committee-members: (
        (name: "张三", workplace: "工作单位", title: "职称"),
        (name: "李四", workplace: "工作单位", title: "职称"),
        (name: "王五", workplace: "工作单位", title: "职称"),
        (name: "赵六", workplace: "工作单位", title: "职称"),
        (name: "孙七", workplace: "工作单位", title: "职称"),
      ),
    )
      + info
  )

  return (
    //* 将传入参数再导出
    doctype: doctype,
    degree: degree,
    twoside: twoside,
    anonymous: anonymous,
    fonts: fonts,
    info: info,
    //* 页面布局
    doc: (..args) => {
      doc(
        ..args,
        info: info + args.named().at("info", default: (:)),
      )
    },
    //* 正文前格式
    preface: (..args) => {
      preface(
        twoside: twoside,
        ..args,
      )
    },
    //* 正文格式
    mainmatter: (..args) => {
      if doctype == "master" or doctype == "doctor" {
        mainmatter(
          doctype: doctype,
          twoside: twoside,
          display-header: true,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
        )
      } else {
        mainmatter(
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
        )
      }
    },
    //* 附录
    appendix: (..args) => {
      appendix(
        ..args,
      )
    },
    //* 字体展示页（测试用）
    fonts-display-page: (..args) => {
      fonts-display-page(
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    //* 封面页
    cover: (..args) => {
      if doctype == "master" or doctype == "doctor" {
        master-cover(
          doctype: doctype,
          degree: degree,
          anonymous: anonymous,
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      } else if doctype == "postdoc" {
        panic("NOT IMPLEMENTED YET")
      } else {
        bachelor-cover(
          anonymous: anonymous,
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      }
    },
    //* 委员会页面（硕博专用）
    committee-page: (..args) => {
      if doctype == "master" or doctype == "doctor" {
        master-comm-page(
          info: info,
          anonymous: anonymous,
          twoside: twoside,
          ..args,
        )
      } else if doctype == "postdoc" {
        panic("NOT IMPLEMENTED YET")
      } else {
        panic("BACHELOR DO NOT CONATIN COMMITTEE PAGE")
      }
    },
    //* 声明页
    decl-page: (..args) => {
      if doctype == "master" or doctype == "doctor" {
        master-decl-page(
          anonymous: anonymous,
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
        )
      } else if doctype == "postdoc" {
        panic("postdoc has not yet been implemented.")
      } else {
        bachelor-decl-page(
          anonymous: anonymous,
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      }
    },
    //* 中文摘要页
    abstract: (..args) => {
      if doctype == "postdoc" {
        panic("postdoc has not yet been implemented.")
      } else {
        abstract(
          anonymous: anonymous,
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      }
    },
    //* 英文摘要页
    abstract-en: (..args) => {
      if doctype == "postdoc" {
        panic("postdoc has not yet been implemented.")
      } else {
        abstract-en(
          anonymous: anonymous,
          twoside: twoside,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      }
    },
    //* 目录页
    outline-page: (..args) => {
      outline-page(
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    //* 插图目录页
    list-of-figures: (..args) => {
      list-of-figures(
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    //* 表格目录页
    list-of-tables: (..args) => {
      list-of-tables(
        twoside: twoside,
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },
    //* 符号表页
    notation: (..args) => {
      notation(
        twoside: twoside,
        ..args,
      )
    },
    //* 参考文献页
    bilingual-bibliography: (..args) => {
      bilingual-bibliography(
        bibliography: bibliography,
        ..args,
      )
    },
    //* 致谢页
    acknowledgement: (..args) => {
      acknowledgement(
        anonymous: anonymous,
        twoside: twoside,
        ..args,
      )
    },
    //* 成果页
    publication: (..args) => {
      if doctype != "bachelor" {
        publication(
          anonymous: anonymous,
          twoside: twoside,
          ..args,
        )
      } else {
        panic("BACHELOR DO NOT CONTAIN THIS PAGE")
      }
    },
    //* 导师与委员会评价页
    decision: (..args) => {
      if doctype == "doctor" {
        decision(
          anonymous: anonymous,
          twoside: twoside,
          ..args,
        )
      } else {
        panic("DO NOT CONTAIN THIS PAGE")
      }
    },
  )
}
