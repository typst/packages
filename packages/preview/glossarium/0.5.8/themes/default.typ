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

// global state containing the entry counts
#let __glossary_counts = state("__glossary_counts", (:))
#let __update_count(key) = {
  __glossary_counts.update(x => {
    x.insert(key, x.at(key, default: 0) + 1)
    return x
  })
}

// glossarium version
#let glossarium_version = "0.5.8"

// error prefix
#let __glossarium_error_prefix = (
  "glossarium@" + glossarium_version + " error : "
)

// Attributes
#let KEY = "key"
#let SHORT = "short"
#let LONG = "long"
#let ART_SHORT = "artshort"
#let ART_LONG = "artlong"
#let PLURAL = "plural"
#let LONG_PLURAL = "longplural"
#let DESCRIPTION = "description"
#let GROUP = "group"
#let SORT = "sort"
#let CUSTOM = "custom"
#let ATTRIBUTES = (
  KEY,
  SHORT,
  LONG,
  ART_SHORT,
  ART_LONG,
  PLURAL,
  LONG_PLURAL,
  DESCRIPTION,
  GROUP,
  SORT,
  CUSTOM,
)


// Errors types
#let __key_not_found = "key_not_found"
#let __key_already_exists = "key_already_exists"
#let __key_capitalization_is_ambiguous = "key_capitalization_is_ambiguous"
#let __attribute_is_empty = "attribute_is_empty"
#let __glossary_is_empty = "glossary_is_empty"
#let __key_not_registered = "key_not_registered"
#let __entry_has_neither_short_nor_long = "entry_has_neither_short_nor_long"
#let __make_glossary_not_called = "make_glossary_not_called"
#let __capitalize_called_with_content_type = "capitalize_called_with_content_type"
#let __entry_has_unknown_keys = "entry_has_unknown_keys"
#let __entry_list_is_not_array = "entry_list_is_not_array"
#let __longplural_but_not_long = "longplural_but_not_long"
#let __style_is_not_a_function = "style_is_not_a_function"
#let __style_unsupported_attributes = "style_unsupported_attributes"
#let __style_unknown_attribute = "style_unknown_attribute"
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
  } else if kind == __key_already_exists {
    msg = "key '" + key + "' already exists in the glossary"
  } else if kind == __key_capitalization_is_ambiguous {
    msg = "key '" + key + "' already exists in the glossary with different capitalization"
  } else if kind == __attribute_is_empty {
    let attr = kwargs.at("attr")
    msg = "requested attribute " + attr + " is empty for key '" + key + "'"
  } else if kind == __glossary_is_empty {
    msg = "glossary is empty. Use `register-glossary(entry-list)` immediately after `make-glossary`."
  } else if kind == __key_not_registered {
    msg = "key '" + key + "' is not registered in the glossary. Use `register-glossary(entry-list)`."
  } else if kind == __entry_has_neither_short_nor_long {
    msg = "entry '" + key + "' has neither short nor long form"
  } else if kind == __make_glossary_not_called {
    msg = "make-glossary not called. Add `#show: make-glossary` at the beginning of the document."
  } else if kind == __capitalize_called_with_content_type {
    msg = (
      "Capitalization was requested for " + key + ", but short or long is of type content. Use a string instead."
    )
  } else if kind == __entry_has_unknown_keys {
    let keys = kwargs.at("keys")
    msg = "entry '" + key + "' has unknown keys: " + keys
  } else if kind == __entry_list_is_not_array {
    msg = "entry-list is not an array."
  } else if kind == __longplural_but_not_long {
    msg = "'" + key + "' has a longplural attribute but no long attribute. Longplural will not be shown."
  } else if kind == __style_is_not_a_function {
    msg = "style-entries: style is not a function. Use a function to style the entries."
  } else if kind == __style_unsupported_attributes {
    let attr = kwargs.at("attr")
    msg = "style-entries: attribute '" + attr + "' is not supported for styling."
    if attr == GROUP {
      msg += " Use `user-print-group-heading` in `print-glossary` to style groups."
    }
  } else if kind == __style_unknown_attribute {
    let attr = kwargs.at("attr")
    msg = "style-entries: unknown attribute '" + attr + "' for styling."
  } else {
    msg = "unknown error"
  }

  // return the error message
  return __glossarium_error_prefix + msg
}

#let default-capitalize(text) = {
  if text == none { return text }
  if type(text) == content {
    panic(__error_message(text, __capitalize_called_with_content_type))
  }
  return upper(text.first()) + text.slice(1)
}
#let __uncapitalize(text) = {
  return lower(text.first()) + text.slice(1)
}

// __query_labels_with_key(loc, key) -> array<label>
// Query the labels with the key
//
// # Arguments
//  loc (location): the location of the reference
//  key (str): the key of the term
//
// # Returns
// The labels with the key
#let __query_labels_with_key(key) = {
  return query(selector(label(__glossary_label_prefix + key)))
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
  let entries = __glossary_entries.at(loc)
  let lowerkey = __uncapitalize(key)
  if key in entries {
    return entries.at(key)
  } else if lowerkey in entries {
    return entries.at(lowerkey)
  } else {
    panic(__error_message(key, __key_not_found))
  }
}

// count-refs(key) -> int
// Count the number of references to the entry in the document
//
// # Arguments
// entry (dictionary): the entry
//
// # Returns
// The number of references to the entry
//
// # Usage
// ```typ
// #context count-refs("potato")
// ```
#let count-refs(key) = {
  return __glossary_counts.final().at(key, default: 0)
}

// count-all-refs(entry-list: none, groups: none) -> array<(str, int)>
// Return the number of references for each entry in the document

// # Arguments
// entry-list (array<dictionary>): the list of entries. Defaults to all entries
// groups (array<str>): the list of groups to be considered. `""` is the default group.
//
// # Returns
// The number of references for each entry across the document
//
// # Usage
// ```typ
// #context count-all-refs()
// ```
#let count-all-refs(entry-list: none, groups: none) = {
  let el = if entry-list == none {
    __glossary_entries.get().values()
  } else {
    entry-list
  }
  let g = if groups == none {
    el.map(x => x.at(GROUP, default: "")).dedup()
  } else if type(groups) == array {
    groups
  } else {
    panic("groups must be an array of strings, e.g., (\"\",)")
  }
  el = el.filter(x => x.at(GROUP, default: "") in g)
  let counts = el.map(x => (x.at(KEY), count-refs(x.at(KEY))))
  return counts
}

// there-are-refs(entry-list: none, groups: none) -> bool
// Check if there are references to the entries in the document
//
// # Arguments
// entry-list (array<dictionary>): the list of entries. Defaults to all entries
// groups (array<str>): the list of groups to be considered. `""` is the default group.
//
// # Returns
// True if there are references to the entries in the document
//
// # Usage
// ```typ
// #context if there-are-refs() {
//   [= Glossary]
// }
// ```
#let there-are-refs(entry-list: none, groups: none) = {
  let counts = count-all-refs(entry-list: entry-list, groups: groups)
  return counts.to-dict().values().any(x => x > 0)
}


// is-first(key) -> bool
// Check if the key is the first reference to the term
//
// # Arguments
//  loc (location): the location of the reference
//  key (str): the key of the term
//
// # Returns
// True if the key is the first reference to the term or long form is requested
#let is-first(key) = {
  return __glossary_counts.get().at(key, default: 0) == 0
}

// __link_and_label(key, text, prefix: none, suffix: none, update: true) -> content
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
#let __link_and_label(key, text, prefix: none, suffix: none, href: true, update: true) = {
  return [#if update { __update_count(key) }#prefix#if href { link(label(key), text) } else { text }#suffix#label(
      __glossary_label_prefix + key,
    )]
}

#let __get_attribute(entry, attrname) = entry.at(attrname)
#let __get_key(entry) = __get_attribute(entry, KEY)
#let __get_short(entry) = __get_attribute(entry, SHORT)
#let __get_long(entry) = __get_attribute(entry, LONG)
#let __get_artshort(entry) = __get_attribute(entry, ART_SHORT)
#let __get_artlong(entry) = __get_attribute(entry, ART_LONG)
#let __get_plural(entry) = __get_attribute(entry, PLURAL)
#let __get_longplural(entry) = __get_attribute(entry, LONG_PLURAL)
#let __get_description(entry) = __get_attribute(entry, DESCRIPTION)
#let __get_group(entry) = __get_attribute(entry, GROUP)
#let __get_sort(entry) = __get_attribute(entry, SORT)
#let __get_custom(entry) = __get_attribute(entry, CUSTOM)

#let __has_attribute(entry, attrname) = {
  let attr = __get_attribute(entry, attrname)
  return attr != none and attr != "" and attr != []
}
#let has-short(entry) = __has_attribute(entry, SHORT)
#let has-long(entry) = __has_attribute(entry, LONG)
#let has-artshort(entry) = __has_attribute(entry, ART_SHORT)
#let has-artlong(entry) = __has_attribute(entry, ART_LONG)
#let has-plural(entry) = __has_attribute(entry, PLURAL)
#let has-longplural(entry) = __has_attribute(entry, LONG_PLURAL)
#let has-description(entry) = __has_attribute(entry, DESCRIPTION)
#let has-group(entry) = __has_attribute(entry, GROUP)
#let has-sort(entry) = __has_attribute(entry, SORT)
#let has-custom(entry) = __has_attribute(entry, CUSTOM)

#let _get-attribute(key, attrname, link: false, update: false) = {
  let entry = __get_entry_with_key(here(), key)
  let attr = entry.at(attrname)
  if link {
    return __link_and_label(entry.at(KEY), entry.at(attrname), update: update)
  } else if attrname in entry and entry.at(attrname) != none {
    return attr
  } else {
    panic(__error_message(key, __attribute_is_empty, attr: attrname))
  }
}
// get-attribute(key, attr) -> contextual content
// Get the specified attribute from entry
//
// # Arguments
// key (str): the key of the term
// attr (str): the attribute to be retrieved
//
// # Returns
// The attribute of the term
#let get-attribute(key, attrname, link: false, update: false, ctx: true) = {
  let call = () => _get-attribute(
    key,
    attrname,
    link: link,
    update: update,
  )
  if ctx {
    return context call()
  } else {
    return call()
  }
}

// gls-key(key, link: false) -> contextual content
// Get the key of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The key of the term
#let gls-key(key, link: false, update: false, ctx: true) = get-attribute(key, KEY, link: link, update: update, ctx: ctx)

// gls-short(key, link: false) -> contextual content
// Get the short form of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The short form of the term
#let gls-short(key, link: false, update: false, ctx: true) = get-attribute(
  key,
  SHORT,
  link: link,
  update: update,
  ctx: ctx,
)

// gls-artshort(key, link: false) -> contextual content
// Get the article of the short form
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The article of the short form
#let gls-artshort(key, link: false, update: false, ctx: true) = get-attribute(
  key,
  ART_SHORT,
  link: link,
  update: update,
  ctx: ctx,
)

// gls-plural(key, link: false) -> contextual content
// Get the plural form of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The plural form of the term
#let gls-plural(key, link: false, update: false, ctx: true) = get-attribute(
  key,
  PLURAL,
  link: link,
  update: update,
  ctx: ctx,
)

// gls-long(key, link: false) -> contextual content
// Get the long form of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The long form of the term
#let gls-long(key, link: false, update: false, ctx: true) = get-attribute(
  key,
  LONG,
  link: link,
  update: update,
  ctx: ctx,
)

// gls-artlong(key, link: false) -> contextual content
// Get the article of the long form
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The article of the long form
#let gls-artlong(key, link: false, update: false, ctx: true) = get-attribute(
  key,
  ART_LONG,
  link: link,
  update: update,
  ctx: ctx,
)

// gls-longplural(key, link: false) -> contextual content
// Get the long plural form of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The long plural form of the term
#let gls-longplural(key, link: false, update: false, ctx: true) = get-attribute(
  key,
  LONG_PLURAL,
  link: link,
  update: update,
  ctx: ctx,
)

// gls-description(key, link: false) -> contextual content
// Get the description of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The description of the term
#let gls-description(key, link: false, update: false, ctx: true) = get-attribute(
  key,
  DESCRIPTION,
  link: link,
  update: update,
  ctx: ctx,
)

// gls-group(key, link: false) -> contextual content
// Get the group of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The group of the term
#let gls-group(key, link: false, update: false, ctx: true) = get-attribute(
  key,
  GROUP,
  link: link,
  update: update,
  ctx: ctx,
)

//
// gls-sort(key, link: false) -> contextual content
// Get the sort of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary
//
// # Returns
// The sort attribute of the term
#let gls-sort(key, link: false, update: false, ctx: true) = get-attribute(
  key,
  SORT,
  link: link,
  update: update,
  ctx: ctx,
)

// gls-custom(key, link: false, update: false, ctx: true) -> user-defined content
// Get the custom attribute of the term
//
// # Arguments
//  key (str): the key of the term
//  link (bool): enable link to glossary. Only works with content types for custom
//  update (bool): update the entry count
//  ctx (bool): whether to use a context inside this function when accessing the entry.
//              If true, this function can be called as is but returns a content type.
//              To access members of e.g. a dictionary stored in the custom attribute, the user
//              needs to use their own context. Usage (custom is a dictionary with member 'unit'):
//              ```typst
//              #context gls-custom("c").unit
//              ```
//
// # Returns
// The custom attribute of the term
#let gls-custom(key, link: false, update: false, ctx: true) = get-attribute(
  key,
  CUSTOM,
  link: link,
  update: update,
  ctx: ctx,
)

// Check capitalization of user input (@ref, or @Ref) against real key
#let is-upper(key) = key.at(0) != __get_key(__get_entry_with_key(here(), key)).at(0)

#let _style-entries(attr, style) = {
  if type(style) != function {
    panic(__error_message(none, __style_is_not_a_function))
  }
  if attr in (KEY, SORT, GROUP) {
    panic(__error_message(none, __style_unsupported_attributes, attr: attr))
  }
  if attr not in ATTRIBUTES {
    panic(__error_message(none, __style_unknown_attribute, attr: attr))
  }
  __glossary_entries.update(x => {
    for (k, v) in x.pairs() {
      v.insert(attr, style(v.at(attr, default: none)))
      x.insert(k, v)
    }
    return x
  })
}

// style-entries(entry-list, attr, style) -> array<dictionary>
#let style-entries(attr, style) = context _style-entries(attr, style)

#let default-plural(text) = {
  return text + "s"
}

#let _gls(
  key,
  suffix: none,
  long: none,
  display: none,
  link: true,
  update: true,
  capitalize: false,
  plural: false,
  article: false,
  user-capitalize: default-capitalize,
  user-plural: default-plural,
) = {
  let entry = __get_entry_with_key(here(), key)

  // Attributes
  let ent-short = __get_short(entry)
  let ent-long = __get_long(entry)
  let ent-plural = __get_plural(entry)
  let ent-longplural = __get_longplural(entry)
  let artlong = __get_artlong(entry)
  let artshort = __get_artshort(entry)
  if capitalize {
    ent-short = user-capitalize(ent-short)
    ent-long = user-capitalize(ent-long)
    ent-plural = user-capitalize(ent-plural)
    ent-longplural = user-capitalize(ent-longplural)
    artlong = user-capitalize(artlong)
    artshort = user-capitalize(artshort)
  }

  // Conditions
  let is-first = is-first(entry.at(KEY))
  let has-short = has-short(entry)
  let has-long = has-long(entry)
  let has-plural = has-plural(entry)
  let has-longplural = has-longplural(entry)
  let eshort = ent-short
  let elong = ent-long
  if plural {
    eshort = if has-plural {
      ent-plural
    } else {
      user-plural(ent-short)
    }
    elong = if has-longplural {
      ent-longplural
    } else if has-long {
      user-plural(ent-long)
    }
  }
  eshort += suffix

  // Priority order:
  //  1. `gls(key, display: "text")` will return `text`
  //  2. `gls(key, long: false)` will return `short+suffix`
  //  3. The first ref will return `long (short+suffix)` if has-long
  //  4. `gls(key, long: true)` will return `long (short+suffix)` or `long` if has-long
  //  5. `gls(key)` will return `short+suffix`
  let text = if display != none {
    // 1. display
    [#display]
  } else if long == false {
    // 2. Always use short+suffix if long: false, even on first appearance
    [#eshort]
  } else if (is-first or long == true) and has-long {
    // 3 & 4. long (short+suffix) (first or long requested, and has long form)
    if has-short {
      [#elong (#eshort)]
    } else {
      [#elong]
    }
  } else {
    // 5. fallback to short+suffix
    [#eshort]
  }
  let art = if long == false {
    artshort
  } else if (is-first or long == true) and has-long {
    artlong
  } else {
    artshort
  }

  if article {
    text = [#art #text]
  }
  return __link_and_label(entry.at(KEY), text, href: link, update: update)
}
// gls(key, suffix: none, long: none, display: none) -> contextual content
// Reference to term
//
// # Arguments
//  key (str): the key of the term
//  suffix (str): the suffix to be added to the short form
//  long (bool): enable/disable the long form
//  display (str): override text to be displayed
//  capitalize (bool): Capitalize first letter of long form
//
// # Returns
// The link and the entry label
#let gls(
  key,
  suffix: none,
  long: none,
  display: none,
  link: true,
  update: true,
  capitalize: false,
  plural: false,
  article: false,
  user-capitalize: default-capitalize,
  user-plural: default-plural,
) = context _gls(
  key,
  suffix: suffix,
  long: long,
  display: display,
  link: link,
  update: update,
  capitalize: capitalize,
  plural: plural,
  article: article,
  user-capitalize: user-capitalize,
  user-plural: user-plural,
)

// gls(key, suffix: none, long: none, display: none) -> contextual content
// Reference to term, capitalized
#let Gls(
  key,
  suffix: none,
  long: none,
  display: none,
  link: true,
  update: true,
  user-capitalize: default-capitalize,
  user-plural: default-plural,
) = gls(
  key,
  suffix: suffix,
  long: long,
  display: display,
  link: link,
  update: update,
  capitalize: true,
  user-capitalize: user-capitalize,
  user-plural: user-plural,
)

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
#let agls(
  key,
  suffix: none,
  long: none,
  display: none,
  link: true,
  update: true,
  capitalize: false,
  user-capitalize: default-capitalize,
  user-plural: default-plural,
) = gls(
  key,
  suffix: suffix,
  long: long,
  display: display,
  link: link,
  update: update,
  capitalize: capitalize,
  article: true,
  user-capitalize: user-capitalize,
  user-plural: user-plural,
)
#let Agls(
  key,
  suffix: none,
  long: none,
  display: none,
  link: true,
  update: true,
  user-capitalize: default-capitalize,
  user-plural: default-plural,
) = gls(
  key,
  suffix: suffix,
  long: long,
  display: display,
  link: link,
  update: update,
  capitalize: true,
  article: true,
  user-capitalize: user-capitalize,
  user-plural: user-plural,
)

// glspl(key, long: false) -> content
// Reference to term with plural form
//
// # Arguments
//  key (str): the key of the term
//  long (bool): enable/disable the long form
//  capitalize (bool): Capitalize first letter of long form
//
// # Returns
// The link and the entry label
#let glspl(
  key,
  suffix: none,
  long: none,
  display: none,
  link: true,
  update: true,
  capitalize: false,
  user-capitalize: default-capitalize,
  user-plural: default-plural,
) = gls(
  key,
  long: long,
  suffix: suffix,
  display: display,
  link: link,
  update: update,
  capitalize: capitalize,
  plural: true,
  user-capitalize: user-capitalize,
  user-plural: user-plural,
)

// glspl(key, long: none) -> content
// Reference to term with plural form, capitalized
#let Glspl(
  key,
  suffix: none,
  long: none,
  display: none,
  link: true,
  update: true,
  user-capitalize: default-capitalize,
  user-plural: default-plural,
) = gls(
  key,
  long: long,
  suffix: suffix,
  display: display,
  link: link,
  update: update,
  capitalize: true,
  plural: true,
  user-capitalize: user-capitalize,
  user-plural: user-plural,
)

// Select all figure refs and filter by __glossarium_figure
//
// Transform the ref to the glossary term
#let refrule(
  r,
  update: true,
  long: none,
  link: true,
  user-capitalize: default-capitalize,
  user-plural: default-plural,
) = {
  if (
    r.element != none and r.element.func() == figure and r.element.kind == __glossarium_figure
  ) {
    let position = r.element.location()
    // call to the general citing function
    let key = str(r.target)
    if key.ends-with(":pl") {
      key = key.slice(0, -3)
      // Plural ref
      return glspl(
        key,
        update: update,
        link: link,
        long: long,
        capitalize: is-upper(key),
        user-capitalize: user-capitalize,
        user-plural: user-plural,
      )
    } else {
      // Default ref
      return gls(
        key,
        update: update,
        link: link,
        long: long,
        capitalize: is-upper(key),
        user-capitalize: user-capitalize,
        user-plural: user-plural,
      )
    }
  } else {
    return r
  }
}

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
#let make-glossary(
  body,
  link: true,
  always-long: none,
  user-capitalize: default-capitalize,
  user-plural: default-plural,
) = {
  [#metadata("glossarium:make-glossary")<glossarium:make-glossary>]
  // Set figure body alignement
  show figure.where(kind: __glossarium_figure): it => {
    align(start, it.body)
  }
  show ref: refrule.with(link: link, long: always-long, user-capitalize: user-capitalize, user-plural: user-plural)
  body
}

// __normalize_entry_list(entry-list) -> array<dictionary>
// Add default values to each entry.
//
// # Arguments
//  entry-list (array<dictionary>): the list of entries
//  use-key-as-short (bool): flag to use the key as the short form
//
// # Returns
// The normalized entry list
#let __normalize_entry_list(entry-list, use-key-as-short: true) = {
  let new-list = ()
  for entry in entry-list {
    let unknown_keys = entry.keys().filter(x => (x not in ATTRIBUTES))
    if unknown_keys.len() > 0 {
      panic(__error_message(entry.at(KEY), __entry_has_unknown_keys, keys: unknown_keys.join(",")))
    }
    let newentry = (
      key: entry.at(KEY),
      short: entry.at(SHORT, default: if use-key-as-short { entry.at(KEY) } else { none }),
      artshort: entry.at(ART_SHORT, default: "a"),
      plural: entry.at(PLURAL, default: none),
      long: entry.at(LONG, default: none),
      artlong: entry.at(ART_LONG, default: "a"),
      longplural: entry.at(LONG_PLURAL, default: none),
      description: entry.at(DESCRIPTION, default: none),
      group: entry.at(GROUP, default: ""),
      sort: entry.at(SORT, default: entry.at(KEY)),
      custom: entry.at(CUSTOM, default: none),
    )
    if not use-key-as-short and not has-short(newentry) and not has-long(newentry) {
      panic(__error_message(newentry.at(KEY), __entry_has_neither_short_nor_long))
    }
    if has-longplural(newentry) and not has-long(newentry) {
      panic(__error_message(newentry.at(KEY), __longplural_but_not_long))
    }
    new-list.push(newentry)
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
#let get-entry-back-references(entry, deduplicate: false) = {
  let term-references = __query_labels_with_key(entry.at(KEY))
  let back-references = term-references.map(x => x.location()).sorted(key: x => x.page())
  if deduplicate {
    back-references = back-references
      .fold((values: (), pages: ()), ((values, pages), x) => {
        if pages.contains(x.page()) {
          // Skip duplicate references
          return (values: values, pages: pages)
        } else {
          // Add the back reference
          values.push(x)
          pages.push(x.page())
          return (values: values, pages: pages)
        }
      })
      .values
  }
  return back-references.map(x => {
    let page-numbering = x.page-numbering()
    if page-numbering == none {
      page-numbering = "1"
    }
    return link(x)[#numbering(page-numbering, ..counter(page).at(x))]
  })
}

// default-print-back-references(entry) -> content
// Print the back references of the entry
//
// # Arguments
// entry (dictionary): the entry
//
// # Returns
// Joined back references
#let default-print-back-references(entry, deduplicate: false) = {
  return get-entry-back-references(entry, deduplicate: deduplicate).join(", ")
}

// default-print-description(entry) -> content
// Print the description of the entry
//
// # Arguments
// entry (dictionary): the entry
//
// # Returns
// The description of the entry
#let default-print-description(entry) = entry.at(DESCRIPTION)

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
  let txt = strong.with(delta: 200)

  if has-long(entry) and has-short(entry) {
    caption += txt(emph(entry.at(SHORT)) + [ -- ] + entry.at(LONG))
  } else if has-long(entry) {
    caption += txt(entry.at(LONG))
  } else {
    caption += txt(emph(entry.at(SHORT)))
  }
  return caption
}

// default-print-gloss(
//  entry,
//  show-all: false,
//  disable-back-references: false,
//  deduplicate-back-references: false,
//  minimum-refs: 1,
//  description-separator: ": ",
//  user-print-title: default-print-title,
//  user-print-description: default-print-description,
//  user-print-back-references: default-print-back-references,
// ) -> content
// Print the entry
//
// # Arguments
//  entry (dictionary): the entry
//  show-all (bool): show all entries
//  disable-back-references (bool): disable back references
//  minimum-refs (int): minimum number of references to show the entry
//  ...
//
// # Returns
//  The gloss content
#let default-print-gloss(
  entry,
  show-all: false,
  disable-back-references: false,
  deduplicate-back-references: false,
  minimum-refs: 1,
  description-separator: ": ",
  user-print-title: default-print-title,
  user-print-description: default-print-description,
  user-print-back-references: default-print-back-references,
) = {
  set par(
    hanging-indent: 1em,
    first-line-indent: 0em,
  )
  // ? references-in-description layout divergence
  if show-all == true or count-refs(entry.at(KEY)) >= minimum-refs {
    // Title
    user-print-title(entry)

    // Description
    if has-description(entry) {
      // Title - Description separator
      description-separator
      user-print-description(entry)
    }

    // Back references
    // Separate context window to separate BR's query
    context if disable-back-references != true {
      " "
      user-print-back-references(entry, deduplicate: deduplicate-back-references)
    }
  }
}


// default-print-reference(
//  entry,
//  show-all: false,
//  disable-back-references: false,
//  deduplicate-back-references: false,
//  minimum-refs: 1,
//  description-separator: ": ",
//  user-print-gloss: default-print-gloss,
//  user-print-title: default-print-title,
//  user-print-description: default-print-description,
//  user-print-back-references: default-print-back-references,
// ) -> content
// Print the entry
//
// # Arguments
//  entry (dictionary): the entry
//  show-all (bool): show all entries
//  disable-back-references (bool): disable back references
//  minimum-refs (int): minimum number of references to show the entry
//  ..;
//
// # Returns
// A glossarium figure+labels
#let default-print-reference(
  entry,
  show-all: false,
  disable-back-references: false,
  deduplicate-back-references: false,
  minimum-refs: 1,
  description-separator: ": ",
  user-print-gloss: default-print-gloss,
  user-print-title: default-print-title,
  user-print-description: default-print-description,
  user-print-back-references: default-print-back-references,
) = [
  #figure(supplement: "", kind: __glossarium_figure, numbering: none, user-print-gloss(
    entry,
    show-all: show-all,
    disable-back-references: disable-back-references,
    deduplicate-back-references: deduplicate-back-references,
    minimum-refs: minimum-refs,
    description-separator: description-separator,
    user-print-title: user-print-title,
    user-print-description: user-print-description,
    user-print-back-references: user-print-back-references,
  ))#label(entry.at(KEY))
  // The line below adds a ref shorthand for plural form, e.g., "@term:pl"
  #figure(
    kind: __glossarium_figure,
    supplement: "",
  )[]#label(entry.at(KEY) + ":pl")
  // Same as above, but for capitalized form, e.g., "@Term"
  // Skip if key is already capitalized
  #if upper(entry.at(KEY).at(0)) != entry.at(KEY).at(0) {
    [
      #figure(
        kind: __glossarium_figure,
        supplement: "",
      )[]#label(default-capitalize(entry.at(KEY)))
      #figure(
        kind: __glossarium_figure,
        supplement: "",
      )[]#label(default-capitalize(entry.at(KEY)) + ":pl")
    ]
  }
]

// default-group-break() -> content
// Default group break
#let default-group-break() = {
  return []
}

#let default-print-group-heading(group, level: none) = {
  if level == none {
    let previous-headings = query(selector(heading).before(here()))
    if previous-headings.len() != 0 {
      level = previous-headings.last().level + 1
    } else {
      level = 1
    }
  }
  heading(group, level: level, outlined: false)
}

// default-print-glossary(
//  entries,
//  groups,
//  show-all: false,
//  disable-back-references: false,
//  group-heading-level: none,
//  minimum-refs: 1,
//  description-separator: ": ",
//  group-sortkey: g => g,
//  entry-sortkey: e => e.at(SORT),
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
//  deduplicate-back-references (bool): deduplicate back references
//  group-heading-level (int): force the level of the group heading
//  minimum-refs (int): minimum number of references to show the entry
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
  deduplicate-back-references: false,
  group-heading-level: none,
  minimum-refs: 1,
  description-separator: ": ",
  group-sortkey: g => g,
  entry-sortkey: e => e.at(SORT),
  user-print-group-heading: default-print-group-heading,
  user-print-reference: default-print-reference,
  user-group-break: default-group-break,
  user-print-gloss: default-print-gloss,
  user-print-title: default-print-title,
  user-print-description: default-print-description,
  user-print-back-references: default-print-back-references,
) = {
  for group in groups.sorted(key: group-sortkey) {
    let group-entries = entries.filter(x => x.at(GROUP) == group)
    let group-ref-counts = group-entries.map(x => count-refs(x.at(KEY)))
    let print-group = (
      // ? group-heading-pagebreak Layout divergence if location is conditional on print-group
      group != "" and (show-all == true or group-ref-counts.any(x => x >= minimum-refs))
    )
    // Only print group name if any entries are referenced
    if print-group {
      user-print-group-heading(group, level: group-heading-level)
    }
    for entry in group-entries.sorted(key: entry-sortkey) {
      user-print-reference(
        entry,
        show-all: show-all,
        disable-back-references: disable-back-references,
        deduplicate-back-references: deduplicate-back-references,
        minimum-refs: minimum-refs,
        description-separator: description-separator,
        user-print-gloss: user-print-gloss,
        user-print-title: user-print-title,
        user-print-description: user-print-description,
        user-print-back-references: user-print-back-references,
      )
    }
    if print-group {
      user-group-break()
    }
  }
}

// __check_keys(entry-list) -> none
// Check for ambiguosity of the keys and in existing keys from previously registered glossaries
#let __check_keys(entries) = {
  let keys = __glossary_entries.get().keys()
  let new_keys = entries.map(x => x.at(KEY))
  let lowered_keys = __glossary_entries.get().keys().map(lower)
  let lowered_new_keys = entries.map(x => lower(x.at(KEY)))

  for (i, key) in new_keys.enumerate() {
    if (key in keys) or (key in new_keys.slice(0, i)) {
      panic(__error_message(key, __key_already_exists))
    }
    let l = lower(key)
    if l in lowered_keys or l in lowered_new_keys.slice(0, i) {
      panic(__error_message(key, __key_capitalization_is_ambiguous))
    }
  }
}

//  __update_glossary(entries) -> none
// Update the global state glossary
//
// # Arguments
//  entries (array<dictionary>): the list of entries
#let __update_glossary(entries) = {
  __glossary_entries.update(x => {
    for entry in entries {
      x.insert(entry.at(KEY), entry)
    }
    return x
  })
}

#let _register-glossary(entry-list, use-key-as-short: true) = {
  if type(entry-list) != array {
    panic(__error_message(none, __entry_list_is_not_array))
  }
  // Normalize entry-list
  let entries = __normalize_entry_list(
    entry-list,
    use-key-as-short: use-key-as-short,
  )

  __check_keys(entries)

  __update_glossary(entries)
}
// register-glossary(entry-list, use-key-as-short: true) -> none
// Register the glossary entries
//
// # Arguments
//  entries (array<dictionary>): the list of entries
//  use-key-as-short (bool): flag to use the key as the short form
#let register-glossary(entry-list, use-key-as-short: true) = context _register-glossary(
  entry-list,
  use-key-as-short: use-key-as-short,
)

#let _print-glossary(
  entry-list,
  groups: (),
  show-all: false,
  disable-back-references: false,
  deduplicate-back-references: false,
  group-heading-level: none,
  minimum-refs: 1,
  description-separator: ": ",
  group-sortkey: g => g,
  entry-sortkey: e => e.at(SORT),
  user-print-glossary: default-print-glossary,
  user-print-group-heading: default-print-group-heading,
  user-print-reference: default-print-reference,
  user-group-break: default-group-break,
  user-print-gloss: default-print-gloss,
  user-print-title: default-print-title,
  user-print-description: default-print-description,
  user-print-back-references: default-print-back-references,
) = {
  {
    if query(<glossarium:make-glossary>).len() == 0 {
      panic(__error_message(none, __make_glossary_not_called))
    }
  }
  if entry-list == none {
    panic("entry-list is required")
  }
  if type(groups) != array {
    panic("groups must be an array")
  }

  let entries = __glossary_entries.get()
  if entries.len() == 0 {
    panic(__error_message(none, __glossary_is_empty))
  } else {
    for e in entry-list {
      if e.at(KEY) not in entries {
        panic(__error_message(e.at(KEY), __key_not_registered))
      }
    }
  }

  // Glossary
  let body = []
  body += {
    show ref: refrule.with(update: false)

    // Entries
    let el = __glossary_entries
      .get()
      .values()
      .filter(x => (
        x.at(KEY) in entry-list.map(x => x.at(KEY))
      ))

    // Groups
    let g = if groups == () {
      el.map(x => x.at(GROUP)).dedup()
    } else {
      groups
    }
    user-print-glossary(
      el,
      g,
      show-all: show-all,
      disable-back-references: disable-back-references,
      deduplicate-back-references: deduplicate-back-references,
      group-heading-level: group-heading-level,
      minimum-refs: minimum-refs,
      description-separator: description-separator,
      group-sortkey: group-sortkey,
      entry-sortkey: entry-sortkey,
      user-print-reference: user-print-reference,
      user-print-group-heading: user-print-group-heading,
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
// print-glossary(
//  entry-list,
//  groups: (),
//  show-all: false,
//  disable-back-references: false,
//  deduplicate-back-references: false,
//  group-heading-level: none,
//  minimum-refs: 1,
//  description-separator: ": ",
//  group-sortkey: g => g,
//  entry-sortkey: e => e.at(SORT),
//  user-print-glossary: default-print-glossary,
//  user-print-group-heading: default-print-group-heading,
//  user-print-reference: default-print-reference,
//  user-group-break: default-group-break,
//  user-print-gloss: default-print-gloss,
//  user-print-title: default-print-title,
//  user-print-description: default-print-description,
//  user-print-back-references: default-print-back-references,
// ) -> content
// Print the glossary
//
// # Arguments
//  entry-list (array<dictionary>): the list of entries
//  groups (array<str>): the list of groups to be displayed. `""` is the default group.
//  show-all (bool): show all entries
//  disable-back-references (bool): disable back references
//  group-heading-level (int): force the level of the group heading
//  minimum-refs (int): minimum number of references to show the entry
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
  groups: (),
  show-all: false,
  disable-back-references: false,
  deduplicate-back-references: false,
  group-heading-level: none,
  minimum-refs: 1,
  description-separator: ": ",
  group-sortkey: g => g,
  entry-sortkey: e => e.at(SORT),
  user-print-glossary: default-print-glossary,
  user-print-group-heading: default-print-group-heading,
  user-print-reference: default-print-reference,
  user-group-break: default-group-break,
  user-print-gloss: default-print-gloss,
  user-print-title: default-print-title,
  user-print-description: default-print-description,
  user-print-back-references: default-print-back-references,
) = context _print-glossary(
  entry-list,
  groups: groups,
  show-all: show-all,
  disable-back-references: disable-back-references,
  deduplicate-back-references: deduplicate-back-references,
  group-heading-level: group-heading-level,
  minimum-refs: minimum-refs,
  description-separator: description-separator,
  group-sortkey: group-sortkey,
  entry-sortkey: entry-sortkey,
  user-print-glossary: user-print-glossary,
  user-print-group-heading: user-print-group-heading,
  user-print-reference: user-print-reference,
  user-group-break: user-group-break,
  user-print-gloss: user-print-gloss,
  user-print-title: user-print-title,
  user-print-description: user-print-description,
  user-print-back-references: user-print-back-references,
)
