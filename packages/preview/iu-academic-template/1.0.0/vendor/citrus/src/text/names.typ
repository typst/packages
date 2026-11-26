// citrus - Name Formatting
//
// Formats author/editor names according to CSL rules
// Includes CSL-M extension: cs:institution for institutional authors

#import "../parsing/mod.typ": is-cjk-name, lookup-term
#import "../core/constants.typ": POSITION, RENDER-CONTEXT, STYLE-CLASS
#import "../core/utils.typ": capitalize-first-char
#import "../core/formatting.typ": finalize

// =============================================================================
// Inheritable Name Attribute Resolution
// =============================================================================
// CSL spec: Name attributes cascade: names element -> citation/bibliography -> style
// This helper resolves an attribute through this cascade.

/// Resolve an inheritable name attribute through the CSL cascade
/// - attr-name: Attribute name (e.g., "initialize-with")
/// - attrs: Attributes from the current names/name element
/// - ctx: Interpretation context with style and render-context
/// Returns: The resolved value (or none if not set at any level)
#let _resolve-name-attr(attr-name, attrs, ctx) = {
  // 1. Check element-level (names/name attrs)
  let value = attrs.at(attr-name, default: none)
  if value != none { return value }

  // 2. Check render-context level (citation or bibliography)
  let render-context = ctx.at("render-context", default: none)
  if render-context == RENDER-CONTEXT.citation {
    let citation = ctx.style.at("citation", default: (:))
    value = citation.at(attr-name, default: none)
    if value != none { return value }
  } else if render-context == RENDER-CONTEXT.bibliography {
    let bibliography = ctx.style.at("bibliography", default: (:))
    value = bibliography.at(attr-name, default: none)
    if value != none { return value }
  }

  // 3. Check style level
  ctx.style.at(attr-name, default: none)
}

// =============================================================================
// Module-level regex patterns (avoid recompilation)
// =============================================================================

// Pattern to split given names for initialization
// Matches: spaces, hyphens, or periods (for already-initialized names like "K.S.")
#let _name-split-pattern = regex("[ -]+")
// Pattern to detect already-initialized names (single letter followed by period)
#let _initialized-name-pattern = regex("^[A-Z]\\.[A-Z]")
#let _name-split-all-pattern = regex("[ .\\-]+")
#let _space-split-pattern = regex("[ ]+")
// Romanesque script detection (from citeproc-js STARTSWITH_ROMANESQUE_REGEXP)
// Used to determine if a space is needed before et-al term
// Matches: Latin, Greek, Cyrillic, Hebrew, Arabic, Thai, and related scripts
#let _romanesque-start-pattern = regex(
  "^[&a-zA-Z\u{0e01}-\u{0e5b}\u{00c0}-\u{017f}\u{0370}-\u{03ff}\u{0400}-\u{052f}\u{0590}-\u{05d4}\u{05d6}-\u{05ff}\u{1f00}-\u{1fff}\u{0600}-\u{06ff}\u{200c}\u{200d}\u{200e}\u{0218}\u{0219}\u{021a}\u{021b}\u{202a}-\u{202e}]",
)

/// Extract the initial from a name part
/// CSL spec: take all leading uppercase characters (for multi-char initials like Mongolian "Ts")
/// - part: Name part string (e.g., "TSerendorjiin")
/// Returns: Initial string (e.g., "Ts")
#let _extract-initial(part) = {
  if part.len() == 0 { return "" }
  let clusters = part.clusters()

  // Check if there are any lowercase letters in the string
  let has-lowercase = clusters.any(c => c != upper(c) and c == lower(c))

  if not has-lowercase {
    // All uppercase (like "ME") - just take first letter
    // These are already initials, not a name to abbreviate
    return upper(clusters.first())
  }

  // Find all leading uppercase characters
  let initial = ""
  for c in clusters {
    if c == upper(c) and c != lower(c) {
      // Uppercase letter
      initial = initial + c
    } else {
      break
    }
  }

  // If we got multiple uppercase followed by lowercase, normalize to title case (e.g., "TS" -> "Ts")
  let initial-clusters = initial.clusters()
  if initial-clusters.len() > 1 {
    upper(initial-clusters.first()) + lower(initial-clusters.slice(1).join())
  } else if initial-clusters.len() == 1 {
    initial
  } else {
    // No uppercase found, take first char uppercased
    upper(clusters.first())
  }
}

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

  // Check render-context to determine which element to inherit from
  let render-context = ctx.at("render-context", default: none)

  if render-context == RENDER-CONTEXT.citation {
    // For citation rendering: try citation-level setting
    let citation-val = ctx.at(citation-ctx-key, default: none)
    if citation-val != none { return citation-val }

    // Then citation element setting from style
    let citation = ctx.style.at("citation", default: (:))
    if type(citation) == dictionary {
      let cit-val = citation.at(bib-key, default: none)
      if cit-val != none { return cit-val }
    }
  } else if render-context == RENDER-CONTEXT.bibliography {
    // For bibliography rendering: try bibliography-level setting
    let bib = ctx.style.at("bibliography", default: none)
    if bib != none and type(bib) == dictionary {
      let bib-val = bib.at(bib-key, default: none)
      if bib-val != none { return bib-val }
    }
  } else {
    // No render-context specified - try citation context key first (for compatibility)
    let citation-val = ctx.at(citation-ctx-key, default: none)
    if citation-val != none { return citation-val }
  }

  // Fall back to style-level setting
  let style-val = ctx.style.at(bib-key, default: none)
  if style-val != none { return style-val }

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
    none,
    ctx,
  )

  et-al-use-first = _resolve-et-al-setting(
    et-al-use-first,
    sort-names-use-first,
    is-subsequent,
    "et-al-subsequent-use-first",
    "citation-et-al-use-first",
    "et-al-use-first",
    none,
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

// Whitespace characters for term spacing detection
#let _whitespace-chars = (" ", "\u{2009}", "\u{2008}", "\u{200A}", "\u{00A0}")

/// Check if string starts with any whitespace character
#let _has-leading-space(s) = {
  s != "" and _whitespace-chars.any(c => s.starts-with(c))
}

/// Check if string ends with any whitespace character
#let _has-trailing-space(s) = {
  s != "" and _whitespace-chars.any(c => s.ends-with(c))
}

/// Join two items with an "and" term, respecting term's own whitespace
/// Hebrew example: term="ו\u{2008}" → attaches directly to first, has trailing space
#let _join-with-and(first, second, and-term, use-delimiter, delimiter) = {
  let term-str = if type(and-term) == str { and-term } else { "" }
  let leading = _has-leading-space(term-str)
  let trailing = _has-trailing-space(term-str)

  if use-delimiter {
    // delimiter before and-term
    if trailing {
      [#first#delimiter#and-term#second]
    } else {
      [#first#delimiter#and-term #second]
    }
  } else {
    // No delimiter - respect term's whitespace
    if trailing and not leading {
      [#first#and-term#second]
    } else if leading and trailing {
      [#first#and-term#second]
    } else if leading {
      [#first#and-term #second]
    } else {
      [#first #and-term #second]
    }
  }
}

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

/// Determine if a single name ends with a period (forward-only)
#let name-ends-with-period(name, name-attrs, name-parts, ctx) = {
  let literal = name.at("literal", default: "")
  if literal != "" {
    let family-part = name-parts.at("family", default: (:))
    let part-suffix = family-part.at("suffix", default: "")
    return literal.trim().ends-with(".") or part-suffix.ends-with(".")
  }

  if name.at("isInstitution", default: false) {
    let family = name.at("family", default: "")
    if family.trim().ends-with(".") { return true }
  }

  let suffix = name.at("suffix", default: "")
  if suffix.ends-with(".") { return true }

  let family = name.at("family", default: "")
  if family.trim().ends-with(".") { return true }

  let given = name.at("given", default: "")
  if given != "" {
    let initialize-with = _resolve-name-attr("initialize-with", name-attrs, ctx)
    if initialize-with != none and initialize-with.contains(".") { return true }
  }

  false
}

/// Determine if a names list ends with a period (forward-only)
#let names-end-flag(names, name-attrs, name-parts, ctx, et-al-term, et-al) = {
  if names.len() == 0 { return false }
  let et-al-min = et-al.et-al-min
  let et-al-use-first = et-al.et-al-use-first
  let use-et-al = if et-al-min != none and et-al-use-first != none {
    names.len() >= et-al-min and et-al-use-first < names.len()
  } else { false }

  if use-et-al { return et-al-term.trim().ends-with(".") }
  name-ends-with-period(names.last(), name-attrs, name-parts, ctx)
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

/// Initialize a given name according to CSL rules
///
/// - given: The given name string
/// - initialize-with: String to place after each initial (e.g., ". ")
/// - initialize: Whether to convert full names to initials (default true)
/// - initialize-hyphen: Whether to preserve hyphens in initialized names
/// Returns: Initialized given name string
#let _initialize-given-name(
  given,
  initialize-with,
  initialize,
  initialize-hyphen,
) = {
  if given == "" or initialize-with == none { return given }

  // When initialize="false", we reformat names that are "already initialized"
  // "Already initialized" means: contains periods OR contains space-separated single letters
  // Names like "ME" (adjacent uppercase) are NOT considered initialized
  if not initialize {
    // Split by space, hyphen, AND period to identify individual parts
    let parts = given
      .split(_name-split-all-pattern)
      .filter(p => p != "" and p.trim() != "")

    // Check if this looks like an already-initialized name:
    // - Has periods, OR
    // - Has multiple parts where at least one is a single letter
    let has-periods = given.contains(".")
    let has-single-letter-parts = parts.any(p => p.len() == 1)
    let is-already-initialized = (
      has-periods or (parts.len() > 1 and has-single-letter-parts)
    )

    if not is-already-initialized {
      return given
    }

    // Reformat: keep full names as-is, reformat initials using initialize-with
    let result = ()
    for p in parts {
      // Check if this part looks like an initial (1-2 chars, starts with uppercase)
      let is-initial = (
        p.len() >= 1
          and p.len() <= 2
          and p.clusters().first() == upper(p.clusters().first())
      )

      if is-initial {
        // Initial (1-2 chars) - reformat with initialize-with
        result.push(p + initialize-with)
      } else {
        // Full name part - keep as-is with trailing space
        result.push(p + " ")
      }
    }
    return result.join("").trim(at: end)
  }

  // For hyphenated names, we need to preserve the structure:
  // "H.-X. L. Y." should become "H.-X. L. Y." (hyphen only between H and X)
  // Split by space first to get groups, then handle hyphens within groups
  if initialize-hyphen and given.contains("-") {
    // Split by space (but not hyphen) to preserve hyphenated groups
    let space-parts = given.split(_space-split-pattern).filter(p => p != "")
    let result-parts = ()

    for space-part in space-parts {
      if space-part.contains("-") {
        // This is a hyphenated group like "H.-X." or "Jean-Pierre" or "Guo-ping"
        let hyphen-parts = space-part.split("-").filter(p => p != "")
        let group-initials = ()
        for hp in hyphen-parts {
          // Remove trailing period if present
          let clean = hp.trim(".", at: end).trim()
          if clean.len() == 0 { continue }
          let is-lowercase = clean == lower(clean)
          if is-lowercase {
            // Lowercase part (like "ping" in "Guo-ping")
            // When initialize-with is empty, drop these parts
            // When initialize-with is non-empty, keep them with hyphen
            if initialize-with.trim() != "" {
              group-initials.push(clean)
            }
            // else: drop the lowercase part
          } else {
            group-initials.push(
              upper(clean.clusters().first()) + initialize-with.trim(at: end),
            )
          }
        }
        // Join hyphenated parts with hyphen
        if group-initials.len() > 0 {
          result-parts.push(group-initials.join("-"))
        }
      } else {
        // Regular part (not hyphenated)
        let clean = space-part.trim(".", at: end).trim()
        if clean.len() == 0 { continue }
        let is-particle = clean == lower(clean)
        if is-particle {
          result-parts.push(clean)
        } else {
          result-parts.push(
            upper(clean.clusters().first()) + initialize-with.trim(at: end),
          )
        }
      }
    }

    // Join groups with space + initialize-with spacing
    let result = result-parts.join(" ")
    return result
  }

  // For initialize=true path, check if name is already initialized
  // (contains periods and mostly single-letter parts)
  let is-already-initialized = (
    given.contains(".")
      and given
        .split(".")
        .filter(p => p.trim() != "")
        .all(p => p.trim().len() <= 2)
  )

  // Normal initialization: convert all parts to initials
  // First split by space/hyphen, then handle parts that contain periods
  let raw-parts = if is-already-initialized {
    given.split(".").map(p => p.trim()).filter(p => p != "")
  } else {
    given.split(_name-split-pattern).filter(p => p != "")
  }

  // Expand parts that contain periods (e.g., "M.E." → ["M", "E"])
  let parts = ()
  for raw-p in raw-parts {
    if raw-p.contains(".") {
      // Split by period and add each non-empty part
      for sub in raw-p.split(".").map(p => p.trim()).filter(p => p != "") {
        parts.push(sub)
      }
    } else {
      parts.push(raw-p)
    }
  }

  // Build initials - lowercase particles kept as-is
  let initials = ()
  for (i, p) in parts.enumerate() {
    if p.len() == 0 { continue }

    let is-particle = p == lower(p)
    let next-is-particle = if i + 1 < parts.len() {
      parts.at(i + 1) == lower(parts.at(i + 1))
    } else { false }

    if is-particle {
      initials.push(p + " ")
    } else {
      let init = _extract-initial(p) + initialize-with
      if next-is-particle and not initialize-with.ends-with(" ") {
        init = init + " "
      }
      initials.push(init)
    }
  }

  initials.join("").trim(at: end)
}

/// Format a single name
///
/// - name: Parsed name dict (family, given, prefix, suffix, literal)
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
  let name-position = position
  // Handle literal names (institutional names)
  // CSL-JSON can have names with only "literal" field
  let literal = name.at("literal", default: "")
  if literal != "" {
    // Apply family name-part formatting to literal if specified
    let family-part-attrs = name-parts.at("family", default: (:))
    return format-name-part(literal, family-part-attrs)
  }

  let family = name.at("family", default: "")
  let given = name.at("given", default: "")

  // Handle given-only names (e.g., "Banksy") - just return the given name as-is
  // Single-name authors should not be initialized
  if family == "" and given != "" {
    let given-part-attrs = name-parts.at("given", default: (:))
    return format-name-part(given, given-part-attrs)
  }

  // CSL has two types of particles:
  // - prefix (non-dropping-particle): always attached to family name (e.g., "la" in "la Martinière")
  // - dropping-prefix (dropping-particle): placed between given and family in display order (e.g., "de")
  let prefix = name.at("prefix", default: "") // non-dropping-particle
  let dropping-prefix = name.at("dropping-prefix", default: "") // dropping-particle
  let suffix = name.at("suffix", default: "") // "Jr.", "III", etc.
  let comma-suffix = name.at("comma-suffix", default: false) // true = add comma before suffix in display order

  let is-chinese = is-cjk-name(name)

  // Get formatting options from attrs with proper cascade (names -> citation/bib -> style)
  let name-as-sort-order = _resolve-name-attr("name-as-sort-order", attrs, ctx)
  if type(name-as-sort-order) == str {
    name-as-sort-order = name-as-sort-order.trim()
  }
  let initialize-with = _resolve-name-attr("initialize-with", attrs, ctx)
  let sort-separator = _resolve-name-attr("sort-separator", attrs, ctx)
  // CSL spec default for sort-separator is ", " - apply if still none
  if sort-separator == none { sort-separator = ", " }
  // Check element-level "form" first, then cascade through "name-form"
  let name-form = attrs.at("form", default: none)
  if name-form == none {
    name-form = _resolve-name-attr("name-form", attrs, ctx)
  }
  // CSL spec default is "long"
  if name-form == none { name-form = "long" }

  // Apply name-part formatting
  let family-part-attrs = name-parts.at("family", default: (:))
  let given-part-attrs = name-parts.at("given", default: (:))

  let formatted-family = format-name-part(family, family-part-attrs)
  // CSL spec: non-dropping-particle is part of family name and should follow its formatting
  let formatted-prefix = if prefix != "" {
    format-name-part(prefix, family-part-attrs)
  } else { "" }
  let formatted-given = given

  // Get disambiguation givenname-level from context (CSL Method 1)
  // Level 0 = default, 1 = initials, 2 = full given name
  let givenname-level = ctx.at("givenname-level", default: 0)
  let givenname-levels = ctx.at("givenname-levels", default: none)
  if (
    givenname-levels != none
      and type(givenname-levels) == array
      and givenname-levels.len() >= name-position
  ) {
    givenname-level = givenname-levels.at(name-position - 1)
  }
  // In note styles, subsequent cites use short form without disambiguation.
  // In author-date styles, all cites must render identically.
  let cite-position = ctx.at("position", default: POSITION.first)
  let is-note-style = ctx.at("style-class", default: "") == STYLE-CLASS.note
  if (
    is-note-style
      and name-form == "short"
      and (
        cite-position == POSITION.subsequent
          or cite-position == POSITION.ibid
          or cite-position == POSITION.ibid-with-locator
      )
  ) {
    givenname-level = 0
  }

  // Short form: only family name with non-dropping-particle (unless disambiguation requires more)
  // CSL spec: non-dropping-particle is always attached to family name, even in short form
  if name-form == "short" and givenname-level == 0 {
    if formatted-prefix != "" {
      // Use original prefix for character checks (formatting may wrap in content)
      if prefix.ends-with("'") or prefix.ends-with("-") {
        return formatted-prefix + formatted-family
      } else {
        return formatted-prefix + " " + formatted-family
      }
    }
    return formatted-family
  }

  // If disambiguation requires showing given name but form is "short",
  // show the given name with family name in standard order (Given Family)
  if name-form == "short" and givenname-level > 0 {
    if givenname-level == 2 {
      // Level 2: full given name
      formatted-given = format-name-part(given, given-part-attrs)
    } else if given != "" and not is-chinese {
      // Level 1: initials
      let init-sep = if initialize-with != none { initialize-with } else {
        ". "
      }
      formatted-given = _initialize-given-name(given, init-sep, true, false)
      formatted-given = format-name-part(formatted-given, given-part-attrs)
    }
    // CSL spec: disambiguated short names show as "G. Family" not "Family, G."
    if formatted-given != "" {
      return [#formatted-given #formatted-family]
    }
    return formatted-family
  }

  // Initialize given name if required (and not overridden by disambiguation)
  if (
    initialize-with != none
      and given != ""
      and not is-chinese
      and givenname-level != 2
  ) {
    let initialize = attrs.at("initialize", default: ctx.style.at(
      "initialize",
      default: true,
    ))
    if type(initialize) == str { initialize = initialize == "true" }
    formatted-given = _initialize-given-name(
      given,
      initialize-with,
      initialize,
      ctx.style.initialize-with-hyphen,
    )
  }

  // Apply given name part formatting
  formatted-given = format-name-part(formatted-given, given-part-attrs)

  // Determine name order
  let use-sort-order = (
    name-as-sort-order == "all"
      or (name-as-sort-order == "first" and name-position == 1)
  )

  // Build name string
  if is-chinese {
    // Chinese: 姓名 (no separator)
    formatted-family + formatted-given
  } else if use-sort-order {
    // Sort order: Family, Given [particles], Suffix
    // demote-non-dropping-particle controls where non-dropping-particle goes:
    // - "never": prefix stays with family name (la Martinière)
    // - "display-and-sort" or "sort-only": prefix moves after given name

    let demote = ctx.style.demote-non-dropping-particle
    let demote-prefix = demote == "display-and-sort"
    if formatted-prefix != "" and not demote-prefix {
      // Prefix stays with family name
      formatted-family = formatted-prefix + " " + formatted-family
    }

    // Build name parts: Family, Given [dropping-prefix] [demoted-prefix], Suffix
    let result = formatted-family
    if formatted-given != "" {
      result = [#result#sort-separator#formatted-given]
    }
    // Add particles after given name if demoted or if dropping-prefix exists
    let particles = ()
    if dropping-prefix != "" { particles.push(dropping-prefix) }
    if formatted-prefix != "" and demote-prefix {
      particles.push(formatted-prefix)
    }
    if particles.len() > 0 {
      result = [#result #particles.join(" ")]
    }
    // CSL spec: suffix is preceded by sort-separator in sort order
    if suffix != "" {
      result = [#result#sort-separator#suffix]
    }
    result
  } else {
    // Display order: Given [dropping-prefix] [non-dropping-prefix] Family Suffix
    // dropping-prefix (e.g., "de") goes between given and family
    // non-dropping-prefix (e.g., "la") stays attached to family
    let result = ()
    if formatted-given != "" { result.push(formatted-given) }

    // Handle dropping-prefix (e.g., "d'" or "de")
    // If it ends with apostrophe or hyphen, it should attach directly to next part
    let attach-dropping-prefix = (
      dropping-prefix != ""
        and (dropping-prefix.ends-with("'") or dropping-prefix.ends-with("-"))
    )

    if dropping-prefix != "" and not attach-dropping-prefix {
      // Normal dropping-prefix with space
      result.push(dropping-prefix)
    }

    // Handle non-dropping-particle + family
    if formatted-prefix != "" {
      // Check if prefix ends with a connecting character (apostrophe or hyphen)
      // Use original prefix for character check, formatted-prefix for output
      if prefix.ends-with("'") or prefix.ends-with("-") {
        // No space between prefix and family
        if attach-dropping-prefix {
          result.push([#dropping-prefix#formatted-prefix#formatted-family])
        } else {
          result.push([#formatted-prefix#formatted-family])
        }
      } else {
        if attach-dropping-prefix {
          result.push([#dropping-prefix#formatted-prefix])
        } else {
          result.push(formatted-prefix)
        }
        result.push(formatted-family)
      }
    } else {
      // No non-dropping-particle, just family
      if attach-dropping-prefix {
        result.push([#dropping-prefix#formatted-family])
      } else {
        result.push(formatted-family)
      }
    }
    // In display order, comma-suffix=true adds comma before suffix
    if suffix != "" {
      if comma-suffix {
        // Join what we have, then add ", Suffix"
        return result.join(" ") + ", " + suffix
      }
      result.push(suffix)
    }
    result.join(" ")
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
/// - et-al-attrs: Formatting attributes for the et-al element (font-style, etc.)
#let format-names(
  names,
  attrs,
  ctx,
  name-parts: (:),
  substitute-string: none,
  substitute-count: 0,
  et-al-term: "et-al",
  et-al-attrs: (:),
) = {
  if names.len() == 0 { return [] }
  if substitute-string != none and substitute-count == -1 {
    return substitute-string
  }

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

  let personal-count = names.len()

  // Determine how many names to show
  // CSL spec: et-al is only used when the name list is TRUNCATED
  // If et-al-use-first >= names.len(), we show all names and don't use et-al
  // Use personal-count for et-al threshold, but show-count from total names
  let use-et-al = (
    et-al-min != none
      and et-al-use-first != none
      and personal-count >= et-al-min
      and et-al-use-first < personal-count
  )
  let show-count = if use-et-al { et-al-use-first } else { names.len() }

  // CSL spec: when et-al-use-first="0", no names are shown at all
  // This should trigger group suppression (names element renders empty)
  // "et al." alone doesn't count as output from a variable
  if show-count == 0 and use-et-al {
    return []
  }

  // CSL spec: form="count" returns the count of names that would be rendered
  // This is calculated AFTER et-al truncation
  let name-form = attrs.at("form", default: "long")
  if name-form == "count" {
    return str(show-count)
  }

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

  // Get delimiters with inheritance: name attrs -> citation/bib level -> style level
  let delimiter = attrs.at("delimiter", default: none)
  if delimiter == none {
    delimiter = ctx.at("citation-name-delimiter", default: none)
  }
  if delimiter == none { delimiter = ctx.style.name-delimiter }

  // Resolve "and" with fallback to citation level, then style level
  let and-mode = attrs.at("and", default: none)
  if and-mode == none { and-mode = ctx.at("citation-and", default: none) }
  if and-mode == none { and-mode = ctx.style.at("and", default: none) }

  // Resolve delimiter-precedes-last with fallback
  let delimiter-precedes-last = attrs.at(
    "delimiter-precedes-last",
    default: none,
  )
  if delimiter-precedes-last == none {
    delimiter-precedes-last = ctx.at(
      "citation-delimiter-precedes-last",
      default: none,
    )
  }
  if delimiter-precedes-last == none {
    delimiter-precedes-last = ctx.style.at(
      "delimiter-precedes-last",
      default: none,
    )
  }
  if delimiter-precedes-last == none { delimiter-precedes-last = "contextual" }

  // CSL spec: delimiter-precedes-et-al controls delimiter before "et al."
  // Default is "contextual" (delimiter only if list has 2+ names)
  // Inheritance: name attrs -> citation/bib level -> style level -> default
  let delimiter-precedes-et-al = attrs.at(
    "delimiter-precedes-et-al",
    default: none,
  )
  if delimiter-precedes-et-al == none {
    delimiter-precedes-et-al = ctx.at(
      "citation-delimiter-precedes-et-al",
      default: none,
    )
  }
  if delimiter-precedes-et-al == none {
    delimiter-precedes-et-al = ctx.style.at(
      "delimiter-precedes-et-al",
      default: none,
    )
  }
  if delimiter-precedes-et-al == none {
    delimiter-precedes-et-al = "contextual"
  }

  // Get the "and" term
  let and-term = if and-mode == "symbol" {
    let term = lookup-term(ctx, "and", form: "symbol")
    if term != none { term } else { "&" }
  } else if and-mode == "text" {
    let term = lookup-term(ctx, "and", form: "long")
    if term != none { term } else { "and" }
  } else {
    none
  }

  // Join names with appropriate delimiters and "and" term
  let result = if formatted.len() == 1 {
    formatted.first()
  } else if formatted.len() == 2 and not use-et-al and and-term != none {
    // Two names with "and"
    let name-as-sort-order = attrs.at(
      "name-as-sort-order",
      default: ctx.style.name-as-sort-order,
    )
    if type(name-as-sort-order) == str {
      name-as-sort-order = name-as-sort-order.trim()
    }
    // Check if the first name (before last) is inverted
    // Literal/institutional names are never inverted
    let first-name = names.at(0, default: (:))
    let first-is-literal = first-name.at("literal", default: "") != ""
    let first-is-inverted = if first-is-literal {
      false
    } else {
      name-as-sort-order == "all" or name-as-sort-order == "first"
    }

    let use-delim = if delimiter-precedes-last == "always" {
      true
    } else if delimiter-precedes-last == "after-inverted-name" {
      first-is-inverted
    } else {
      // "contextual" or "never" - no delimiter for 2 names
      false
    }
    _join-with-and(
      formatted.first(),
      formatted.last(),
      and-term,
      use-delim,
      delimiter,
    )
  } else if and-term != none and not use-et-al {
    // Multiple names with "and" before last
    let all-but-last = formatted.slice(0, -1)
    let last = formatted.last()

    // Determine if delimiter should precede the last name/and
    let name-as-sort-order = attrs.at(
      "name-as-sort-order",
      default: ctx.style.name-as-sort-order,
    )
    if type(name-as-sort-order) == str {
      name-as-sort-order = name-as-sort-order.trim()
    }

    // Check if the name before last is inverted (for after-inverted-name)
    let before-last-idx = formatted.len() - 2
    let before-last-name = names.at(before-last-idx, default: (:))
    let before-last-is-literal = (
      before-last-name.at("literal", default: "") != ""
    )
    let before-last-is-inverted = if before-last-is-literal {
      false
    } else {
      // Position is 1-based, so before-last is at position (formatted.len() - 1)
      let pos = before-last-idx + 1
      (
        name-as-sort-order == "all"
          or (name-as-sort-order == "first" and pos == 1)
      )
    }

    let use-delim = if delimiter-precedes-last == "always" {
      true
    } else if delimiter-precedes-last == "after-inverted-name" {
      before-last-is-inverted
    } else if delimiter-precedes-last == "contextual" {
      formatted.len() > 2
    } else {
      // "never" or unknown
      false
    }
    _join-with-and(
      all-but-last.join(delimiter),
      last,
      and-term,
      use-delim,
      delimiter,
    )
  } else {
    formatted.join(delimiter)
  }

  // Add et al if needed
  if use-et-al {
    // CSL spec: et-al-use-last shows ellipsis and last name instead of "et al."
    // Condition: original name list has at least 2 more names than truncated list
    let can-use-last = (
      et-al-use-last == true and (names.len() - show-count >= 2)
    )

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
      let et-al-text-raw = lookup-term(ctx, et-al-term, form: "long")
      let et-al-text = if et-al-text-raw != none { et-al-text-raw } else {
        "et al."
      }

      // If et-al term is empty (e.g., "and others" defined as empty), skip et-al entirely
      if et-al-text == "" {
        result
      } else {
        // Apply formatting from <et-al> element (e.g., font-style="italic")
        let et-al = if et-al-attrs.len() > 0 {
          finalize(et-al-text, et-al-attrs)
        } else {
          et-al-text
        }

        // CSL spec: delimiter-precedes-et-al determines when to add delimiter before "et al."
        // "contextual" (default): delimiter only if 2+ names shown
        // "always": always add delimiter
        // "never": never add delimiter (just space)
        // "after-inverted-name": delimiter only after inverted name
        let use-delimiter-before-et-al = if (
          delimiter-precedes-et-al == "always"
        ) {
          true
        } else if delimiter-precedes-et-al == "contextual" {
          formatted.len() >= 2
        } else if delimiter-precedes-et-al == "after-inverted-name" {
          // Check if the last shown name is inverted
          let name-as-sort-order = _resolve-name-attr(
            "name-as-sort-order",
            attrs,
            ctx,
          )
          let last-shown-idx = show-count - 1
          let last-shown-name = names.at(last-shown-idx, default: (:))
          let is-literal = last-shown-name.at("literal", default: "") != ""
          if is-literal {
            false
          } else {
            let pos = last-shown-idx + 1
            (
              name-as-sort-order == "all"
                or (
                  name-as-sort-order == "first" and pos == 1
                )
            )
          }
        } else {
          // "never" or unknown
          false
        }

        if use-delimiter-before-et-al {
          [#result#delimiter#et-al]
        } else {
          // When no delimiter, determine if a space is needed before et-al.
          // Romanesque scripts need a space; CJK and other scripts do not.
          let et-al-str = if type(et-al-text) == str { et-al-text } else { "" }
          let needs-space = (
            et-al-str.len() > 0
              and et-al-str.first().match(_romanesque-start-pattern) != none
          )

          if needs-space {
            [#result#" "#et-al]
          } else {
            [#result#et-al]
          }
        }
      }
    }
  } else {
    result
  }
}

/// Apply name-level formatting (font-weight, font-style, etc.) to formatted names
///
/// CSL spec: The <name> element can have formatting attributes like font-weight="bold"
/// which should apply to all rendered names.
///
/// - content: The formatted names content
/// - attrs: Attributes from the <name> element
/// Returns: Formatted content with name-level formatting applied
#let apply-name-formatting(content, attrs) = {
  if content == [] or content == "" { return content }

  let result = content

  // Apply font formatting
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
/// - et-al-attrs: Formatting attributes for the et-al element
#let format-names-with-institutions(
  names,
  attrs,
  institution-attrs,
  ctx,
  name-parts: (:),
  substitute-string: none,
  substitute-count: 0,
  et-al-term: "et-al",
  et-al-attrs: (:),
) = {
  if substitute-string != none and substitute-count == -1 {
    return substitute-string
  }
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
      et-al-term: et-al-term,
      et-al-attrs: et-al-attrs,
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
        et-al-term: et-al-term,
        et-al-attrs: et-al-attrs,
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
    let with-term-raw = lookup-term(ctx, "with", form: "long")
    let with-term = if with-term-raw != none and with-term-raw != "" {
      with-term-raw
    } else { "with" }
    let unaffiliated-formatted = format-names(
      unaffiliated,
      attrs,
      ctx,
      name-parts: name-parts,
      et-al-term: et-al-term,
      et-al-attrs: et-al-attrs,
    )
    [#unaffiliated-formatted #with-term #formatted-groups.join(group-delimiter)]
  } else if formatted-groups.len() > 0 {
    formatted-groups.join(group-delimiter)
  } else {
    format-names(
      names,
      attrs,
      ctx,
      name-parts: name-parts,
      et-al-term: et-al-term,
      et-al-attrs: et-al-attrs,
    )
  }

  result
}
