//! Example placeholder contents to make the template compile out-of-the-box.

/// Example `/projects.yaml`.
#let projects-yaml = bytes(
  ```yaml
  configuration:
    category_heading: robust

  categories:
    - category: writing
      title: 📝 Writing
      subtitle: Compose articles and books.

  labels:
    - label: cli
      name: 🤖 CLI
      description: Command-line programs with pre-built binaries available.
    - label: api
      name: 🔌 API
      description: Libraries providing API for development.
    - label: extension
      name: 🧩 Extension
      description: Browser addons and user scripts, and other kinds of extensions.

  projects:
    - name: tinymist
      github_id: Myriad-Dreamin/tinymist
      category: writing
      labels: [extension, cli, api]
      cargo_id: tinymist-query
  ```.text,
)

/// Example `/build/latest.json`.
#let latest-history-json = bytes(
  ```json
  [
    {
      "name":"tinymist",
      "github_id":"Myriad-Dreamin\/tinymist",
      "category":"writing",
      "labels":[
        "extension",
        "cli",
        "api"
      ],
      "pypi_id":null,
      "github_url":"https:\/\/github.com\/Myriad-Dreamin\/tinymist",
      "homepage":"https:\/\/myriad-dreamin.github.io\/tinymist",
      "license":"Apache-2.0",
      "created_at":"2024-03-06 21:30:21",
      "updated_at":"2025-12-16 03:37:50.000",
      "last_commit_pushed_at":"2025-12-16 03:37:50",
      "commit_count":1686.0,
      "recent_commit_count":83.0,
      "fork_count":111.0,
      "watchers_count":4.0,
      "pr_count":1710.0,
      "open_issue_count":150.0,
      "closed_issue_count":505.0,
      "star_count":2619.0,
      "latest_stable_release_published_at":"2025-11-26 01:23:42.000",
      "latest_stable_release_number":"0.14.4",
      "github_release_downloads":44202.0,
      "monthly_downloads":9898.0,
      "release_count":50.0,
      "description":"Tinymist [ˈtaɪni mɪst] is an integrated language service for Typst [taɪpst].",
      "dependent_project_count":3.0,
      "github_dependent_project_count":null,
      "contributor_count":76.0,
      "projectrank":27,
      "pypi_url":null,
      "pypi_latest_release_published_at":null,
      "pypi_dependent_project_count":null,
      "pypi_monthly_downloads":null,
      "show":true,
      "projectrank_placing":1.0,
      "cargo_id":"tinymist-query",
      "cargo_url":"https:\/\/crates.io\/crates\/tinymist-query",
      "cargo_latest_release_published_at":"2025-12-03 21:28:13.736",
      "cargo_dependent_project_count":3.0,
      "cargo_monthly_downloads":1058.0,
      "cargo_total_downloads":11178.0,
      "npm_id":null,
      "npm_url":null,
      "npm_latest_release_published_at":null,
      "npm_dependent_project_count":null,
      "npm_monthly_downloads":null,
      "greasy_fork_id":null,
      "greasy_fork_url":null,
      "greasy_fork_code_url":null,
      "greasy_fork_total_installs":null,
      "greasy_fork_fan_score":null,
      "trending":null,
      "updated_github_id":null,
      "new_addition":null,
      "go_id":null,
      "go_url":null,
      "go_latest_release_published_at":null,
      "go_dependent_project_count":null,
      "maven_id":null,
      "maven_url":null,
      "maven_latest_release_published_at":null,
      "gitlab_id":null,
      "gitlab_url":null,
      "codeberg_id":null,
      "codeberg_url":null
    }
  ]
  ```.text,
)

/// Example `/config/header.md`.
#let header-md = ```md
<!-- markdownlint-disable -->
<h1 align="center">
  Best of Typst (TCDM)
  <br>
  </h1>

  <p align="center">
    <strong>
      🏆&nbsp;
      A ranked list of awesome projects related to <a href="https://typst.app/home">Typst</a>,
      or the charted dark matter in Typst Universe (TCDM).
    </strong>
  </p>

<p align="center">
  <a href="https://best-of.org" title="Best-of Badge"><img src="http://bit.ly/3o3EHNN" alt="🏆 best-of"></a>
  <a href="#Contents" title="Project Count"><img
      src="https://img.shields.io/badge/projects-{project_count}-blue.svg?color=5ac4bf" alt="projects {project_count}"></a>
  <a href="https://github.com/YDX-2147483647/best-of-typst/releases" title="Best-of Updates"><img
      src="https://img.shields.io/github/release-date/YDX-2147483647/best-of-typst?color=green&label=updated" alt="updated date (shown in the image)"></a>
</p>

This list contains {project_count} awesome open-source projects with a total of {stars_count} stars grouped into {category_count} categories.
If you like to add or update projects, feel free to open an [issue](https://github.com/YDX-2147483647/best-of-typst/issues/new/choose).
```.text
