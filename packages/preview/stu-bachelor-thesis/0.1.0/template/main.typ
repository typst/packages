#import "@preview/stu-bachelor-thesis:0.1.0": template-main
#import "lib/references.typ": setup-bibliography

#[
  #show: text-body => template-main(
    /************封面&致谢************/
    (
      title: "汕头大学学位论文格式模板",
      title-en: "Shantou University Dissertation Format Template",
      gradeandmajor: "电子信息工程　20XX级",
      student-id: "2021123456",
      author: "张三",
      college: "工学院",
      department: "电子工程系",
      supervisor: "李四教授",
      //submit-date: "2026年5月1日", // 默认直接使用当前日期，取消注释以设置日期

      /*摘要相关*/
      abstract: [
        //中文摘要
        学位论文是学生从事科研工作、工程实践的成果的主要表现，集中表明了作者在工作、实践中获得的新的发明、理论或见解，是学生申请学生、硕士或博士学位的重要依据，也是科研领域中的重要文献资料和社会的宝贵财富。

        为了提高学生学位论文的质量，做到学位论文在内容和格式上的规范化与统一化，特制作本模板。
      ],
      keywords: ("学位论文", "论文格式", "规范化", "模板"), //中文关键词
      abstract-en: [
        //英文摘要
        A dissertation is a primary manifestation of students' achievements
        in scientific research work and engineering practice.
        It systematically demonstrates the author's new inventions, theories or insights
        obtained through research and practice.
        It serves as an important basis for students to apply
        for bachelor's, master's or doctoral degrees,
        and is also an important literature resource
        in the scientific research field and a valuable asset to society.

        In order to improve the quality of students' dissertations
        and achieve standardization and unification of dissertations
        in both content and format, this template has been specially created.
      ],
      keywords-en: (
        //英文关键词
        "dissertation",
        "dissertation format",
        "standardization",
        "template",
      ),
      thanks-body: [
        //致谢
        首先，感谢李四老师在这次毕业论文中对我耐心而专业的指导，李四老师在论文写作流程和方法方面对我的教导让我受益匪浅，从而顺利完成本次毕业论文。我认为一篇论文不能代表我在电子信息工程方面的水平，更不应该止步于此，而是要学习李四老师不断学习的精神和勤奋求真的治学态度，在电子信息工程领域开拓进取，学以致用，成为该领域的人才，不负李四老师的谆谆教诲。

        其次，感谢本班学习委员和给我帮助的所有同学，班长和学习委员为我解答了很多我不熟悉的难题，很多同学也为我送来相关资料和论文写作技巧，让我体会到同学之间互帮互助、团结奋进的真挚友情，这种温暖、团结、进取的学习气氛，让我感动，让我一生铭记。

        最后感谢我的家人，是他们多年来对我学业的支持才让我走到这一步，才使我得以顺利完成学业。
      ],
    ),
    text-body,
  )

  /************正文************/
  #import "chapter_1.typ": *
  #import "chapter_2.typ": *
  #import "chapter_3.typ": *
  #import "chapter_4.typ": *
  #Chapter_one;//显示第一章内容
  #Chapter_two;//显示第二章内容
  #Chapter_three;//显示第三章内容
  #Chapter_four;//显示第四章内容
]

/****参考文献****/
#setup-bibliography("ref.bib")//不需要变动，直接把需要引用的文献导入到ref.bib文件
