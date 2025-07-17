/// The module `lq.color.map` contains a careful selection of color maps. These color maps have been chosen with regard to accessibility. All featured maps are
/// - CVD (color-vision deficiency) friendly,
/// - perceptually uniform,
/// - and perceptually ordered
/// 
/// and therefore suitable for accurate and scientific application. 
/// 
/// The maps `viridis`, `magma` `plasma`, and `inferno` have been developed by 
/// Stéfan van der Walt and Nathaniel Smith for Matplotlib. The color map `cividis`
/// is an optimization of `viridis` accounting for perceptual linearity also for
/// those with CVD. The bi-sequential map `tovu` is a CVD-friendlier combination of the `topo`
/// map from #link("https://github.com/matplotlib/cmocean")[cmocean] and 
/// `bukavu`. 
/// The remaining maps have been created by 
/// #link("https://www.fabiocrameri.ch/colourmaps/")[Crameri _et al_]. 
/// 
/// 
/// 
/// == Sequential color maps
/// ```typ render
/// #import "src/typst/_color-sequence.typ": show-map
/// 
/// #let show-map(name) = block(width: 14cm, {
///   let map = dictionary(lq.color.map).at(name)
///   show "lq.color.map.": set text(gray)
///   raw("lq.color.map." + name)
///   stack(spacing: -1pt,
///     rect(
///       width: 100%,
///       height: 1.5cm,
///       fill: gradient.linear(..map)
///     ),
///     rect(
///       width: 100%,
///       height: 1cm,
///       fill: gradient.linear(..map).sharp(map.len()),
///     )
///   )
/// })
/// #show-map("cividis")
/// #show-map("viridis")
/// #show-map("magma")
/// #show-map("plasma")
/// #show-map("inferno")
/// #show-map("batlow")
/// #show-map("acton")
/// #show-map("lajolla")
/// #show-map("lipari")
/// #show-map("davos")
/// ```
/// 
/// 
/// 
/// == Diverging color maps
/// ```typ render
/// #import "src/typst/_color-sequence.typ": show-map
/// 
/// #let show-map(name) = block(width: 14cm, {
///   let map = dictionary(lq.color.map).at(name)
///   show "lq.color.map.": set text(gray)
///   raw("lq.color.map." + name)
///   stack(spacing: -1pt,
///     rect(
///       width: 100%,
///       height: 1.5cm,
///       fill: gradient.linear(..map)
///     ),
///     rect(
///       width: 100%,
///       height: 1cm,
///       fill: gradient.linear(..map).sharp(map.len()),
///     )
///   )
/// })
/// #show-map("cork")
/// #show-map("vik")
/// #show-map("tofino")
/// #show-map("managua")
/// #show-map("roma")
/// ```
/// 
/// 
/// == Bi-sequential color maps
/// ```typ render
/// #import "src/typst/_color-sequence.typ": show-map
/// 
/// #let show-map(name) = block(width: 14cm, {
///   let map = dictionary(lq.color.map).at(name)
///   show "lq.color.map.": set text(gray)
///   raw("lq.color.map." + name)
///   stack(spacing: -1pt,
///     rect(
///       width: 100%,
///       height: 1.5cm,
///       fill: gradient.linear(..map)
///     ),
///     rect(
///       width: 100%,
///       height: 1cm,
///       fill: gradient.linear(..map).sharp(map.len()),
///     )
///   )
/// })
/// #show-map("tovu")
/// #show-map("oleron")
/// #show-map("bukavu")
/// #show-map("fes")
/// ```
/// 
/// 
/// == Qualitative color maps
/// Qualitative color maps are good for [style cycles](/docs/tutorials/cycles). 
/// ```typ render
/// #import "src/typst/_color-sequence.typ": *
/// 
/// #show-sequence("petroff10")
/// #show-sequence("petroff8")
/// #show-sequence("petroff6")
/// #show-sequence("okabe-ito")
/// ```

#import "map.typ"
