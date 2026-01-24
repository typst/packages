// citeproc-typst - Name Formatting
//
// Formats author/editor names according to CSL rules
// Includes CSL-M extension: cs:institution for institutional authors

#import "../parsing/locales.typ": is-cjk-name, lookup-term
#import "../core/constants.typ": POSITION
#import "../core/utils.typ": capitalize-first-char

// =============================================================================
// Module-level regex patterns (avoid recompilation)
// =============================================================================

#let _name-split-pattern = regex("[ -]+")

// =============================================================================
// Et-al Setting Resolution
// =============================================================================

/// Resolve an et-al setting with fallback cascade
///
/// Priority: sort-key override > subsequent cite > citation-level > bibliography > default
///
/// - value: Current value (from attrs)
/// - sort-override: Sort key override from context
/// - is-subsequent: Whether this is a subsequent cite
/// - subsequent-ctx-key: Context key for subsequent cite value
/// - citation-ctx-key: Context key for citation-level value
/// - bib-key: Bibliography key
/// - default-val: Default value
/// - ctx: Context
/// Returns: Resolved value
#let _resolve-et-al-setting(
  value,
  sort-override,
  is-subsequent,
  subsequent-ctx-key,
  citation-ctx-key,
  bib-key,
  default-val,
  ctx,
) = {
  // Sort key override has highest priority
  if sort-override != none { return sort-override }

  // Use provided value if set
  if value != none { return value }

  // For subsequent cites, try subsequent-specific setting
  if is-subsequent {
    let subsequent-val = ctx.at(subsequent-ctx-key, default: none)
    if subsequent-val != none { return subsequent-val }
  }

  // Try citation-level setting
  let citation-val = ctx.at(citation-ctx-key, default: none)
  if citation-val != none { return citation-val }

  // Fall back to bibliography setting
  let bib = ctx.style.at("bibliography", default: none)
  if bib != none {
    return bib.at(bib-key, default: default-val)
  }

  default-val
}

/// Resolve all et-al settings for name formatting
///
/// - attrs: Name element attributes
/// - ctx: Context
/// Returns: (et-al-min, et-al-use-first, et-al-use-last) tuple
#let _resolve-et-al-settings(attrs, ctx) = {
  // Get initial values from attrs
  let et-al-min = attrs.at("et-al-min", default: none)
  let et-al-use-first = attrs.at("et-al-use-first", default: none)
  let et-al-use-last = attrs.at("et-al-use-last", default: none)

  // Get sort key overrides (highest priority)
  let sort-names-min = ctx.at("sort-names-min", default: none)
  let sort-names-use-first = ctx.at("sort-names-use-first", default: none)
  let sort-names-use-last = ctx.at("sort-names-use-last", default: none)

  // Check if this is a subsequent cite
  let position = ctx.at("position", default: POSITION.first)
  let is-subsequent = (
    position == POSITION.subsequent
      or position == POSITION.ibid
      or position == POSITION.ibid-with-locator
  )

  // Resolve each setting
  et-al-min = _resolve-et-al-setting(
    et-al-min,
    sort-names-min,
    is-subsequent,
    "et-al-subsequent-min",
    "citation-et-al-min",
    "et-al-min",
    4,
    ctx,
  )

  et-al-use-first = _resolve-et-al-setting(
    et-al-use-first,
    sort-names-use-first,
    is-subsequent,
    "et-al-subsequent-use-first",
    "citation-et-al-use-first",
    "et-al-use-first",
    3,
    ctx,
  )

  // et-al-use-last has simpler fallback (no subsequent/citation variants)
  if sort-names-use-last != none {
    et-al-use-last = sort-names-use-last
  } else if et-al-use-last == none {
    let bib = ctx.style.at("bibliography", default: none)
    et-al-use-last = if bib != none {
      bib.at("et-al-use-last", default: false)
    } else { false }
  }

  // Convert types
  if type(et-al-min) == str { et-al-min = int(et-al-min) }
  if type(et-al-use-first) == str { et-al-use-first = int(et-al-use-first) }
  if type(et-al-use-last) == str { et-al-use-last = et-al-use-last == "true" }

  // Apply disambiguation expansion
  let names-expanded = ctx.at("names-expanded", default: 0)
  if names-expanded > 0 {
    et-al-use-first = et-al-use-first + names-expanded
  }

  (
    et-al-min: et-al-min,
    et-al-use-first: et-al-use-first,
    et-al-use-last: et-al-use-last,
  )
}

// =============================================================================
// Name Part Formatting
// =============================================================================

/// Apply name-part formatting
/// Handles CSL formatting attributes: font-style, font-weight, font-variant,
/// text-decoration, text-case, and affixes (prefix/suffix)
///
/// - text: Name part text to format
/// - attrs: Attributes from <name-part> element
/// Returns: Formatted content
#let format-name-part(text, attrs) = {
  if text == "" { return "" }
  if attrs.len() == 0 { return text }

  let result = text

  // Apply text-case first (works on strings)
  let text-case = attrs.at("text-case", default: none)
  if text-case != none {
    if text-case == "uppercase" {
      result = upper(result)
    } else if text-case == "lowercase" {
      result = lower(result)
    } else if text-case == "capitalize-first" and result.len() > 0 {
      result = capitalize-first-char(result)
    } else if text-case == "capitalize-all" {
      result = result.split(" ").map(w => capitalize-first-char(w)).join(" ")
    }
  }

  // Apply affixes
  let prefix = attrs.at("prefix", default: "")
  let suffix = attrs.at("suffix", default: "")
  if prefix != "" or suffix != "" {
    result = prefix + result + suffix
  }

  // Apply font formatting (convert to content if needed)
  let font-style = attrs.at("font-style", default: none)
  if font-style == "italic" or font-style == "oblique" {
    result = emph(result)
  }

  let font-weight = attrs.at("font-weight", default: none)
  if font-weight == "bold" {
    result = strong(result)
  } else if font-weight == "light" {
    result = text(weight: "light", result)
  }

  let text-decoration = attrs.at("text-decoration", default: none)
  if text-decoration == "underline" {
    result = underline(result)
  }

  let font-variant = attrs.at("font-variant", default: none)
  if font-variant == "small-caps" {
    result = smallcaps(result)
  }

  result
}

/// Check if a name is an institutional name (CSL-M extension)
///
/// In CSL-M, institutional names are stored with "literal" field or
/// with only "family" field and no "given" field.
///
/// - name: Name dict
/// Returns: bool
#let is-institutional-name(name) = {
  // Check for literal name (explicit institution)
  if "literal" in name { return true }

  // Check for family-only name (no given name)
  let family = name.at("family", default: "")
  let given = name.at("given", default: "")

  family != "" and given == ""
}

/// Format a single name
///
/// - name: Parsed name dict (family, given, prefix, suffix)
/// - attrs: Name formatting attributes from CSL
/// - ctx: Context
/// - position: Position in name list (1-indexed)
/// - name-parts: Dict of name-part formatting (from <name-part> elements)
#let format-single-name(
  name,
  attrs,
  ctx,
  position: 1,
  name-parts: (:),
) = {
  let family = name.at("family", default: "")
  let given = name.at("given", default: "")
  let prefix = name.at("prefix", default: "") // "von", "de", etc.
  let suffix = name.at("suffix", default: "") // "Jr.", "III", etc.

  let is-chinese = is-cjk-name(name)

  // Get formatting options from attrs (or style defaults)
  let name-as-sort-order = attrs.at(
    "name-as-sort-order",
    default: ctx.style.name-as-sort-order,
  )
  let initialize-with = attrs.at(
    "initialize-with",
    default: ctx.style.initialize-with,
  )
  let sort-separator = attrs.at(
    "sort-separator",
    default: ctx.style.sort-separator,
  )
  let name-form = attrs.at("form", default: "long")

  // Apply name-part formatting
  let family-part-attrs = name-parts.at("family", default: (:))
  let given-part-attrs = name-parts.at("given", default: (:))

  let formatted-family = format-name-part(family, family-part-attrs)
  let formatted-given = given

  // Get disambiguation givenname-level from context (CSL Method 1)
  // Level 0 = default, 1 = initials, 2 = full given name
  let givenname-level = ctx.at("givenname-level", default: 0)

  // Short form: only family name (unless disambiguation requires more)
  if name-form == "short" and givenname-level == 0 {
    return formatted-family
  }

  // If disambiguation requires showing given name but form is "short",
  // show the given name with family name in standard order (Given Family)
  if name-form == "short" and givenname-level > 0 {
    // Show initials (level 1) or full name (level 2)
    if givenname-level == 2 {
      // Full given name - don't initialize
      formatted-given = format-name-part(given, given-part-attrs)
    } else {
      // Level 1: show initials
      if given != "" and not is-chinese {
        let parts = given.split(_name-split-pattern).filter(p => p != "")
        // Use initialize-with from style, default to ". "
        let init-sep = if initialize-with != none { initialize-with } else {
          ". "
        }
        let initials = parts.map(p => {
          if p.len() > 0 { upper(p.first()) + init-sep } else { "" }
        })
        formatted-given = initials.join("").trim(at: end)
      }
      formatted-given = format-name-part(formatted-given, given-part-attrs)
    }
    // CSL spec: disambiguated short names show as "G. Family" not "Family, G."
    if formatted-given != "" {
      return [#formatted-given #formatted-family]
    } else {
      return formatted-family
    }
  }

  // Initialize given name if required (and not overridden by disambiguation)
  if (
    initialize-with != none
      and given != ""
      and not is-chinese
      and givenname-level != 2
  ) {
    // Split given names and take initials
    let parts = given.split(_name-split-pattern).filter(p => p != "")
    let initialize-hyphen = ctx.style.initialize-with-hyphen

    // Build initials with initialize-with after each
    let initials = parts.map(p => {
      if p.len() > 0 { upper(p.first()) + initialize-with } else { "" }
    })

    // Join with hyphen if needed
    if initialize-hyphen and given.contains("-") {
      // For hyphenated names, trim trailing space from each initial before joining
      // So "J. " + "-" + "P. " becomes "J.-P." not "J. -P."
      formatted-given = initials.map(i => i.trim(at: end)).join("-")
      // Add back trailing space if initialize-with ends with space
      if initialize-with.ends-with(" ") {
        formatted-given = formatted-given + " "
      }
    } else {
      formatted-given = initials.join("")
    }

    // Trim trailing space from initialize-with
    formatted-given = formatted-given.trim(at: end)
  }

  // Apply given name part formatting
  formatted-given = format-name-part(formatted-given, given-part-attrs)

  // Determine name order
  let use-sort-order = (
    name-as-sort-order == "all"
      or (name-as-sort-order == "first" and position == 1)
  )

  // Build name string
  if is-chinese {
    // Chinese: 姓名 (no separator)
    formatted-family + formatted-given
  } else if use-sort-order {
    // Sort order: Family Given Suffix (with sort-separator, no comma before suffix)
    // Per GB/T 7714-2025: "Sodeman W A Jr" not "Sodeman W A, Jr"

    // Handle prefix (demote-non-dropping-particle setting)
    let demote = ctx.style.demote-non-dropping-particle
    if prefix != "" and demote == "never" {
      // Prefix stays with family name
      formatted-family = prefix + " " + formatted-family
    }

    // Build name parts
    let result = formatted-family
    if formatted-given != "" {
      result = [#result#sort-separator#formatted-given]
    }
    // Add suffix without comma (per GB/T 7714)
    if suffix != "" {
      result = [#result #suffix]
    }
    result
  } else {
    // Display order: Given Family
    let parts = ()
    if formatted-given != "" { parts.push(formatted-given) }
    if prefix != "" { parts.push(prefix) }
    parts.push(formatted-family)
    if suffix != "" { parts.push(suffix) }
    parts.join(" ")
  }
}

/// Format a list of names
///
/// - names: Array of parsed name dicts
/// - attrs: Name formatting attributes
/// - ctx: Context
/// - name-parts: Dict of name-part formatting from <name-part> elements
/// - substitute-string: String to use for substituted names (for subsequent-author-substitute)
/// - substitute-count: Number of names from start to substitute (0 = no substitution)
#let format-names(
  names,
  attrs,
  ctx,
  name-parts: (:),
  substitute-string: none,
  substitute-count: 0,
) = {
  if names.len() == 0 { return [] }

  // ==========================================================================
  // CSL-M suppress-min / suppress-max
  // ==========================================================================
  // suppress-min: suppress names entirely if count <= value
  // suppress-max: suppress names entirely if count >= value
  // suppress-min="0": suppress all personal names (leave institutions)
  // suppress-max with form="count": show count only if > max

  let suppress-min = attrs.at("suppress-min", default: none)
  let suppress-max = attrs.at("suppress-max", default: none)

  if suppress-min != none {
    let min-val = if type(suppress-min) == str { int(suppress-min) } else {
      suppress-min
    }
    // suppress-min="0" is special: suppresses personal names only
    if min-val == 0 {
      // Filter out personal names, keep only institutional
      let institutional = names.filter(n => is-institutional-name(n))
      if institutional.len() == 0 { return [] }
      // Continue with institutional names only
      names = institutional
    } else if names.len() <= min-val {
      return []
    }
  }

  if suppress-max != none {
    let max-val = if type(suppress-max) == str { int(suppress-max) } else {
      suppress-max
    }
    if names.len() >= max-val {
      // For form="count", we return the count instead of suppressing
      let name-form = attrs.at("form", default: "long")
      if name-form == "count" {
        return str(names.len())
      }
      return []
    }
  }

  // Resolve et-al settings with fallback cascade
  let et-al = _resolve-et-al-settings(attrs, ctx)
  let et-al-min = et-al.et-al-min
  let et-al-use-first = et-al.et-al-use-first
  let et-al-use-last = et-al.et-al-use-last

  // Determine how many names to show
  // CSL spec: et-al is only used when the name list is TRUNCATED
  // If et-al-use-first >= names.len(), we show all names and don't use et-al
  let use-et-al = names.len() >= et-al-min and et-al-use-first < names.len()
  let show-count = if use-et-al { et-al-use-first } else { names.len() }

  // Format individual names
  let formatted = ()
  for (i, name) in names
    .slice(0, calc.min(show-count, names.len()))
    .enumerate() {
    // Check if this name should be substituted
    if substitute-string != none and i < substitute-count {
      formatted.push(substitute-string)
    } else {
      formatted.push(format-single-name(
        name,
        attrs,
        ctx,
        position: i + 1,
        name-parts: name-parts,
      ))
    }
  }

  // Get delimiters
  let delimiter = attrs.at("delimiter", default: ctx.style.name-delimiter)
  let and-mode = attrs.at("and", default: ctx.style.and-term) // "text", "symbol", or none
  let delimiter-precedes-last = attrs.at(
    "delimiter-precedes-last",
    default: "contextual",
  )
  // CSL spec: delimiter-precedes-et-al controls delimiter before "et al."
  // Default is "contextual" (delimiter only if list has 2+ names)
  let delimiter-precedes-et-al = attrs.at(
    "delimiter-precedes-et-al",
    default: "contextual",
  )

  // Get the "and" term
  let and-term = if and-mode == "symbol" {
    lookup-term(ctx, "and", form: "symbol")
  } else if and-mode == "text" {
    lookup-term(ctx, "and", form: "long")
  } else {
    none
  }

  // Join names
  let result = if formatted.len() == 1 {
    formatted.first()
  } else if formatted.len() == 2 and not use-et-al and and-term != none {
    // Two names with "and"
    [#formatted.first() #and-term #formatted.last()]
  } else if and-term != none and not use-et-al {
    // Multiple names with "and" before last
    let all-but-last = formatted.slice(0, -1)
    let last = formatted.last()

    let use-delimiter-before-last = (
      (delimiter-precedes-last == "always")
        or (delimiter-precedes-last == "contextual" and formatted.len() > 2)
    )

    if use-delimiter-before-last {
      [#all-but-last.join(delimiter)#delimiter#and-term #last]
    } else {
      [#all-but-last.join(delimiter) #and-term #last]
    }
  } else {
    formatted.join(delimiter)
  }

  // Add et al if needed
  if use-et-al {
    // CSL spec: et-al-use-last shows ellipsis and last name instead of "et al."
    // Condition: original name list has at least 2 more names than truncated list
    let can-use-last = et-al-use-last and (names.len() - show-count >= 2)

    if can-use-last {
      // Format the last name
      let last-name = format-single-name(
        names.last(),
        attrs,
        ctx,
        position: names.len(),
        name-parts: name-parts,
      )
      // CSL spec: "followed by the name delimiter, the ellipsis character, and the last name"
      [#result#delimiter … #last-name]
    } else {
      let et-al = lookup-term(ctx, "et-al", form: "long")

      // CSL spec: delimiter-precedes-et-al determines when to add delimiter before "et al."
      // "contextual" (default): delimiter only if 2+ names shown
      // "always": always add delimiter
      // "never": never add delimiter (just space)
      // "after-inverted-name": delimiter only after inverted name
      let use-delimiter-before-et-al = (
        (delimiter-precedes-et-al == "always")
          or (
            delimiter-precedes-et-al == "contextual" and formatted.len() >= 2
          )
      )

      if use-delimiter-before-et-al {
        [#result#delimiter#et-al]
      } else {
        // Use explicit space (not content space which can be collapsed)
        [#result#" "#et-al]
      }
    }
  } else {
    result
  }
}

// =============================================================================
// CSL-M Institution Support
// =============================================================================

/// Format an institutional name (CSL-M extension)
///
/// Institutional names can have multiple subunits separated by "|"
///
/// - name: Name dict with "literal" or "family" field
/// - attrs: Institution formatting attributes
/// - ctx: Context
#let format-institution(name, attrs, ctx) = {
  // Get the institution name
  let full-name = if "literal" in name {
    name.literal
  } else {
    name.at("family", default: "")
  }

  if full-name == "" { return "" }

  // Parse subunits (separated by "|" in CSL-M)
  let subunits = full-name.split("|").map(s => s.trim())

  // Get institution formatting options
  let delimiter = attrs.at("delimiter", default: ", ")
  let use-first = attrs.at("use-first", default: none)
  let use-last = attrs.at("use-last", default: none)
  let substitute-use-first = attrs.at("substitute-use-first", default: none)
  let reverse-order = attrs.at("reverse-order", default: "false") == "true"
  let institution-parts = attrs.at("institution-parts", default: "long")

  // Reverse order if requested (for "big endian" display)
  if reverse-order {
    subunits = subunits.rev()
  }

  // Apply use-first and use-last truncation
  if use-first != none or use-last != none {
    let first-count = if use-first != none { int(use-first) } else { 0 }
    let last-count = if use-last != none { int(use-last) } else { 0 }

    if first-count + last-count < subunits.len() {
      let first-part = subunits.slice(0, first-count)
      let last-part = subunits.slice(subunits.len() - last-count)
      subunits = first-part + last-part
    }
  }

  // Handle short form (use abbreviation if available)
  if institution-parts == "short" {
    // In a full implementation, this would check for abbreviations
    // For now, just use the subunits as-is
  }

  subunits.join(delimiter)
}

/// Format names with institutional name support (CSL-M extension)
///
/// This function handles mixed personal and institutional names.
///
/// - names: Array of parsed name dicts
/// - attrs: Name formatting attributes
/// - institution-attrs: Institution formatting attributes (from cs:institution)
/// - ctx: Context
/// - name-parts: Dict of name-part formatting from <name-part> elements
/// - substitute-string: String to use for substituted names
/// - substitute-count: Number of names from start to substitute
#let format-names-with-institutions(
  names,
  attrs,
  institution-attrs,
  ctx,
  name-parts: (:),
  substitute-string: none,
  substitute-count: 0,
) = {
  if names.len() == 0 { return [] }

  // Separate personal and institutional names
  let personal-names = ()
  let inst-groups = () // Groups of (personal authors, institution)

  let current-personal = ()
  for name in names {
    if is-institutional-name(name) {
      // Start a new group with current personal names + this institution
      inst-groups.push((
        personal: current-personal,
        institution: name,
      ))
      current-personal = ()
    } else {
      current-personal.push(name)
    }
  }

  // Handle trailing personal names (unaffiliated)
  let unaffiliated = current-personal

  // If no institutions, just format as regular names
  if inst-groups.len() == 0 {
    return format-names(
      names,
      attrs,
      ctx,
      name-parts: name-parts,
      substitute-string: substitute-string,
      substitute-count: substitute-count,
    )
  }

  // Format each group
  let group-delimiter = institution-attrs.at("delimiter", default: ", ")
  let and-mode = institution-attrs.at("and", default: none)

  let formatted-groups = ()

  for group in inst-groups {
    let parts = ()

    // Format personal names in this group
    if group.personal.len() > 0 {
      parts.push(format-names(
        group.personal,
        attrs,
        ctx,
        name-parts: name-parts,
      ))
    }

    // Format institution
    let inst-formatted = format-institution(
      group.institution,
      institution-attrs,
      ctx,
    )
    if inst-formatted != "" {
      parts.push(inst-formatted)
    }

    if parts.len() > 0 {
      formatted-groups.push(parts.join(group-delimiter))
    }
  }

  // Add unaffiliated authors at the beginning with "with" term
  let result = if unaffiliated.len() > 0 and formatted-groups.len() > 0 {
    let with-term = lookup-term(ctx, "with", form: "long")
    if with-term == "" { with-term = "with" }
    let unaffiliated-formatted = format-names(
      unaffiliated,
      attrs,
      ctx,
      name-parts: name-parts,
    )
    [#unaffiliated-formatted #with-term #formatted-groups.join(group-delimiter)]
  } else if formatted-groups.len() > 0 {
    formatted-groups.join(group-delimiter)
  } else {
    format-names(names, attrs, ctx, name-parts: name-parts)
  }

  result
}
