#import "components/cover.typ": cover
#import "components/abstract.typ" as a
#import "components/outline.typ": outline
#import "components/acknowledgments.typ": acknowledgments as acks
#import "utils/style.typ": apply-style, global-style
#import "utils/fonts.typ": fonts as default-fonts, setup-fonts
#import "@preview/valkyrie:0.2.2" as z
#import "@preview/gb7714-bilingual:0.2.3": gb7714-bibliography, init-gb7714, multicite

#let info-schema = z.dictionary((
  title: z.dictionary((
    zh: z.either(z.string(), z.array(z.string())),
    en: z.string(),
  )),
  author: z.dictionary((
    name: z.string(),
    id: z.string(),
  )),
  advisor: z.either(z.string(), z.array(z.string())),
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
  bibliography: "",
  acknowledgments: [],
  config: (:),
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
  let fonts = default-fonts + config.at("fonts", default: (:))
  let resolved-fonts = setup-fonts(fonts)

  let title-str = (zh: if type(title.zh) == str { title.zh } else { title.zh.join() }, en: title.en)

  set document(
    title: title-str.zh,
    author: author.name,
    keywords: keywords.zh,
    description: abstract.zh,
  )

  // 全局样式
  show: global-style.with(fonts: resolved-fonts)

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
  show: apply-style.with(
    title: title-str.zh,
    chap-num-config: config.at("numbering", default: ()),
  )
  show: init-gb7714.with(bytes(bibliography), style: "numeric", version: "2015")

  body

  pagebreak(weak: true)

  gb7714-bibliography(full: false)

  acks(acknowledgments)
}
