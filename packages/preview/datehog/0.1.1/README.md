# datehog

Date parsing and epoch arithmetic for Typst. \
For the changes see the [Changelog](./CHANGELOG.md).

Typst's built-in `datetime` can be constructed from calendar parts and
formatted, but it cannot parse a string and has no epoch conversion:

```typst
#datetime("2020-03-14")   // error: unexpected argument
#d.timestamp()            // error: type datetime has no method `timestamp`
```

datehog fills exactly that gap. Strings and epoch milliseconds in, a plain
dictionary out, everything in UTC, everything a pure function.

Status: unit tests pass; **29 031/29 031** calendar dates from 1600–2400 match
Python's `datetime`; **445/445** parser cases match the reference implementation
it is calibrated against. Details under [Testing](#testing).

```typst
#import "@preview/datehog:0.1.1" as dh

#dh.parse("2020-03-14T08:30:00Z").day        // 14
#dh.parse("Feb 2020").month                  // 2
#dh.parse-ms("15 February 2020")             // 1581724800000
#dh.to-iso(dh.from-ms(1584174600000))        // "2020-03-14T08:30:00.000Z"
#dh.to-iso-date(dh.add-months(dh.parse("2020-01-31"), 1))   // "2020-02-29"
```

## The moment type

Everything resolves to a *moment*: an instant in UTC as an ordinary
dictionary, so it prints under `repr`, compares with `==`, and is memoised by
Typst like any other value.

```typst
#dh.from-ms(1584174600250)
// (datehog: "moment", ms: 1584174600250,
//  year: 2020, month: 3, day: 14,
//  hour: 8, minute: 30, second: 0, millisecond: 250,
//  weekday: 6, ordinal: 74)
```

`weekday` is ISO (Monday = 1, Sunday = 7); `ordinal` is the day of the year.

## API

**Parsing** — all return a moment, or `none` for unparseable input. Nothing
ever panics: a bad cell in a data table must not take down the document.

| | |
|---|---|
| `parse(value, assume-offset: 0)` | every strategy, in JavaScript's order |
| `parse-ms(value, assume-offset: 0)` | the same, as epoch milliseconds |
| `is-parseable(value)` | would parsing succeed? |
| `parse-iso(s, assume-offset: 0)` | strict ISO 8601 / ECMAScript only |
| `parse-numeric(s, assume-offset: 0)` | `M/D/YYYY`, `YYYY-M-D` and dot/dash variants |
| `parse-loose(s, assume-offset: 0)` | month names and RFC 2822 |
| `is-iso-date-only(s)`, `is-numeric-date-shape(s)` | shape predicates |
| `year-from-words(s)` | the year in `"FY 2018"` |
| `offset-from-string(s)` | `"+02:00"` → `120` minutes east of UTC |
| `local-offset(key: "tz", default: 0)` | that offset from `sys.inputs` — see [Timezones](#timezones-utc-by-default-deliberately) |
| `expand-two-digit-year(s)` | `"99"` → `"1999"`, `"20"` → `"2020"` |

**Construction and conversion**

| | |
|---|---|
| `from-ms(ms)`, `to-ms(m)` | epoch milliseconds |
| `from-parts(y, m, d, hour: .., minute: .., second: .., millisecond: ..)` | UTC calendar parts |
| `to-seconds(m)`, `to-days(m)` | floored epoch seconds / days |
| `to-iso(m)` | `2020-03-14T08:30:00.000Z` |
| `to-iso-date(m)` | `2020-03-14` |
| `from-typst-datetime(d)`, `to-typst-datetime(m)` | interop (lossy: no milliseconds) |
| `is-moment(v)`, `pad(n, width)` | |

**Arithmetic** — `add-ms`, `add-days`, `add-months` (clamps: Jan 31 + 1 month
is Feb 29, not Mar 2).

**Calendar** — `is-leap-year`, `days-in-month`, `is-valid-date`,
`days-from-civil`, `civil-from-days`, `weekday-from-days`,
`ordinal-from-civil`.

**Names** — `month-name`, `month-from-name`, `weekday-name`, plus the
`MONTH-NAMES` / `MONTH-ABBR` / `WEEKDAY-NAMES` / `WEEKDAY-ABBR` tables.

## Timezones: UTC by default, deliberately

**Zoneless input is read as UTC.** An explicit zone in the string always wins;
`assume-offset` (minutes east of UTC) applies when there is none.

```typst
#dh.to-iso(dh.parse-iso("2020-03-14T08:30:00"))                    // 08:30 Z
#dh.to-iso(dh.parse-iso("2020-03-14T08:30:00", assume-offset: 120)) // 06:30 Z
#dh.to-iso(dh.parse-iso("2020-03-14T08:30:00Z", assume-offset: 120))// 08:30 Z
```

ECMAScript reads a zoneless date-*time* string in the host's local zone. datehog
cannot, because **Typst cannot discover the host's timezone at all**. This is
worth spelling out, because two plausible workarounds both fail.

*Deriving it from `datetime.today()`* does not work. It returns a local date but
no time of day, so there is nothing to compare against UTC at better than
one-day resolution, and `datetime.today(offset: n)` requires you to supply the
offset rather than reporting it. Scanning does not recover it either — at the
time of writing, 14 different offsets all reproduce `datetime.today()`'s date:

```typst
#let local = datetime.today().display("[year]-[month]-[day]")
#range(-12, 15).filter(n => datetime.today(offset: n).display("[year]-[month]-[day]") == local)
// (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
```

*Shipping a wasm plugin to read it* does not work either. Typst plugins run in
`wasmi` with no WASI and exactly one host import —
`typst_env.wasm_minimal_protocol_send_result_to_host`, the result callback. A
plugin is a pure function over the bytes Typst hands it. Compiling
`std::env::var("TZ")` or `SystemTime::now()` into a plugin succeeds, and both
then trap at runtime with `plugin panicked: wasm 'unreachable' instruction
executed`, because neither has an implementation on `wasm32-unknown-unknown`.
There is no clock and no environment inside the sandbox to reach.

### Passing the offset in

Since the offset cannot be discovered, it has to be supplied. `local-offset`
reads it from `sys.inputs`:

```sh
typst compile --input tz="$(date +%z)" doc.typ
```

```typst
#let tz = dh.local-offset()                      // +0200 -> 120
#dh.parse("2020-03-14T08:30:00", assume-offset: tz)
```

`offset-from-string` accepts `Z`, `+02:00`, `+0200`, `-05`, `UTC+02:00` or a
bare minute count. IANA names like `Europe/Berlin` are **not** supported —
resolving those needs the tzdata database, which does not belong in a date
package — and `local-offset` falls back to its default rather than failing, so a
document still compiles either way.

One caveat worth stating: `date +%z` is the offset *now*. For data spanning a
DST boundary it is wrong for half the rows. Where that matters, prefer input
that carries its own zone — a string with an explicit offset always wins over
`assume-offset`.

### Why UTC is the right default anyway

Local-time parsing makes a document render differently depending on the machine
that compiled it — a chart axis shifting by a day between a laptop in Berlin and
CI in UTC is a bug, not a feature. Defaulting to UTC means a document that says
nothing about timezones is reproducible; a document that cares says so
explicitly.

## JavaScript compatibility

`dh.js` reproduces V8's `Date.parse` closely enough to port JavaScript code
that depends on it. The ordering — strict ISO, then numeric forms, then
month-name forms, then the trailing-year heuristic — matches V8's, including
two behaviours strict parsers get differently:

- **V8 accepts** `"FY 2018"`, `"hello world 2018"` — words plus exactly one
  four-digit year — as January 1 of that year. Real spreadsheet columns look
  like this, so it matters.
- **V8 rejects** `"15.01.2020"` and `"15/01/2020"`: it reads the first
  component as a month, and 15 is not a month. Lenient parsers read these as
  15 January. datehog rejects them, as V8 does.

Also in `dh.js`: `is-likely-timestamp(n)` and `timestamp-to-ms(n)`, for the
common case of a numeric column that is really seconds or milliseconds since
the epoch.

### Known divergences from V8

datehog is bug-for-bug compatible with [flint-chart]'s Python port of these
semantics, which is stricter than V8 in three places. Where V8 is more
permissive, datehog follows the stricter reading:

| input | V8 | datehog |
|---|---|---|
| `"Stage 1"`, `"Round 2"`, `"Wk 01"` | parses (reads the trailing digit as a month) | `none` |
| `"2020-02-30"`, `"2019-02-29"` | overflows into the next month | `none` |
| `"1/2/3"` (no four-digit component) | parses | `none` |
| `"2018 FY"` (year first) | `none` | parses |

The first row is worth knowing about if you are porting: V8 will happily treat
a column of `"Stage 1"`, `"Stage 2"` … as *dates*, which is almost never what
the data means.

[flint-chart]: https://github.com/microsoft/flint-chart

## Performance

Every parser is a pure top-level function and every regex is bound at module
level, so Typst memoises parses and compiles each pattern once. Real data
re-presents the same handful of dates thousands of times, and that is where
this pays:

| 50 000 `parse-ms` calls | time |
|---|---|
| 500 distinct values | **278 ms** |
| all distinct | 857 ms |

About 3.1× at a realistic redundancy ratio, for free. If you are building your
own helpers on top, keep them top-level and pure for the same reason — but
don't wrap trivial checks in functions, where the call plus cache lookup costs
more than the check.

The calendar conversions go through Typst's native `datetime` and `duration`
rather than a reimplemented calendar: subtracting two datetimes gives a
duration, adding one back gives a datetime, and that covers every conversion
between a date and a day count. One definition of the Gregorian calendar is in
play, not two — and it is faster, since the built-in is Rust and hand-rolled
arithmetic would be interpreted (measured: ~13 % quicker on the cold path).

Milliseconds are the exception. Native datetimes have second resolution, so a
moment tracks the day count and intraday milliseconds itself and only reaches
for `datetime` at the date boundary.

## Implementation notes

Three constraints shaped the code, all of them worth knowing if you extend it.

**Typst's regex engine has no backreferences.** It is Rust's `regex` crate,
which is finite-automaton based. A pattern like

```regex
^\s*(\d{1,4})\s*([./-])\s*(\d{1,2})\s*\2\s*(\d{1,4})\s*$
```

— requiring the two separators in `01/15/2020` to be the *same* character — is
rejected outright rather than silently misbehaving. `parse-numeric` captures
both separators and compares them in code instead. Expect this anywhere you
port a pattern from a PCRE-family engine.

**Integer division must be `calc.div-euclid`, never `/`.** In Typst `/` yields
a float, so a day count past 2^53 would lose exactness silently. Every division
in `civil.typ` is floor division on integers. (`calc.div-euclid(-7, 2) == -4`,
which is what the calendar algorithms need for pre-epoch dates.)

**Multi-line expressions need parentheses, and continuation lines cannot lead
with an operator.** `a and\n b` is a parse error, and `"x"\n + "y"` parses the
`+` as unary and fails at runtime. Wrap the whole expression in `(...)` and keep
operators at line ends.

## Compatibility

Verified on **Typst 0.15.1**. `typst.toml` declares a floor of 0.13.0, which is
a conservative estimate rather than a tested one — nothing here uses a recent
feature, but older releases have not been exercised. If you hit a problem on an
earlier version, that floor is the thing to correct.

## Comparing against another implementation

If you are diffing datehog against a JavaScript or Python reference, **run the
reference under `TZ=UTC`**. Both interpret zoneless date-time strings in the
host zone, so their output is machine-dependent; datehog's is not. Getting this
wrong produces differences that look like parser bugs and are really timezone
drift — in one real corpus of 705 chart fixtures, 15 changed value depending on
the build machine's timezone, all in the hour-of-day and `"Mon YYYY"` groups.

`tests/compare.py` sets `TZ=UTC` for both reference runners for this reason.

## Range and safety

Native datetimes span years **-9999 to 9999**, and that is datehog's range too.
Outside it every entry point returns `none`.

That is not politeness, it is necessary. Typst's datetime has two failure modes
neither of which can be caught:

- `datetime(year: 2020, month: 2, day: 30)` is a Typst **error**, so nothing
  here constructs one without validating first — which is why a month-length
  table survives in `civil.typ` despite the rest being native.
- Overrunning the upper bound is a **compiler panic** inside the underlying
  `time` crate, not a Typst error at all. `from-ms(MAX-MS + 1)` returns `none`
  precisely so that a stray value in a data column cannot take the compiler
  down.

`MIN-YEAR`, `MAX-YEAR`, `MIN-DAYS`, `MAX-DAYS`, `MIN-MS`, `MAX-MS` and the
predicates `is-year-in-range` / `is-days-in-range` are exported for callers who
want to check before converting.

## Testing

```bash
./tests/run.sh          # unit tests + calendar differential
./tests/run.sh --all    # also the V8 / flint-py differential (needs node)
```

- `test.typ` — assertions covering the arithmetic and the edges with no
  external reference. The suite passes exactly when the file runs cleanly.
- `civil_differential.py` — 29 031 dates from 1600 to 2400, every month
  boundary and leap-year edge, checked against Python's `datetime`.
- `compare.py` — every date-shaped string in a real fixture corpus plus
  hand-picked edge cases, run through datehog, V8 and flint-py. Gated on
  flint-py agreement, with one exception: where flint-py itself diverges from
  V8, datehog is expected to follow V8 rather than replicate the mistake (see
  [CHANGELOG.md](CHANGELOG.md) for the specific cases). Only a disagreement
  with flint-py that isn't explained by one of those two patterns fails the
  suite.

Current status: unit tests pass, 29 031/29 031 calendar dates match, and on
445/445 parser cases datehog matches flint-py or, where flint-py itself is
wrong, matches V8 instead.

## License

MIT.
