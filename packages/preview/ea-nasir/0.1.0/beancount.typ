#import "account.typ": _mkAccount
#import "transaction.typ": _mkDelta, _mkTransaction
#import "ledger.typ": _addAccount, _addTransaction, mkLedger

/**
 * The default config to parse an account.
 * It is used when no other config is given.
 *
 * - positivePrefix: configures the account name prefix that will be interpreted as a monotone positive account.
 * - negativePrefix: configures the account name prefix that will be interpreted as a monotone negative account.
 */
#let parseAccountConfig = (positivePrefix: "expenses:", negativePrefix: "income:")

/**
 * Parse a beancount line to open an account.
 * We understand a comment on the account line as an optional description to the account.
 *
 * Per default config we:
 * - understand accounts starting with 'expenses:' to be monotone positive.
 * - understand account starting with 'income' to be monotone negative.
 */
#let _parseAccount = (line, config: parseAccountConfig) => {
  let match = line.match(
    regex("^(\d{4}-\d{2}-\d{2})\s+open\s+(\S+)\s+(\w+)\s*;?\s*(.*)$"),
  )

  if (match == none) { return (match, "line '" + line + "' is not a valid statement to open an account.") }

  let (date, name, currency, description) = match.captures

  let monotone = none
  if (name.starts-with(config.positivePrefix)) {
    monotone = "positive"
  }
  if (name.starts-with(config.negativePrefix)) {
    monotone = "negative"
  }

  return _mkAccount(name, date, currency, 0, description, monotone)
}

#let _parseTransaction = (ledger, lines) => {
  let (headline, ..deltaLines) = lines
  let matches = headline.match(regex("^(\d{4}-\d{2}-\d{2})\s+\*\s+\"([^\"]+)\"\s+\"([^\"]+)\"\s*;?\s*(.*)$"))

  if (matches == none) {
    return (none, "line '" + headline + "' is not a valid transaction start.")
  }

  let (date, name, narration, description) = matches.captures

  let deltas = ()
  let missingAccountNames = ()

  for line in deltaLines {
    let matches = line.trim().match(regex("^([\w:]+)\s+(-?\d+\.?\d*)\s+(\w+)\s*;?.*$"))

    if (matches != none) {
      let (name, amount, currency) = matches.captures
      let (delta, error) = _mkDelta(name, amount, currency)

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

    missingAccountNames.push(matches.captures.at(0))
  }

  for accountName in missingAccountNames {
    let account = ledger.accounts.at(accountName, default: none)

    if (account == none) {
      return (none, "Account '" + accountName + "' not found in ledger.")
    }

    let currency = account.currency

    let imbalance = decimal(0)
    for delta in deltas {
      if (delta.currency == currency) {
        imbalance += delta.amount
      }
    }

    let (delta, error) = _mkDelta(accountName, -imbalance, currency)
    if (error != none) { return (none, error) }

    deltas.push(delta)
  }

  let (t, e) = _mkTransaction(date, name, narration, deltas, description)

  assert.eq(e, none, message: "" + e)

  return (t, e)
}

#let isTransactionStart = line => {
  return line.starts-with(regex("^(\d{4}-\d{2}-\d{2})\s+\*\s+\""))
}

#let isIndented = line => { return line.starts-with(regex("^\s+")) }

#let isAccountOpen = line => {
  return line.starts-with(regex("^(\d{4}-\d{2}-\d{2})\s+open\s+"))
}

#let isComment = line => { return line.starts-with(regex("^\s*;")) }

#let isEmpty = line => {
  return line.trim() == ""
}

/**
 * _parseLedger takes a string in beancount format
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
#let _parseLedger = (text, config: parseAccountConfig) => {
  let ledger = mkLedger()
  let transactionLines = ()

  for line in text.split("\n") {
    // We ignore all empty and comment only lines.
    if (isEmpty(line) or isComment(line)) { continue }

    // If we're in a transaction block we continue with it.
    if (transactionLines.len() > 0) {
      if (isIndented(line)) {
        transactionLines.push(line)
        continue
      }

      let (transaction, error) = _parseTransaction(ledger, transactionLines)
      if (error != none) { return (none, error) }

      let (_ledger, error) = _addTransaction(ledger, transaction)
      if (error != none) { return (none, error) }

      ledger = _ledger
      transactionLines = ()
    }

    // Detect account opening
    if (isAccountOpen(line)) {
      let (account, error) = _parseAccount(line, config: config)
      if (error != none) { return (none, error) }

      let (_ledger, error) = _addAccount(ledger, account)
      if (error != none) { return (none, error) }

      ledger = _ledger
    }

    // Detect start of transaction
    if (isTransactionStart(line)) {
      transactionLines.push(line)
    }
  }
  // Maybe we were still parsing a transaction?
  if (transactionLines.len() > 0) {
    let (transaction, error) = _parseTransaction(ledger, transactionLines)
    if (error != none) { return (none, error) }

    let (_ledger, error) = _addTransaction(ledger, transaction)
    if (error != none) { return (none, error) }

    ledger = _ledger
  }

  return (ledger, none)
}

/**
 * parses text in the beancount format into a ledger.
 * - text: str
 * - config: optional, in the shape of parseAccountConfig
 */
#let parseLedger = (text, config: parseAccountConfig) => {
  let (ledger, error) = _parseLedger(text, config: config)
  assert.eq(error, none, message: "" + error)
  return ledger
}
