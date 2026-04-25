// =============================================================================
// source-to-class-diagram — C# Grammar
// =============================================================================
// Relation inference rules (same as Java grammar):
//   1. A non-primitive field/property → association  (label = member name)
//   2. `new X()` anywhere in class body → promotes association → composition
//   3. Constructor parameter of type X  → promotes association → aggregation
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

        let vis-match = rest.match(regex("^(public|private|protected|internal)\\s+"))
        if vis-match != none {
          visibility = vis-match.captures.at(0)
          if visibility == "internal" { visibility = "package" }
          rest = rest.slice(vis-match.end).trim()
        }

        let modifiers  = ()
        let keep-going = true
        while keep-going {
          if rest.starts-with("static ") {
            modifiers.push("static")
            rest = rest.slice(7).trim()
          } else if rest.starts-with("abstract ") or rest.starts-with("virtual ") or rest.starts-with("override ") {
            if not ("abstract" in modifiers) { modifiers.push("abstract") }
            rest = rest.split(" ").slice(1).join(" ").trim()
          } else if rest.starts-with("sealed ") or rest.starts-with("readonly ") {
            rest = rest.split(" ").slice(1).join(" ").trim()
          } else {
            keep-going = false
          }
        }

        // C# properties with `{ get; set; }` on the same line: strip the accessor block
        // before deciding if it's a method, so `public Foo Bar { get; set; }` → treated as field.
        let is-property-inline = (rest.contains("{ get") or rest.contains("{get")
                                  or rest.contains("{ set") or rest.contains("{set"))

        // Strip initialiser (`= ...`) before checking for `(` so that field
        // declarations like `List<Foo> _f = new List<Foo>()` are never
        // misidentified as methods.
        let rest-sig = if rest.contains("=") { rest.split("=").at(0).trim() } else { rest }
        let rest-sig = if rest-sig.contains("{") { rest-sig.split("{").at(0).trim() } else { rest-sig }

        let is-method = rest-sig.contains("(") and not is-property-inline

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
          // ── Field, Property or Enum constant ────────────────────────────
          // Strip initialiser, accessor block, and semicolon
          if rest.contains("=")  { rest = rest.split("=").at(0).trim() }
          if rest.contains("{")  { rest = rest.split("{").at(0).trim() }
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

            // For generic types like List<Foo>, extract inner type as target.
            let inner-match  = return-type.match(regex("<([A-Z][\\w.]*)>"))
            let assoc-target = if inner-match != none {
              inner-match.captures.at(0)
            } else {
              return-type.replace(regex("<.*>"), "").replace("[]", "")
            }

            // Rule 1: non-primitive field/property → register association (first wins)
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
            // Enum constant: single identifier with no type (e.g. Pequeno, Medio)
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
      //        Done AFTER step 2 so a field init `Foo f = new Foo()` is also promoted.
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

    // C# attribute annotation: [Layout(Level = 1, Order = 1)]
    // Also accept legacy @Layout(level=1, order=1) for compatibility.
    let layout-match = line.match(regex("^\\[Layout\\s*\\((.*)\\)\\]"))
    if layout-match == none {
      layout-match = line.match(regex("^@Layout\\s*\\((.*)\\)"))
    }
    if layout-match != none {
      let params  = layout-match.captures.at(0)
      // Match Pascal-case (C#) and lowercase (legacy) keys
      let level-m = params.match(regex("(?i)level\\s*=\\s*(\\d+)"))
      let order-m = params.match(regex("(?i)order\\s*=\\s*(\\d+)"))
      if level-m != none { layout-level = int(level-m.captures.at(0)) }
      if order-m != none { layout-order = int(order-m.captures.at(0)) }
      continue
    }

    // Allman-style opening brace: `{` on its own line after a class/interface declaration.
    // current-class is kept alive (not cleared) when is-opening was false; once we see
    // the `{` we can formally enter the class body.
    if current-class != none and line == "{" {
      brace-depth = 1
      continue
    }

    // C# class/interface/struct/enum declaration
    let m = line.match(regex(
      "^(?:(public|protected|private|internal)\\s+)?(?:(abstract|sealed)\\s+)?(class|interface|struct|enum)\\s+([A-Z][\\w.]*)"
    ))
    if m != none {
      let modifier = m.captures.at(1)
      let keyword  = m.captures.at(2)
      let name     = m.captures.at(3)
      let cls-type = if modifier == "abstract" or keyword == "abstract" { "abstract" }
                     else if keyword == "struct" { "class" }
                     else                        { keyword }

      let cls = ir.uml-class(name: name, type: cls-type, level: layout-level, order: layout-order)
      current-class   = cls
      current-members = ()
      field-rels      = (:)
      layout-level    = none
      layout-order    = none

      // C# uses `: BaseClass, IInterface` syntax for inheritance/implementation
      let after-name  = line.slice(m.end)
      let colon-match = after-name.match(regex(":\\s*([^{]+)"))
      if colon-match != none {
        for inherit in colon-match.captures.at(0).split(",").map(s => s.trim()) {
          if inherit != "" {
            // Heuristic: names starting with capital I followed by another capital = interface
            let rel-type = if (inherit.starts-with("I") and inherit.len() > 1
                                and inherit.at(1).match(regex("[A-Z]")) != none) {
              "implementation"
            } else {
              "inheritance"
            }
            relations.push(ir.uml-relation(from: name, to: inherit, type: rel-type))
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
        // Allman-style: the opening `{` will appear on the next line.
        // Keep current-class alive and wait — do NOT push to classes yet.
      }
    }
  }

  ir.uml-diagram(classes: classes, relations: relations, packages: packages)
}
