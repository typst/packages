#import "types.typ"
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
  /// Optional set of tags so that future element can refer to this one
  /// and others with the same tag.
  /// -> label | array(label)
  tags: (),
  /// Anchor point to the alignment.
  /// If #typ.v.auto, the anchor is automatically determined from #arg[align].
  /// If an alignment, the corresponding point of the object will be at the specified
  /// location.
  /// -> auto | align
  anchor: auto,
) = {
  ((
    type: types.elt.placed,
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
  /// Styling options for the content that ends up inside this container.
  /// If you don't find the option you want here, check if it might be in
  /// the #arg[style] parameter of @cmd:content instead.
  /// - `align`: flush text `left`/`center`/`right`
  /// - `text-fill`: color of text
  /// -> dictionary
  style: (:),
  /// Margin around the eventually filled container so that text from
  /// other paragraphs doesn't come too close.
  /// Follows the same convention as #typ.pad if given a dictionary
  /// (`x`, `y`, `left`, `right`, `rest`, etc.)
  /// -> length | dictionary
  margin: 5mm,
  /// One or more labels that will not affect this element's positioning.
  /// -> label | array(label)
  invisible: (),
  /// Optional set of tags so that future element can refer to this one
  /// and others with the same tag.
  /// -> label | array(label)
  tags: (),
) = {
  ((
    type: types.elt.container,
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

/// Continue layout to next page.
/// -> elem
#let pagebreak() = {
  ((
    type: types.elt.pagebreak,
  ),)
}

/// Continue content to next container.
/// Has the same internal fields as the output of @cmd:content so that we don't
/// have to check for ```typc key in elem``` all the time.
/// -> flowing
#let colbreak() = {
  ((
    type: types.flow.colbreak,
    data: none,
    style: (:),
  ),)
}

/// Continue content to next container after filling the current container
/// with whitespace.
/// -> flowing
#let colfill() = {
  ((
    type: types.flow.colfill,
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
  /// Apply an arbitrary transformation #lambda(content, ret:content)
  /// to the content before segmentation.
  /// -> function
  transform: ct => ct,
  /// Applies ```typ #set text(size: ..)```.
  /// -> length
  size: auto,
  /// Applies ```typ #set text(lang: ..)```.
  /// -> string
  lang: auto,
  /// Applies ```typ #set text(hyphenate: ..)```.
  /// -> bool
  hyphenate: auto,
  /// Applies ```typ #set par(leading: ..)```.
  /// -> length
  leading: auto,
  /// Applies ```typ #set par(spacing: ..)```.
  /// -> length
  spacing: auto,
  /// Adjust this parameter if you change the default list markers
  /// so that MEANDER has the correct spacing.
  /// In practice, if your document defines a
  /// #codesnippet[```typ
  /// #set list(markers: (..,))
  /// ```]
  /// then you should probably have the matching parameter
  /// #codesnippet[```typ
  /// list-markers: (..,)
  /// ```]
  /// -> list(content)
  list-markers: auto,
  /// Adjust this parameter if you change the default list numbering
  /// so that MEANDER has the correct spacing.
  /// In practice, if your document defines a
  /// #codesnippet[```typ
  /// #set enum(numbering: "..")
  /// ```]
  /// then you should probably have the matching parameter
  /// #codesnippet[```typ
  /// enum-numbering: ".."
  /// ```]
  /// -> numbering
  enum-numbering: auto,
  /// This parameter lets you control how MEANDER performs some normalization
  /// passes in lists and sequences. See @cmd:normalize:normalize-seq for details.
  /// #property-unstable()
  /// -> dictionary
  normalize: auto,
) = {
  let style = (
    size: size,
    lang: lang,
    leading: leading,
    hyphenate: hyphenate,
    list-markers: list-markers,
    enum-numbering: enum-numbering,
    normalize: normalize,
  )
  for (k,v) in style.pairs() {
    if v == auto {
      let _ = style.remove(k)
    }
  }
  ((
    type: types.flow.content,
    data: utils.apply-styles(transform(data), ..style),
    style: style,
  ),)
}

/// Callback to generate elements that depend on prior
/// layout information. 
/// #property(since: version(0, 4, 0))
#let callback(
  /// Elements from the `query` module assigned to names.
  /// See @queries for a list of usable values.
  /// #warning-alert[
  /// Version 0.4.1 made this into a dictionary rather than a variadic
  /// argument sink to avoid ambiguities.
  /// ]
  /// #property(changed: version(0, 4, 1))
  /// -> dictionary
  env: (:),
  /// A function that takes as input a dictionary of environment values
  /// and outputs elements for the layout.
  ///
  /// The function may only generate layout elements, not flow elements.
  /// That is, it can call @cmd:placed, @cmd:container, @cmd:pagebreak,
  /// but *not* @cmd:content, @cmd:colbreak, @cmd:colfill.
  /// -> function(dictionary => list(elem))
  fun,
) = {
  ((
    type: types.elt.callback,
    env: env,
    fun: fun,
  ),)
}
