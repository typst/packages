///! Temporal position scales: date, datetime, and time.
///!
///! These wrappers train a continuous numeric domain like \@scale-x-continuous
///! and only differ at axis-label time, where the numeric break is converted
///! back to a Typst `datetime` against a fixed epoch and rendered through
///! `dt.display(date-format)`.
///!
///! Input contract: column values may be numeric (already encoded against
///! the epoch documented on each scale) or ISO-8601 strings, which the
///! scale parses on the fly during training.

#let _temporal-scale(
  aesthetic,
  temporal,
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
  expand: auto,
  date-format: none,
) = (
  kind: "scale",
  aesthetic: aesthetic,
  type: "continuous",
  temporal: temporal,
  date-format: date-format,
  name: name,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  expand: expand,
)

/// Continuous x scale that formats axis labels as dates.
///
/// Column values may be numeric days since 2000-01-01 or ISO-8601 strings of the form `YYYY-MM-DD`. Each break is converted via `datetime(year: 2000, month: 1, day: 1) + duration(days: int(n))` and rendered with `dt.display(date-format)`.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain (in days), or `none` for automatic limits.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values (in days), or `auto` for automatic tick selection.
/// - labels: Array of tick labels aligned with `breaks`, or `auto`.
/// - date-format: Typst `datetime.display` pattern used for break labels.
/// - expand: Padding around the domain. Accepts a `ratio` (`5%`) for proportional breathing room, a `length` (`5pt`) for canvas-space padding, a `relative` (`5pt + 5%`) for both, or a `(lo, hi)` 2-tuple for asymmetric padding. `auto` keeps the per-scale default; `false` collapses to zero.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-y-date`, `scale-x-datetime`, `scale-x-continuous`.
///
/// Numeric days since 2000-01-01 formatted as year-month ticks.
///
/// ```typst
/// #let d = range(0, 12).map(i => (x: 8766 + 30 * i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-line(), geom-point(size: 2pt)),
///   scales: (scale-x-date(date-format: "[year]-[month repr:numerical]"),),
///   width: 12cm,
///   height: 6cm,
/// )
/// ```
///
/// ISO-8601 strings work just as well; pick a longer `date-format` to spell the month out.
///
/// ```typst
/// #let d = (
///   (x: "2024-01-15", y: 1),
///   (x: "2024-04-15", y: 4),
///   (x: "2024-07-15", y: 9),
///   (x: "2024-10-15", y: 16),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-line(), geom-point(size: 2pt)),
///   scales: (scale-x-date(date-format: "[month repr:short] [year]"),),
///   width: 12cm,
///   height: 6cm,
/// )
/// ```
#let scale-x-date(
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
  expand: auto,
  date-format: "[year]-[month repr:numerical]-[day]",
) = _temporal-scale(
  "x",
  "date",
  name: name,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  expand: expand,
  date-format: date-format,
)

/// Continuous y scale that formats axis labels as dates.
///
/// Column values may be numeric days since 2000-01-01 or ISO-8601 strings of the form `YYYY-MM-DD`.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain (in days), or `none` for automatic limits.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values (in days), or `auto` for automatic tick selection.
/// - labels: Array of tick labels aligned with `breaks`, or `auto`.
/// - date-format: Typst `datetime.display` pattern used for break labels.
/// - expand: Padding around the domain. Accepts a `ratio` (`5%`) for proportional breathing room, a `length` (`5pt`) for canvas-space padding, a `relative` (`5pt + 5%`) for both, or a `(lo, hi)` 2-tuple for asymmetric padding. `auto` keeps the per-scale default; `false` collapses to zero.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-x-date`, `scale-y-datetime`.
///
/// Date axis on the y, useful for horizontal bar charts of time-stamped events.
///
/// ```typst
/// #let d = (
///   (label: "Alpha", y: "2024-01-15"),
///   (label: "Beta",  y: "2024-03-01"),
///   (label: "Gamma", y: "2024-05-20"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "label", y: "y"),
///   layers: (geom-point(size: 4pt),),
///   scales: (scale-y-date(date-format: "[month repr:short] [day]"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-y-date(
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
  expand: auto,
  date-format: "[year]-[month repr:numerical]-[day]",
) = _temporal-scale(
  "y",
  "date",
  name: name,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  expand: expand,
  date-format: date-format,
)

/// Continuous x scale that formats axis labels as datetimes.
///
/// Column values may be numeric seconds since 2000-01-01T00:00:00 or ISO-8601 strings of the form `YYYY-MM-DDTHH:MM[:SS]` or `YYYY-MM-DD HH:MM[:SS]`. Each break is converted via `datetime(year: 2000, month: 1, day: 1, hour: 0, minute: 0, second: 0) + duration(seconds: int(n))` and rendered with `dt.display(date-format)`.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain (in seconds), or `none` for automatic limits.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values (in seconds), or `auto` for automatic tick selection.
/// - labels: Array of tick labels aligned with `breaks`, or `auto`.
/// - date-format: Typst `datetime.display` pattern used for break labels.
/// - expand: Padding around the domain. Accepts a `ratio` (`5%`) for proportional breathing room, a `length` (`5pt`) for canvas-space padding, a `relative` (`5pt + 5%`) for both, or a `(lo, hi)` 2-tuple for asymmetric padding. `auto` keeps the per-scale default; `false` collapses to zero.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-y-datetime`, `scale-x-date`, `scale-x-time`.
///
/// ISO-8601 datetime strings rendered with hour-and-minute ticks.
///
/// ```typst
/// #let d = range(0, 6).map(i => (
///   x: "2024-04-01T0" + str(8 + i) + ":00",
///   y: i * i,
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-line(), geom-point(size: 2pt)),
///   scales: (scale-x-datetime(date-format: "[hour]:[minute]"),),
///   width: 12cm,
///   height: 6cm,
/// )
/// ```
#let scale-x-datetime(
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
  expand: auto,
  date-format: "[year]-[month repr:numerical]-[day] [hour]:[minute]",
) = _temporal-scale(
  "x",
  "datetime",
  name: name,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  expand: expand,
  date-format: date-format,
)

/// Continuous y scale that formats axis labels as datetimes.
///
/// Column values may be numeric seconds since 2000-01-01T00:00:00 or ISO-8601 strings of the form `YYYY-MM-DDTHH:MM[:SS]` or `YYYY-MM-DD HH:MM[:SS]`.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain (in seconds), or `none` for automatic limits.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values (in seconds), or `auto` for automatic tick selection.
/// - labels: Array of tick labels aligned with `breaks`, or `auto`.
/// - date-format: Typst `datetime.display` pattern used for break labels.
/// - expand: Padding around the domain. Accepts a `ratio` (`5%`) for proportional breathing room, a `length` (`5pt`) for canvas-space padding, a `relative` (`5pt + 5%`) for both, or a `(lo, hi)` 2-tuple for asymmetric padding. `auto` keeps the per-scale default; `false` collapses to zero.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-x-datetime`, `scale-y-date`.
///
/// Datetime axis on the y, useful for laying out events along a vertical timeline.
///
/// ```typst
/// #let d = range(0, 6).map(i => (
///   x: i,
///   y: "2024-04-01T0" + str(8 + i) + ":00",
/// ))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-y-datetime(date-format: "[hour]:[minute]"),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-y-datetime(
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
  expand: auto,
  date-format: "[year]-[month repr:numerical]-[day] [hour]:[minute]",
) = _temporal-scale(
  "y",
  "datetime",
  name: name,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  expand: expand,
  date-format: date-format,
)

/// Continuous x scale that formats axis labels as times of day.
///
/// Column values may be numeric seconds since midnight (an integer in `[0, 86400)`) or ISO-8601 strings of the form `HH:MM[:SS]`. Each break is converted via `datetime(year: 2000, month: 1, day: 1, hour: 0, minute: 0, second: 0) + duration(seconds: int(n))` and rendered with `dt.display(date-format)`; only the time portion of the pattern should be used.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain (in seconds), or `none` for automatic limits.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values (in seconds), or `auto` for automatic tick selection.
/// - labels: Array of tick labels aligned with `breaks`, or `auto`.
/// - date-format: Typst `datetime.display` pattern used for break labels.
/// - expand: Padding around the domain. Accepts a `ratio` (`5%`) for proportional breathing room, a `length` (`5pt`) for canvas-space padding, a `relative` (`5pt + 5%`) for both, or a `(lo, hi)` 2-tuple for asymmetric padding. `auto` keeps the per-scale default; `false` collapses to zero.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-y-time`, `scale-x-datetime`.
///
/// Time-of-day axis using ISO-8601 `HH:MM` strings.
///
/// ```typst
/// #let d = (
///   (x: "08:00", y: 1),
///   (x: "10:00", y: 4),
///   (x: "12:00", y: 9),
///   (x: "16:00", y: 16),
///   (x: "20:00", y: 5),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-line(), geom-point(size: 2pt)),
///   scales: (scale-x-time(),),
///   width: 12cm,
///   height: 6cm,
/// )
/// ```
#let scale-x-time(
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
  expand: auto,
  date-format: "[hour]:[minute]",
) = _temporal-scale(
  "x",
  "time",
  name: name,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  expand: expand,
  date-format: date-format,
)

/// Continuous y scale that formats axis labels as times of day.
///
/// Column values may be numeric seconds since midnight (an integer in `[0, 86400)`) or ISO-8601 strings of the form `HH:MM[:SS]`.
///
/// - name: Axis title. Overrides any name set via `labs` when both are present.
/// - limits: Pair `(lo, hi)` clipping the trained domain (in seconds), or `none` for automatic limits.
/// - oob: Out-of-range policy: `"drop"` (default) removes rows whose value falls outside `limits`; `"squish"` clamps continuous values to the nearest endpoint.
/// - breaks: Array of break values (in seconds), or `auto` for automatic tick selection.
/// - labels: Array of tick labels aligned with `breaks`, or `auto`.
/// - date-format: Typst `datetime.display` pattern used for break labels.
/// - expand: Padding around the domain. Accepts a `ratio` (`5%`) for proportional breathing room, a `length` (`5pt`) for canvas-space padding, a `relative` (`5pt + 5%`) for both, or a `(lo, hi)` 2-tuple for asymmetric padding. `auto` keeps the per-scale default; `false` collapses to zero.
///
/// Returns: Scale object consumed by `plot`.
///
/// See also: `scale-x-time`, `scale-y-datetime`.
///
/// Time-of-day axis on the y for vertical event displays.
///
/// ```typst
/// #let d = (
///   (x: "Mon", y: "08:30"),
///   (x: "Tue", y: "09:15"),
///   (x: "Wed", y: "10:00"),
///   (x: "Thu", y: "08:45"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   scales: (scale-y-time(),),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let scale-y-time(
  name: none,
  limits: none,
  oob: "drop",
  breaks: auto,
  labels: auto,
  expand: auto,
  date-format: "[hour]:[minute]",
) = _temporal-scale(
  "y",
  "time",
  name: name,
  limits: limits,
  oob: oob,
  breaks: breaks,
  labels: labels,
  expand: expand,
  date-format: date-format,
)
