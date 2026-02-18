# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.3] - 2025-03-29

- 更新本科毕设模板至教务处 2025 模板 by @idawnlight 。

## [0.3.2] - 2025-02-22

- 适配 Typst 0.13.0 ，使用 `par(first-line-indent: (length, all: true))` 代替原有的 `fake-par` 方案。
- 改用更优的页眉显示章节标题逻辑，详见 `seu-thesis\utils\get-heading-title.typ` 注释。
- 添加毕设翻译模板。

## [0.3.1] - 2025-01-26

- 适配 Typst 0.12.0 。

## [0.3.0] - 2024-07-07

- 尝试弃用大部分自造轮子，改为通过引入第三方 package 实现相关功能。
- 规范化模板参数/变量名。
- 校对毕设模板的间距。 [^1]

[^1]: 由于 Typst 使用的行距模型与 Word 不同，行距难以保持完全一致。

### Breaking Changes 破坏性变更

- `#import` 方式改变：由原来的
  ```typst
  // 毕设
  #import "@preview/cheda-seu-thesis:0.2.2": bachelor-conf, thanks, appendix
  // 学位
  #import "@preview/cheda-seu-thesis:0.2.2": degree-conf, thanks, appendix
  ```
  更改为
  ```typst
  // 毕设
  #import "@preview/cheda-seu-thesis:0.3.0": bachelor-conf, bachelor-utils
  #let (thanks, show-appendix) = bachelor-utils
  // 学位
  #import "@preview/cheda-seu-thesis:0.3.0": degree-conf, degree-utils
  #let (thanks, show-appendix) = degree-utils
  ```
  本模板暂未计划完全改为闭包。
- 进入附录章节的方式改变：
  - 由 `#appendix()` 变为 `#show: shou-appendix`；
  - `#bibliography` 不再会自动进入附录。
- 引用图表的方式改变：
  - 由自造轮子改为使用 `i-figured` ；
  - 需要将旧版本的 `@xxx` 修改为对应类型的 `@tbl:xxx` `@fig:xxx` `@eqt:xxx` 。
- 模板参数格式改变：详见对应模板的 demo 。
- 不再使用 `state` 储存章节标题与章节编号。

### 改进

- 使用 `i-figured` 代替自造的公式编号引用轮子。
- 使用自带的 `outline` 代替自造的目录页轮子。
- 统一变量、参数等的命名风格。
- 不再使用大量 `state` 。
- 更新学位论文授权声明文字。

### 修复

- 修复学位论文页眉读取章节号、名称时可能取到 `none` 的问题。
- 修复毕设引用文献中不显示末尾 `.` 的问题。

## [0.2.2] - 2024-05-18

### 改进

- 学位论文改为使用 Typst 0.11.0 增加的公式编号位置参数代替原有的公式编号对齐轮子。
- 拆分 CSL 文件，按本研不同的要求分为两个文件。

## [0.2.1] - 2024-05-02

### 新功能

- 允许控制学位论文的一级标题页面是否显示页眉。

### 改进

- 优化资源文件大小。

## [0.2.0] - 2024-04-15

此版本重构了目录结构，合并两个模板的大部分工具函数，并按 Typst template package 组织文件。

[0.3.3]: https://github.com/csimide/SEU-Typst-Template/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/csimide/SEU-Typst-Template/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/csimide/SEU-Typst-Template/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/csimide/SEU-Typst-Template/compare/c44b5172178c0c2380b322e50931750e2d761168...v0.3.0
[0.2.2]: https://github.com/csimide/SEU-Typst-Template/compare/908a28c7da02b260f04dcf31ed22278a212cad19...c44b5172178c0c2380b322e50931750e2d761168
[0.2.1]: https://github.com/csimide/SEU-Typst-Template/compare/42b34b829bb9816d89a0955e2196346ab6e39ad4...908a28c7da02b260f04dcf31ed22278a212cad19
