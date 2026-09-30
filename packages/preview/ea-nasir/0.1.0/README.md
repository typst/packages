# ea-nasir

A package for plaintext accounting named after the famous copper merchant [Ea-nāṣir](https://en.wikipedia.org/wiki/Ea-n%C4%81%E1%B9%A3ir).

This package does not handle clay tablets, but sees value in the ideas of [plaintext accounting](https://plaintextaccounting.org/) and aims to make them available in typst.

As such this package allows for the creation of accounts and transactions and to group these in a ledger.

The beancount format can be used to read accounts and transactions from a text file.

## Usage example

Say you've got a beancount file like [ea-nasir.beancount](https://codeberg.org/runjak/ea-nasir/src/commit/65dd274671fdaf793be56c5ca2185b8265187751/ea-nasir.beancount).

You can read it into a ledger like this:

```typst
#import "@preview/ea-nasir:0.1.0": parseLedger, reportLedger

#let ledger = parseLedger(read("./ea-nasir.beancount"))
```

Which gives you a `ledger` holding all the accounts and transactions defined in that file.

You can then create a report on it like this:

```typst
#let report = reportLedger(ledger)
```

giving you a detailed report of the ledger.

`#report.prefixes` then holds data like this:

```typst
#{
  (
  assets: (
    EUR: (
      total:
      decimal("1"),
      plus: decimal("7"),
      minus: decimal("-6"),
    ),
  ),
  copper: (
    XCP: (
      total:
      decimal("0"),
      plus: decimal("8"),
      minus: decimal("-8"),
    ),
  ),
  expenses: (
    EUR: (
      total:
      decimal("6"),
      plus: decimal("6"),
      minus: decimal("0"),
    ),
  ),
  income: (
    EUR: (
      total:
      decimal("-7"),
      plus: 0,
      minus: decimal("-7"),
    ),
  ),
)
}
```

## Beancount syntax

The syntax used by this package is (currently) only a subset of what other tools support. This section describes what is supported.

### Example

```beancount
2026-08-01 open expenses:copper EUR ; Money spent on copper
2026-08-01 open expenses:travel EUR ; Travel costs
2026-08-01 open assets:money EUR    ; Money kept by us
2026-08-01 open copper:ea-nasir XCP ; Copper held by Ea-nāṣir
2026-08-01 open copper:warehouse XCP ; Copper in our warehouse

2026-08-02 * "Buy copper" "We buy some sub-par copper from ea-nasir"
  assets:money ; Inferred to -6 EUR
  expenses:copper 5 EUR
  expenses:travel 1 EUR
  copper:ea-nasir -4 XCP
  copper:warehouse 4 XCP
```

### Empty lines

Empty lines may contain arbitrary whitespace.

### Comments

Comments start with `;` and are generally allowed on their own lines as well as at the end of other lines.

### Dates

Dates generally have the Form `yyyy-MM-dd` - the date portion of an [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) string.

When comparing dates this package only cares about the day, never the time of day of account openings and transactions.

So a transaction may happen on the same day as an account is opened or later, but never before.

### Account opening

Account opening statements have the form of
`<date> open <account name> <currency>`.

They can have a trailing comment that will be interpreted as the `description` for the account, like so: `<date> open <account name> <currency> ; <description>`.

#### Monotone

Parsing config will decide on the monotone behaviour of an account: some accounts may only receive (`positive`) or only loose (`negative`) money.

The default here is to treat accounts where the name starts with `expenses:` as monotone positive, and ones where the name starts with `income:` as monotone negative.

### Transactions

Transactions generally start with a headline followed by a number of deltas.

A transaction headline has the form of `<date> * "<name>" "<narration>"`.

Like with the account opening statement we accept a trailing comment as description: `<date> * "<name>" "<description>"`.

Both `name` and `narration` are not allowed to contain `"` - because escaping just isn't implemented.

Deltas generally have this form: `<account name> <amount> <currency>`.

It is allowed for a delta to just be the `account name`, if that account is the only one of unspecified `amount` and `currency` so that the `amount` can be inferred from the other deltas, and the `currency` can be looked up from the ledger.

Recall our example:

```beancount
2026-08-02 * "Buy copper" "We buy some sub-par copper from ea-nasir"
  assets:money ; Inferred to -6 EUR
  expenses:copper 5 EUR
  expenses:travel 1 EUR
  copper:ea-nasir -4 XCP
  copper:warehouse 4 XCP
```

## Concepts

### Currency

- A currency is a string.
- Same string means same currency.
- Typical currencies are USD, EUR.
- We also allow 🍿, "milk" or whatever else.

### Date

- Dates are generally of type datetime
- We parse strings of the form yyyy-mm-dd into datetimes.

### Account

- A (hierarchical) name
- An opening date
- A currency (USD, EUR, 🍿)
- A starting amount - missing will default to 0.
- An optional description
- An optional rule called monotone
  - positive: amount may only grow.
  - negative: amount may only shrink.
  - If a monotone rule is given all deltas must obey it.
- A sorted log of deltas and times. We expect to append only.
  - deltas are always decimals.
  - times are always ?

#### Account naming

We understand the `:` in an account name to express hierarchy.

If we have accounts `Expenses:Foo` and `Expenses:Bar`
we can compute sums for both accounts as well as for `Expenses`.

### Transaction

- A date
- A name
- A narration
- An optional description to expand on name and narration.
- A list of account deltas
  - Triplets of account, amount, currency
  - All deltas of the same currency must sum up to 0.

### Ledger

- A collection of accounts and transactions.

### Reports

- A report is calculated over an account or over a ledger.
- A report can be constrained to a date range.
- A report adds up all sums (of a date range) for an account.
  - They are returned as (total, plus, minus).
  - If the opening time of the account is in the date range,
    the initial amount is included in the sum.

#### Account reports

The report for an account consists of the following fields:

- The `name` for the account the report was computed on
- The `currency` used for the account
- The `from`, `to` fields for the date range of the report
- The `total` sum
- The `plus` sum (sum of all positive additions to the account)
- The `minus` sum (sum of all negative additions to the account)

#### Ledger reports

The report for a ledger consists of the following fields:

- A dictionary of `accounts` that maps account names to the report for that account
- A dictionary of `prefixes` that map prefixes for account names (as separated by `:`) to currencySums
  - Where each currencySum maps a currency string to (total, plus, minus)
- An `all` dictionary, that is the union of `accounts` and `prefixes`.
- The `from`, `to` fields for the date range of the report

## API

This package exports the following functions:

### Beancount

The central function to parse beancount text is `parseLedger`.

It takes a second, optional argument config, which defaults to `parseAccountConfig`, but can be overwritten accordingly.

### Report

Two reporting functions exist:

- `reportLedger`: create a report for a ledger over an optional timeframe.
- `reportAccount`: create a report for an account over an optional timeframe.

### Ledger

A ledger is generally handled as immutable.
This means the following functions don't modify the ledger, but create a new one instead.

- `mkLedger`: creates a new, empty ledger
- `addAccount`: adds an account to a ledger
- `addTransaction`: applies a transaction to a ledger

### Transaction

The package exports the following functions for the transaction concept:

- `mkTransaction`: it is how transactions are created.
- `mkDelta`: a helper functions to create deltas for a transaction.
- `validateDelta`: a helper function to validate the structure of deltas.

### Account

The package exports two functions working on the account concept:

- `mkAccount`, which creates new accounts.
- `log`, which takes an account and some data to add to the log of an account. It handles the account as immutable.

### Date

We have two helper functions for date handling:

- `toDate`, which converts a date of the form `yyyy-MM-dd` to a `datetime`.
- `sameDayOrLater`, which compares two dates checking that the second argument is on the same day or later than the first argument.
