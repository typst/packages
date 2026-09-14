/// Styles to format a time zone.
///
/// Corresponds to the `zone-style` argument of `fmt`.
///
/// Note that both the offset and a time zone name (IANA or BCP47) must be given to `zone`.
///
/// ```
/// #icu.fmt(
///   datetime.today(),
///   zone: (offset: "+01", iana: "Europe/Berlin"),
///   zone-style: icu.zone-styles.specific-long
/// ) // Central European Standard Time
/// ```
///
/// - specific-long: The long specific non-location format, as in "Pacific Daylight Time".
/// - specific-short: The short specific non-location format, as in "PDT".
/// - localized-offset-long: The long offset format, as in "GMT−8:00".
/// - localized-offset-short: The short offset format, as in "GMT−8".
/// - generic-long: The long generic non-location format, as in "Pacific Time".
/// - generic-short: The short generic non-location format, as in "PT".
/// - location: The location format, as in "Los Angeles time".
/// - exemplar-city: The exemplar city format, as in "Los Angeles".
#let zone-styles = (
  specific-long: "specific-long",
  specific-short: "specific-short",
  localized-offset-long: "localized-offset-long",
  localized-offset-short: "localized-offset-short",
  generic-long: "generic-long",
  generic-short: "generic-short",
  location: "location",
  exemplar-city: "exemplar-city",
)

/// The length of the formatted date/time.
///
/// Corresponds to the `length` argument of `fmt`.
///
/// - long: A long date; typically spelled-out, as in "January 1, 2000".
/// - medium: A medium-sized date; typically abbreviated, as in "Jan. 1, 2000".
/// - short: A short date; typically numeric, as in "1/1/2000".
#let length = (
  long: "long",
  medium: "medium",
  short: "short",
)

/// Fields of the date to include.
///
/// Corresponds to the `date-fields` argument of `fmt`.
///
/// - D: Day of the month
/// - E: Day of the week
/// - M: Month
/// - Y: Year
#let date-fields = (
  D: "D",
  MD: "MD",
  YMD: "YMD",
  DE: "DE",
  MDE: "MDE",
  YMDE: "YMDE",
  E: "E",
  M: "M",
  YM: "YM",
  Y: "Y",
)

/// How precise the time should be included.
///
/// Corresponds to the `time-precision` argument of `fmt`.
///
/// - hour: Only show the hour.
/// - minute: Show the hour and minute.
/// - second: Show hour, minute, and second.
/// - subsecond{n}: Show n fractional digits for the seconds.
/// - minute-optional: Show the hour and add the minute if it's non-zero.
#let time-precision = (
  hour: "hour",
  minute: "minute",
  second: "second",
  subsecond1: "subsecond1",
  subsecond2: "subsecond2",
  subsecond3: "subsecond3",
  subsecond4: "subsecond4",
  subsecond5: "subsecond5",
  subsecond6: "subsecond6",
  subsecond7: "subsecond7",
  subsecond8: "subsecond8",
  subsecond9: "subsecond9",
  minute-optional: "minute-optional",
)

/// How the numbers should be aligned.
///
/// Corresponds to the `alignment` argument of `fmt`.
///
/// - auto: Use locale specific alignment.
/// - column: Align the values for a column layout (i.e. pad with fields if necessary).
#let alignment = (
  auto_: "auto",
  column: "column",
)

/// How the year should be displayed.
///
/// Corresponds to the `year-style` argument of `fmt`.
///
/// - auto: Display the century and/or era when needed to disambiguate.
/// - full: Always display the century, and display the era when needed to disambiguate.
/// - with-era: Always display the century and era.
#let year-styles = (
  auto_: "auto",
  full: "full",
  with-era: "with-era",
)
