# gb7714-bilingual

GB/T 7714 双语参考文献系统，支持中英文术语自动切换。

> 同时支持 **GB/T 7714—2015** 和 **GB/T 7714—2025**（2026-07-01 实施）两个版本

## 特性

- ✅ **双版本支持**：可选择 2015 或 2025 版本标准
- ✅ 自动检测文献语言（通过 `language` 字段、正则匹配汉字）
- ✅ 中英文术语自动切换（第X卷/v.X、期/no.、等/et al.）
- ✅ 支持顺序编码制（numeric）和著者-出版年制（author-date）
- ✅ 正确处理作者格式化（中文连写、英文姓大写+名首字母）
- ✅ 支持同作者同年文献消歧（a, b, c 后缀）
- ✅ 支持多引用合并（`multicite` 函数，支持带页码）
- ✅ 支持引用形式切换（上标/非上标/仅作者/仅年份）
- ✅ 支持带页码引用（supplement 参数）
- ✅ 支持点击引用跳转到参考文献列表
- ✅ 完整的文献类型标识（支持 `mark` 字段手动声明）
- ✅ 支持析出文献（`//` 符号）
- ✅ 支持多个 BibTeX 文件

## 安装

```typst
#import "@preview/gb7714-bilingual:0.2.1": init-gb7714, gb7714-bibliography, multicite
```

## 使用方法

### 基本用法

```typst
#import "@preview/gb7714-bilingual:0.2.1": init-gb7714, gb7714-bibliography, multicite

// 使用 2025 版本（默认）
#show: init-gb7714.with(read("ref.bib"), style: "numeric", version: "2025")

正文中使用 @wang2010guide 引用文献。

#gb7714-bibliography()
```

> **注意**：需要使用 `read()` 读取 bib 文件内容传入。

### 选择标准版本

```typst
// 使用 GB/T 7714—2015
#show: init-gb7714.with(read("ref.bib"), style: "numeric", version: "2015")
```

### 著者-出版年制

```typst
#show: init-gb7714.with(read("ref.bib"), style: "author-date", version: "2025")

这是一个引用 @smith2020。

#gb7714-bibliography()
```

### 多个 BibTeX 文件

```typst
// 使用多个 bib 文件（用 + 合并内容）
#show: init-gb7714.with(read("main.bib") + read("extra.bib"), style: "numeric")
```

### 引用形式切换

```typst
// 默认上标形式（numeric 模式自动上标，无需 #super）
孔乙己提到@smith2020 的重要发现

// 非上标形式（散文引用）
另见#cite(<smith2020>, form: "prose")的详细分析

// 仅作者
研究由#cite(<smith2020>, form: "author")完成

// 仅年份
该研究发表于#cite(<smith2020>, form: "year")年
```

### 带页码引用

```typst
// 简写形式
关于方法论的讨论见@liu2015[第 3 章]
具体实验步骤见@liu2015[126--129]

// 函数形式（可结合 form）
详见#cite(<kopka2004>, form: "prose", supplement: [第 5.2 节])
```

### 多引用合并

```typst
// 基本用法：同一作者的多篇文献会自动合并年份
#multicite("smith2020a", "smith2020b", "jones2019")
// Numeric: [1-3]（上标）
// Author-date: （Smith，2020a，2020b；Jones，2019）

// 带页码的合并引用
#multicite(
  (key: "smith2020a", supplement: [260]),
  "smith2020b",
  (key: "jones2019", supplement: [Table 2]),
)
// Numeric: [1：260, 2, 3：Table 2]
// Author-date: （Smith，2020a：260，2020b；Jones，2019：Table 2）

// 非上标形式
#multicite("smith2020a", "smith2020b", form: "prose")
// Numeric: [1-2]（非上标）
```

### 自定义渲染（高级）

```typst
// 使用 full-control 完全控制输出格式
#gb7714-bibliography(full-control: entries => {
  for e in entries [
    // 自定义编号格式
    (#e.order)#h(1em)
    // 使用带 label 的渲染结果（支持点击跳转）
    #e.labeled-rendered
    #parbreak()
  ]
})

// 或者完全自定义，访问原始字段
#gb7714-bibliography(full-control: entries => {
  for e in entries {
    let f = e.fields
    [
      [#e.order]
      #f.at("author", default: "").
      #emph(f.at("title", default: "")).
      #f.at("journal", default: ""),
      #f.at("year", default: "").
    ]
    parbreak()
  }
})
```

## 2015 与 2025 版本差异

| 差异点                    | GB/T 7714—2015    | GB/T 7714—2025    |
| ------------------------- | ----------------- | ----------------- |
| 预印本类型标识            | `[A]`（档案）     | `[PP]`（预印本）  |
| 著者-出版年制正文引用括号 | 英文 `()`         | 统一中文 `（）`   |
| 正文引用分隔符            | 英文 `; ` 和 `, ` | 中文 `；` 和 `，` |

## BibTeX 文件格式

为获得最佳效果，建议在 BibTeX 条目中添加 `language` 字段：

```bibtex
@article{wang2010guide,
  title   = {科技论文中文摘要写作要点分析},
  author  = {王晓华 and 闫其涛 and 程智强 and 张睿},
  journal = {编辑学报},
  year    = {2010},
  language = {chinese}
}

@book{kopka2004guide,
  title     = {Guide to LATEX},
  author    = {Kopka, Helmut and Daly, Patrick W},
  publisher = {Addison-Wesley},
  year      = {2004},
  language = {english}
}
```

如果没有 `language` 字段，系统会通过检测标题/作者中的汉字自动判断语言。

## API 参考

### `init-gb7714(bib-content, style: "numeric", version: "2025", doc)`

初始化 GB/T 7714 双语参考文献系统。

- `bib-content`: BibTeX 文件内容（使用 `read()` 读取）
  - 单文件：`read("ref.bib")`
  - 多文件：`read("main.bib") + read("extra.bib")`
- `show-url`: 是否显示 URL（默认 `true`）
- `show-doi`: 是否显示 DOI（默认 `true`）
- `show-accessed`: 是否显示访问日期（默认 `true`）
- `style`: 引用风格
  - `"numeric"`: 顺序编码制，如 [1]
  - `"author-date"`: 著者-出版年制，如（王，2020）
- `version`: 标准版本
  - `"2015"`: GB/T 7714—2015
  - `"2025"`: GB/T 7714—2025（默认）

### `gb7714-bibliography(title: auto, full-control: none)`

渲染参考文献列表。

- `title`: 参考文献标题
  - `auto`（默认）：根据文献语言自动选择（"参考文献" 或 "References"），一级标题
  - `none`：不显示标题
  - 自定义内容：如 `heading(level: 2)[References]`
- `full-control`: 完全控制渲染的回调函数（高级用法）
  - 签名：`(entries) => content`
  - 使用此参数时，用户完全控制输出格式

### `get-cited-entries()`

获取被引用的条目列表（低层 API，需在 `context` 中使用）。

返回数组，每个元素包含：

- `key`: 引用键
- `order`: 引用顺序
- `year-suffix`: 消歧后缀（如 "a", "b"）
- `lang`: 语言（"zh" 或 "en"）
- `entry-type`: 条目类型
- `fields`: 原始字段字典
- `parsed-names`: 解析后的作者名
- `rendered`: 纯渲染结果（不含 label）
- `ref-label`: 用于跳转的 label 对象（需手动附加到内容中）
- `labeled-rendered`: 已附加 label 的渲染结果（推荐使用，或用 `rendered` + `ref-label` 自行组合）

### `multicite(..keys, form: none)`

多引用合并函数。

- `keys`: 引用键列表，支持两种形式：
  - 字符串：`"smith2020"`
  - 字典：`(key: "smith2020", supplement: [260])`
    - `key`: 引用键（必需）
    - `supplement`: 页码等附加信息（可选）
- `form`: 引用形式（命名参数）
  - `none` / `"normal"`: 默认（顺序编码制上标，著者-出版年制整体括号）
  - `"prose"`: 散文形式（顺序编码制非上标，著者-出版年制仅年份括号）

## 支持的条目类型

| BibTeX 类型                | 2015 标识 | 2025 标识 | 说明            |
| -------------------------- | --------- | --------- | --------------- |
| article                    | [J]       | [J]       | 期刊文章        |
| preprint                   | [A]       | [PP]      | 预印本          |
| newspaper                  | [N]       | [N]       | 报纸文章        |
| book, inbook, incollection | [M]       | [M]       | 图书            |
| inproceedings, conference  | [C]       | [C]       | 会议论文        |
| phdthesis, mastersthesis   | [D]       | [D]       | 学位论文        |
| techreport, report         | [R]       | [R]       | 报告            |
| standard                   | [S]       | [S]       | 标准            |
| patent                     | [P]       | [P]       | 专利            |
| dataset                    | [DS]      | [DS]      | 数据集          |
| map                        | [CM]      | [CM]      | 地图            |
| software                   | [CP]      | [CP]      | 软件/计算机程序 |
| online, webpage            | [EB/OL]   | [EB/OL]   | 网页/电子公告   |
| archive                    | [A]       | [A]       | 档案            |
| misc                       | [Z]       | [Z]       | 其他            |

带 URL 或 DOI 的条目会自动添加 `/OL` 载体标识，如 `[J/OL]`。

### 特殊类型处理

由于底层库 citegeist 不支持 `@standard` 和 `@newspaper` 等非标准 BibTeX 类型，本库提供多种解决方案：

**方法 1：使用 `mark`/`usera` 字段手动声明类型标识**

```bibtex
% 报纸文章
@misc{news2024,
  mark     = {N},
  title    = {重要新闻标题},
  author   = {记者},
  journal  = {人民日报},
  date     = {2024-01-15},
  pages    = {1},
  year     = {2024}
}

% 标准文献
@misc{gb7714,
  mark     = {S},
  number   = {GB/T 7714—2015},
  title    = {信息与文献参考文献著录规则},
  publisher = {中国标准出版社},
  year     = {2015}
}

% 自定义载体（数据库/磁带）
@misc{dbmt,
  author   = {Rossmann, K and Rittel, H F},
  title    = {Database created from magnetic resonance images},
  year     = {1976},
  usera    = {DB},
  medium   = {MT}
}
% 输出：Rossmann K，Rittel H F. Database...[DB/MT]. 1976.
```

**方法 2：使用 `entrysubtype`/`note` 字段（biblatex-gb7714 兼容）**

```bibtex
% 标准（兼容 Zotero 导入）
@book{gb7714,
  title        = {信息与文献参考文献著录规则},
  number       = {GB/T 7714—2015},
  publisher    = {中国标准出版社},
  year         = {2015},
  entrysubtype = {standard}
}

% 报纸
@article{news2024,
  title    = {重要新闻标题},
  author   = {记者},
  journal  = {人民日报},
  year     = {2024},
  note     = {newspaper}
}
```

**方法 3：标准文献自动检测**

如果 `number` 字段以标准前缀开头（GB, ISO, IEC, IEEE, ANSI, DIN, JIS, BS），会自动识别为标准文献 `[S]`：

```bibtex
@standard{iso9001,
  number   = {ISO 9001:2015},
  title    = {Quality management systems},
  year     = {2015}
}
```

**类型检测优先级**：`mark/usera` > `entrysubtype/note` > `number 前缀` > 原始类型

**支持的 mark 值**：

| mark | 类型标识 | 说明     |
| ---- | -------- | -------- |
| S    | [S]      | 标准     |
| N    | [N]      | 报纸     |
| J    | [J]      | 期刊     |
| M    | [M]      | 图书     |
| C    | [C]      | 会议     |
| D    | [D]      | 学位论文 |
| R    | [R]      | 报告     |
| P    | [P]      | 专利     |
| G    | [G]      | 汇编     |
| EB   | [EB/OL]  | 网页     |
| DB   | [DB]     | 数据库   |
| CP   | [CP]     | 软件     |
| CM   | [CM]     | 地图     |
| DS   | [DS]     | 数据集   |

**自定义载体标识**：使用 `medium` 字段指定载体，如 `medium = {MT}` 生成 `[类型/MT]`。

### 析出文献（书中章节）

使用 `@inbook` 或 `@incollection` 时，会自动添加 `//` 析出符号，类型标识位于析出标题后：

```bibtex
@inbook{chapter2019,
  title     = {深度学习基础},
  author    = {张华},
  booktitle = {人工智能导论},
  publisher = {机械工业出版社},
  address   = {北京},
  year      = {2019},
  pages     = {45--78}
}
```

输出：`张华. 深度学习基础[M]//人工智能导论. 北京：机械工业出版社，2019：45–78.`

**析出文献来源责任者**：支持 `bookauthor` 和 `editor` 字段表示来源文献的责任者：

```bibtex
@inbook{weinstein1974,
  author     = {Weinstein, L and Swartz, M N},
  title      = {Pathogenic properties of invading microorganisms},
  booktitle  = {Pathologic physiology: mechanisms of disease},
  bookauthor = {Sodeman, Jr., W A and Sodeman, W A},
  edition    = {5},
  publisher  = {Saunders},
  address    = {Philadelphia},
  year       = {1974},
  pages      = {457--472}
}
```

输出：`Weinstein L，Swartz M N. Pathogenic properties...[M]// Sodeman W A Jr，Sodeman W A. Pathologic physiology...`

## 项目结构

```bash
src/
├── core/           # 核心模块（状态、工具、语言检测）
├── versions/       # 版本配置（2015、2025）
├── renderers/      # 渲染器（期刊、书籍、会议等）
├── authors.typ     # 作者格式化
├── types.typ       # 文献类型标识
└── api.typ         # 公共 API
lib.typ             # 主入口
```

## 更新日志

详见 [CHANGELOG.md](CHANGELOG.md)

## 许可证

MIT
