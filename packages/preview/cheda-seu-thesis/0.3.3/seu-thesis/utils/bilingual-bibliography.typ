// Authors: csimide, OrangeX4
// Tested only on GB-7714-2015-Numeric

#let bilingual-bibliography(
  mapping: (:),
  cont,
) = {
  // Please fill in the remaining mapping table here
  mapping = (
    //"等": "et al",
    "卷": "Vol.",
    "册": "Bk.",
    // "译": "tran",
    // "等译": "et al. tran",
    // 注: 请见下方译者数量判断部分。
  ) + mapping

  let to-string(content) = {
    if content.has("text") {
      content.text
    } else if content.has("children") {
      content.children.map(to-string).join("")
    } else if content.has("child") {
      to-string(content.child)
    } else if content.has("body") {
      to-string(content.body)
    } else if content == [ ] {
      " "
    }
  }

  show grid.cell.where(x: 1): it => {
    // 后续的操作是对 string 进行的。
    let ittext = to-string(it)
    // 判断是否为中文文献：去除特定词组后，仍有至少两个连续汉字。
    let pureittext = ittext.replace(
      regex("[等卷册和版本章期页篇译间者(不详)]"),
      "",
    )
    if pureittext.find(regex("\p{sc=Hani}{2,}")) != none {
      ittext
    } else {
      // 若不是中文文献，进行替换
      // 第xxx卷、第xxx册的情况：变为 Vol. XXX 或 Bk. XXX。
      let reptext = ittext
      reptext = reptext.replace(
        regex("(第\s?)?\d+\s?[卷册]"),
        itt => {
          if itt.text.contains("卷") {
            "Vol. "
          } else {
            "Bk. "
          }
          itt.text.find(regex("\d+"))
        },
      )

      // 第xxx版/第xxx本的情况：变为 1st ed 格式。
      reptext = reptext.replace(
        regex("(第\s?)?\d+\s?[版本]"),
        itt => {
          let num = itt.text.find(regex("\d+"))
          num
          if num.clusters().len() == 2 and num.clusters().first() == "1" {
            "th"
          } else {
            (
              "1": "st",
              "2": "nd",
              "3": "rd",
            ).at(num.clusters().last(), default: "th")
          }
          " ed"
        },
      )

      // 译者数量判断：单数时需要用 trans，复数时需要用 tran 。
      /*
      注:
      1. 目前判断译者数量的方法非常草率，有逗号就是多个作者。但是在部分 GB/T 7714-2015 方言中，姓名中可以含有逗号。
      2. 在 GB/T 7714-2015 原文中有 `等译`（P15 10.1.3 小节 示例 1-[1]），但未给出相应的英文缩写翻译。
      3. CSL 社区库内的 GB/T 7714-2015 会使用 `等, 译` 和 `et al., tran` 的写法。为了保证统一性，这里会译作不带逗号的版本，即 `et al. tran`
      如果工作不正常，可以考虑换为简单关键词替换，即注释这段情况，取消 13 行 mapping 内 `译` 条目的注释。
      */
      reptext = reptext.replace(
        regex("\].+?译"),
        itt => {
          // 我想让上面这一行匹配变成非贪婪的，但加问号后没啥效果？
          if itt.text.replace(regex(",\s?译"), "").find(",") != none {
            itt.text.replace(regex(",?\s?译"), " tran")
          } else {
            itt.text.replace(regex(",?\s?译"), " trans")
          }
        },
      )

      // `等` 特殊处理：`等`后方接内容也需要译作 `et al.`，如 `等译` 需要翻译为 `et al. trans`
      reptext = reptext.replace(
        regex("等."),
        itt => {
          "et al."
          // 如果原文就是 `等.`，则仅需简单替换，不需要额外处理
          // 如果原文 `等` 后没有跟随英文标点，则需要补充一个空格
          if not itt.text.last() in (
            ".",
            ",",
            ";",
            ":",
            "[",
            "]",
            "/",
            "\\",
            "<",
            ">",
            "?",
            "(",
            ")",
            " ",
            "\"",
            "'",
          ) {
            " "
          }
          // 原文有英文句号时不需要重复句号，否则需要将匹配到的最后一个字符吐回来
          if not itt.text.last() == "." {
            itt.text.last()
          }
        },
      )

      // 其他情况：直接替换
      reptext = reptext.replace(
        regex("\p{sc=Hani}+"),
        itt => {
          mapping.at(itt.text, default: itt.text)
          // 注意：若替换功能工作良好，应该不会出现 `default` 情形
        },
      )
      reptext
    }
  }

  set text(lang: "zh")
  cont
}

#let show-bibliography(
  mapping: (:),
  bilingual: true,
  it,
) = {
  set bibliography(title: none)
  show bibliography: it => {
    heading(
      bookmarked: true,
      outlined: true,
      numbering: none,
      level: 1,
    )[参考文献]
    if bilingual {
      bilingual-bibliography(mapping: mapping, it)
    } else {
      it
    }
  }
  it
}