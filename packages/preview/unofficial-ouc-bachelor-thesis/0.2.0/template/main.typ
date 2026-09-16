#import "@preview/unofficial-ouc-bachelor-thesis:0.2.0": project

#show: project.with(
  title: (
    zh: ("城市空气质量时空分布特征", "及其影响因素分析"),
    en: "The Practice of Dance Based on Singing, Dancing, Rapping and Basketball",
  ),
  author: (name: "蔡徐坤", id: "123456789"),
  advisor: ("唱跳导师", "篮球导师"),
  college: "信息科学与工程学院",
  department: "计算机科学与技术2017级",
  abstract: (
    zh: [
      关于这个事，我简单说两句，你明白就行，总而言之这个事呢，现在就是这个情况，具体的呢，大家也都看得到，也得出来说那么几句，可能你听的不是很明白，但是意思就是那么个意思，不知道的你也不用去猜，这种事情见得多了，我只想说懂得都懂，不懂的我也不多解释，毕竟自己知道就好，细细品吧。
    ],
    en: [
      #lorem(100)
    ],
  ),
  keywords: (
    zh: ("关于这个事", "我简单说两句", "你明白就行"),
    en: ("lorem ipsum", "dolor sit amet", "consectetur adipiscing elit"),
  ),
  bibliography: read("references.bib"),
  acknowledgments: [
    在论文的最后我想向所有帮助支持过我的亲人、朋友、老师致以崇高的敬意和真诚的感谢，感谢你们在我的学习和科研中给予的生活和工作的支持。

    这段时光中，我要特别感谢指导老师在选题、研究方法和论文写作上的悉心指导；感谢同学和朋友在我碰到问题时给予帮助；最后特别感谢我的父母，感谢你们对我学习生涯的支持与鼓励。
  ],
  config: (
    fonts: (
      宋体: "SimSun",
      黑体: "SimHei",
      楷体: "KaiTi",
      仿宋: "FangSong",
      西文: "Times New Roman",
      等宽: ("Consolas", "Courier New", "Liberation Mono", "Noto Sans Mono CJK SC", "Noto Sans Mono", "SimSun"),
    ),
    numbering: (
      (figure.where(kind: raw), figure, "1-1"),
      (figure.where(kind: "algorithm"), figure, "1-1"),
    ),
  ),
)

= 绪论

#include "chapters/01-basic-syntax.typ"

= 使用指南

#include "chapters/02-user-guide.typ"
