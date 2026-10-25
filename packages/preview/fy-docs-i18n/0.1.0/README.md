# fy-docs-i18n

简体中文 | [English](README.en.md)

为 Typst 提供多语言文本加载、查询与报错。你可以把翻译保存为 TOML 文件，按 key 提取文本，再用可配置的语言匹配策略选择翻译。包不依赖文档排版、色板或其他 fy-docs 包，也不自动读取 `context` 中的语言。

需要 Typst 0.15.1 或更新版本。版本为 0.1.0，使用 `@preview/fy-docs-i18n:0.1.0` 导入。

## 快速使用

```typst
#import "@preview/fy-docs-i18n:0.1.0": *

#let dict = (
  greeting: ("zh-Hans": "你好", en: "Hello"),
  invalid-input: ("zh-Hans": "输入无效", en: "Invalid input"),
)
#let i18n = i18n-config(matchers: (language => language == "en",))
#let item = (i18n.item-from)(dict, "greeting")
#(i18n.item-get)(item)

// 需要中止时，按 key 查询用户自己的错误字典：
// (i18n.panic)(dict, "invalid-input")
```

## 数据与语言匹配

多语言字典（dict）是 `dictionary<key: str, item>`；多语言项（item）是 `dictionary<language: str, text: str>`。两者都是普通 Typst 字典，没有额外包装字段。语言名称必须是非空字符串。空字典为 `(:)`，空字符串也是有效翻译。

`matchers` 是函数数组，每个函数接收语言字符串并返回 bool。先按匹配器数组顺序，再按 item 中的语言顺序查找；首次返回 true 时选中对应文本。同一匹配器匹配多个语言时，取字典中第一项。

所有公开函数的默认匹配器依次为：精确匹配 `zh-Hans`、匹配 `zh` 前缀、精确匹配 `en`。语言名称区分大小写。空匹配器数组不会匹配任何语言。建议将精确匹配放在前缀匹配之前；例如先匹配 `zh-Hans`，再匹配 `zh` 前缀。前缀匹配同时命中多个语言时，结果仍取决于字典顺序；有明确地区或文字偏好时，应添加对应的精确匹配器。

## 公开函数

### `i18n-dict-from(files, allow-missing: false, matchers: ...)`

从语言名称到文件路径的字典加载翻译。每个路径值接受字符串或 `path`，语言名称直接使用字典的 key，不从文件名推导，区分大小写且不能为空。

```typst
#let dict = i18n-dict-from((
  en: path("i18n/en.toml"),
  "zh-Hans": path("i18n/zh-Hans.toml"),
))
```

每个 TOML 文件直接保存 key 与翻译，不使用包装表。例如 `en.toml`：

```toml
greeting = "Hello"
invalid-input = "Invalid input"
```

对应 `zh-Hans.toml`：

```toml
greeting = "你好"
invalid-input = "输入无效"
```

第一个文件的 key 集合是基准。默认在读取后续文件时立即检查新增或缺失的 key；`allow-missing: true` 汇总实际提供的翻译，不填充缺失值。翻译值必须是字符串。空文件字典 `(:)` 返回空字典；TOML 中重复 key 由 Typst 解析器处理。

字符串路径相对于包内 `dict.typ` 解析，根相对字符串使用该文件所属项目或包的根。`path` 保留创建时的路径基准；读取用户项目的文件时，应由调用方创建 `path("...")` 再传入包。两种路径值可在同一个文件字典中混用，路径可包含目录，不要求文件名与语言名称一致。

### `i18n-item-from(dict, key, allow-empty: false, matchers: ...)`

验证多语言字典和字符串 key，返回该 key 对应的 item。不存在时默认报错；`allow-empty: true` 返回空 item `(:)`。`matchers` 用于选择本函数的校验错误语言。

### `i18n-item-get(item, matchers: ..., allow-empty: false)`

验证 item 并按匹配器顺序查询，返回字符串。没有匹配时默认报错；`allow-empty: true` 返回 `none`。不会把空字符串视为缺失。

### `i18n-panic(dict, key, matchers: ...)`

从用户提供的多语言字典中提取 key 对应的 item，按匹配策略选取字符串，立即调用 Typst 的 `panic`。用户可以提供任意错误 key 和翻译，无需使用包内错误资源。字典非法、key 不存在或没有匹配翻译时，先报告相应的校验或查询错误。

### `i18n-config(matchers: ...)`

验证并捕获匹配器数组，返回包含 `dict-from`、`item-from`、`item-get`、`panic` 四个函数的字典。这些函数的参数和对应公开函数一致，默认使用捕获的匹配器；单次调用可用 `matchers` 命名参数覆盖。

字典内函数的调用形式为 `(i18n.item-get)(item)`。配置对象不读取 `context`，也不创建延迟执行的内容；用户可通过它统一普通文本与错误消息的语言策略。

## 校验与错误消息

所有公开函数验证输入参数类型及字典、数组内部结构。内部类型检查器返回 bool，不通过 `lib.typ` 导出。匹配器实际调用后会验证返回值是否为 bool；不提前执行未用到的匹配器。

包自身的校验错误提供简体中文与英文翻译，并使用当前匹配策略查询。没有匹配的内置错误语言时回退到简体中文。匹配器结构非法或返回值不是 bool 时采用固定中文错误，避免再次调用错误匹配器。匹配器应为纯函数；调用签名错误、函数内部异常、文件读取与 TOML 解析错误由 Typst 报告。

## 本地检查与 CI

在[开发仓库](https://github.com/Fengyang-Conglomerate/fy-docs-typst-i18n)的包目录运行（preview 包不包含测试脚本）：

```sh
typstyle --check .
python3 tests/run.py
```

格式工具固定为 typstyle 0.15.1，需要 Python 3.11 或更新版本及 PATH 中的 Typst。使用 `typstyle -i .` 应用格式化。

测试根据脚本位置寻找源码，在系统临时目录中编译并自动清理，与当前目录、仓库名称和相邻项目无关。覆盖输入校验、语言匹配、配置绑定与覆盖、文件加载、自定义双语报错和隔离的版本化包导入，并检查内置双语资源的 key 与占位符一致性。

GitHub Actions 在 push、pull_request 或手动触发时执行格式检查与集成测试。固定 typstyle 下载版本并校验 SHA-256；工作流只有 `contents: read` 权限，不发布或推送。

包清单排除测试、CI 和 Git 元数据，保留运行源码、错误资源与文档。本包采用 MIT OR Apache-2.0 双许可证，使用者可以选择其中任意一种。完整条款见 [LICENSE-MIT](LICENSE-MIT) 与 [LICENSE-APACHE](LICENSE-APACHE)。
