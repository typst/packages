# 主题开发指南 (Theme Development Guide)

非常欢迎社区开发者贡献更多精美的主题！为了保证生态的统一和高可用性，请在开发主题时严格遵守以下规范。

---

## 1. 目录结构规范

每一个新主题必须放置在 `themes/<主题名>/` 目录下，并且至少包含以下两个核心文件：

```text
themes/my-theme/
├── template.typ    # 1. 核心渲染代码，导出 blueprint() 函数
└── example.typ     # 2. 专属预览入口（无需修改项目根目录即可独立编译预览）
```

---

## 2. 模块化渲染协议（推荐）

为了让主题开发更简单、更统一，本项目提供了 **模块化渲染协议**（`themes/module-core.typ`）。

### 核心理念

将简历分为以下几类模块，主题作者只需为每类模块设计样式：

1. **resume-info** - 个人信息（姓名、头像、联系方式等）
2. **education** - 教育经历
3. **experience** - 工作经历
4. **projects** - 项目经历
5. **internship** - 实习经历
6. **skills** - 个人技能
7. **awards** - 荣誉奖项
8. **certificates** - 资质证书
9. **自定义模块** - 用户可以在 `data.yml` 中添加任意其他模块

### 使用方法

在你的 `template.typ` 中引入模块协议：

```typst
#import "../module-core.typ": standard-modules

#let blueprint(data: (:), body) = {
  // 获取所有模块
  let modules = standard-modules(data)

  // 遍历渲染每个模块
  for module in modules {
    if module.id == "resume-info" {
      // 渲染头部个人信息
      render-header(module.payload)
    } else if module.id == "education" {
      // 渲染教育经历
      render-section(module.title)
      for item in module.payload {
        render-education-item(item)
      }
    } else if module.id == "experience" {
      // 渲染工作经历
      render-section(module.title)
      for item in module.payload {
        render-experience-item(item)
      }
    } else if module.id == "projects" {
      // 渲染项目经历
      render-section(module.title)
      for item in module.payload {
        render-project-item(item)
      }
    } else if module.id == "internship" {
      // 渲染实习经历
      render-section(module.title)
      for item in module.payload {
        render-internship-item(item)
      }
    } else if module.id == "skills" {
      // 渲染技能列表
      render-section(module.title)
      render-skills(module.payload)
    } else {
      // 渲染自定义模块（通用处理）
      render-section(module.title)
      render-custom-content(module.payload)
    }
  }

  body
}
```

### 模块数据结构

每个模块是一个字典，包含以下字段：

- `id` (string): 模块的唯一标识符
- `title` (string): 模块的显示标题（从 `data.yml` 的 `module-config` 读取）
- `payload` (any): 模块的数据内容

### 用户如何自定义

用户可以在 `data.yml` 中通过 `module-config` 控制模块顺序，每个段落的标题直接写在段落数据内：

```yaml
# 控制模块渲染顺序
module-config:
    module-order:
        - "resume-info"
        - "education"
        - "experience"
        - "projects"
        - "internship"
        - "skills"
        - "awards"
        - "certificates"

# 段落标题直接内嵌在数据中
education:
    title: "教育背景" # 自定义段落标题
    items:
        - school: "..."
          # ...

# 自定义模块（会自动被检测）
awards:
    title: "获奖情况"
    items:
        - title: "国家奖学金"
          date: "2023"
```

---

## 3. 接口标准规范（传统方式）

如果不使用模块化协议，`template.typ` 必须导出一个名为 `blueprint` 的入口函数，并接收 `data` 字典作为参数。**字体完全由主题自主决定**，在 `blueprint` 内部定义：

```typst
#let blueprint(
  data: (:),
  body,
) = {
  // 主题字体配置（由主题作者决定）
  let fonts-theme = ("Heiti SC", "Heiti SC")

  // 应用字体
  set text(font: fonts-theme)

  // 渲染逻辑...
}
```

---

## 4. 预览入口规范 (example.typ)

在你的主题目录中，必须提供 `example.typ` 用于独立预览：

```typst
#import "template.typ": blueprint

#let data = yaml("../../data.yml")  // 引用项目根目录的数据

#show: blueprint.with(data: data)
```

**预览命令：**

```bash
typst compile themes/my-theme/example.typ --root .
```

---

## 5. 数据健壮性规范（非常重要）

在从 `data` 字典中提取数据时，**必须提供默认值 (default)**，避免用户未填写某字段时导致编译崩溃。

```typst
// ✅ 正确做法：
let resume-info = data.at("resume-info", default: (:))
let avatar = resume-info.at("avatar", default: "")
let education = data.at("education", default: ())

// ❌ 错误做法（会导致崩溃）：
// let avatar = data.resume-info.avatar
```

---

## 6. 代码规范

### 命名规范

- 使用 kebab-case（连字符）命名**所有**函数和变量：
    - ✅ 正确：`resume-item`, `chi-line`, `fa-home`, `contact-icon`
    - ❌ 错误：`resume_item`, `chiline`, `fa_home`

### 代码组织

- 用分隔注释块组织代码，提高可读性：

    ```typst
    // ─────────────────────────────────────────────────────────
    //  图标定义
    // ─────────────────────────────────────────────────────────

    #let icon(symbol) = { ... }

    // ─────────────────────────────────────────────────────────
    //  辅助函数
    // ─────────────────────────────────────────────────────────

    #let format-date(date) = { ... }
    ```

### 函数写法

- 对于有多个参数的函数，使用命名参数：
    ```typst
    #let resume-item(title: "", position: "", detail: "", time: "") = {
      // ...
    }
    ```

---

## 7. 统一 YAML 数据规范

所有主题必须支持以下统一的 YAML 数据格式。每个段落使用 `{title, items}` 字典结构，`title` 为段落标题，`items` 为条目数组。

### 模块配置 (module-config)

```yaml
module-config:
    module-order: # 段落渲染顺序
        - "resume-info"
        - "education"
        - "experience"
        - "projects"
        - "internship"
        - "skills"
        - "awards"
        - "certificates"
```

### 个人信息 (resume-info)

```yaml
resume-info:
    title: "个人信息" # 段落标题（可选）
    name: "" # 姓名（必填）
    avatar: "" # 头像路径（可选）
    contacts: # 所有个人信息和联系方式统一使用此格式
        - type: "phone" # 类型（控制图标）
          label: "手机号" # 字段名
          value: "138xxxx" # 显示值
          url: "" # 可点击链接（可选）
        - type: "email"
          label: "邮箱"
          value: "xxx@example.com"
          url: "mailto:xxx@example.com"
        - type: "gender"
          label: "性别"
          value: "男"
        - type: "birthday"
          label: "生日"
          value: "2000-01-01"
        - type: "city"
          label: "所在城市"
          value: "上海"
        - type: "motto"
          label: "座右铭"
          value: "一句话签名"
    summary: "" # 个人简介（可选，多行文本）
    self-evaluation: "" # 自我评价（可选，多行文本）
    interests: [] # 兴趣爱好（可选，字符串数组）
```

> **设计说明**：resume-info 只保留 `name` 和 `avatar` 两个独立字段，其他所有个人信息（性别、生日、城市、座右铭、联系方式等）统一放在 `contacts` 数组中，通过 `type` 字段区分类型，方便主题添加图标和统一渲染。

### 教育经历 (education)

```yaml
education:
    title: "教育经历"
    items:
        - school: "" # 学校名称
          degree: "" # 学位
          major: "" # 专业
          start: "" # 开始时间
          end: "" # 结束时间
          location: "" # 地点（可选）
          details: # 详情列表
              - "..."
```

### 工作经历 (experience)

```yaml
experience:
    title: "工作经历"
    items:
        - company: "" # 公司名称
          position: "" # 职位（统一用 position）
          start: ""
          end: ""
          location: "" # 地点（可选）
          details:
              - "..."
```

### 项目经历 (projects)

```yaml
projects:
    title: "项目经历"
    items:
        - name: "" # 项目名称
          role: "" # 担任角色
          start: ""
          end: ""
          url: "" # 项目链接（可选）
          github: "" # GitHub 链接（可选）
          details:
              - "..."
```

### 实习经历 (internship)

```yaml
internship:
    title: "实习经历"
    items:
        - name: "" # 项目/公司名称
          role: "" # 担任角色
          start: ""
          end: ""
          url: "" # 项目链接（可选）
          github: "" # GitHub 链接（可选）
          details:
              - "..."
```

### 技能 (skills)

支持三种格式混用：

```yaml
skills:
    title: "技能"
    items:
        # 格式1：结构化
        - name: "Python"
          level: "精通"
          description: "5年经验"
        # 格式2：纯字符串
        - "熟悉 Docker/K8s 等容器化技术"
        # 格式3：分组
        - category: "前端"
          items: ["React", "Vue"]
```

### 荣誉奖项 (awards)

```yaml
awards:
    title: "荣誉奖项"
    items:
        - title: "" # 奖项名称
          date: "" # 获奖时间
```

### 资质证书 (certificates)

```yaml
certificates:
    title: "资质证书"
    items:
        - name: "" # 证书名称
          date: "" # 获证时间
          org: "" # 颁发机构（可选）
```

### module-core.typ 辅助函数

主题可从 `module-core.typ` 导入以下常用工具：

| 函数                                        | 说明                                                                  |
| ------------------------------------------- | --------------------------------------------------------------------- |
| `standard-modules(data)`                    | 将 YAML 数据解析为标准化模块数组，每个模块含 `id`, `title`, `payload` |
| `extract-items(section-data)`               | 从段落数据中提取 items 数组（兼容裸数组和 `{title, items}` 字典）     |
| `extract-title(section-data, fallback: "")` | 从段落数据中提取标题                                                  |
| `contact-value(c)`                          | 获取联系方式的显示值（兼容 `value` 和 `label` 字段）                  |
| `render-contact(c)`                         | 渲染单个联系方式（自动处理 URL 链接）                                 |
| `render-contacts(contacts, ...)`            | 批量渲染联系方式（支持 delimiter/show-label/icon-fn 参数）            |
| `normalize-skills(skills)`                  | 将混合格式的技能数组归一化为字符串列表                                |
| `resume-info-extras(resume-info)`           | 提取 resume-info 中的扩展字段（summary, interests 等）                |
| `render-dict-item(item)`                    | 通用字典条目渲染                                                      |
| `markup(text)`                              | 将 YAML 字符串解析为 Typst 标记                                       |

---

## 8. 自定义扩展

用户可以在 `data.yml` 中自由增加自定义字段（例如 `skills`, `awards` 等）。主题开发者若希望支持这些扩展字段：

1. 在 `blueprint()` 中用 `.at()` 方法检查和提取
2. 提供默认值以保证健壮性
3. 在 README 或文件头注释中说明支持的扩展字段

**示例：**

```typst
let skills = data.at("skills", default: ())
if skills.len() > 0 {
  // 渲染技能部分...
}
```

---

## 9. 提交新主题

完成开发后，欢迎向本项目提交 Pull Request：

1. 确保目录结构符合规范
2. 运行 `typst compile themes/my-theme/example.typ --root .` 测试编译
3. 在 PR 中说明主题的特色和适用场景
4. 更新根目录 [README.md](../README.md) 的主题预览部分（可选）

---

## 10. 常见问题与解决方案

### Q: 如何在主题中使用字体？

A: 在 `blueprint()` 的最开始定义 `fonts-theme` 变量，使用 `set text(font: fonts-theme)` 全局应用。不要从用户数据或参数中读取字体，字体应该是主题设计的一部分。

### Q: 如何处理可选的数据字段？

A: **始终**使用 `.at("field", default: value)` 的写法。对于合成类字段（对象或数组），应提供合理的默认值（通常是 `(:)` 或 `()`）。

### Q: 如何渲染嵌套的列表数据？

A: 使用 `.map(d => [...])` 和 `.join()` 的组合：

```typst
details.map(d => [#d]).join("\n")
```

### Q: 编译时出现"unknown font"警告，怎么办？

A: 确保使用的字体在目标系统上可用。对于中文主题，常用的安全字体有：

- macOS: Songti SC, Heiti SC, Kaiti SC
- Windows: SimSun, SimHei
- Linux/跨平台: Noto Sans CJK SC

---

## 11. 参考实现

本项目的 `modern` 和 `classic` 两个主题都是完整的参考实现。建议在开发新主题时参考它们的结构和编码风格。
