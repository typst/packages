
#let bob-wasm = plugin("bob_typ.wasm")

/// Transforms a bob string into an svg string.
///
/// # Arguments
/// * `art` - The bob string to transform.
///
/// # Returns
/// The svg string.
///
/// # Example
/// ```typ
/// let svg = bob2svg("<--->")
/// ```
#let bob2svg(
    art,
) = bob-wasm.art_to_svg(bytes(art))

/// Renders a bob string.
///
/// # Arguments
/// * `art` - The bob string to render as string or as raw block.
/// * `..args` - The arguments to pass to the image.decode function, for example "width: 50%".
///
/// # Returns
/// The rendered image.
///
/// # Example
/// ```typ
/// render("<--->")
/// render(
///   ```
///   <--->
///   `,
///   width: 25%
/// )
/// ```
#let render(
    art,
    ..args,
) = {
    if sys.version >= version((0, 13, 0)) {
        if type(art) == str {
            image(bob2svg(art), format: "svg", ..args)
        } else if art.text != none {
            image(bob2svg(art.text), format: "svg", ..args)
        }
    } else {
        if type(art) == "string" {
            image.decode(bob2svg(art), format: "svg", ..args)
        } else if art.text != none {
            image.decode(bob2svg(art.text), format: "svg", ..args)
        }
    }
}
