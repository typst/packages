// TTP Module for MITRE ATT&CK References
// Renders inline TTP cards with links to MITRE definitions

/// Renders a MITRE ATT&CK TTP reference as an inline card.
///
/// - id: The technique ID (e.g., "T1059.001")
/// - name: Optional technique name (shown on hover/after ID)
/// - show-name: Whether to show the name inline (default: false)
/// - style: Custom styling
#let ttp(
  id,
  name: none,
  show-name: false,
  style: (:),
) = {
  // Default style
  let default-style = (
    bg: rgb("#fef3c7"),
    border: rgb("#f59e0b"),
    text: rgb("#92400e"),
    size: 0.85em,
    radius: 3pt,
  )

  let s = default-style
  if "bg" in style { s.bg = style.bg }
  if "border" in style { s.border = style.border }
  if "text" in style { s.text = style.text }
  if "size" in style { s.size = style.size }

  // Build MITRE URL
  // Format: https://attack.mitre.org/techniques/T1059/001/
  let url-id = id.replace(".", "/")
  let mitre-url = "https://attack.mitre.org/techniques/" + url-id + "/"

  // Build display content
  let display = if show-name and name != none {
    [#id (#name)]
  } else {
    id
  }

  // Render inline card
  link(mitre-url, box(
    fill: s.bg,
    stroke: 0.5pt + s.border,
    radius: s.radius,
    inset: (x: 4pt, y: 2pt),
    baseline: 20%,
    text(size: s.size, fill: s.text, weight: "medium")[#display],
  ))
}

/// Renders a TTP with tactic context.
///
/// - id: The technique ID
/// - tactic: The tactic name (e.g., "Execution")
/// - name: Optional technique name
#let ttp-full(
  id,
  tactic: none,
  name: none,
  style: (:),
) = {
  let default-style = (
    tactic-color: rgb("#6366f1"),
  )

  let s = default-style
  if "tactic-color" in style { s.tactic-color = style.tactic-color }

  // Tactic badge
  let tactic-badge = if tactic != none {
    box(
      fill: s.tactic-color.lighten(80%),
      stroke: 0.5pt + s.tactic-color,
      radius: 3pt,
      inset: (x: 4pt, y: 2pt),
      baseline: 20%,
      text(size: 0.8em, fill: s.tactic-color.darken(20%), weight: "medium")[#tactic],
    )
    h(0.3em)
  }

  [#tactic-badge#ttp(id, name: name, show-name: name != none)]
}

// Tactic-specific shortcuts with appropriate colors
#let tactic-colors = (
  reconnaissance: rgb("#6b7280"),
  resource-development: rgb("#6b7280"),
  initial-access: rgb("#dc2626"),
  execution: rgb("#ea580c"),
  persistence: rgb("#ca8a04"),
  privilege-escalation: rgb("#65a30d"),
  defense-evasion: rgb("#0d9488"),
  credential-access: rgb("#0284c7"),
  discovery: rgb("#7c3aed"),
  lateral-movement: rgb("#c026d3"),
  collection: rgb("#db2777"),
  command-and-control: rgb("#e11d48"),
  exfiltration: rgb("#be123c"),
  impact: rgb("#991b1b"),
)

/// Enterprise technique (most common)
#let technique = ttp

/// Sub-technique reference
#let sub-technique = ttp
