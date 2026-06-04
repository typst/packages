#import "@preview/scripst:1.1.0": *

= 使用 Scripst 排版 Typst 文档

== 使用 Typst

Typst 是使用起来比 LaTeX 更轻量的语言，一旦模板编写完成，就可以用类似 Markdown 的轻量标记完成文档的编写。

相比 LaTeX，Typst 的优势在于：
- 极快的编译速度
- 语法简单、轻量
- 代码可扩展性强
- 更简单的数学公式输入
- ...

所以，Typst 非常适合轻量级日常文档的编写。只需要花费撰写 Markdown 的时间成本，就能得到甚至好于 LaTeX 的排版效果。

可以通过下面的方式安装 Typst：

```bash
sudo apt install typst # Debian/Ubuntu
sudo pacman -S typst # Arch Linux
winget install --id Typst.Typst # Windows
brew install typst # macOS
```

你也可以在#link("https://github.com/typst/typst")[Typst的GitHub仓库]中找到更多的信息。

== 使用 Scripst

在 Typst 的基础上，Scripst 提供了一些简约的，可便利日常文档生成的模板样式。

=== 解压使用

可以在#link("https://github.com/An-314/scripst")[Scripst的GitHub仓库]找到并下载 Scripst 的模板。

可以选择 `<> code` $->$ `Download ZIP` 来下载 Scripst 的模板。在使用时，只需要将模板文件放在你的文档目录下，然后在文档的开头引入模板文件即可。

#caution(count: false)[
  要考虑清楚项目的目录结构，以便正确引入模板文件。
  ```
  project/
  ├── src/
  │   ├── main.typ
  │   ├── ...
  │   └── components.typ
  ├── pic/
  │   ├── ...
  ├── main.typ
  ├── chap1.typ
  ├── chap2.typ
  ├── ...
  ```
  如果项目的目录结构如上所示，那么在 `main.typ` 中引入模板文件的方式应该是：
  ```typst
  #import "src/main.typ": *
  ```
]

这种方法的好处是，你可以随时调整模板中的部分参数。Script模板采用模块化设计，你可以轻松找到并修改模板中你需要修改的部分。

=== 本地包管理

*一个更好的方法是*，参考官方给出的#link("https://github.com/typst/packages?tab=readme-ov-file#local-packages")[本地的包管理文档]，将模板文件放在本地包管理的目录`{data-dir}/typst/packages/{namespace}/{name}/{version}`下，这样就可以在任何地方使用 Scripst 的模板了。

当然，无需担心模板文件难以修改，你可以直接在文档中使用`#set, #show`等指令来覆盖模板中的部分参数。

例如该模板的应该放在
```
~/.local/share/typst/packages/preview/scripst/1.1.0               # in Linux
%APPDATA%\typst\packages\preview\scripst\1.1.0                    # in Windows
~/Library/Application Support/typst/packages/local/scripst/1.1.0  # macOS
```
你可以执行指令
```bash
cd ~/.local/share/typst/packages/preview/scripst/1.1.0
git clone https://github.com/An-314/scripst.git 1.1.0
```
如果是这样的目录结构，那么在文档中引入模板文件的方式应该是：
```typst
#import "@preview/scripst:1.1.0": *
```
这样的好处是你可以直接通过`typst init`来一键使用模板创建新的项目：
```bash
typst init @preview/scripst:1.1.0 project_name
```
#newpara()

=== 在线包管理

我们将尽快提交至社区，以便您可以直接在文档中使用
```typst
#import "@preview/scripst:1.1.0": *
```
来引入 Scripst 的模板。你也可以通过`typst init`来一键使用模板创建新的项目：
```bash
typst init @preview/scripst:1.1.0 project_name
```

这种方法无需下载模板文件，只需要在文档中引入即可。
