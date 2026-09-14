// Sidebar component for CV layout
// Manages side content state

// === Side Content Function ===
// Updates the sidebar content state for display in the CV layout
#let side(content) = {
  context state("side-content").update(content)
}
