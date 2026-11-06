#import "utils.typ": parse-datetime, simplify-number
#import "babel.typ": BABEL, babel

/// Create an external link
#let _link(dest, body) = html.a(href: dest, target: "_blank", body)

/// Display the info with an icon, if it exists.
#let _icon-info(icon, info, title: "{}", suffix: "") = {
  assert.ne(title, "{}")

  if info != none {
    let formatted_info = if type(info) == float {
      simplify-number(info)
    } else {
      info
    }

    html.span(class: "tag", title: title.replace("{}", formatted_info), {
      [#icon #formatted_info#suffix]
    })
  }
}
#let _icon-date(icon, date, title: "{}") = {
  assert.ne(title, "{}")

  if date != none {
    html.elem(
      "time",
      attrs: (
        class: "tag",
        title: title.replace("{}", date),
        // We can't use `html.time` because of https://github.com/typst/typst/issues/7195
        datetime: date,
      ),
      {
        icon
        [ ]
        parse-datetime(date).display("[year]-[month]-[day]")
      },
    )
  }
}
#let _icon-issue(icon, p) = if p.open_issue_count != none and p.closed_issue_count != none {
  let total = p.open_issue_count + p.closed_issue_count
  html.span(
    class: "tag",
    title: "{open} of {total} issues are open"
      .replace("{open}", str(p.open_issue_count))
      .replace("{total}", str(total)),
  )[#icon #simplify-number(total) - #int(p.open_issue_count / total * 100)% open]
} else if p.open_issue_count != none {
  // Some platform does not count closed issues in the API.
  html.span(
    class: "tag",
    title: "{} open issues".replace("{}", str(p.open_issue_count)),
  )[#icon #simplify-number(p.open_issue_count) open]
}
/// Display `*_dependent_project_count` with an icon, if it exists.
#let _icon-deps(icon, project, package-manager) = {
  let key = package-manager + "_dependent_project_count"
  _icon-info(
    icon,
    // The key may not exist, if all projects do not have this field.
    // This is likely for rare package managers.
    project.at(key, default: none),
    title: babel(en: "depended by {} projects", zh: "被{}个项目使用"),
  )
}


/// Display metrics if there is any.
#let _metrics(..args) = {
  assert.eq(args.named(), (:))

  let metrics = args.pos().filter(x => x != none).join([ · ])
  if metrics != none {
    [ (#metrics):]
  }
}

#let _not-implemented(integration) = {
  p => {
    // Uncomment the following for developing.
    // return none
    panic(
      "{integration} integration has not been implemented: {name} ({id})"
        .replace("{integration}", integration)
        .replace("{name}", p.name)
        .replace("{id}", str(p.at(integration + "_id"))),
    )
  }
}


/// A map from the key to the content builder.
/// The order matters.
#let _integration_map = (
  github_id: p => {
    _link(p.github_url)[GitHub]

    _metrics(
      _icon-info("👨‍💻", p.contributor_count, title: babel(en: "{} contributors", zh: "{}个贡献者")),
      _icon-info("🔀", p.fork_count, title: "{} forks"),
      _icon-info("📥", p.github_release_downloads, title: babel(en: "{} release downloads", zh: "{}次下载")),
      _icon-deps("📦", p, "github"),
      _icon-issue("📋", p),
      _icon-date("⏱️", p.last_commit_pushed_at, title: BABEL.last-commit-pushed-at),
    )

    raw(block: true, lang: "sh", "git clone https://github.com/" + p.github_id)
  },
  pypi_id: p => {
    _link(p.pypi_url)[PyPI]

    _metrics(
      _icon-info("📥", p.pypi_monthly_downloads, suffix: BABEL.per-month, title: BABEL.monthly-downloads),
      _icon-deps("📦", p, "pypi"),
      _icon-date("⏱️", p.pypi_latest_release_published_at, title: BABEL.latest-release-published-at),
    )

    raw(block: true, lang: "sh", "pip install " + p.pypi_id)
  },
  codeberg_id: p => {
    _link(p.codeberg_url)[Codeberg]

    _metrics(
      _icon-info("🔀", p.fork_count, title: "{} forks"),
      _icon-issue("📋", p),
      _icon-date("⏱️", p.last_commit_pushed_at, title: BABEL.last-commit-pushed-at),
    )

    raw(block: true, lang: "sh", "git clone " + p.codeberg_url)
  },
  gitlab_id: p => {
    _link(p.gitlab_url)[GitLab]

    _metrics(
      _icon-info("🔀", p.fork_count, title: "{} forks"),
      _icon-issue("📋", p),
      _icon-date("⏱️", p.updated_at, title: babel(en: "updated at {}", zh: "更新于{}")),
    )

    raw(block: true, lang: "sh", "git clone " + p.gitlab_url)
  },
  gitee_id: p => {
    _link(p.gitee_url)[Gitee]

    _metrics(
      _icon-info("🔀", p.fork_count, title: "{} forks"),
      _icon-issue("📋", p),
      _icon-date("⏱️", p.updated_at, title: babel(en: "updated at {}", zh: "更新于{}")),
    )

    raw(block: true, lang: "sh", "git clone " + p.gitee_url)
  },
  conda_id: _not-implemented("conda"),
  npm_id: p => {
    _link(p.npm_url)[npm]

    _metrics(
      _icon-info("📥", p.npm_monthly_downloads, suffix: BABEL.per-month, title: BABEL.monthly-downloads),
      _icon-deps("📦", p, "npm"),
      _icon-date("⏱️", p.npm_latest_release_published_at, title: BABEL.latest-release-published-at),
    )

    raw(block: true, lang: "sh", "npm install " + p.npm_id)
  },
  maven_id: p => {
    _link(p.maven_url)[Maven]

    _metrics(
      _icon-date("⏱️", p.maven_latest_release_published_at, title: BABEL.latest-release-published-at),
    )

    let (group, artifact) = p.maven_id.split(":")
    raw(
      block: true,
      lang: "xml",
      ```xml
      <dependency>
        <groupId>{group_id}</groupId>
        <artifactId>{artifact_id}</artifactId>
        <version>[VERSION]</version>
      </dependency>
      ```
        .text
        .replace("{group_id}", group)
        .replace("{artifact_id}", artifact),
    )
  },
  dockerhub_id: _not-implemented("dockerhub"),
  cargo_id: p => {
    _link(p.cargo_url)[Cargo]

    _metrics(
      _icon-info("📥", p.cargo_monthly_downloads, suffix: BABEL.per-month, title: BABEL.monthly-downloads),
      _icon-deps("📦", p, "cargo"),
      _icon-date("⏱️", p.cargo_latest_release_published_at, title: BABEL.latest-release-published-at),
    )

    raw(block: true, lang: "sh", "cargo install " + p.cargo_id)
  },
  go_id: p => {
    _link(p.go_url)[Go]

    _metrics(
      _icon-deps("📦", p, "go"),
      _icon-date("⏱️", p.go_latest_release_published_at, title: BABEL.latest-release-published-at),
    )

    raw(block: true, lang: "sh", "go install " + p.go_id)
  },
  greasy_fork_id: p => {
    _link(p.greasy_fork_url)[Greasy Fork]

    _metrics(
      _icon-info(
        "📥",
        p.greasy_fork_total_installs,
        suffix: babel(en: " total", zh: "（总计）"),
        title: babel(en: "{} total installs", zh: "总计{}次下载"),
      ),
      _icon-info("🌟", p.greasy_fork_fan_score, title: "fan score: {}"),
    )
    [ ]
    _link(p.greasy_fork_code_url)[#p.greasy_fork_id]
  },
)

/// Generate integration info for the project.
/// Returns an array of integrations as contents, variable-length, might be empty.
#let project-body(project, config) = {
  let integrations = ()

  for (key, builder) in _integration_map {
    // The key may not exist, if the integration was added after the run or not used by any project.
    if key in project and project.at(key, default: none) != none {
      integrations.push(builder(project))
    }
  }

  integrations
}
