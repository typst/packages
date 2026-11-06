# 基于 Typst 的中山大学学位论文模板
[![GitLab 仓库](https://gitlab.com/sysu-gitlab/thesis-template/better-thesis/-/badges/release.svg?style=flat-square&value_width=100)](https://gitlab.com/sysu-gitlab/thesis-template/better-thesis/-/releases) [![GitHub stars](https://img.shields.io/github/stars/sysu/better-thesis.svg?style=social&label=Star&maxAge=2592000)](https://github.com/sysu/better-thesis)

**[点击此处注册 typst.app 并创建你的论文工程](https://typst.app/app?template=modern-sysu-thesis&version=0.1.1)**

本科生模板已经符合学位论文格式要求（[#6](https://gitlab.com/sysu-gitlab/thesis-template/better-thesis/-/issues/6)），欢迎同学/校友们[贡献代码](https://gitlab.com/sysu-gitlab/thesis-template/better-thesis/-/merge_requests)/反馈问题（[GitLab issue](https://gitlab.com/sysu-gitlab/thesis-template/better-thesis/-/issues)/[邮件](mailto:contact-project+sysu-gitlab-thesis-template-better-thesis-57823416-issue-@incoming.gitlab.com)）！

模板交流 QQ 群：[797942860](https://jq.qq.com/?_wv=1027&k=m58va1kd)


## 参考规范
- 本科生论文模板参考 [中山大学本科生毕业论文（设计）写作与印制规范 2020年发](https://spa.sysu.edu.cn/zh-hans/article/1744)
- 研究生论文模板参考 [中山大学研究生学位论文格式要求](https://graduate.sysu.edu.cn/sites/graduate.prod.dpcms4.sysu.edu.cn/files/2019-04/%E4%B8%AD%E5%B1%B1%E5%A4%A7%E5%AD%A6%E7%A0%94%E7%A9%B6%E7%94%9F%E5%AD%A6%E4%BD%8D%E8%AE%BA%E6%96%87%E6%A0%BC%E5%BC%8F%E8%A6%81%E6%B1%82.pdf)

## 使用方法

### typst.app
经过近一月紧张的迭代重构，本模板已经[发布在typst-app.universe](https://typst.app/universe/package/modern-sysu-thesis)上，[点击此处直接创建你的论文工程](https://typst.app/app?template=modern-sysu-thesis&version=0.2.0)，并直接开始编写你的论文！

<!-- TODO(#1): 在 typst.universe 版本上线后分离模板项目 -->

### Windows 用户

1. [下载本仓库](https://gitlab.com/sysu-gitlab/thesis-template/better-thesis/-/archive/main/better-thesis-main.zip)，或者使用 `git clone https://gitlab.com/sysu-gitlab/thesis-template/better-thesis` 命令克隆本仓库。
2. 右键 `install_typst.ps1` 文件，选择“用 Powershell 运行”，等待 Typst 安装完成。
3. 根据 [Typst 文档](https://typst.app/docs/)，参考 [项目结构](#项目结构) 中的说明，按照你的需要修改论文的各个部分。
4. 双击运行 `compile.bat`，即可生成 `thesis.pdf` 文件。

### Linux/macOS 用户

1. [下载本仓库](https://gitlab.com/sysu-gitlab/thesis-template/better-thesis/-/archive/main/better-thesis-main.zip)，或者使用 `git clone https://gitlab.com/sysu-gitlab/thesis-template/better-thesis` 命令克隆本仓库。
2. 使用命令行安装 Rust 工具链以及 Typst：

```bash
# 安装 Rust 环境并激活，之前安装过则不需要执行下面这两行
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# 安装 Typst CLI
cargo install typst-cli

# 访问缓慢的话，执行以下命令设置清华镜像源，并从镜像站安装
cat << EOF > $HOME/.cargo/config
[source.crates-io]
replace-with = "tuna"

[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
EOF
cargo install typst-cli
```

3. 根据 [Typst 文档](https://typst.app/docs/)，参考 [项目结构](#项目结构) 中的说明，按照你的需要修改论文的各个部分。
4. 执行 `make` 命令，即可生成 `thesis.pdf` 文件。

## 项目结构
详见 `template\thesis.typ`

## FAQ
### 为什么 XXX 的功能不能用/不符合预期？
1. 先参考 [Typst 中文支持相关问题](https://typst-doc-cn.github.io/docs/chinese/)，以及 [Typst 官方文档](https://typst.app/docs/) 与 [tpyst.app/universe 仓库](https://typst.app/universe)，了解相关问题进展或解决方案
2. 如果在以上资料中找不到关联资料，可以参考是否在的 [issue 列表](https://gitlab.com/sysu-gitlab/thesis-template/better-thesis/-/issues) 中能找到相关问题与进展。
3. 如果依然没有线索，欢迎反馈问题（[GitLab issue](https://gitlab.com/sysu-gitlab/thesis-template/better-thesis/-/issues)/[邮件](mailto:contact-project+sysu-gitlab-thesis-template-better-thesis-57823416-issue-@incoming.gitlab.com)）

### 为什么学校学位论文已经有了 [LaTeX 模板](https://github.com/SYSU-SCC/sysu-thesis)，还有 Typst 模板？
- 前述 LaTeX 模板目前仅有计算机学院官方指定使用，其他学院并没有统一指定
- 考虑到 LaTeX 对于大部分非计算机/理工科的学生入门成本比较高，因此有必要提供一种更加简洁清晰并且方便的论文模板，包括：
    - 开箱即用：
        - 如[前文所述](#typstapp)，本模板提供了在线直接编辑/保存/备份方案
        - 本地使用模板时，模板组件可以简单地通过 `typst` 命令自动管理安装
    - 语法简洁：typst 是与 markdown 类似的标记性语言，可以通过标记的方式来轻松控制语法（如`= 标题`、`*粗体*`、`_斜体_` `@引用`、 数学公式`$E = m c^2$`）

### 为什么有两份 Typst 模板（[sysu-thesis-typst] 和 modern-sysu-thesis）？
后者是在前者的基础上，同时参考 [modern-nju-thesis] ，改造后适配了 [typst.app/universe](https://typst.app/universe)。以及，放到 [@sysu](https://github.com/sysu) 组织下提高了曝光度。

## 致谢
- 感谢 [sysu-thesis-typst] 提供了中山大学的页面样式与初版源码
- 感谢 [modern-nju-thesis] 提供了一个更好的代码组织架构
- 感谢中山大学 Typst 模板交流群（[797942860](https://jq.qq.com/?_wv=1027&k=m58va1kd)）、Typst 中文交流群（793548390）群友的帮助交流。

[sysu-thesis-typst]: https://github.com/howardlau1999/sysu-thesis-typst
[modern-nju-thesis]: https://typst.app/universe/package/modern-nju-thesis
