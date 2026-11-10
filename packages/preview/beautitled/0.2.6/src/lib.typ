// beautitled - Beautiful title styling package for Typst
// ============================================================================
// A comprehensive package for styling headings with many distinctive themes
// All styles are PRINT-FRIENDLY (minimal ink usage)
// ============================================================================

// Import all styles
#import "styles/titled.typ": style-titled
#import "styles/classic.typ": style-classic
#import "styles/modern.typ": style-modern
#import "styles/elegant.typ": style-elegant
#import "styles/bold.typ": style-bold
#import "styles/creative.typ": style-creative
#import "styles/minimal.typ": style-minimal
#import "styles/magazine.typ": style-magazine
#import "styles/technical.typ": style-technical
#import "styles/vintage.typ": style-vintage
#import "styles/schoolbook.typ": style-schoolbook
#import "styles/notes.typ": style-notes
#import "styles/clean.typ": style-clean
#import "styles/academic.typ": style-academic
#import "styles/textbook.typ": style-textbook
#import "styles/scholarly.typ": style-scholarly
#import "styles/classical.typ": style-classical
#import "styles/educational.typ": style-educational
#import "styles/structured.typ": style-structured

// ============================================================================
// Available Styles Reference (19 styles)
// ============================================================================
//
// ORIGINAL:
//   titled      - Boxed sections with floating labels (default)
//
// GENERAL PURPOSE:
//   classic     - Traditional with underlines
//   modern      - Clean geometric with accent
//   elegant     - Refined with ornaments
//   bold        - Strong left border
//   creative    - Student portfolio style
//   minimal     - Ultra-clean
//   vintage     - Classic book ornaments
//
// EDUCATIONAL:
//   schoolbook  - Textbook style
//   notes       - Course notes
//   clean       - Maximum simplicity
//
// ACADEMIC:
//   technical   - Documentation
//   academic    - Professional academic
//   textbook    - Bold numbers, clear hierarchy
//   scholarly   - Centered with thin rules
//   classical   - Small caps, minimal
//   educational - Left border with numbers
//   structured  - Boxed numbers
//   magazine    - Editorial style
//
// ============================================================================

// Style registry
#let beautitled-styles = (
  // Original
  titled: style-titled,
  // General
  classic: style-classic,
  modern: style-modern,
  elegant: style-elegant,
  bold: style-bold,
  creative: style-creative,
  minimal: style-minimal,
  vintage: style-vintage,
  // Educational
  schoolbook: style-schoolbook,
  notes: style-notes,
  clean: style-clean,
  // Academic
  technical: style-technical,
  academic: style-academic,
  textbook: style-textbook,
  scholarly: style-scholarly,
  classical: style-classical,
  educational: style-educational,
  structured: style-structured,
  magazine: style-magazine,
)

// ============================================================================
// Global Configuration State
// ============================================================================

#let beautitled-config = state("beautitled-config", (
  style: "titled",  // Default to original titled style

  // Color palette
  primary-color: rgb("#2c3e50"),
  secondary-color: rgb("#7f8c8d"),
  accent-color: rgb("#2980b9"),
  background-color: white,

  // Typography
  heading-font: none,
  body-font: none,

  // Font sizes
  part-size: 24pt,
  chapter-size: 18pt,
  section-size: 14pt,
  subsection-size: 12pt,
  subsubsection-size: 11pt,

  // Numbering
  enable-parts: false,  // Native = Heading becomes a part when enabled
  show-part-number: true,
  show-chapter-number: true,
  show-section-number: true,
  show-subsection-number: true,
  show-chapter-in-section: true,  // Show "Ch. X : Title" in section labels (titled style)

  // Prefixes (localization)
  part-prefix: "Partie",
  chapter-prefix: "Chapitre",
  section-prefix: "Section",

  // Spacing
  part-above: 2em,
  part-below: 1.2em,
  chapter-above: 1.5em,
  chapter-below: 0.8em,
  section-above: 1em,
  section-below: 0.5em,
  subsection-above: 0.8em,
  subsection-below: 0.4em,

  // Page breaks
  part-pagebreak: true,    // Automatic page break before parts (inline mode)
  chapter-pagebreak: false, // Automatic page break before chapters
  part-fullpage: true,     // LaTeX-style: part gets its own centered page

  // TOC styling
  toc-title: "Table of Contents",  // Default TOC title
  toc-style: none,  // none = use same as style, or specify different style name
  toc-indent: 1em,
  toc-part-size: 14pt,
  toc-chapter-size: 12pt,
  toc-section-size: 11pt,
  toc-subsection-size: 10pt,
  toc-fill: repeat[.],
  toc-show-subsections: true,
))

// ============================================================================
// Setup Function
// ============================================================================

#let beautitled-setup(
  style: none,
  primary-color: none,
  secondary-color: none,
  accent-color: none,
  background-color: none,
  heading-font: none,
  body-font: none,
  part-size: none,
  chapter-size: none,
  section-size: none,
  subsection-size: none,
  subsubsection-size: none,
  enable-parts: none,
  show-part-number: none,
  show-chapter-number: none,
  show-section-number: none,
  show-subsection-number: none,
  show-chapter-in-section: none,
  part-prefix: none,
  chapter-prefix: none,
  section-prefix: none,
  part-above: none,
  part-below: none,
  chapter-above: none,
  chapter-below: none,
  section-above: none,
  section-below: none,
  subsection-above: none,
  subsection-below: none,
  part-pagebreak: none,
  chapter-pagebreak: none,
  part-fullpage: none,
  toc-title: none,
  toc-style: none,
  toc-indent: none,
  toc-part-size: none,
  toc-chapter-size: none,
  toc-section-size: none,
  toc-subsection-size: none,
  toc-fill: none,
  toc-show-subsections: none,
) = {
  beautitled-config.update(cfg => {
    let new = cfg
    if style != none { new.style = style }
    if primary-color != none { new.primary-color = primary-color }
    if secondary-color != none { new.secondary-color = secondary-color }
    if accent-color != none { new.accent-color = accent-color }
    if background-color != none { new.background-color = background-color }
    if heading-font != none { new.heading-font = heading-font }
    if body-font != none { new.body-font = body-font }
    if part-size != none { new.part-size = part-size }
    if chapter-size != none { new.chapter-size = chapter-size }
    if section-size != none { new.section-size = section-size }
    if subsection-size != none { new.subsection-size = subsection-size }
    if subsubsection-size != none { new.subsubsection-size = subsubsection-size }
    if enable-parts != none { new.enable-parts = enable-parts }
    if show-part-number != none { new.show-part-number = show-part-number }
    if show-chapter-number != none { new.show-chapter-number = show-chapter-number }
    if show-chapter-in-section != none { new.show-chapter-in-section = show-chapter-in-section }
    if show-section-number != none { new.show-section-number = show-section-number }
    if show-subsection-number != none { new.show-subsection-number = show-subsection-number }
    if part-prefix != none { new.part-prefix = part-prefix }
    if chapter-prefix != none { new.chapter-prefix = chapter-prefix }
    if section-prefix != none { new.section-prefix = section-prefix }
    if part-above != none { new.part-above = part-above }
    if part-below != none { new.part-below = part-below }
    if chapter-above != none { new.chapter-above = chapter-above }
    if chapter-below != none { new.chapter-below = chapter-below }
    if section-above != none { new.section-above = section-above }
    if section-below != none { new.section-below = section-below }
    if subsection-above != none { new.subsection-above = subsection-above }
    if subsection-below != none { new.subsection-below = subsection-below }
    if part-pagebreak != none { new.part-pagebreak = part-pagebreak }
    if chapter-pagebreak != none { new.chapter-pagebreak = chapter-pagebreak }
    if part-fullpage != none { new.part-fullpage = part-fullpage }
    if toc-title != none { new.toc-title = toc-title }
    if toc-style != none { new.toc-style = toc-style }
    if toc-indent != none { new.toc-indent = toc-indent }
    if toc-part-size != none { new.toc-part-size = toc-part-size }
    if toc-chapter-size != none { new.toc-chapter-size = toc-chapter-size }
    if toc-section-size != none { new.toc-section-size = toc-section-size }
    if toc-subsection-size != none { new.toc-subsection-size = toc-subsection-size }
    if toc-fill != none { new.toc-fill = toc-fill }
    if toc-show-subsections != none { new.toc-show-subsections = toc-show-subsections }
    new
  })
}

// ============================================================================
// Counters and State
// ============================================================================

#let part-counter = counter("beautitled-part")
#let chapter-counter = counter("beautitled-chapter")
#let section-counter = counter("beautitled-section")
#let subsection-counter = counter("beautitled-subsection")
#let subsubsection-counter = counter("beautitled-subsubsection")

// State to prevent show rule recursion
#let _beautitled-internal = state("beautitled-internal", false)

// Protected dot separator for numbering (prevents decimal-comma regex from matching)
#let _numsep = "\u{2060}.\u{2060}"

/// Reset all counters to 0
#let reset-counters() = {
  part-counter.update(0)
  chapter-counter.update(0)
  section-counter.update(0)
  subsection-counter.update(0)
  subsubsection-counter.update(0)
}

// ============================================================================
// Internal: Get style renderer
// ============================================================================

#let get-style-renderer(style-name) = {
  if style-name in beautitled-styles {
    beautitled-styles.at(style-name)
  } else {
    beautitled-styles.at("titled")
  }
}

// ============================================================================
// Part Heading
// ============================================================================

#let _default-part-style(title, num, cfg, show-num) = {
  let primary = cfg.primary-color
  let secondary = cfg.secondary-color
  let accent = cfg.accent-color

  block(width: 100%, above: 0pt, below: 0pt)[
    #align(center)[
      #if show-num [
        #text(size: 12pt, weight: "bold", fill: accent, tracking: 0.12em)[#upper(cfg.part-prefix) #numbering("I", num)]
        #v(0.45em)
      ]
      #text(size: cfg.part-size, weight: "bold", fill: primary)[#title]
      #v(0.45em)
      #line(length: 35%, stroke: 0.8pt + secondary)
    ]
  ]
}

#let part(
  title,
  numbered: auto,
  label: none,
  fullpage: auto,
  image: none,
  image-caption: none,
  image-position: "below",  // "above" or "below" the title
  from-init: false,
) = {
  beautitled-config.update(cfg => {
    let new = cfg
    new.enable-parts = true
    new
  })
  part-counter.step()
  chapter-counter.update(0)
  section-counter.update(0)
  subsection-counter.update(0)
  subsubsection-counter.update(0)

  context {
    let cfg = beautitled-config.get()
    let style = get-style-renderer(cfg.style)
    let num = part-counter.get().first()
    let show-num = if numbered == auto { cfg.show-part-number } else { numbered }
    let use-fullpage = if fullpage == auto { cfg.part-fullpage } else { fullpage }

    let outline-title = if show-num {
      [#cfg.part-prefix #numbering("I", num) : #title]
    } else {
      title
    }

    let meta-and-heading = {
      if label != none {
        [#metadata((kind: "_btl-ref-meta", target-key: str(label), env-type: "part", show-num: show-num, title: title)) #label]
      }
      place(hide[#heading(level: 1, outlined: true, bookmarked: true, outline-title) <_btl-internal>])
    }

    if use-fullpage {
      // LaTeX-style: part gets its own vertically-centred page
      pagebreak(weak: true)
      let img-block = if image != none {
        v(2em)
        if image-caption != none {
          figure(image, caption: image-caption, numbering: none, supplement: none)
        } else {
          image
        }
      }
      let title-block = if "part" in style {
        (style.part)(title, num, cfg, show-num)
      } else {
        _default-part-style(title, num, cfg, show-num)
      }
      v(1fr)
      align(center)[
        #if image-position == "above" and image != none { img-block }
        #title-block
        #if image-position != "above" and image != none { img-block }
      ]
      meta-and-heading
      v(1fr)
      pagebreak(weak: true)
    } else {
      if cfg.part-pagebreak and num > 1 {
        pagebreak(weak: true)
      }
      v(cfg.part-above)
      if "part" in style {
        (style.part)(title, num, cfg, show-num)
      } else {
        _default-part-style(title, num, cfg, show-num)
      }
      meta-and-heading
      v(cfg.part-below)
    }
  }
}

// ============================================================================
// Chapter Heading
// ============================================================================

#let chapter(title, numbered: auto, label: none, from-init: false) = {
  chapter-counter.step()
  section-counter.update(0)
  subsection-counter.update(0)
  subsubsection-counter.update(0)

  context {
    let cfg = beautitled-config.get()
    let style = get-style-renderer(cfg.style)
    let num = chapter-counter.get().first()
    let show-num = if numbered == auto { cfg.show-chapter-number } else { numbered }

    // Page break before chapter if enabled
    if cfg.chapter-pagebreak and num > 1 {
      pagebreak(weak: true)
    }

    v(cfg.chapter-above)

    // Create outline entry for TOC/bookmarks
    let outline-title = if show-num {
      [#cfg.chapter-prefix #num : #title]
    } else {
      title
    }

    (style.chapter)(title, num, cfg, show-num)

    // Register heading for outline without affecting layout (placed after content)
    // The label marks this as internal to prevent show rule recursion
    let outline-level = if cfg.enable-parts { 2 } else { 1 }
    if label != none {
      [#metadata((kind: "_btl-ref-meta", target-key: str(label), env-type: "chapter", show-num: show-num, title: title)) #label]
    }
    place(hide[#heading(level: outline-level, outlined: true, bookmarked: true, outline-title) <_btl-internal>])
    v(cfg.chapter-below)
  }
}

// ============================================================================
// Section Heading
// ============================================================================

#let section(title, numbered: auto, label: none, from-init: false) = {
  section-counter.step()
  subsection-counter.update(0)
  subsubsection-counter.update(0)

  context {
    let cfg = beautitled-config.get()
    let style = get-style-renderer(cfg.style)
    let ch-num = chapter-counter.get().first()
    let sec-num = section-counter.get().first()
    let show-num = if numbered == auto { cfg.show-section-number } else { numbered }

    v(cfg.section-above)

    // Create outline entry for TOC/bookmarks
    let outline-title = if show-num {
      if ch-num > 0 {
        [#str(ch-num)#_numsep#str(sec-num) #title]
      } else {
        [#str(sec-num). #title]
      }
    } else {
      title
    }

    (style.section)(title, ch-num, sec-num, cfg, show-num)
    let outline-level = if cfg.enable-parts { 3 } else { 2 }
    if label != none {
      [#metadata((kind: "_btl-ref-meta", target-key: str(label), env-type: "section", show-num: show-num, title: title)) #label]
    }
    place(hide[#heading(level: outline-level, outlined: true, bookmarked: true, outline-title) <_btl-internal>])
    v(cfg.section-below)
  }
}

// ============================================================================
// Subsection Heading
// ============================================================================

#let subsection(title, numbered: auto, label: none, from-init: false) = {
  subsection-counter.step()
  subsubsection-counter.update(0)

  context {
    let cfg = beautitled-config.get()
    let style = get-style-renderer(cfg.style)
    let ch-num = chapter-counter.get().first()
    let sec-num = section-counter.get().first()
    let subsec-num = subsection-counter.get().first()
    let show-num = if numbered == auto { cfg.show-subsection-number } else { numbered }

    v(cfg.subsection-above)

    // Create outline entry for TOC/bookmarks
    let outline-title = if show-num {
      [#str(sec-num)#_numsep#str(subsec-num) #title]
    } else {
      title
    }

    (style.subsection)(title, ch-num, sec-num, subsec-num, cfg, show-num)
    let outline-level = if cfg.enable-parts { 4 } else { 3 }
    if label != none {
      [#metadata((kind: "_btl-ref-meta", target-key: str(label), env-type: "subsection", show-num: show-num, title: title)) #label]
    }
    place(hide[#heading(level: outline-level, outlined: cfg.toc-show-subsections, bookmarked: true, outline-title) <_btl-internal>])
    v(cfg.subsection-below)
  }
}

// ============================================================================
// Subsubsection Heading
// ============================================================================

#let subsubsection(title, numbered: auto, label: none, from-init: false) = {
  subsubsection-counter.step()

  context {
    let cfg = beautitled-config.get()
    let style = get-style-renderer(cfg.style)
    let sec-num = section-counter.get().first()
    let subsec-num = subsection-counter.get().first()
    let subsubsec-num = subsubsection-counter.get().first()
    let show-num = if numbered == auto { cfg.show-subsection-number } else { numbered }

    v(cfg.subsection-above)

    // Create outline entry for bookmarks
    let outline-title = if show-num {
      [#str(sec-num)#_numsep#str(subsec-num)#_numsep#str(subsubsec-num) #title]
    } else {
      title
    }

    if "subsubsection" in style {
      (style.subsubsection)(title, sec-num, subsec-num, subsubsec-num, cfg, show-num)
    } else {
      text(weight: "semibold", size: 10pt)[
        #if show-num [#str(sec-num)#_numsep#str(subsec-num)#_numsep#str(subsubsec-num) #h(0.4em)]
        #title
      ]
    }
    let outline-level = if cfg.enable-parts { 5 } else { 4 }
    if label != none {
      [#metadata((kind: "_btl-ref-meta", target-key: str(label), env-type: "subsubsection", show-num: show-num, title: title)) #label]
    }
    place(hide[#heading(level: outline-level, outlined: false, bookmarked: true, outline-title) <_btl-internal>])
    v(cfg.subsection-below)
  }
}

// ============================================================================
// Heading Reference
// ============================================================================

/// Reference a labelled beautitled heading (part, chapter, section, subsection, subsubsection).
///
/// The heading must be called with a label parameter, e.g.:
///   #chapter(label: <intro>)[Introduction]
///   See #beautitled-ref(<intro>) for context.
///
/// Parameters:
///   target        - The label of the heading to reference
///   show-page     - Include a page number (default: false)
///   page-prefix   - Prefix before page number (default: "p. ")
///   short         - Omit the prefix word, show number only (default: false)
#let beautitled-ref(
  target,
  show-page: false,
  page-prefix: "p. ",
  short: false,
) = context {
  let cfg = beautitled-config.get()
  let key = str(target)

  let hits = query(metadata).filter(m => {
    let v = m.value
    type(v) == dictionary and v.at("kind", default: none) == "_btl-ref-meta" and v.at("target-key", default: none) == key
  })

  if hits.len() == 0 {
    [??]
  } else {
    let info = hits.first().value
    let env-type = info.env-type
    let show-num = info.show-num

    let num-text = if not show-num {
      info.title
    } else if env-type == "part" {
      let n = part-counter.at(target).first()
      if short { [#numbering("I", n)] }
      else { [#cfg.part-prefix #numbering("I", n)] }
    } else if env-type == "chapter" {
      let n = chapter-counter.at(target).first()
      if short { [#n] }
      else { [#cfg.chapter-prefix #n] }
    } else if env-type == "section" {
      let ch = chapter-counter.at(target).first()
      let sec = section-counter.at(target).first()
      let num = if ch > 0 { [#str(ch)#_numsep#str(sec)] } else { [#str(sec)] }
      if short { num } else { [#cfg.section-prefix #num] }
    } else if env-type == "subsection" {
      let sec = section-counter.at(target).first()
      let sub = subsection-counter.at(target).first()
      [#str(sec)#_numsep#str(sub)]
    } else if env-type == "subsubsection" {
      let sec = section-counter.at(target).first()
      let sub = subsection-counter.at(target).first()
      let subsub = subsubsection-counter.at(target).first()
      [#str(sec)#_numsep#str(sub)#_numsep#str(subsub)]
    } else {
      [??]
    }

    let page-text = if show-page {
      let pg = counter(page).at(target).first()
      [ (#page-prefix#pg)]
    } else {
      []
    }

    link(target)[#num-text#page-text]
  }
}

#let btl-ref = beautitled-ref

// ============================================================================
// Table of Contents / Outline
// ============================================================================

// TOC style renderers - each matches its corresponding heading style
// Using block with above/below spacing instead of v() to avoid overlap issues
#let toc-styles = (
  // Default/titled style
  titled: (cfg) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    (
      chapter: it => {
        block(above: 0.6em, stroke: (left: 2pt + cfg.accent-color), inset: (left: 0.5em))[
          #text(size: cfg.toc-chapter-size, weight: "bold", fill: primary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
      section: it => {
        block(inset: (left: cfg.toc-indent))[
          #text(size: cfg.toc-section-size, fill: primary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
      subsection: it => {
        block(inset: (left: cfg.toc-indent * 2))[
          #text(size: cfg.toc-subsection-size, fill: secondary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
    )
  },

  // Classic style
  classic: (cfg) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    (
      chapter: it => {
        block(above: 0.5em, below: 0.2em)[
          #text(size: cfg.toc-chapter-size, weight: "bold", fill: primary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
          #line(length: 100%, stroke: 0.5pt + secondary)
        ]
      },
      section: it => {
        block(inset: (left: cfg.toc-indent))[
          #text(size: cfg.toc-section-size, fill: primary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
      subsection: it => {
        block(inset: (left: cfg.toc-indent * 2))[
          #text(size: cfg.toc-subsection-size, fill: secondary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
    )
  },

  // Modern style
  modern: (cfg) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color
    let secondary = cfg.secondary-color
    (
      chapter: it => {
        block(above: 0.6em)[
          #box(width: 3pt, height: 0.9em, fill: accent)
          #h(0.4em)
          #text(size: cfg.toc-chapter-size, weight: "bold", fill: primary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
      section: it => {
        block(inset: (left: cfg.toc-indent))[
          #text(size: cfg.toc-section-size, fill: primary)[
            #text(fill: accent)[▸] #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
      subsection: it => {
        block(inset: (left: cfg.toc-indent * 2))[
          #text(size: cfg.toc-subsection-size, fill: secondary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
    )
  },

  // Elegant style
  elegant: (cfg) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    (
      chapter: it => {
        block(above: 0.5em)[
          #text(size: cfg.toc-chapter-size, weight: "bold", fill: primary, tracking: 0.05em)[
            #link(it.element.location())[#smallcaps[#it.element.body]]
            #box(width: 1fr, repeat[#h(0.3em)·])
            #it.page()
          ]
        ]
      },
      section: it => {
        block(inset: (left: cfg.toc-indent))[
          #text(size: cfg.toc-section-size, fill: primary, style: "italic")[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, repeat[#h(0.3em)·])
            #it.page()
          ]
        ]
      },
      subsection: it => {
        block(inset: (left: cfg.toc-indent * 2))[
          #text(size: cfg.toc-subsection-size, fill: secondary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, repeat[#h(0.3em)·])
            #it.page()
          ]
        ]
      },
    )
  },

  // Bold style
  bold: (cfg) => {
    let primary = cfg.primary-color
    let accent = cfg.accent-color
    let secondary = cfg.secondary-color
    (
      chapter: it => {
        block(above: 0.5em, stroke: (left: 3pt + accent), inset: (left: 0.6em))[
          #text(size: cfg.toc-chapter-size, weight: "black", fill: primary)[
            #link(it.element.location())[#upper(it.element.body)]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
      section: it => {
        block(inset: (left: cfg.toc-indent))[
          #text(size: cfg.toc-section-size, weight: "bold", fill: primary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
      subsection: it => {
        block(inset: (left: cfg.toc-indent * 2))[
          #text(size: cfg.toc-subsection-size, fill: secondary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
    )
  },

  // Minimal style
  minimal: (cfg) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    (
      chapter: it => {
        block(above: 0.4em)[
          #text(size: cfg.toc-chapter-size, weight: "regular", fill: primary)[
            #link(it.element.location())[#it.element.body]
            #h(1fr)
            #it.page()
          ]
        ]
      },
      section: it => {
        block(inset: (left: cfg.toc-indent))[
          #text(size: cfg.toc-section-size, fill: primary)[
            #link(it.element.location())[#it.element.body]
            #h(1fr)
            #it.page()
          ]
        ]
      },
      subsection: it => {
        block(inset: (left: cfg.toc-indent * 2))[
          #text(size: cfg.toc-subsection-size, fill: secondary)[
            #link(it.element.location())[#it.element.body]
            #h(1fr)
            #it.page()
          ]
        ]
      },
    )
  },

  // Scholarly style
  scholarly: (cfg) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    (
      chapter: it => {
        block(above: 0.6em, below: 0.3em)[
          #text(size: cfg.toc-chapter-size, weight: "bold", fill: primary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
      section: it => {
        block(inset: (left: cfg.toc-indent))[
          #text(size: cfg.toc-section-size, fill: primary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
      subsection: it => {
        block(inset: (left: cfg.toc-indent * 2))[
          #text(size: cfg.toc-subsection-size, fill: secondary, style: "italic")[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
    )
  },

  // Simple style - clean flat list with dots
  simple: (cfg) => {
    let primary = cfg.primary-color
    let secondary = cfg.secondary-color
    (
      chapter: it => {
        block(above: 0.4em)[
          #text(size: cfg.toc-chapter-size, fill: primary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
      section: it => {
        block(above: 0.4em)[
          #text(size: cfg.toc-section-size, fill: primary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
      subsection: it => {
        block(above: 0.3em, inset: (left: cfg.toc-indent))[
          #text(size: cfg.toc-subsection-size, fill: secondary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
        ]
      },
    )
  },
)

#let _toc-with-part(renderer, cfg) = {
  let primary = cfg.primary-color
  let accent = cfg.accent-color

  let part-renderer = if "part" in renderer {
    renderer.part
  } else {
    it => {
      block(above: 0.9em, below: 0.35em)[
        #align(center)[
          #text(size: cfg.toc-part-size, weight: "bold", fill: primary)[
            #link(it.element.location())[#it.element.body]
            #box(width: 1fr, cfg.toc-fill)
            #it.page()
          ]
          #line(length: 100%, stroke: 0.6pt + accent)
        ]
      ]
    }
  }

  (
    part: part-renderer,
    chapter: renderer.chapter,
    section: renderer.section,
    subsection: renderer.subsection,
  )
}

// Get TOC style renderer, fallback to titled style
#let get-toc-style(style-name, cfg) = {
  let renderer = if style-name in toc-styles {
    (toc-styles.at(style-name))(cfg)
  } else {
    (toc-styles.at("titled"))(cfg)
  }
  _toc-with-part(renderer, cfg)
}

/// Styled table of contents
#let beautitled-toc(
  title: auto,  // auto = use config toc-title, none = no title, or custom string
  depth: 3,
  style: none,  // Override style for TOC only
  title-align: center,  // Title alignment: center, left, right
) = context {
  let cfg = beautitled-config.get()
  let actual-title = if title == auto { cfg.toc-title } else { title }
  let toc-style-name = if style != none { style } else if cfg.toc-style != none { cfg.toc-style } else { cfg.style }
  let primary = cfg.primary-color
  let secondary = cfg.secondary-color
  let accent = cfg.accent-color
  let toc-renderer = get-toc-style(toc-style-name, cfg)
  let has-parts = cfg.enable-parts or part-counter.final().first() > 0

  // Title (only if provided)
  if actual-title != none {
    align(title-align)[
      #text(size: cfg.chapter-size, weight: "bold", fill: primary)[#actual-title]
    ]
    v(1em)
  }

  // Custom outline rendering based on style
  if has-parts {
    show outline.entry.where(level: 1): it => (toc-renderer.part)(it)
    show outline.entry.where(level: 2): it => block(inset: (left: cfg.toc-indent))[(toc-renderer.chapter)(it)]
    show outline.entry.where(level: 3): it => block(inset: (left: cfg.toc-indent))[(toc-renderer.section)(it)]
    show outline.entry.where(level: 4): it => block(inset: (left: cfg.toc-indent))[(toc-renderer.subsection)(it)]
  } else {
    show outline.entry.where(level: 1): it => (toc-renderer.chapter)(it)
    show outline.entry.where(level: 2): it => (toc-renderer.section)(it)
    show outline.entry.where(level: 3): it => (toc-renderer.subsection)(it)
  }

  outline(
    title: none,
    depth: depth,
    indent: auto,
  )
}

// ============================================================================
// Show Rule Initialization
// ============================================================================

#let beautitled-init(doc) = {
  // Transform native Typst headings to beautitled styled versions
  // Skip headings that have the internal label (outline entries created by beautitled)
  show heading.where(level: 1): it => {
    if it.has("label") and str(it.label) == "_btl-internal" { it }
    else {
      context {
        let cfg = beautitled-config.get()
        if cfg.enable-parts { part(it.body, from-init: true) }
        else { chapter(it.body, from-init: true) }
      }
    }
  }
  show heading.where(level: 2): it => {
    if it.has("label") and str(it.label) == "_btl-internal" { it }
    else {
      context {
        let cfg = beautitled-config.get()
        if cfg.enable-parts { chapter(it.body, from-init: true) }
        else { section(it.body, from-init: true) }
      }
    }
  }
  show heading.where(level: 3): it => {
    if it.has("label") and str(it.label) == "_btl-internal" { it }
    else {
      context {
        let cfg = beautitled-config.get()
        if cfg.enable-parts { section(it.body, from-init: true) }
        else { subsection(it.body, from-init: true) }
      }
    }
  }
  show heading.where(level: 4): it => {
    if it.has("label") and str(it.label) == "_btl-internal" { it }
    else {
      context {
        let cfg = beautitled-config.get()
        if cfg.enable-parts { subsection(it.body, from-init: true) }
        else { subsubsection(it.body, from-init: true) }
      }
    }
  }
  show heading.where(level: 5): it => {
    if it.has("label") and str(it.label) == "_btl-internal" { it }
    else {
      context {
        let cfg = beautitled-config.get()
        if cfg.enable-parts { subsubsection(it.body, from-init: true) }
        else { it }
      }
    }
  }
  // Suppress original headings from outline (beautitled creates its own entries)
  set heading(outlined: false, bookmarked: false)
  doc
}

// ============================================================================
// Preset Configurations
// ============================================================================

/// French academic preset
#let preset-french = beautitled-setup.with(
  part-prefix: "Partie",
  chapter-prefix: "Chapitre",
  section-prefix: "Section",
)

/// English preset
#let preset-english = beautitled-setup.with(
  part-prefix: "Part",
  chapter-prefix: "Chapter",
  section-prefix: "Section",
)

/// German academic preset
#let preset-german = beautitled-setup.with(
  part-prefix: "Teil",
  chapter-prefix: "Kapitel",
  section-prefix: "Abschnitt",
)

/// No numbering preset
#let preset-no-numbers = beautitled-setup.with(
  show-part-number: false,
  show-chapter-number: false,
  show-section-number: false,
  show-subsection-number: false,
)

// ============================================================================
// Color Themes
// ============================================================================

/// Ocean blue theme
#let theme-ocean = beautitled-setup.with(
  primary-color: rgb("#1a5276"),
  secondary-color: rgb("#5dade2"),
  accent-color: rgb("#2980b9"),
)

/// Forest green theme
#let theme-forest = beautitled-setup.with(
  primary-color: rgb("#1e8449"),
  secondary-color: rgb("#82e0aa"),
  accent-color: rgb("#27ae60"),
)

/// Royal purple theme
#let theme-royal = beautitled-setup.with(
  primary-color: rgb("#6c3483"),
  secondary-color: rgb("#bb8fce"),
  accent-color: rgb("#8e44ad"),
)

/// Monochrome theme
#let theme-mono = beautitled-setup.with(
  primary-color: rgb("#2c3e50"),
  secondary-color: rgb("#7f8c8d"),
  accent-color: rgb("#34495e"),
)

/// Warm theme
#let theme-warm = beautitled-setup.with(
  primary-color: rgb("#a04000"),
  secondary-color: rgb("#dc7633"),
  accent-color: rgb("#d35400"),
)

/// Coral theme
#let theme-coral = beautitled-setup.with(
  primary-color: rgb("#c0392b"),
  secondary-color: rgb("#e74c3c"),
  accent-color: rgb("#e74c3c"),
)
