# Changelog

## 0.5.0 - 2025-05-17

### Fixed

- 修复参考文献格式问题，基于 GB7714-2005 格式，并适当修改：
    
    - 英文文献相关字符用英文表示，如 “等” 使用 “et al” 表示，中文文献反之
    - 作者英文名只有首字母大写

- 大括号内多行数学公式字体显示过小问题，增加公式间距

### Added

针对 bib 文件自动导入的参考文献信息参差不齐问题，需手动完善 bib 文件中的参考文献字段信息，README 中新增 BibTex 格式修改指南。

## 0.4.0 - 2025-04-25

### Fixed

编号后不换行问题 ([#2](https://github.com/shaneworld/HHU-Thesis-Template/pull/2))

### Changed

更新 README 中的过时内容，完善本地部署步骤

### Added

- 添加参考文献格式（GB7714-2005）
- 提供了更加灵活的 label-content 框，支持自适应长度和手动换行。([#3](https://github.com/shaneworld/HHU-Thesis-Template/pull/3))

### Contributors

- [@Met4physics](https://github.com/Met4physics)
- [@X1ngChui](https://github.com/X1ngChui)

## 0.3.0 - 2025-02-26

### Fixed

代码块后的首段无首行缩进

### Changed

- 调整目录不同层级缩进，统一目录字号
- 减小图片与上下文距离

## 0.2.0 - 2024-11-15

### Fixed

- 审阅人和 `subject` 参数不生效。
- 图表后的段落需要手动进行首行缩进。
- 修复有序列表序号与文本不对齐的问题。

### Removed

- 移除 `fake-par`。
- 移除 `outline-conf` 中对一级标题的设置。
- 移除 `sourcer` 包。
- 移除 `term` 下划线函数。
- 移除 `fieldvalue` 下划线函数。

### Added

- 添加 `form` 参数自定义论文格式。
- 添加参考文献引用格式为 `gb-7714-2005-numeric`。
- 添加图表与上下正文之间的间距。

### Changed

- 调整封面下划线文字的上下偏移，视觉效果与前文更协调。
- 更改 `title` 标题配置项为 `[]` 可换行的配置方式。
- 调整目录行距为1.5倍。
- 修改英文封面论文信息的对齐方式。


## 0.1.0 - 2024-11-14

_Initial release._

[0.1.0]: https://github.com/shaneworld/HHU-Thesis-Template/releases/tag/v0.1.0
