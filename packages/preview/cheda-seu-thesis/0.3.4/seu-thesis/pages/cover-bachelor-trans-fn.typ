#import "../utils/packages.typ": fakebold
#import "../utils/fonts.typ": 字体, 字号, chineseunderline, justify-words

#let bachelor-trans-cover-conf(
  student-id: none,
  author: none,
  school: none,
  major: none,
  advisor: none,
  thesis-name-cn: none,
  thesis-name-raw: none,
  date: none,
) = page(
  paper: "a4",
  margin: (
    top: 2cm + 0.7cm,
    bottom: 2cm + 0.5cm,
    left: 2cm + 0.5cm,
    right: 2cm,
  ),
  {
    set text(lang: "zh")
    set par(leading: 0.65em, spacing: 1.2em, first-line-indent: 0pt)

    set align(center)
    //#hide[#heading(outlined: false, bookmarked: true)[封面]]

    image("../assets/vi/东南大学校标文字组合.png", width: 7.01cm)
    block(
      height: 2cm,
      {
        text(font: 字体.黑体, size: 字号.一号, tracking: 3.6pt, fakebold[本科毕业设计（论文）资料翻译])
      },
    )

    v(3pt)

    set text(font: 字体.宋体, size: 字号.三号)

    block(
      width: 100%,
      align(
        left,
        {
          h(1.7em) + [翻译资料名称（外文）]
        },
      ),
    )


    v(-6pt)

    block(
      height: 1.8cm,
      width: 100%,
      align(center + top, thesis-name-raw),
    )

    v(-6pt)

    block(
      width: 100%,
      align(
        left,
        {
          h(1.7em) + [翻译资料名称（中文）]
        },
      ),
    )

    v(-6pt)

    block(
      height: 1.8cm,
      width: 100%,
      align(center + top, thesis-name-cn),
    )

    v(49pt)

    set text(font: 字体.宋体, size: 字号.小二, weight: "regular")

    grid(
      columns: (5em, 10.3em),
      column-gutter: 2.6em,
      rows: 1.13cm,
      justify-words("学号", width: 4em) + "：", chineseunderline(student-id),
      justify-words("姓名", width: 4em) + "：", chineseunderline(author),
      justify-words("学院", width: 4em) + "：", chineseunderline(school),
      justify-words("专业", width: 4em) + "：", chineseunderline(major),
      justify-words("指导教师", width: 4em) + "：", chineseunderline(advisor),
      justify-words("起止日期", width: 4em) + "：", chineseunderline(date),
    )
  },
)

// 测试部分
#bachelor-trans-cover-conf(
  student-id: "00121001",
  author: "王东南",
  school: "示例学院",
  major: "示例专业",
  advisor: "湖牌桥",
  thesis-name-cn: "新兴排版方式下的摸鱼科学优化研究",
  thesis-name-raw: "Optimization of Fish-Touching Strategies \n in Emerging Typesetting Environments",
  date: "某个完成日期",
)
