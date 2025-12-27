/// Check if a project has been deleted.
///
/// Note: There is no way to distinguish deleted projects from projects that were once public but have become private.
#let _is-deleted(p) = if p.show {
  false
} else {
  // The key may not exist, if all projects do not have this field.
  let has(key) = p.at(key, default: none) != none

  if has("github_id") and p.github_url == none and p.homepage == "{}" {
    true
  } else if has("greasy_fork_id") and p.greasy_fork_code_url == none and p.homepage == none {
    true
  } else if has("gitee_id") and p.gitee_url == none and (p.homepage == none or ".gitee.io/" in p.homepage) {
    // Gitee Pages are usually manually recorded, so they may have seemingly valid homepages.
    true
  } else {
    false
  }
}

/// A simplified version of `best_of.projects_collection.categorize_projects`.
///
/// Returns categories with `projects` and `hidden-projects` populated.
///
/// Note that the number of projects (including hidden ones) in the output might less than that of the input, because deleted projects will be dropped.
#let categorize-projects(projects, categories) = {
  // We can't `let … = categories.at(…)` here, or the variable `categories` won't be updated.

  for id in categories.keys() {
    categories.at(id).insert("projects", ())
    categories.at(id).insert("hidden-projects", ())
  }

  for p in projects {
    // Drop deleted projects.
    if _is-deleted(p) { continue }

    if p.show {
      categories.at(p.category).projects.push(p)
    } else {
      categories.at(p.category).hidden-projects.push(p)
    }
  }

  categories
}
