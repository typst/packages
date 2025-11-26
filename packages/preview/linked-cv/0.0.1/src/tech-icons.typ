// Tech Stack Icons - Auto-generated from icon-data.json
// DO NOT EDIT MANUALLY - Regenerate using: python generate_tech_icons.py
//
// All icons have standardized viewBox="0 0 128 128" for consistent sizing
// Icon data loaded from icon-data.json at compile time (no duplication!)

// Load icon data from JSON file
#let icon-data = json("icon-data.json")

// List of all available icon names for type safety and autocomplete
#let available-icons = icon-data.keys().sorted()

// Common aliases for icon names (maps common names to actual icon names)
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
  // Resolve aliases
  let resolved-name = resolve-icon-name(name)

  // Validate icon name
  assert(
    resolved-name in icon-data,
    message: "Unknown icon: '" + name + "' (resolved to: '" + resolved-name + "'). Available: " + available-icons.slice(0, 10).join(", ") + "... (and " + str(available-icons.len() - 10) + " more)"
  )

  let svg-body = icon-data.at(resolved-name)

  // Build complete SVG with standardized viewBox
  // xmlns and viewBox are the same for all icons (no duplication in data)
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
//   icons: Array of icon names (can use aliases)
//   size: Height of each icon (default: 0.66em)
//   spacing: Space between icons (default: 2pt)
//
// Example:
//   #tech-icons(("python", "typescript", "react"))
//   #tech-icons(("gcp", "docker", "k8s"), size: 0.8em)
//
#let tech-icons(icons, size: 0.66em, spacing: 2pt) = {
  let tech-list = icons.join(", ")
  let tech-stack-text = "Tech stack: " + tech-list

  box({
    context {
      place(
        right + top,
        dx: 0pt,
        dy: 0pt,
        box(width: 0pt, height: 0pt, [
          #box(width: 10000pt, [
            #text(
              size: 0.01pt,
              fill: white,
              tech-stack-text
            )
          ])
        ])
      )
    }

    for (i, icon-name) in icons.enumerate() {
      tech-icon(icon-name, size: size)
      if i < icons.len() - 1 {
        h(spacing)
      }
    }
  })
}
