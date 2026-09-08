// ============================================================
// counter.typ — 计数器定义
// ============================================================

// partcounter 状态:
//   0 = 封面部分（无页眉页脚）
//   1 = 前置部分（罗马数字页码，有页眉）
//   2 = 正文部分（阿拉伯数字页码，有页眉）
//   3 = 附录部分（页码同正文，编号切换为 "附录 A"/"A.1"）

#let partcounter = counter("part")
#let chaptercounter = counter("chapter")
#let footnotecounter = counter(footnote)
#let rawcounter = counter(figure.where(kind: "code"))
#let imagecounter = counter(figure.where(kind: image))
#let subfigurecounter = counter(figure.where(kind: "subfigure"))
#let tablecounter = counter(figure.where(kind: table))
#let equationcounter = counter(figure.where(kind: "equation"))
#let theoremcounter = counter(figure.where(kind: "theorem"))
#let definitioncounter = counter(figure.where(kind: "definition"))
#let lemmacounter = counter(figure.where(kind: "lemma"))
#let corollarycounter = counter(figure.where(kind: "corollary"))
#let propositioncounter = counter(figure.where(kind: "proposition"))
#let propertycounter = counter(figure.where(kind: "property"))
#let examplecounter = counter(figure.where(kind: "example"))
#let remarkcounter = counter(figure.where(kind: "remark"))

/// 定理类环境的 kind 集合：用于 show.typ 识别定理类 figure
#let theorem-kinds = (
  "theorem", "definition", "lemma", "corollary",
  "proposition", "property", "example", "remark",
)

/// 跳过页状态：用于 always-start-odd 时标记被跳过的空白偶数页。
#let skippedstate = state("skipped", false)

/// 续表标题状态：figure-show-rule 注入表题，供三线表续页表头渲染"续表 X.Y 名称"
#let continued-caption-state = state("booktab-continued-caption", none)

/// 重置所有随章节编号的计数器（正文每章开头调用）
/// 注意：chaptercounter 在此前已通过 .step() 递增
#let reset-chapter-counters() = {
  imagecounter.update(())
  tablecounter.update(())
  rawcounter.update(())
  equationcounter.update(())
  counter(math.equation).update(())
  theoremcounter.update(())
  definitioncounter.update(())
  lemmacounter.update(())
  corollarycounter.update(())
  propositioncounter.update(())
  propertycounter.update(())
  examplecounter.update(())
  remarkcounter.update(())
}
