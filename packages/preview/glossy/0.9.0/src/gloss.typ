#import "@preview/valkyrie:0.2.2" as z

#import "./schemas.typ": *
#import "./themes.typ": *
#import "./utils.typ": *

#let __gloss_entries = state("__gloss_entries", (:))

#let __gloss_label_prefix = "__gloss:"
#let __gloss_first_use_counter_postfix = ":first-use-count"
#let __gloss_entry_postfix = ":entry"

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
// Panics:
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
  if type(entry.short) != str {
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
    group: entry.at("group", default: ""),
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
// Panics:
//   - If the key does not exist in the glossary
//
#let __get_entry(key) = {
  let entries = __gloss_entries.final()
  if key not in entries.keys() {
    panic("Glossary error: Missing key '" + key + "'")
  }

  entries.at(key)
}

// Creates a label object for term usage in documents.
//
// Parameters:
//   key (string): The glossary entry key
//
// Returns:
//   label: A Typst label object for the term usage
//
#let __term_label(key) = {
  label(__gloss_label_prefix + key)
}

// Creates a label object for the entry in the glossary.
//
// Parameters:
//   key (string): The glossary entry key
//
// Returns:
//   label: A Typst label object for the term usage
//
#let __entry_label(key) = {
  label(__gloss_label_prefix + key + __gloss_entry_postfix)
}

// Updates the term usage (first use counter & wants to be referenced counter)
// in the glossary state.
//
// Parameters:
//   key (string): The glossary entry key
//
// Returns:
//   none: Updates state as a side effect
//
#let __mark_term_used(key, count-as-referenced, count-as-first-use) = {
  if count-as-referenced {
    counter(__gloss_label_prefix + key).step()
  }
  if count-as-first-use {
    counter(
      __gloss_label_prefix + key + __gloss_first_use_counter_postfix,
    ).step()
  }
}

// Queries whether the term wants to be referenced from ANYWHERE
//
// Parameters:
//   key (string): The glossary entry key
//   location (location): The location in the document. Use none for end of document
//
// Returns:
//   boolean: If the entry is used above the location in the document
//
#let __is_term_ever_referenced(key, location: none) = {
  let c = counter(__gloss_label_prefix + key)
  c = if location == none { c.final() } else { c.at(location) }
  c.at(0) > 0
}

// Queries whether the term has been "first used"
//
// "First used" is used to determine how to display the term, either "long
// (short)" or just "(short)"
//
// Parameters:
//   key (string): The glossary entry key
//   location (location): The location in the document. Use none for end of document
//
// Returns:
//   boolean: If the entry is used above the location in the document
//
#let __is_term_first_used(key, location: none) = {
  let c = counter(
    __gloss_label_prefix + key + __gloss_first_use_counter_postfix,
  )
  c = if location == none { c.final() } else { c.at(location) }
  c.at(0) > 0
}

// Reset the first use counter to 0
//
// Parameters:
//   key (string): The glossary entry key
//
// Returns:
//   none: Updates state as a side effect
//
#let __reset_term_first_used(key, location: none) = {
  counter(
    __gloss_label_prefix + key + __gloss_first_use_counter_postfix,
  ).update(0)
}

// Determine if the glossary contains a visible entry
//
// Parameters:
//   key (string): The glossary entry key
//
// Returns:
//   boolean: If the term is visible in the glossary (and the label is unique)
//
#let __has_glossary_entry(key) = {
  query(__entry_label(key)).len() > 0
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
//   term-links (boolean): If terms should be clickable links leading to glossary
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
#let __gls(
  key,
  modes-modifiers: array,
  format-term: function,
  show-term: function,
  term-links: true,
  display-text: none,
) = {
  let possible_modes = (
    "auto",
    "both",
    "short",
    "long",
    "supplement",
    "description",
    "reset",
  )
  // ---------------------------------------------------------------------------
  // Normalize mode & modifier inputs AND check if the modifiers are valid
  // ---------------------------------------------------------------------------
  let modes-modifiers = modes-modifiers.map(it => {
    if it == "def" or it == "desc" {
      return "description"
    } else if it == "a" or it == "an" {
      return "an"
    } else if it == "use" or it == "spend" {
      return "use"
    } else if it == "nouse" or it == "nospend" {
      return "no-use"
    } else if it == "noref" or it == "noindex" {
      return "noindex"
    } else if it in ("both", "short", "long", "reset", "cap", "pl") {
      return it
    } else if it in ("auto", "description", "supplement") {
      panic(
        it,
        "is a valid mode, but is not used by applying a modifier with this name. Read the documentation.",
      )
    } else {
      panic(it, "is not a recognized mode or modifier.")
    }
  })
  if display-text != none and display-text != auto {
    // A supplement is provided, thus the mode is "supplement"
    modes-modifiers.push("supplement")
  }

  // ---------------------------------------------------------------------------
  // Determine the requested modes (plural) and the modifier array
  // ---------------------------------------------------------------------------
  modes-modifiers.push("__MIDDLE_ITEM") // unused modifier
  let (requested_modes, modifiers) = modes-modifiers
    .sorted(key: it => {
      if it in possible_modes {
        // It is a 'mode'
        return -1
      } else if it == "__MIDDLE_ITEM" {
        return 0
      } else {
        // It is a 'modifier'
        return 1
      }
    })
    .split("__MIDDLE_ITEM")

  // ---------------------------------------------------------------------------
  // Check for illegal mode and/or modifier combinations
  // ---------------------------------------------------------------------------
  if requested_modes.len() > 1 {
    panic("Cannot mix modes ", requested_modes, ", pick one.")
  }
  if "description" in requested_modes and modifiers.len() > 0 {
    panic("Cannot use mode 'def'/'desc' with other modifiers.")
  }
  if "reset" in requested_modes and modifiers.len() > 0 {
    panic("Cannot use mode 'reset' with other modifiers.")
  }
  if "an" in modifiers and "pl" in modifiers {
    panic("Cannot use 'a'/'an' and 'pl' together.")
  }
  if "use" in modifiers and "no-use" in modifiers {
    panic("Cannot use 'use'/'spend' and 'nouse'/'nospend' together.")
  }

  // ---------------------------------------------------------------------------
  // Retrieve the glossary entry and its label
  // ---------------------------------------------------------------------------
  let entry = __get_entry(key)

  // ---------------------------------------------------------------------------
  // Determine the requested mode (singular)
  // ---------------------------------------------------------------------------
  let requested_mode = if requested_modes.len() == 0 {
    "auto"
  } else {
    requested_modes.at(0)
  }

  // ---------------------------------------------------------------------------
  // If mode is "description", show the entry's description immediately
  // ---------------------------------------------------------------------------
  if requested_mode == "description" {
    if entry.description == none {
      panic("Use of 'def'/'desc' requires a description be defined.")
    }
    return show-term([#entry.description])
  }
  // ---------------------------------------------------------------------------
  // If mode is "reset", reset the (first) usage counter and return immediately
  // ---------------------------------------------------------------------------
  if requested_mode == "reset" {
    __reset_term_first_used(key)
    return
  }

  // ---------------------------------------------------------------------------
  // Manage term usage counting and determine if it's the first reference
  // ---------------------------------------------------------------------------
  let is_first_use = not __is_term_first_used(key, location: here())
  let default-count-as-first-use = (
    requested_mode == "auto" or requested_mode == "both"
  )
  let force-count-as-first-use = "use" in modifiers
  let force-skip-as-first-use = "no-use" in modifiers
  let wants_reference = "noindex" not in modifiers
  __mark_term_used(
    key,
    wants_reference,
    force-count-as-first-use
      or (not force-skip-as-first-use and default-count-as-first-use),
  )

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
    } else if article == none {
      // No article present, so capitalize the term's first letter.
      (article, upper(term.first()) + term.slice(1))
    } else {
      // Article is present; capitalize its first letter instead.
      (upper(article.first()) + article.slice(1), term)
    }
  }

  // get_article(mode): Returns the appropriate article string based on the mode.
  //   - If wants_article is false, returns none
  //   - If mode is "short", return the short article.
  //   - If mode is "long" or "both", return the long article.
  // The calling logic ensures that when mode = "long" or "both", a long form exists.
  let get_article = mode => {
    let wants_article = "an" in modifiers
    if not wants_article {
      none
    } else if mode == "short" {
      entry.article + " "
    } else {
      // mode == "long" or "both"
      entry.longarticle + " "
    }
  }

  // ---------------------------------------------------------------------------
  // Determine desired options based on modifiers and entry.long availability
  // ---------------------------------------------------------------------------
  // Decide which mode ("short", "long", or "both" or "supplement") to use.
  // If the requested mode can't be fulfilled due to no long form, fall back to "short".
  // If no explicit mode is given (i.e. we are in 'auto' mode), the default behavior is:
  //   - On first use and if a long form exists, "both".
  //   - Otherwise, "short".
  if requested_mode == "auto" {
    // Set requested_mode to automatically determined mode
    requested_mode = if is_first_use {
      "both"
    } else {
      "short"
    }
  }

  let long_available = entry.long != none
  let mode = if (
    (requested_mode == "both" or requested_mode == "long")
      and not long_available
  ) {
    // The fall back case, because long form is not available, but it is requested
    "short"
  } else {
    // No fall back needed, the requested mode can be fulfilled
    requested_mode
  }

  // Pluralize (if requested)
  let short-form = pluralize_term(entry.short, entry.plural)
  let long-form = pluralize_term(entry.long, entry.longplural) // `none` safe here

  // Apply format-term() to get the term
  let formatted-term = if mode == "supplement" {
    // Display text was overriden by user, just accept it (string or content)
    display-text
  } else {
    // Normal display (ie no override from user)
    format-term(mode, short-form, long-form)
  }
  if "cap" in modifiers and type(formatted-term) != str {
    // This is because we still need to capitalize the term, and we cannot do
    // that with content, thus requiring a string here.
    // TODO: consider if we want to capitalize *before* this. First intuition is
    // "no".
    panic("Your custom format-term() function must return a string.")
  }

  // Get the article, then capitalize either the article or term (if requested)
  let (article, term) = capitalize_term(get_article(mode), formatted-term)

  // ---------------------------------------------------------------------------
  // Construct and return the final output
  // ---------------------------------------------------------------------------
  context {
    let linked-term = if term-links and __has_glossary_entry(key) {
      link(__entry_label(key), term)
    } else {
      term
    }
    // Figure out our label (unless not wanted)
    let term-label = if wants_reference {
      __term_label(key)
    } else {
      []
    }

    // Create the output content
    [#article#show-term(linked-term)#metadata(term)#term-label]
    // |^^^^^|^^^^^^^^^             |^^^^^^^^      |^^^^^^^^^^
    // |     |                      |              \_ the label for backlink from
    // |     |                      |                 glossary i.e. <__gloss:key>, etc.
    // |     |                      \_ metadata lets us label (ie makes it "labelable")
    // |     \_ apply user formatting function to the term
    // \_art.
  }
}

// Creates page number links back to each usage of a glossary term.
//
// This function generates an array of page numbers, where each number links
// back to a usage of the term in the document. Duplicate page numers are
// removed to avoid redundancy.
//
// Parameters:
//   key (string): The glossary entry key
//
// Returns:
//   array: Linked page numbers
//
// Example output after a typical .join(", "):
// "1, 3, 5" where each number links to the term usage on that page
//
#let __create_backlinks(key) = {
  return query(__term_label(key)) // find all reference
    .map(meta => {
      // extract location and page number (or symbol)
      let loc = meta.location()
      let page = numbering(
        __default(loc.page-numbering(), "1"),
        ..counter(page).at(loc),
      )
      (loc, page)
    })
    .dedup(key: ((loc, page)) => page) // deduplicate by page
    .map(((loc, page)) => link(loc, page)) // create links
}

// Formats a term string based on the specified mode.
//
// Given mode, long-form, and short-form, this function returns the formatted
// term based on the mode. When mode is ...
//
// - "short" -> returns "short-form"
// - "long" -> returns "long-form"
// - "both" -> returns "short-form (long-form)"
//
// Parameters:
//   mode (string): The mode in which to format the term. Possible values are "short", "long", or "both".
//   short-form (string): The short form of the term.
//   long-form (string): The long form of the term.
//
// Returns:
//   string: The formatted term based on the specified mode.
//
#let __default-format-term(mode, short-form, long-form) = {
  if mode == "short" {
    short-form
  } else if mode == "long" {
    long-form
  } else {
    // mode assumed to be "both"
    long-form + " (" + short-form + ")"
  }
}

// Styles a term to control its display in a document.
//
// Parameters:
//   term-body (content'ish): the unstyled output from __gls()
//
// Returns:
//   content: display ready content (assumed based on `term-body`)
//
#let __default-show-term(term-body) = {
  // Default: just render it like normal text
  term-body
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
//   term-links (boolean): If terms should be clickable links leading to glossary
//   body (content): Document content to process
//
// Returns:
//   content: Processed document content with glossary functionality enabled
//
// Panics:
//   - If entries parameter is not a dictionary
//
#let init-glossary(
  entries,
  format-term: __default-format-term,
  show-term: __default-show-term,
  term-links: false,
  body,
) = context {
  // Type checking
  let checked-entries = (:)
  for (key, entry) in entries {
    let checked-key = z.parse(key, z.string(), scope: ("dictionary key",))
    let checked-entry = z.parse(entry, dict-schema, scope: (
      "dictionary entry",
    ))
    checked-entries.insert(checked-key, checked-entry)
  }
  let checked-format-term = z.parse(show-term, z.function(), scope: (
    "format-term",
  ))
  let checked-show-term = z.parse(show-term, z.function(), scope: (
    "show-term",
  ))
  let checked-body = z.parse(body, z.content(), scope: ("body",))

  // Process and store each glossary entry
  for (key, entry) in entries {
    __add_entry(key, __normalize_entry(key, entry))
    // Create placeholder labels for autocompletion
    [#metadata(key)#label(key)]
  }

  // Set up reference handling for glossary terms
  show ref: r => {
    let (raw_key, ..raw_modifiers) = str(r.target).split(":")
    let supplement = r.supplement // used for term display overrides

    // Determine if we need to swap the key and first modifier.
    // Conditions for swapping:
    //  - The original key is "a" or "an" (case-insensitive),
    //  - That "key" does not correspond to an actual entry,
    //  - There is at least one modifier,
    //  - The first modifier corresponds to an existing entry key.
    let can_swap = (
      (lower(raw_key) == "a" or lower(raw_key) == "an")
        and not __has_entry(raw_key)
        and raw_modifiers.len() > 0
        and __has_entry(raw_modifiers.first())
    )

    // If we can swap, use the first modifier as the key and insert "a" as the first modifier.
    let (key, modifiers) = if can_swap {
      (raw_modifiers.first(), ("a",) + raw_modifiers.slice(1))
    } else {
      (raw_key, raw_modifiers)
    }

    // Now see if this is an actual glossary term key
    if __has_entry(key) {
      // Found in dictionary, render via __gls()
      __gls(
        key,
        modes-modifiers: modifiers.map(lower),
        format-term: format-term,
        show-term: show-term,
        term-links: term-links,
        display-text: supplement,
      )
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
//         - pages: Array of linked page numbers where term appears
//       - index: Zero-based entry index within group
//       - total: Total entries in group
//   groups (array): Optional list of groups to include
//                  If empty, includes all groups
//
// Returns:
//   content: Formatted glossary content
//
// Panics:
//   - If a requested group doesn't exist
//
#let glossary(
  title: "Glossary",
  theme: theme-academic,
  sort: true,
  ignore-case: false,
  groups: (),
  show-all: false,
) = context {
  // Type checking
  let checked-title = z.parse(title, z.content(), scope: ("title",))
  let checked-groups = z.parse(groups, groups-list-schema, scope: ("groups",))
  let checked-ignore-case = z.parse(ignore-case, z.boolean(), scope: (
    "ignore-case",
  ))
  let checked-theme = z.parse(theme, theme-schema, scope: ("theme",))

  // Collect and organize entries by group
  let output = (:)
  let all_entries = __gloss_entries.final()
  let all_used = if not show-all {
    all_entries.keys().filter(key => __is_term_ever_referenced(key))
  } else {
    all_entries.keys()
  }

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
    for key in all_used {
      let entry = all_entries.at(key)
      if entry.at("group") == group {
        current_entries.push((
          short: entry.at("short"),
          long: entry.at("long"),
          description: entry.at("description"),
          label: [#metadata(key)#__entry_label(key)],
          pages: __create_backlinks(key),
        ))
      }
    }

    // Add non-empty groups to output
    if current_entries.len() > 0 {
      group = if group == none { "" } else { group }

      // sort entries by case insensitivity if requested
      let sorted_entries = if sort {
        current_entries
          // 1. create array of tuples with (lower [if ignore-case], entry)
          .map(e => {
            if ignore-case { (lower(e.short), e) } else { (e.short, e) }
          })
          // 2. sort the tuples (by first element then second)
          .sorted() // NOTE: sorted() is NOT language-aware
          // 3. strip away the tuple's first element, leaving an array of entries
          .map(t => t.last())
      } else {
        current_entries
      }

      // add entries to this group's output map
      output.insert(group, sorted_entries)
    }
  }

  // Render the glossary using the theme
  let group_index = 0

  [
    #metadata("glossary")<glossary>
    #(checked-theme.section)(
      title,
      for (group, entries) in output {
        (checked-theme.group)(
          group,
          group_index,
          output.len(),
          for (i, entry) in entries.enumerate() {
            (checked-theme.entry)(entry, i, entries.len())
          },
        )
        group_index += 1
      },
    )
  ]
}
