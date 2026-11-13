// touying-ufac-unofficial — the icons: the ones the theme ships (assets/icons/*.json, in the JSON format of Iconify, only
// the icons the theme uses; scripts/icons.sh downloads them) and the role of each one, plus the bridge to the iconify
// package for the icons a deck provides itself (`provide-icons`).
#import "@preview/iconify:0.5.3" as _iconify

/// The collections shipped by the theme, by prefix: Octicons (the roles of the theme), Phosphor (code), Devicon (the
/// logos of the languages), Simple Icons (the Typst logo), Material Icon Theme (the terminal of the shell) and VSCode
/// Icons (the output of a program).
/// -> dictionary
#let _shipped = ("octicon", "ph", "devicon", "simple-icons", "material-icon-theme", "vscode-icons").map(p => (p, json("../assets/icons/" + p + ".json"))).to-dict()

/// The icon of each role of the theme, as `"collection:name"`: Octicons (size 16) for the callouts, the
/// badges of exercises and examples, the file name of a code block, the terminal and the contact; Phosphor in the bold weight
/// for code; colored icons for the pills of the code blocks: the logos of Devicon (Typst from Simple Icons), the
/// terminal of Material Icon Theme for the shell and the log of VSCode Icons for the output of a program. A role is
/// also a valid name for `icon`: `#icon("caution")`. `warning` and `caution` are the same icon, under the name of
/// 0.2.0 and the one of the callout.
///
/// #test(
///   `theme-icons.warning == "octicon:alert-16"`,
///   `theme-icons.output == "vscode-icons:file-type-log"`,
/// )
/// -> dictionary
#let theme-icons = (
  warning: "octicon:alert-16",
  caution: "octicon:alert-16",
  tip: "octicon:light-bulb-16",
  info: "octicon:info-16",
  note: "octicon:note-16",
  remark: "octicon:history-16",
  exercise: "octicon:pencil-16",
  example: "octicon:beaker-16",
  file: "octicon:file-code-16",
  terminal: "octicon:terminal-16",
  contact: "octicon:mail-16",
  output: "vscode-icons:file-type-log",
  code: "ph:code-bold",
  python: "devicon:python",
  matlab: "devicon:matlab",
  shell: "material-icon-theme:console",
  typst: "simple-icons:typst",
)

/// Where an icon comes from, decided at the call: `(collection, name)` of a shipped icon, or the full `"collection:name"`
/// of an icon the deck provides (looked up later, in the iconify store). A bare name is a role of the theme
/// (`"warning"`) or the name of a shipped Octicon without its size, as in 0.2.0 (`"alert"`, `"pencil"`, `"beaker"`); any
/// other bare name is an error that tells how to use the Octicons the theme does not ship.
///
/// #test(
///   `_icon-source("warning") == ("octicon", "alert-16")`,
///   `_icon-source("pencil") == ("octicon", "pencil-16")`,
///   `_icon-source("devicon:python") == ("devicon", "python")`,
///   `_icon-source("mdi:home") == "mdi:home"`,
///   `_icon-source("octicon:rocket-16") == "octicon:rocket-16"`,
/// )
/// -> array | str
#let _icon-source(
  /// Name of the icon. -> str
  name,
) = {
  assert(type(name) == str, message: "icon: the name is a string, got " + repr(name))
  let full = theme-icons.at(name, default: name)
  if not full.contains(":") {
    let n = full + "-16"
    assert(n in _shipped.octicon.icons, message: "unknown icon: \"" + name + "\". The theme ships only its own icons (" +
      theme-icons.keys().join(", ") + "); for another one, give its collection with `#provide-icons(json(..))` and "
      + "write it as \"collection:name\", such as #icon(\"octicon:" + name + "-16\") (see the manual)")
    return ("octicon", n)
  }
  let (col, n) = (full.split(":").first(), full.split(":").slice(1).join(":"))
  if col in _shipped and n in _shipped.at(col).icons { (col, n) } else { full }
}

/// SVG source of an icon of a collection in the JSON format of Iconify, with `currentColor` replaced by `fill` (the
/// multicolor logos keep their colors). An alias is followed to its parent icon. The `viewBox` is built here rather
/// than by the iconify package, which swaps its width and height (a wide logo came out small).
///
/// #test(
///   `_data-svg((icons: (a: (body: "<path fill=\"currentColor\"/>"))), "a", red).contains("#ff4136")`,
///   `_data-svg((width: 24, height: 12, icons: (a: (body: ""))), "a", red).contains("viewBox=\"0 0 24 12\"")`,
/// )
/// -> str
#let _data-svg(
  /// The collection: a dictionary with `icons` (and optional `aliases`, `width`, `height`). -> dictionary
  data,
  /// Name of the icon in it. -> str
  name,
  /// Color of the icon. -> color
  fill,
) = {
  let ic = data.icons.at(name, default: none)
  if ic == none {
    let alias = data.at("aliases", default: (:)).at(name)
    ic = alias + data.icons.at(alias.parent)
  }
  let w = str(ic.at("width", default: data.at("width", default: 16)))
  let h = str(ic.at("height", default: data.at("height", default: 16)))
  ("<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 " + w + " " + h + "\" width=\"" + w + "\" height=\"" + h
    + "\">" + ic.body.replace("currentColor", fill.to-hex()) + "</svg>")
}

/// SVG source of any icon: a shipped one, or (in `context`) one of a collection the deck gave to `provide-icons`. A
/// missing collection or icon is an error that names it.
/// -> str
#let _icon-svg(
  /// Source of the icon, see @_icon-source. -> array | str
  source,
  /// Color of the icon. -> color
  fill,
) = {
  if type(source) == array { return _data-svg(_shipped.at(source.first()), source.last(), fill) }
  let (col, n) = (source.split(":").first(), source.split(":").slice(1).join(":"))
  let store = _iconify.icons-store.final()
  assert(col in store, message: "icon \"" + source + "\": no collection \"" + col + "\" was given; add "
    + "`#provide-icons(json(\"" + col + ".json\"))` to the deck (see the manual)")
  let data = store.at(col)
  assert(n in data.icons or n in data.at("aliases", default: (:)), message: "icon \"" + source + "\": the collection \""
    + col + "\" given to provide-icons has no icon \"" + n + "\"")
  _data-svg(data, n, fill)
}

/// Gives the deck more icons: one or more collections in the JSON format of Iconify (`json("mdi.json")`), whose icons
/// are then written `#icon("mdi:home")`. It is the `provide-icons` of the iconify package. It goes in a slide, and its
/// icons serve the whole deck, the cover included.
///
/// ```typ
/// #provide-icons(json("octicon.json"))
/// #icon("octicon:rocket-16")
/// ```
/// -> content
#let provide-icons(
  /// The collections, each a dictionary read from a JSON file of Iconify. -> dictionary
  ..collections,
) = _iconify.provide-icons(..collections)
