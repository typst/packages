# stair-division

Typeset **synthetic division (Ruffini's rule)** in [Typst](https://typst.app) — the
classic three-row division box and the stacked factorization staircase.

Unlike a sign or variation table, this **computes**: you pass the coefficients and
the root, and it does the arithmetic *and* draws it — the products row, the running
sums, the boxed remainder. No more hand-building tables and quietly dropping the
middle row. No dependencies (native `table`).

<p align="center">
  <img src="https://raw.githubusercontent.com/13Stokes31/stair-division/v0.1.1/gallery/g1.png" width="45%" alt="Single division, three-row tableau">
  <img src="https://raw.githubusercontent.com/13Stokes31/stair-division/v0.1.1/gallery/g2.png" width="45%" alt="Full factorization staircase">
</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/13Stokes31/stair-division/v0.1.1/gallery/g3.png" width="45%" alt="Leading coefficient not one">
  <img src="https://raw.githubusercontent.com/13Stokes31/stair-division/v0.1.1/gallery/g4.png" width="45%" alt="Spanish labels">
</p>

## Usage

```typ
#import "@preview/stair-division:0.1.1": ruffini, ruffini-factor

// Divide x³ − 2x² + 1 by (x − 2):
#ruffini((1, -2, 0, 1), 2)
// → three-row tableau; Quotient: C(x) = x²   Remainder: R = 1

// Factor x³ − 6x² + 11x − 6 using its roots 1, 2, 3:
#ruffini-factor((1, -6, 11, -6), (1, 2, 3))
// → stacked staircase; Factorization: P(x) = (x − 1)(x − 2)(x − 3)
```

To use a local copy instead, put `lib.typ` beside your document and import
`#import "lib.typ": ruffini, ruffini-factor`.

**Coefficients** go highest degree first and **must include zeros** for missing
terms: `x³ − 2x² + 1` → `(1, -2, 0, 1)`.

**Divisor convention:** `root` is the `a` in `(x − a)`. To divide by `(x + 3)`,
pass `-3`.

### Fractions

After input conversion, arithmetic is **exact rational arithmetic**, within
Typst's integer limits, and fractions render as fractions. You can write them
two ways:

- **As a plain number** — integers are exact. A floating-point input is accepted
  only when a continued-fraction candidate reproduces the received float exactly,
  with a denominator at most `10000` and an absolute numerator at most `2^53 - 1`:

  ```typ
  #ruffini((2, -1, -1), 1/2)      // root 1/2   → shows ½
  #ruffini((1, 0, -3), 1/3)       // received float is recovered as ⅓
  #ruffini((0.25, 0.5, -1), 0.5)  // decimals too → ¼, ½
  ```

- **As a string** (in quotes) — specifies the rational value exactly, without
  going through floating-point. This works for `root` and `coefficients`:

  ```typ
  #ruffini(("1/2", "1/4", "-1/4"), "1/2")   // fractional coefficients + root
  ```

Strings must contain a signed integer or two signed integers separated by exactly
one `/`, with a nonzero denominator. Whitespace around the value or slash is
allowed (`" -2 / -4 "` becomes `1/2`); whitespace inside an integer and extra
components are rejected (`"1 2/3"`, `"1/2/3"`).

**Use strings when the intended rational value matters.** Typst evaluates bare
fractions before calling the package. Different rationals can produce the same
float, so their original value cannot always be recovered. The package uses no
approximation tolerance: unsupported floats stop with an error asking for a string,
rather than being rounded to zero, an integer, or a nearby fraction.

```typ
#ruffini((1, 0), 1/99991)              // error: use a string
#ruffini((1, 0), "1/99991")            // exact
#ruffini((1, 0), 1/10000000000)        // error; not rounded to zero
#ruffini((1, 0), "1/10000000000")      // exact
#ruffini((1, 0), 1.0000000001)         // error; not rounded to one
#ruffini((1, 0), "10000000001/10000000000") // exact
```

Typst uses [64-bit floating-point numbers](https://typst.app/docs/reference/foundations/float/).
If precision was already lost in an expression before calling the package,
input conversion cannot restore it.

**Variable.** The rendered labels use `x` by default; pass `variable: "t"` (or any
letter) to write `C(t)`, `P(z)`, `(t − 2)`, …

## `ruffini(coefficients, root, ...)`

One division `P(x) ÷ (x − root)`, rendered as the three-row tableau
(coefficients · products · results) with the remainder boxed.

| Parameter             | Default      | Meaning |
|-----------------------|--------------|---------|
| `coefficients`        | *(required)* | Array, highest degree first, zeros included. Numbers, or string fractions for unusual ones (see [Fractions](#fractions)). |
| `root`                | *(required)* | The `a` in `(x − a)`. A number (`-3`, `1/2`), or a string for unusual fractions (`"7/99991"`). |
| `lang`                | `"en"`       | Language of the rendered words: `"en"` or `"es"`. |
| `variable`            | `"x"`        | The polynomial's variable in the rendered labels. |
| `color`               | blue         | Accent color of the L-rule and the remainder box. |
| `show-result`         | `true`       | Append the *Quotient / Remainder* line. |
| `highlight-remainder` | `true`       | Draw the box around the remainder cell. |
| `trail`               | `false`      | Overlay teaching arrows (see below). |

### Explaining the algorithm (`trail`)

`trail: true` overlays the arrows that show *how* synthetic division works —
**bring the first coefficient down**, **multiply by the root** (the `×a`
diagonals), **add the column** (the `+` signs) — so it doubles as a lecture
figure. Drawn natively (no CeTZ). Best with integer coefficients.

<p align="center">
  <img src="https://raw.githubusercontent.com/13Stokes31/stair-division/v0.1.1/gallery/g5.png" width="60%" alt="Teaching trail: bring down, multiply by the root, add the column">
</p>

```typ
#ruffini((1, -2, 0, 1), 2, trail: true)
```

## `ruffini-factor(coefficients, roots, ...)`

Applies several `roots` in turn — each quotient becomes the next dividend — and
draws the stacked staircase. If every division is exact, it appends the
factorization; otherwise it says so.

| Parameter     | Default      | Meaning |
|---------------|--------------|---------|
| `coefficients`| *(required)* | Array, highest degree first, zeros included. |
| `roots`       | *(required)* | The successive values `a` to divide by, in order. Ints or string fractions. |
| `lang`        | `"en"`       | `"en"` or `"es"`. |
| `variable`    | `"x"`        | The polynomial's variable in the rendered labels. |
| `color`       | blue         | Accent color of the rules. |
| `show-result` | `true`       | Append the *Factorization* line. |
| `highlight-remainder` | `true` | Box each division's remainder cell. |

The factorization keeps the leading coefficient correct and, when a nonconstant
quotient remains after the supplied roots, shows it in parentheses — e.g.
`P(x) = (x − 1)(x + 1)(3x + 2)` or `P(x) = (x − 2)(x² + x + 1)`.

## What it handles

| Case | Behavior |
|---|---|
| Exact division | Remainder `0`, boxed; quotient shown. |
| **Nonzero remainder** | Boxed remainder; `R = …` in the result line. |
| Missing terms | Handled via the explicit zero coefficients you pass. |
| **Fractional root / coefficients** | Exact rational arithmetic; rendered as fractions. Bare numbers for ordinary fractions, strings for unusual ones. |
| Leading coefficient ≠ 1 | Preserved through the staircase and in the factorization. |
| Repeated zero roots | Rendered as separate factors, e.g. `P(x) = x x`. |
| **Remaining quotient** | Shown in parentheses after the factors for the supplied roots. |
| Supplied value is not a root | `ruffini-factor` reports "not an exact division". |

## Localization

Rendered words default to English. Pass `lang: "es"` for Spanish
(Cociente / Resto / Factorización). Adding a language is copying one block in the
`_i18n` dictionary in `lib.typ` and translating four words — contributions welcome.

## Compatibility

- Typst `>= 0.14.0`
- No dependencies.

## Known limitations

- Roots are supplied by the caller; the package does not search for them or test
  whether a remaining quotient is irreducible.
- Division is only by linear binomials `(x − a)`.
- Numerators, denominators, and intermediate arithmetic are limited by Typst's
  signed 64-bit integers. Large inputs can stop compilation with an overflow
  error, even when the reduced result would fit; this is not arbitrary-precision
  arithmetic.
- `trail` is available only for a single division. Its fixed cell sizes are best
  suited to integer coefficients; tall fractions can crowd the arrows.

## Verification

Run `python3 tests/run.py` from the repository root. It checks arithmetic against
Python's `Fraction`, compiles the rendering examples, and verifies expected input
errors. Only Python 3 and Typst are needed; there are no additional test dependencies.
See [TESTING.md](https://github.com/13Stokes31/stair-division/blob/v0.1.1/TESTING.md)
for the visual checklist and test sources in the repository.

## Changes in 0.1.1

- Repeated zero roots now compile correctly in the factorization line.
- Fraction strings are validated in full; extra components and spaces inside
  integers are rejected instead of silently changing the input.
- Float conversion requires an exact round trip and rejects nonfinite values.
  Unsupported floats now request a string instead of rounding to a nearby value.
- Added executable arithmetic and input-error checks; clarified precision and
  integer-size limits in the documentation.

## License

[MIT](LICENSE).
