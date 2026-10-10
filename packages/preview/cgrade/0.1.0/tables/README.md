# tables — canonical school-grade scale data

One concern only: the numeric bounds of each grading scale plus the
modified Bavarian formula that maps passing foreign grades onto the
German 1.0–4.0 scale. `tests/vectors/*.json` is the executable form of
this contract. There is no CLDR equivalent for grades; this table is
original library work compiled from the sources below.

## Sources

- KMK Beschluss on the Gesamtnote including the Anlage with the
  modified Bavarian formula (`x = 1 + 3 * (Nmax - Nd) / (Nmax - Nmin)`,
  "es wird nicht gerundet": the result is truncated, never rounded).
- The anabin statement database (KMK/ZAB) for country scale bounds.
- The HSG (University of St. Gallen) conversion table for the
  Swiss reference points (6 → 1.0, 5.5 → 1.7, 5 → 2.5, 4.5 → 3.2,
  4 → 4.0).
- notenberechner.ch (University of Göttingen table) for the same
  Swiss reference row.

## Schema (`grades.json`)

| Key | Meaning |
|-----|---------|
| `scales` | Lowercase scale ID → `{best, worst, pass, step, higher_is_better}`. `best` is the best achievable grade, `worst` the worst possible grade (failing), `pass` the lowest still-passing grade (`Nmin` in the formula). `step` is an advisory display hint only, never used in computation. `higher_is_better` orients the scale: `true` means larger numbers are better (`ch`, `fr`, `it`, `es`, `us`), `false` means smaller numbers are better (`de`, `at`). |
| `supported` | Every scale ID the lookup accepts. |

## Formula (all languages)

Foreign → German: `x = 1 + 3 * (Nmax - Nd) / (Nmax - Nmin)`, where
`Nmax` is the best achievable foreign grade, `Nmin` the lowest passing
foreign grade, and `Nd` the achieved grade. The result is **truncated**
(not rounded) to 1 decimal, per KMK ("es wird nicht gerundet").

German → foreign (inverse): `Nd = Nmax - (x - 1) / 3 * (Nmax - Nmin)`,
truncated to 2 decimals.

`convert` chains both directions through the German scale
(`convert(a, b, v) = from_de(b, to_de(a, v))`) and is therefore a
documented approximation: the intermediate 1-decimal truncation loses
information, so same-system conversion is not the identity
(`convert("ch", "ch", 5.5) = 5.53`).

## Validity (all languages)

1. Unknown scale IDs yield no output (`None`/`null`/`none`).
2. `Nd` outside the passing interval `[pass .. best]` (in that system's
   orientation) yields no output, never an extrapolation. Failing grades
   have no Bavarian equivalent by construction.
3. `Nmin == Nmax` yields no output (division by zero).
4. Non-finite inputs yield no output.
5. `is_pass` additionally yields no output for grades outside the full
   `[worst .. best]` interval (grades that do not exist); existing but
   failing grades yield `false`.

## Float handling

Inputs are quantized to the nearest thousandth (half away from zero),
then all arithmetic runs on integers: tenths and hundredths are cut with
floored integer division, never with float `floor`. This keeps the KMK
truncation exact (e.g. an exact 1.29 stays 1.2 and an exact 2.3 stays
2.3) on every port. See the implementation comments.

Scale IDs are lowercase in tables, returned scale lists, and examples.
Lookups accept mixed-case input. No words or labels are stored: tone
belongs to applications, this library is data-only.
