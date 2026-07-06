// adaptive-dots: Automatically adapts ellipsis dots based on context
// Similar to LaTeX amsmath \dots behavior

// ============================================================================
// Pre-computed constants (evaluated once at module load)
// ============================================================================

// Element function extractors
#let sequence = $a b$.body.func()
#let space-elem = $a b$.body.children.at(1).func()

// Centered-baseline operators: binary operators and relations
// These use dots.c (⋯) instead of dots (…)
// Using dictionary for O(1) lookup
#let centered-ops = {
  let ops = (:)
  // Binary operators (TeX class 2)
  for op in (
    "+", "−", "-", "×", "÷", "±", "∓", 
    "⋅", "·", "∗", "*", "∘", 
    "⊕", "⊗", "⊙", "⊖", "⊘",
    "∧", "∨", "⊻", "⊼", "⊽",
    "∪", "∩", "∖", "△", "▽",
    "⋆", "⋄", "•", "∙",
  ) { ops.insert(op, true) }
  // Relations (TeX class 3)
  for op in (
    "=", "≠", "≡", "≢", "≈", "≉", "∼", "≃", "≅", "≇",
    "<", ">", "≤", "≥", "≦", "≧", "≪", "≫", 
    "≺", "≻", "⪯", "⪰", "≼", "≽",
    "⊂", "⊃", "⊆", "⊇", "⊊", "⊋", "⊄", "⊅",
    "∈", "∉", "∋", "∌",
    "⊢", "⊣", "⊨", "⊩",
    "∝", "∥", "∦", "⊥", "∣", "∤",
    "→", "←", "↔", "⇒", "⇐", "⇔",
    "↦", "↪", "↩", "⟶", "⟵", "⟷",
  ) { ops.insert(op, true) }
  ops
}

// ============================================================================
// Explicit dot variants (escape auto-conversion)
// ============================================================================

/// Baseline dots - use this to force baseline dots in centered contexts
/// Usage: $1 + 2 + ldots + n$ → baseline dots despite + operators
#let ldots = math.class("normal", $dots$)

/// Centered dots - use this to force centered dots in baseline contexts  
/// Usage: $a, b, cdots, z$ → centered dots despite commas
#let cdots = math.class("normal", $dots.c$)

// ============================================================================
// Helper functions
// ============================================================================

/// Check if content is a centered-baseline operator
#let is-centered-op(content) = {
  if content == none { return false }
  
  // Handle text content (most common case)
  if content.has("text") {
    return centered-ops.at(content.text, default: false)
  }
  
  // Handle symbol content - check repr for known operators
  // This catches cases like sym.plus, sym.eq, etc.
  let r = repr(content)
  if r.starts-with("[") and r.ends-with("]") {
    let inner = r.slice(1, -1)
    return centered-ops.at(inner, default: false)
  }
  
  false
}

/// Check if content represents ellipsis dots (but not our escaped variants)
#let is-dots-element(content) = {
  if content == none { return false }
  
  let r = repr(content)
  
  // Skip math.class wrapped dots (our ldots/cdots escapes)
  if r.contains("class") { return false }
  
  // Check for dots symbol (from $...$ or $dots$)
  if r == "[…]" { return true }
  
  // Check for text containing ellipsis
  if content.has("text") {
    return content.text == "…" or content.text == "..."
  }
  
  // Check function - dots is a symbol (but not dots.c, dots.v, etc.)
  if r.contains("dots") and not r.contains("dots.") { return true }
  
  false
}

/// Get sibling at offset, skipping space elements
/// Returns (sibling-content, sibling-index) or (none, -1)
#let get-sibling(children, index, direction) = {
  let i = index + direction
  while i >= 0 and i < children.len() {
    let child = children.at(i)
    if child.func() != space-elem {
      return (child, i)
    }
    i = i + direction
  }
  (none, -1)
}

// ============================================================================
// Core transformation
// ============================================================================

/// Transform a sequence, replacing dots with context-appropriate variant
#let convert-dots-sequence(seq) = {
  // Only process sequences
  if type(seq) != content or seq.func() != sequence {
    return seq
  }
  
  let children = seq.children
  if children.len() == 0 { return seq }
  
  // Quick check: if no dots in sequence, return unchanged
  let has-dots = children.any(c => is-dots-element(c))
  if not has-dots { return seq }
  
  // Build new children array with dots replaced
  let new-children = ()
  
  for (i, child) in children.enumerate() {
    if is-dots-element(child) {
      // Get neighbors
      let (prev, _) = get-sibling(children, i, -1)
      let (next, _) = get-sibling(children, i, 1)
      
      // Choose variant based on neighbors
      if is-centered-op(prev) or is-centered-op(next) {
        new-children.push($dots.c$)
      } else {
        new-children.push($dots$)
      }
    } else {
      new-children.push(child)
    }
  }
  
  new-children.join()
}

// ============================================================================
// Main entry point
// ============================================================================

/// Apply adaptive dots transformation to document
/// Usage: #show: adaptive-dots
#let adaptive-dots(body) = {
  show math.equation: eq => {
    show sequence: seq => {
      let converted = convert-dots-sequence(seq)
      if seq != converted { converted } else { seq }
    }
    eq
  }
  
  body
}
