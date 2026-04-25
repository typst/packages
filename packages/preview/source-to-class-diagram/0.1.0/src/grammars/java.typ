// =============================================================================
// source-to-class-diagram — Java Grammar
// =============================================================================
// Relation inference rules:
//   1. A non-primitive field  → association  (label = field name)
//   2. `new X()` anywhere in class body → promotes association → composition
//   3. Constructor parameter of type X   → promotes association → aggregation
//
// Priority: aggregation (2) > composition (1) > association (0)
// Promotions never downgrade an existing relation.
//
// TYPST GOTCHA: closures/inner-functions cannot mutate outer-scope arrays.
// All pushes to `relations` must be done inline, not via helper functions.

#import "../ir.typ"
#import "../parser/utils.typ" as putils

// ---------------------------------------------------------------------------
// Priority helpers  (pure functions — safe to use)
// ---------------------------------------------------------------------------

#let _priority = (association: 0, composition: 1, aggregation: 2)

/// Try to upgrade the relation type for `target` in `field-rels`.
/// Only upgrades if `new-type` has strictly higher priority.
/// Returns the (possibly updated) field-rels dict.
#let _try-upgrade(field-rels, target, new-type) = {
  if target in field-rels {
    let existing = field-rels.at(target)
    let cur  = _priority.at(existing.type,  default: 0)
    let next = _priority.at(new-type, default: 0)
    if next > cur {
      let updated = field-rels
      updated.insert(target, (label: existing.label, type: new-type))
      updated
    } else {
      field-rels
    }
  } else {
    field-rels
  }
}

// ---------------------------------------------------------------------------
// Parser
// ---------------------------------------------------------------------------

#let parse(source) = {
  let lines = source.split("\n")

  let classes   = ()
  let relations = ()
  let packages  = ()

  let current-class   = none
  let current-members = ()
  let brace-depth     = 0

  let layout-level = none
  let layout-order = none

  // Per-class accumulator: target-class-name → (label: str, type: str)
  // Fields are registered here as "association" and promoted in-place as we parse.
  let field-rels = (:)

  for raw-line in lines {
    let line = raw-line.trim()
    if line == "" or line.starts-with("//") { continue }

    // -----------------------------------------------------------------------
    // Inside a class body
    // -----------------------------------------------------------------------
    if brace-depth > 0 {
      let depth-before = brace-depth
      for ch in line.clusters() {
        if ch == "{" { brace-depth += 1 }
        if ch == "}" { brace-depth -= 1 }
      }

      // --- 1. Detect `throw new ExceptionType()` → dependency --------------
      let throw-targets = ()
      for tm in line.matches(regex("throw\\s+new\\s+([A-Z][\\w.]*)")) {
        let target = tm.captures.at(0)
        throw-targets.push(target)
        relations.push(ir.uml-relation(
          from: current-class.name,
          to:   target,
          type: "dependency",
        ))
      }

      // --- 2. Parse direct class members (depth-before == 1) ---------------
      if depth-before == 1 and brace-depth > 0 {
        let rest = line
        let visibility = if current-class.type == "interface" { "public" } else { "package" }

        let vis-match = rest.match(regex("^(public|private|protected)\\s+"))
        if vis-match != none {
          visibility = vis-match.captures.at(0)
          rest = rest.slice(vis-match.end).trim()
        }

        let modifiers  = ()
        let keep-going = true
        while keep-going {
          if rest.starts-with("static ")        { modifiers.push("static");   rest = rest.slice(7).trim() }
          else if rest.starts-with("abstract ") { modifiers.push("abstract"); rest = rest.slice(9).trim() }
          else if rest.starts-with("final ")    {                             rest = rest.slice(6).trim() }
          else { keep-going = false }
        }

        let is-method = rest.contains("(")

        if is-method {
          let pre-paren-match = rest.match(regex("^([^(]+)"))
          if pre-paren-match != none {
            let pre-paren = pre-paren-match.text.trim()
            let parts     = pre-paren.split(regex("\\s+"))

            if parts.len() == 1 and parts.at(0) == current-class.name {
              // ── Constructor ────────────────────────────────────────────────
              let paren-inside = putils.extract-between(rest, "(", ")")
              if paren-inside != none and paren-inside.trim() != "" {
                let params-str = paren-inside.trim()
                current-members.push(ir.uml-member(
                  name:        current-class.name,
                  return-type: none,
                  visibility:  visibility,
                  modifiers:   modifiers,
                  kind:        "method",
                  params:      params-str,
                ))
                // Rule 3: constructor params of non-primitive types
                //         promote the field's association to aggregation.
                for p in params-str.split(",") {
                  let p-words = p.trim().split(regex("\\s+"))
                  if p-words.len() >= 2 {
                    let raw-type  = p-words.at(0)
                    let inner-m   = raw-type.match(regex("<([A-Z][\\w.]*)>"))
                    let type-name = if inner-m != none {
                      inner-m.captures.at(0)
                    } else {
                      raw-type.replace(regex("<.*>"), "").replace("[]", "")
                    }
                    if not putils.is-primitive-type(type-name) {
                      field-rels = _try-upgrade(field-rels, type-name, "aggregation")
                    }
                  }
                }
              } else {
                current-members.push(ir.uml-member(
                  name:        current-class.name,
                  return-type: none,
                  visibility:  visibility,
                  modifiers:   modifiers,
                  kind:        "method",
                  params:      none,
                ))
              }

            } else if parts.len() >= 2 {
              // ── Regular method ─────────────────────────────────────────────
              let name        = parts.last()
              let return-type = parts.slice(0, parts.len() - 1).join(" ")
              let params-str  = putils.extract-between(rest, "(", ")")
              current-members.push(ir.uml-member(
                name:        name,
                return-type: return-type,
                visibility:  visibility,
                modifiers:   modifiers,
                kind:        "method",
                params:      if params-str != "" { params-str } else { none },
              ))
            }
          }
        } else {
          // ── Field or Enum constant ────────────────────────────────────────
          if rest.contains("=") { rest = rest.split("=").at(0).trim() }
          if rest.ends-with(";") { rest = rest.slice(0, rest.len() - 1).trim() }

          // Enum constants: strip trailing comma and optional constructor args
          if current-class.type == "enum" {
            if rest.ends-with(",") { rest = rest.slice(0, rest.len() - 1).trim() }
            let paren-idx = rest.position("(")
            if paren-idx != none { rest = rest.slice(0, paren-idx).trim() }
          }

          let parts = rest.split(regex("\\s+"))
          if parts.len() >= 2 {
            let name        = parts.last()
            let return-type = parts.slice(0, parts.len() - 1).join(" ")

            // For generic types like List<Class2>, the *meaningful* target is
            // the inner type (Class2), not the collection wrapper (List).
            // Extract the inner type when present; fall back to clean-type.
            let inner-match  = return-type.match(regex("<([A-Z][\\w.]*)>"))
            let assoc-target = if inner-match != none {
              inner-match.captures.at(0)
            } else {
              return-type.replace(regex("<.*>"), "").replace("[]", "")
            }

            // Rule 1: non-primitive field → register association (first field wins)
            if not putils.is-primitive-type(assoc-target) {
              if assoc-target not in field-rels {
                field-rels.insert(assoc-target, (label: name, type: "association"))
              }
            }

            current-members.push(ir.uml-member(
              name:        name,
              return-type: return-type,
              visibility:  visibility,
              modifiers:   modifiers,
              kind:        "field",
            ))
          } else if parts.len() == 1 and current-class.type == "enum" and parts.at(0) != "" {
            // Enum constant: single identifier with no type (e.g. PEQUENO, MEDIO)
            current-members.push(ir.uml-member(
              name:        parts.at(0),
              return-type: none,
              visibility:  "public",
              modifiers:   (),
              kind:        "field",
            ))
          }
        }
      }

      // --- 3. Detect `new X()` anywhere in class body ----------------------
      //        Rule 2: promotes field association to composition.
      //        Done AFTER step 2 so a field init `Foo f = new Foo()` is promoted.
      if line.contains("new ") {
        for nm in line.matches(regex("new\\s+([A-Z][\\w.]*)\\s*\\(")) {
          let target = nm.captures.at(0)
          if (target not in throw-targets) and (not putils.is-primitive-type(target)) {
            field-rels = _try-upgrade(field-rels, target, "composition")
          }
        }
      }

      // --- 4. Class body closed — emit accumulated field relations ----------
      // TYPST GOTCHA: must be inline here; a helper closure cannot mutate `relations`.
      if brace-depth == 0 {
        if current-class != none {
          current-class.insert("members", current-members)
          classes.push(current-class)

          // Inline flush of field-rels → relations
          for (target, rel) in field-rels {
            relations.push(ir.uml-relation(
              from:  current-class.name,
              to:    target,
              type:  rel.type,
              label: rel.label,
            ))
          }

          current-class   = none
          current-members = ()
          field-rels      = (:)
        }
      }

      continue
    }

    // -----------------------------------------------------------------------
    // Outside class body — layout annotations and class declarations
    // -----------------------------------------------------------------------

    let layout-match = line.match(regex("^@Layout\\s*\\((.*)\\)"))
    if layout-match != none {
      let params  = layout-match.captures.at(0)
      let level-m = params.match(regex("level\\s*=\\s*(\\d+)"))
      let order-m = params.match(regex("order\\s*=\\s*(\\d+)"))
      if level-m != none { layout-level = int(level-m.captures.at(0)) }
      if order-m != none { layout-order = int(order-m.captures.at(0)) }
      continue
    }

    let m = line.match(regex(
      "^(?:(public|protected|private|package)\\s+)?(?:(abstract)\\s+)?(class|interface|enum|@interface)\\s+([A-Z][\\w.]*)"
    ))
    if m != none {
      let is-abstract = m.captures.at(1) != none
      let keyword     = m.captures.at(2)
      let name        = m.captures.at(3)
      let cls-type    = if is-abstract               { "abstract"   }
                        else if keyword == "@interface" { "annotation" }
                        else                           { keyword      }

      let cls = ir.uml-class(name: name, type: cls-type, level: layout-level, order: layout-order)
      current-class   = cls
      current-members = ()
      field-rels      = (:)
      layout-level    = none
      layout-order    = none

      // Inheritance / implementation
      let after-name = line.slice(m.end)

      let extends-match = after-name.match(regex("extends\\s+([A-Z][\\w.]*)"))
      if extends-match != none {
        relations.push(ir.uml-relation(
          from: name,
          to:   extends-match.captures.at(0),
          type: "inheritance",
        ))
      }

      let implements-match = after-name.match(regex("implements\\s+([^{]+)"))
      if implements-match != none {
        for impl in implements-match.captures.at(0).split(",").map(s => s.trim()) {
          if impl != "" {
            relations.push(ir.uml-relation(from: name, to: impl, type: "implementation"))
          }
        }
      }

      let is-opening = line.contains("{")
      if is-opening {
        brace-depth = 1
        for ch in line.clusters() {
          if ch == "{" { brace-depth += 1 }
          if ch == "}" { brace-depth -= 1 }
        }
        brace-depth -= 1   // adjust the initial +1 assumption

        if brace-depth == 0 {
          // Inline / empty class — flush immediately
          current-class.insert("members", current-members)
          classes.push(current-class)
          for (target, rel) in field-rels {
            relations.push(ir.uml-relation(
              from:  current-class.name,
              to:    target,
              type:  rel.type,
              label: rel.label,
            ))
          }
          current-class = none
          field-rels    = (:)
        }
      } else {
        classes.push(cls)
        current-class = none
      }
    }
  }

  ir.uml-diagram(classes: classes, relations: relations, packages: packages)
}
