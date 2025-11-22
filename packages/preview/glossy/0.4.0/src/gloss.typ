#import "@preview/valkyrie:0.2.1" as z

#import "./schemas.typ": *
#import "./themes.typ": *
#import "./utils.typ": *

#let __gloss_entries = state("__gloss_entries", (:))
#let __gloss_used = state("__gloss_used", (:))

#let __gloss_label_prefix = "__gloss:"

// Normalizes a dictionary entry by ensuring all required and optional keys exist
// with appropriate default values.
//
// Parameters:
//   key: The key from the input dictionary
//   entry (dictionary): Input dictionary containing at least 'short' and optionally
//                      'long', 'plural', 'longplural', 'description', and 'group'
//
//   entry (string): If you pass a string to entry, we assume you're using the
//                   abbreviated syntax `short: "long"`, where the `key` is used
//                   for `short` and `entry` is used for `long`.
//
// Returns:
//   dictionary: Normalized dictionary with all expected keys populated
//
// Throws:
//   - If 'short' key is missing when using normal (non-abbreviated) syntax
//   - If 'short' value is not a string
//   - If 'short' value is an empty string
//
#let __normalize_entry(key, entry) = {
  // If it's a string, it's using the abbreviated syntax `short: "long"`.
  if (type(entry) == str) {
    entry = (short: key, long: entry)
  }

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
    article: entry.at("article", default: __determine_article(entry.short)),
    long: long,
    longplural: entry.at("longplural", default: __pluralize(long)),
    longarticle: entry.at("longarticle", default: __determine_article(long)),
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
// Parameters:
//   key (string): The glossary entry key to render.
//   modifiers (array): Array of modifier strings that control term rendering:
//     - "cap": Capitalize the first letter of the term.
//     - "pl": Use plural form of the term.
//     - "both": Show "Long form (short form)".
//     - "short": Show only the short form.
//     - "long": Show only the long form.
//     - "def" or "desc": Show the term's description instead of its name.
//     - "a" or "an": Prepend an article, chosen from the entry (short or long form).
//   show-term (function): A function that renders the chosen term.
//
// Behavior:
//   - Without modifiers, the first use of a term shows "Long form (short form)",
//     subsequent uses show only the short form.
//   - Explicit modifiers ("long", "short", "both") override the default behavior.
//   - If a requested long form doesn't exist, the logic falls back to the short form.
//   - A usage counter tracks how many times a term has been referenced.
//
// Returns:
//   content: The fully formatted term, including optional article, capitalization,
//            usage tracking metadata, and the chosen form (short, long, or both).
//
#let __gls(key, modifiers: array, show-term: function) = {
  // ---------------------------------------------------------------------------
  // Check for illegal modifier combinations
  // ---------------------------------------------------------------------------
  if ("def" in modifiers or "desc" in modifiers) and modifiers.len() > 1 {
    panic("Cannot use 'def'/'desc' with other modifiers.")
  }
  if ("a" in modifiers or "an" in modifiers) and ("pl" in modifiers) {
    panic("Cannot use 'a'/'an' and 'pl' together.")
  }

  // ---------------------------------------------------------------------------
  // Retrieve the glossary entry and its label
  // ---------------------------------------------------------------------------
  let entry = __get_entry(key)
  let entry_label = __dict_label_str(key)

  // ---------------------------------------------------------------------------
  // If "def" or "desc" modifier is present, show the entry's description immediately
  // ---------------------------------------------------------------------------
  if "def" in modifiers or "desc" in modifiers {
    if entry.description == none {
      panic("Use of 'def'/'desc' requires a description be defined.")
    }
    return show-term([#entry.description])
  }

  // ---------------------------------------------------------------------------
  // Manage term usage counting and determine if it's the first reference
  // ---------------------------------------------------------------------------
  let entry_counter = counter(entry_label)
  entry_counter.step()
  let key_index = entry_counter.get().first()
  let is_first_use = key_index == 0

  // ---------------------------------------------------------------------------
  // Record another usage of this term (increment the usage counter)
  // ---------------------------------------------------------------------------
  __save_term_usage(key, key_index + 1)

  // ---------------------------------------------------------------------------
  // Helper Functions
  // ---------------------------------------------------------------------------

  // pluralize_term(singular, plural): Returns plural form if "pl" modifier is present and available;
  // otherwise returns the singular form.
  let pluralize_term = (singular, plural) => {
    if "pl" in modifiers and plural != none {
      plural
    } else {
      singular
    }
  }

  // capitalize_term(article, term): If "cap" is in modifiers, capitalizes the first letter
  // of whichever text appears first (the article if present, otherwise the term).
  // Returns a tuple (article, term) which may be modified to have uppercase first letters.
  let capitalize_term = (article, term) => {
    if "cap" not in modifiers {
      (article, term)
    } else if article == "" {
      // No article present, so capitalize the term's first letter.
      (article, upper(term.first()) + term.slice(1))
    } else {
      // Article is present; capitalize its first letter instead.
      (upper(article.first()) + article.slice(1), term)
    }
  }

  // get_term(mode): Returns the appropriate term string based on the mode.
  // mode is one of "short", "long", or "both".
  //   - "short": Returns the short form.
  //   - "long": Returns the long form.
  //   - "both": Returns "Long form (short form)".
  // We rely on prior logic to ensure that when mode = "both" or "long", a long form is available.
  let get_term = (mode) => {
    let short_form = pluralize_term(entry.short, entry.plural)
    let long_form = pluralize_term(entry.long, entry.longplural) // none safe here
    if mode == "short" {
      // Just the short form.
      short_form
    } else if mode == "long" {
      // Just the long form.
      long_form
    } else {
      // mode == "both": "Long form (short form)".
      long_form + " (" + short_form + ")"
    }
  }

  // get_article(mode): Returns the appropriate article string based on the mode.
  //   - If wants_article is false, returns an empty string.
  //   - If mode is "short", return the short article.
  //   - If mode is "long" or "both", return the long article.
  // The calling logic ensures that when mode = "long" or "both", a long form exists.
  let get_article = (mode) => {
    let wants_article = "a" in modifiers or "an" in modifiers
    if not wants_article {
      ""
    } else if mode == "short" {
      entry.article + " "
    } else {
      // mode == "long" or "both"
      entry.longarticle + " "
    }
  }

  // determine_mode(wants_both, wants_long, wants_short, is_first_use, long_available):
  // Decides which mode ("short", "long", or "both") to use.
  // Preference is given to explicit modifiers. If the requested mode can't be fulfilled due to no long form,
  // fall back to "short".
  // If no explicit mode is given, the default behavior is:
  //   - On first use and if a long form exists, "both".
  //   - Otherwise, "short".
  let determine_mode = (wants_both, wants_long, wants_short, is_first_use, long_available) => {
    if wants_both {
      // Explicit request for "both":
      // If a long form exists, use "both", otherwise fall back to "short".
      if long_available {
        "both"
      } else {
        "short"
      }
    } else if wants_long {
      // Explicit request for "long":
      // If a long form exists, use "long", otherwise fall back to "short".
      if long_available {
        "long"
      } else {
        "short"
      }
    } else if wants_short {
      // Explicit request for "short":
      // Always "short" regardless of availability.
      "short"
    } else {
      // No explicit mode given:
      // On first use with a long form available, default to "both".
      // Otherwise, use "short".
      if is_first_use and long_available {
        "both"
      } else {
        "short"
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Determine desired options based on modifiers and entry.long availability
  // ---------------------------------------------------------------------------
  let wants_both = "both" in modifiers
  let wants_long = "long" in modifiers
  let wants_short = "short" in modifiers
  let long_available = entry.long != none

  // Determine mode using the helper function
  let mode = determine_mode(wants_both, wants_long, wants_short, is_first_use, long_available)

  // Get the article and term for the chosen mode, then apply capitalization if requested
  let (article, term) = capitalize_term(get_article(mode), get_term(mode))

  // ---------------------------------------------------------------------------
  // Construct and return the final output
  // ---------------------------------------------------------------------------
  context {
    [#article#show-term(term)#metadata(term)#__term_label(key, key_index)]
  // |^^^^^^^|^^^^^^^^^      |^^^^^^^^      |^^^^^^^^^^^^
  // \_art.  |               |              |
  //         \_ apply user formatting function to the term
  //                         |              |
  //                         \_ metadata lets us label (ie it's "labelable")
  //                                        |
  //                                        \_ i.e. <__gloss.key.0>, etc.
  //                                           for backlink from glossary
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
  // Convert term (key + count) to labels with their displayed page numbers
  let page_labels = range(count).map(i => {
    let label = __term_label(key, i)
    let loc = locate(label)
    (
      label,
      numbering(__default(loc.page-numbering(), "1"), ..counter(page).at(loc))
    )
  })

  // Filter out repeated page numbers using a regular loop
  let seen = (:)
  let singulated = ()
  for (label, page) in page_labels {
    if not seen.keys().contains(page) {
      seen.insert(page, true)
      singulated.push((label, page))
    }
  }

  // Convert resulting set to array of links
  singulated.map(((label, page)) => link(label, page)).join(", ")
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
  // Type checking
  let checked-entries = (:)
  for (key, entry) in entries {
    let checked-key = z.parse(key, z.string(), scope: ("dictionary key",))
    let checked-entry = z.parse(entry, dict-schema, scope: ("dictionary entry",))
    checked-entries.insert(checked-key, checked-entry)
  }
  let checked-show-term = z.parse(show-term, z.function(), scope: ("show-term",))
  let checked-body = z.parse(body, z.content(), scope: ("body",))

  // Process and store each glossary entry
  for (key, entry) in entries {
    __add_entry(key, __normalize_entry(key, entry))
  }

  // Set up reference handling for glossary terms
  show ref: r => {
    let (raw_key, ..raw_modifiers) = str(r.target).split(":")

    // Determine if we need to swap the key and first modifier.
    // Conditions for swapping:
    //  - The original key is "a" or "an" (case-insensitive),
    //  - That "key" does not correspond to an actual entry,
    //  - There is at least one modifier,
    //  - The first modifier corresponds to an existing entry key.
    let can_swap = (lower(raw_key) == "a" or lower(raw_key) == "an") and not __has_entry(raw_key) and raw_modifiers.len() > 0 and __has_entry(raw_modifiers.first())

    // If we can swap, use the first modifier as the key and insert "a" as the first modifier.
    let (key, modifiers) = if can_swap {
      (raw_modifiers.first(), ("a",) + raw_modifiers.slice(1))
    } else {
      (raw_key, raw_modifiers)
    }

    // Now see if this is an actual glossary term key
    if __has_entry(key) {
      // Found in dictionary, render via __gls()
      __gls(key, modifiers: modifiers.map(lower), show-term: show-term)
    } else {
      // Not one of ours, so just pass it through
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
  // Type checking
  let checked-title = z.parse(title, z.content(), scope: ("title",))
  let checked-groups = z.parse(groups, groups-list-schema, scope: ("groups",))
  let checked-ignore-case = z.parse(ignore-case, z.boolean(), scope: ("ignore-case",))
  let checked-theme = z.parse(theme, theme-schema, scope: ("theme",))

  // Collect and organize entries by group
  let output = (:)
  let all_entries = __gloss_entries.final()
  let all_used = __gloss_used.final()

  // Determine which groups to process
  let all_groups = all_entries
    .values()
    .map(e => e.at("group"))
    .map(g => { if g == none { "" } else { g } })
    .dedup()
    .sorted()

  let target_groups = if checked-groups.len() == 0 {
    all_groups
  } else {
    // Validate requested groups exist
    for g in checked-groups {
      if g == none {
        g = ""
      }
      if g not in all_groups {
        panic("Requested group, '" + g + "', not found.")
      }
    }
    checked-groups
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

  (checked-theme.section)(
    title,
    for (group, entries) in output {
      (checked-theme.group)(
        group,
        group_index,
        output.len(),
        for (i, entry) in entries.enumerate() {
          (checked-theme.entry)(entry, i, entries.len())
        }
      )
      group_index += 1
    }
  )
}
