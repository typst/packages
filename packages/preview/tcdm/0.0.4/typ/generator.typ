// = Known limitations
//
// == Configurations
//
// Only the following configurations are respected.
//
// - markdown_header_file, markdown_footer_file
//   They will be parsed by [pulldown-cmark](https://docs.rs/pulldown-cmark), not GitHub, so additional edits might be necessary.
// - project_dead_months
// - project_inactive_months
// - project_new_months
// - category_heading (only `robust` is supported)
//
// == Categories
//
// All categories will be shown, even if empty or hidden.
//
// == Labels
//
// The following fields are not supported: image, ignore, url.
//
// All labels should be specified in advance.
//
// == Projects
//
// - Group projects are not supported.
// - The following fields are not supported: commercial, resource.
// - Not all integrations are implemented. See `integrations.typ` for details.

#import "markdown.typ" as md
#import "projects-collection.typ": categorize-projects
#import "utils.typ": diff-month, parse-datetime, simplify-number
#import "default-config.typ": default-configuration
#import "integrations.typ": project-body
#import "license.typ": get-license
#import "babel.typ": babel

#let today = datetime.today()

/// Get the number of months from the first non-none candidate to today
#let to-today(..candidates) = {
  assert.eq(candidates.named(), (:))
  let first = candidates.pos().filter(s => s != none).first(default: none)
  if first != none {
    diff-month(today, parse-datetime(first))
  }
}

#let _tag(title: "", body) = {
  assert.ne(title, "")
  html.span(class: "tag", title: title, body)
}

/// Generate metrics info the project `p`.
/// Returns an array of metrics as contents, variable-length.
#let _metrics-info(p, config) = {
  let rank = _tag(title: babel(en: "Combined quality score: ", zh: "综合质量分数：") + str(p.projectrank), {
    if p.projectrank_placing == 1 {
      "🥇"
    } else if p.projectrank_placing == 2 {
      "🥈"
    } else {
      "🥉"
    }
    [ ]
    str(p.projectrank)
  })

  let star-count = if p.star_count != none {
    _tag(title: {
      if p.star_count == 1 { "1 star" } else { str(p.star_count) + " stars" }
      " on GitHub/GitLab/Codeberg/…"
    })[⭐ #simplify-number(p.star_count)]
  }

  let status = {
    let total-month = to-today(p.created_at)
    let inactive-months = to-today(p.last_commit_pushed_at, p.updated_at)

    if (
      inactive-months != none and config.project_dead_months != none and config.project_dead_months < inactive-months
    ) {
      _tag(
        title: babel(
          en: "Dead project ({} months no activity)",
          zh: "项目不再维护（已{}个月无活动）",
        ).replace("{}", str(config.project_dead_months)),
        "💀",
      )
    } else if (
      inactive-months != none
        and config.project_inactive_months != none
        and config.project_inactive_months < inactive-months
    ) {
      _tag(
        title: babel(
          en: "Inactive project ({} months no activity)",
          zh: "项目不活跃（已{}个月无活动）",
        ).replace("{}", str(config.project_inactive_months)),
        "💤",
      )
    } else if total-month != none and config.project_new_months != none and config.project_new_months >= total-month {
      _tag(
        title: babel(
          en: "New project (less than {} months old)",
          zh: "新项目（创建不到{}个月）",
        ).replace("{}", str(config.project_new_months)),
        "🐣",
      )
    } else if p.trending != none {
      if p.trending > 0 {
        _tag(title: babel(en: "Trending up", zh: "排名正在上升"), "📈")
      } else if p.trending < 0 {
        _tag(title: babel(en: "Trending down", zh: "排名正在下降"), "📉")
      }
    } else if p.at("new_addition", default: none) != none and p.new_addition {
      _tag(title: babel(en: "Recently added", zh: "最近添加"), "➕")
    }
  }

  (rank, star-count, status).filter(x => x != none)
}


/// Generate labels info the project `p`.
/// Returns an array of labels as contents, variable-length, might be empty.
#let _labels-info(p, labels) = {
  p.labels.map(target => {
    let info = labels.find(l => l.label == target)
    assert.ne(
      info,
      none,
      message: "Found undeclared label: {}. Labels must be declared in projects.yaml.".replace("{}", target),
    )

    // Not all labels have descriptions.
    _tag(title: info.at("description", default: info.name), info.name)
  })
}

#let _license-info(p) = {
  if p.license != none {
    let (url, name, warning, title) = get-license(p.license)
    let body = if warning [❗~#name] else { name }

    if url != none {
      html.a(class: "tag", target: "_blank", href: url, title: title, body)
    } else {
      _tag(title: title, body)
    }
  } else {
    _tag(
      title: babel(en: "Warning: no license can be found", zh: "警告：未识别到许可证"),
      [❗~#babel(en: "No license", zh: "无许可证")],
    )
  }
}

#let generate-project(project, config, labels) = {
  html.details(class: "project", {
    html.summary({
      strong(html.a(href: project.homepage, target: "_blank", project.name))
      " - "
      (
        _metrics-info(project, config),
        _labels-info(project, labels),
        _license-info(project),
      )
        .flatten()
        .filter(x => x != none)
        .join([ · ])


      if project.description != none {
        linebreak()
        html.span(class: "description", project.description)
      }
    })

    let integrations = project-body(project, config).map(list.item).join()
    if integrations != none {
      integrations
    } else [
      _#babel(en: "No project information available.", zh: "未查到项目信息")_
    ]
  })
}

#let generate-categories(categorized-projects, config, labels) = {
  assert.eq(config.category_heading, "robust")

  for (id, cat) in categorized-projects {
    show: html.section.with(class: "category")

    [#[= #cat.title]#label(id)]
    if "subtitle" in cat {
      md.render(cat.subtitle, ..md.config)
    }

    [#metadata((
      n-projects: cat.projects.len() + cat.hidden-projects.len(),
      subtitle: if "subtitle" in cat { cat.subtitle },
    ))<category-meta>]

    for p in cat.projects {
      list.item(generate-project(p, config, labels))
    }

    if cat.hidden-projects.len() > 0 {
      html.details({
        html.summary(
          babel(en: "Show {} hidden projects…", zh: "显示{}个隐藏项目……").replace("{}", str(cat.hidden-projects.len())),
        )
        for p in cat.hidden-projects {
          list.item(generate-project(p, config, labels))
        }
      })
    }
  }
}

#let generate-outline() = {
  show outline.entry.where(level: 1): it => {
    let meta = query(selector(<category-meta>).after(it.element.location()))
      .map(meta => meta.value)
      .first(default: none)

    link(
      it.element.location(),
      if meta != none and meta.subtitle != none {
        html.span(title: meta.subtitle, it.body())
      } else {
        it.body()
      },
    )

    if meta != none {
      emph(babel(en: " — {} projects", zh: "——{}个项目").replace("{}", repr(meta.n-projects)))
    }
  }
  [#outline() <Contents>]
}
