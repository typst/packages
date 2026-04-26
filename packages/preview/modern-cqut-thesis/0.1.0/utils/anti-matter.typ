// 导出 anti-matter 中的函数
#let (
  anti-front-end,
  anti-inner-end,
  anti-outer-counter,
  anti-inner-counter,
  anti-active-counter-at,
  anti-page-at,
  anti-page,
  anti-header,
  anti-thesis,
  anti-matter,
) = {
  // TODO: 我认为可以移除spec,改用loc.page-numbering()

  // 验证spec
  let assert-spec-valid(spec) = {
    if type(spec) != dictionary {
      panic("spec必须是一个字典,而不是 " + type(spec))
    }

    if spec.len() != 3 {
      panic("spec必须恰好包含3个元素,而不是 " + str(spec.len()))
    }

    if "front" not in spec { panic("缺少front键") }
    if "inner" not in spec { panic("缺少inner键") }
    if "back" not in spec { panic("缺少back键") }
  }

  let meta-label = <anti-matter:label>
  let key-front-end = "anti-matter:front-end"
  let key-inner-end = "anti-matter:inner-end"

  // 获取给定位置的事项和修正
  let where-am-i(spec, loc) = {
    let markers = query(meta-label)

    assert.eq(
      markers.len(),
      2,
      message: "必须恰好有两个标记(不要使用 <anti-matter:meta>)"
    )
    assert.eq(markers.at(0).value, key-front-end, message: "第一个标记必须是前端标记")
    assert.eq(markers.at(1).value, key-inner-end, message: "第二个标记必须是内部结束标记")

    let front-matter = markers.first().location()
    let inner-matter = markers.last().location()

    let front-matter-end = counter(page).at(front-matter).at(0)
    let inner-matter-end = counter(page).at(inner-matter).at(0)

    if loc.page() <= front-matter.page() {
      ("front", spec.front, 0)
    } else if front-matter.page() < loc.page() and loc.page() <= inner-matter.page() {
      ("inner", spec.inner, front-matter-end)
    } else {
      ("back", spec.back, inner-matter-end - front-matter-end)
    }
  }

  /// 标记文档前端事项的结束,将其放在前端事项的最后一页。
  /// 确保将其放在尾随的`pagebreaks`之前。
  ///
  /// -> content
  let anti-front-end() = [#metadata(key-front-end) #meta-label]

  /// 标记文档内部事项的结束,将其放在内部事项的最后一页。
  /// 确保将其放在尾随的`pagebreaks`之前。
  ///
  /// -> content
  let anti-inner-end() = [#metadata(key-inner-end) #meta-label]

  /// 返回文档前端和后端事项的计数器。
  ///
  /// -> counter
  let anti-outer-counter() = counter("anti-matter:outer")

  /// 返回文档主要内容的计数器。
  ///
  /// -> counter
  let anti-inner-counter() = counter("anti-matter:inner")

  /// 返回给定位置的活动计数器。这可用于在特定位置设置页面计数器。
  ///
  /// - spec (dictionary): 文档的规格,参见 @@anti-matter
  /// - loc (location): 获取活动计数器的位置
  /// -> counter
  let anti-active-counter-at(spec, loc) = {
    let (matter, _, _) = where-am-i(spec, loc)

    if matter == "inner" {
      anti-inner-counter()
    } else {
      anti-outer-counter()
    }
  }

  /// 使用默认规格,共享外部编号和计数器。
  ///
  /// 返回的字典简单地包含`front`、`inner`和`back`键的编号。
  ///
  /// - outer (string, function): 用于前端和后端事项的编号
  /// - inner (string, function): 用于文档主要内容的编号
  /// -> dictionary
  let anti-thesis(outer: "I", inner: "1") = (
    front: outer,
    inner: inner,
    back: outer,
  )

  /// 返回给定位置的页面编号,根据规格进行必要的调整和编号。
  ///
  /// - spec (dictionary): 文档的规格,参见 @@anti-matter
  /// - loc (location): 评估编号的位置
  /// -> content
  let anti-page-at(spec, loc) = {
    let (_, num, correction) = where-am-i(spec, loc)

    let vals = counter(page).at(loc)
    vals.at(0) = vals.at(0) - correction

    numbering(num, ..vals)
  }

  /// 返回给定位置的格式化页码,根据规格进行必要的调整和编号。
  ///
  /// - spec (dictionary): 描述文档编号的规格,参见 @@anti-matter
  /// -> content
  let anti-page(spec) = context {
    let loc = here()
    anti-page-at(spec, loc)
  }

  /// 渲染页眉,同时维护anti-matter计数器步进。
  ///
  /// - spec (dictionary): 描述文档编号的规格,参见 @@anti-matter
  /// - header (content): 要渲染的页眉
  /// -> content
  let anti-header(spec, header) = {
    context {
      let loc = here()
      anti-active-counter-at(spec, loc).step()
    }
    header
  }

  /// 应用页面编号和outline.entry的show规则以修复其页面编号的模板函数。
  /// 如果需要更细粒度地控制大纲条目和页眉,请参阅库文档。
  /// 这可以用于show规则。参数会被验证。
  ///
  /// - spec (dictionary): 描述文档编号的规格,参见 @@anti-matter
  /// - debug (bool): 在页眉中显示当前事项和相关信息
  /// - body (content): 要使用anti-matter编号渲染的内容
  /// -> content
  let anti-matter(
    spec: anti-thesis(),
    debug: false,
    body,
  ) = {
    assert-spec-valid(spec)

    set page(
      header: if debug {
        context {
          let loc = here()
          anti-header(spec)[
            #let (matter, numbering, correction) = where-am-i(spec, loc)
            #(matter: matter, numbering: numbering, correction: correction)
          ]
        }
      } else {
        anti-header(spec, none)
      },
      numbering: (..args) => anti-page(spec),
    )
    show outline.entry: it => {
      link(it.element.location(), it.body)
      if it.fill != none {
        [ ]
        box(width: 1fr, it.fill)
        [ ]
      } else {
        h(1fr)
      }
      link(it.element.location(), anti-page-at(spec, it.element.location()))
    }
  
    body
  }

  (
    anti-front-end,
    anti-inner-end,
    anti-outer-counter,
    anti-inner-counter,
    anti-active-counter-at,
    anti-page-at,
    anti-page,
    anti-header,
    anti-thesis,
    anti-matter,
  )
}
