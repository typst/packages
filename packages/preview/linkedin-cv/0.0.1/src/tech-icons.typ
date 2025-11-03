#let icon-data = json("icon-data.json")

#let available-icons = icon-data.keys().sorted()

#let icon-aliases = (
  "gcp": "googlecloud",
  "google-cloud": "googlecloud",
  "tailwind": "tailwindcss",
  "next": "nextjs",
  "node": "nodejs",
  "d3": "d3js",
  "vue": "vuejs",
  "ember": "emberjs",
  "backbone": "backbonejs",
  "three": "threejs",
  "p5": "p5js",
  "react-bootstrap": "reactbootstrap",
  "material-ui": "materialui",
  "ms-sql": "microsoftsqlserver",
  "mssql": "microsoftsqlserver",
  "sqlserver": "microsoftsqlserver",
  "postgres": "postgressql",
  "postgresql": "postgressql",
  "poetry": "pythonpoetry",
  "terraform": "hashicorpterraform",
  "vagrant": "hashicorpvagrant",
  "vault": "hashicorpvault",
  "k8s": "kubernetes",
  "uml": "unifiedmodellinglanguage",
  "ts": "typescript",
  "js": "javascript",
  "py": "python",
)

#let resolve-icon-name(name) = {
  if name in icon-aliases {
    icon-aliases.at(name)
  } else {
    name
  }
}

#let tech-icon(name, size: 0.66em, baseline: 20%) = {
  let resolved-name = resolve-icon-name(name)

  assert(
    resolved-name in icon-data,
    message: "Unknown icon: '" + name + "' (resolved to: '" + resolved-name + "'). Available: " + available-icons.slice(0, 10).join(", ") + "... (and " + str(available-icons.len() - 10) + " more)"
  )

  let svg-body = icon-data.at(resolved-name)

  let svg-string = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 128 128\">" + svg-body + "</svg>"

  box(
    height: size,
    baseline: baseline,
  )[
    #image(bytes(svg-string), format: "svg", height: 100%)
  ]
}

#let tech-icons(icons, size: 0.66em, spacing: 2pt) = {
  box({
    for (i, icon-name) in icons.enumerate() {
      tech-icon(icon-name, size: size)
      if i < icons.len() - 1 {
        h(spacing)
      }
    }
  })
}
