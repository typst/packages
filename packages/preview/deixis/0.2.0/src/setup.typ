#import "core/internal.typ": *
#import "notes/footnote.typ": *
#import "notes/margin.typ": *
#import "notes/inset.typ": *
#import "marks/region.typ": *
#import "reference.typ": *
#import "routing/overlay.typ": _deixis-validate-note-connection-pins
#import "render/overlay.typ": _deixis-paint-page-overlay, _deixis-html-overlay-bodies
#import "core/occurrences.typ": _deixis-validate-occurrences
#import "routing/explicit.typ": _deixis-validate-connections
#import "core/references.typ": _deixis-validate-reference-identities
#import "routing/crossings.typ": _deixis-validate-crossings
#import "routing/connector-scene.typ": _deixis-validate-scene-routes
#import "routing/attached.typ": _deixis-validate-attached-nodes
#import "routing/document-groups.typ": _deixis-validate-routing-plans

/// Paints Deixis in a page layer owned by a host theme.
///
/// Use with `deixis-setup-notes(page-overlays: false)` when a presentation
/// framework owns page settings. Install this content through its page API.
///
/// - layer (str): `"foreground"` or `"background"`.
/// -> content
#let deixis-page-overlay(layer: "foreground") = {
  // Native contextual content equality does not distinguish callback bodies.
  // Keep a private, nonpainting discriminator outside the deferred context so
  // setup can recognize its hook without evaluating user/native decoration.
  metadata((deixis-page-overlay: layer))
  context _deixis-visible-root({
    assert(layer in ("foreground", "background"), message: "deixis: A page overlay must be foreground or background.")
    if layer == "background" {
      let frame(size) = [#metadata((page: here().page(),
        width: deixis-utils.resolve-signed-len(size.width), height: deixis-utils.resolve-signed-len(size.height),
        binding: deixis-utils.get-page-binding(),
        margins: deixis-utils.get-page-margins(here().page()).pairs().fold((:),
          (result, pair) => result + ((pair.first()): deixis-utils.resolve-signed-len(pair.last())))))<deixis-page-frame>]
      if type(page.width) == length and type(page.height) == length {
        frame((width: page.width, height: page.height))
      } else { layout(frame) }
    }
    let prefix = if layer == "background" { "bg" } else { "fg" }
    let layers = deixis-system.get().at(prefix + "-layers", default: (:))
    // A host-owned first-page background precedes setup's main-flow update.
    // The package compositor is available independently of that layer registry.
    if "deixis" not in layers { layers.insert("deixis", context { _deixis-paint-page-overlay(layer) }) }
    let native = "native-" + prefix
    let user = "user-" + prefix
    if layer == "background" {
      if native in layers { layers.at(native) }
      if user in layers { layers.at(user) }
    }
    for (name, content) in layers {
      if name not in (native, user) { content }
    }
    if layer == "foreground" {
      if user in layers { layers.at(user) }
      if native in layers { layers.at(native) }
    }
  })
}

/// Installs document registration/show rules, validation, and optional page overlays.
///
/// Wrap document notes, pins, scopes, counters, queries and declared connections
/// with `#show: deixis-setup-notes.with(...)`. Resolved numeric routes/scenes,
/// head/shaft painting and configuration do not require note setup.
///
/// ```warning
/// `deixis` uses the page foreground and background to display some notes.
/// Replacing a native page foreground/background later removes that layer's
/// compositor, while registration and show rules remain installed. Reapply
/// setup after the new page settings to restore automatic composition. Reuse
/// the same bound setup function when retaining nondefault setup options.
/// Themes and scoped page styles should own their layers with `page-overlays:
/// false` and include `deixis-page-overlay` in each background/foreground.
/// The background hook also publishes physical page geometry.
/// ```
///
/// - body (content): The main document content to wrap.
/// - foreground (none, content): Custom content to inject into the foreground overlay layer.
/// - background (none, content): Custom content to inject into the background overlay layer.
/// - override-page-footnotes (bool): Default unspecified page-footnote bodies to native flow (`false`) or the foreground overlay (`true`); explicit layers retain ownership.
///
/// -> content
#let deixis-setup-notes(
  /// The main document content to wrap.
  /// -> content
  body,
  /// Custom content to inject into the foreground overlay layer.
  /// -> none | content
  foreground: none,
  /// Custom content to inject into the background overlay layer.
  /// -> none | content
  background: none,
  /// Default unspecified page-footnote bodies to the foreground overlay instead
  /// of native flow. Explicit body layers and deixis-set layers are honored.
  ///
  /// ```info
  /// Native flow paginates long bodies. Overlays reserve complete bodies and
  /// can group series with aligned markers, but cannot split across pages.
  /// ```
  ///
  /// -> bool
  override-page-footnotes: false,
  /// Automatically install page layers. Set false when a host theme calls
  /// deixis-page-overlay through its own background/foreground configuration.
  /// -> bool
  page-overlays: true,
) = {
  deixis-setup-state.update(true)
  show metadata.where(label: <deixis-paint-source>): _deixis-live-paint-source
  show metadata.where(label: <deixis-visibility-probe>): _deixis-live-visibility
  show metadata.where(label: <deixis-inline-mark-output>): it => (it.value)(false)
  show hide: _deixis-native-hide

  // Page footnotes share the native footer. Its separator, clearance and gap
  // remain native `footnote.entry` settings, including the user's own rules.
  // Deixis page-footnote bodies format their own marker and indentation. The
  // native prefix would otherwise form a separate first fragment: when the body
  // migrates, that fragment and its separator stay behind with the marker.
  show footnote.entry: it => if it.note.at("label", default: none) == <deixis-native-footnote> {
    it.note.body
  } else { it }
  // Outline entries replay heading and caption bodies: show marked passages only.
  show outline: _deixis-replay

  // Initialize contextual page ownership without deferring the document body.
  // Presentation frameworks need to inspect their slide wrappers before layout.
  context {
    let native-bg = if page-overlays { page.background } else { none }
    let native-fg = if page-overlays { page.foreground } else { none }
    // Reapplying setup after replacing only one page field must not capture
    // the untouched compositor as its own native decoration. Compare the
    // explicitly tagged unevaluated content; a bare context compares equal to
    // unrelated user contexts, and evaluating/querying would recurse too late.
    let inherited-bg = page-overlays and native-bg == deixis-page-overlay(layer: "background")
    let inherited-fg = page-overlays and native-fg == deixis-page-overlay()
    deixis-system.update(sys => {
      let prior-bg = sys.at("bg-layers", default: (:)).at("native-bg", default: none)
      let prior-fg = sys.at("fg-layers", default: (:)).at("native-fg", default: none)
      let fg-layers = (:)
      let bg-layers = (:)

      sys.insert("override-page-footnotes", override-page-footnotes)
      bg-layers.insert("deixis", context { _deixis-paint-page-overlay("background") })
      fg-layers.insert("deixis", context { _deixis-paint-page-overlay("foreground") })

      let actual-fg = if inherited-fg { prior-fg } else { native-fg }
      let actual-bg = if inherited-bg { prior-bg } else { native-bg }
      if actual-fg != none { fg-layers.insert("native-fg", actual-fg) }
      if actual-bg != none { bg-layers.insert("native-bg", actual-bg) }

      if foreground not in (auto, none) { fg-layers.insert("user-fg", place(top + left, foreground)) }
      if background not in (auto, none) { bg-layers.insert("user-bg", place(top + left, background)) }
      sys.insert("fg-layers", fg-layers)
      sys.insert("bg-layers", bg-layers)

      return sys
    })
  }

  show: content => {
    if not page-overlays { return content }
    // HTML export has no pages. Typst defines std.html only with the html
    // feature, so ordinary paged builds keep the undeferred page rule. With
    // the feature, the target needs context around the setup-owned layers;
    // host themes (page-overlays: false) still see the undeferred body.
    if "html" not in dictionary(std) {
      set page(background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay())
      content
    } else {
      context if _std-target() == "html" { content } else {
        set page(background: deixis-page-overlay(layer: "background"), foreground: deixis-page-overlay())
        content
      }
    }
  }

  show: _deixis-show-refs
  show metadata.where(label: <deixis-palette-output>): _deixis-live-palette-output
  show metadata.where(label: <deixis-declaration>): _deixis-live-declaration
  show metadata.where(label: <deixis-omission-evidence>): _deixis-live-omission-evidence
  body
  context if _std-target() == "html" { _deixis-html-overlay-bodies() }
  context _deixis-validate-scope-graph()
  context _deixis-validate-occurrences()
  // HTML export draws no connectors, so endpoints have no painted frames.
  context if _std-target() != "html" { _deixis-validate-connections() }
  context _deixis-validate-attached-nodes()
  context _deixis-validate-note-connection-pins()
  context _deixis-validate-reference-identities()
  context _deixis-validate-omissions()
  context _deixis-validate-attachments()
  context _deixis-validate-page-footnotes()
  context _deixis-validate-margin-overflow()
  context _deixis-validate-crossings()
  context _deixis-validate-scene-routes()
  context _deixis-validate-routing-plans()
}
