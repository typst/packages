# 河海大学本科毕业论文（设计）模板（工科）

使用 Typst 制作的河海大学「本科毕业设计（论文）报告」模板（工科）。官方模板参考[河海大学本科毕业设计（论文）规范格式参考](https://bylw.hhu.edu.cn/UpLoadFile/83cd5f1169974a0db06d865c7ee11af4.pdf)

> [!IMPORTANT]
>
> 此模板非官方模板，可能仍存在一些问题，后续会不断更新完善。
>
> 此模板仅适用于工科专业本科毕业论文（设计），后续可能会更新文科模板。
>
> 本模板使用 Typst 0.12.x 编译，Typst 更新频率较高，可能出现版本更新后无法编译成功的情况。

![demo](./demo_images/title.png)

## 使用方法

模板已上传 Typst Universe ，可以使用 `typst init` 功能初始化，也可以使用 Web APP 编辑。**Typst Universe 上的模板可能不是最新版本。如果需要使用最新版本的模板，从本 repo 中获取。**

#### 本地使用（推荐）

使用前，请先安装 `https://github.com/shaneworld/Dots/tree/master/fonts` 中的全部字体。

- 克隆本 repo 到本地，编辑 `init-files` 目录内的文件。

- 使用 `typst init @preview/shane-hhu-thesis:0.1.0` 本地初始化模板。

#### Web APP 内使用

由于 Typst Web APP 在每次打开页面的时候都会从服务器中下载字体，速度较慢，体验较差，因此不建议使用此方法。

在 [Typst Universe](https://typst.app/universe/package/shane-hhu-thesis) 中点击 `Create project in app` 按钮进入 Web APP 内。

然后，请将 `https://github.com/shaneworld/Dots/tree/master/fonts` 内的所有字体上传到 Web APP 内该项目的根目录后按照提示使用。

## 模板内容

此 Typst 模板按照[《河海大学本科毕业设计（论文）基本规范(修订)》](https://bylw.hhu.edu.cn/UpLoadFile/83cd5f1169974a0db06d865c7ee11af4.pdf)制作，制作时参考了[东南大学制作的 Typst 模板](https://github.com/csimide/SEU-Typst-Template)。

目前包含以下页面：

- [x] 中英文封面
- [x] 郑重声明
- [x] 中英文摘要
- [x] 目录
- [x] 正文
- [x] 致谢
- [x] 参考文献
- [x] 附录

此论文模板不仅适用于本科生毕业论文/设计，同样适用于平时的课程报告等规范内容。可以通过自定义 `form` 字段更改论文种类，有以下3种格式可供选择：

- `thesis`：毕业论文
- `design`：毕业设计
- `report`：课程报告

可以通过修改 `heading` 字段修改页眉内容，修改 `thesis-name` 下的 `CN` 字段修改封面页面展示的标题。

如果发现模板的问题，欢迎提交 issue。

## 致谢

- 东南大学论文模板：[csimide/SEU-Typst-Template](https://github.com/csimide/SEU-Typst-Template)

- 北京大学本科生毕业论文模板：[sigongzi/pkuthss-typst-undergraduate](https://github.com/sigongzi/pkuthss-typst-undergraduate)
