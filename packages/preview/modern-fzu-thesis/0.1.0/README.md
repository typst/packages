# 福州大学本科生毕业设计(论文) Typst 模板



>[!CAUTION]
> 不要在克隆下来的模板仓库里面写论文! 也不要编辑模板里的内容! 只有在你需要自定义编辑模板或者你知道你自己在干什么的时候这么做. 克隆仓库并安装模板之后, 你应该在另一个地方新建一个 typst 项目, 在项目里引用这个模板, 然后开始你的论文编写.

>[!WARNING]
> WIP. 目前仅适配了本科生理工科论文格式.

>[!CAUTION]
> 非官方模板, 存在不被学校认可的风险。

>[!NOTE]
>本模板主要由 [modern-nju-thesis](https://github.com/nju-lug/modern-nju-thesis) 迁移而来。在此感谢 [OrangeX4](https://github.com/OrangeX4) 的贡献!

![模板封面](./thumbnail.png)

依照学校官方通知[关于做好2025届本科生毕业设计（论文）工作的通知](https://jwch.fzu.edu.cn/content.jsp?urltype=news.NewsContentUrl&wbtreeid=1039&wbnewsid=13791)，基于2025届福州大学本科生毕业设计（论文）相关规范设计。适配了规范中本科生理工科论文格式。


## 前提条件

1. Typst

MacOS/Linux 用户可以使用 brew 安装 Typst

```bash
brew install typst
```

Windows 用户可以使用 winget 安装 Typst

```powershell
winget install typst
```

2. (Optional) Typst vscode 插件

Tinymist Typst 插件可以让你在 vscode 中获得更好的编辑体验。



## 使用方法

由于本模板尚未上传至 Typst Universe，因此推荐在本地安装配置本模板之后，使用 vscode 本地编辑你的论文。

你可以使用 typship，在仓库目录下执行，来安装本模板。

```bash
typship install local
```

如果你不想安装 typship，本项目也提供了安装脚本方便你快速安装本模板，执行脚本之后会将本仓库的文件复制到你本地 typst 包管理的 local namespace 中。

scripts 目录中包含了不同平台的安装脚本，你可以根据你的平台选择对应的脚本执行。

```bash
# MacOS/Linux
./scripts/install-macos.sh
```

```bash
# Windows
./scripts/install-windows.bat
```

```powershell
# Windows PowerShell
./scripts/install-windows.ps1
```

安装成功后你可以使用 `typst init` 来初始化一个 typst 项目。

```bash
typst init "@local/modern-fzu-thesis:0.1.0"
```

或者你需要完全从头开始，可以直接在任意 typst 文件中通过

```typst
#import "@local/modern-fzu-thesis:0.1.0": *
```

来导入本模板。

## 注意事项

更多信息可以参考 [README.nju.md](./README.nju.md) 。