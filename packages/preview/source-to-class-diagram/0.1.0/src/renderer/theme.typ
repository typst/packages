// =============================================================================
// source-to-class-diagram — Theme System
// =============================================================================
// Visual theming for class diagrams.

/// Default UML theme with professional colors.
#let default-theme = (
  // Header colors per class type
  class-header: (
    class:      (fill: rgb("#D4E6F1"), stroke: rgb("#2980B9")),
    abstract:   (fill: rgb("#E8DAEF"), stroke: rgb("#8E44AD")),
    interface:  (fill: rgb("#D5F5E3"), stroke: rgb("#27AE60")),
    enum:       (fill: rgb("#FCF3CF"), stroke: rgb("#F39C12")),
    annotation: (fill: rgb("#FADBD8"), stroke: rgb("#E74C3C")),
  ),
  // Body area
  class-body: (
    fill: white,
    stroke: rgb("#888888"),
  ),
  // Typography
  font: (
    class-name-size: 11pt,
    member-size: 9pt,
    member-font: "Consolas",
    stereotype-size: 8pt,
  ),
  // Visibility icon colors
  visibility-colors: (
    public:    rgb("#27AE60"),
    private:   rgb("#E74C3C"),
    protected: rgb("#F39C12"),
    package:   rgb("#2980B9"),
  ),
  // Visibility display symbols (shown in the diagram)
  visibility-symbols: (
    public:    (field: "○", method: "●"),
    private:   (field: "□", method: "■"),
    protected: (field: "◇", method: "◆"),
    package:   (field: "△", method: "▲"),
  ),
  // Relation styles
  relation: (
    stroke-thickness: 1pt,
    color: rgb("#2C3E50"),
    label-size: 8pt,
    card-size: 8pt,
  ),
  // Box styling
  corner-radius: 3pt,
  padding: 6pt,
  min-width: 100pt,
)

/// Get header style for a class type. Falls back to "class" style.
#let get-header-style(theme, cls-type) = {
  if cls-type in theme.class-header {
    theme.class-header.at(cls-type)
  } else {
    theme.class-header.at("class")
  }
}
