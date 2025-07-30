// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// glossarium figure kind
#let __glossarium_figure = "glossarium_entry"

// prefix of label for references query
#let __glossary_label_prefix = "__gls:"

// global state containing the glossary entry and their location
// A glossary entry is a `dictionary`.
// See `__normalize_entry_list`.
#let __glossary_entries = state("__glossary_entries", (:))

// glossarium version
#let glossarium_version = "0.5.0"

// error prefix
#let __glossarium_error_prefix = "glossarium@" + glossarium_version + " error : "

// Errors types
#let __key_not_found = "key_not_found"
#let __attribute_is_empty = "attribute_is_empty"
#let __glossary_is_empty = "glossary_is_empty"
#let __entry_has_neither_short_nor_long = "entry_has_neither_short_nor_long"
#let __unknown_error = "unknown_error"

// __error_message(key, kind, ..kwargs) -> str
// Generate an error message
//
// # Arguments
//  key (str): the key of the term
//  kind (str): the kind of the error
//  kwargs (arguments): additional arguments
//
// # Returns
// The error message
#let __error_message(key, kind, ..kwargs) = {
  let msg = none
  let kwargs = kwargs.named() // convert arguments sink to dictionary

  // Generate the error message
  if kind == __key_not_found {
    msg = "key '" + key + "' not found"
  } else if kind == __attribute_is_empty {
    let attr = kwargs.at("attr")
    msg = "requested attribute " + attr + "is empty for key '" + key + "'"
  } else if kind == __entry_has_neither_short_nor_long {
    msg = "entry '" + key + "' has neither short nor long form"
  } else if kind == __glossary_is_empty {
    msg = "glossary is empty. Use `register-glossary(entry-list)` immediately after `make-glossary`."
  } else {
    msg = "unknown error"
  }

  // return the error message
  return __glossarium_error_prefix + msg
}

// __query_labels_with_key(loc, key, before: false) -> array<label>
// Query the labels with the key
//
// # Arguments
//  loc (location): the location of the reference
//  key (str): the key of the term
//  before (bool): if true, it will query the labels before the location
//
// # Returns
// The labels with the key
#let __query_labels_with_key(loc, key, before: false) = {
  if before {
    return query(
      selector(label(__glossary_label_prefix + key)).before(
        loc,
        inclusive: false,
      ),
    )
  } else {
    return query(selector(label(__glossary_label_prefix + key)))
  }
}

// __get_entry_with_key(loc, key) -> dictionary
// Get an entry from the glossary
//
// # Arguments
//  loc (location): the location of the reference
//  key (str): the key of the term
//
// # Returns
// The entry of the term
//
// # Panics
// If the key is not found, it will raise a `key_not_found` error
#let __get_entry_with_key(loc, key) = {
  let entries = if sys.version <= version(0, 11, 1) {
    __glossary_entries.final()
  } else {
    __glossary_entries.at(loc)
  }
  if key in entries {
    return entries.at(key)
  } else {
    panic(__error_message(key, __key_not_found))
  }
}

// __is_first_or_long(loc, key, long: none) -> bool
// Check if the key is the first reference to the term or long form is requested
//
// # Arguments
//  loc (location): the location of the reference
//  key (str): the key of the term
//  long (bool): if true, it will return true if the long form is requested
//
// # Returns
// True if the key is the first reference to the term or long form is requested
#let __is_first_or_long(loc, key, long: none) = {
  let gloss = __query_labels_with_key(loc, key, before: true)
  return gloss == () or long == true
}

#let __has_attribute(entry, key) = {
  let attr = entry.at(key, default: "")
  return attr != "" and attr != []
}
#let has-short(entry) = __has_attribute(entry, "short")
#let has-long(entry) = __has_attribute(entry, "long")
#let has-artshort(entry) = __has_attribute(entry, "artshort")
#let has-artlong(entry) = __has_attribute(entry, "artlong")
#let has-plural(entry) = __has_attribute(entry, "plural")
#let has-longplural(entry) = __has_attribute(entry, "longplural")
#let has-description(entry) = __has_attribute(entry, "description")
#let has-group(entry) = __has_attribute(entry, "group")

// __link_and_label(key, text, prefix: none, suffix: none) -> contextual content
// Build a link and a label
//
// # Arguments
//  key (str): the key of the term
//  text (content): the text to be displayed
//  prefix (str|content): the prefix to be added to the label
//  suffix (str|content): the suffix to be added to the label
//
// # Returns
// The link and the entry label
#let __link_and_label(key, text, prefix: none, suffix: none) = (
  context {
    return [#prefix#link(
        label(key),
        text,
      )#suffix#label(__glossary_label_prefix + key)]
  }
)

// gls(key, suffix: none, long: none, display: none) -> contextual content
// Reference to term
//
// # Arguments
//  key (str): the key of the term
//  suffix (str): the suffix to be added to the short form
//  long (bool): enable/disable the long form
//  display (str): override text to be displayed
//
// # Returns
// The link and the entry label
#let gls(key, suffix: none, long: none, display: none) = {
  context {
    let entry = __get_entry_with_key(here(), key)

    // Attributes
    let ent-long = entry.at("long", default: "")
    let ent-short = entry.at("short", default: "")

    // Conditions
    let is-first-or-long = __is_first_or_long(here(), key, long: long)
    let has-long = has-long(entry)

    // Link text
    // 1. If `display` attribute is provided, use it
    // 2. Else, if
    //  a. The entry is referenced for the first time OR long form is explicitly requested
    //      AND
    //  b. The entry has a nonempty `long` attribute
    //      AND
    //  c. long form is not disabled
    // 3. Else, return the `short` attribute + suffix
    // Priority order:
    //  1. `gls(key, display: "text")` will return `text`
    //  2. `gls(key, long: false)` will return `short+suffix`
    //  3. If attribute `long` is empty, `gls(key)` will return `short+suffix`
    //  4. The first `gls(key)` will return `long (short+suffix)`
    //  5. `gls(key, long: true)` will return `long (short+suffix)`
    let link-text = []
    if display != none {
      link-text += [#display]
    } else if is-first-or-long and has-long and long != false {
      link-text += [#ent-long (#ent-short#suffix)]
    } else {
      link-text += [#ent-short#suffix]
    }

    return __link_and_label(entry.key, link-text)
  }
}

// agls(key, suffix: none, long: none) -> contextual content
// Reference to term with article
//
// # Arguments
//  key (str): the key of the term
//  suffix (str|content): the suffix to be added to the short form
//  long (bool): enable/disable the long form
//
// # Returns
// The link and the entry label
#let agls(key, suffix: none, long: none) = {
  context {
    let entry = __get_entry_with_key(here(), key)

    // Attributes
    let ent-long = entry.at("long", default: "")
    let ent-short = entry.at("short", default: "")
    let ent-artlong = entry.at("artlong", default: "a")
    let ent-artshort = entry.at("artshort", default: "a")

    // Conditions
    let is-first-or-long = __is_first_or_long(here(), key, long: long)
    let has-long = has-long(entry)
    let has-short = has-short(entry)

    // Link text
    let link-text = none
    let article = none
    if is-first-or-long and has-long and long != false {
      link-text = [#ent-long (#ent-short#suffix)]
      article = ent-artlong
    } else if has-short {
      // Default to short
      link-text += [#ent-short#suffix]
    } else {
      // Default to short
      link-text = [#entry.short#suffix]
      article = ent-artshort
    }

    // Return
    return __link_and_label(entry.key, link-text, prefix: [#article ])
  }
}

// glspl(key, long: none) -> contextual content
// Reference to term with plural form
//
// # Arguments
//  key (str): the key of the term
//  long (bool): enable/disable the long form
//
// # Returns
// The link and the entry label
#let glspl(key, long: none) = {
  context {
    let default-plural-suffix = "s"
    let entry = __get_entry_with_key(here(), key)

    // Attributes
    let ent-short = entry.at("short", default: "")
    let ent-plural = entry.at("plural", default: "")
    let ent-long = entry.at("long", default: "")
    let ent-longplural = entry.at("longplural", default: "")

    // Conditions
    let is-first-or-long = __is_first_or_long(here(), key, long: long)
    let has-short = has-short(entry)
    let has-plural = has-plural(entry)
    let has-long = has-long(entry)
    let has-longplural = has-longplural(entry)

    let longplural = if not has-longplural and has-long {
      // Default longplural
      // if the entry long plural is not provided, then fallback to adding default
      // default-plural-suffix
      [#ent-long#default-plural-suffix]
    } else {
      [#ent-longplural]
    }

    let shortplural = if not has-plural {
      // Default short plural
      // if the entry plural is not provided, then fallback to adding default
      // default-plural-suffix
      [#ent-short#default-plural-suffix]
    } else {
      [#ent-plural]
    }

    // Link text
    let link-text = if is-first-or-long and has-long and long != false {
      [#longplural (#shortplural)]
    } else if has-short {
      // Default to short
      [#shortplural]
    } else {
      [#shortplural]
    }

    return __link_and_label(entry.key, link-text)
  }
}

// __gls_attribute(key, attr) -> contextual str|content
// Get the specified attribute from entry
//
// # Arguments
// key (str): the key of the term
// attr (str): the attribute to be retrieved
//
// # Returns
// The attribute of the term
#let __gls_attribute(key, attr, link: false) = (
  context {
    let entry = __get_entry_with_key(here(), key)
    if link {
      return __link_and_label(entry.key, entry.at(attr))
    } else if attr in entry {
      return entry.at(attr)
    } else {
      panic(__error_message(key, __attribute_is_empty, attr: attr))
    }
  }
)

// gls-key(key, link: false) -> str
// Get the key of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The key of the term
#let gls-key(key, link: false) = __gls_attribute(key, "key", link: link)

// gls-short(key, link: false) -> str
// Get the short form of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The short form of the term
#let gls-short(key, link: false) = __gls_attribute(key, "short", link: link)

// gls-artshort(key, link: false) -> str|content
// Get the article of the short form
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The article of the short form
#let gls-artshort(key, link: false) = __gls_attribute(
  key,
  "artshort",
  link: link,
)

// gls-plural(key, link: false) -> str|content
// Get the plural form of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The plural form of the term
#let gls-plural(key, link: false) = __gls_attribute(key, "plural", link: link)

// gls-long(key, link: false) -> str|content
// Get the long form of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The long form of the term
#let gls-long(key, link: false) = __gls_attribute(key, "long", link: link)

// gls-artlong(key, link: false) -> str|content
// Get the article of the long form
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The article of the long form
#let gls-artlong(key, link: false) = __gls_attribute(key, "artlong", link: link)

// gls-longplural(key, link: false) -> str|content
// Get the long plural form of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The long plural form of the term
#let gls-longplural(key, link: false) = __gls_attribute(
  key,
  "longplural",
  link: link,
)

// gls-description(key, link: false) -> str|content
// Get the description of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The description of the term
#let gls-description(key, link: false) = __gls_attribute(
  key,
  "description",
  link: link,
)

// gls-group(key, link: false) -> str
// Get the group of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The group of the term
#let gls-group(key, link: false) = __gls_attribute(key, "group", link: link)

// make-glossary(body) -> content
// Show rule for glossary
//
// # Arguments
//  body (content): whole document
//
// # Usage
// Transform everything
// ```typ
// #show: make-glossary
// ```
#let make-glossary(body) = {
  // Select all figure refs and filter by __glossarium_figure
  // Transform the ref to the glossary term
  show ref: r => {
    if (r.element != none and r.element.func() == figure and r.element.kind == __glossarium_figure) {
      // call to the general citing function
      let key = str(r.target)
      if key.ends-with(":pl") {
        // Plural ref
        glspl(str(key).slice(0, -3))
      } else {
        // Default ref
        gls(str(key), suffix: r.citation.supplement)
      }
    } else {
      r
    }
  }
  body
}

// __normalize_entry_list(entry-list) -> list<dictionary>
// Add default values to each entry.
//
// # Arguments
//  entry-list (list<dictionary>): the list of entries
//
// # Returns
// The normalized entry list
#let __normalize_entry_list(entry-list) = {
  let new-list = ()
  for entry in entry-list {
    if not has-short(entry) and not has-long(entry) {
      panic(__error_message(entry.key, __entry_has_neither_short_nor_long))
    }
    new-list.push((
      key: entry.key,
      short: entry.at("short", default: ""),
      artshort: entry.at("artshort", default: "a"),
      plural: entry.at("plural", default: ""),
      long: entry.at("long", default: ""),
      artlong: entry.at("artlong", default: "a"),
      longplural: entry.at("longplural", default: ""),
      description: entry.at("description", default: ""),
      group: entry.at("group", default: ""),
    ))
  }
  return new-list
}

// get-entry-back-references(entry) -> array<content>
// Get the back references of the entry
//
// # Arguments
// entry (dictionary): the entry
//
// # Returns
// The back references as an array of links
#let get-entry-back-references(entry) = {
  let term-references = __query_labels_with_key(here(), entry.key)
  return term-references
    .map(x => x.location())
    .sorted(key: x => x.page())
    .fold(
      (values: (), pages: ()),
      ((values, pages), x) => {
        if pages.contains(x.page()) {
          // Skip duplicate references
          return (values: values, pages: pages)
        } else {
          // Add the back reference
          values.push(x)
          pages.push(x.page())
          return (values: values, pages: pages)
        }
      },
    )
    .values
    .map(x => {
    let page-numbering = x.page-numbering()
    if page-numbering == none {
      page-numbering = "1"
    }
    return link(x)[#numbering(page-numbering, ..counter(page).at(x))]
  })
}

// count-refs(entry) -> int
// Count the number of references to the entry
//
// # Arguments
// entry (dictionary): the entry
//
// # Returns
// The number of references to the entry
#let count-refs(entry) = {
  let refs = __query_labels_with_key(here(), entry.key)
  return refs.len()
}

// default-print-back-references(entry) -> contextual content
// Print the back references of the entry
//
// # Arguments
// entry (dictionary): the entry
//
// # Returns
// Joined back references
#let default-print-back-references(entry) = {
  return get-entry-back-references(entry).join(", ")
}

// default-print-description(entry) -> content
// Print the description of the entry
//
// # Arguments
// entry (dictionary): the entry
//
// # Returns
// The description of the entry
#let default-print-description(entry) = {
  return entry.at("description")
}

// default-print-title(entry) -> content
// Print the title of the entry
//
// # Arguments
// entry (dictionary): the entry
//
// # Returns
// The title of the entry
#let default-print-title(entry) = {
  let caption = []
  let txt = text.with(weight: 600)

  if has-long(entry) and has-short(entry) {
    caption += txt(emph(entry.short) + [ -- ] + entry.long)
  } else if has-long(entry) {
    caption += txt(entry.long)
  } else {
    caption += txt(emph(entry.short))
  }
  return caption
}

// default-print-gloss(
//  entry,
//  show-all: false,
//  disable-back-references: false,
//  user-print-title: default-print-title,
//  user-print-description: default-print-description,
//  user-print-back-references: default-print-back-references,
// ) -> contextual content
// Print the entry
//
// # Arguments
//  entry (dictionary): the entry
//  show-all (bool): show all entries
//  disable-back-references (bool): disable back references
//  ...
//
// # Returns
//  The gloss content
#let default-print-gloss(
  entry,
  show-all: false,
  disable-back-references: false,
  user-print-title: default-print-title,
  user-print-description: default-print-description,
  user-print-back-references: default-print-back-references,
) = (
  context {
    let caption = []

    if show-all == true or count-refs(entry) != 0 {
      // Title
      caption += user-print-title(entry)

      // Description
      if has-description(entry) {
        // Title - Description separator
        caption += ": "
        caption += user-print-description(entry)
      }

      // Back references
      if disable-back-references != true {
        caption += " "
        caption += user-print-back-references(entry)
      }
    }

    return caption
  }
)

// default-print-reference(
//  entry,
//  show-all: false,
//  disable-back-references: false,
//  user-print-gloss: default-print-gloss,
//  user-print-title: default-print-title,
//  user-print-description: default-print-description,
//  user-print-back-references: default-print-back-references,
// ) -> contextual content
// Print the entry
//
// # Arguments
//  entry (dictionary): the entry
//  show-all (bool): show all entries
//  disable-back-references (bool): disable back references
//  ..;
//
// # Returns
// A glossarium figure+labels
#let default-print-reference(
  entry,
  show-all: false,
  disable-back-references: false,
  user-print-gloss: default-print-gloss,
  user-print-title: default-print-title,
  user-print-description: default-print-description,
  user-print-back-references: default-print-back-references,
) = {
  return [
    #show figure.where(kind: __glossarium_figure): it => if sys.version >= version(0, 12, 0) {
      align(start, it.caption)
    } else {
      it.caption
    }
    #par(
      hanging-indent: 1em,
      first-line-indent: 0em,
    )[
      #figure(
        supplement: "",
        kind: __glossarium_figure,
        numbering: none,
        caption: user-print-gloss(
          entry,
          show-all: show-all,
          disable-back-references: disable-back-references,
          user-print-title: user-print-title,
          user-print-description: user-print-description,
          user-print-back-references: user-print-back-references,
        ),
      )[]#label(entry.key)
      // The line below adds a ref shorthand for plural form, e.g., "@term:pl"
      #figure(
        kind: __glossarium_figure,
        supplement: "",
      )[] #label(entry.key + ":pl")
    ]
    #parbreak()
  ]
}


// default-group-break() -> content
// Default group break
#let default-group-break() = {
  return []
}

// default-print-glossary(
//  entries,
//  groups,
//  show-all: false,
//  disable-back-references: false,
//  user-print-reference: default-print-reference
//  user-group-break: default-group-break,
//  user-print-gloss: default-print-gloss,
//  user-print-title: default-print-title,
//  user-print-description: default-print-description,
//  user-print-back-references: default-print-back-references,
// ) -> contextual content
// Default glossary print function
//
// # Arguments
//  entries (array<dictionary>): the list of entries
//  groups (array<str>): the list of groups
//  show-all (bool): show all entries
//  disable-back-references (bool): disable back references
//  ...
//
// # Warnings
// A strong warning is given not to override `user-print-reference` without
// careful consideration of `default-print-reference`'s original implementation.
// The package's behaviour may break in unexpected ways if not handled correctly.
//
// # Returns
// The glossary content
#let default-print-glossary(
  entries,
  groups,
  show-all: false,
  disable-back-references: false,
  user-print-reference: default-print-reference,
  user-group-break: default-group-break,
  user-print-gloss: default-print-gloss,
  user-print-title: default-print-title,
  user-print-description: default-print-description,
  user-print-back-references: default-print-back-references,
) = {
  let body = []
  let previous-headings = query(selector(heading).before(here()))
  let group-heading-level = 1
  if previous-headings.len() != 0 {
    group-heading-level = previous-headings.last().level
  }
  for group in groups.sorted() {
    let group-entries = entries.filter(x => x.at("group") == group)
    let group-ref-counts = group-entries.map(count-refs)

    let print-group = (group != "" and (show-all == true or group-ref-counts.any(x => x > 0)))

    // Only print group name if any entries are referenced
    if print-group {
      body += [#heading(group, level: group-heading-level)]
    }
    for entry in group-entries.sorted(key: x => x.key) {

      body += user-print-reference(
        entry,
        show-all: show-all,
        disable-back-references: disable-back-references,
        user-print-gloss: user-print-gloss,
        user-print-title: user-print-title,
        user-print-description: user-print-description,
        user-print-back-references: user-print-back-references,
      )
    }

    body += user-group-break()
  }

  return body
}

//  __update_glossary(entries) -> none
// Update the global state glossary
//
// # Arguments
//  entries (array<dictionary>): the list of entries
#let __update_glossary(entries) = {
  __glossary_entries.update(x => {
    for entry in entries {
      if entry.key in entries {
        panic("Duplicate key: " + entry.key)
      }
      x.insert(entry.key, entry)
    }
    return x
  })
}

// register-glossary(entry-list) -> none
// Register the glossary entries
//
// # Arguments
// entries (array<dictionary>): the list of entries
#let register-glossary(entry-list) = {
  if sys.version <= version(0, 11, 1) {
    return
  }
  // Normalize entry-list
  let entries = __normalize_entry_list(entry-list)

  __update_glossary(entries)
}

// print-glossary(
//  entry-list,
//  show-all: false,
//  disable-back-references: false,
//  user-print-glossary: default-print-glossary,
//  user-print-reference: default-print-reference,
//  user-group-break: default-group-break,
//  user-print-gloss: default-print-gloss,
//  user-print-title: default-print-title,
//  user-print-description: default-print-description,
//  user-print-back-references: default-print-back-references,
// ) -> contextual content
// Print the glossary
//
// # Arguments
//  entry-list (list<dictionary>): the list of entries
//  show-all (bool): show all entries
//  disable-back-references (bool): disable back references
//  ...
//
// # Warnings
// A strong warning is given not to override `user-print-reference` without
// careful consideration of `default-print-reference`'s original implementation.
// The package's behaviour may break in unexpected ways if not handled correctly.
//
// # Usage
// Print the glossary
// ```typ
// print-glossary(entry-list)
// ```
#let print-glossary(
  entry-list,
  show-all: false,
  disable-back-references: false,
  user-print-glossary: default-print-glossary,
  user-print-reference: default-print-reference,
  user-group-break: default-group-break,
  user-print-gloss: default-print-gloss,
  user-print-title: default-print-title,
  user-print-description: default-print-description,
  user-print-back-references: default-print-back-references,
) = {
  if entry-list == none {
    panic("entry-list is required")
  }
  let entries = ()
  if sys.version <= version(0, 11, 1) {
    // Normalize entry-list
    entries = __normalize_entry_list(entry-list)

    // Update state
    __update_glossary(entries)
  } else {
    context {
      if __glossary_entries.get().len() == 0 {
        panic(__error_message(none, __glossary_is_empty))
      }
    }
  }

  // Glossary
  let body = []
  body += context {
    let el = if sys.version <= version(0, 11, 1) {
      entries
    } else if entry-list != none {
      __glossary_entries.get().values().filter(x => (x.key in entry-list.map(x => x.key)))
    }
    user-print-glossary(
      el,
      el.map(x => x.at("group")).dedup(),
      show-all: show-all,
      disable-back-references: disable-back-references,
      user-print-reference: user-print-reference,
      user-group-break: user-group-break,
      user-print-gloss: user-print-gloss,
      user-print-title: user-print-title,
      user-print-description: user-print-description,
      user-print-back-references: user-print-back-references,
    )
  }

  // Content
  body
}
