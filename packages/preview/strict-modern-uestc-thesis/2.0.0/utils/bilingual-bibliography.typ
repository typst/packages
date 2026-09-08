// ref: https://github.com/nju-lug/modern-nju-thesis/issues/3
// ref: https://github.com/TideDra/seu-thesis-typst
// ref: https://github.com/citation-style-language/styles/blob/master/china-national-standard-gb-t-7714-2015-numeric.csl
// Author: csimide, OrangeX4
// Tested only on GB-7714-2015-Numeric

#let citation-replace(it, 
                      allow-comma-in-name: false, 
                      extra-comma-before-et-al-trans: false,
                      mapping: (:)) = {
  mapping = (
    (
      //"等": "et al",
      "卷": "Vol.",
      "册": "Bk.",
      // "译": ", tran",
      // "等译": "et al. tran",
      // 注: 请见下方译者数量判断部分。
    )
      + mapping
  )

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
  let ittext = to-string(it)
  // 判断是否为中文文献：去除特定词组后，仍有至少两个连续汉字。
  let pureittext = ittext.replace(regex("[等卷册和版本章期页篇译间者(不详)]"), "")
  if pureittext.find(regex("\p{sc=Hani}{2,}")) != none {
    ittext
  } else {
    // 若不是中文文献，进行替换
    // 第xxx卷、第xxx册的情况：变为 Vol. XXX 或 Bk. XXX。
    let reptext = ittext
    reptext = reptext.replace(
      regex("(第\s?)?\d+\s?[卷册]"),
      itt => {
        if itt.text.contains("卷") { "Vol. " } else { "Bk. " }
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
          ("1": "st", "2": "nd", "3": "rd").at(num.clusters().last(), default: "th")
        }
        " ed"
      },
    )

    // 译者数量判断：单数时需要用 trans，复数时需要用 tran 。
    /*
    注:
        1. 目前判断译者数量的方法非常草率：有逗号就是多个作者。但是在部分 GB/T 7714-2015 方言中，姓名中可以含有逗号。如果使用的 CSL 是姓名中含有逗号的版本，请将 bilingual-bibliography 的 allow-comma-in-name 参数设为 true。
        2. 在 GB/T 7714-2015 原文中有 `等译`（P15 10.1.3 小节 示例 1-[1] 等），但未给出相应的英文缩写翻译。CSL 社区库内的 GB/T 7714-2015 会使用 `等, 译` 和 `et al., tran` 的写法。为使中英文与标准原文写法一致，本小工具会译作 `et al. tran`。若需要添加逗号，请将 bilingual-bibliography 的 extra-comma-before-et-al-trans 参数设为 true。
        3. GB/T 7714-2015 P8 7.2 小节规定：“译”前需加逗号。因此单个作者的情形，“译” 会被替换为 ", trans"。与“等”并用时的情况请见上一条注。
        如果工作不正常，可以考虑换为简单关键词替换，即注释这段情况，取消 13 行 mapping 内 `译` 条目的注释。
    */
    reptext = reptext.replace(
      regex("\].+?译"),
      itt => {
        // 我想让上面这一行匹配变成非贪婪的，但加问号后没啥效果？
        let comma-in-itt = itt.text.replace(regex(",?\s?译"), "").matches(",")
        if (type(comma-in-itt) == array and comma-in-itt.len() >= (if allow-comma-in-name { 2 } else { 1 })) {
          if extra-comma-before-et-al-trans {
            itt.text.replace(regex(",?\s?译"), ", tran")
          } else {
            itt.text.replace(regex(",?\s?译"), " tran")
          }
        } else {
          itt.text.replace(regex(",?\s?译"), ", trans")
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
        if not itt.text.last() in (".", ",", ";", ":", "[", "]", "/", "\\", "<", ">", "?", "(", ")", " ", "\"", "'") {
          " "
        }
        // 原文有英文句号时不需要重复句号，否则需要将匹配到的最后一个字符吐回来
        if not itt.text.last() == "." { itt.text.last() }
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

#let bilingual-bibliography(
  body: none,
  title: "参考文献",
  full: false,
  // style: "gb-7714-2015-numeric",
  style: "cite-style.csl",
  mapping: (:),
  extra-comma-before-et-al-trans: false,
  // 用于控制多位译者时表现为 `et al. tran`(false) 还是 `et al., tran`(true)
  allow-comma-in-name: false,
  // 如果使用的 CSL 中，英文姓名中会出现逗号，请设置为 true
) = {

  show grid.cell.where(x: 1): it => {
    citation-replace(it, mapping: mapping, allow-comma-in-name: allow-comma-in-name,
                     extra-comma-before-et-al-trans: extra-comma-before-et-al-trans)
  }

  set text(lang: "zh")
  bibliography(body, title: title, full: full, style: style)
}

#let achievement-list(
  bib-path,
  title: none,
  items: (),
  highlight-names: (),
  mapping: (:),
  style: "cite-style.csl" 
) = {
  // 1. 预处理
  import "@preview/alexandria:0.2.2": *
  show: alexandria(prefix: "__your_work__:", read: path => read(path))
  items = if type(items.at(0)) == array { items } else { (items,) }
  let citations = items.map(it => cite(label("__your_work__:" + str(it.at(0))))).join()
  let entry-counter = counter("achievement-entry")
  entry-counter.update(0)
  let highlight-names = if type(highlight-names) == array {
      highlight-names
    } else {
      (highlight-names,)
    }
  // 4. 核心拦截逻辑
  show grid.cell.where(x: 1): it => {
    // 计数器步进 (这是 State 更新，必须在 Context 外面)
    entry-counter.step()
    
    // 【关键修改】：从这里开始进入 context，直到返回最终内容
    // 所有依赖 idx 的逻辑都在这个大括号里完成
    context {
      // 获取索引
      let idx = entry-counter.get().first() - 1
      // 获取数据 (现在是在 context 内部，可以直接拿到 array)
      let item-data = if idx < items.len() { items.at(idx) } else { none }

      // --- 字符串清洗逻辑 ---
      let reptext = citation-replace(it)
      // -------------------

      let highlighted-body = {
        // 1. 转义特殊字符
        let escape-regex(s) = s.replace(regex("[.\\+*?^$()\[\]{}|]"), m => "\\" + m.text)
        
        // 2. 准备名字列表 (长度降序)
        let sorted-names = highlight-names.sorted(key: it => it.len()).rev()
        
        if sorted-names.len() > 0 {
          // 3. 构建正则对象 (必须使用 regex() 包裹)
          let names-pattern = sorted-names.map(escape-regex).join("|")
          // 捕获组: (1:前缀) (2:名字) (3:后缀)
          let re = regex("(^|\s)(" + names-pattern + ")(,|\.)")
          
          // 4. 使用 matches 获取所有匹配，然后取第一个
          // 这样能确保我们拿到的是 match 对象而不是 int 或 string
          let all-matches = reptext.matches(re)
          
          if all-matches.len() > 0 {
            let m = all-matches.first() // 只取第一个匹配
            
            // 5. 使用 match 对象的属性进行切片
            let pre-text = reptext.slice(0, m.start)
            let post-text = reptext.slice(m.end, reptext.len())
            
            let caps = m.captures
            let prefix = caps.at(0) // 对应的 (^|\s)
            let name = caps.at(1)   // 对应的 名字
            let suffix = caps.at(2) // 对应的 (,|.)

            // 6. 拼接：[前文] [前缀] [**名字**] [后缀] [后文]
            [#pre-text#prefix#strong(name)#suffix#post-text]
          } else {
            reptext // 无匹配
          }
        } else {
          reptext // 列表为空
        }
      }
      // ===========================

      // 拼接成果信息 (rank, comment)
      let final-content = if item-data != none {
        // 1. 提取额外信息：去掉第一个元素(BibKey)，获取剩余所有项
        // slice(1) 表示从第2个元素一直取到最后
        let extras = item-data.slice(1)
        
        // 2. 过滤空值并拼接
        // filter: 去掉空字符串或none
        // join: 用中文逗号连接所有非空项
        let append-str = extras.filter(it => it != none and it != "").join("，")
        
        // 3. 最终组合
        // 如果有附加信息，在引用文本后加 1em 空格，然后加粗显示附加信息
        if append-str != "" {
           [#highlighted-body#h(1em)#strong(append-str)]
        } else {
           highlighted-body
        }
      } else {
        highlighted-body
      }

      // 返回最终内容
      final-content
    }
  }
  // 5. 生成参考文献列表

  box[#bibliographyx(
    bib-path,
    title: none, 
    style: style,
    prefix: "__your_work__:"
  )]
  place(hide(citations))
}