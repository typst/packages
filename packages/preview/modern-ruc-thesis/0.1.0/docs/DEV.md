# 开发者指南

感谢你对 `ruc-thesis-typst` 感兴趣！本文档旨在帮助开发者理解项目结构并参与贡献。

## 📚 文档导航

- [排版要求 (requirements.md)](requirements.md): 详细记录了学校对毕业论文的排版要求（字号、页边距等），开发时请严格参考此文档。

## 🏗️ 项目结构

```
ruc-thesis-typst/
├── typst.toml              # [核心] 包配置文件
├── lib.typ                 # [核心] 模板入口文件
├── docs/                   # [文档] 开发与使用文档
│   ├── requirements.md     # [参考] 排版要求文档
│   └── DEV.md              # 开发者指南
├── assets/                 # [资源] 存放模板必须的静态资源
│   └── ruc-logo-header.png # 页眉用的学校Logo
├── src/                    # [源码] 模板的具体实现逻辑
│   ├── fonts.typ           # 字体定义
│   ├── utils.typ           # 辅助函数
│   ├── pages/              # [页面] 各个功能页面的实现
│   │   ├── abstract.typ    # 摘要
│   │   ├── acknownledge.typ # 致谢
│   │   ├── appendix.typ    # 附录
│   │   ├── cover.typ       # 封面
│   │   ├── declaration.typ # 声明
│   │   ├── outline.typ     # 目录
│   │   └── signature.typ   # 签名页
│   └── styles/             # [样式] 通用样式定义
│       ├── body.typ        # 正文样式
│       └── header.typ      # 页眉样式
└── template/               # [示例] 用户写作目录
    ├── main.typ            # 主入口
    ├── refs.bib            # 参考文献
    ├── assets/             # 用户图片
    └── chapters/           # 章节内容
```

## 📝 Git 提交规范

为了保持提交历史的整洁，请遵循以下 Commit Message 规范：

Format: `<type>(<scope>): <subject>`

**Type (类型):**
- `feat`: 新功能 (feature)
- `fix`: 修补 bug
- `docs`: 文档修改 (documentation)
- `style`: 代码格式修改 (不影响代码运行的变动)
- `refactor`: 重构 (即不是新增功能，也不是修改 bug 的代码变动)
- `chore`: 构建过程或辅助工具的变动

**Scope (范围):**
- 指明修改的文件或模块，例如 `cover`, `fonts`, `README` 等。

**Subject (主题):**
- 简短描述本次修改的内容。

**示例:**
- `feat(cover): 完成封面布局实现`
- `fix(fonts): 修正宋体字体回退逻辑`
- `docs(README): 更新安装说明`

## 🔄 开发流程

1.  **环境准备**：确保安装了最新版本的 Typst CLI。
2.  **修改源码**：主要逻辑位于 `src/` 目录下。
3.  **测试验证**：修改后，请编译 `template/main.typ` 查看效果。
    ```bash
    typst compile template/main.typ
    ```
4.  **提交代码**：请确保代码风格整洁，并提交 Pull Request。

## 贡献方向

- 修复排版 Bug
- 适配更多学院的特殊要求
- 改进文档
