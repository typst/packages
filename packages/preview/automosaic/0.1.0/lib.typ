/// `mosaic` lays out grids of images (or arbitrary content) that fill an available box
/// while preserving every element's aspect ratio and keeping uniform gaps. Build the
/// tree by hand with `display-content-tree`, or hand a flat list of weighted items to
/// `display-auto-layout` to search for the best split automatically.
///
/// == Example
///
/// #example(```
/// #import "@local/mosaic:0.1.0": *
///
/// #context box(width: 100%, height: 6cm)[
///   #display-content-tree(
///     (image("a.jpg"), image("b.jpg")),
///     axis: "horizontal",
///     gap: 0.5em,
///   )
/// ]
/// ```)

#import "src/layout.typ": make-content-dict, add-body-to-content-dict, resolve-aspect, resolve-stretchable, fit-content-dict, parse-content-tree, display-content-tree
#import "src/auto-layout.typ": display-auto-layout
