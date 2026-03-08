// 本模板基于lib模板https://github.com/talal/ilm 使用DeepSeek修改而成
// This template is based on the lib template https://github.com/talal/ilm and modified by DeepSeek

#import "../themes/index.typ" : * // 导入主题设置模块 / Import theme settings module

#import "book.typ" : * // 导入主模块 / Import main module

// 用增加字符间距的函数覆盖默认的 `smallcaps` 和 `upper` 函数。
// Override default `smallcaps` and `upper` functions with increased character spacing.
// 默认的字间距（tracking）是 0.6pt。
// Default character tracking is 0.6pt.
// 设置字间距
// Set character tracking
#let character-spacing = 0.6pt
#let smallcaps(body) = std-smallcaps(text(tracking: character-spacing, body))
#let upper(body) = std-upper(text(tracking: character-spacing, body))
