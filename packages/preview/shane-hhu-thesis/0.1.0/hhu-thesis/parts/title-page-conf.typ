#import "../utils/utils.typ": fakebold, ziti, zihao, chineseunderline, fieldname

// 中文封面配置
#let title-cn-conf(
  author: (CN: "李华", EN: "Li Hua", ID: "2162510220", YEAR: "2021级"),
  advisors: (
    CN: "张三",
    EN: "Zhang San"
  ),
  thesis-name: (
    CN: "本科毕业论文",
    EN: [
      BACHELOR'S DEGREE THESIS \
      OF HOHAI UNIVERSITY
    ],
    heading: "河海大学本科毕业论文"
  ),
  title: (
    CN: "植物对泥沙沉降规律的影响研究",
    EN: "Study on the influence of plants on sediment deposition",
  ),
  school: (
    CN: "河海大学",
    EN: "Hohai University",
  ),
  subject: "Here is the subject",
  major: "自动化",
  reader: "李四 副教授",
  date: "二〇二四年五月",
) = {
  page(
    margin: (top: 2cm, bottom: 2cm, left: 3.2cm, right: 3.2cm),
    numbering: none,
    header: none,
    footer: none,
    {
      set text(font: ziti.宋体, size: zihao.小四, weight: "regular", lang: "zh")
      set align(center + top)
      set par(first-line-indent: 0pt)

      place(
        top + center,
        dy: 4.8cm,
        {
          image("../assets/HHU-Logo.png", width: 11cm)
        },
      )

      place(
        top + right,
        dy: 2cm,
        dx: -2cm,
        {
          set text(
            font: ziti.黑体,
            size: zihao.五号,
            weight: "regular",
            lang: "zh",
            region: "cn",
          )
          set align(center)
          grid(
            columns: (2em, 8em),
            row-gutter: 1em,
            "学号",
            chineseunderline(author.ID),
            "年级",
            chineseunderline(author.YEAR),
          )
        },
      )

      v(265pt)

      block(
        height: 100% - 277.3pt,
        grid(
        rows: (auto, 1.8cm, auto, 1fr, auto, 1fr, auto, 1fr, auto),
        // 大标题，如“硕士学位论文”
        block(fakebold(text(
          font: ziti.宋体,
          size: zihao.一号,
          thesis-name.CN
        ))),
        // 空间
        [],
        // 标题 + 学位论文形式
        {
          block(text(
            font: ziti.黑体,
            size: zihao.二号,
            weight: "bold",
            title.CN
          ))
        },
        // 空间
        [],
        // 下方内容
        {
          // let term = fieldvalue.with(style : ziti.仿宋, size : zihao.小三) 
          // TODO: Better way to justify words
          // let justify-4em(s) = justify-words(s, width: 4em)
          set text(font: ziti.宋体, size: zihao.小三, weight: "regular")
          grid(
            columns: (5em, 0.2em, 10em),
            row-gutter: 1em,
            fieldname([专#h(2em)业], bold: true), "", chineseunderline(major),
            fieldname([姓#h(2em)名], bold: true), "", chineseunderline(author.CN),
            fieldname([指导教师], bold: true), "", chineseunderline(advisors.CN),
            fieldname([评#h(0.5em)阅#h(0.5em)人], bold: true), "", chineseunderline(reader),
          )
        },
        // 空间
        [],
        // 日期和地点
        grid(
          rows: 2,
          gutter: 16pt,  // 可以调整行间距
          [#text(
            font: ziti.黑体,
            size: zihao.三号,
            weight: "bold",
            date
          )],
          [#text(
            font: ziti.黑体,
            size: zihao.三号,
            weight: "bold",
            "中国      南京"
          )]
        )
      ),
      )
    },
  )
}

// 英文封面配置
#let title-en-conf(
  author: (CN: "李华", EN: "Li Hua", ID: "2162510220", YEAR: "2021级"),
  advisors: (
    CN: "张三",
    EN: "Zhang San"
  ),
  thesis-name: (
    CN: "本科毕业论文",
    EN: [
      BACHELOR'S DEGREE THESIS \
      OF HOHAI UNIVERSITY
    ],
    heading: "河海大学本科毕业论文"
  ),
  title: (
    CN: "植物对泥沙沉降规律的影响研究",
    EN: "Study on the influence of plants on sediment deposition",
  ),
  school: (
    CN: "河海大学",
    EN: "Hohai University",
  ),
  subject: "Here is the subject",
  major: "自动化",
  reader: "李四 副教授",
  date: "二〇二四年五月",
) = page(
  margin: (top: 4cm, bottom: 2cm, left: 3.2cm, right: 3.2cm),
  numbering: none,
  header: none,
  footer: none,
  {
    set par(first-line-indent: 0pt)
    set align(center)

    set par(leading: 1em)
    block(text(font: "Times New Roman", size: zihao.二号, weight: "bold", upper(thesis-name.EN)))

    v(1.8cm)

    set text(font: "Times New Roman", size: zihao.二号, weight: "bold")
    set block(spacing: 1.8cm)

    block(text(font: "Times New Roman", size: zihao.二号, weight: "bold", title.EN))

    v(3cm)

    set text(font: ziti.宋体, size: zihao.小三, weight: "regular")
    grid(
      columns: (5em, 1em, 10em),
      row-gutter: 1.5em,
      fieldname([College]), ":", school.EN,
      fieldname([Subject]), ":", subject,
      fieldname([Name]), ":", author.EN,
      fieldname([Directed by]), ":", advisors.EN,
    )

    v(1cm)

    block(text(font: "Times New Roman", size: zihao.小二, weight: "regular", "NANJING CHINA"))
  },
)

// // TODO: 合并默认配置
// #title-cn-conf(
//   author: (CN: "王东南", EN: "WANG Dong-nan", ID: "012345", YEAR: "2021级"),
//   advisors: (CN: "湖牌桥", EN: "HU Pai-qiao"),
//   thesis-name: (
//     CN: "本科毕业论文",
//     EN: [
//       BACHELOR'S DEGREE THESIS \
//       OF HOHAI UNIVERSITY
//     ],
//     heading: "河海大学本科毕业论文",
//   ),
//   title: (
//     CN: "植物对泥沙沉降规律的影响研究",
//     EN: "Study on the influence of plants on sediment deposition",
//   ),
//   subject: "this is the subject",
//   school: (CN: "河海大学", EN: "Hohai University"),
//   major: "自动化",
//   date: "二〇二四年五月",
// )
// 
// #title-en-conf(
//   author: (CN: "王东南", EN: "WANG Dong-nan", ID: "012345", YEAR: "2021级"),
//   advisors: (
//     CN: "湖牌桥",
//     EN: "HU Pai-qiao"
//   ),
//   thesis-name: (
//     CN: "本科毕业论文",
//     EN: [
//       BACHELOR'S DEGREE THESIS \
//       OF HOHAI UNIVERSITY
//     ],
//     heading: "河海大学本科毕业论文",
//   ),
//   title: (
//     CN: "植物对泥沙沉降规律的影响研究",
//     EN: "Study on the influence of plants on sediment deposition",
//   ),
//   subject: "this is the subject",
//   reader: "审稿人",
//   school: (CN: "河海大学", EN: "Hohai University"),
//   major: "自动化",
//   date: "二〇二四年五月",
// )
