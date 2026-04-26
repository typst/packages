#import "./themes.typ": *
#import "./utils.typ": *

#let __gloss_entries = state("__gloss_entries", (:))
#let __gloss_used = state("__gloss_used", (:))

#let __gloss_label_prefix = "__gloss:"

// Normalizes a dictionary entry by ensuring all required and optional keys exist
// with appropriate default values.
//
// Parameters:
//   entry (dictionary): Input dictionary containing at least 'short' and optionally
//                      'long', 'plural', 'longplural', 'description', and 'group'
//
// Returns:
//   dictionary: Normalized dictionary with all expected keys populated
//
// Throws:
//   - If 'short' key is missing
//   - If 'short' value is not a string
//   - If 'short' value is an empty string
//
#let __normalize_entry(entry) = {
  // Validate required fields
  if not "short" in entry {
    panic("Entry must contain a 'short' key")
  }
  if type(entry.short) != "string" {
    panic("Entry 'short' must be a string")
  }
  if entry.short.trim() == "" {
    panic("Entry 'short' cannot be empty")
  }

  // Extract values with defaults, using consistent none for missing optionals
  let long = entry.at("long", default: none)

  // Return the normalized entry
  (
    short: entry.short,
    plural: entry.at("plural", default: __pluralize(entry.short)),
    long: long,
    longplural: entry.at("longplural", default: __pluralize(long)),
    description: entry.at("description", default: none),
    group: entry.at("group", default: "")
  )
}

// Checks if a key exists in the glossary state.
//
// Parameters:
//   key (string): The key to look up in the glossary entries
//
// Returns:
//   boolean: True if the key exists in the glossary, false otherwise
//
#let __has_entry(key) = {
  key in __gloss_entries.final().keys()
}

// Updates the glossary state by adding or updating an entry.
//
// Parameters:
//   key (string): The key under which to store the entry
//   entry (dictionary): The normalized glossary entry to store
//
// Returns:
//   none: Updates state as a side effect
//
#let __add_entry(key, entry) = {
  __gloss_entries.update(state => {
    state.insert(key, entry)
    state
  })
}

// Retrieves a glossary entry from the state.
//
// Parameters:
//   key (string): The key of the entry to retrieve
//
// Returns:
//   dictionary: The glossary entry associated with the key
//
// Throws:
//   - If the key does not exist in the glossary
//
#let __get_entry(key) = {
  let entries = __gloss_entries.final()
  if key not in entries.keys() {
    panic("Glossary error: Missing key '" + key + "'")
  }

  entries.at(key)
}

// Creates a prefixed label string for dictionary entries and term usage.
//
// Parameters:
//   key (string): The glossary entry key
//
// Returns:
//   string: The prefixed label string for dictionary entries
//
#let __dict_label_str(key) = {
  __gloss_label_prefix + key
}

// Creates a label object for dictionary entries.
//
// Parameters:
//   key (string): The glossary entry key
//
// Returns:
//   label: A Typst label object for the dictionary entry
//
#let __dict_label(key) = {
  label(__dict_label_str(key))
}

// Creates a prefixed label string for term usage in documents.
//
// Parameters:
//   key (string): The glossary entry key
//   index (int): The occurrence index of the term in the document
//
// Returns:
//   string: The prefixed label string for term usage
//
#let __term_label_str(key, index) = {
  __gloss_label_prefix + key + "." + str(index)
}

// Creates a label object for term usage in documents.
//
// Parameters:
//   key (string): The glossary entry key
//   index (int): The occurrence index of the term in the document
//
// Returns:
//   label: A Typst label object for the term usage
//
#let __term_label(key, index) = {
  label(__term_label_str(key, index))
}

// Updates the term usage count in the glossary state.
//
// Parameters:
//   key (string): The glossary entry key
//   count (int): The number of times the term has been used
//
// Returns:
//   none: Updates state as a side effect
//
#let __save_term_usage(key, count) = {
  __gloss_used.update(state => {
    state.insert(key, count)
    state
  })
}

// Renders a glossary term with various formatting options.
//
// This function handles the display of terms in the document, managing both first
// and subsequent uses, pluralization, capitalization, and different display forms
// (short, long, or combined forms).
//
// Parameters:
//   key (string): The glossary entry key to render
//   modifiers (array): Array of modifier strings that control term rendering:
//     - "cap": Capitalize the first letter of the term
//     - "pl": Use plural form of the term
//     - "both": Show "Long form (short form)"
//     - "short": Show only the short form
//     - "long": Show only the long form
//     - "def" or "desc": Show the term's description instead
//
// Returns:
//   content: Formatted term with appropriate labels and metadata
//
// Behavior:
//   - Without modifiers, first use shows "Long form (short form)", subsequent uses show short form
//   - Explicit modifiers override the default first-use behavior
//   - If long form is requested but unavailable, falls back to short form
//   - Maintains usage counter for term references
//
#let __gls(key, modifiers: array) = {
  // Fetch the entry and prepare label
  let entry = __get_entry(key)
  let entry_label = __dict_label_str(key)

  // Handle description mode
  if "def" in modifiers or "desc" in modifiers {
    return [#entry.description]
  }

  // Track term usage
  let entry_counter = counter(entry_label)
  entry_counter.step()
  let key_index = entry_counter.get().first()
  let first = key_index == 0

  __save_term_usage(key, key_index + 1)

  // Helper: Apply pluralization if requested
  let pluralize_term = (singular, plural) => {
    if "pl" in modifiers and plural != none { plural } else { singular }
  }

  // Helper: Apply capitalization if requested
  let capitalize_term = (term) => {
    if "cap" in modifiers { upper(term.first()) + term.slice(1) } else { term }
  }

  // Helper: Apply both pluralization and capitalization
  let format_term = (term, plural) => {
    capitalize_term(pluralize_term(term, plural))
  }

  // Helper: Select and format the appropriate term form
  let select_term = (is_long_mode, use_both) => {
    let short_form = format_term(entry.short, entry.plural)
    let long_form = if entry.long != none {
      format_term(entry.long, entry.longplural)
    } else {
      none
    }

    if use_both and long_form != none {
      [#long_form (#short_form)]
    } else if is_long_mode and long_form != none {
      [#long_form]
    } else {
      [#short_form]
    }
  }

  // Determine display mode from modifiers
  let is_both = "both" in modifiers
  let is_long = "long" in modifiers and not is_both
  let is_short = "short" in modifiers and not is_both and not is_long

  context {
    // Generate final display based on modifiers or default behavior
    let display = if is_both or is_long or is_short {
      select_term(is_long, is_both)
    } else {
      select_term(false, first)
    }

    // Emit term with metadata and usage label
    [#display#metadata(display)#__term_label(key, key_index)]
  }
}

// Creates page number links back to each usage of a glossary term.
//
// This function generates a comma-separated list of page numbers, where each
// number links back to a usage of the term in the document. Duplicate page
// numbers are removed to avoid redundancy.
//
// Parameters:
//   key (string): The glossary entry key
//   count (int): Number of times the term appears in the document
//
// Returns:
//   content: Comma-separated list of linked page numbers
//
// Example output: "1, 3, 5" where each number links to the term usage on that page
//
#let __create_backlinks(key, count) = {
  // Generate labels for each term usage
  let labels = for i in range(count) {
    (__term_label(key, i),)
  }

  // Get page numbers for each usage
  let pages = labels
    .map(l => locate(l))
    .map(loc => numbering(
      __default(loc.page-numbering(), "1"),
      loc.page()
    ))

  // Create links, excluding duplicate page numbers
  let seen = ()
  let links = for i in range(labels.len()) {
    let label = labels.at(i)
    let page = pages.at(i)

    if seen.contains(page) {
      (none,)
    } else {
      seen.push(page)
      (link(label, page),)
    }
  }.filter(l => l != none)

  // Join links with commas
  links.join(", ")
}

// Initializes the glossary system and sets up term reference handling.
//
// This function is typically used with `#show: init-glossary`. It performs
// three main tasks:
// 1. Validates and loads glossary entries into the state
// 2. Sets up reference handling to intercept and format term usage
// 3. Applies custom term formatting if provided
//
// Parameters:
//   entries (dictionary): Dictionary of glossary entries where:
//     - keys are term identifiers
//     - values are entry dictionaries containing term details
//   show-term ((content) => content): Optional function to customize term rendering
//     Default: Returns term content unchanged
//   body (content): Document content to process
//
// Returns:
//   content: Processed document content with glossary functionality enabled
//
// Throws:
//   - If entries parameter is not a dictionary
//
#let init-glossary(
  entries,
  show-term: (term-body) => term-body,
  body
) = context {
  // Validate entries parameter type
  if type(entries) != dictionary {
    panic("entries must be a dictionary, instead got: " + repr(entries))
  }

  // Process and store each glossary entry
  for (key, entry) in entries {
    __add_entry(key, __normalize_entry(entry))
  }

  // Set up reference handling for glossary terms
  show ref: r => {
    let (key, ..modifiers) = str(r.target).split(":")
    if __has_entry(key) {
      show-term(__gls(key, modifiers: modifiers))
    } else {
      r
    }
  }

  body
}

// Renders a complete glossary with customizable formatting and grouping.
//
// The glossary displays all used terms, optionally grouped by category, with page
// references back to term usage. The appearance is controlled by a theme that
// defines how sections, groups, and entries are formatted.
//
// Parameters:
//   title (string): Glossary section title (default: "Glossary")
//   theme (dictionary): Controls glossary appearance with three functions:
//     - section(title, body): Renders the main glossary section
//       - title: The glossary title
//       - body: Content containing all groups and entries
//     - group(name, index, total, body): Renders a group of related terms
//       - name: Group name
//       - index: Zero-based group index
//       - total: Total number of groups
//       - body: Content containing the group's entries
//     - entry(entry, index, total): Renders a single glossary entry
//       - entry: Dictionary containing:
//         - short: Short form of term
//         - long: Long form of term (optional)
//         - description: Term description (optional)
//         - label: Term's dictionary label
//         - pages: Linked page numbers where term appears
//       - index: Zero-based entry index within group
//       - total: Total entries in group
//   groups (array): Optional list of groups to include
//                  If empty, includes all groups
//
// Returns:
//   content: Formatted glossary content
//
// Throws:
//   - If a requested group doesn't exist
//
#let glossary(
  title: "Glossary",
  theme: theme-twocol,
  ignore-case: false,
  groups: (),
) = context {
  // Collect and organize entries by group
  let output = (:)
  let all_entries = __gloss_entries.final()
  let all_used = __gloss_used.final()

  // Determine which groups to process
  let all_groups = all_entries
    .values()
    .map(e => e.at("group"))
    .dedup()
    .sorted()

  let target_groups = if groups.len() == 0 {
    all_groups
  } else {
    // Validate requested groups exist
    for g in groups {
      if g not in all_groups {
        panic("Requested group not found: " + g)
      }
    }
    groups
  }

  // Process entries group by group
  for group in target_groups {
    let current_entries = ()

    // Collect all used entries for this group
    for (key, count) in all_used {
      let entry = all_entries.at(key)
      if entry.at("group") == group {
        current_entries.push((
          short: entry.at("short"),
          long: entry.at("long"),
          description: entry.at("description"),
          label: [#metadata(key)#__dict_label(key)],
          pages: __create_backlinks(key, count)
        ))
      }
    }

  // Add non-empty groups to output
  if current_entries.len() > 0 {
    group = if group == none { "" } else { group }

    // sort entries by case insensitivity if requested
    let sorted_entries = current_entries
      // 1. create array of tuples with (lower [if ignore-case], entry)
      .map(e => { if ignore-case { (lower(e.short), e) } else { (e.short, e) } })
      // 2. sort the tuples (by first element then second)
      .sorted(key: t => t.first())
      // 3. strip away the tuple's first element, leaving an array of entries
      .map(t => t.last())

    // add entries to this group's output map
    output.insert(group, sorted_entries)
  }
}

  // Render the glossary using the theme
  let group_index = 0

  (theme.section)(
    title,
    for (group, entries) in output {
      (theme.group)(
        group,
        group_index,
        output.len(),
        for (i, entry) in entries.enumerate() {
          (theme.entry)(entry, i, entries.len())
        }
      )
      group_index += 1
    }
  )
}
