#import "components/cover.typ": cover
#import "components/abstract.typ" as a
#import "components/outline.typ": outline
#import "components/acknowledgments.typ": acknowledgments as acks
#import "utils/style.typ": apply-style, global-style
#import "utils/fonts.typ": fonts as default-fonts, setup-fonts
#import "@preview/valkyrie:0.2.2" as z

#let info-schema = z.dictionary((
  title: z.dictionary((
    zh: z.either(z.string(), z.array(z.string())),
    en: z.string(),
  )),
  author: z.dictionary((
    name: z.string(),
    id: z.string(),
  )),
  advisor: z.string(),
  college: z.string(),
  department: z.string(),
  abstract: z.dictionary((
    zh: z.any(),
    en: z.any(),
  )),
  keywords: z.dictionary((
    zh: z.array(z.string()),
    en: z.array(z.string()),
  )),
  bibliography: z.any(),
  acknowledgments: z.any(),
))

#let project(
  title: (:),
  author: (name: "", id: ""),
  advisor: "",
  college: "",
  department: "",
  abstract: (:),
  keywords: (:),
  fonts: default-fonts,
  bibliography: "",
  acknowledgments: [],
  body,
) = {
  let _ = z.parse(
    (
      title: title,
      author: author,
      advisor: advisor,
      college: college,
      department: department,
      abstract: abstract,
      keywords: keywords,
      bibliography: bibliography,
      acknowledgments: acknowledgments,
    ),
    info-schema,
  )

  // 把传入的纯字体名称转换为带有中西文 fallback 配置的实际可用字体数组
  let fonts = default-fonts + fonts
  let resolved-fonts = setup-fonts(fonts)

  let title-str = (zh: if type(title.zh) == str { title.zh } else { title.zh.join() }, en: title.en)

  set document(
    title: title-str.zh,
    author: author.name,
    keywords: keywords.zh,
    description: abstract.zh,
  )

  // 封面
  cover(
    title: title.zh,
    name: author.name,
    id: author.id,
    advisor: advisor,
    college: college,
    department: department,
    fonts: resolved-fonts,
  )

  // 全局样式
  show: global-style.with(fonts: resolved-fonts)

  // 摘要
  a.abstract(
    title: title-str,
    abstract: abstract,
    keywords: keywords,
    fonts: resolved-fonts,
  )

  // 目录
  outline()

  // 正文样式与内容
  show: apply-style.with(title: title-str.zh)


  body

  pagebreak(weak: true)

  std.bibliography(bytes(bibliography), style: "gb-7714-2015-numeric", full: true)

  acks(acknowledgments)
}
