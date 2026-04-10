#let icon-data = json("icon-data.json")

#let available-icons = icon-data.keys().sorted()

#let icon-aliases = (
  // Cloud platforms
  "gcp": "googlecloud",
  "google-cloud": "googlecloud",

  // CSS frameworks & libraries
  "tailwind": "tailwindcss",

  // JavaScript frameworks
  "next": "nextjs",
  "node": "nodejs",
  "d3": "d3js",
  "vue": "vuejs",
  "ember": "emberjs",
  "backbone": "backbonejs",
  "three": "threejs",
  "p5": "p5js",

  // React ecosystem
  "react-bootstrap": "reactbootstrap",
  "material-ui": "materialui",

  // Databases
  "sqlserver": "microsoftsqlserver",
  "postgres": "postgressql",
  "postgresql": "postgressql",

  // Python tools
  "poetry": "pythonpoetry",

  // Infrastructure
  "vagrant": "hashicorpvagrant",
  "vault": "hashicorpvault",
  "k8s": "kubernetes",

  // Other
  "uml": "unifiedmodellinglanguage",

  // Language shortcuts
  "ts": "typescript",
  "js": "javascript",
  "py": "python",
)

// Resolve icon name (handles aliases)
#let resolve-icon-name(name) = {
  if name in icon-aliases {
    icon-aliases.at(name)
  } else {
    name
  }
}

// Render a tech stack icon as inline SVG
//
// All icons use standardized viewBox="0 0 128 128" for consistent sizing.
// Only the unique SVG body content is stored per icon.
//
// Parameters:
//   name: Icon name (must be one of the available-icons) or alias
//   size: Height of the icon (default: 0.66em to match text)
//   baseline: Baseline alignment (default: 20%)
//
// Example:
//   #tech-icon("python")
//   #tech-icon("typescript", size: 1em)
//   #tech-icon("gcp")  // Uses alias → googlecloud
//
#let tech-icon(name, size: 0.66em, baseline: 20%) = {
  let resolved-name = resolve-icon-name(name)

  assert(
    resolved-name in icon-data,
    message: "Unknown icon: '" + name + "' (resolved to: '" + resolved-name + "'). Available: " + available-icons.slice(0, 10).join(", ") + "... (and " + str(available-icons.len() - 10) + " more)"
  )

  let svg-body = icon-data.at(resolved-name)

  let svg-string = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 128 128\">" + svg-body + "</svg>"

  // Render as inline image
  box(
    height: size,
    baseline: baseline,
  )[
    #image(bytes(svg-string), format: "svg", height: 100%)
  ]
}

// Render multiple tech icons horizontally
//
// Parameters:
//   icons: Array of icon names (can use aliases) or custom content (images, etc.)
//   size: Height of each icon (default: 0.66em)
//   spacing: Space between icons (default: 2pt)
//
// Example:
//   #tech-icons(("python", "typescript", "react"))
//   #tech-icons(("gcp", "docker", "k8s"), size: 0.8em)
//   #tech-icons(("python", image("custom-logo.svg"), "react"))
//
#let tech-icons(icons, size: 0.66em, spacing: 2pt) = {
  box({
    for (i, icon-item) in icons.enumerate() {
      // If it's a string, treat it as an icon name
      if type(icon-item) == str {
        tech-icon(icon-item, size: size)
      } else {
        // Otherwise, render custom content (e.g., image) with consistent sizing
        box(
          height: size,
          baseline: 20%,
        )[#icon-item]
      }
      if i < icons.len() - 1 {
        h(spacing)
      }
    }
  })
}
