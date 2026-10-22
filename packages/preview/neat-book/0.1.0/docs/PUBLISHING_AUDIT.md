# 发布前检查记录

检查日期：2026-10-20。对象：Neat Book 0.1.0。

## 网页默认字体

直接获取 Typst 官方网页版的当前字体索引：
<https://typst.app/assets/font-derived/font-index.mpk>。
它是在线编辑器实际使用的字体目录，不是第三方整理的字体清单。
保存的相关字体条目、文件名、字重与索引 SHA-256 见
[本次字体清单快照](web-fonts-2026-10-20.json)。

| 用途 | 默认字体 | 索引中的字形 | 结论 |
| --- | --- | --- | --- |
| 西文 | Libertinus Serif | 常规/半粗/粗，含对应 italic | 满足默认正文和粗斜体 |
| 中文 | Noto Serif CJK SC | 7 个直立字重，含 400/700 | 满足常规/粗体 |
| 日文 | Noto Serif CJK JP | 7 个直立字重，含 400/700 | 满足常规/粗体 |
| 韩文 | Noto Serif CJK KR | 7 个直立字重，含 400/700 | 满足常规/粗体 |
| 等宽 | DejaVu Sans Mono | 常规/粗体/斜体/粗斜体 | 满足代码与行内文本 |
| 标题 | Noto Sans CJK SC | 7 个直立字重，含 400/700 | 满足默认标题 |
| 数学 | New Computer Modern Math | 400/450/700 | 满足数学字体选择 |

结论：默认字体无需更换，网页项目不需要为这些默认家族额外上传字体。
CJK 家族没有原生 italic；本项目通过逐字倾斜显式实现，相关向量渲染回归检查已加入 `make test`。
这次核对确认在线目录与所需字形，并不等同于在已登录的网页版项目中进行过交互编译。
线上字体的具体版本可能与本机版本不同，因此不承诺像素级相同的分页或字形。

重新核对：

```sh
python3 -m pip install msgpack
python3 scripts/check-web-fonts.py
```

也可先下载官方索引，再通过 `--index path/to/font-index.mpk` 离线检查。

## 素材与许可

- 封面 `template/assets/logo.svg` 为本项目绘制的书本图形；不是大学、出版社或 ElegantBook 标志。
- `thumbnail.png` 从本项目封面生成。仓库内未捆绑第三方照片、插图、书籍截图或字体二进制。
- 示例数学陈述是常见事实，解释、证明与代码为本项目编写；文献库只包含书目元数据。
- 示例封面的作者与机构为演示占位文字，不是对任何单位合作、认证或署名的主张。
- 代码语言标志由版本化依赖提供：当前示例使用 Python（Devicon）和 Rust（vscode-icons）。
  不能仅凭依赖的 MIT 软件许可推断全部品牌图标均属 MIT。已分别核对上游许可与商标规则，
  并注明 Rust 上游图标的配色/渐变变体及未进一步修改的事实。
- 本项目使用标志辨认代码语言，不声称 Python/Rust 官方合作或背书。
- 已添加随发布包携带的 [第三方声明](../THIRD_PARTY_NOTICES.md)，列明直接/间接依赖、图标来源、字体许可及相关版权声明。

按当前仓库内容及上述用途，未发现阻碍公开发布的素材来源问题。
未来替换为单位 logo、教材插图或其他语言标志时，应单独核对新增素材；本次结论不覆盖尚未添加的素材。

## 包名、账户与发布状态

- `typst/packages` 当前未发现 `packages/preview/neat-book`，也未找到标题/正文含 `neat-book` 的开放 PR。
  这是本次 GitHub API 查询的结果，不构成包名预留。
- 当前可用 GitHub 账户为 `xiong-ZH-zq`；查询时该账户下未发现 `neat-book` 仓库。
- 上述查询发生在首次发布之前。后续经用户明确授权，已创建公开源码仓库
  <https://github.com/xiong-ZH-zq/neat-book>，并填写 `repository` 元数据。
- 当前署名保留 `xzqbear`，MIT 许可保留不变；模板使用者可根据 MIT 许可使用和分发。

## 验证

本地编译与渲染回归：`make test`。
检查包使用 Typst 官方 `package-check` 0.7.0 的实现，内置 Typst 0.15.0；
运行文件来自 [社区预编译版本](https://github.com/typst-community/dev-builds/releases/tag/package-check-v0.7.0)。
它是官方检查器源码的社区构建，不是 Typst 官方签发的二进制。
本次 `make test` 全部通过，覆盖编译、引用编号、附录顺序、QED、跨页内容、初始化模板、
CJK 实际向量倾斜、粗斜体字重、嵌套强调和关闭合成选项。

以下两种检查均退出 0，无警告、无错误：

```sh
typst-package-check check --offline --json dist/packages/preview/neat-book/0.1.0
typst-package-check check --json dist/packages/preview/neat-book/0.1.0
```

检查时使用工作区内的独立依赖缓存，未修改用户全局包目录。
离线检查覆盖源码、manifest、模板编译和相对文件链接；完整检查另外启用网络相关规则。
检查发现并已修复：打包脚本遗漏 README 所链接的 `docs/RELEASING.md`；
现已纳入提交目录，并通过 `exclude` 避免增加编译器下载包的体积。

## 后续公开发布方案

用户已确认公开仓库 `xiong-ZH-zq/neat-book`，沿用当前 MIT 许可与 `xzqbear` 署名。
发布流程为推送源码，再将准备好的
`dist/packages/preview/neat-book/0.1.0/` 提交到 `typst/packages` 的 PR。
Universe 受理状态以官方 PR 为准；只有合并并完成打包后，版本化导入才可供普通用户使用。
