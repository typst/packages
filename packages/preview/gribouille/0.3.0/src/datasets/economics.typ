///! Bundled economics dataset.
///!
///! A 24-row monthly subset spanning 2008-01-01 to 2009-12-01.
///! The window covers the 2008 recession so the trends are visibly
///! non-trivial in time-series demos.
///!
///! Values are synthetic but plausible: `pce` and `pop` rise broadly,
///! `psavert` climbs as households rebuild savings, and `unemploy`
///! and `uempmed` peak through 2009.

/// US monthly economic time series (subset).
///
/// Each row is a month from 2008-01-01 to 2009-12-01. Columns:
///
/// - `date` (string `"YYYY-MM-DD"`).
/// - `pce` (personal consumption expenditures, billions of dollars).
/// - `pop` (total population, thousands).
/// - `psavert` (personal savings rate, percent).
/// - `uempmed` (median duration of unemployment, weeks).
/// - `unemploy` (number of unemployed, thousands).
///
/// The bundled literal is stored in column-store form; `plot` accepts either column-store or row-store input and normalises internally.
///
/// **Source:** shape and column definitions follow the `economics` dataset bundled with the ggplot2 R package; see `help("economics")` in R. Original series come from the US Federal Reserve Economic Data (FRED), <https://fred.stlouisfed.org/>:
///
/// - `pce`: <https://fred.stlouisfed.org/series/PCE>.
/// - `pop`: <https://fred.stlouisfed.org/series/POP>.
/// - `psavert`: <https://fred.stlouisfed.org/series/PSAVERT>.
/// - `uempmed`: <https://fred.stlouisfed.org/series/UEMPMED>.
/// - `unemploy`: <https://fred.stlouisfed.org/series/UNEMPLOY>.
///
/// Preview all 24 entries.
///
/// ```typst
/// #let cols = economics.pairs()
/// #let cell(v) = if v == none { text(fill: gray, [_none_]) } else { [#v] }
/// #table(
///   columns: cols.len(),
///   align: center + horizon,
///   inset: 5pt,
///   stroke: 0.5pt,
///   ..cols.map(p => strong(raw(p.at(0)))),
///   ..range(cols.first().at(1).len()).map(i => cols.map(p => cell(p.at(1).at(i)))).flatten(),
/// )
/// ```
///
/// Plot the unemployment series over time using `date` as a continuous date axis.
///
/// ```typst
/// #plot(
///   data: economics,
///   mapping: aes(x: "date", y: "unemploy"),
///   layers: (geom-line(stroke: 1pt),),
///   scales: (scale-x-date(),),
///   width: 11cm,
///   height: 6cm,
/// )
/// ```
///
/// Stack two layers with their own y mappings to compare two series on the same panel.
///
/// ```typst
/// #plot(
///   data: economics,
///   mapping: aes(x: "date"),
///   layers: (
///     geom-line(mapping: aes(y: "psavert"), colour: rgb("#1b9e77"), stroke: 1pt),
///     geom-line(mapping: aes(y: "uempmed"), colour: rgb("#d95f02"), stroke: 1pt),
///   ),
///   scales: (scale-x-date(),),
///   labs: labs(y: "Percent / Weeks"),
///   width: 11cm,
///   height: 6cm,
/// )
/// ```
#let economics = (
  date: (
    "2008-01-01",
    "2008-02-01",
    "2008-03-01",
    "2008-04-01",
    "2008-05-01",
    "2008-06-01",
    "2008-07-01",
    "2008-08-01",
    "2008-09-01",
    "2008-10-01",
    "2008-11-01",
    "2008-12-01",
    "2009-01-01",
    "2009-02-01",
    "2009-03-01",
    "2009-04-01",
    "2009-05-01",
    "2009-06-01",
    "2009-07-01",
    "2009-08-01",
    "2009-09-01",
    "2009-10-01",
    "2009-11-01",
    "2009-12-01",
  ),
  pce: (
    9846,
    9870,
    9905,
    9935,
    9985,
    9988,
    9966,
    9923,
    9853,
    9728,
    9613,
    9561,
    9533,
    9555,
    9543,
    9551,
    9587,
    9608,
    9635,
    9678,
    9697,
    9737,
    9778,
    9821,
  ),
  pop: (
    303516,
    303695,
    303881,
    304093,
    304322,
    304563,
    304809,
    305042,
    305259,
    305469,
    305680,
    305869,
    306051,
    306243,
    306437,
    306648,
    306871,
    307108,
    307354,
    307589,
    307795,
    308013,
    308222,
    308417,
  ),
  psavert: (
    3.0,
    3.2,
    3.5,
    3.6,
    5.5,
    4.7,
    4.5,
    4.0,
    4.2,
    5.4,
    6.4,
    6.4,
    5.7,
    5.0,
    5.3,
    6.7,
    7.5,
    6.4,
    5.7,
    4.9,
    4.8,
    5.0,
    5.1,
    5.0,
  ),
  uempmed: (
    8.6,
    8.9,
    9.0,
    8.9,
    9.4,
    10.1,
    9.7,
    9.7,
    10.2,
    10.4,
    9.8,
    10.5,
    10.7,
    11.7,
    12.3,
    13.1,
    14.2,
    17.2,
    16.0,
    16.3,
    17.6,
    18.9,
    19.8,
    20.1,
  ),
  unemploy: (
    7685,
    7497,
    7822,
    7637,
    8395,
    8575,
    8937,
    9438,
    9494,
    10074,
    10538,
    11286,
    12058,
    12898,
    13426,
    13853,
    14499,
    14707,
    14601,
    14814,
    15009,
    15352,
    15219,
    15098,
  ),
)
