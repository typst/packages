// spryst — easy spritesheet access for Typst.
//
// Wraps the `spryst.wasm` plugin so you can slice a spritesheet into sprites
// with a single call, then drop them into your document as images.

/// The compiled `spryst` plugin. Internal.
///
/// -> plugin
#let _plugin = plugin("/wasm/spryst.wasm")

/// Normalises a `margin` or `spacing` argument into an `(x, y)` pair. A single
/// number is applied to both axes; an array is returned unchanged. Internal.
///
/// - value (int, array): a single length, or an `(x, y)` array
///
/// -> array
#let _axes(value) = if type(value) == array { value } else { (value, value) }

/// Builds the CBOR slice spec sent to the plugin from convenience arguments.
/// Internal.
///
/// Pass either `rows` + `cols` (grid mode) or `tile-width` + `tile-height`
/// (size mode).
///
/// - rows (none, int): number of sprite rows (grid mode)
/// - cols (none, int): number of sprite columns (grid mode)
/// - tile-width (none, int): width of a single sprite in pixels (size mode)
/// - tile-height (none, int): height of a single sprite in pixels (size mode)
/// - margin (int, array): border between the sheet edges and the outermost tiles
/// - spacing (int, array): gap between adjacent tiles
///
/// -> bytes
#let _spec(
  rows: none,
  cols: none,
  tile-width: none,
  tile-height: none,
  margin: 0,
  spacing: 0,
) = {
  let (margin-x, margin-y) = _axes(margin)
  let (spacing-x, spacing-y) = _axes(spacing)

  let fields = (
    margin_x: margin-x,
    margin_y: margin-y,
    spacing_x: spacing-x,
    spacing_y: spacing-y,
  )

  if rows != none { fields.rows = rows }
  if cols != none { fields.cols = cols }
  if tile-width != none { fields.tile_width = tile-width }
  if tile-height != none { fields.tile_height = tile-height }

  cbor.encode(fields)
}

/// Reports the sheet's pixel dimensions and the resolved grid, without decoding
/// any sprites. The returned dictionary has `sheet_width`, `sheet_height`,
/// `rows`, `cols`, `tile_width`, `tile_height`, and `count`.
///
/// ```typ
///  #let data = read("sheet.png", encoding: none)
///  #sheet-info(data, rows: 4, cols: 4)
/// ```
///
/// - data (bytes): the raw spritesheet image (PNG, JPEG, GIF, or WebP)
/// - args (arguments): slice arguments forwarded to `_spec` (`rows`, `cols`,
///   `tile-width`, `tile-height`, `margin`, `spacing`)
///
/// -> dictionary
#let sheet-info(data, ..args) = {
  cbor(_plugin.info(data, _spec(..args.named())))
}

/// Slices `data` into every sprite. The returned dictionary has `rows`, `cols`,
/// `tile_width`, `tile_height`, and `sprites` — an array of sprite dictionaries,
/// each with `row`, `col`, `x`, `y`, `width`, `height`, and `png`.
///
/// ```typ
///  #let data = read("sheet.png", encoding: none)
///  #let sheet = spritesheet(data, rows: 4, cols: 4)
///  #grid(
///    columns: sheet.cols,
///    ..sheet.sprites.map(sprite-image),
///  )
/// ```
///
/// - data (bytes): the raw spritesheet image (PNG, JPEG, GIF, or WebP)
/// - args (arguments): slice arguments forwarded to `_spec` (`rows`, `cols`,
///   `tile-width`, `tile-height`, `margin`, `spacing`)
///
/// -> dictionary
#let spritesheet(data, ..args) = {
  cbor(_plugin.split(data, _spec(..args.named())))
}

/// Extracts a single sprite, addressed by `index` (row-major, zero-based) or by
/// `row` + `col`. Returns a sprite dictionary with `row`, `col`, `x`, `y`,
/// `width`, `height`, and `png`.
///
/// ```typ
///  #let data = read("sheet.png", encoding: none)
///  #sprite-image(sprite(data, index: 5, rows: 4, cols: 4))
/// ```
///
/// - data (bytes): the raw spritesheet image (PNG, JPEG, GIF, or WebP)
/// - index (none, int): row-major, zero-based sprite index
/// - row (none, int): zero-based row (use together with `col`)
/// - col (none, int): zero-based column (use together with `row`)
/// - args (arguments): slice arguments forwarded to `_spec` (`rows`, `cols`,
///   `tile-width`, `tile-height`, `margin`, `spacing`)
///
/// -> dictionary
#let sprite(data, index: none, row: none, col: none, ..args) = {
  let selector = (:)
  if index != none { selector.index = index }
  if row != none { selector.row = row }
  if col != none { selector.col = col }

  cbor(_plugin.sprite(data, _spec(..args.named()), cbor.encode(selector)))
}

/// Turns a sprite dictionary (from `spritesheet` or `sprite`) into an `image`.
///
/// ```typ
///  #sprite-image(sprite(data, index: 0, rows: 4, cols: 4), width: 32pt)
/// ```
///
/// - spr (dictionary): a sprite dictionary containing a `png` field
/// - args (arguments): extra named arguments forwarded to `image` (e.g.
///   `width`, `height`, `fit`)
///
/// -> content
#let sprite-image(spr, ..args) = image(spr.png, format: "png", ..args)


/// Builds an indexer for an already-sliced spritesheet, addressing sprites by
/// either a single row-major index or a `(row, col)` pair. A convenience wrapper
/// around `sprite-image` so you can pull sprites straight from a `spritesheet`
/// result without indexing into `.sprites` yourself. For example:
///
/// ```typ
///   #let sheet = spritesheet(
///     read("sheet.png", encoding: none),
///     tile-width: 32,
///     tile-height: 32,
///   )
///   #let get-sprite = make-getter(sheet)
///
///   #get-sprite(5, width: 32pt)
///   #get-sprite(1, 2, width: 32pt)
/// ```
///
/// - sheet (dictionary): the output of `spritesheet` for a given sheet
///
/// -> function
#let make-getter(sheet) = {
  let get(..args) = {
    let named = args.named()
    let idx = args.pos()

    if idx.len() == 1 {
      sprite-image(sheet.sprites.at(idx.at(0)), ..named)
    } else if idx.len() == 2 {
      let (row, col) = (idx.at(0), idx.at(1))
      sprite-image(sheet.sprites.at(row * sheet.cols + col), ..named)
    } else {
      panic(
        "Invalid sprite selector. Use either an index or a (row, col) pair.",
      )
    }
  }

  get
}
