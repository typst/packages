# 基于 Typst 的中山大学学位论文模板
[![GitLab 仓库](https://gitlab.com/sysu-gitlab/thesis-template/better-thesis/-/badges/release.svg?style=flat-square&value_width=100)](https://gitlab.com/sysu-gitlab/thesis-template/better-thesis/-/releases) [![GitHub stars](https://img.shields.io/github/stars/sysu/better-thesis.svg?style=social&label=Star&maxAge=2592000)](https://github.com/sysu/better-thesis)

**[点击此处注册 typst.app 并创建你的论文工程](https://typst.app/app?template=modern-sysu-thesis&version=0.1.1)**

当前还未完全符合学位论文格式要求，欢迎同学/校友们[贡献代码](https://gitlab.com/sysu-gitlab/thesis-template/better-thesis/-/merge_requests)/反馈问题（[GitLab issue](https://gitlab.com/sysu-gitlab/thesis-template/better-thesis/-/issues)/[邮件](mailto:contact-project+sysu-gitlab-thesis-template-better-thesis-57823416-issue-@incoming.gitlab.com)）！模板交流 QQ 群：[797942860](https://jq.qq.com/?_wv=1027&k=m58va1kd)

**Q：我不会 LaTeX，可以用这个模板写论文吗？**

**A：完全可以！Typst 是一个比 LaTeX 更简单的排版语言，同时安装更加方便，编译更加快速！**

## 使用方法

### typst.app
经过近一月紧张的迭代重构，本模板已经[发布在typst.universe](https://typst.app/universe/package/modern-sysu-thesis)上，[点击此处直接创建你的论文工程](https://typst.app/app?template=modern-sysu-thesis&version=0.1.1)，并直接开始编写你的论文！

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
