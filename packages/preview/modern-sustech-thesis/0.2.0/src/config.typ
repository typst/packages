#import "util.typ": *
#import "component.typ": *
#import "style.typ": *

// Binding config to elements. {{{
#let bind-config(
  conf: none,
  trans: none,
) = {
  (
    // Util arguments. {{{
    fig-sizes: fig-sizes,
    // }}}
    // Element functions. {{{
    figures: figures,
    title-page: title-page.with(
      conf: conf,
      trans: trans,
    ),
    abstract: abstract.with(
      conf: conf,
      trans: trans,
    ),
    // }}}
    // Styles. {{{
    generic-style: generic.with(
      conf: conf,
      trans: trans,
    ),
    front-matter-paginated-style: front-matter-paginated.with(
      conf: conf,
    ),
    body-matter-style: body-matter.with(
      conf: conf,
    ),
    appendix-style: appendix.with(
      conf: conf,
    ),
    attachment-style: post-appendix,
    // }}}
    // Components. {{{
    cover: cover(
      conf: conf,
      trans: trans,
    ),
    reviewers-n-committee: reviewers-n-committee(
      conf: conf,
      trans: trans,
    ),
    declarations: declarations(
      conf: conf,
      trans: trans,
    ),
    outline: toc(
      conf: conf,
    ),
    conclusion: heading-conclusion(
      conf: conf,
    ),
    // }}}
  )
}
// }}}

// Processing config from user. {{{

/// 根据配置生成论文组件。
///
/// = 用法
/// 建议按照模版操作，而不要自己从头开始写。
///
/// + 按照说明填写参数；默认值正确的，或不需要的，可以不填
/// + 将返回值赋给变量，以便后续使用
///
/// == 有翻译的参数
/// 部分参数，如 `candidate`（作者姓名），可能需要翻译。凡是注明“必须是 `语言: 内容` 条目组”的都如此。
/// ```typc
/// setup(
///   candidate: (
///     zh: "鲁迅",
///     en: "Lu Xun",
///   ),
///   // ...
/// )
/// ```
///
/// 某参数可能有翻译，但此时不需要的，可以省去对应语言的条目。
/// ```typc
/// setup(
///   candidate: (
///     zh: "鲁迅",
///   ),
///   // ...
/// )
/// ```
///
/// = 原理
/// 此函数返回一字典，包含各个文档组件。用户用解构赋值（destructure）创建对应变量，参见 #link("https://typst.app/docs/reference/scripting/#bindings")
///
/// 此函数“告诉”旗下各函数“用户需要你们怎么做”，用户就可以直接调用这些函数，或取用它们的结果，省去填写繁复参数的步骤。
///
/// 将此函数的返回值输出到成品（如利用 `repr`、`raw`），就能看到它生成了哪些组件。
///
/// = 示例
/// ```example
/// #let (
///   cover,
///   title-page,
///   // ...
/// ) = setup(
///   title: (
///     zh: [狂人日记],
///     en: [Diary of a Madman],
///   ),
///   candidate: (
///     zh: "鲁迅",
///     en: "Lu Xun",
///   ),
///   // ...
/// )
/// ```
///
/// - trans (dictionary): 覆盖内置翻译，而又被其他参数覆盖；大概不需要动这个
/// - lang (str): 语言，必须是 `text.lang` 支持的二字代码
/// - region (auto, str): 语言的地区，必须是 `auto` 或 `text.region` 支持的二字代码；如果语言是 `"zh"` 或 `"en"` 且没有声明地区，会自动变为 `"cn"` 和 `"us"`
/// - distribution (str): 分发形式，电子版（`"digital"`）还是打印版（`"printed"`）
/// - title (dictionary): 标题，必须是 `语言: 内容` 条目组
/// - display-title (auto, dictionary): 显示的标题，必须是 `auto` 或 `语言: 内容` 条目组；研究生、博士论文可以用此让英文标题显示小写字母、非字符符号等
/// - subtitle (dictionary): 副标题，必须是 `语言: 内容` 条目组
/// - display-subtitle (auto, dictionary): 显示的副标题，必须是 `auto` 或 `语言: 内容` 条目组
/// - keywords (array): 关键词
/// - candidate (dictionary): 作者姓名，必须是 `语言: 内容` 条目组
/// - supervisor (dictionary): 指导教师姓名与职称，必须是 `语言: 内容` 条目组；同 “advisor”
/// - associate-supervisor (dictionary): 副指导教师姓名与职称，必须是 `语言: 内容` 条目组；本科论文中无效
/// - department (dictionary): 院系，必须是 `语言: 内容` 条目组
/// - degree (str): 学位，必须是 `"bachelor"`、`"master"`、`"doctor"` 之一
/// - degree-type (str): 学位类型，必须是 `"academic"`、`"professional"` 之一
/// - discipline (dictionary): 专业，必须是 `语言: 内容` 条目组
/// - domain (dictionary): 专业类型，必须是 `语言: 内容` 条目组；本科论文中无效
/// - print-date (datetime): 打印日期，同成文日期；研究生、博士论文中，“日”无效
/// - defence-date (datetime): 答辩日期；本科论文中不生效；研究生、博士论文中，日不生效
/// - clc (str): 中国图书馆分类编码
/// - udc (str): 通用十进制图书分类编码
/// - cuc (str): 中国大学代码，默认为南方科技大学的代码；本科论文中无效
/// - thesis-number (str): 论文编号；仅在本科论文中有效
/// - student-number (str): 学号；仅在本科论文中有效
/// - confidentiality (str): 密级；如为公开，必须是 `"公开"`
/// - publication-delay (none, int): 公开前的延迟；`none` 是立即公开，中文版中作_年_，英文版中作_月_；本科论文中无效
/// - reviewers (array, none): 公开评审人，`none` 是全隐名评审，每一项必须是如 `(name: 姓名, title: 职称, institute: 机构)` 的 `dictionary`，或同顺序的 `array`；本科论文中无效
/// - committee (array, none): 答辩委员会，每一项必须是如 `(position: 会职, name: 姓名, title: 职称, institute: 机构)` 的 `dictionary`，或同顺序的 `array`
/// - bibliography-style (str): 参考文献样式，必须是 `"numeric"`、`"author-date"` 之一，或 `bibliography.style` 支持的样式；“numeric” 对应2015版国标的顺序样式，“author-date” 则对应作者–日期样式；如选则非国标样式，则须自己设置 `cite.style`，否则引用的上标还会是国标样式
/// - description (str, none): 文件描述，文件即生成的 PDF；不是论文中出现的摘要
/// - binding-guide (bool): 是否显示装订引导线；仅在打印版本科论文中生效
/// -> dictionary
#let setup(
  trans: (:),
  lang: "zh",
  region: auto,
  distribution: "digital",
  title: none,
  display-title: auto,
  subtitle: none,
  display-subtitle: auto,
  keywords: none,
  candidate: none,
  supervisor: none,
  associate-supervisor: none,
  department: none,
  degree: "bachelor",
  degree-type: "academic",
  discipline: none, // Academic
  domain: none, // Professional
  print-date: none,
  defence-date: none,
  clc: none, // Chinese Library Classificantion
  udc: none, // Universal Decimal Classificantion
  cuc: "14325", // Chinese University Code
  thesis-number: none, // Only seen on bachelor's cover
  student-number: none, // Only on bachelor's cover
  confidentiality: "公开",
  publication-delay: none,
  reviewers: none,
  committee: none,
  bibliography-style: "numeric",
  // Extra...
  description: none,
  binding-guide: true,
) = {
  let (lang, region) = args-lang(lang, region).named()
  let professional = degree-type == "professional"
  let bachelor = degree == "bachelor"
  let master = degree == "master"
  let doctor = degree == "doctor"
  let print = distribution == "printed"
  let bibliography-style = if bibliography-style == "numeric" {
    "./gb-t-7714-2015-numeric.hayagriva-0.9.1.csl"
  } else if bibliography-style == "author-date" {
    "./gb-t-7714-2015-author-date.hayagriva-0.9.1.csl"
  } else {
    bibliography-style
  }

  bind-config(
    conf: (
      lang: lang,
      region: region,
      distribution: distribution,
      degree: degree,
      degree-type: degree-type,
      print-date: print-date,
      defence-date: defence-date,
      clc: clc,
      udc: udc,
      cuc: cuc,
      thesis-number: thesis-number,
      student-number: student-number,
      confidentiality: confidentiality,
      publication-delay: publication-delay,
      reviewers: firstof(reviewers, default: ()),
      committee: firstof(committee, default: ()),
      bibliography-style: bibliography-style,
      description: description,
      // Util
      professional: professional,
      bachelor: bachelor,
      master: master,
      doctor: doctor,
      print: print,
      binding-guide: binding-guide,
    ),
    trans: {
      let base = merge-dicts(trans-default, trans)
      let expl = (
        title: to-dict(title),
        display-title: firstconcrete(
          display-title,
          (:),
          ts: infer-display-title.with(
            title,
            bachelor: bachelor,
          ),
        ),
        subtitle: to-dict(subtitle),
        display-subtitle: firstconcrete(
          display-subtitle,
          (:),
          ts: infer-display-title.with(
            subtitle,
            bachelor: bachelor,
          ),
        ),
        keywords: to-dict(keywords),
        candidate: to-dict(candidate),
        supervisor: to-dict(supervisor),
        associate-supervisor: to-dict(associate-supervisor),
        department: to-dict(department),
        discipline: to-dict(discipline),
        domain: to-dict(domain),
      )
      for l in base.keys() {
        base.at(l) += take-lang(expl, l)
      }
      base
    },
  )
}
// }}}

