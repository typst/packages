#import "core.typ": *

/// The default prefix used in ```ref #deixis-attach.prefix``` when `prefix: auto`.
/// Defaults to `"deixispin"` and can be set using ```ref #deixis-set-pin-pattern```.
///
/// ```warning
/// While counter-intuitive, prefix should not contain special characters like `".~!@#$%^&*()-_"`, if you want it to works on `raw` code.
/// ```
///
/// -> str
#let deixis-pin-prefix-state = state("deixis-pin-prefix", "deixispin")

/// The default postfix used in ```ref #deixis-attach.postfix``` when `postfix: auto`.
/// Defaults to `""` (empty string) and can be set using ```ref #deixis-set-pin-pattern```.
///
/// ````warning
/// Similar to ```ref #deixis-pin-prefix-state```, postfix should not contain special characters like `".~!@#$%^&*()-_"`.
/// ````
///
/// -> str
#let deixis-pin-postfix-state = state("deixis-pin-postfix", "")

/// Sets the global prefix and postfix used by ```ref #deixis-attach``` regex engine.
///
/// - prefix (str): The string prefix to use for regex matching.
/// - postfix (str): The string postfix to use for regex matching.
#let deixis-set-pin-pattern(
  /// The string prefix to use for regex matching.
  /// -> str
  prefix: auto,
  /// The string postfix to use for regex matching.
  /// -> str
  postfix: auto,
) = {
  if prefix != auto {
    deixis-pin-prefix-state.update(prefix)
  }
  if postfix != auto {
    deixis-pin-postfix-state.update(postfix)
  }
}

/// Manually drops an invisible, named geometric anchor (a `"pin"`) into the document flow.
///
/// Pins are the coordinate anchors that ```ref #deixis-region-mark``` uses to draw its highlights.
/// They can also be used as anchor coordinates for ```ref #deixis-inset-note-body``` and ```ref #deixis-margin-note-body```.
///
/// - name (str): The unique identifier for this pin.
/// - padding (str, length, dictionary): The mathematical padding around the pin. Using `"text"` automatically calculates the height of the current font size.
/// - extra-data (dictionary): Additional metadata to attach to the pin payload.
///
/// -> content
#let deixis-pin(
  /// The unique identifier for this pin.
  /// -> str
  name,
  /// The mathematical padding around the pin.
  /// - Accepts `length` or `dictionary`.
  /// ```example
  /// #place(center + horizon, deixis-pin("test-padding", padding: 5pt))
  /// #deixis-region-mark(pins: ("test-padding",))
  /// ```
  /// - If `"text"`, the height of the current font size is calculated.
  /// ```example
  /// The library was filled with the #deixis-pin("susurrus-l", padding: "text")susurrus#deixis-pin("susurrus-r", padding: "text") of turning pages.
  /// #deixis-region-mark(pins: ("susurrus-l", "susurrus-r"))
  /// ```
  ///
  /// -> str | length | dictionary
  padding: "text",
  /// Additional metadata to attach to the pin payload.
  /// -> dictionary
  extra-data: (:),
) = context {
  let actual-padding = if padding == "text" {
    text-padding
  } else {
    padding
  }

  let pad = deixis-utils.get-margins(actual-padding)
  let abs-pad = (
    left: deixis-utils.resolve-len(pad.left),
    right: deixis-utils.resolve-len(pad.right),
    top: deixis-utils.resolve-len(pad.top),
    bottom: deixis-utils.resolve-len(pad.bottom),
  )

  box[#metadata((
    name: name,
    padding: abs-pad,
    ..extra-data,
  ))<deixis-pin>]
}

/// A wrapper that attaches pins to a block of content.
///
/// This function does two things:
/// 1. It scans the `body` text for your pin prefix (e.g., `deixispinTop`) and converts them into physical inline pins.
/// 2. It can place absolute overlay pins relative to the bounding box of the `body` (e.g., placing a pin exactly at `dx: 100%, dy: 100%`).
///
/// - body (content): The content block to wrap and scan.
/// - pins (dictionary): A dictionary mapping pin names to overlay coordinates and padding. Example: `("my-pin": (dx: 100%, dy: 50%, padding: 2pt))`.
/// - prefix (auto, str, none): The regex prefix to search for. If `auto`, it uses the global state. Set to `none` to disable regex scanning.
/// - padding (auto, str, length, dictionary): Padding for pins replaced with `prefix`. It has no effect on pins defined with `pins`.
/// - inline (bool): If `true`, the wrapper uses an inline `box` instead of a `block`.
///
/// -> content
#let deixis-attach(
  /// The content block to wrap and scan.
  /// -> content
  body,
  /// A dictionary mapping pin names to overlay coordinates and padding. Example: `("my-pin": (dx: 100%, dy: 50%, padding: 2pt))`.
  ///
  /// ```example
  /// #deixis-attach(
  ///   pins: (
  ///     cat-tl: (dx: 40%, dy: 35%, padding: (left: -5pt, top: -5pt)),
  ///     cat-br: (dx: 60%, dy: 60%, padding: (right: 5pt, bottom: 5pt)),
  /// ))[
  ///   #image("../assets/loading-cat.jpg")
  /// ]
  /// #deixis-region-mark(
  ///   pins: ("cat-tl", "cat-br"),
  ///   stroke: red + 2pt,
  /// )
  /// ```
  ///
  /// -> dictionary
  pins: (:),
  /// The regex prefix to search for. If `auto`, it uses the global state. Set to `none` to disable regex scanning.
  ///
  /// ```info
  /// Pins attached with regex scan will have `padding: "text"` by default. Use @deixis-attach.padding for customization.
  /// ```
  ///
  /// ````example
  /// Usage:
  /// #deixis-attach(prefix: "mypin")[
  ///   ```typst
  ///   mypincode1#deixis-attachmypincode2(postfix: "deixis")[
  ///     deixispinp1deixisThis line will be pinned.deixispinp2deixis
  ///   ]
  ///   // Now one can use pins "p1" and "p2"
  ///   ```
  /// ]
  /// #deixis-region-mark(pins: ("code1", "code2"), fill: red.transparentize(95%))
  /// ````
  ///
  /// ```tip
  /// Oftentimes, if `prefix` alone is not enough, you can also define a `postfix`.
  ///
  /// The name of the pin attached with regex scan should also not contain any special character, depending on the `raw` language.
  /// ```
  ///
  /// -> auto | str | none
  prefix: auto,
  /// The regex postfix to search for. If `auto`, it uses the global state.
  ///
  /// ````example
  /// Python hello world program:
  /// #deixis-attach(
  ///   prefix: "mypin",
  ///   postfix: "mypin")[
  ///   ```python
  ///   mypincode3mypinprintmypincode4mypin("Hello world!")
  ///   ```
  /// ]
  /// #deixis-region-mark(pins: ("code3", "code4"), fill: red.transparentize(95%))
  /// ````
  ///
  /// -> auto | str | none
  postfix: auto,
  /// Padding for pins replaced with @deixis-attach.prefix. It has no effect on pins defined with @deixis-attach.pins.
  ///
  /// ```example
  /// Pythagorean theorem:
  ///
  /// #align(center)[
  /// #deixis-attach(
  ///   prefix: "mypin",
  ///   padding: (  // dict of pin names
  ///     eq1: (top: 1.2em, bottom: 0.5em, left: 1em),
  ///     eq2: (top: 1.2em, bottom: 0.5em, right: 1em),
  ///   ),
  /// )[
  ///   mypineq1$a^2 + b^2 = c^2$mypineq2
  /// ]
  /// ]
  /// #deixis-region-mark(pins: ("eq1", "eq2"), stroke: orange, fill: orange.transparentize(95%))
  /// ```
  ///
  /// -> auto | str | length | dictionary
  padding: auto,
  /// If `true`, the wrapper uses an inline `box` instead of a `block`.
  ///
  /// ```example
  /// #lorem(7)
  /// #deixis-attach(
  ///   pins: (tl1: (dx: 0%, dy: 0%), br1: (dx: 100%, dy: 100%)),
  ///   inline: false)[
  ///   Block-level attached content.
  /// ]
  /// #deixis-region-mark(pins: ("tl1", "br1"), stroke: teal)
  ///
  /// #lorem(7)
  /// #deixis-attach(
  ///   pins: (tl2: (dx: 0%, dy: 0%), br2: (dx: 100%, dy: 100%)),
  ///   inline: true)[
  ///   Inline attached content.
  /// ]
  /// #deixis-region-mark(pins: ("tl2", "br2"), stroke: green)
  /// ```
  ///
  /// -> bool
  inline: false,
) = context {
  _deixis-check-setup-state()

  let prefix = if prefix == auto { deixis-pin-prefix-state.get() } else { prefix }
  let postfix = if postfix == auto { deixis-pin-postfix-state.get() } else { postfix }

  let valid-prefix = prefix != none and type(prefix) == str and prefix.len() > 0
  let valid-postfix = postfix != none and type(postfix) == str and postfix.len() > 0

  let pattern-str = ""
  if valid-postfix {
    pattern-str = prefix + "([a-zA-Z0-9_-]+?)" + postfix
  } else {
    pattern-str = prefix + "([a-zA-Z0-9_-]+)"
  }
  // ------------------------------

  let pin-pattern = if valid-prefix { regex(pattern-str) }

  let dimension-dict-padding = (
    type(padding) == dictionary and padding.keys().any(k => k in ("left", "right", "top", "bottom", "x", "y", "rest"))
  )
  if dimension-dict-padding and not padding.keys().all(k => k in ("left", "right", "top", "bottom", "x", "y", "rest")) {
    panic("deixis: #deixis-attach padding keys must be either dimensions or pin names. Mixxing them is not allowed.")
  }

  let pin-replacer = it => if valid-prefix {
    // Safely extract Capture Group 1 (the pin name) directly from the regex match!
    let m = it.text.match(pin-pattern)
    let pin-name = m.captures.at(0)

    let pin-padding = if padding == auto {
      "text"
    } else if type(padding) == dictionary {
      if dimension-dict-padding {
        padding
      } else {
        if pin-name == "rest" {
          panic(
            "deixis: #deixis-attach reserves 'rest' as a special keyword for pin-scoped padding dictionary. Rename your pin.",
          )
        }
        padding.at(pin-name, default: padding.at("rest", default: 0pt))
      }
    } else {
      padding
    }
    deixis-pin(pin-name, padding: pin-padding, extra-data: (type: "inline-regex"))
  } else { it }

  show pin-pattern: pin-replacer
  show raw: it => if valid-prefix {
    show pin-pattern: pin-replacer
    it
  } else { it }

  if pins.len() > 0 {
    let container = if inline { box } else { block }
    container(width: auto, height: auto, {
      for (pin-name, pin-args) in pins {
        let dx = if "dx" in pin-args { pin-args.dx } else { pin-args.at(0, default: 0pt) }
        let dy = if "dy" in pin-args { pin-args.dy } else { pin-args.at(1, default: 0pt) }
        let padding = if "padding" in pin-args { pin-args.padding } else { 0pt }
        let extra-data = if "extra-data" in pin-args { pin-args.extra-data } else { (:) }

        place(top + left, dx: dx, dy: dy, deixis-pin(
          pin-name,
          padding: padding,
          extra-data: (type: "overlay", dx: dx, dy: dy) + extra-data,
        ))
      }
      body
    })
  } else {
    body
  }
}
