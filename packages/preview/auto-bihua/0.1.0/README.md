# auto-bihua

<p align="center">
  <a href="#english"><img alt="English version" src="https://img.shields.io/badge/lang-English-3178c6?style=for-the-badge"></a>
  &nbsp;
  <a href="#中文"><img alt="中文版本" src="https://img.shields.io/badge/语言-中文-c62828?style=for-the-badge"></a>
</p>

Stroke count, stroke order, and stroke-based sorting for Chinese characters in
Typst. Wraps a Rust → WASM plugin with compile-time lookup tables for
`Unihan kTotalStrokes` (~103,000 CJK characters) and `cnchar` stroke order
(6,939 simplified characters).

| API | Returns |
|-----|---------|
| `bihua-count(chars, split: false)` | total stroke count, or per-character array |
| `bihua-order(char, style: "digit")` | stroke order in 4 styles |
| `bihua-sort(items)` | array sorted by stroke count, then stroke order |
| `version()` | version + data-source info |

---

## English

### Installation

```typst
#import "@preview/auto-bihua:0.1.0": *
```

### `bihua-count`

Stroke count of one or more Chinese characters.

```typst
#bihua-count("汉字")                  // → 11
#bihua-count("汉字", split: true)     // → (5, 6)
#bihua-count("龘")                    // → 48
#bihua-count("Hello 世界", split: true)
// → (none, none, none, none, none, none, 5, 9)
#bihua-count("漢字")                  // → 20  (traditional supported)
#bihua-count("")                      // → 0
```

- `chars` accepts `str` or `content` (Typst text content with a `.text` field).
- Non-Chinese characters contribute `0` to the total, and `none` in `split` mode.
- Counts come from Unihan, so coverage extends to traditional characters and
  CJK extensions.

### `bihua-order`

Stroke order of a single character. Four output styles:

```typst
#bihua-order("汉")                       // "44154"          (digit, default)
#bihua-order("汉", style: "name")        // ("点","点","提","横撇","捺")
#bihua-order("汉", style: "shape")       // ("丶","丶","㇀","㇇","㇏")
#bihua-order("汉", style: "letter")      // "kkiel"          (raw cnchar code)
```

| Style    | Output             | Use case |
|----------|--------------------|----------|
| `digit`  | string of `1`–`5`  | GB13000 standard: 1=横 2=竖 3=撇 4=点 5=折. Use as a comparable sort key. |
| `name`   | array of strings   | Display: 横折钩, 横撇, 竖弯钩, … |
| `shape`  | array of strings   | Display Unicode stroke glyphs (`㇏`, `㇇`, `丿`, …). |
| `letter` | string             | The 26-letter cnchar encoding, finer-grained than digit. |

Errors and edge cases:
- Passing a multi-character string panics. Iterate yourself if needed.
- Characters not in the stroke-order dictionary (traditional Hanzi, rare CJK
  extension chars, single-stroke radicals like `丿`, `丶`) return `""` for
  string styles and `()` for array styles.

### `bihua-sort`

Sort an array of strings (or contents) by stroke count, then by stroke order
as tiebreaker. Comparison is character-by-character, mirroring the standard
Chinese-publishing convention of "first by total strokes, then by stroke
type."

```typst
#bihua-sort(("汉","字","人","一","乙","二"))
// → ("一", "乙", "二", "人", "汉", "字")

#bihua-sort(("人民","汉字","一二","北京","上海","天津"))
// → ("一二", "人民", "上海", "天津", "北京", "汉字")
```

- Items with characters outside both data sets sort to the end.
- Tiebreaker uses the GB13000 digit sequence (not the raw cnchar letter
  encoding), so 提 sorts before 竖 as the standard prescribes.

### Real-world recipes

**Sort Chinese author names by surname strokes** (common journal style):

```typst
#bihua-sort(("王伟","李娜","张敏","刘洋","陈静","杨磊","黄勇","赵丽","周强","吴芳"))
// → ("王伟","刘洋","李娜","杨磊","吴芳","张敏","陈静","周强","赵丽","黄勇")
```

**Stroke order card** for character study:

```typst
#let card(c) = block(
  stroke: 0.5pt + gray, inset: 8pt, radius: 4pt,
  [
    *#text(24pt, c)* #h(1em) #bihua-count(c) strokes \
    #bihua-order(c, style: "name")
      .enumerate()
      .map(((i, n)) => [#(i+1).#n])
      .join("  ")
  ]
)
#card("永")
```

**Index a glossary by first-character stroke count**:

```typst
#let terms = ("汉字","人民","一致","中国","北京","笔画")
#let groups = (:)
#for t in bihua-sort(terms) {
  let n = str(bihua-count(t.first()))
  groups.insert(n, groups.at(n, default: ()) + (t,))
}
#table(columns: 2,
  ..groups.pairs().map(((n, ts)) => (n + " 画", ts.join("、"))).flatten()
)
```

### Data sources

- **Stroke count**: Unicode 17.0 `Unihan_IRGSources.txt`, field `kTotalStrokes`
  (~103k CJK code points, includes traditional and CJK extensions).
- **Stroke order**: `cnchar` package's `stroke-order-jian.json`
  (6,939 simplified characters), MIT license.
- **Stroke type encoding**: cnchar's 26-letter alphabet, projected to the
  GB13000 5-type system at lookup time.

### Building from source

```sh
cd wasm
rustup target add wasm32-unknown-unknown
cargo build --release
cp target/wasm32-unknown-unknown/release/auto_bihua.wasm ../auto-bihua.wasm
```

Or with `just`: `just build`. The data files are processed by `build.rs` into
static `phf` maps at compile time, so no runtime parsing.

### Limitations

- Stroke order data covers only ~6,939 simplified characters. Traditional
  characters have stroke counts but no order; `bihua-order` returns empty.
- Single-stroke radicals (`丿`, `丶`) and some CJK extension characters
  are absent from the stroke-order dictionary even though their stroke
  count is known.

### License

MIT. Data licenses: Unihan (Unicode terms), cnchar (MIT).

---

## 中文

### 安装

```typst
#import "@preview/auto-bihua:0.1.0": *
```

### `bihua-count` — 笔画数

输入单字或多字，返回总笔画数（默认）或按字拆分的数组。

```typst
#bihua-count("汉字")                  // → 11
#bihua-count("汉字", split: true)     // → (5, 6)
#bihua-count("龘")                    // → 48
#bihua-count("Hello 世界", split: true)
// → (none, none, none, none, none, none, 5, 9)
#bihua-count("漢字")                  // → 20  （繁体也支持）
#bihua-count("")                      // → 0
```

- 参数 `chars` 接受字符串或带 `.text` 字段的 content。
- 非汉字字符在总和模式贡献 `0`，在 `split` 模式返回 `none`。
- 数据来源是 Unihan，覆盖繁体字和 CJK 扩展区。

### `bihua-order` — 笔顺

输入单个汉字，返回其笔顺。四种输出风格：

```typst
#bihua-order("汉")                       // "44154"          （数字, 默认）
#bihua-order("汉", style: "name")        // ("点","点","提","横撇","捺")
#bihua-order("汉", style: "shape")       // ("丶","丶","㇀","㇇","㇏")
#bihua-order("汉", style: "letter")      // "kkiel"          （cnchar 原始字母编码）
```

| 风格     | 输出              | 用途 |
|----------|------------------|------|
| `digit`  | `1`–`5` 数字串    | GB13000 五笔位：1=横 2=竖 3=撇 4=点 5=折，可直接作为排序键。 |
| `name`   | 字符串数组        | 显示：横折钩、横撇、竖弯钩 …… |
| `shape`  | 字符串数组        | 显示笔形 Unicode 字符（`㇏`、`㇇`、`丿` ……）。 |
| `letter` | 字符串            | cnchar 26 字母编码，比数字风格更细。 |

异常与边界：
- 传入多字字符串会 panic，请自行逐字遍历。
- 不在笔顺词典里的字符（繁体字、CJK 扩展生僻字、`丿`/`丶` 等单笔部首）：
  字符串风格返回 `""`，数组风格返回 `()`。

### `bihua-sort` — 笔画排序

对字符串（或 content）数组按笔画数排序，同笔画数时按笔顺数字序为次要键。
逐字比较，与中文出版界"先比总画数，同画数比笔形"的惯例一致。

```typst
#bihua-sort(("汉","字","人","一","乙","二"))
// → ("一", "乙", "二", "人", "汉", "字")

#bihua-sort(("人民","汉字","一二","北京","上海","天津"))
// → ("一二", "人民", "上海", "天津", "北京", "汉字")
```

- 包含两份数据都不收录字符的项会排到末尾。
- 次要键使用 GB13000 五笔位数字序（而非 cnchar 字母字典序），所以 提 排
  在 竖 之前，符合国标顺序。

### 实战用法

**中文作者按姓氏笔画排序**（中文期刊投稿常用规范）：

```typst
#bihua-sort(("王伟","李娜","张敏","刘洋","陈静","杨磊","黄勇","赵丽","周强","吴芳"))
// → ("王伟","刘洋","李娜","杨磊","吴芳","张敏","陈静","周强","赵丽","黄勇")
```

**笔顺展示卡片**（适合识字教材）：

```typst
#let card(c) = block(
  stroke: 0.5pt + gray, inset: 8pt, radius: 4pt,
  [
    *#text(24pt, c)* #h(1em) 共 #bihua-count(c) 画 \
    #bihua-order(c, style: "name")
      .enumerate()
      .map(((i, n)) => [#(i+1).#n])
      .join("  ")
  ]
)
#card("永")
```

**词条按首字笔画分组建索引**：

```typst
#let terms = ("汉字","人民","一致","中国","北京","笔画")
#let groups = (:)
#for t in bihua-sort(terms) {
  let n = str(bihua-count(t.first()))
  groups.insert(n, groups.at(n, default: ()) + (t,))
}
#table(columns: 2,
  ..groups.pairs().map(((n, ts)) => (n + " 画", ts.join("、"))).flatten()
)
```

### 数据来源

- **笔画数**：Unicode 17.0 `Unihan_IRGSources.txt`，字段 `kTotalStrokes`
  （约 10.3 万 CJK 码位，含繁体与扩展区）。
- **笔顺**：`cnchar` 项目的 `stroke-order-jian.json`（6939 简体字），MIT 协议。
- **笔形编码**：cnchar 26 字母方案，查询时映射到 GB13000 五类。

### 从源码构建

```sh
cd wasm
rustup target add wasm32-unknown-unknown
cargo build --release
cp target/wasm32-unknown-unknown/release/auto_bihua.wasm ../auto-bihua.wasm
```

或用 `just build`。`build.rs` 在编译期把数据文件转成静态 `phf` 表，运行时
零解析开销。

### 已知限制

- 笔顺数据只覆盖约 6939 个简体字。繁体字有笔画数但无笔顺；`bihua-order`
  返回空。
- 单笔部首（如 `丿`、`丶`）和部分 CJK 扩展区字符虽有笔画数，但不在笔顺
  词典中。

### 许可

MIT。数据：Unihan（Unicode 协议）、cnchar（MIT）。
