#import "lib.typ": *

= 补充说明

== 贡献代码

本仓库为示例代码，模板代码位于 `uestc-thesis-template` 目录中。欢迎大家贡献代码。

== 常见问题

=== 编译命令

编译需要指定根目录参数 `--root .`，在 makefile 中已配置好：

#block(width: 100%)[
  #set align(center)
  #block(breakable: false)[
    #set align(left)
    ```bash
    typst compile --root . main.typ output.pdf
    ```
  ]
]

=== 字体问题

如果中英文之间、符号与中文中间出现错位，通常是字体原因。

- Windows 默认字体 `SimHei`（黑体）和 `SimSun`（宋体）无需额外安装
- macOS/Linux 建议使用思源字体，修改 `main.typ` 中的字体设置：
  - `info-keys.黑体字体: "Source Han Sans SC"`
  - `info-keys.宋体字体: "Source Han Serif SC"`

=== Typst 版本

本模板要求 Typst 版本 >= 0.13.0，可以通过 `typst --version` 检查。
