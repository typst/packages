#import "account.typ": _mk-account
#import "transaction.typ": _mk-delta, _mk-transaction
#import "ledger.typ": _add-account, _add-transaction, mk-ledger

/**
 * The default config to parse an account.
 * It is used when no other config is given.
 *
 * - positive-prefix: configures the account name prefix that will be interpreted as a monotone positive account.
 * - negative-prefix: configures the account name prefix that will be interpreted as a monotone negative account.
 */
#let parse-account-config = (positive-prefix: "expenses:", negative-prefix: "income:")

/**
 * Parse a beancount line to open an account.
 * We understand a comment on the account line as an optional description to the account.
 *
 * Per default config we:
 * - understand accounts starting with 'expenses:' to be monotone positive.
 * - understand account starting with 'income' to be monotone negative.
 */
#let _parse-account = (line, config: parse-account-config) => {
  let match = line.match(
    regex("^(\d{4}-\d{2}-\d{2})\s+open\s+(\S+)\s+(\w+)\s*;?\s*(.*)$"),
  )

  if (match == none) { return (match, "line '" + line + "' is not a valid statement to open an account.") }

  let (date, name, currency, description) = match.captures

  let monotone = none
  if (name.starts-with(config.positive-prefix)) {
    monotone = "positive"
  }
  if (name.starts-with(config.negative-prefix)) {
    monotone = "negative"
  }

  return _mk-account(name, date, currency, 0, description, monotone)
}

#let _parse-transaction = (ledger, lines) => {
  let (headline, ..delta-lines) = lines
  let matches = headline.match(regex("^(\d{4}-\d{2}-\d{2})\s+\*\s+\"([^\"]+)\"\s+\"([^\"]+)\"\s*;?\s*(.*)$"))

  if (matches == none) {
    return (none, "line '" + headline + "' is not a valid transaction start.")
  }

  let (date, name, narration, description) = matches.captures

  let deltas = ()
  let missing-account-names = ()

  for line in delta-lines {
    let matches = line.trim().match(regex("^([\w:]+)\s+(-?\d+\.?\d*)\s+(\w+)\s*;?.*$"))

    if (matches != none) {
      let (name, amount, currency) = matches.captures
      let (delta, error) = _mk-delta(name, amount, currency)

      if (error != none) {
        return (none, error)
      }

      deltas.push(delta)
      continue
    }

    let matches = line.trim().match(regex("^([^;\s]+)\s*;?.*$"))

    if (matches == none) {
      return (none, "Could not read line '" + line + "' as a transaction delta.")
    }

    missing-account-names.push(matches.captures.at(0))
  }

  for account-name in missing-account-names {
    let account = ledger.accounts.at(account-name, default: none)

    if (account == none) {
      return (none, "Account '" + account-name + "' not found in ledger.")
    }

    let currency = account.currency

    let imbalance = decimal(0)
    for delta in deltas {
      if (delta.currency == currency) {
        imbalance += delta.amount
      }
    }

    let (delta, error) = _mk-delta(account-name, -imbalance, currency)
    if (error != none) { return (none, error) }

    deltas.push(delta)
  }

  let (t, e) = _mk-transaction(date, name, narration, deltas, description)

  assert.eq(e, none, message: "" + e)

  return (t, e)
}

#let is-transaction-start = line => {
  return line.starts-with(regex("^(\d{4}-\d{2}-\d{2})\s+\*\s+\""))
}

#let is-indented = line => { return line.starts-with(regex("^\s+")) }

#let is-account-open = line => {
  return line.starts-with(regex("^(\d{4}-\d{2}-\d{2})\s+open\s+"))
}

#let is-comment = line => { return line.starts-with(regex("^\s*;")) }

#let is-empty = line => {
  return line.trim() == ""
}

/**
 * _parse-ledger takes a string in beancount format
 * and parses it into a ledger.
 *
 * It understands:
 * - comments
 * - opening of accounts
 * - transactions
 *   - partial deltas,
 *     if only one option is missing for a currency
 *
 * It does not handle:
 * - includes
 * - assert statements
 * - padding accounts
 */
#let _parse-ledger = (text, config: parse-account-config) => {
  let ledger = mk-ledger()
  let transaction-lines = ()

  for line in text.split("\n") {
    // We ignore all empty and comment only lines.
    if (is-empty(line) or is-comment(line)) { continue }

    // If we're in a transaction block we continue with it.
    if (transaction-lines.len() > 0) {
      if (is-indented(line)) {
        transaction-lines.push(line)
        continue
      }

      let (transaction, error) = _parse-transaction(ledger, transaction-lines)
      if (error != none) { return (none, error) }

      let (_ledger, error) = _add-transaction(ledger, transaction)
      if (error != none) { return (none, error) }

      ledger = _ledger
      transaction-lines = ()
    }

    // Detect account opening
    if (is-account-open(line)) {
      let (account, error) = _parse-account(line, config: config)
      if (error != none) { return (none, error) }

      let (_ledger, error) = _add-account(ledger, account)
      if (error != none) { return (none, error) }

      ledger = _ledger
    }

    // Detect start of transaction
    if (is-transaction-start(line)) {
      transaction-lines.push(line)
    }
  }
  // Maybe we were still parsing a transaction?
  if (transaction-lines.len() > 0) {
    let (transaction, error) = _parse-transaction(ledger, transaction-lines)
    if (error != none) { return (none, error) }

    let (_ledger, error) = _add-transaction(ledger, transaction)
    if (error != none) { return (none, error) }

    ledger = _ledger
  }

  return (ledger, none)
}

/**
 * parses text in the beancount format into a ledger.
 * - text: str
 * - config: optional, in the shape of parse-account-config
 */
#let parse-ledger = (text, config: parse-account-config) => {
  let (ledger, error) = _parse-ledger(text, config: config)
  assert.eq(error, none, message: "" + error)
  return ledger
}
