#{
  import "@preview/unofficial-stu-bachelor-thesis:0.1.0": template-main
  /************正文************/
  let text-content = {
    include "chapter_1.typ"
    include "chapter_2.typ"
    include "chapter_3.typ"
    include "chapter_4.typ"
  }
  /************封面&模板设置************/
  show: template-main.with(
    (
      title: "汕头大学学位论文格式模板",
      //推荐使用下面的格式编写题目，因为设置了自动换行，使用下面的格式可以避免分行
      //title: ("基于Typst的", "汕头大学学位论文模板"),
      //如果确实需要单行书写，则可以使用下面的格式
      //title: ("汕头大学学位论文模板格式", ""),
      //但是这依旧会使得封面题目当中出现两条线，这是因为汕大的模板里面本身就是两条线的
      title-en: "Shantou University Dissertation Format Template",
      gradeandmajor: "电子信息工程　2021级",
      student-id: "2021123456",
      author: "张三",
      college: "工学院",
      department: "电子工程系",
      supervisor: "李四教授",
      //请从学校的Word模板里面提取校徽文件替换"figures/STU_logo.jpg"文件
      stu_logo: image(width: 5.51cm, height: 1.73cm, "figures/STU_logo.jpg"),
      //日期设置，默认使用当前日期，通过取消注释以更改生成的毕业论文日期
      //submit-date: datetime(year: 2026, month: 5, day: 2),

      /*摘要相关*/
      abstract: [
        //中文摘要
        学位论文是学生从事科研工作、工程实践的成果的主要表现，集中表明了作者在工作、实践中获得的新的发明、理论或见解，是学生申请学生、硕士或博士学位的重要依据，也是科研领域中的重要文献资料和社会的宝贵财富。

        为了提高学生学位论文的质量，做到学位论文在内容和格式上的规范化与统一化，特制作本模板。
      ],
      //中文关键词
      keywords: ("学位论文", "论文格式", "规范化", "模板"),
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

      //致谢，请在"acknowledgements.typ"文件里面写致谢
      acknowledgements: {
        include "acknowledgements.typ"
      },

      //参考文献参数传递，写作不需要管，只需要在"ref.bib"里面写上bib格式的参考文献即可
      bib: bibliography(
        style: "gb-7714-2005-numeric",
        title: none,
        "ref.bib",
      ),

      /***可选项(Optional Settings)***/
      //封面内容宽度。若出现封面内容超出横线，则可以尝试通过取消下面的注释尝试解决。
      //cover-width: 80%,

      //是否添加封底空白页，默认true，也就是默认添加封底空白页可以通过取消下面的注释来去掉封底空白页。
      //add-back-cover: false,

      //是否添加授权使用说明页，默认值是false，也就是不添加授权使用说明页，通过取消注释以添加授权使用说明页。
      //generate-auth-use-page: true,
    ),
  )
  text-content
}
