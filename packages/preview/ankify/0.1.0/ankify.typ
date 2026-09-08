// See the file LICENSE for the full license governing this code.

// Use Valkyrie for type validation
#import "@preview/valkyrie:0.2.2" as z

#import "util/schemas.typ": configuration-schema, default-configuration, note-schema
#import "util/merge.typ": merge

// ⚠ Warning: For Ankify-internal use only! Not part of the public API. (It
// still has to be exported for technical reasons, hence its visibility to the
// user.)
//
// State to hold Ankify notes.
#let __ankify-notes = state("ankify-notes", ())

// ⚠ Warning: For Ankify-internal use only! Not part of the public API. (It
// still has to be exported for technical reasons, hence its visibility to the
// user.)
//
// State to hold Ankify configuration.
#let __ankify-configuration = state("ankify-configuration", default-configuration)

/// Ankify Typst Extension
///
/// This file provides functions for creating Anki cards and configuring
/// the Ankify CLI tool from within Typst documents.
///
/// ## Usage
///
/// ```typst
/// #import "ankify.typ": note, configure
///
/// // Configure Ankify settings
/// #configure(
///   ankiconnect-url: "http://127.0.0.1:8765",
///   verbose: true,
///   defaults: (
///     model: "Basic",
///     deck: "MyDeck",
///     tags: ("study", "typst")
///   )
/// )
///
/// // Create cards
/// #note(
///   "pythagorean-theorem",
///   model: "Basic",
///   data: (
///     Front: "What is the Pythagorean theorem?",
///     Back: [$a^2 + b^2 = c^2$]
///   ),
///   deck: "Mathematics",
///   tags: ("geometry", "theorem"),
///   format: "svg"
/// )
/// ```

#let filter-content(data) = {
  let data-without-content = (:)
  for (k, v) in data {
    if (type(v) == content) {
      data-without-content.insert(k, "")
    } else if (type(v) == dictionary) {
      // Recursively filter content in nested dictionaries
      let filtered-dict = (:)
      for (nested-k, nested-v) in v {
        if (type(nested-v) == content) {
          filtered-dict.insert(nested-k, "")
        } else {
          filtered-dict.insert(nested-k, nested-v)
        }
      }
      data-without-content.insert(k, filtered-dict)
    } else {
      data-without-content.insert(k, v)
    }
  }
  return data-without-content
}

// Create a note.
//
// *Note:* This function creates a note which is visible to Ankify, but which
// won't be visible in the document itself. Accordingly, this function is
// ideally called within some user-defined function that is used to create some
// content that should have an Anki note attached to it.
//
// = Examples
//
// ```typst
// #let theorem(label, name, statement) = {
//   #note(label, data: (Front: name, Back: statement), deck: "Theorems", tags: ("theorem"))
//   [*Theorem (#name).* #statement]
// }
//
// #theorem(
//   "pythagorean-theorem",
//   "Pythagorean Theorem",
//   [If $a$ and $b$ are the legs of a right triangle, and $c$ is the hypotenuse, then $a^2 + b^2 = c^2$.]
// )
// ```
//
// ---
//
// - note-label (str): _(Required)_ Note label, used as a unique identifier.
//
// - data (dictionary): Dictionary of field names to content, strings, or
//   dictionaries.
//
//   _Default:_ `none`
//
// - model (str): Anki note type.
//
//   _Default:_ `"Basic"`
//
// - deck (str): Anki deck name.
//
//   _Default:_ `"Default"`
//
// - tags (array): Array of tags (strings) to apply.
//
//   _Default:_ `()` (empty array)
//
// - other (dictionary): Additional metadata to pass to AnkiConnect.
//
//   _Default:_ `none`
//
// - format (str): Rendering format (`"png"`, `"svg"`, `"plain"`).
//
//   _Default:_ `"svg"`
//
// - render (function): Function to render the note content. Its signature is
//   `(note: dictionary, field: str, field-content: content | str) => content`,
//   where the named parameter `field-content` receives the content of the field
//   in question and is made available for the user's convenience.
//
//   _Default:_ `(field-content: []) => { field-content }`
//
// -> content
#let note(
  note-label,
  data: none,
  model: none,
  deck: none,
  tags: none,
  other: none,
  format: none,
  render: none,
) = {
  context {
    let note-object = (
      label: note-label,
      data: data,
      model: model,
      tags: tags,
      deck: deck,
      other: other,
      format: format,
    )

    note-object = merge(
      __ankify-configuration.get().defaults,
      note-object,
    )

    // Structural invariants — always enforced, even when `checks.typst` is
    // disabled: a card is meaningless without a non-empty label and at least
    // one data field.
    assert(
      type(note-object.label) == str and note-object.label.len() > 0,
      message: "note() requires a non-empty string label",
    )
    assert(
      type(note-object.data) == dictionary and note-object.data.len() > 0,
      message: "note '" + note-object.label + "' requires a non-empty `data` dictionary",
    )

    let checks = __ankify-configuration.get().checks

    if (checks.typst) {
      note-object = z.parse(note-object, note-schema)
    }

    // Emit the note as document metadata for the CLI to query. `render` is
    // dropped — it is a function, so it would serialise to a useless
    // placeholder; the renderer reads it from document state instead.
    let metadata-note = (
      label: note-object.label,
      data: filter-content(note-object.data),
      model: note-object.model,
      deck: note-object.deck,
      tags: note-object.tags,
      other: note-object.other,
      format: note-object.format,
    )
    [#metadata(metadata-note) <ankify-note>]

    // Return both the update (which places the state change) and the content
    [
      #__ankify-notes.update(notes => {
        notes.push(note-object)
        notes
      })
    ]
  }
}


// Configure Ankify.
//
// `configure()` may be called more than once. Each call merges into the
// running configuration: only the parameters you pass take effect, and
// everything else is left untouched. Dictionary parameters (`defaults`,
// `cache`, `checks`) merge key by key, so a later call can adjust a single
// nested setting without resetting its siblings.
//
// = Examples
//
// ```typst
// #configure(
//   ankiconnect-url: "http://127.0.0.1:8765",
//   setup: body => {
//     set page(fill: rgb("#111"))
//     body
//   }
// )
// ```
//
// ---
//
// - ankiconnect-url (str): URL for AnkiConnect API.
//
//   _Default:_ `"http://127.0.0.1:8765"`
//
// - verbose (bool): Enable verbose output.
//
//   _Default:_ `false`
//
// - scale (int | float): Factor by which every rendered card image is
//   enlarged. `1.0` renders at natural size; the default `1.5` makes cards
//   larger and easier to read. Increase it further if your cards still look
//   too small.
//
//   _Default:_ `1.5`
//
// - defaults (dictionary): Default values for notes.
//
//   - `model` (`str`): Default note type.
//
//     _Default:_ `"Basic"`
//
//   - `deck` (`str`): Default deck name.
//
//     _Default:_ `"Default"`
//
//   - `format` (`str`): Default rendering format (`"png"`, `"svg"`, `"plain"`).
//
//     _Default:_ `"png"`
//
//   - `tags` (`array`): Default tags (strings) to apply.
//
//     _Default:_ `()` (empty array)
//
//   - `other` (`dictionary`): Additional metadata to pass to AnkiConnect.
//
//     _Default:_ `none`
//
//   - `render` (function): Function to render the note content. Its signature is
//     `(note: dictionary, field: str, field-content: content | str) => content`,
//     where the named parameter `field-content` receives the content of the field
//     in question and is made available for the user's convenience.
//
//     _Default:_
//     ```typ
//     (note: none, field: none, field-content: none) => { field-content }
//     ```
//
//     *⚠ Warning:* Be sure to include the full
//     `(note: none, field: none, field-content: none)` parameter signature, as
//     you might get an error otherwise about unknown parameters being passed to
//     the function in the temporary Typst document created by Ankify to render
//     the notes.
//
// - setup (function): Setup function to run at the start of the document. Has
//   one parameter, `body`, which is the document body. The function should
//   return `body` after performing some setup actions, such as setting the
//   page layout.
//
//   _Default:_ a built-in function that sets a 16cm-wide page with 1cm
//   margins. Pass your own function to override it.
//
//   _Example with default page layout:_
//   ```typ
//   body => {
//     set page(width: 105mm, height: auto, margin: 5mm)
//     body
//   }
//   ```
//
// - cache (dictionary): Cache settings.
//
//   - `enabled` (`bool`): Whether to enable caching.
//
//     _Default:_ `true`
//
//   - `custom-file` (`str`): Path to custom cache file.
//
//     _Default:_ `none` (uses default cache)
//
// - checks (dictionary): Validation checks to perform.
//
//   - `typst` (`bool`): Enable Typst data and format checks.
//
//     _Default:_ `true`
//
//   - `ankiconnect` (`dictionary`): Enable AnkiConnect checks.
//
//     - `model` (`bool`): Check if model exists.
//
//       _Default:_ `true`
//
//     - `deck` (`bool`): Check if deck exists.
//
//       _Default:_ `true`
//
//     - `tags` (`bool`): Check if tags exist.
//
//       _Default:_ `true`
//
// -> none
#let configure(
  ankiconnect-url: none,
  verbose: none,
  scale: none,
  defaults: none,
  setup: none,
  cache: none,
  checks: none,
) = {
  __ankify-configuration.update(config => {
    let new-config = (
      ankiconnect-url: ankiconnect-url,
      verbose: verbose,
      scale: scale,
      setup: setup,
      defaults: defaults,
      cache: cache,
      checks: checks,
    )

    new-config = merge(
      config,
      new-config,
    )

    // Type-check arguments
    new-config = z.parse(new-config, configuration-schema)

    config = new-config

    new-config
  })
  context {
    [#metadata(__ankify-configuration.get()) <ankify-configuration>]
  }
}


/// Helper function to create a basic card with just front and back.
///
/// This is a convenience function for the most common use case.
///
/// # Arguments
///
/// - `label`: Unique identifier for the card
/// - `front`: Front side content
/// - `back`: Back side content
/// - `deck` (optional): Deck name
/// - `tags` (optional): Array of tags
///
/// # Example
///
/// ```typst
/// #basic("my-card", "Question", "Answer", deck: "Study")
/// ```
#let basic(label, front, back, deck: none, tags: none) = {
  note(
    label,
    data: (Front: front, Back: back),
    deck: deck,
    tags: tags,
  )
}

/// Helper function to create a cloze deletion card.
///
/// The card is always rendered as plain text, whatever the configured default
/// format: Anki needs the `{{c1::..}}` markers verbatim to turn them into
/// deletions, so rendering the text to an image would break the card.
///
/// # Arguments
///
/// - `label`: Unique identifier for the card
/// - `text`: Text with cloze deletions (use {{c1::answer}} syntax)
/// - `deck` (optional): Deck name
/// - `tags` (optional): Array of tags
///
/// # Example
///
/// ```typst
/// #cloze("capitals", "The capital of France is {{c1::Paris}}")
/// ```
#let cloze(label, text, deck: none, tags: none) = {
  note(
    label,
    model: "Cloze",
    data: (Text: text),
    deck: deck,
    tags: tags,
    format: "plain",
  )
}
