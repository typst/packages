#import "./themes.typ": *
#import "./utils.typ": *

#let __gloss_entries = state("__gloss_entries", (:))
#let __gloss_used = state("__gloss_used", (:))

#let __gloss_label_prefix = "__gloss:"

// given an array of dictionaries, make sure each has all the keys we'll
// reference, using default values if needed
#let __normalize_entries(entry-list) = {
  // TODO: panic if key or short missing, all others optional
  let new-list = ()
  for entry in entry-list {
    let long = entry.at("long", default: none)
    let longplural = entry.at("longplural", default: none)
    if long != none and longplural == none {
      longplural = __pluralize(long)
    }

    new-list.push((
      key: entry.key,
      short: entry.short,
      plural: entry.at("plural", default: __pluralize(entry.short)),
      long: long,
      longplural: longplural,
      description: entry.at("description", default: none),
      group: entry.at("group", default: ""),
    ))
  }
  return new-list
}

// update our state with a glossary entry
#let __add_entry(entry) = {
  // make sure our final glossary state does not already have this key
  if __gloss_entries.final().at(entry.key, default: false) == true {
    panic("Glossary error. Duplicate key: " + entry.key)
  }

  // add it to the state
  __gloss_entries.update(st => {
    st.insert(entry.key, entry)
    return st
  })
}

// fetch a glossary entry from our state, or panic
#let __get_entry(key) = {
    let entries = __gloss_entries.final()
    if key not in entries {
      panic("Glossary error. Missing key: " + key)
    }

    entries.at(key)
}

// returns true if an entry with `key` is in our glossary state
#let __has_entry(key) = {
    let entries = __gloss_entries.final()
    key in entries
}

// helper to prefix a key for label/reference scoping for the dictionary entry
#let __dict_label_str(key) = {
  __gloss_label_prefix + key
}

// helper to get a label with prefix for the dictionary entry
#let __dict_label(key) = {
  label(__dict_label_str(key))
}

// helper to prefix a key for label/reference scoping for the term use in a doc
#let __term_label_str(key, index) = {
  __gloss_label_prefix + key + "." + str(index)
}

// helper to get a label with prefix for the term use in a doc
#let __term_label(key, index) = {
  label(__term_label_str(key, index))
}

// update the usage count for a given key
#let __save_term_usage(key, count) = {
  __gloss_used.update(st => {
    st.insert(key, count)
    return st;
  })
}

// the main function which emits terms used in a document
//
// handles all the modifiers:
//
// - cap: capitalize the term
// - pl: pluralize the term
// - both: emit "Long form (short form)"
// - short: emit just the short form
// - long: emit just the long form
#let __gls(
  key,
  modifiers: array
) = {

  // Get the term
  let entry = __get_entry(key)
  let entry_label = __dict_label_str(key)

  // Lookup and increment the count
  let entry_counter = counter(entry_label)
  entry_counter.step()

  // See if this is the first use
  let key_index = entry_counter.get().first()
  let first = key_index == 0

  // Count the entry as used so we can link back from glossary
  __save_term_usage(entry.key, key_index + 1)

  // Helper: Apply pluralization if needed
  let pluralize_term = (singular, plural) => {
    if "pl" in modifiers and plural != none { plural } else { singular }
  }

  // Helper: Capitalize term if "cap" modifier present
  let capitalize_term = (term) => {
    if "cap" in modifiers { upper(term.first()) + term.slice(1) } else { term }
  }

  // Helper: Format a term with pluralization and capitalization
  let format_term = (term, plural) => {
    capitalize_term(pluralize_term(term, plural))
  }

  // Helper: Select and format the displayed term (long, short, or both)
  let select_term = (is_long_mode, use_both) => {
    // Derive pluralized and capitalized versions of the long and short forms
    let short_form = format_term(entry.short, entry.plural)
    let long_form = if entry.long != none { format_term(entry.long, entry.longplural) } else { none }

    // Return logic for term selection:
    if use_both and long_form != none {
      // 1. If "both" is requested AND we have a long form available:
      //    Show "Long Form (Short Form)"
      [#long_form (#short_form)]
    } else if is_long_mode and long_form != none {
      // 2. If long mode is requested AND we have a long form available:
      //    Show just the long form
      [#long_form]
    } else {
      // 3. Fallback case - use short form when:
      //    - "both" was requested but no long form exists
      //    - long mode was requested but no long form exists
      //    - short form was explicitly requested
      //    - no specific mode was requested
      [#short_form]
    }
  }

  // Determine which form to display: "short", "long", or "both"
  let is_both = "both" in modifiers
  let is_long = "long" in modifiers and not is_both
  let is_short = "short" in modifiers and not is_both and not is_long

  context {
    // Final display logic
    let display = if is_both or is_long or is_short {
      // User requested specific behavior via modifiers
      select_term(is_long, is_both)
    } else {
      // Default behavior: show "both" on first use, else "short"
      select_term(false, first)
    }

    // TODO: figure out how to link to __dict_label(key) if the glossary exists
    // NOTE: this is a low priority, I don't think it's that important or useful.

    // Emit with labels for this instance of the term usage
    [#display#metadata(display)#__term_label(key, key_index)]
  }
}

// Create all the backlinks to term uses in a doc, in the form of page numbers
// linked. Used when emitting a glossary, so its page numbers can link back to
// the uses.
#let __create_backlinks(key, count) = {
  // create array of labels to link to
  let labels = for i in range(count) {
    (__term_label(key, i),)
  }

  // create arrays of locations, and page number display text
  let pages = labels
    .map(l => { locate(l) })
    .map((loc) => { numbering(__default(loc.page-numbering(), "1"), loc.page()) })

  // convert labels to links, filtering out duplicated pages
  let seen = ()
  let links = for i in range(labels.len()) {
    let l = labels.at(i)
    let p = pages.at(i)
    if seen.contains(p) {
      (none,)
    } else {
      seen.push(p)
      (link(l, p),)
    }
  }.filter(l => l != none)

  // connect links with commas and return
  links.join(", ")
}

// Main wrapper (usually used in a `#show: init-glossary`) which loads the
// entries passed in into our state. Furthermore, hooks into references so that
// we can intercept term usage in a doc and label them appropriately.
#let init-glossary(entries, body) = context {
  for entry in __normalize_entries(entries) {
    __add_entry(entry)
  }

  // convert refs we recognize into links with labels
  show ref: r => {
    let (key, ..modifiers) = str(r.target).split(":")
    if __has_entry(key) {
      __gls(key, modifiers: modifiers)
    } else {
      r
    }
  }

  body
}

// Used to print a glossary. Can customize title, theme, and/or specify groups.
//
// A theme is a dictionary with three attributes:
//
// #let my-theme = (
//   section: (title, body) => {
//     // how to display the glossary section and its body which will contain
//     // groups, each with their entries
//   },
//
//   group: (name, body) => {
//     // how to display a group name and its body (which will contain the
//     // entries in that group)
//   },
//
//   entry: (entry, i, n) => {
//     // how to display a single entry, along with its index and total count
//   }
// }

#let glossary(title: "Glossary", theme: theme-2col, groups: ()) = context {
  // our output is a map of group name to array of entries (each entry is a map)
  let output = (:)

  // pull in entire dictionary
  let all_entries = __gloss_entries.final()

  // filter down to just what we used
  let all_used = __gloss_used.final()

  // TODO: what about entries with no group? Or group == "" or == none

  // get all groups
  let all_groups = all_entries.values().map(e => e.at("group")).dedup().sorted()
  let groups = if groups.len() == 0 { all_groups } else { groups }

  // make sure requested groups are legit
  for g in groups {
    if g not in all_groups {
      panic("Requested group not found: " + g)
    }
  }

  // iterate one group at a time
  for g in groups {
    // collect used entries in this group
    let cur = ()
    for (key, count) in all_used {
      let e = all_entries.at(key)
      if e.at("group") == g {
        // this term is both in this group and was used, add to our output
        let short = e.at("short")
        let long = e.at("long")
        let description = e.at("description")
        let label = [#metadata(key)#__dict_label(key)]
        let pages = __create_backlinks(key, count)
        cur.push((short: short, long: long, description: description, label: label, pages: pages))
      }
    }
    if cur.len() > 0 {
      if g == none { g = "" }
      output.insert(g, cur.sorted(key: e => e.short))
    }
  }

  // TODO: rendering for a) just one group, or b) the default group (ie terms
  // with no group)??  -- in this case should we just not use the theme.group()
  // function?

  // index for group because dictionary don't have enumerate()
  let i_group = 0;

  // render it using our theme
  (theme.section)(
    title,
    // section body (all groups)
    for (group, entries) in output {
      (theme.group)(
        group,
        i_group,
        output.len(),
        // group body (all entries)
        for (i,e) in entries.enumerate() {
          (theme.entry)(e, i, entries.len())
        },
      )
      i_group += 1
    }
  )
}
