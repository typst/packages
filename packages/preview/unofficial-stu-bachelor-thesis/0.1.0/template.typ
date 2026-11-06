#import "lib/algo.typ": algo, comment, d, i
#let template-main(info, text-body) = {
  import "lib/font_config.typ": *
  import "lib/cover.typ": *
  import "lib/declaration.typ": *
  import "lib/chinese_abstract.typ": *
  import "lib/english_abstract.typ": *
  import "lib/catalog.typ": *
  import "lib/main_text.typ": *
  import "lib/thanks_page.typ": *
  import "lib/auth_use.typ": *

  info = (
    (
      title: "汕头大学学位论文格式模板",
      title-en: "Shantou University Dissertation Format Template",
      gradeandmajor: "电子信息工程　2021级",
      student-id: "2021123456",
      author: "张三",
      college: "工学院",
      department: "电子工程系",
      supervisor: "李四教授",
      submit-date: datetime.today(),
      abstract: [
        学位论文是学生从事科研工作、工程实践的成果的主要表现，集中表明了作者在工作、实践中获得的新的发明、理论或见解，是学生申请学生、硕士或博士学位的重要依据，也是科研领域中的重要文献资料和社会的宝贵财富。

        为了提高学生学位论文的质量，做到学位论文在内容和格式上的规范化与统一化，特制作本模板。
      ],
      keywords: ("学位论文", "论文格式", "规范化", "模板"),
      abstract-en: [
        A dissertation is a primary manifestation of students' achievements in scientific research work and engineering practice. It systematically demonstrates the author's new inventions, theories or insights obtained through research and practice. It serves as an important basis for students to apply for bachelor's, master's or doctoral degrees, and is also an important literature resource in the scientific research field and a valuable asset to society.

        In order to improve the quality of students' dissertations and achieve standardization and unification of dissertations in both content and format, this template has been specially created.
      ],
      keywords-en: (
        "dissertation",
        "dissertation format",
        "standardization",
        "template",
      ),
      acknowledgements: "",
      bib: "",
      cover-width: 60%,
      generate-auth-use-page: false,
      add-back-cover: true,
    )
      + info
  )

  /************本科生论文封面************/
  bachelor-cover(
    info: info,
  )

  if info.generate-auth-use-page {
    auth-use-page()
  }

  info.title = if type(info.title) == str [#info.title] else if (
    type(info.title) == array
  ) [#if info.title.len() == 2 [#(
    info.title.at(0) + info.title.at(1)
  )] else if (
    info.title.len() == 1
  ) [#info.title.at(0)] else [#panic(
    "非法title输入，请检查title数组长度！",
  )]] else [#panic(
    "非法title输入，请检查title输入！",
  )]

  /************声明页************/
  bachelor-decl-page(
    info: info,
  )

  // 设置页面的页边距为顶边距2.5cm，右边距2.0cm，底边距2.0cm，左边距2.5cm。
  set page(
    paper: "a4",
    margin: (top: 2.5cm, right: 2.0cm, bottom: 2.0cm, left: 2.5cm),
  )
  set text(font: 宋体, lang: "zh")
  {
    set page(
      footer: context {
        set align(center)
        set text(font: 宋体, size: 小五)
        counter(page).display("I")
      },
    )
    /************中文摘要页************/
    bachelor-abstract-ch(
      info: info,
      info.abstract,
    )

    /************英文摘要页************/
    bachelor-abstract-en(
      info: info,
      info.abstract-en,
    )

    /************目录页************/
    setup-outline()
  }

  {
    /************页脚设置************/
    set page(
      footer: context {
        set align(center)
        set text(size: 小五, font: 宋体)
        counter(page).display("1")
      },
    )

    /************正文************/
    setup-bodytext(text-body)

    //参考文献页设置
    show bibliography: it => {
      pagebreak(weak: true)
      set page(footer: context {
        set align(center)
        set text(size: 小五, font: 宋体)
        counter(page).display("1")
      })
      show heading.where(level: 2): it => {
        set align(left)
        set text(font: 黑体, size: 小四)
        it
      }

      heading(level: 2, numbering: none)[参考文献]

      set text(font: 宋体, size: 小五)
      set block(above: 1.25em, below: 1.25em)
      set par(justify: true, first-line-indent: 2em)
      it
    }
    info.bib
    /************致谢************/
    setup-thanks(info.acknowledgements)
  }

  /***封底***/
  if info.add-back-cover {
    pagebreak()
  }
}
