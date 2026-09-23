// 西文字体
#let serif_en = "Times New Roman"

// 宋体
#let song = "SimSun"
// 黑体
#let hei = "SimHei"

// 中英文混合时的衬线体方案
#let serif = ((name: serif_en, covers: "latin-in-cjk"), song, "New Computer Modern Math")
// 中英文混合时的无衬线体方案，西文字符依然使用衬线体
#let sans = ((name: serif_en, covers: "latin-in-cjk"), hei, "New Computer Modern Math")
