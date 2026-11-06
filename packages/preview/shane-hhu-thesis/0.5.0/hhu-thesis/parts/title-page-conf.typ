#import "../utils/utils.typ": fakebold, ziti, zihao, chineseunderline, fieldname, fit-in,  label-content-grid

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
    CN: [植物对泥沙沉降规律的影响研究],
    EN: [Study on the influence of plants on \ sediment deposition],
  ),
  school: (
    CN: "河海大学",
    EN: "Hohai University",
  ),
  subject: "subject",
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
          label-content-grid(
            (
              ("学号", author.ID),
              ("年级", author.YEAR),
            ),
            align: center,
            row-gutter: 15pt,
            spliter-width: 3pt,
            min-content-width: 80pt,
            label-style: (content) => {
              text(font: ziti.黑体, size: zihao.五号, weight: "regular")[#fit-in(content)]
            },
            content-style: (content) => {
              text(font: ziti.黑体, size: zihao.五号, weight: "regular")[#chineseunderline(content)]
            },
          )
        },
      )

      v(265pt)

      block(
        height: 100% - 277.3pt,
        grid(
        rows: (auto, 1.8cm, auto, 1fr, auto, 1fr, auto, 1fr, auto),
        // 大标题：如本科毕业论文
        block(fakebold(text(
          font: ziti.宋体,
          size: zihao.一号,
          thesis-name.CN
        ))),
        // 空间
        [],
        // 标题
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
          set text(font: ziti.宋体, size: zihao.小三, weight: "regular")
          set underline(offset: 5pt)
          set place(dy: -0.2em, center)
          label-content-grid(
            (
              ("专业", major),
              ("姓名", author.CN),
              ("指导教师", advisors.CN),
              ("评阅人", reader),
            ),
            align: center,
            row-gutter: 1.5em,
            spliter-width: 0.2em,
            min-label_width: 4em,
            min-content-width: 10em,
            label-style: (content) => {
              text(font: ziti.黑体, size: zihao.小三, weight: "bold")[#fit-in(content)]
            },
            content-style: (content) => {
              [#chineseunderline(content)]
            },
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
    CN: [植物对泥沙沉降规律的影响研究],
    EN: [Study on the influence of plants on sediment deposition],
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

    set text(font: ziti.宋体, size: zihao.四号, weight: "regular")
    set align(center)
    label-content-grid(
      (
        ("College", school.EN),
        ("Subject", subject),
        ("Name", author.EN),
        ("Directed by", advisors.EN),
      ),
        align: (right, center, left),
        row-gutter: 1.5em,
        spliter: ":",
        spliter-width: 1em,
        min-label_width: 0em,
        min-content-width: 8em,
      )
    v(1cm)

    block(text(font: "Times New Roman", size: zihao.小二, weight: "regular", "NANJING CHINA"))
  },
)
