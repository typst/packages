# ez-today

Simply displays the current date with easy to use customization.

## Included languages

German, English, French, Italian, Czech, Portuguese, Slovakian and Polish months can be used out of the box. If you want to use a language that is not included, you can easily add it yourself. This is shown in the customization section below.

## Usage

The usage is very simple, because there is only the `today()` function.

```typ
#import "@preview/ez-today:1.1.0"

// To get the current date use this
#ez-today.today()
```

## Reference

### `today`

Prints the current date with given arguments.

```typ
#let today(
  lang: "de",
  format: "d. M Y",
  custom-months: ()
) = { .. }
```

**Arguments:**

- `lang`: [`str`] &mdash; Select one of the included languages (de, en, fr, it, cs, pt).
- `format`: [`str`] &mdash; Specify the output format.
- `custom-months`: [`array`] of [`str`] &mdash; Use custom names for each month. This array must have 12 entries. If this is used, the `lang` argument does nothing.

## Customization

The default output prints the full current date with German months like this:

```typ
#ez-today.today()   // 11. Oktober 2024
```

You can choose one of the included languages with the `lang` argument:

```typ
#ez-today.today(lang: "en")   // 11. October 2024
#ez-today.today(lang: "fr")   // 11. Octobre 2024
#ez-today.today(lang: "it")   // 11. Ottobre 2024
#ez-today.today(lang: "cs")   // 11. Října 2024
#ez-today.today(lang: "pt")   // 11. Outubro 2024
#ez-today.today(lang: "sk")   // 11. Októbra 2024
#ez-today.today(lang: "pl")   // 11. Października 2024
```

You can also change the format of the output with the `format` argument. Pass any string you want here, but know that the following characters will be replaced with the following:

- `d` &mdash; The current day as a decimal
- `D` &mdash; The current day as a zero-padded decimal
- `n` &mdash; The current month as a decimal (`lang` argument does nothing)
- `m` &mdash; The current month as a zero-padded decimal (`lang` argument does nothing)
- `M` &mdash; The current month as a string with either the selected language or the custom array
- `y` &mdash; The current year as a decimal with the last two numbers
- `Y` &mdash; The current year as a decimal

If you want the current date in ISO 8601 format, you can do so by passing `ISO` to the `format` argument.

Here are some examples:

```typ
#ez-today.today(format:"ISO")                   // 2024-10-11
#ez-today.today(lang: "en", format: "M d Y")    // October 11 2024
#ez-today.today(format: "m-d-y")                // 10-11-24
#ez-today.today(format: "d/m")                  // 11/10
#ez-today.today(format: "d.m.Y")                // 11.10.2024
```

Use the `custom-months` argument to give each month a custom name. You can add a new language or use short terms for each month.

```typ
// Defining some custom names
#let my-months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
// Get current date with custom names
#ez-today.today(custom-months: my-months, format: "M-y")    // Oct-24
```

## Changelog

### 1.1.0

- Day numbers with only one digit can be printed as a zero-padded number
- Fix: The ISO 8601 format now uses zero-padded day numbers

### 1.0.0

- Added support for Slovakian and Polish language by ShinoYumi
- Added function for ISO 8601 format by ShinoYumi
- Month numbers with only one digit are now zero-padded

### 0.3.0

- Added support for Portuguese language by Me-At-The-Age-Of-Git

### 0.2.0

- Added support for Czech language by ShinoYumi

### 0.1.0

- First release of ez-today
