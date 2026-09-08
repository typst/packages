// POV-Ray rendering for Typst.
//
// Loads the WebAssembly-compiled POV-Ray plugin and exposes a `render`
// function that accepts a scene source plus every POV-Ray render option
// that makes sense in a filesystem-less, single-threaded WASM context.
//
// Options are serialized as newline-separated POV-Ray command strings
// (INI-style `Key=value` or command-line-style `+A0.1`) and handed to
// `vfeRenderOptions::AddCommand` on the plugin side. That's the same
// interface the POV-Ray binary accepts for its `.ini` files and CLI,
// so anything documented in the POV-Ray manual can be passed through
// via the `extra` escape hatch below.

#let _plugin = plugin("povray.wasm")

// Module-level regex so we don't recompile on every `expand-includes`
// call (this function recurses, so even one scene can trigger many).
#let _include-pattern = regex(
  "(?m)^[ \t]*#include[ \t]+[\"<]([^\">\n]+)[\">]"
)

/// Return the POV-Ray version string the plugin was built against.
#let version() = str(_plugin.version())

/// Expand POV-Ray `#include "name"` (and `#include <name>`) directives
/// in `scene` by substituting the corresponding entry from `includes`.
///
/// POV-Ray's include mechanism is textual — the parser splices the
/// included file's content in place and re-tokenizes. We do the same
/// thing here at the Typst layer, which means the WASM plugin never
/// has to fake a filesystem and every `#include` that POV-Ray would
/// handle on disk works identically when expanded from an `includes`
/// dictionary.
///
/// - Handles both `"..."` (user-style) and `<...>` (system-style) forms.
/// - Expansion is recursive: an include can itself contain `#include`s.
/// - A depth cap (64) catches runaway recursion.
/// - Each branch of the recursion tracks ancestors in `seen`; if a file
///   appears twice in the same ancestor chain, the second reference is
///   replaced with a comment — this mirrors what POV-Ray authors achieve
///   manually with `#ifndef(GUARD) #declare GUARD = 1 ... #end`.
/// - A referenced name that isn't in `includes` is left untouched, so
///   POV-Ray will raise its own "Cannot open include file" error with
///   the original filename visible in the error message.
///
/// Comments: this is line-based text substitution, so `#include` inside
/// a block comment still gets expanded. Typically harmless (the splice
/// lands inside the comment and POV-Ray ignores it) but worth knowing.
#let expand-includes(scene, includes, seen: (), depth: 0) = {
  assert(depth < 64,
    message: "#include depth limit exceeded — probable circular include chain")
  if includes == none or includes == (:) { return scene }

  scene.replace(_include-pattern, m => {
    let name = m.captures.at(0)
    if name in seen {
      ("// #include \"" + name + "\" (already included — "
       + "skipped by povray.expand-includes cycle guard)")
    } else if name in includes {
      let expanded = expand-includes(
        includes.at(name),
        includes,
        seen: seen + (name,),
        depth: depth + 1,
      )
      ("// ── begin include \"" + name + "\" ──\n"
       + expanded
       + "\n// ── end include \"" + name + "\" ──")
    } else {
      // Leave as-is — POV-Ray will error out with the real filename.
      m.text
    }
  })
}

// Emit "Key=value" for non-`none` values, "" for `none`. A single-
// element array is returned so the caller can spread it into the
// command list with `..` (empty array spreads to nothing).
#let _kv(key, val) = if val != none { (key + "=" + str(val),) } else { () }

// Emit "Key=on" / "Key=off" for a tri-state; `none` omits the line.
#let _tf(key, val) = {
  if val == true { (key + "=on",) }
  else if val == false { (key + "=off",) }
  else { () }
}

/// Build the newline-separated POV-Ray options string from a
/// `config` dictionary. Only non-`none` entries are emitted, so
/// anything the caller leaves unset keeps POV-Ray's own default.
#let _build-options(config, extra) = {
  // Antialiasing is non-orthogonal: if AA is off, the sub-options are
  // meaningless; if AA is none (caller didn't touch it), POV-Ray's
  // own default applies and we shouldn't force anything.
  let aa = if config.antialias == true {
    (
      ("Antialias=on",),
      _kv("Antialias_Threshold", config.aa-threshold),
      _kv("Sampling_Method",     config.aa-method),
      _kv("Antialias_Depth",     config.aa-depth),
      _tf("Jitter",              config.aa-jitter),
      _kv("Jitter_Amount",       config.aa-jitter-amount),
      _kv("Antialias_Gamma",     config.aa-gamma),
    ).flatten()
  } else if config.antialias == false {
    ("Antialias=off",)
  } else { () }

  (
    .._kv("Width",              config.width),
    .._kv("Height",             config.height),
    .._kv("Quality",            config.quality),
    ..aa,
    .._kv("Display_Gamma",      config.display-gamma),
    .._kv("File_Gamma",         config.file-gamma),
    .._kv("Max_Trace_Level",    config.max-trace-level),
    .._tf("Bounding",           config.bounding),
    .._kv("Bounding_Threshold", config.bounding-threshold),
    .._tf("Remove_Bounds",      config.remove-bounds),
    .._tf("Split_Unions",       config.split-unions),
    .._kv("Start_Row",          config.start-row),
    .._kv("End_Row",            config.end-row),
    .._kv("Start_Column",       config.start-column),
    .._kv("End_Column",         config.end-column),
    .._tf("Output_Alpha",       config.output-alpha),
    .._kv("Compression",        config.compression),
    ..extra,
  ).join("\n")
}

/// Render a POV-Ray scene to a PNG image.
///
/// The scene is POV-Ray source (SDL) — exactly what you'd write in a
/// `.pov` file. The plugin parses from an in-memory buffer, so there is
/// no filesystem for `image_map` / `height_field` etc. to read from.
/// `#include` directives *do* work if you supply the contents via the
/// `includes` keyword argument (see below).
///
/// All options are optional keyword arguments. Passing `none` for any of
/// them keeps POV-Ray's default behavior for that setting (what the
/// docs call "no command-line override").
///
/// Returns a Typst `image` of the rendered PNG.
#let render(
  scene,

  // ---- includes ------------------------------------------------------
  // Dict mapping include filename → file contents (usually
  // `read("path.inc")`). Each `#include "name"` line in `scene` is
  // replaced with the corresponding entry, recursively. Names are
  // matched verbatim — if the scene says `#include "lib/foo.inc"`, the
  // key must be "lib/foo.inc". See `expand-includes` for details.
  includes: (:),

  // ---- output ---------------------------------------------------------
  // Image dimensions in pixels. POV-Ray will adjust aspect ratio to match
  // unless the scene's camera sets its own `right`/`up` vectors.
  width: 800,
  height: 600,

  // ---- quality --------------------------------------------------------
  // 0..11. Higher enables more tracing features:
  //   0  ambient light only
  //   1  +  diffuse + pigments
  //   2  +  lights + shadows
  //   3  +  extended lights
  //   4  +  textures
  //   5  +  reflections (no refraction)
  //   7  +  refractions
  //   8  +  shadow transparency
  //   9  +  full media sampling
  //  11  + (= 9 currently; POV-Ray 3.7+)
  // The scene's `global_settings` may further raise this.
  quality: 9,

  // ---- antialiasing ---------------------------------------------------
  // Enable/disable adaptive antialiasing.
  antialias: true,
  // Threshold for color difference that triggers extra samples. Lower =
  // more samples = slower = smoother. Reasonable range: 0.05..0.5.
  aa-threshold: 0.3,
  // Sampling method: 1 = non-recursive (fixed supersample grid),
  // 2 = adaptive recursive, 3 = stochastic Monte Carlo (3.7+).
  aa-method: 2,
  // Depth for methods 2/3. Total samples/pixel is (depth²) at depth 1,
  // up to ~(depth²)² at higher depths. 3 is a good default.
  aa-depth: 3,
  // Randomize subpixel sample positions (breaks up regular aliasing).
  aa-jitter: true,
  // Jitter amount (0.0 – 1.0). `none` uses POV-Ray's default.
  aa-jitter-amount: none,
  // Gamma applied when comparing colors for the adaptive AA test.
  aa-gamma: none,

  // ---- gamma ----------------------------------------------------------
  // Display gamma (the gamma the final image is rendered *for*).
  display-gamma: none,
  // Gamma assumed for color literals in the scene file that don't use
  // a color space modifier.
  file-gamma: none,

  // ---- tracing --------------------------------------------------------
  // Maximum ray recursion depth (reflections + refractions). Overrides
  // the scene's `global_settings { max_trace_level N }`.
  max-trace-level: none,
  // Auto-bounding of complex CSG objects: `true`/`false` or `none` for
  // scene/POV-Ray default.
  bounding: none,
  bounding-threshold: none,
  // Remove redundant bounding volumes.
  remove-bounds: none,
  // Split unions with non-overlapping children into separate bounded
  // objects (faster intersection tests, more memory).
  split-unions: none,

  // ---- partial render -------------------------------------------------
  // Render only a rectangular section of the image. Useful for tiling
  // or for debugging a specific area at high quality.
  start-row: none,
  end-row: none,
  start-column: none,
  end-column: none,

  // ---- output encoding ------------------------------------------------
  // Write a full RGBA PNG with an alpha channel. Requires the scene to
  // produce transparent pixels — use `background { color rgbt <r,g,b,1> }`
  // where `t=1` means fully transparent. Without this, the background
  // is opaque black regardless of the transmit value.
  output-alpha: false,
  // PNG compression level, 0 (no compression) .. 9 (max).
  compression: none,

  // ---- escape hatch ---------------------------------------------------
  // Array of raw POV-Ray command strings appended verbatim. Use for
  // anything not covered above — e.g. `("+HI<path>",)` for high-detail
  // HDR. Each entry is passed as-is to `vfeRenderOptions::AddCommand`.
  extra: (),
) = {
  let opts = _build-options((
    width: width, height: height, quality: quality,
    antialias: antialias, aa-threshold: aa-threshold,
    aa-method: aa-method, aa-depth: aa-depth,
    aa-jitter: aa-jitter, aa-jitter-amount: aa-jitter-amount,
    aa-gamma: aa-gamma,
    display-gamma: display-gamma, file-gamma: file-gamma,
    max-trace-level: max-trace-level,
    bounding: bounding, bounding-threshold: bounding-threshold,
    remove-bounds: remove-bounds, split-unions: split-unions,
    start-row: start-row, end-row: end-row,
    start-column: start-column, end-column: end-column,
    output-alpha: output-alpha,
    compression: compression,
  ), extra)
  let expanded-scene = expand-includes(scene, includes)
  let png = _plugin.render(bytes(expanded-scene), bytes(opts))
  image(png, format: "png")
}

/// Render an inline POV-Ray scene without string quoting.
///
/// Accepts a raw-block `code`, extracts its text, and forwards the rest
/// to `render()`:
///
///   #pov(```povray
///     camera { location <0, 2, -5> look_at 0 }
///     light_source { <4, 6, -4> rgb 1.2 }
///     sphere { 0, 1 pigment { rgb <1, 0.4, 0.15> } }
///   ```, width: 800, height: 600)
///
/// The triple-backtick block preserves `"` and `<>` literally, so you
/// never have to escape POV-Ray syntax. The `povray` language tag also
/// gets syntax highlighting in editors that know the `.sublime-syntax`.
#let pov(code, ..args) = {
  let scene = if type(code) == content and code.func() == raw {
    code.text
  } else if type(code) == str {
    code
  } else {
    panic("pov() expects a raw block or a string, got " + str(type(code)))
  }
  render(scene, ..args)
}

/// Enable POV-Ray syntax highlighting for `povray` raw blocks.
///
/// Apply as a show rule once at the top of your document:
///
///   #import "@preview/povrayst:0.1.0": pov, render, highlight
///   #show: highlight
///
/// The syntax file shipped inside the package is loaded automatically —
/// no path to manage on the caller's side.
#let highlight(body) = {
  set raw(syntaxes: "povray.sublime-syntax")
  body
}
