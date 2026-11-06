# CTyp

CTyp is a Typst package providing basic Chinese typography support.
This package integrates some common Chinese typography settings for a quick Chinese typesetting experience.
As the Chinese typesetting support in Typst is still under development, this package can only provide non-language-level typesetting support and does not guarantee to meet all Chinese typesetting needs.
Considering this package is mainly for Chinese users, the remainder of this README is currently only available in Chinese.

CTyp 是一个用于提供 Typst 中文排版支持的包。
该包集成了一些常用的中文排版设置，用于提供快速的中文排版体验。

> [!WARNING]
> 由于 Typst 的中文排版支持仍不完善，该包只能提供非语言级的排版支持。
> 并不保证能够实现所有中文排版需求。

## 快速开始

通过以下代码快速使用 CTyp 包的设置，默认使用 Fandol 字体（需自行安装）：

```typ
#import "@preview/ctyp:0.1.1": ctyp
#let (ctypset, cjk) = ctyp()
#show: ctypset
```

> [!NOTE]
> 变量名 `ctypset` 和 `cjk` 可以自行设置，无需使用文档中的名字。

如果在 Typst Web App 环境中，可以直接使用 Noto CJK 字体系列。

```typ
#import "@preview/ctyp:0.1.1": ctyp
#let (ctypset, cjk) = ctyp(
  fontset-cjk: "noto"
)
#show: ctypset
```

## 主要功能

- [x] 中文字体设置
- [x] 页面边距根据字符数控制
- [x] 列表符号/编号基线位置修复

具体功能请参考[使用手册](doc/manual.pdf)或 Wiki。

## 开发路线

- [ ] 使用 [Elembic](https://typst.app/universe/package/elembic) 包实现可配置的元素。
- [ ] 接口修改为类似于 [Touying](https://typst.app/universe/package/touying) 中的 `config-*` 函数。
- [ ] 根据 [Chinese layout gap analysis](https://typst-doc-cn.github.io/clreq/) 文档尽可能实现更多中文排版需求。

## 贡献

欢迎提交 PR 或 Issue。

## 许可证

CTyp 使用 [MIT 许可证](LICENSE)。
