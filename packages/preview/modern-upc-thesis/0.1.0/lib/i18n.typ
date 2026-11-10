// ============================================================
// lib/i18n.typ: 多语言字典
// ============================================================

#let dict = (
  zh: (
    abstract: "摘 要",
    abstract-en: "Abstract",
    keywords: "关键词",
    keywords-en: "Keywords",
    acknowledgements: "致 谢",
    bibliography: "参考文献",
    table-of-contents: "目 录",
    figure: "图",
    table: "表",
    chapter: "章",
    appendix: "附录",
    // 学校通用
    bachelor-thesis: "本科毕业设计（论文）",
    university: "大学",
    institute: "学院",
    advisor: "指导教师",
    author: "学生姓名",
    date: "完成日期",
    // 原创性声明
    originality: "原创性声明",
    originality-text: "本人郑重声明：所呈交的学位论文，是本人在导师的指导下，独立进行研究工作所取得的成果。除文中已经注明引用的内容外，本论文不含任何其他个人或集体已经发表或撰写过的作品成果。对本文的研究做出重要贡献的个人和集体，均已在文中以明确方式标明。本人完全意识到本声明的法律结果由本人承担。",
    // 页眉
    header-thesis: "中国石油大学（华东）本科毕业设计(论文)",
  ),
  en: (
    abstract: "Abstract",
    keywords: "Keywords",
    acknowledgements: "Acknowledgements",
    bibliography: "References",
    table-of-contents: "Table of Contents",
    figure: "Figure",
    table: "Table",
    chapter: "Chapter",
    appendix: "Appendix",
    bachelor-thesis: "Bachelor Thesis",
    university: "University",
    institute: "School",
    advisor: "Advisor",
    author: "Author",
    date: "Date",
    originality: "Declaration of Originality",
    originality-text: "I hereby declare that this thesis is the result of my own independent research under the supervision of my advisor. All sources used have been properly acknowledged.",
    header-thesis: "Bachelor Thesis",
  ),
)

// 获取翻译字符串
#let t(key, lang: "zh") = {
  let d = dict.at(lang, default: dict.zh)
  d.at(key, default: key)
}
