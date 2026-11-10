// ============================================
// 高级展示模块 (Advanced Display Module)
// ============================================
// 基于基础组件构建专用简历段落模块：
// - 章节标题、个人信息
// - 教育 / 工作 / 技能 / 项目 / 总结 / 奖项
// 所有样式均通过 get-config() 从 State 读取。

#import "config.typ": get-config
#import "icons.typ": icon, icons
#import "components.typ": sidebar, list-view, tag-list, date-text, tech-text, icon-link, styled-link

// --------------------------------------------
// 章节标题组件 (Section Header Components)
// --------------------------------------------

/// 章节标题
/// 带图标和分隔线的章节标题
///
/// 参数:
///   title: 章节标题文本
///   icon-name: 图标名称（可选）
///   color: 标题颜色（默认主题色）
///   with-line: 是否显示下划线
#let section-header(
  title,
  icon-name: none,
  color: auto,
  with-line: true,
) = context {
  let cfg = get-config()
  let actual-color = if color == auto { cfg.colors.primary } else { color }
  let spacing = cfg.spacing
  let sizes = cfg.at("font-sizes")
  let features = cfg.at("style-features")

  v(spacing.section)
  
  let title-content = if icon-name != none {
    box({
      icon(icon-name, color: actual-color)
      h(0.3em)
      text(fill: actual-color, size: sizes.h2, weight: "bold", title)
    })
  } else {
    text(fill: actual-color, size: sizes.h2, weight: "bold", title)
  }
  
  if with-line {
    stack(
      v(0.3em),
      title-content,
      v(0.6em),
      line(length: 100%, stroke: features.at("heading-line-stroke") + actual-color),
      v(0.1em),
    )
  } else {
    title-content
    v(spacing.subsection)
  }
}

// --------------------------------------------
// 个人信息模块 (Personal Info Module)
// --------------------------------------------

/// 个人信息项
/// 单个信息项（图标+内容）
///
/// 参数:
///   icon-name: 图标名称
///   content: 内容文本
///   link: 链接地址（可选）
///   color: 颜色（默认主题色）
#let info-item(
  icon-name,
  body-content,
  link-url: none,
  color: auto,
) = context {
  let cfg = get-config()
  let actual-color = if color == auto { cfg.colors.primary } else { color }

  box({
    icon(icon-name, color: actual-color)
    h(0.15em)
    if link-url != none {
      styled-link(link-url, text-content: body-content, color: actual-color)
    } else {
      text(fill: actual-color, body-content)
    }
  })
}

/// 个人信息组
/// 多个信息项的水平排列
///
/// 参数:
///   items: 信息项数组，每项为字典 {icon, content, link?}
///   color: 统一颜色（默认主题色）
///   separator: 分隔符
#let info-group(
  items,
  color: auto,
  separator: [ · ],
) = context {
  let cfg = get-config()
  let actual-color = if color == auto { cfg.colors.primary } else { color }

  items.map(item => {
    let icon-name = item.at("icon")
    let content = item.at("content")
    let url = item.at("link", default: none)
    info-item(icon-name, content, link-url: url, color: actual-color)
  }).join(h(0.5em) + separator + h(0.5em))
  
  v(0.5em)
}

/// 个人头部信息
/// 姓名+联系方式的整体展示
///
/// 参数:
///   name: 姓名
///   info-items: 信息项数组
///   photo: 照片路径（可选）
///   photo-width: 照片宽度
#let personal-header(
  name,
  info-items,
  photo: none,
  photo-width: 0em,
) = context {
  let cfg = get-config()

  grid(
    columns: (auto, 1fr, photo-width),
    gutter: (if photo != none { 1em } else { 0em }, 0em),
    {
      // 左侧信息区
      text(size: cfg.at("font-sizes").h1, weight: "bold", name)
      v(0.5em)
      info-group(info-items)
    },
    {},
    if photo != none {
      image(photo, width: photo-width)
    },
  )
}

// --------------------------------------------
// 教育经历模块 (Education Module)
// --------------------------------------------

/// 教育经历项
/// 单个教育经历条目
///
/// 参数:
///   period: 时间段
///   school: 学校名称
///   degree: 学位
///   major: 专业
///   gpa: GPA（可选）
///   honors: 荣誉（可选）
///   description: 描述（可选）
#let education-item(
  period,
  school,
  degree,
  major,
  gpa: none,
  honors: (),
  description: none,
) = context {
  let cfg = get-config()
  let small = cfg.at("font-sizes").small

  sidebar(
    date-text(period),
    {
      strong(school)
      h(0.5em)
      text(size: small, fill: cfg.colors.secondary, [\|])
      h(0.5em)
      text(degree + [, ] + major)
      
      if gpa != none {
        h(0.5em)
        text(size: small, fill: cfg.colors.secondary, [GPA: ] + gpa)
      }
      
      if honors.len() > 0 {
        v(0.3em)
        text(size: small, [
          #icon("award", color: cfg.colors.secondary, size: 0.9em)
          #honors.join([, ])
        ])
      }
      
      if description != none {
        v(0.3em)
        description
      }
    },
  )
  v(cfg.spacing.at("list-item"))
}

/// 教育经历列表
/// 多个教育经历的展示
///
/// 参数:
///   items: 教育经历数组
#let education-list(items) = {
  for item in items {
    education-item(
      period: item.at("period"),
      school: item.at("school"),
      degree: item.at("degree"),
      major: item.at("major"),
      gpa: item.at("gpa", default: none),
      honors: item.at("honors", default: ()),
      description: item.at("description", default: none),
    )
  }
}

// --------------------------------------------
// 工作经历模块 (Work Experience Module)
// --------------------------------------------

/// 工作经历项
/// 单个工作经历条目
///
/// 参数:
///   period: 时间段
///   company: 公司名称
///   position: 职位
///   location: 地点（可选）
///   responsibilities: 职责列表
///   achievements: 成就列表（可选）
///   tech-stack: 技术栈（可选）
#let work-item(
  period,
  company,
  position,
  location: none,
  responsibilities: (),
  achievements: (),
  tech-stack: (),
) = context {
  let cfg = get-config()
  let small = cfg.at("font-sizes").small

  sidebar(
    date-text(period),
    {
      strong(company)
      if location != none {
        h(0.5em)
        text(size: small, fill: cfg.colors.secondary, [\(] + location + [\)])
      }
      v(0.15em)
      text(fill: cfg.colors.primary, weight: "medium", position)
      
      if tech-stack.len() > 0 {
        v(0.3em)
        tag-list(tech-stack)
      }
      
      if responsibilities.len() > 0 {
        v(0.3em)
        list-view(responsibilities)
      }
      
      if achievements.len() > 0 {
        v(0.3em)
        text(size: small, fill: cfg.colors.secondary, [主要成就：])
        list-view(achievements)
      }
    },
  )
  v(cfg.spacing.at("list-item"))
}

/// 工作经历列表
/// 多个工作经历的展示
///
/// 参数:
///   items: 工作经历数组
#let work-list(items) = {
  for item in items {
    work-item(
      period: item.at("period"),
      company: item.at("company"),
      position: item.at("position"),
      location: item.at("location", default: none),
      responsibilities: item.at("responsibilities", default: ()),
      achievements: item.at("achievements", default: ()),
      tech-stack: item.at("tech-stack", default: ()),
    )
  }
}

// --------------------------------------------
// 专业技能模块 (Skills Module)
// --------------------------------------------

/// 技能分类项
/// 单个技能分类
///
/// 参数:
///   category: 分类名称
///   skills: 技能列表
///   level: 熟练度（可选）
#let skill-category(
  category,
  skills,
  level: none,
) = context {
  let cfg = get-config()
  let small = cfg.at("font-sizes").small

  grid(
    columns: (20%, 1fr),
    column-gutter: 0.5em,
    {
      set align(left + top)
      text(weight: "bold", category)
    },
    {
      if type(skills) == array {
        skills.join([, ])
      } else {
        skills
      }
      if level != none {
        h(0.5em)
        text(size: small, fill: cfg.colors.secondary, [\(] + level + [\)])
      }
    },
  )
  v(cfg.spacing.at("list-item"))
}

/// 技能列表
/// 多个技能分类的展示
///
/// 参数:
///   categories: 技能分类数组
#let skill-list(categories) = {
  for cat in categories {
    skill-category(
      category: cat.at("category"),
      skills: cat.at("skills"),
      level: cat.at("level", default: none),
    )
  }
}

/// 技能标签云
/// 以标签形式展示技能
///
/// 参数:
///   skills: 技能数组
///   columns: 列数
#let skill-cloud(
  skills,
  columns: 2,
) = context {
  let cfg = get-config()
  let xsmall = cfg.at("font-sizes").xsmall

  grid(
    columns: (1fr,) * columns,
    column-gutter: 1em,
    row-gutter: 0.5em,
    ..skills.map(skill => {
      box({
        if "icon" in skill {
          icon(skill.icon, color: cfg.colors.primary, size: 0.9em)
          h(0.3em)
        }
        skill.name
        if "level" in skill {
          h(0.3em)
          text(size: xsmall, fill: cfg.colors.secondary, skill.level)
        }
      })
    })
  )
}

// --------------------------------------------
// 项目经历模块 (Project Module)
// --------------------------------------------

/// 项目经历项
/// 单个项目条目
///
/// 参数:
///   name: 项目名称
///   tech-stack: 技术栈
///   description: 项目描述
///   responsibilities: 职责/贡献列表
///   link: 项目链接（可选）
///   period: 时间段（可选）
#let project-item(
  name,
  tech-stack,
  description,
  responsibilities: (),
  link: none,
  period: none,
) = context {
  let cfg = get-config()
  let small = cfg.at("font-sizes").small

  v(0.3em)
  
  // 项目名称行
  box({
    if link != none {
      icon-link(link, "link", name, color: cfg.colors.primary)
    } else {
      strong(name)
    }
    if period != none {
      h(1fr)
      text(size: small, fill: cfg.colors.secondary, date-text(period))
    }
  })
  
  v(0.15em)
  
  // 技术栈
  tech-text(tech-stack.join([ \u{2F} ]))
  
  v(0.3em)
  
  // 描述
  description
  
  // 职责列表
  if responsibilities.len() > 0 {
    v(0.3em)
    list-view(responsibilities)
  }
  
  v(cfg.spacing.at("list-item"))
}

/// 项目经历列表
/// 多个项目的展示
///
/// 参数:
///   items: 项目数组
#let project-list(items) = {
  for item in items {
    project-item(
      name: item.at("name"),
      tech-stack: item.at("tech-stack"),
      description: item.at("description"),
      responsibilities: item.at("responsibilities", default: ()),
      link: item.at("link", default: none),
      period: item.at("period", default: none),
    )
  }
}

// --------------------------------------------
// 个人总结模块 (Summary Module)
// --------------------------------------------

/// 个人总结
/// 以列表形式展示个人特质
///
/// 参数:
///   items: 总结要点数组
///   icon-name: 列表项图标（可选）
#let summary-list(
  items,
  icon-name: "check",
) = context {
  let cfg = get-config()

  list-view(
    items.map(item => {
      box({
        icon(icon-name, color: cfg.colors.primary, size: 0.9em)
        h(0.3em)
        item
      })
    })
  )
}

/// 个人简介段落
/// 段落形式的个人简介
///
/// 参数:
///   content: 简介内容
#let summary-paragraph(content) = {
  set par(justify: true)
  content
}

// --------------------------------------------
// 奖项证书模块 (Awards Module)
// --------------------------------------------

/// 奖项项
/// 单个奖项条目
///
/// 参数:
///   name: 奖项名称
///   date: 获奖日期
///   issuer: 颁发机构（可选）
///   description: 描述（可选）
#let award-item(
  name,
  date,
  issuer: none,
  description: none,
) = context {
  let cfg = get-config()
  let small = cfg.at("font-sizes").small

  grid(
    columns: (1fr, auto),
    column-gutter: 1em,
    {
      box({
        icon("award", color: cfg.colors.primary, size: 0.9em)
        h(0.3em)
        strong(name)
      })
      if issuer != none {
        v(0.1em)
        text(size: small, fill: cfg.colors.secondary, issuer)
      }
      if description != none {
        v(0.2em)
        text(size: small, description)
      }
    },
    align(right, text(size: small, fill: cfg.colors.secondary, date)),
  )
  v(cfg.spacing.at("list-item"))
}

/// 奖项列表
/// 多个奖项的展示
///
/// 参数:
///   items: 奖项数组
#let award-list(items) = {
  for item in items {
    award-item(
      name: item.at("name"),
      date: item.at("date"),
      issuer: item.at("issuer", default: none),
      description: item.at("description", default: none),
    )
  }
}

// --------------------------------------------
// 导出 (Exports)
// --------------------------------------------

// 直接导出所有章节函数
#let section-header = section-header
#let info-item = info-item
#let info-group = info-group
#let personal-header = personal-header
#let education-item = education-item
#let education-list = education-list
#let work-item = work-item
#let work-list = work-list
#let skill-category = skill-category
#let skill-list = skill-list
#let skill-cloud = skill-cloud
#let project-item = project-item
#let project-list = project-list
#let summary-list = summary-list
#let summary-paragraph = summary-paragraph
#let award-item = award-item
#let award-list = award-list

/// 导出所有模块组件字典
#let sections = (
  section-header: section-header,
  info-item: info-item,
  info-group: info-group,
  personal-header: personal-header,
  education-item: education-item,
  education-list: education-list,
  work-item: work-item,
  work-list: work-list,
  skill-category: skill-category,
  skill-list: skill-list,
  skill-cloud: skill-cloud,
  project-item: project-item,
  project-list: project-list,
  summary-list: summary-list,
  summary-paragraph: summary-paragraph,
  award-item: award-item,
  award-list: award-list,
)

