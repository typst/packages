// 中国地质大学学位论文模板 cug-thesis-typst
// Author: https://github.com/Rsweater
// Repo: https://github.com/Rsweater/cug-thesis-typst
// 在线模板可能不会更新得很及时，如果需要最新版本，请关注 Repo
#import "layouts/doc.typ": doc
#import "layouts/mainmatter.typ": mainmatter
#import "layouts/appendix.typ": appendix
#import "pages/fonts-display-page.typ": fonts-display-page
#import "pages/postgraduate/titlepage.typ": postgraduate-titlepage
#import "pages/postgraduate/declaration.typ": postgraduate-declaration
#import "pages/postgraduate/resume.typ": postgraduate-resume
#import "pages/postgraduate/abstract.typ": postgraduate-abstract
#import "pages/postgraduate/abstract-en.typ": postgraduate-abstract-en
#import "pages/postgraduate/outline.typ": postgraduate-outline
#import "pages/list-of-figures-tables.typ": list-of-figures-tables
#import "pages/notation.typ": notation
#import "pages/postgraduate/acknowledgement.typ": acknowledgement
#import "utils/custom-cuti.typ": *
#import "utils/bilingual-bibliography.typ": bilingual-bibliography
#import "utils/custom-numbering.typ": custom-numbering
#import "utils/custom-heading.typ": heading-display, active-heading, current-heading
#import "utils/indent.typ": indent, fake-par
#import "utils/style.typ": 字体, 字号
#import "@preview/anti-matter:0.0.2": anti-inner-end as mainmatter-end
#import "@preview/i-figured:0.2.4": show-figure, show-equation

// 使用函数闭包特性，通过 `documentclass` 函数类进行全局信息配置，然后暴露出拥有了全局配置的、具体的 `layouts` 和 `templates` 内部函数。
#let documentclass(
  nl-cover: false,  // TODO: 是否使用国家图书馆封面，默认关闭
  single-side: (),  // 单面打印范围
  anonymous: false,  // 盲审模式
  bibliography: none,  // 原来的参考文献函数
  // 控制页面是否渲染
  pages: (
    // 封面可能由学院统一打印提供，因此可以不渲染
    cover: true,

    // 附录部分为可选。设置为 true 后，会在参考文献部分与致谢部分之间插入附录部分。
    appendix: false,
  ),
  fonts: (:),  // 字体，应传入「宋体」、「黑体」、「楷体」、「仿宋」、「等宽」
  info: (:),
  // 论文正文信息，包括绪论、主体、结论
  // content,
) = {
  // 默认参数
  fonts = 字体 + fonts
  info = (
    // 论文标题，将展示在封面、扉页与页眉上
    // 多行标题请使用数组传入 `("thesis title", "with part next line")`，或使用换行符：`"thesis title\nwith part next line"`
    title: ("中国地质大学学位论文Typst模板", "参考研究生学位论文写作规范（2015-）"),
    title-en: ("The Specification of Writting and Printing", "for CUG thesis"),

    // 论文作者信息：学号、姓名、院系、专业、指导老师
    grade: "2025",
    student-id: "120222xxxx",
    school-code: "10491",
    school-name: "中国地质大学",
    school-name-en: "China University of Geosciences",
    author: "张三",
    author-en: "Ming Xing",
    department: "国家地理信息系统\n工程技术研究中心",
    department-en: "National Engineering Research Center of Geographic Information System",
    doctype: "master",
    degreetype: "professional", 
    is-equivalent: false, 
    is-fulltime: true,
    degree: "工程硕士", 
    degree-en: "Master of Engineering",
    major: "测绘工程",
    major-en: "Surveying and Mapping Engineering",
    // 指导老师信息，以`("name", "title")` 数组方式传入
    supervisor: ("李四", "教授"),
    supervisor-en: ("Prof.", "Li Si"),
    supervisor-ii: (),
    supervisor-ii-en: (),
    address-en: "Wuhan 430074 P.R. China",

    // 提交日期，默认为论文 PDF 生成日期
    submit-date: datetime.today(),
    // 以下为研究生项
    // defend-date: datetime.today(),
    // confer-date: datetime.today(),
    // bottom-date: datetime.today(),
    chairman: "某某某 教授",
    reviewer: ("某某某 教授", "某某某 教授"),
    clc: "O643.12",
    udc: "544.4",
    secret-level: "公开",
    supervisor-contact: "南京大学 江苏省南京市栖霞区仙林大道163号",
    email: "xyz@smail.nju.edu.cn",
  ) + info

  (
    // 将传入参数再导出
    doctype: info.doctype,
    degree: info.degree,
    nl-cover: nl-cover,
    single-side: single-side,
    anonymous: anonymous,
    fonts: fonts,
    info: info,
    // 页面布局
    // 论文渲染控制参数处理。设置可选页面的默认设置项
    doc: (..args) => {
      doc(
        ..args,
        info: info + args.named().at("info", default: (:)),
      )
    },
    mainmatter: (..args) => {
      if info.doctype == "master" or info.doctype == "doctor" {
        mainmatter(
          twoside: if single-side.contains("mainmatter") { true } else { false },
          anonymous: anonymous,
          display-header: true,
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          info: info + args.named().at("info", default: (:)),
        )
      } else {
        mainmatter(
          twoside: if single-side.contains("mainmatter") { true } else { false },
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
        )
      }
    },
    mainmatter-end: (..args) => {
      mainmatter-end(
        ..args,
      )
    },
    appendix: (..args) => {
      appendix(
        ..args,
      )
    },

    // 字体展示页
    fonts-display-page: (..args) => {
      fonts-display-page(
        twoside: if single-side.contains("fonts-display-page") { true } else { false },
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },

    // 封面
    

    // 题名页，通过 type 分发到不同函数
    title-page: (..args) => {
      if info.doctype == "master" or info.doctype == "doctor" {
        postgraduate-titlepage(
          anonymous: anonymous,
          twoside: if single-side.contains("title-page") { true } else { false },
          ..args,
          info: info + args.named().at("info", default: (:)),
        )
      } else if info.doctype == "postdoc" {
        panic("postdoc has not yet been implemented.")
      } else {
        panic("bachelor has not yet been implemented.")
        // bachelor-cover(
        //   anonymous: anonymous,
        //   twoside: if single-side.contains("title-page") { true } else { false },
        //   ..args,
        //   fonts: fonts + args.named().at("fonts", default: (:)),
        //   info: info + args.named().at("info", default: (:)),
        // )
      }
    },

    // 声明页，通过 type 分发到不同函数
    decl-page: (..args) => {
      if info.doctype == "master" or info.doctype == "doctor" {
        postgraduate-declaration(
          anonymous: anonymous,
          twoside: if single-side.contains("decl-page") { true } else { false },
          ..args,
          info: info + args.named().at("info", default: (:)),
        )
      } else if info.doctype == "postdoc" {
        panic("postdoc has not yet been implemented.")
      } else {
        panic("bachelor has not yet been implemented.")
        // bachelor-decl-page(
        //   anonymous: anonymous,
        //   twoside: if single-side.contains("decl-page") { true } else { false },
        //   ..args,
        //   fonts: fonts + args.named().at("fonts", default: (:)),
        //   info: info + args.named().at("info", default: (:)),
        // )
      }
    },

    resume-page: (..args) => {
      if info.doctype == "master" or info.doctype == "doctor" {
        postgraduate-resume(
          anonymous: anonymous,
          twoside: if single-side.contains("resume-page") { true } else { false },
          ..args,
          info: info + args.named().at("info", default: (:)),
        )
      } else if info.doctype == "postdoc" {
        panic("postdoc has not yet been implemented.")
      } else {
        panic("bachelor has not yet been implemented.")
        // bachelor-decl-page(
        //   anonymous: anonymous,
        //   twoside: if single-side.contains("resume-page") { true } else { false },
        //   ..args,
        //   fonts: fonts + args.named().at("fonts", default: (:)),
        //   info: info + args.named().at("info", default: (:)),
        // )
      }
    },
    
    // 中文摘要页，通过 type 分发到不同函数
    abstract: (..args) => {
      if info.doctype == "master" or info.doctype == "doctor" {
        postgraduate-abstract(
          doctype: info.doctype,
          degree: info.degree,
          anonymous: anonymous,
          twoside: if single-side.contains("abstract") { true } else { false },
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:))
        )
      } else if info.doctype == "postdoc" {
        panic("postdoc has not yet been implemented.")
      } else {
        panic("bachelor has not yet been implemented.")
        // bachelor-abstract(
        //   anonymous: anonymous,
        //   twoside: if single-side.contains("abstract") { true } else { false },
        //   ..args,
        //   fonts: fonts + args.named().at("fonts", default: (:)),
        //   info: info + args.named().at("info", default: (:)),
        // )
      }
    },

    // 英文摘要页，通过 type 分发到不同函数
    abstract-en: (..args) => {
      if info.doctype == "master" or info.doctype == "doctor" {
        postgraduate-abstract-en(
          doctype: info.doctype,
          degree: info.degree,
          anonymous: anonymous,
          twoside: if single-side.contains("abstract-en") { true } else { false },
          ..args,
          fonts: fonts + args.named().at("fonts", default: (:)),
          // info: info + args.named().at("info", default: (:)),
        )
      } else if info.doctype == "postdoc" {
        panic("postdoc has not yet been implemented.")
      } else {
        panic("bachelor has not yet been implemented.")
        // bachelor-abstract-en(
        //   anonymous: anonymous,
        //   twoside: if single-side.contains("abstract-en") { true } else { false },
        //   ..args,
        //   fonts: fonts + args.named().at("fonts", default: (:)),
        //   info: info + args.named().at("info", default: (:)),
        // )
      }
    },

    // 目录页
    outline-page: (..args) => {
      postgraduate-outline(
        twoside: if single-side.contains("outline-page") { true } else { false },
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },

    // 图标目录页
    list-of-figures-tables: (..args) => {
      list-of-figures-tables(
        twoside: if single-side.contains("outline-page") { true } else { false },
        ..args,
        fonts: fonts + args.named().at("fonts", default: (:)),
      )
    },

    // 符号表页
    notation: (..args) => {
      notation(
        twoside: if single-side.contains("notation") { true } else { false },
        ..args,
      )
    },

    // 参考文献页
    bilingual-bibliography: (..args) => {
      bilingual-bibliography(
        bibliography: bibliography,
        ..args,
      )
    },

    // 致谢页
    acknowledgement: (..args) => {
      acknowledgement(
        anonymous: anonymous,
        twoside: if single-side.contains("acknowledgement") { true } else { false },
        ..args,
      )
    },
  )
}
