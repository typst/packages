///! Public aesthetic-agnostic scale constructors.
///!
///! Each constructor returns a deferred stub `(kind: "scale", name: ...,
///! args: ...)`. The aesthetic is supplied by the `scales()` key, which
///! dispatches the stub to the matching internal builder (see scale/bind.typ).
///! Pass these to \@plot through \@scales, e.g.
///! `scales(x: scale-log10(), colour: scale-viridis-d())`.

// The stub defers `args` unvalidated because the valid key set depends on
// the aesthetic, which is only known when `scales()` binds the stub.
// `bind-scale` (scale/bind.typ) then checks every named key against the
// bound builder's key tuple and rejects positional arguments before
// spreading, so a misspelled argument fails with a scales-scoped message
// listing the valid keys for that scale and aesthetic.
#let _stub(family, args) = (kind: "scale", name: family, args: args)

// Generic scales ------------------------------------------------------------

/// Continuous scale for any continuous aesthetic.
///
/// Keyed to `x`/`y` it controls the axis (`limits`, `breaks`, `transform`, `expand`, `secondary`); keyed to `colour`/`fill` it sets the `palette`; keyed to `size`/`alpha`/`linewidth`/`stroke` it sets the output `range`.
///
/// - args: Named arguments forwarded to the bound scale.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - breaks: Array of tick positions in data units, a bare number for a single tick, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) for computed breaks. On the binned `linetype` ladder they are bin edges instead.
///   - minor-breaks: Array of minor-gridline positions in data units, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) to subdivide the majors, halfway between them in transformed space. `x`/`y` only.
///   - n-minor: Integer count of minor gridlines between adjacent majors, or `auto` (default) for one; ignored when `minor-breaks` is set. `x`/`y` only.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///   - transform: `"identity"` (default), `"log10"`, `"sqrt"`, or `"reverse"`. `x`/`y` only.
///   - expand: Padding around the domain as a ratio (`5%`), a length (`5pt`), a `relative`, or a `(lo, hi)` pair whose sides may each be `auto`; `false` or `none` removes it. `auto` (default) pads 5% per side. `x`/`y` only.
///   - secondary: Secondary axis built with `dup-axis` or `sec-axis`, or `none` (default). `x`/`y` only.
///   - palette: Typst gradient or array of colours interpolated across the domain on `colour`/`fill`, or an array of dash keywords on `linetype`; `auto` (default) uses viridis and the built-in dash set respectively.
///   - range: Output `(lo, hi)` pair: lengths for `size` (default `(1pt, 6pt)`), `linewidth` (default `(0.4pt, 1.4pt)`), and `stroke` (default `(0.2pt, 1.4pt)`); numbers in `[0, 1]` for `alpha` (default `(0.1, 1)`).
///   - n-breaks: Integer number of equal-width bins used when `breaks` is `auto`; default 4. `linetype` only.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-discrete`, `scale-binned`.
///
/// Pin the x domain and rename the axis with a continuous scale.
///
/// ```typst
/// #let d = range(1, 11).map(i => (x: i, y: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: scales(x: scale-continuous(name: "Index", limits: (0, 12))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-continuous(..args) = _stub("continuous", args)

/// Discrete scale for any categorical aesthetic.
///
/// Keyed to `x`/`y` it orders the axis levels; keyed to `colour`/`fill`, `shape`, or `linetype` it assigns the per-level palette, defaulting to that aesthetic's built-in set.
///
/// - args: Named arguments forwarded to the bound scale.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Array of level names selecting which levels appear and in which order; `none` (default) keeps the trained levels. A level name must be a string, because a discrete scale reads a bare number as a position rather than as a level, so quote a numeric level as `"1"`.
///   - oob: Handling of rows whose level falls outside `limits`: `"drop"` (default) removes them; `"squish"` censors too, since clamping has no meaning on levels.
///   - labels: Array of labels in level order, a function of the level returning a string or content, or `auto` (default) to print the level itself.
///   - expand: Padding around the domain as a ratio (`5%`), a length (`5pt`), a `relative`, or a `(lo, hi)` pair whose sides may each be `auto`; `false` or `none` removes it. `auto` (default) pads 0.6 of a level slot per side. `x`/`y` only.
///   - palette: Array of output values, one per level and recycled when shorter than the level count: colours for `colour`/`fill`, marker keywords for `shape`, dash keywords for `linetype`. `auto` (default) uses that aesthetic's built-in set.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-continuous`, `scale-manual`.
///
/// Force the level order on a discrete x axis.
///
/// ```typst
/// #let d = ((grp: "b", y: 3), (grp: "a", y: 5), (grp: "c", y: 2))
/// #plot(
///   data: d,
///   mapping: aes(x: "grp", y: "y"),
///   layers: (geom-col(),),
///   scales: scales(x: scale-discrete(limits: ("a", "b", "c"))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-discrete(..args) = _stub("discrete", args)

/// Binned scale that quantises a continuous variable into `n-breaks` bins.
///
/// Valid on `x`/`y`, `size`, `alpha`, `linewidth`, `stroke`, `shape`, and `linetype`; the per-row mapping stays continuous while the legend or axis snaps to bin midpoints.
///
/// - args: Named arguments forwarded to the bound scale.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - n-breaks: Integer number of equal-width bins used when `breaks` is `auto`; default 10 on `x`/`y` and 4 on the other aesthetics.
///   - breaks: Array of bin edges, a function of the trained values returning edges (the `breaks-*` helpers return such a function), ticked at the bin midpoints and overriding `n-breaks`, or `auto` (default) to cut `n-breaks` equal-width bins.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///   - range: Output `(lo, hi)` pair: lengths for `size` (default `(1pt, 6pt)`), `linewidth` (default `(0.4pt, 1.4pt)`), and `stroke` (default `(0.2pt, 1.4pt)`); numbers in `[0, 1]` for `alpha` (default `(0.1, 1)`).
///   - palette: Array of per-bin output values: marker keywords for `shape`, dash keywords for `linetype`. `auto` (default) uses that aesthetic's built-in set.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-continuous`.
///
/// Quantise the x axis into five equal-width bins.
///
/// ```typst
/// #let d = range(0, 30).map(i => (x: i / 3.0, y: calc.sin(i / 4.0)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: scales(x: scale-binned(n-breaks: 5)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-binned(..args) = _stub("binned", args)

/// Manual discrete scale: supply a per-level array of output values.
///
/// Valid on `colour`/`fill`, `alpha`, `size`, `linewidth`, `stroke`, `shape`, and `linetype`. Pass the outputs through `values`. Fill values accept any Typst paint: native `tiling` patterns distinguish levels without relying on colour, and the legend swatches render them too. Per-row `alpha` does not apply to non-colour paints.
///
/// - args: Named arguments forwarded to the bound scale.
///   - values: Array of output values in level order, recycled when shorter than the number of levels: any Typst paint for `colour`/`fill`, numbers in `[0, 1]` for `alpha`, lengths for `size`/`linewidth`/`stroke`, marker keywords for `shape`, and dash keywords for `linetype`. Default `()` holds no value, so pass at least one.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Array of level names selecting which levels appear and in which order; `none` (default) keeps the trained levels. A level name must be a string, because a discrete scale reads a bare number as a position rather than as a level, so quote a numeric level as `"1"`.
///   - oob: Handling of rows whose level falls outside `limits`: `"drop"` (default) removes them; `"squish"` censors too, since clamping has no meaning on levels.
///   - labels: Array of labels in level order, a function of the level returning a string or content, or `auto` (default) to print the level itself.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-discrete`, `scale-identity`.
///
/// Assign explicit per-level colours with a manual scale.
///
/// ```typst
/// #let d = ((x: 1, y: 1, g: "a"), (x: 2, y: 2, g: "b"), (x: 3, y: 3, g: "c"))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt),),
///   scales: scales(colour: scale-manual(
///     values: (rgb("#ff8c00"), rgb("#800080"), rgb("#008B8B")),
///   )),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Pattern fills: native Typst tilings keep dodged bars distinguishable in black-and-white print.
///
/// ```typst
/// #let stripes = tiling(size: (4pt, 4pt))[
///   #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 0.7pt + black))
/// ]
/// #let dots = tiling(size: (4pt, 4pt))[
///   #place(dx: 1pt, dy: 1pt, circle(radius: 0.8pt, fill: black))
/// ]
/// #let cross = tiling(size: (5pt, 5pt))[
///   #place(line(start: (0%, 50%), end: (100%, 50%), stroke: 0.5pt + black))
///   #place(line(start: (50%, 0%), end: (50%, 100%), stroke: 0.5pt + black))
/// ]
/// #let d = (
///   (g: "a", k: "u", n: 3), (g: "a", k: "v", n: 2), (g: "a", k: "w", n: 4),
///   (g: "b", k: "u", n: 4), (g: "b", k: "v", n: 3), (g: "b", k: "w", n: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "g", y: "n", fill: "k"),
///   layers: (geom-col(position: "dodge"),),
///   scales: scales(fill: scale-manual(values: (stripes, dots, cross))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// A tiling can carry both a base fill colour and a pattern: place a full-tile box for the background, then the pattern marks on top. Each level gets its own colour-and-pattern pair and the legend swatches show both.
///
/// ```typst
/// #let stripes(base, ink) = tiling(size: (5pt, 5pt))[
///   #place(box(width: 5pt, height: 5pt, fill: base))
///   #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 1pt + ink))
/// ]
/// #let dots(base, ink) = tiling(size: (5pt, 5pt))[
///   #place(box(width: 5pt, height: 5pt, fill: base))
///   #place(dx: 1.5pt, dy: 1.5pt, circle(radius: 1pt, fill: ink))
/// ]
/// #let cross(base, ink) = tiling(size: (6pt, 6pt))[
///   #place(box(width: 6pt, height: 6pt, fill: base))
///   #place(line(start: (0%, 50%), end: (100%, 50%), stroke: 0.7pt + ink))
///   #place(line(start: (50%, 0%), end: (50%, 100%), stroke: 0.7pt + ink))
/// ]
/// #let d = (
///   (g: "a", k: "u", n: 3), (g: "a", k: "v", n: 2), (g: "a", k: "w", n: 4),
///   (g: "b", k: "u", n: 4), (g: "b", k: "v", n: 3), (g: "b", k: "w", n: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "g", y: "n", fill: "k"),
///   layers: (geom-col(position: "dodge"),),
///   scales: scales(fill: scale-manual(values: (
///     stripes(rgb("#fde68a"), rgb("#b45309")),
///     dots(rgb("#bfdbfe"), rgb("#1d4ed8")),
///     cross(rgb("#bbf7d0"), rgb("#047857")),
///   ))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-manual(..args) = _stub("manual", args)

/// Identity scale: use each row's value as the visual output directly.
///
/// Valid on `colour`/`fill`, `alpha`, `size`, `linewidth`, `stroke`, `shape`, and `linetype`. Draws no legend.
///
/// - args: Named arguments forwarded to the bound scale.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-manual`.
///
/// Use a column of colours directly as the fill with an identity scale.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, c: rgb("#e41a1c")),
///   (x: 2, y: 2, c: rgb("#4daf4a")),
///   (x: 3, y: 3, c: rgb("#377eb8")),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "c"),
///   layers: (geom-point(size: 4pt),),
///   scales: scales(fill: scale-identity()),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-identity(..args) = _stub("identity", args)

// Position transform and temporal scales ------------------------------------

/// Position scale on a base-10 log axis (`x` or `y`).
///
/// All mapped values must be strictly positive.
///
/// - args: Named arguments forwarded to the axis scale.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - breaks: Array of tick positions in data units, a bare number for a single tick, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) for computed breaks.
///   - minor-breaks: Array of minor-gridline positions in data units, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) to subdivide the majors, halfway between them in transformed space.
///   - n-minor: Integer count of minor gridlines between adjacent majors, or `auto` (default) for one; ignored when `minor-breaks` is set.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-continuous`, `scale-sqrt`.
///
/// Compress an exponential growth curve onto a log-10 y axis.
///
/// ```typst
/// #let d = range(1, 11).map(i => (x: i, y: calc.pow(2, i)))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: scales(y: scale-log10(name: "Value")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-log10(..args) = _stub("log10", args)

/// Position scale on a square-root axis (`x` or `y`).
///
/// All mapped values must be non-negative.
///
/// - args: Named arguments forwarded to the axis scale.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - breaks: Array of tick positions in data units, a bare number for a single tick, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) for computed breaks.
///   - minor-breaks: Array of minor-gridline positions in data units, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) to subdivide the majors, halfway between them in transformed space.
///   - n-minor: Integer count of minor gridlines between adjacent majors, or `auto` (default) for one; ignored when `minor-breaks` is set.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-continuous`, `scale-log10`.
///
/// Straighten a quadratic relationship on a square-root x axis.
///
/// ```typst
/// #let d = range(0, 11).map(i => (x: i * i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: scales(x: scale-sqrt(name: "x")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-sqrt(..args) = _stub("sqrt", args)

/// Position scale with the axis direction reversed (`x` or `y`).
///
/// Tick labels stay in data units; only the axis direction flips.
///
/// - args: Named arguments forwarded to the axis scale.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - breaks: Array of tick positions in data units, a bare number for a single tick, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) for computed breaks.
///   - minor-breaks: Array of minor-gridline positions in data units, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) to subdivide the majors, halfway between them in transformed space.
///   - n-minor: Integer count of minor gridlines between adjacent majors, or `auto` (default) for one; ignored when `minor-breaks` is set.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-continuous`.
///
/// Reverse the y axis so larger values sit at the bottom.
///
/// ```typst
/// #let d = range(1, 11).map(i => (x: i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   scales: scales(y: scale-reverse(name: "Rank")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-reverse(..args) = _stub("reverse", args)

/// Temporal position scale formatting axis labels as dates (`x` or `y`).
///
/// Column values may be numeric days since 2000-01-01 or ISO-8601 `YYYY-MM-DD` strings.
///
/// - args: Named arguments forwarded to the axis scale.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair of numbers or ISO-8601 strings, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - breaks: Array of tick positions in the scale's numeric units, a bare number for a single tick, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) for computed breaks.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///   - expand: Padding around the domain as a ratio (`5%`), a length (`5pt`), a `relative`, or a `(lo, hi)` pair whose sides may each be `auto`; `false` or `none` removes it. `auto` (default) pads 5% per side.
///   - date-format: Typst `datetime.display` format string; default `"[year]-[month repr:numerical]-[day]"`.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-datetime`, `scale-time`.
///
/// Format an x axis of numeric days since 2000-01-01 as year-month ticks.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: 8766 + 30 * i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-line(), geom-point(size: 2pt)),
///   scales: scales(x: scale-date(date-format: "[year]-[month repr:numerical]")),
///   width: 12cm,
///   height: 6cm,
/// )
/// ```
#let scale-date(..args) = _stub("date", args)

/// Temporal position scale formatting axis labels as datetimes (`x` or `y`).
///
/// - args: Named arguments forwarded to the axis scale.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair of numbers or ISO-8601 strings, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - breaks: Array of tick positions in the scale's numeric units, a bare number for a single tick, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) for computed breaks.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///   - expand: Padding around the domain as a ratio (`5%`), a length (`5pt`), a `relative`, or a `(lo, hi)` pair whose sides may each be `auto`; `false` or `none` removes it. `auto` (default) pads 5% per side.
///   - date-format: Typst `datetime.display` format string; default "[year]-[month repr:numerical]-[day] [hour]:[minute]".
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-date`, `scale-time`.
///
/// Label a y axis of elapsed seconds as clock times.
///
/// ```typst
/// #let d = range(0, 7).map(i => (x: i, y: i * 3600))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-line(),),
///   scales: scales(y: scale-datetime(date-format: "[hour]:[minute]")),
///   width: 12cm,
///   height: 6cm,
/// )
/// ```
#let scale-datetime(..args) = _stub("datetime", args)

/// Temporal position scale formatting axis labels as times (`x` or `y`).
///
/// - args: Named arguments forwarded to the axis scale.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair of numbers or ISO-8601 strings, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - breaks: Array of tick positions in the scale's numeric units, a bare number for a single tick, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) for computed breaks.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///   - expand: Padding around the domain as a ratio (`5%`), a length (`5pt`), a `relative`, or a `(lo, hi)` pair whose sides may each be `auto`; `false` or `none` removes it. `auto` (default) pads 5% per side.
///   - date-format: Typst `datetime.display` format string; default "[hour]:[minute]".
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-date`, `scale-datetime`.
///
/// Label a y axis of elapsed seconds as times of day.
///
/// ```typst
/// #let d = range(0, 7).map(i => (x: i, y: i * 900))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-line(),),
///   scales: scales(y: scale-time()),
///   width: 12cm,
///   height: 6cm,
/// )
/// ```
#let scale-time(..args) = _stub("time", args)

// Colour and fill palette scales --------------------------------------------

/// Discrete viridis colour/fill scale.
///
/// `option` selects `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
///
/// - args: Named arguments forwarded to the colour/fill scale.
///   - option: Viridis variant: `"viridis"` (default), `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Array of level names selecting which levels appear and in which order; `none` (default) keeps the trained levels. A level name must be a string, because a discrete scale reads a bare number as a position rather than as a level, so quote a numeric level as `"1"`.
///   - oob: Handling of rows whose level falls outside `limits`: `"drop"` (default) removes them; `"squish"` censors too, since clamping has no meaning on levels.
///   - labels: Array of labels in level order, a function of the level returning a string or content, or `auto` (default) to print the level itself.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-viridis-c`, `scale-viridis-b`.
///
/// Colour three groups with a discrete viridis palette.
///
/// ```typst
/// #let d = ((x: 1, y: 1, g: "a"), (x: 2, y: 2, g: "b"), (x: 3, y: 3, g: "c"))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt),),
///   scales: scales(colour: scale-viridis-d()),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-viridis-d(..args) = _stub("viridis-d", args)

/// Continuous viridis colour/fill scale.
///
/// - args: Named arguments forwarded to the colour/fill scale.
///   - option: Viridis variant: `"viridis"` (default), `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - breaks: Array of tick positions in data units, a bare number for a single tick, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) for computed breaks.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-viridis-d`, `scale-viridis-b`.
///
/// Map a numeric column onto a continuous viridis fill.
///
/// ```typst
/// #let d = range(1, 8).map(i => (x: i, y: i, w: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "w"),
///   layers: (geom-point(size: 5pt),),
///   scales: scales(fill: scale-viridis-c(option: "magma")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-viridis-c(..args) = _stub("viridis-c", args)

/// Binned viridis colour/fill scale.
///
/// - args: Named arguments forwarded to the colour/fill scale.
///   - option: Viridis variant: `"viridis"` (default), `"magma"`, `"plasma"`, `"inferno"`, or `"cividis"`.
///   - n-breaks: Integer number of equal-width bins used when `breaks` is `auto`; default 5.
///   - breaks: Array of bin edges, a function of the trained values returning edges (the `breaks-*` helpers return such a function), ticked at the bin midpoints and overriding `n-breaks`, or `auto` (default) to cut `n-breaks` equal-width bins.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-viridis-c`, `scale-steps`.
///
/// Bin a numeric column onto a stepped viridis fill.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "w"),
///   layers: (geom-point(size: 5pt),),
///   scales: scales(fill: scale-viridis-b(n-breaks: 4)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-viridis-b(..args) = _stub("viridis-b", args)

/// Discrete ColorBrewer colour/fill scale.
///
/// `palette` names a ColorBrewer set such as `"Set1"` or `"Spectral"`.
///
/// - args: Named arguments forwarded to the colour/fill scale.
///   - palette: ColorBrewer set name resolved through `brewer-palette`, e.g. `"Set1"` or `"Spectral"`; default `"Set1"`.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Array of level names selecting which levels appear and in which order; `none` (default) keeps the trained levels. A level name must be a string, because a discrete scale reads a bare number as a position rather than as a level, so quote a numeric level as `"1"`.
///   - oob: Handling of rows whose level falls outside `limits`: `"drop"` (default) removes them; `"squish"` censors too, since clamping has no meaning on levels.
///   - labels: Array of labels in level order, a function of the level returning a string or content, or `auto` (default) to print the level itself.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-distiller`, `scale-fermenter`.
///
/// Colour groups with a discrete ColorBrewer palette.
///
/// ```typst
/// #let d = ((x: 1, y: 1, g: "a"), (x: 2, y: 2, g: "b"), (x: 3, y: 3, g: "c"))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt),),
///   scales: scales(colour: scale-brewer(palette: "Set1")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-brewer(..args) = _stub("brewer", args)

/// Discrete Okabe-Ito colourblind-safe colour/fill scale.
///
/// - args: Named arguments forwarded to the colour/fill scale.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Array of level names selecting which levels appear and in which order; `none` (default) keeps the trained levels. A level name must be a string, because a discrete scale reads a bare number as a position rather than as a level, so quote a numeric level as `"1"`.
///   - oob: Handling of rows whose level falls outside `limits`: `"drop"` (default) removes them; `"squish"` censors too, since clamping has no meaning on levels.
///   - labels: Array of labels in level order, a function of the level returning a string or content, or `auto` (default) to print the level itself.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-brewer`.
///
/// Colour groups with the colourblind-safe Okabe-Ito palette.
///
/// ```typst
/// #let d = ((x: 1, y: 1, g: "a"), (x: 2, y: 2, g: "b"), (x: 3, y: 3, g: "c"))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt),),
///   scales: scales(colour: scale-okabe-ito()),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-okabe-ito(..args) = _stub("okabe-ito", args)

/// Two-colour continuous gradient colour/fill scale.
///
/// Interpolates between `low` and `high`.
///
/// - args: Named arguments forwarded to the colour/fill scale.
///   - low: Bin or ramp low-end colour; default `rgb("#132B43")`.
///   - high: Bin or ramp high-end colour; default `rgb("#56B1F7")`.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - breaks: Array of tick positions in data units, a bare number for a single tick, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) for computed breaks.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-gradient2`, `scale-gradientn`.
///
/// Interpolate a numeric fill between two colours.
///
/// ```typst
/// #let d = range(1, 8).map(i => (x: i, y: i, w: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "w"),
///   layers: (geom-point(size: 5pt),),
///   scales: scales(fill: scale-gradient(low: rgb("#132B43"), high: rgb("#56B1F7"))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-gradient(..args) = _stub("gradient", args)

/// Diverging three-colour gradient colour/fill scale.
///
/// Interpolates `low`-`mid`-`high` around `midpoint`.
///
/// - args: Named arguments forwarded to the colour/fill scale.
///   - low: Bin or ramp low-end colour; default `rgb("#1F77B4")`.
///   - mid: Bin or ramp midpoint colour; default `rgb("#FFFFFF")`.
///   - high: Bin or ramp high-end colour; default `rgb("#D62728")`.
///   - midpoint: Data value placed at `mid`, in data units; default `0`.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - breaks: Array of tick positions in data units, a bare number for a single tick, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) for computed breaks.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-gradient`, `scale-gradientn`.
///
/// Diverge a signed numeric fill around zero.
///
/// ```typst
/// #let d = range(0, 11).map(i => (x: i, y: i, w: i - 5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "w"),
///   layers: (geom-point(size: 5pt),),
///   scales: scales(fill: scale-gradient2(midpoint: 0)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-gradient2(..args) = _stub("gradient2", args)

/// N-colour continuous gradient colour/fill scale.
///
/// Interpolates through the `colours` array.
///
/// - args: Named arguments forwarded to the colour/fill scale.
///   - colours: Array of colours interpolated in order from the low end of the domain to the high end; default `()` holds no colour, so pass at least two.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - breaks: Array of tick positions in data units, a bare number for a single tick, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) for computed breaks.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-gradient`, `scale-gradient2`.
///
/// Interpolate a numeric fill through several colours.
///
/// ```typst
/// #let d = range(1, 8).map(i => (x: i, y: i, w: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "w"),
///   layers: (geom-point(size: 5pt),),
///   scales: scales(fill: scale-gradientn(
///     colours: (rgb("#000000"), rgb("#888888"), rgb("#ffffff")),
///   )),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-gradientn(..args) = _stub("gradientn", args)

/// Discrete greyscale colour/fill scale.
///
/// `start` and `end` bound the grey range in `[0, 1]`.
///
/// - args: Named arguments forwarded to the colour/fill scale.
///   - start: Lightness of the first grey, a number in `[0, 1]`; default `0.2`.
///   - end: Lightness of the last grey, a number in `[0, 1]`; default `0.8`.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Array of level names selecting which levels appear and in which order; `none` (default) keeps the trained levels. A level name must be a string, because a discrete scale reads a bare number as a position rather than as a level, so quote a numeric level as `"1"`.
///   - oob: Handling of rows whose level falls outside `limits`: `"drop"` (default) removes them; `"squish"` censors too, since clamping has no meaning on levels.
///   - labels: Array of labels in level order, a function of the level returning a string or content, or `auto` (default) to print the level itself.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-brewer`.
///
/// Colour groups along a discrete greyscale ramp.
///
/// ```typst
/// #let d = ((x: 1, y: 1, g: "a"), (x: 2, y: 2, g: "b"), (x: 3, y: 3, g: "c"))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt),),
///   scales: scales(colour: scale-grey(start: 0.1, end: 0.8)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-grey(..args) = _stub("grey", args)

/// Discrete evenly-spaced HCL hue colour/fill scale.
///
/// - args: Named arguments forwarded to the colour/fill scale.
///   - hue: `(start, end)` angle pair sweeping the HCL hue circle; default `(15deg, 375deg)`.
///   - chroma: HCL chroma, a number; default `100`.
///   - luminance: HCL luminance, a number; default `65`.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Array of level names selecting which levels appear and in which order; `none` (default) keeps the trained levels. A level name must be a string, because a discrete scale reads a bare number as a position rather than as a level, so quote a numeric level as `"1"`.
///   - oob: Handling of rows whose level falls outside `limits`: `"drop"` (default) removes them; `"squish"` censors too, since clamping has no meaning on levels.
///   - labels: Array of labels in level order, a function of the level returning a string or content, or `auto` (default) to print the level itself.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-brewer`.
///
/// Colour groups with evenly-spaced HCL hues.
///
/// ```typst
/// #let d = ((x: 1, y: 1, g: "a"), (x: 2, y: 2, g: "b"), (x: 3, y: 3, g: "c"))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt),),
///   scales: scales(colour: scale-hue()),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-hue(..args) = _stub("hue", args)

/// Continuous ColorBrewer colour/fill scale (distiller).
///
/// - args: Named arguments forwarded to the colour/fill scale.
///   - palette: ColorBrewer set name resolved through `brewer-palette`, e.g. `"Set1"` or `"Spectral"`; default `"Spectral"`.
///   - direction: `1` (default) keeps the palette order; a negative value reverses it.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - breaks: Array of tick positions in data units, a bare number for a single tick, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) for computed breaks.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-brewer`, `scale-fermenter`.
///
/// Map a numeric fill through a continuous ColorBrewer ramp.
///
/// ```typst
/// #let d = range(1, 8).map(i => (x: i, y: i, w: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "w"),
///   layers: (geom-point(size: 5pt),),
///   scales: scales(fill: scale-distiller(palette: "Spectral")),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-distiller(..args) = _stub("distiller", args)

/// Binned two-colour gradient colour/fill scale (steps).
///
/// - args: Named arguments forwarded to the colour/fill scale.
///   - low: Bin or ramp low-end colour; default `rgb("#132B43")`.
///   - high: Bin or ramp high-end colour; default `rgb("#56B1F7")`.
///   - n-breaks: Integer number of equal-width bins used when `breaks` is `auto`; default 5.
///   - breaks: Array of bin edges, a function of the trained values returning edges (the `breaks-*` helpers return such a function), ticked at the bin midpoints and overriding `n-breaks`, or `auto` (default) to cut `n-breaks` equal-width bins.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-gradient`, `scale-stepsn`.
///
/// Bin a numeric fill into stepped gradient bands.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "w"),
///   layers: (geom-point(size: 5pt),),
///   scales: scales(fill: scale-steps(n-breaks: 5)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-steps(..args) = _stub("steps", args)

/// Binned diverging three-colour gradient colour/fill scale (steps2).
///
/// - args: Named arguments forwarded to the colour/fill scale.
///   - low: Bin or ramp low-end colour; default `rgb("#005A32")`.
///   - mid: Bin or ramp midpoint colour; default `white`.
///   - high: Bin or ramp high-end colour; default `rgb("#A50026")`.
///   - midpoint: Data value placed at `mid`, in data units; default `0`.
///   - n-breaks: Integer number of equal-width bins used when `breaks` is `auto`; default 5.
///   - breaks: Array of bin edges, a function of the trained values returning edges (the `breaks-*` helpers return such a function), ticked at the bin midpoints and overriding `n-breaks`, or `auto` (default) to cut `n-breaks` equal-width bins.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-gradient2`, `scale-steps`.
///
/// Bin a signed numeric fill into diverging stepped bands.
///
/// ```typst
/// #let d = range(0, 11).map(i => (x: i, y: i, w: i - 5))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "w"),
///   layers: (geom-point(size: 5pt),),
///   scales: scales(fill: scale-steps2(midpoint: 0, n-breaks: 6)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-steps2(..args) = _stub("steps2", args)

/// Binned N-colour gradient colour/fill scale (stepsn).
///
/// - args: Named arguments forwarded to the colour/fill scale.
///   - colours: Array of colours interpolated in order from the low end of the domain to the high end; default `()` holds no colour, so pass at least two.
///   - n-breaks: Integer number of equal-width bins used when `breaks` is `auto`; default 5.
///   - breaks: Array of bin edges, a function of the trained values returning edges (the `breaks-*` helpers return such a function), ticked at the bin midpoints and overriding `n-breaks`, or `auto` (default) to cut `n-breaks` equal-width bins.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-gradientn`, `scale-steps`.
///
/// Bin a numeric fill into N-colour stepped bands.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "w"),
///   layers: (geom-point(size: 5pt),),
///   scales: scales(fill: scale-stepsn(
///     colours: (rgb("#000000"), rgb("#888888"), rgb("#ffffff")),
///     n-breaks: 4,
///   )),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-stepsn(..args) = _stub("stepsn", args)

/// Binned ColorBrewer colour/fill scale (fermenter).
///
/// - args: Named arguments forwarded to the colour/fill scale.
///   - palette: ColorBrewer set name resolved through `brewer-palette`, e.g. `"Set1"` or `"Spectral"`; default `"Spectral"`.
///   - n-breaks: Integer number of equal-width bins used when `breaks` is `auto`; default 5.
///   - breaks: Array of bin edges, a function of the trained values returning edges (the `breaks-*` helpers return such a function), ticked at the bin midpoints and overriding `n-breaks`, or `auto` (default) to cut `n-breaks` equal-width bins.
///   - direction: `1` (default) keeps the palette order; a negative value reverses it.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-distiller`, `scale-steps`.
///
/// Bin a numeric fill into ColorBrewer stepped bands.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: i, y: i, w: i + 1))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "w"),
///   layers: (geom-point(size: 5pt),),
///   scales: scales(fill: scale-fermenter(palette: "Spectral", n-breaks: 5)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-fermenter(..args) = _stub("fermenter", args)

// Size scales ---------------------------------------------------------------

/// Area-proportional continuous size scale.
///
/// Marker area, rather than diameter, scales linearly with the value.
///
/// - args: Named arguments forwarded to the size scale.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - range: Marker-radius `(lo, hi)` length pair; default `(1pt, 6pt)`.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - breaks: Array of tick positions in data units, a bare number for a single tick, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) for computed breaks.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-continuous`, `scale-radius`.
///
/// Scale marker area, not diameter, with the value.
///
/// ```typst
/// #let d = range(1, 8).map(i => (x: i, y: i, w: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "w"),
///   layers: (geom-point(),),
///   scales: scales(size: scale-area(range: (1pt, 12pt))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-area(..args) = _stub("area", args)

/// Binned area-proportional size scale.
///
/// - args: Named arguments forwarded to the size scale.
///   - n-breaks: Integer number of equal-width bins used when `breaks` is `auto`; default 4.
///   - breaks: Array of bin edges, a function of the trained values returning edges (the `breaks-*` helpers return such a function), ticked at the bin midpoints and overriding `n-breaks`, or `auto` (default) to cut `n-breaks` equal-width bins.
///   - range: Marker-radius `(lo, hi)` length pair; default `(1pt, 6pt)`.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-area`, `scale-binned`.
///
/// Bin an area-proportional size scale into discrete steps.
///
/// ```typst
/// #let d = range(1, 8).map(i => (x: i, y: i, w: i * i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "w"),
///   layers: (geom-point(),),
///   scales: scales(size: scale-binned-area(n-breaks: 4, range: (1pt, 12pt))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-binned-area(..args) = _stub("binned-area", args)

/// Linear-radius continuous size scale.
///
/// The explicit-name alias for a linear value-to-radius size mapping. The area-proportional variant is `scale-area`.
///
/// - args: Named arguments forwarded to the size scale.
///   - name: Axis or legend title, as a string or content; `none` (default) falls back to the mapped column name.
///   - range: Marker-radius `(lo, hi)` length pair; default `(1pt, 6pt)`.
///   - limits: Domain as a `(lo, hi)` pair, where either side may be `auto` to train that side from the data; `none` (default) trains both sides.
///   - oob: Handling of rows outside `limits`: `"drop"` (default) removes them, `"squish"` clamps them to the nearest limit.
///   - breaks: Array of tick positions in data units, a bare number for a single tick, a function of the trained values returning positions (the `breaks-*` helpers return such a function), or `auto` (default) for computed breaks.
///   - labels: Array of labels aligned with the breaks, a function of the break value returning a string or content (the `format-*` helpers return such a function), or `auto` (default) to format each break.
///
/// Returns: Deferred scale spec consumed by `scales`.
///
/// See also: `scales`, `scale-continuous`, `scale-area`.
///
/// Scale marker radius linearly with the value.
///
/// ```typst
/// #let d = range(1, 8).map(i => (x: i, y: i, w: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", size: "w"),
///   layers: (geom-point(),),
///   scales: scales(size: scale-radius(range: (1pt, 8pt))),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-radius(..args) = _stub("radius", args)
