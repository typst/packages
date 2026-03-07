// Shared module contract for theme authors.
// A theme can render sections by iterating over `standard-modules(data)`.

// 将 YAML 字符串作为 Typst 标记语言解析（支持 *加粗* _斜体_ 等内联语法）
#let markup(text) = eval("[" + text + "]")

// ─────────────────────────────────────────────────────────
//  resume-info 扩展字段提取
// ─────────────────────────────────────────────────────────

// 提取 resume-info 中的扩展字段（summary、self-evaluation、interests）
#let resume-info-extras(resume-info) = {
  (
    summary: resume-info.at("summary", default: ""),
    self-evaluation: resume-info.at("self-evaluation", default: ""),
    interests: resume-info.at("interests", default: ()),
  )
}

// 通用字典项渲染（用于 awards/certificates 等自定义模块）
#let render-dict-item(item) = {
  let title = item.at("title", default: item.at("name", default: ""))
  let desc = item.at("description", default: item.at("org", default: ""))
  let date = item.at("date", default: "")
  if title != "" {
    [*#title* #if date != "" { [ (#date)] } #if desc != "" { [ — #desc] }]
  } else {
    let parts = ()
    for (k, v) in item {
      parts.push(k + ": " + str(v))
    }
    [#parts.join(", ")]
  }
}

// ─────────────────────────────────────────────────────────
//  数据格式兼容：支持新旧两种格式
// ─────────────────────────────────────────────────────────

// 从段落数据中提取条目列表（兼容旧的数组格式和新的 {title, items} 字典格式）
#let extract-items(section-data) = {
  if type(section-data) == dictionary {
    section-data.at("items", default: ())
  } else if type(section-data) == array {
    section-data
  } else {
    ()
  }
}

// 从段落数据中提取标题
#let extract-title(section-data, fallback: "") = {
  if type(section-data) == dictionary {
    let t = section-data.at("title", default: "")
    if t != "" { t } else { fallback }
  } else {
    fallback
  }
}

// 获取联系方式的显示值（兼容旧 label 格式和新 value 格式）
#let contact-value(c) = c.at("value", default: c.at("label", default: ""))

// 渲染单个联系方式（处理 URL 链接）
#let render-contact(c) = {
  let display = contact-value(c)
  let url = c.at("url", default: "")
  if url != "" { link(url, display) } else { display }
}

// 批量渲染联系方式为内联文本
// - delimiter: 分隔符内容
// - show-label: 是否显示标签前缀（如"手机号："）
// - icon-fn: 图标函数 (type => content)，传入 none 不显示图标
#let render-contacts(contacts, delimiter: [ | ], show-label: false, icon-fn: none) = {
  if contacts.len() == 0 { return }
  contacts
    .map(c => {
      let item = render-contact(c)
      if show-label {
        let label = c.at("label", default: "")
        if label != "" { item = [#label：#item] }
      }
      if icon-fn != none {
        item = [#icon-fn(c.at("type", default: "")) #item]
      }
      item
    })
    .join(delimiter)
}

#let _has-content(value) = {
  if type(value) == array {
    value.len() > 0
  } else if type(value) == dictionary {
    value.len() > 0
  } else if type(value) == str {
    value != ""
  } else {
    value != none
  }
}

#let _skill-line(skill) = {
  if type(skill) == str {
    skill
  } else if type(skill) == dictionary {
    // 支持 name/level/description 格式
    let name = skill.at("name", default: "")
    if name != "" {
      let level = skill.at("level", default: "")
      let description = skill.at("description", default: "")
      let parts = (name,)
      if level != "" { parts.push(level) }
      if description != "" { parts.push(description) }
      return parts.join("：")
    }

    // 支持 category/items 格式
    let category = skill.at("category", default: skill.at("title", default: ""))
    let items = skill.at("items", default: ())

    if type(items) == array and items.len() > 0 {
      if category != "" {
        category + "：" + items.join("、")
      } else {
        items.join("、")
      }
    } else {
      skill.at("value", default: category)
    }
  } else {
    ""
  }
}

#let normalize-skills(skills) = {
  let lines = ()
  for skill in skills {
    let line = _skill-line(skill)
    if line != "" {
      lines.push(line)
    }
  }
  lines
}

#let standard-modules(data) = {
  let resume-info = data.at("resume-info", default: (:))
  let module-config = data.at("module-config", default: (:))

  // 内置模块的默认标题
  let default-titles = (
    "resume-info": "个人信息",
    "education": "教育经历",
    "experience": "工作经历",
    "projects": "项目经历",
    "internship": "实习经历",
    "skills": "个人技能",
    "awards": "荣誉奖项",
    "certificates": "资质证书",
  )

  // 内置模块的标准字段名（不会被当作自定义模块）
  let reserved-keys = (
    "resume-info",
    "education",
    "experience",
    "projects",
    "internship",
    "skills",
    "awards",
    "certificates",
    "module-config",
  )

  // 获取自定义的模块顺序或自动扫描 YAML 中的顺序
  let module-order = module-config.at("module-order", default: none)

  // 如果未指定 module-order，自动按照 YAML 文件的字段顺序扫描
  if module-order == none {
    module-order = ()
    for (key, value) in data {
      if key not in ("module-config",) {
        module-order.push(key)
      }
    }
  }

  let modules = ()

  // 按照模块顺序处理每个模块
  for module-id in module-order {
    if module-id == "resume-info" {
      // resume-info 始终作为头部元数据
      let ri-title = resume-info.at("title", default: module-config.at(
        "resume-info",
        default: default-titles.at("resume-info"),
      ))
      modules.push((
        id: "resume-info",
        title: ri-title,
        payload: resume-info,
      ))
    } else if module-id == "education" {
      let raw = data.at("education", default: none)
      if raw != none {
        let items = extract-items(raw)
        let section-title = extract-title(raw, fallback: module-config.at(
          "education",
          default: default-titles.at("education"),
        ))
        if _has-content(items) {
          modules.push((id: "education", title: section-title, payload: items))
        }
      }
    } else if module-id == "experience" {
      let raw = data.at("experience", default: none)
      if raw != none {
        let items = extract-items(raw)
        let section-title = extract-title(raw, fallback: module-config.at(
          "experience",
          default: default-titles.at("experience"),
        ))
        if _has-content(items) {
          modules.push((id: "experience", title: section-title, payload: items))
        }
      }
    } else if module-id == "projects" {
      let raw = data.at("projects", default: none)
      if raw != none {
        let items = extract-items(raw)
        let section-title = extract-title(raw, fallback: module-config.at(
          "projects",
          default: default-titles.at("projects"),
        ))
        if _has-content(items) {
          modules.push((id: "projects", title: section-title, payload: items))
        }
      }
    } else if module-id == "internship" {
      let raw = data.at("internship", default: none)
      if raw != none {
        let items = extract-items(raw)
        let section-title = extract-title(raw, fallback: module-config.at(
          "internship",
          default: default-titles.at("internship"),
        ))
        if _has-content(items) {
          modules.push((id: "internship", title: section-title, payload: items))
        }
      }
    } else if module-id == "skills" {
      let raw = data.at("skills", default: none)
      if raw != none {
        let items = extract-items(raw)
        let section-title = extract-title(raw, fallback: module-config.at(
          "skills",
          default: default-titles.at("skills"),
        ))
        let skills = normalize-skills(items)
        if _has-content(skills) {
          modules.push((id: "skills", title: section-title, payload: skills))
        }
      }
    } else if module-id == "awards" {
      let raw = data.at("awards", default: none)
      if raw != none {
        let items = extract-items(raw)
        let section-title = extract-title(raw, fallback: module-config.at(
          "awards",
          default: default-titles.at("awards"),
        ))
        if _has-content(items) {
          modules.push((id: "awards", title: section-title, payload: items))
        }
      }
    } else if module-id == "certificates" {
      let raw = data.at("certificates", default: none)
      if raw != none {
        let items = extract-items(raw)
        let section-title = extract-title(raw, fallback: module-config.at(
          "certificates",
          default: default-titles.at("certificates"),
        ))
        if _has-content(items) {
          modules.push((id: "certificates", title: section-title, payload: items))
        }
      }
    } else {
      // 自定义模块
      let value = data.at(module-id, default: none)
      if value != none {
        let payload = value
        let section-title = module-config.at(module-id, default: module-id)
        if type(value) == dictionary and "items" in value {
          section-title = extract-title(value, fallback: section-title)
          payload = value.at("items", default: value)
        }
        if _has-content(payload) {
          modules.push((id: module-id, title: section-title, payload: payload))
        }
      }
    }
  }

  modules
}
