// GB/T 7714—2015 版本配置

#let config-2015 = (
  // 版本标识
  version: "2015",
  name: "GB/T 7714—2015",
  // 标点符号（2015 统一使用英文半角标点）
  punctuation: (
    comma: ", ",
    colon: ": ",
    lparen: "(",
    rparen: ")",
  ),
  // 作者格式化规则
  author-format: (
    family-uppercase: true, // 姓大写（SMITH）
    hyphen-to-space: true, // 连字符展开（J P）
    delimiter: ", ", // 作者分隔符
  ),
  // 条目类型规则
  entry-type-rules: (
    standard-has-author: true, // 标准有作者
  ),
  // 文献类型标识映射
  type-map: (
    "article": "J",
    "periodical": "J",
    "preprint": "A", // 2015 归类为档案
    "newspaper": "N",
    "book": "M",
    "inbook": "M",
    "incollection": "M",
    "chapter": "M",
    "inproceedings": "C",
    "conference": "C",
    "proceedings": "C",
    "phdthesis": "D",
    "mastersthesis": "D",
    "thesis": "D",
    "techreport": "R",
    "report": "R",
    "standard": "S",
    "patent": "P",
    "dataset": "DS",
    "map": "CM",
    "software": "CP",
    "online": "EB",
    "webpage": "EB",
    "archive": "A",
    "misc": "Z",
  ),
  // 正文引用格式
  citation: (
    lparen: "(",
    rparen: ")",
    author-year-sep: ", ",
    multi-sep: "; ",
    locator-sep: ": ", // 页码分隔符（年份和页码之间）
  ),
  // 术语（中文）
  terms-zh: (
    volume-prefix: "第",
    volume-suffix: "卷",
    issue: "期",
    edition: "版",
    page: "页",
    pages: "页",
    translator: "译",
    editor: "编",
    et-al: "等",
    in-word: "见",
    accessed: "访问于",
    online: "在线",
    no-date: "出版年不详",
    anonymous: "佚名",
  ),
  // 术语（英文）
  terms-en: (
    volume-prefix: "Vol.",
    volume-suffix: "",
    issue: "no.",
    edition: "ed",
    page: "p.",
    pages: "pp.",
    translator: "trans",
    editor: "ed",
    et-al: "et al.",
    in-word: "In",
    accessed: "accessed",
    online: "online",
    no-date: "n.d.",
    anonymous: "Anon",
  ),
)
