// ============================================================
// eqblock.typ — 公式块组件
// 提供行间公式的编号与题注：eq-block
// ============================================================

#import "../utils/number.typ": chinesenumbering
#import "../utils/counter.typ": chaptercounter

/// 公式块组件
/// 将行间公式包装为 figure(kind: "equation")，支持 caption 描述和公式目录
/// 省略 caption 时原样返回公式，按 math.equation 原生方式编号，不入公式目录
///
/// 使用公式目录时，所有需要编号的公式应统一用 eq-block，
/// 避免与普通 $ ... $ 的 math.equation 计数器冲突。
/// 不需要编号的公式可用 #math.equation($...$, numbering: none, block: true)
///
/// 示例：
///   #eq-block(caption: [勾股定理])[
///     $ a^2 + b^2 = c^2 $
///   ] <eq-pythagoras>
#let eq-block(body, caption: none) = {
  if caption != none {
    figure(
      {
        set math.equation(numbering: none)
        body
      },
      caption: caption,
      kind: "equation",
      supplement: [式],
       numbering: (..nums) => context {
         // 与 show.typ:_kind-numbering 逻辑一致，见 layout.typ 去重计划
         chinesenumbering(
          chaptercounter.at(here()).first(),
          ..nums,
          location: here(),
          brackets: true,
        )
      },
    )
  } else {
    body
  }
}
