#import "equation.typ": equation-numering
#import "../tools/figure-i.typ": figure-numering

#let set-ref(body) = {
  show ref: it => {
    let ele = it.element
    if ele == none {
      it
    } else if ele.func() == math.equation {
      // 如果引用的数学公式
      // 显示数学公式自带的方式
      let num-str = equation-numering((), element: ele)
      link(ele.location(), "公式" + num-str)
    } else if ele.func() == heading {
      // 如果引用的是标题
      // 显示 1.1.1.1 节这种格式
      let nums = counter(heading).at(ele.location())
      let n = nums.len()
      if n == 1 {
        link(ele.location(), numbering("第一章", ..nums))
      } else {
        link(ele.location(), numbering("第1.1.1.1节", ..nums))
      }
    } else if ele.func() == figure {
      // 图1-1, 表1-1 之类的
      let fig = it.element
      if fig.numbering == none { return it }
      let meta = query(metadata)
        .find(data => (
          type(data.value) == dictionary
            and data.value.at("figure-location", default: none) == it.element.location()
        ))
        .value
      let location = meta.body-location
      let kind = meta.kind
      let supplement = (if it.supplement == auto { it.element } else { it }).supplement
      let num = figure-numering((), kind: kind, element: fig)
      link(location, [#supplement#num])
    } else {
      it
    }
  }
  body
}

#let c(..keys) = {
  show super: it => it.body
  keys.pos().map(k => cite(k)).join()
}