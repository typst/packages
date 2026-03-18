#import "std.typ"
#import "utils.typ"

/// Core function to create an obstacle.
/// -> elem
#let placed(
  /// Reference position on the page or relative to a previously placed object.
  /// -> align | position
  align,
  /// Horizontal displacement.
  /// -> relative
  dx: 0% + 0pt,
  /// Vertical displacement.
  /// -> relative
  dy: 0% + 0pt,
  /// An array of functions to transform the bounding box of the content.
  /// By default, a ```typc 5pt``` margin.
  /// See @contouring and @contouring-doc for more information.
  /// -> contour
  boundary: (auto,),
  /// Whether the obstacle is shown.
  /// Useful for only showing once an obstacle that intersects several invocations.
  /// Contrast the following:
  /// - #arg[boundary] set to @cmd:contour:phantom will display
  ///   the object without using it as an obstacle,
  /// - #arg(display: false) will use the object as an obstacle but not display it.
  /// -> bool
  display: true,
  /// Inner content.
  /// -> content
  content,
  /// #property(since: version(0, 2, 3))
  /// Optional set of tags so that future element can refer to this one
  /// and others with the same tag.
  /// -> label | array(label)
  tags: (),
  /// #property(since: version(0, 2, 3))
  /// Anchor point to the alignment.
  /// If #typ.v.auto, the anchor is automatically determined from #arg[align].
  /// If an alignment, the corresponding point of the object will be at the specified
  /// location.
  /// -> auto | align
  anchor: auto,
) = {
  ((
    type: place,
    align: align,
    dx: dx,
    dy: dy,
    display: display,
    boundary: boundary,
    anchor: anchor,
    content: content,
    tags: utils.coerce-to-array(tags),
  ),)
}

/// Core function to create a container.
/// -> elem
#let container(
  /// Location on the page or position of a previously placed container.
  /// -> align | location
  align: top + left,
  /// Horizontal displacement.
  /// -> relative
  dx: 0% + 0pt,
  /// Vertical displacement.
  /// -> relative
  dy: 0% + 0pt,
  /// Width of the container.
  /// -> relative
  width: 100%,
  /// Height of the container.
  /// -> relative
  height: 100%,
  /// #property(since: version(0, 2, 2))
  /// Styling options for the content that ends up inside this container.
  /// If you don't find the option you want here, check if it might be in
  /// the #arg[style] parameter of @cmd:content instead.
  /// - `align`: flush text `left`/`center`/`right`
  /// - `text-fill`: color of text
  /// -> dictionnary
  style: (:),
  /// #property(since: version(0, 2, 2))
  /// Margin around the eventually filled container so that text from
  /// other paragraphs doesn't come too close.
  /// Follows the same convention as #typ.pad if given a dictionary
  /// (`x`, `y`, `left`, `right`, `rest`, etc.)
  /// -> length | dictionary
  margin: 5mm,
  /// #property(since: version(0, 2, 3))
  /// One or more labels that will not affect this element's positioning.
  /// -> label | array(label)
  invisible: (),
  /// #property(since: version(0, 2, 3))
  /// Optional set of tags so that future element can refer to this one
  /// and others with the same tag.
  /// -> label | array(label)
  tags: (),
) = {
  ((
    type: box,
    align: align,
    dx: dx,
    dy: dy,
    width: width,
    height: height,
    margin: margin,
    tags: utils.coerce-to-array(tags),
    invisible: utils.coerce-to-array(invisible),
    style: style,
  ),)
}

/// #property(since: version(0, 2, 1))
/// Continue layout to next page.
/// -> obstacle
#let pagebreak() = {
  ((
    type: std.pagebreak,
  ),)
}

/// #property(since: version(0, 2, 2))
/// Continue content to next container.
/// Has the same internal fields as the output of @cmd:content so that we don't
/// have to check for ```typc key in elem``` all the time.
/// -> elem
#let colbreak() = {
  ((
    type: std.colbreak,
    data: none,
    style: (:),
  ),)
}

/// #property(since: version(0, 2, 3))
/// Continue content to next container after filling the current container
/// with whitespace.
/// -> elem
#let colfill() = {
  ((
    type: pad,
    data: none,
    style: (:),
  ),)
}

/// Core function to add flowing content.
/// -> flowing
#let content(
  /// Inner content.
  /// -> content
  data,
  /// #property(since: version(0, 2, 2))
  /// Applies ```typ #set text(size: ..)```.
  /// -> length
  size: auto,
  /// #property(since: version(0, 2, 2))
  /// Applies ```typ #set text(lang: ..)```.
  /// -> string
  lang: auto,
  /// #property(since: version(0, 2, 2))
  /// Applies ```typ #set text(hyphenate: ..)```.
  /// -> bool
  hyphenate: auto,
  /// #property(since: version(0, 2, 2))
  /// Applies ```typ #set par(leading: ..)```.
  /// -> length
  leading: auto,
) = {
  let style = (
    size: size,
    lang: lang,
    leading: leading,
    hyphenate: hyphenate,
  )
  for (k,v) in style.pairs() {
    if v == auto {
      let _ = style.remove(k)
    }
  }
  ((
    type: text,
    data: utils.apply-styles(data, ..style),
    style: style,
  ),)
}

