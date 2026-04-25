// =============================================================================
// source-to-class-diagram — Class Box Renderer
// =============================================================================
// Builds Typst content blocks for UML class boxes and places them in CeTZ.

#import "../deps.typ": cetz
#import "theme.typ" as themes

/// Render a single UML member line as Typst content.
///
/// - member (dict): A uml-member dictionary
/// - theme (dict): The active theme
#let _render-member(member, theme) = {
  let vis-sym = theme.visibility-symbols.at(member.visibility, default: "~")
  if type(vis-sym) == dictionary {
    vis-sym = vis-sym.at(member.kind, default: "~")
  }
  let vis-col = theme.visibility-colors.at(member.visibility, default: rgb("#666"))

  // Build the text content
  let member-content = {
    // Visibility symbol
    text(fill: vis-col, weight: "bold")[#vis-sym]
    [ ]  // space

    if member.kind == "method" {
      // Method: name(params): ReturnType
      [#member.name]
      [(]
      if member.params != none {
        text(size: 0.9em)[#member.params]
      }
      [)]
      if member.return-type != none {
        [: #member.return-type]
      }
    } else {
      // Field: name: Type
      [#member.name]
      if member.return-type != none {
        [: #member.return-type]
      }
    }
  }

  // Apply modifiers
  if "static" in member.modifiers {
    underline(member-content)
  } else if "abstract" in member.modifiers {
    emph(member-content)
  } else {
    member-content
  }
}

/// Build the complete Typst content block for a class box.
///
/// - cls (dict): A uml-class dictionary
/// - theme (dict): The active theme
/// Returns: Typst content that visually represents the class box.
#let build-class-content(cls, theme) = {
  let header-style = themes.get-header-style(theme, cls.type)
  let fields = cls.members.filter(m => m.kind == "field")
  let methods = cls.members.filter(m => m.kind == "method")

  // --- Header Content ---
  let header-body = {
    set align(center)
    // Stereotype
    if cls.stereotype != none {
      text(size: theme.font.stereotype-size, style: "italic")[«#cls.stereotype»]
      linebreak()
    }
    // Type indicator for interfaces/enums/annotations
    if cls.type == "interface" {
      text(size: theme.font.stereotype-size, style: "italic")[«interface»]
      linebreak()
    } else if cls.type == "enum" {
      text(size: theme.font.stereotype-size, style: "italic")[«enum»]
      linebreak()
    } else if cls.type == "annotation" {
      text(size: theme.font.stereotype-size, style: "italic")[«annotation»]
      linebreak()
    }
    // Class name
    {
      set text(size: theme.font.class-name-size, weight: "bold")
      if cls.type == "abstract" {
        emph[#cls.name]
      } else {
        [#cls.name]
      }
    }
    // Generics
    if cls.generics != none {
      text(size: theme.font.stereotype-size)[<#cls.generics>]
    }
  }

  // --- Build the table ---
  let rows = ()

  // Header row
  rows.push(
    table.cell(fill: header-style.fill, align: center, inset: theme.padding)[
      #header-body
    ]
  )

  // Fields section
  if fields.len() > 0 {
    let fields-body = {
      set text(size: theme.font.member-size, font: theme.font.member-font)
      set align(left)
      for (i, f) in fields.enumerate() {
        _render-member(f, theme)
        if i < fields.len() - 1 { linebreak() }
      }
    }
    rows.push(
      table.cell(inset: theme.padding)[#fields-body]
    )
  }

  // Methods section
  if methods.len() > 0 {
    let methods-body = {
      set text(size: theme.font.member-size, font: theme.font.member-font)
      set align(left)
      for (i, m) in methods.enumerate() {
        _render-member(m, theme)
        if i < methods.len() - 1 { linebreak() }
      }
    }
    rows.push(
      table.cell(inset: theme.padding)[#methods-body]
    )
  }

  // If no fields and no methods, add an empty row for minimal box
  if fields.len() == 0 and methods.len() == 0 {
    rows.push(table.cell(inset: (x: theme.padding, y: 2pt))[])
  }

  // Build the final table
  {
    set text(size: theme.font.member-size)
    table(
      columns: (auto,),
      stroke: 1pt + header-style.stroke,
      inset: 0pt,
      align: left,
      ..rows,
    )
  }
}

/// Draw a class box in the CeTZ canvas.
///
/// - cls (dict): A uml-class dictionary
/// - pos (tuple): (x, y) position in canvas coordinates
/// - theme (dict): The active theme
#let draw-class(cls, pos, theme) = {
  let content-block = build-class-content(cls, theme)
  cetz.draw.content(
    pos,
    name: cls.name,
    anchor: "center",
    content-block,
  )
}
