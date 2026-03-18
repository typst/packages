// JLU Thesis Template for Typst
// 吉林大学学位论文模板

#import "core/template.typ": jlu-thesis

// 导出主模板函数
#let jlu-bachelor = jlu-thesis
#let jlu-master = jlu-thesis  // 将来可以扩展
#let jlu-doctor = jlu-thesis  // 将来可以扩展

// 兼容性导出
#let doc = jlu-thesis