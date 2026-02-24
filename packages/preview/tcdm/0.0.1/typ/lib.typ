#import "markdown.typ" as md
#import "example-config.typ" as placeholder

/// Parameters:
/// - projects-data: `json("/build/latest.json")`
/// - projects-yaml: `yaml("/projects.yaml")`
///
/// Returns a dictionary with the following fields:
/// - configuration: Parsed configuration
/// - statistics: Statistics of the list, can be passed to `md.preprocess` later
/// - assets: Inline CSS and JS
/// - body: The main part of the document, including the outline
#let load(projects-data: (), projects-yaml: (:)) = {
  import "projects-collection.typ": categorize-projects
  import "default-config.typ": default-configuration
  import "generator.typ": generate-categories, generate-outline

  // Read data sources

  let (configuration: raw_configuration, categories: raw_categories, labels) = projects-yaml
  let configuration = default-configuration + raw_configuration

  // Calculate data

  let categories = raw_categories.map(((category, ..rest)) => (category, rest)).to-dict()
  let categorized = categorize-projects(projects-data, categories)
  let statistics = (
    // We use a complex formula here, because `projects.len()` might be too large as it also counts deleted projects.
    project_count: categorized.values().map(c => c.projects.len() + c.hidden-projects.len()).sum(default: 0),
    category_count: categories.len(),
    stars_count: projects-data.map(p => p.star_count).sum(default: 0),
  )

  // Write document

  let assets = {
    html.style(read("style.css"))
    html.script(type: "module", read("tooltip.js"))
  }

  let body = {
    generate-outline()
    generate-categories(categorized, configuration, labels)
  }

  (configuration: configuration, statistics: statistics, assets: assets, body: body)
}
